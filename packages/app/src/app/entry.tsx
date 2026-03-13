import App from "./app";
import { GlobalSDKProvider } from "./context/global-sdk";
import { GlobalSyncProvider } from "./context/global-sync";
import { LocalProvider } from "./context/local";
import { ServerProvider } from "./context/server";
import { DEFAULT_MAYA_SERVER_URL } from "./lib/openwork-server";
import { isTauriRuntime } from "./utils";

function getStoredOpenworkUrl(): string {
  if (typeof window === "undefined") return "";
  try {
    const raw = window.localStorage.getItem("openwork.server.urlOverride") ?? "";
    const trimmed = raw.trim();
    if (!trimmed) return "";
    const withProtocol = /^https?:\/\//.test(trimmed) ? trimmed : `https://${trimmed}`;
    return withProtocol.replace(/\/+$/, "");
  } catch {
    return "";
  }
}

export default function AppEntry() {
  const defaultUrl = (() => {
    // Desktop app connects to the local OpenCode engine.
    if (isTauriRuntime()) return "http://127.0.0.1:4096";

    // When running the web UI against an OpenWork server (e.g. Docker dev stack),
    // use the server's `/opencode` proxy instead of loopback.
    const openworkUrl =
      typeof import.meta.env?.VITE_OPENWORK_URL === "string"
        ? import.meta.env.VITE_OPENWORK_URL.trim()
        : "";
    if (openworkUrl) {
      return `${openworkUrl.replace(/\/+$/, "")}/opencode`;
    }

    // When the UI is served by the OpenWork server (Docker "remote" mode),
    // OpenCode is proxied at same-origin `/opencode`.
    if (import.meta.env.PROD && typeof window !== "undefined") {
      return `${window.location.origin}/opencode`;
    }

    // Dev: use stored or default MAYA server URL so health check and OpenCode use the same host (avoids 401 on /opencode/global/health).
    const stored = getStoredOpenworkUrl();
    const mayaBase = stored || (DEFAULT_MAYA_SERVER_URL?.trim() ?? "");
    if (mayaBase) {
      return `${mayaBase.replace(/\/+$/, "")}/opencode`;
    }

    // Dev fallback (Vite) - allow overriding for remote debugging.
    const envUrl =
      typeof import.meta.env?.VITE_OPENCODE_URL === "string"
        ? import.meta.env.VITE_OPENCODE_URL.trim()
        : "";
    return envUrl || "http://127.0.0.1:4096";
  })();

  return (
    <ServerProvider defaultUrl={defaultUrl}>
      <GlobalSDKProvider>
        <GlobalSyncProvider>
          <LocalProvider>
            <App />
          </LocalProvider>
        </GlobalSyncProvider>
      </GlobalSDKProvider>
    </ServerProvider>
  );
}
