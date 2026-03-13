import { spawn, execSync } from "node:child_process";
import { existsSync, openSync, readFileSync } from "node:fs";
import { access, mkdir } from "node:fs/promises";
import { createServer } from "node:net";
import { randomUUID } from "node:crypto";
import path from "node:path";

const cwd = process.cwd();
const isWin = process.platform === "win32";
const exe = isWin ? ".exe" : "";

const loadEnv = () => {
  const envPath = path.join(cwd, ".env");
  if (!existsSync(envPath)) return;
  const content = readFileSync(envPath, "utf-8");
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (m) {
      const key = m[1];
      const value = m[2].replace(/^["']|["']$/g, "").trim();
      if (!(key in process.env)) process.env[key] = value;
    }
  }
};
loadEnv();
const tmpDir = path.join(cwd, "tmp");

const ensureTmp = async () => {
  await mkdir(tmpDir, { recursive: true });
};

const isPortFree = (port: number, host: string) =>
  new Promise<boolean>((resolve) => {
    const server = createServer();
    server.once("error", () => resolve(false));
    server.listen(port, host, () => {
      server.close(() => resolve(true));
    });
  });

const getFreePort = (host: string) =>
  new Promise<number>((resolve, reject) => {
    const server = createServer();
    server.once("error", reject);
    server.listen(0, host, () => {
      const address = server.address();
      if (!address || typeof address === "string") {
        server.close(() => reject(new Error("Unable to resolve free port")));
        return;
      }
      const port = address.port;
      server.close(() => resolve(port));
    });
  });

const resolvePort = async (value: string | undefined, host: string) => {
  if (value) {
    const parsed = Number(value);
    if (Number.isFinite(parsed) && parsed > 0) {
      const free = await isPortFree(parsed, host);
      if (free) return parsed;
    }
  }
  return await getFreePort(host);
};

const logLine = (message: string) => {
  process.stdout.write(`${message}\n`);
};

const killProcessOnPort = (port: number) => {
  try {
    if (isWin) {
      const out = execSync(`netstat -ano | findstr :${port}`, { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] });
      const pids = new Set<string>();
      for (const line of out.split(/\r?\n/)) {
        if (!line.includes("LISTENING")) continue;
        const parts = line.trim().split(/\s+/);
        const pid = parts[parts.length - 1];
        if (pid && /^\d+$/.test(pid) && pid !== "0") pids.add(pid);
      }
      for (const pid of pids) {
        try {
          execSync(`taskkill /PID ${pid} /F`, { stdio: "ignore" });
          logLine(`[dev:headless-web] Killed process ${pid} on port ${port}`);
        } catch {
          // ignore
        }
      }
    } else {
      execSync(`lsof -ti:${port} 2>/dev/null | xargs kill -9 2>/dev/null || true`, { stdio: "ignore", shell: true });
      logLine(`[dev:headless-web] Killed process on port ${port}`);
    }
  } catch {
    // no process on port
  }
};

const readBool = (value: string | undefined) => {
  const normalized = (value ?? "").trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" || normalized === "on";
};

const silent = process.argv.includes("--silent");

const autoBuildEnabled = process.env.OPENWORK_DEV_HEADLESS_WEB_AUTOBUILD == null
  ? true
  : readBool(process.env.OPENWORK_DEV_HEADLESS_WEB_AUTOBUILD);

const runCommand = (command: string, args: string[]) =>
  new Promise<void>((resolve, reject) => {
    const spawnOpts: Parameters<typeof spawn>[2] = {
      cwd,
      env: process.env,
      stdio: silent ? "ignore" : "inherit",
    };
    if (isWin) {
      spawnOpts.shell = true;
    }
    const child = spawn(command, args, spawnOpts);
    child.on("error", reject);
    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(`${command} ${args.join(" ")} exited with code ${code ?? "unknown"}`));
    });
  });

const spawnLogged = (command: string, args: string[], logPath: string, env: NodeJS.ProcessEnv) => {
  const logFd = openSync(logPath, "w");
  const spawnOpts: Parameters<typeof spawn>[2] = { cwd, env, stdio: ["ignore", logFd, logFd] };
  if (isWin) spawnOpts.shell = true;
  return spawn(command, args, spawnOpts);
};

const shutdown = (label: string, code: number | null, signal: NodeJS.Signals | null) => {
  const reason = code !== null ? `code ${code}` : signal ? `signal ${signal}` : "unknown";
  logLine(`[dev:headless-web] ${label} exited (${reason})`);
  process.exit(code ?? 1);
};

await ensureTmp();

const desiredWebPort = Number(process.env.OPENWORK_WEB_PORT ?? "5173");
if (Number.isFinite(desiredWebPort) && desiredWebPort > 0) {
  const busy = !(await isPortFree(desiredWebPort, "127.0.0.1"));
  if (busy) {
    logLine(`[dev:headless-web] Port ${desiredWebPort} in use, killing existing process...`);
    killProcessOnPort(desiredWebPort);
    await new Promise((r) => setTimeout(r, 1500));
  }
}

const host = process.env.OPENWORK_HOST ?? "0.0.0.0";
const viteHost = process.env.VITE_HOST ?? process.env.HOST ?? host;
const publicHost = process.env.OPENWORK_PUBLIC_HOST ?? null;
const clientHost = publicHost ?? (host === "0.0.0.0" ? "127.0.0.1" : host);
const workspace = process.env.OPENWORK_WORKSPACE ?? cwd;
const openworkPort = await resolvePort(process.env.OPENWORK_PORT, "127.0.0.1");
const webPort = await resolvePort(process.env.OPENWORK_WEB_PORT, "127.0.0.1");
const openworkToken = process.env.OPENWORK_TOKEN ?? randomUUID();
const openworkHostToken = process.env.OPENWORK_HOST_TOKEN ?? randomUUID();
const openworkServerBin = path.join(cwd, "packages/server/dist/bin", `maya-server${exe}`);
const opencodeRouterBin = path.join(cwd, "packages/opencode-router/dist/bin", `opencode-router${exe}`);

const ensureOpenworkServer = async () => {
  try {
    await access(openworkServerBin);
  } catch {
    if (!autoBuildEnabled) {
      logLine(`[dev:headless-web] Missing OpenWork server binary at ${openworkServerBin}`);
      logLine("[dev:headless-web] Auto-build disabled (OPENWORK_DEV_HEADLESS_WEB_AUTOBUILD=0)");
      logLine("[dev:headless-web] Run: pnpm --filter maya-server build:bin");
      logLine("[dev:headless-web] Or unset/enable OPENWORK_DEV_HEADLESS_WEB_AUTOBUILD to auto-build.");
      process.exit(1);
    }

    logLine(`[dev:headless-web] Missing OpenWork server binary at ${openworkServerBin}`);
    logLine("[dev:headless-web] Auto-building: pnpm --filter maya-server build:bin");
    try {
      await runCommand("pnpm", ["--filter", "maya-server", "build:bin"]);
      await access(openworkServerBin);
    } catch (error) {
      logLine(`[dev:headless-web] Auto-build failed: ${error instanceof Error ? error.message : String(error)}`);
      process.exit(1);
    }
  }
};

const ensureOpencodeRouter = async () => {
  try {
    await access(opencodeRouterBin);
  } catch {
    if (!autoBuildEnabled) {
      logLine(`[dev:headless-web] Missing opencode-router binary at ${opencodeRouterBin}`);
      logLine("[dev:headless-web] Auto-build disabled (OPENWORK_DEV_HEADLESS_WEB_AUTOBUILD=0)");
      logLine("[dev:headless-web] Run: pnpm --filter opencode-router build:bin");
      logLine("[dev:headless-web] Or unset/enable OPENWORK_DEV_HEADLESS_WEB_AUTOBUILD to auto-build.");
      process.exit(1);
    }

    logLine(`[dev:headless-web] Missing opencode-router binary at ${opencodeRouterBin}`);
    logLine("[dev:headless-web] Auto-building: pnpm --filter opencode-router build:bin");
    try {
      await runCommand("pnpm", ["--filter", "opencode-router", "build:bin"]);
      await access(opencodeRouterBin);
    } catch (error) {
      logLine(`[dev:headless-web] Auto-build failed: ${error instanceof Error ? error.message : String(error)}`);
      process.exit(1);
    }
  }
};

const openworkUrl = `http://${clientHost}:${openworkPort}`;
const webUrl = `http://${clientHost}:${webPort}`;
// In practice we want opencode-router on for end-to-end messaging tests.
// Allow opt-out via OPENWORK_DEV_OPENCODE_ROUTER=0.
const opencodeRouterEnabled = process.env.OPENWORK_DEV_OPENCODE_ROUTER == null
  ? true
  : readBool(process.env.OPENWORK_DEV_OPENCODE_ROUTER);
const opencodeRouterRequired = readBool(process.env.OPENWORK_DEV_OPENCODE_ROUTER_REQUIRED);
const viteEnv = {
  ...process.env,
  HOST: viteHost,
  PORT: String(webPort),
  VITE_OPENWORK_URL: process.env.VITE_OPENWORK_URL ?? openworkUrl,
  VITE_OPENWORK_PORT: process.env.VITE_OPENWORK_PORT ?? String(openworkPort),
  VITE_OPENWORK_TOKEN: process.env.VITE_OPENWORK_TOKEN ?? openworkToken,
};
const headlessEnv = {
  ...process.env,
  OPENWORK_WORKSPACE: workspace,
  OPENWORK_HOST: host,
  OPENWORK_PORT: String(openworkPort),
  OPENWORK_TOKEN: openworkToken,
  OPENWORK_HOST_TOKEN: openworkHostToken,
  OPENWORK_SERVER_BIN: openworkServerBin,
  OPENWORK_SIDECAR_SOURCE: process.env.OPENWORK_SIDECAR_SOURCE ?? "external",
  OPENCODE_ROUTER_BIN: process.env.OPENCODE_ROUTER_BIN ?? opencodeRouterBin,
};

await ensureOpenworkServer();
if (opencodeRouterEnabled) {
  await ensureOpencodeRouter();
}

logLine("[dev:headless-web] Starting services");
logLine(`[dev:headless-web] Workspace: ${workspace}`);
logLine(`[dev:headless-web] OpenWork server: ${openworkUrl}`);
logLine(`[dev:headless-web] Web host: ${viteHost}`);
logLine(`[dev:headless-web] Web port: ${webPort}`);
logLine(`[dev:headless-web] Web URL: ${webUrl}`);
logLine(
  `[dev:headless-web] OpenCodeRouter: ${opencodeRouterEnabled ? "on" : "off"} (set OPENWORK_DEV_OPENCODE_ROUTER=0 to disable)`,
);
logLine(`[dev:headless-web] OPENWORK_TOKEN: ${openworkToken}`);
logLine(`[dev:headless-web] OPENWORK_HOST_TOKEN: ${openworkHostToken}`);
logLine(`[dev:headless-web] Web logs: ${path.relative(cwd, path.join(tmpDir, "dev-web.log"))}`);
logLine(`[dev:headless-web] Headless logs: ${path.relative(cwd, path.join(tmpDir, "dev-headless.log"))}`);

const headlessProcess = spawnLogged(
  "pnpm",
  [
    "--filter",
    "maya-orchestrator",
    "dev",
    "--",
    "start",
    "--workspace",
    workspace,
    "--approval",
    "auto",
    "--allow-external",
    "--no-opencode-auth",
    "--opencode-router",
    opencodeRouterEnabled ? "true" : "false",
    ...(opencodeRouterRequired ? ["--opencode-router-required"] : []),
    "--openwork-host",
    host,
    "--openwork-port",
    String(openworkPort),
    "--openwork-token",
    openworkToken,
    "--openwork-host-token",
    openworkHostToken,
  ],
  path.join(tmpDir, "dev-headless.log"),
  headlessEnv,
);

const waitForHealth = async (url: string, timeoutMs = 90_000): Promise<boolean> => {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const res = await fetch(url);
      if (res.ok) return true;
    } catch {
      // ignore
    }
    await new Promise((r) => setTimeout(r, 800));
  }
  return false;
};

logLine("[dev:headless-web] Waiting for OpenWork server to be ready...");
const healthy = await waitForHealth(`${openworkUrl}/health`);
if (!healthy) {
  logLine("[dev:headless-web] OpenWork server did not become healthy in time. Check tmp/dev-headless.log");
  headlessProcess.kill("SIGTERM");
  process.exit(1);
}
logLine("[dev:headless-web] OpenWork server ready, starting web UI...");

killProcessOnPort(webPort);
await new Promise((r) => setTimeout(r, 1500));

const webProcess = spawnLogged(
  "pnpm",
  [
    "--filter",
    "@different-ai/openwork-ui",
    "run",
    "dev",
    "--",
    "--host",
    viteHost,
    "--port",
    String(webPort),
  ],
  path.join(tmpDir, "dev-web.log"),
  viteEnv,
);

const stopAll = (signal: NodeJS.Signals) => {
  webProcess.kill(signal);
  headlessProcess.kill(signal);
};

process.on("SIGINT", () => {
  stopAll("SIGINT");
});
process.on("SIGTERM", () => {
  stopAll("SIGTERM");
});

webProcess.on("exit", (code, signal) => shutdown("web", code, signal));
headlessProcess.on("exit", (code, signal) => shutdown("orchestrator", code, signal));
