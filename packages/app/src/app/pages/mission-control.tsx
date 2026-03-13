import { For, Show, createSignal, onCleanup, createMemo, createEffect, on, untrack } from "solid-js";
import { Box, ChevronDown, ChevronRight, Circle, Gauge, HeartPulse, History, Loader2, MessageCircle, MoreHorizontal, Plus, Zap, CheckCircle2, AlertCircle, Clock, PlayCircle, BookOpen, SlidersHorizontal } from "lucide-solid";
import type { DashboardTab, View, SettingsTab, AgentStatus } from "../types";
import type { ThemeMode } from "../theme";
import type { DashboardViewProps } from "./dashboard";
import { getWorkspaceTaskLoadErrorDisplay, isTauriRuntime } from "../utils";
import StatusBar from "../components/status-bar";

export interface MissionControlViewProps extends DashboardViewProps {}

export default function MissionControlView(props: MissionControlViewProps) {
    // Refresh data when entering mission control - use on() to avoid tracking function identity
    createEffect(
        on(
            () => props.view,
            (view) => {
                if (view === "mission-control") {
                    untrack(() => {
                        props.refreshSoulData?.({ force: true });
                        props.refreshScheduledJobs?.({ force: true });
                    });
                }
            }
        )
    );

    const [workspaceExpanded, setWorkspaceExpanded] = createSignal<Record<string, boolean>>({});
    const [workspaceMenuId, setWorkspaceMenuId] = createSignal<string | null>(null);
    let workspaceMenuRef: HTMLDivElement | undefined;

    const onWindowMouseDown = (event: MouseEvent) => {
        if (workspaceMenuId() && workspaceMenuRef && !workspaceMenuRef.contains(event.target as Node)) {
            setWorkspaceMenuId(null);
        }
    };
    window.addEventListener("mousedown", onWindowMouseDown);
    onCleanup(() => window.removeEventListener("mousedown", onWindowMouseDown));

    const logoSrc = () => "/maya-v1-logo.png";

    const isWorkspaceExpanded = (id: string) => workspaceExpanded()[id] ?? id === props.activeWorkspaceId;
    const toggleWorkspaceExpanded = (id: string) => {
        setWorkspaceExpanded((prev) => ({ ...prev, [id]: !isWorkspaceExpanded(id) }));
    };
    const expandWorkspace = (id: string) => {
        setWorkspaceExpanded((prev) => ({ ...prev, [id]: true }));
    };

    const workspaceLabel = (workspace: any) =>
        workspace.displayName?.trim() ||
        workspace.openworkWorkspaceName?.trim() ||
        workspace.name?.trim() ||
        workspace.path?.trim() ||
        "Worker";

    const workspaceKindLabel = (workspace: any) =>
        workspace.workspaceType === "remote"
            ? workspace.sandboxBackend === "docker" ||
                Boolean(workspace.sandboxRunId?.trim()) ||
                Boolean(workspace.sandboxContainerName?.trim())
                ? "Sandbox"
                : "Remote"
            : "Local";

    const previewSessions = (workspaceId: string, sessions: any[]) => {
        const active = props.activeWorkspaceId === workspaceId;
        if (!active) return [];
        return sessions.slice(0, 5);
    };

    const handleUpdatePillClick = () => {
        if (props.updateStatus?.state === "ready" && !props.anyActiveRuns) {
            props.installUpdateAndRestart();
            return;
        }
        props.setTab("settings");
        props.setSettingsTab("advanced");
    };

    const updatePillLabel = () => {
        const state = props.updateStatus?.state;
        if (state === "ready") {
            return props.anyActiveRuns ? "Update ready" : "Install update";
        }
        if (state === "downloading") {
            return "Downloading";
        }
        return "Update available";
    };

    const updatePillButtonTone = () => {
        const state = props.updateStatus?.state;
        if (state === "ready") {
            return props.anyActiveRuns
                ? "text-amber-11 hover:text-amber-11 hover:bg-amber-3/30"
                : "text-green-11 hover:text-green-11 hover:bg-green-3/30";
        }
        if (state === "downloading") {
            return "text-blue-11 hover:text-blue-11 hover:bg-blue-3/30";
        }
        return "text-dls-secondary hover:text-emerald-11 hover:bg-emerald-3/25";
    };

    const updatePillDotTone = () => {
        const state = props.updateStatus?.state;
        if (state === "ready") {
            return props.anyActiveRuns ? "text-amber-10 fill-amber-10" : "text-green-10 fill-green-10";
        }
        if (state === "downloading") {
            return "text-blue-10";
        }
        return "text-emerald-10 fill-emerald-10";
    };

    const updatePillVersionTone = () => {
        const state = props.updateStatus?.state;
        if (state === "ready") {
            return props.anyActiveRuns ? "text-amber-11/75" : "text-green-11/75";
        }
        return "text-dls-secondary/70";
    };

    const showUpdatePill = () => {
        if (!isTauriRuntime()) return false;
        const state = props.updateStatus?.state;
        return state === "available" || state === "downloading" || state === "ready";
    };

    const agentColumns = createMemo(() => {
        const working: any[] = [];
        const waitingInstruction: any[] = [];
        const waitingPermission: any[] = [];
        const completed: any[] = [];

        const getStatusFromSession = (session: any) => {
            if (session.status === "running" || session.status === "streaming") {
                if (session.permissionPending) {
                    return "waiting_permission";
                }
                return "working";
            }
            if (session.status === "completed" || session.status === "done") {
                return "completed";
            }
            return "waiting_instruction";
        };

        const getWorkspaceName = (workspaceId: string) => {
            const workspace = props.workspaces?.find((ws: any) => ws.id === workspaceId);
            return workspace?.displayName || workspace?.name || "Unknown";
        };

        for (const group of props.workspaceSessionGroups || []) {
            for (const session of group.sessions || []) {
                const status = getStatusFromSession(session);
                const agent = {
                    id: session.id,
                    name: session.title || "Untitled Task",
                    status,
                    workspaceName: getWorkspaceName(group.workspace?.id),
                    currentTask: props.sessionStatusById[session.id] === "running" ? "Processing..." : undefined,
                };

                switch (status) {
                    case "working":
                        working.push(agent);
                        break;
                    case "waiting_permission":
                        waitingPermission.push(agent);
                        break;
                    case "completed":
                        completed.push(agent);
                        break;
                    default:
                        waitingInstruction.push(agent);
                }
            }
        }

        return { working, waitingInstruction, waitingPermission, completed };
    });

    const getAgentCountByStatus = (status: AgentStatus) => {
        const cols = agentColumns();
        switch (status) {
            case "working": return cols.working.length;
            case "waiting_instruction": return cols.waitingInstruction.length;
            case "waiting_permission": return cols.waitingPermission.length;
            case "completed": return cols.completed.length;
            default: return 0;
        }
    };

    const tokenUsageDisplay = createMemo(() => {
        let totalTokens = 0;
        for (const group of props.workspaceSessionGroups || []) {
            for (const session of group.sessions || []) {
                if ((session as any).tokens) {
                    const t = (session as any).tokens;
                    totalTokens += t.input + t.output + t.reasoning + (t.cache?.read || 0) + (t.cache?.write || 0);
                }
            }
        }
        if (totalTokens === 0) {
            return "0";
        }
        if (totalTokens >= 1000000) {
            return (totalTokens / 1000000).toFixed(1) + "M";
        }
        if (totalTokens >= 1000) {
            return (totalTokens / 1000).toFixed(1) + "K";
        }
        return totalTokens.toString();
    });

    const openSettings = (tab: SettingsTab = "general") => {
        props.setSettingsTab(tab);
        props.setTab("settings");
        props.setView("dashboard");
    };

    const openProviderAuth = async () => {
        await props.openProviderAuthModal();
    };

    return (
        <div class="flex h-screen w-full text-dls-text overflow-hidden" style={{ background: "var(--bg-gradient)", "background-attachment": "fixed" }}>
            <style>{`
                .mc-glass-panel {
                    background: var(--glass-bg);
                    backdrop-filter: blur(16px);
                    -webkit-backdrop-filter: blur(16px);
                    border: 1px solid var(--glass-stroke-soft);
                    box-shadow: var(--glass-shadow);
                }
                .monochrome-img {
                    filter: grayscale(1) contrast(1.1) brightness(1.05);
                    opacity: 0.8;
                }
                .mc-btn-glass {
                    background: var(--glass-bg-strong);
                    border: 1px solid var(--glass-stroke-soft);
                    backdrop-filter: blur(8px);
                    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                }
                .mc-btn-glass:hover {
                    background: var(--glass-bg-strong);
                    transform: translateY(-1px);
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                }
                .mc-icon-block {
                    background: var(--glass-bg-strong);
                    border: 1px solid var(--glass-stroke-soft);
                }
            `}</style>

            <aside class="w-64 hidden md:flex flex-col border-r p-4" style={{ background: "var(--glass-bg)", "backdrop-filter": "blur(20px)", "-webkit-backdrop-filter": "blur(20px)", "border-right": "1px solid var(--glass-stroke-soft)" }}>
                {/* Maya branding */}
                <div class="flex flex-col items-center gap-3 mb-8 px-1 pt-2 cursor-pointer" onClick={() => props.setView("mission-control")}>
                    <img src={logoSrc()} alt="Maya" class="h-20 w-auto drop-shadow-md" />
                    <span class="text-lg font-bold tracking-tight" style={{ color: "var(--dls-text-primary)" }}>MAYA</span>
                </div>
                <div class="flex-1 overflow-y-auto">
                    <Show when={showUpdatePill()}>
                        <button
                            type="button"
                            class={`group mb-3 w-full flex items-center gap-2 rounded-md px-2 py-1.5 text-xs font-medium transition-colors ${updatePillButtonTone()}`}
                            onClick={handleUpdatePillClick}
                        >
                            <Show when={props.updateStatus?.state === "downloading"} fallback={
                                <Circle size={8} class={`${updatePillDotTone()} shrink-0`} />
                            }>
                                <Loader2 size={13} class={`animate-spin shrink-0 ${updatePillDotTone()}`} />
                            </Show>
                            <span class="flex-1 text-left">{updatePillLabel()}</span>
                            <Show when={props.updateStatus?.version}>
                                {(version) => (
                                    <span class={`ml-auto font-mono text-[10px] ${updatePillVersionTone()}`}>v{version()}</span>
                                )}
                            </Show>
                        </button>
                    </Show>

                    <div class="space-y-3 mb-3">
                        <For each={props.workspaceSessionGroups || []}>
                            {(group) => {
                                const workspace = () => group.workspace;
                                const isConnecting = () => props.connectingWorkspaceId === workspace()?.id;
                                const isMenuOpen = () => workspaceMenuId() === workspace()?.id;
                                const taskLoadError = () => getWorkspaceTaskLoadErrorDisplay(workspace(), group.error);
                                const soulStatus = () => props.soulStatusByWorkspaceId[workspace()?.id] ?? null;
                                const soulEnabled = () => Boolean(soulStatus()?.enabled);

                                return (
                                    <div class="space-y-1">
                                        <div class="relative group">
                                            <div
                                                role="button"
                                                tabIndex={0}
                                                class="w-full flex items-center justify-between h-10 px-3 rounded-lg text-left transition-colors text-dls-text hover:bg-dls-hover"
                                                onClick={() => {
                                                    expandWorkspace(workspace().id);
                                                    props.activateWorkspace(workspace().id);
                                                }}
                                            >
                                                <button
                                                    type="button"
                                                    class="mr-2 -ml-1 p-1 rounded-md text-dls-secondary hover:text-dls-text hover:bg-dls-active"
                                                    onClick={(event) => {
                                                        event.stopPropagation();
                                                        toggleWorkspaceExpanded(workspace().id);
                                                    }}
                                                >
                                                    <Show when={isWorkspaceExpanded(workspace().id)} fallback={<ChevronRight size={14} />}>
                                                        <ChevronDown size={14} />
                                                    </Show>
                                                </button>
                                                <div class="min-w-0 flex-1">
                                                    <div class="text-sm font-medium truncate">{workspaceLabel(workspace())}</div>
                                                    <div class="text-[11px] text-dls-secondary flex items-center gap-1.5">
                                                        <span>{workspaceKindLabel(workspace())}</span>
                                                        <Show when={soulEnabled()}>
                                                            <span class="inline-flex items-center gap-1 rounded-full border border-rose-7/40 bg-rose-3/40 px-1.5 py-0.5 text-[10px] text-rose-11">
                                                                <HeartPulse size={10} />
                                                                Soul
                                                            </span>
                                                        </Show>
                                                    </div>
                                                </div>
                                                <Show when={group.status === "loading"}>
                                                    <Loader2 size={14} class="animate-spin text-dls-secondary mr-1" />
                                                </Show>
                                                <Show when={group.status === "error"}>
                                                    <span class={`text-[10px] px-2 py-0.5 rounded-full border ${taskLoadError().tone === "offline"
                                                        ? "border-amber-7/50 text-amber-11 bg-amber-3/30"
                                                        : "border-red-7/50 text-red-11 bg-red-3/30"
                                                        }`}>
                                                        {taskLoadError().label}
                                                    </span>
                                                </Show>
                                                <Show when={isConnecting()}>
                                                    <Loader2 size={14} class="animate-spin text-dls-secondary" />
                                                </Show>
                                            </div>
                                            <div class="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <button
                                                    type="button"
                                                    class="p-1 rounded-md text-dls-secondary hover:text-dls-text hover:bg-dls-active"
                                                    onClick={(event) => {
                                                        event.stopPropagation();
                                                        const wsId = workspace().id;
                                                        expandWorkspace(wsId);
                                                        if (wsId === props.activeWorkspaceId) {
                                                            props.createSessionAndOpen();
                                                            return;
                                                        }
                                                        void (async () => {
                                                            await Promise.resolve(props.activateWorkspace(wsId));
                                                            props.createSessionAndOpen();
                                                        })();
                                                    }}
                                                    disabled={props.newTaskDisabled}
                                                >
                                                    <Plus size={14} />
                                                </button>
                                                <button
                                                    type="button"
                                                    class="p-1 rounded-md text-dls-secondary hover:text-dls-text hover:bg-dls-active"
                                                    onClick={(event) => {
                                                        event.stopPropagation();
                                                        setWorkspaceMenuId((current) =>
                                                            current === workspace().id ? null : workspace().id
                                                        );
                                                    }}
                                                >
                                                    <MoreHorizontal size={14} />
                                                </button>
                                            </div>
                                            <Show when={isMenuOpen()}>
                                                <div
                                                    ref={(el) => (workspaceMenuRef = el)}
                                                    class="absolute right-2 top-[calc(100%+4px)] z-20 w-44 rounded-lg border border-dls-border bg-dls-surface shadow-lg p-1"
                                                    onClick={(event) => event.stopPropagation()}
                                                >
                                                    <button
                                                        type="button"
                                                        class="w-full text-left px-2 py-1.5 text-sm rounded-md hover:bg-dls-hover"
                                                        onClick={() => {
                                                            props.openRenameWorkspace(workspace().id);
                                                            setWorkspaceMenuId(null);
                                                        }}
                                                    >
                                                        Edit name
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="w-full text-left px-2 py-1.5 text-sm rounded-md hover:bg-dls-hover text-red-11"
                                                        onClick={() => {
                                                            props.forgetWorkspace(workspace().id);
                                                            setWorkspaceMenuId(null);
                                                        }}
                                                    >
                                                        Remove worker
                                                    </button>
                                                </div>
                                            </Show>
                                        </div>

                                        <div class="mt-0.5 space-y-0.5 border-l border-dls-border ml-2">
                                            <Show when={isWorkspaceExpanded(workspace().id)}>
                                                <For each={previewSessions(workspace().id, group.sessions || [])}>
                                                    {(session) => (
                                                        <div
                                                            role="button"
                                                            tabIndex={0}
                                                            class={`group flex items-center justify-between h-8 px-3 rounded-lg cursor-pointer relative overflow-hidden ml-2 w-[calc(100%-0.5rem)] ${props.selectedSessionId === session.id
                                                                ? "bg-dls-active text-dls-text"
                                                                : "hover:bg-dls-hover"
                                                                }`}
                                                            onClick={() => props.setView("session", session.id)}
                                                            onKeyDown={(event) => {
                                                                if (event.key !== "Enter" && event.key !== " ") return;
                                                                if (event.isComposing || event.keyCode === 229) return;
                                                                event.preventDefault();
                                                                props.setView("session", session.id);
                                                            }}
                                                        >
                                                            <span class="text-sm text-dls-text truncate mr-2 font-medium">
                                                                {session.title || "Untitled Task"}
                                                            </span>
                                                        </div>
                                                    )}
                                                </For>
                                            </Show>
                                        </div>
                                    </div>
                                );
                            }}
                        </For>
                    </div>

                    <button
                        type="button"
                        class="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-medium text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                        onClick={() => props.openCreateWorkspace()}
                    >
                        <Plus size={14} />
                        Add a worker
                    </button>
                </div>
            </aside>

            <main class="flex-1 flex flex-col overflow-hidden" style={{ background: "transparent" }}>
                <header class="h-14 flex items-center justify-between px-6 glass-header z-10 shrink-0">
                    <div class="flex items-center gap-3 min-w-0">
                        <h1 class="text-lg font-medium tracking-tight" style={{ color: "var(--dls-text-primary)" }}>
                            Mission Control
                        </h1>
                        <Show
                            when={props.clientConnected}
                            fallback={
                                <span class="text-[10px] px-2.5 py-1 rounded-full font-semibold uppercase tracking-wider mc-glass-panel" style={{ color: "#f87171" }}>
                                    Offline
                                </span>
                            }
                        >
                            <span class="text-[10px] px-2.5 py-1 rounded-full font-semibold uppercase tracking-wider mc-glass-panel" style={{ color: "#34d399" }}>
                                Operational
                            </span>
                        </Show>
                    </div>
                    <div class="flex items-center gap-4"></div>
                </header>

                <div class="flex-1 overflow-y-auto px-8 py-8">
                    <div class="flex flex-wrap gap-4 mb-8">
                        <div class="mc-glass-panel px-6 py-4 rounded-2xl flex-1 min-w-[180px]">
                            <p class="text-[10px] uppercase tracking-wider mb-2" style={{ color: "var(--dls-text-secondary)" }}>Total Agents</p>
                            <div class="flex items-end gap-2">
                                <span class="text-2xl font-normal" style={{ color: "var(--dls-text-primary)" }}>
                                    {agentColumns().working.length + agentColumns().waitingInstruction.length + agentColumns().waitingPermission.length + agentColumns().completed.length}
                                </span>
                                <span class="text-xs font-light pb-0.5" style={{ color: "var(--dls-text-secondary)" }}>active</span>
                            </div>
                        </div>
                        <div class="mc-glass-panel px-6 py-4 rounded-2xl flex-1 min-w-[180px]">
                            <p class="text-[10px] uppercase tracking-wider mb-2" style={{ color: "var(--dls-text-secondary)" }}>Token Usage</p>
                            <div class="flex items-end gap-2">
                                <span class="text-2xl font-normal" style={{ color: "var(--dls-text-primary)" }}>{tokenUsageDisplay()}</span>
                                <span class="text-xs font-semibold pb-1 ml-auto" style={{ color: "var(--dls-text-secondary)" }}>Total</span>
                            </div>
                        </div>
                        <div class="mc-glass-panel px-6 py-4 rounded-2xl flex-1 min-w-[180px]">
                            <p class="text-[10px] uppercase tracking-wider mb-2" style={{ color: "var(--dls-text-secondary)" }}>Active Workers</p>
                            <div class="flex items-end gap-2">
                                <span class="text-2xl font-normal" style={{ color: "var(--dls-text-primary)" }}>{props.workspaces?.length || 0}</span>
                                <span class="text-xs font-semibold pb-1 ml-auto" style={{ color: props.workspaces?.length > 0 ? "#34d399" : "#f87171" }}>
                                    {props.workspaces?.length > 0 ? "Online" : "Offline"}
                                </span>
                            </div>
                        </div>
                        <div class="mc-glass-panel px-6 py-4 rounded-2xl flex-1 min-w-[180px]">
                            <p class="text-[10px] uppercase tracking-wider mb-2" style={{ color: "var(--dls-text-secondary)" }}>Node Cluster</p>
                            <div class="flex items-end gap-2">
                                <span class="text-2xl font-normal" style={{ color: "var(--dls-text-primary)" }}>MAYA-01</span>
                                <span class="text-xs font-semibold pb-1 ml-auto" style={{ color: props.clientConnected ? "#34d399" : "#f87171" }}>
                                    {props.clientConnected ? "Online" : "Offline"}
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
                        <div class="mc-glass-panel rounded-2xl p-4 min-h-[200px]">
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center gap-2">
                                    <PlayCircle size={16} class="text-blue-11" />
                                    <h3 class="text-sm font-semibold" style={{ color: "var(--dls-text-primary)" }}>Working</h3>
                                </div>
                                <span class="text-xs px-2 py-0.5 rounded-full bg-blue-3/50 text-blue-11 font-medium">
                                    {getAgentCountByStatus("working")}
                                </span>
                            </div>
                            <div class="flex flex-col gap-2">
                                <For each={agentColumns().working}>
                                    {(agent) => (
                                        <div class="p-3 rounded-xl bg-blue-3/20 border border-blue-7/30 hover:bg-blue-3/30 transition-colors cursor-pointer"
                                            onClick={() => props.setView("session", agent.id)}
                                        >
                                            <div class="flex items-center gap-2 mb-1">
                                                <div class="size-2 rounded-full bg-blue-10 animate-pulse" />
                                                <span class="text-xs font-medium truncate" style={{ color: "var(--dls-text-primary)" }}>{agent.name}</span>
                                            </div>
                                            <p class="text-[10px] truncate" style={{ color: "var(--dls-text-secondary)" }}>{agent.workspaceName}</p>
                                        </div>
                                    )}
                                </For>
                                <Show when={agentColumns().working.length === 0}>
                                    <div class="text-center py-8 text-xs" style={{ color: "var(--dls-text-secondary)" }}>
                                        No agents working
                                    </div>
                                </Show>
                            </div>
                        </div>

                        <div class="mc-glass-panel rounded-2xl p-4 min-h-[200px]">
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center gap-2">
                                    <Clock size={16} class="text-amber-11" />
                                    <h3 class="text-sm font-semibold" style={{ color: "var(--dls-text-primary)" }}>Waiting</h3>
                                </div>
                                <span class="text-xs px-2 py-0.5 rounded-full bg-amber-3/50 text-amber-11 font-medium">
                                    {getAgentCountByStatus("waiting_instruction")}
                                </span>
                            </div>
                            <div class="flex flex-col gap-2">
                                <For each={agentColumns().waitingInstruction}>
                                    {(agent) => (
                                        <div class="p-3 rounded-xl bg-amber-3/20 border border-amber-7/30 hover:bg-amber-3/30 transition-colors cursor-pointer"
                                            onClick={() => props.setView("session", agent.id)}
                                        >
                                            <div class="flex items-center gap-2 mb-1">
                                                <div class="size-2 rounded-full bg-amber-10" />
                                                <span class="text-xs font-medium truncate" style={{ color: "var(--dls-text-primary)" }}>{agent.name}</span>
                                            </div>
                                            <p class="text-[10px] truncate" style={{ color: "var(--dls-text-secondary)" }}>{agent.workspaceName}</p>
                                        </div>
                                    )}
                                </For>
                                <Show when={agentColumns().waitingInstruction.length === 0}>
                                    <div class="text-center py-8 text-xs" style={{ color: "var(--dls-text-secondary)" }}>
                                        No agents waiting
                                    </div>
                                </Show>
                            </div>
                        </div>

                        <div class="mc-glass-panel rounded-2xl p-4 min-h-[200px]">
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center gap-2">
                                    <AlertCircle size={16} class="text-orange-11" />
                                    <h3 class="text-sm font-semibold" style={{ color: "var(--dls-text-primary)" }}>Permissions</h3>
                                </div>
                                <span class="text-xs px-2 py-0.5 rounded-full bg-orange-3/50 text-orange-11 font-medium">
                                    {getAgentCountByStatus("waiting_permission")}
                                </span>
                            </div>
                            <div class="flex flex-col gap-2">
                                <For each={agentColumns().waitingPermission}>
                                    {(agent) => (
                                        <div class="p-3 rounded-xl bg-orange-3/20 border border-orange-7/30 hover:bg-orange-3/30 transition-colors cursor-pointer"
                                            onClick={() => props.setView("session", agent.id)}
                                        >
                                            <div class="flex items-center gap-2 mb-1">
                                                <div class="size-2 rounded-full bg-orange-10 animate-pulse" />
                                                <span class="text-xs font-medium truncate" style={{ color: "var(--dls-text-primary)" }}>{agent.name}</span>
                                            </div>
                                            <p class="text-[10px] truncate" style={{ color: "var(--dls-text-secondary)" }}>{agent.workspaceName}</p>
                                        </div>
                                    )}
                                </For>
                                <Show when={agentColumns().waitingPermission.length === 0}>
                                    <div class="text-center py-8 text-xs" style={{ color: "var(--dls-text-secondary)" }}>
                                        No pending permissions
                                    </div>
                                </Show>
                            </div>
                        </div>

                        <div class="mc-glass-panel rounded-2xl p-4 min-h-[200px]">
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center gap-2">
                                    <CheckCircle2 size={16} class="text-green-11" />
                                    <h3 class="text-sm font-semibold" style={{ color: "var(--dls-text-primary)" }}>Completed</h3>
                                </div>
                                <span class="text-xs px-2 py-0.5 rounded-full bg-green-3/50 text-green-11 font-medium">
                                    {getAgentCountByStatus("completed")}
                                </span>
                            </div>
                            <div class="flex flex-col gap-2">
                                <For each={agentColumns().completed}>
                                    {(agent) => (
                                        <div class="p-3 rounded-xl bg-green-3/20 border border-green-7/30 hover:bg-green-3/30 transition-colors cursor-pointer"
                                            onClick={() => props.setView("session", agent.id)}
                                        >
                                            <div class="flex items-center gap-2 mb-1">
                                                <div class="size-2 rounded-full bg-green-10" />
                                                <span class="text-xs font-medium truncate" style={{ color: "var(--dls-text-primary)" }}>{agent.name}</span>
                                            </div>
                                            <p class="text-[10px] truncate" style={{ color: "var(--dls-text-secondary)" }}>{agent.workspaceName}</p>
                                        </div>
                                    )}
                                </For>
                                <Show when={agentColumns().completed.length === 0}>
                                    <div class="text-center py-8 text-xs" style={{ color: "var(--dls-text-secondary)" }}>
                                        No completed tasks
                                    </div>
                                </Show>
                            </div>
                        </div>
                    </div>
                </div>

                <StatusBar
                    clientConnected={props.clientConnected}
                    openworkServerStatus={props.openworkServerStatus}
                    developerMode={props.developerMode}
                    onOpenSettings={() => openSettings("general")}
                    onOpenMessaging={() => {
                        props.setTab("identities");
                        props.setView("dashboard");
                    }}
                    onOpenProviders={openProviderAuth}
                    onOpenMcp={() => {
                        props.setTab("mcp");
                        props.setView("dashboard");
                    }}
                    providerConnectedIds={props.providerConnectedIds}
                    mcpStatuses={props.mcpStatuses}
                />
            </main>

            <aside class="w-56 hidden md:flex flex-col p-4 border-l" style={{ background: "var(--glass-bg)", "backdrop-filter": "blur(20px)", "-webkit-backdrop-filter": "blur(20px)", "border-left": "1px solid var(--glass-stroke-soft)" }}>
                <div class="space-y-1 pt-2">
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${props.tab === "scheduled" && props.view === "dashboard"
                            ? "bg-dls-active text-dls-text"
                            : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                            }`}
                        onClick={() => {
                            props.setTab("scheduled");
                            props.setView("dashboard");
                        }}
                    >
                        <History size={18} />
                        Automations
                    </button>
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors bg-dls-active text-dls-text`}
                        onClick={() => props.setView("mission-control")}
                    >
                        <Gauge size={18} class="text-dls-accent" />
                        Mission Control
                    </button>
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${props.tab === "docs" && props.view === "dashboard"
                            ? "bg-dls-active text-dls-text"
                            : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                            }`}
                        onClick={() => {
                            props.setTab("docs");
                            props.setView("dashboard");
                        }}
                    >
                        <BookOpen size={18} />
                        Docs
                    </button>
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${props.tab === "soul" && props.view === "dashboard"
                            ? "bg-dls-active text-dls-text"
                            : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                            }`}
                        onClick={() => {
                            props.setTab("soul");
                            props.setView("dashboard");
                        }}
                    >
                        <HeartPulse size={18} />
                        Soul
                    </button>
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${props.tab === "skills" && props.view === "dashboard"
                            ? "bg-dls-active text-dls-text"
                            : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                            }`}
                        onClick={() => {
                            props.setTab("skills");
                            props.setView("dashboard");
                        }}
                    >
                        <Zap size={18} />
                        Skills
                    </button>
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${(props.tab === "mcp" || props.tab === "plugins") && props.view === "dashboard"
                            ? "bg-dls-active text-dls-text"
                            : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                            }`}
                        onClick={() => {
                            props.setTab("mcp");
                            props.setView("dashboard");
                        }}
                    >
                        <Box size={18} />
                        Extensions
                    </button>
                    <button
                        type="button"
                        class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${props.tab === "identities" && props.view === "dashboard"
                            ? "bg-dls-active text-dls-text"
                            : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                            }`}
                        onClick={() => {
                            props.setTab("identities");
                            props.setView("dashboard");
                        }}
                    >
                        <MessageCircle size={18} />
                        Messaging
                    </button>
                    <Show when={props.developerMode}>
                        <button
                            type="button"
                            class={`w-full h-10 flex items-center gap-3 px-3 rounded-lg text-sm font-medium transition-colors ${props.tab === "config" && props.view === "dashboard"
                                ? "bg-dls-active text-dls-text"
                                : "text-dls-secondary hover:text-dls-text hover:bg-dls-hover"
                                }`}
                            onClick={() => {
                                props.setTab("config");
                                props.setView("dashboard");
                            }}
                        >
                            <SlidersHorizontal size={18} />
                            Advanced
                        </button>
                    </Show>
                </div>
            </aside>
        </div>
    );
}
