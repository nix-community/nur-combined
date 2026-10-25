export type Run = {
  id: number;
  headBranch: string;
  status: string;
  conclusion: string | null;
};

function headers(token: string): HeadersInit {
  return {
    Authorization: `token ${token}`,
    Accept: "application/json",
    "Content-Type": "application/json",
  };
}

async function req<T>(
  url: string,
  token: string,
  init?: RequestInit,
): Promise<T> {
  const res = await fetch(url, {
    ...init,
    headers: { ...headers(token), ...(init?.headers ?? {}) },
  });
  if (!res.ok) {
    throw new Error(
      `forgejo request failed: ${res.status} ${res.statusText} for ${url}`,
    );
  }
  return (await res.json()) as T;
}

type ApiRun = {
  id: number;
  head_branch: string;
  status: string;
  conclusion?: string | null;
};

export async function listRecentRuns(
  baseUrl: string,
  repo: string,
  token: string,
  limit: number,
): Promise<Run[]> {
  const data = await req<ApiRun[] | { workflow_runs: ApiRun[] }>(
    `${baseUrl}/repos/${repo}/actions/runs?limit=${limit}`,
    token,
  );
  // Forgejo (like GitHub) envelopes runs in `{ workflow_runs: [...] }`.
  const runs = Array.isArray(data) ? data : (data.workflow_runs ?? []);
  return runs.map((r) => ({
    id: r.id,
    headBranch: r.head_branch,
    status: r.status,
    conclusion: r.conclusion ?? null,
    jobs: [],
  }));
}

// Task logs live on disk (Forgejo 15 exposes no token-API for logs or
// reruns): <logDir>/<owner>/<repo>/<taskId%256 as %02x>/<taskId>.log[.zst].
// Missing/expired logs return "" so the caller classifies unknown.
export async function readTaskLogTail(
  logDir: string,
  repo: string,
  taskId: number,
  maxLines: number,
): Promise<string> {
  const rel = `${repo}/${(taskId % 256).toString(16).padStart(2, "0")}/${taskId}.log`;
  const plain = `${logDir}/${rel}`;
  const file = Bun.file(plain);
  let text: string | null = null;
  if (await file.exists()) {
    text = await file.text();
  } else {
    const proc = Bun.spawn(["zstd", "-dc", `${plain}.zst`], {
      stdout: "pipe",
      stderr: "ignore",
    });
    const code = await proc.exited;
    if (code === 0) text = await new Response(proc.stdout).text();
  }
  if (text === null) return "";
  return text.split("\n").slice(-maxLines).join("\n");
}

// Infra-cancel recovery: re-dispatch the workflow (build.yml carries a
// workflow_dispatch trigger). Equivalent to a rerun for our pipeline.
export async function dispatchWorkflow(
  baseUrl: string,
  repo: string,
  token: string,
  workflow: string,
  ref: string,
): Promise<void> {
  const res = await fetch(
    `${baseUrl}/repos/${repo}/actions/workflows/${workflow}/dispatches`,
    {
      method: "POST",
      headers: {
        Authorization: `token ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ ref }),
    },
  );
  if (!res.ok) {
    throw new Error(
      `forgejo dispatch failed: ${res.status} for ${workflow}@${ref}`,
    );
  }
}

export async function openOrReusePr(
  baseUrl: string,
  repo: string,
  token: string,
  head: string,
  base: string,
  title: string,
  body: string,
): Promise<number> {
  const open = await req<{ number: number; head: { ref: string } }[]>(
    `${baseUrl}/repos/${repo}/pulls?state=open&limit=50`,
    token,
  );
  const existing = open.find((p) => p.head.ref === head);
  if (existing) return existing.number;
  const created = await req<{ number: number }>(
    `${baseUrl}/repos/${repo}/pulls`,
    token,
    {
      method: "POST",
      body: JSON.stringify({ head, base, title, body }),
    },
  );
  return created.number;
}

export type { ApiRun };
