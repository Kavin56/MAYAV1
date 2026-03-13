import { Show, createSignal } from "solid-js";
import { AlertCircle, CheckCircle2, Github, Loader2, Lock, Eye, EyeOff } from "lucide-solid";
import Button from "./button";
import { cloneGithubSkill, type CloneGitSkillResult } from "../lib/tauri";

type GitCloneModalProps = {
  open: boolean;
  onClose: () => void;
  onSuccess: (skillName: string) => void;
  activeWorkspaceRoot: string;
};

export default function GitCloneModal(props: GitCloneModalProps) {
  const [url, setUrl] = createSignal("");
  const [token, setToken] = createSignal("");
  const [showToken, setShowToken] = createSignal(false);
  const [loading, setLoading] = createSignal(false);
  const [result, setResult] = createSignal<CloneGitSkillResult | null>(null);

  const handleClone = async () => {
    const urlValue = url().trim();
    if (!urlValue) return;

    setLoading(true);
    setResult(null);

    try {
      const tokenValue = token().trim() || null;
      const cloneResult = await cloneGithubSkill(urlValue, tokenValue, props.activeWorkspaceRoot);
      setResult(cloneResult);

      if (cloneResult.ok && cloneResult.skillName) {
        setTimeout(() => {
          props.onSuccess(cloneResult.skillName!);
        }, 1500);
      }
    } catch (error) {
      setResult({
        ok: false,
        message: error instanceof Error ? error.message : "An unexpected error occurred",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setUrl("");
    setToken("");
    setResult(null);
    setLoading(false);
    props.onClose();
  };

  const isValidUrl = () => {
    const urlValue = url().trim();
    return (
      urlValue.includes("github.com") &&
      (urlValue.includes("/") || urlValue.includes(":"))
    );
  };

  return (
    <Show when={props.open}>
      <div class="fixed inset-0 z-50 flex items-center justify-center">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={handleClose} />
        
        <div class="relative bg-gray-2 border border-gray-6 rounded-xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-6 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="size-8 rounded-lg bg-gray-12 flex items-center justify-center">
                <Github class="w-5 h-5 text-gray-1" />
              </div>
              <h2 class="text-lg font-semibold text-gray-12">Add Skill from GitHub</h2>
            </div>
          </div>

          <div class="p-6 space-y-4">
            <Show when={!result()}>
              <div>
                <label class="block text-sm font-medium text-gray-11 mb-1.5">
                  Repository URL
                </label>
                <input
                  type="text"
                  value={url()}
                  onInput={(e) => setUrl(e.currentTarget.value)}
                  placeholder="https://github.com/owner/repo"
                  class="w-full px-3 py-2 bg-gray-1 border border-gray-6 rounded-lg text-gray-12 placeholder-gray-8 focus:outline-none focus:ring-2 focus:ring-blue-500/50"
                />
                <p class="text-xs text-gray-10 mt-1">
                  Enter a public or private GitHub repository containing a Claude skill
                </p>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-11 mb-1.5 flex items-center gap-1.5">
                  <Lock class="w-3.5 h-3.5" />
                  Personal Access Token
                  <span class="text-gray-10 font-normal">(optional)</span>
                </label>
                <div class="relative">
                  <input
                    type={showToken() ? "text" : "password"}
                    value={token()}
                    onInput={(e) => setToken(e.currentTarget.value)}
                    placeholder="ghp_xxxxxxxxxxxx"
                    class="w-full px-3 py-2 pr-10 bg-gray-1 border border-gray-6 rounded-lg text-gray-12 placeholder-gray-8 focus:outline-none focus:ring-2 focus:ring-blue-500/50"
                  />
                  <button
                    type="button"
                    onClick={() => setShowToken(!showToken())}
                    class="absolute right-2 top-1/2 -translate-y-1/2 text-gray-10 hover:text-gray-11"
                  >
                    <Show when={showToken()} fallback={<Eye class="w-4 h-4" />}>
                      <EyeOff class="w-4 h-4" />
                    </Show>
                  </button>
                </div>
                <p class="text-xs text-gray-10 mt-1">
                  Required for private repositories. Token needs <code class="bg-gray-6 px-1 rounded">repo</code> scope.
                </p>
              </div>

              <div class="flex items-center gap-2 text-sm text-green-11 bg-green-3/30 p-3 rounded-lg">
                <CheckCircle2 class="w-4 h-4 shrink-0" />
                <span>Dependencies will be installed automatically</span>
              </div>
            </Show>

            <Show when={result()}>
              <div class={`p-4 rounded-lg ${result()!.ok ? "bg-green-3/30" : "bg-red-3/30"}`}>
                <div class="flex items-start gap-3">
                  <Show
                    when={result()!.ok}
                    fallback={<AlertCircle class="w-5 h-5 text-red-11 shrink-0 mt-0.5" />}
                  >
                    <CheckCircle2 class="w-5 h-5 text-green-11 shrink-0 mt-0.5" />
                  </Show>
                  <div>
                    <p class={`font-medium ${result()!.ok ? "text-green-11" : "text-red-11"}`}>
                      {result()!.ok ? "Success!" : "Error"}
                    </p>
                    <p class="text-sm text-gray-11 mt-1">{result()!.message}</p>
                  </div>
                </div>
              </div>
            </Show>
          </div>

          <div class="px-6 py-4 border-t border-gray-6 flex justify-end gap-3">
            <Button variant="ghost" onClick={handleClose} disabled={loading()}>
              {result()?.ok ? "Close" : "Cancel"}
            </Button>
            <Show when={!result()?.ok}>
              <Button
                onClick={handleClone}
                disabled={!isValidUrl() || loading()}
              >
                <Show when={loading()} fallback="Clone & Install">
                  <Loader2 class="w-4 h-4 animate-spin mr-2" />
                  Cloning...
                </Show>
              </Button>
            </Show>
          </div>
        </div>
      </div>
    </Show>
  );
}
