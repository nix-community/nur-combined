import { spawn, type ChildProcess } from "node:child_process";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const providerId = "offline";
const modelsDir = join(process.env.XDG_CONFIG_HOME ?? join(process.env.HOME ?? ".", ".config"), "pi", "offline-provider", "models");
const fallbackContextWindow = 32768;

interface LlamaModel {
  id: string;
  meta?: { n_ctx?: number; n_ctx_train?: number };
}

async function startServer(): Promise<{ child: ChildProcess; url: string; models: LlamaModel[] }> {
  const child = spawn("@llama_server@", [
    "--models-dir", modelsDir,
    "--fit-ctx", "131072",
    "--fit-target", "512",
    "--no-warmup",
    "--host", "127.0.0.1",
    "--port", "0",
  ], { stdio: ["ignore", "ignore", "pipe"] });
  const stderr = child.stderr!;
  let listeningResolve: ((url: string) => void) | undefined;
  let listeningReject: ((error: Error) => void) | undefined;
  const listening = new Promise<string>((resolve, reject) => {
    listeningResolve = resolve;
    listeningReject = reject;
  });
  const timeout = setTimeout(() => listeningReject?.(new Error("Timed out waiting for llama-server to listen")), 120_000);
  timeout.unref();
  let output = "";
  stderr.on("data", (chunk: Buffer) => {
    const text = chunk.toString();
    // process.stderr.write(`[${providerId}] ${text}`);
    if (!listeningResolve) return;
    output = `${output}${text}`.slice(-4096);
    const match = output.match(/listening on http:\/\/127\.0\.0\.1:(\d+)/);
    if (!match) return;
    clearTimeout(timeout);
    listeningResolve(`http://127.0.0.1:${match[1]}`);
    listeningResolve = undefined;
  });
  child.once("error", (error) => listeningReject?.(error));
  child.once("exit", (code) => listeningReject?.(new Error(`llama-server exited with status ${code ?? "unknown"}`)));

  try {
    const url = await listening;
    const deadline = Date.now() + 120_000;
    while (Date.now() < deadline) {
      try {
        if ((await fetch(`${url}/health`)).ok) {
          const response = await fetch(`${url}/models`);
          if (!response.ok) throw new Error(`llama-server model discovery returned HTTP ${response.status}`);
          const payload = (await response.json()) as { data?: unknown };
          const models = Array.isArray(payload.data)
            ? payload.data.filter((model): model is LlamaModel =>
                typeof model === "object" && model !== null && typeof (model as LlamaModel).id === "string",
              )
            : [];
          return { child, url, models };
        }
      } catch (error) {
        if (error instanceof Error && error.message.includes("model discovery")) throw error;
      }
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
    throw new Error("Timed out waiting for llama-server health");
  } catch (error) {
    stop(child);
    throw error;
  }
}

function stop(child: ChildProcess | undefined): void {
  if (!child || child.exitCode !== null) return;
  child.kill("SIGTERM");
  setTimeout(() => { if (child.exitCode === null) child.kill("SIGKILL"); }, 2_000).unref();
}

export default async function offlineProvider(pi: ExtensionAPI): Promise<void> {
  const { child, url, models } = await startServer();
  pi.registerProvider(providerId, {
    name: "Offline llama.cpp",
    baseUrl: `${url}/v1`,
    api: "openai-completions",
    apiKey: "local",
    models: models.map((model) => {
      const contextWindow = model.meta?.n_ctx_train ?? model.meta?.n_ctx ?? fallbackContextWindow;
      return {
        id: model.id,
        name: model.id,
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow,
        maxTokens: contextWindow,
        compat: {
          supportsStore: false,
          supportsDeveloperRole: false,
          supportsReasoningEffort: false,
          supportsUsageInStreaming: true,
          supportsStrictMode: false,
          maxTokensField: "max_tokens",
        },
      };
    }),
  });
  pi.on("session_shutdown", () => stop(child));
}
