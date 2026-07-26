import {
  createBashTool,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { isAbsolute, relative, resolve, sep } from "node:path";

const repositoryRoot = process.cwd();
const packageName = process.env.PACKAGE ?? "";
const packageRoot = resolve(repositoryRoot, "pkgs", packageName);
const pathTools: Record<string, true> = {
  read: true,
  write: true,
  edit: true,
  grep: true,
  find: true,
  ls: true,
};
const writeTools: Record<string, true> = { write: true, edit: true };
const secretName = /(key|token|secret|password|passwd|credential)/i;
const blockedCommands: Array<[RegExp, string]> = [
  [/\bsudo\b/i, "sudo is not allowed"],
  [/(^|[;&|()\s])gh(?:\s|$)/i, "GitHub CLI access is not allowed"],
  [
    /\bgit\b[^\n;&|]*\b(commit|push|reset|clean|checkout|remote|tag)\b/i,
    "repository-mutating git commands are not allowed",
  ],
  [/\brm\s+(?:-[^\s]*r[^\s]*f|-[^\s]*f[^\s]*r|--recursive)\b/i, "recursive forced removal is not allowed"],
  [/\b(?:chmod|chown)\b[^\n;&|]*\b777\b/i, "world-writable permission changes are not allowed"],
];

function isWithin(root: string, candidate: string): boolean {
  const path = relative(root, candidate);
  return path === "" || (path !== ".." && !path.startsWith(`..${sep}`) && !isAbsolute(path));
}

function pathBlockReason(toolName: string, inputPath: string): string | undefined {
  const candidate = resolve(repositoryRoot, inputPath);
  const isWrite = writeTools[toolName] === true;
  const allowedRoot = isWrite ? packageRoot : repositoryRoot;
  if (!isWithin(allowedRoot, candidate)) {
    return `${toolName} path is outside ${isWrite ? `pkgs/${packageName}` : "the repository"}: ${inputPath}`;
  }
  return undefined;
}

function commandBlockReason(command: string): string | undefined {
  return blockedCommands.find(([pattern]) => pattern.test(command))?.[1];
}

function sanitizeEnvironment(environment: NodeJS.ProcessEnv): NodeJS.ProcessEnv {
  return Object.fromEntries(Object.entries(environment).filter(([name]) => !secretName.test(name)));
}

function selfTest(): void {
  const expect = (condition: boolean, message: string) => {
    if (!condition) throw new Error(`Pi CI guard self-test failed: ${message}`);
  };

  expect(pathBlockReason("write", `pkgs/${packageName}/default.nix`) === undefined, "package write rejected");
  expect(pathBlockReason("write", "flake.nix") !== undefined, "repository write allowed");
  expect(pathBlockReason("read", "flake.nix") === undefined, "repository read rejected");
  expect(pathBlockReason("read", "../outside") !== undefined, "external read allowed");
  expect(commandBlockReason("git push origin main") !== undefined, "git push allowed");
  expect(commandBlockReason("nix build .#example") === undefined, "safe build rejected");
  const environment = sanitizeEnvironment({ PATH: "/bin", DENDRO_API_KEY: "secret" });
  expect(environment.PATH === "/bin", "safe environment removed");
  expect(environment.DENDRO_API_KEY === undefined, "model credential exposed to bash");
}

export default function (pi: ExtensionAPI) {
  if (!/^[a-z][a-z0-9_-]{0,63}$/.test(packageName)) {
    throw new Error("PACKAGE must be a validated Nix package attribute");
  }
  if (process.env.PI_GUARD_SELF_TEST === "1") selfTest();

  const bashTool = createBashTool(repositoryRoot, {
    spawnHook: ({ command, cwd, env }) => ({
      command,
      cwd,
      env: sanitizeEnvironment(env),
    }),
  });
  pi.registerTool({
    ...bashTool,
    execute: async (id, params, signal, onUpdate, _ctx) => {
      return bashTool.execute(id, params, signal, onUpdate);
    },
  });

  pi.on("tool_call", async (event) => {
    if (event.toolName === "bash") {
      let command: unknown;
      if (event.input && typeof event.input === "object" && "command" in event.input) {
        command = event.input.command;
      }
      const reason = commandBlockReason(typeof command === "string" ? command : "");
      return reason ? { block: true, reason } : undefined;
    }

    if (pathTools[event.toolName] !== true) return undefined;
    let inputPath: unknown;
    if (event.input && typeof event.input === "object" && "path" in event.input) {
      inputPath = event.input.path;
    }
    if (typeof inputPath !== "string" || inputPath.length === 0) return undefined;
    const reason = pathBlockReason(event.toolName, inputPath);
    return reason ? { block: true, reason } : undefined;
  });
}
