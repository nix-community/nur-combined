import { mkdirSync } from "node:fs";
import { join } from "node:path";

export function planFixBranch(runId: number): string {
  return `fix/ci-${runId}`;
}

const SECRET_PATTERNS = [
  /oc_sk_[A-Za-z0-9_-]+/g,
  /Bearer\s+[A-Za-z0-9._~-]+/gi,
  /token\s+[A-Za-z0-9._~-]{8,}/gi,
];

export function redactSecrets(text: string): string {
  let out = text;
  for (const re of SECRET_PATTERNS) {
    out = out.replace(re, "[redacted]");
  }
  return out;
}

export function buildFixPrBody(opts: {
  runId: number;
  logExcerpt: string;
  explanation: string;
}): string {
  const { runId, logExcerpt, explanation } = opts;
  const excerpt =
    logExcerpt.length > 4000 ? logExcerpt.slice(-4000) : logExcerpt;
  return redactSecrets(
    [
      `Automated fix for run ${runId}.`,
      "",
      "## Failure excerpt",
      "```",
      excerpt,
      "```",
      "",
      "## Fix",
      explanation,
      "",
    ].join("\n"),
  );
}

async function sh(cmd: string[], cwd: string): Promise<void> {
  const proc = Bun.spawn(cmd, { cwd, stdout: "inherit", stderr: "inherit" });
  const code = await proc.exited;
  if (code !== 0) throw new Error(`command failed (${code}): ${cmd.join(" ")}`);
}

export async function prepareFixWorkdir(args: {
  repoUrl: string;
  ref: string;
  branch: string;
  workRoot: string;
}): Promise<string> {
  const { repoUrl, ref, branch, workRoot } = args;
  mkdirSync(workRoot, { recursive: true });
  const dir = join(workRoot, branch.replaceAll("/", "-"));
  const git = (a: string[]) => sh(["git", ...a], dir);
  try {
    await Bun.$`test -d ${dir}/.git`.text();
    await git(["fetch", "origin", ref]);
  } catch {
    await sh(["git", "clone", repoUrl, dir], workRoot);
    await git(["fetch", "origin", ref]);
  }
  await git(["checkout", "-B", branch, `origin/${ref}`]);
  return dir;
}
