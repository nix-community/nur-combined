import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  DEFAULT_POLL_OPTS,
  memoryState,
  runPollOnce,
  type PollForgejo,
  type StateStore,
} from "./harness";
import { dispatchWorkflow, readTaskLogTail } from "./forgejo";

type Args = {
  dryRun: boolean;
  repo: string;
  limit: number;
  baseUrl: string;
  stateDir: string;
  maxReruns: number;
  logDir: string;
  workflow: string;
};

function parseArgs(argv: string[]): Args {
  const args: Args = {
    dryRun: false,
    repo: process.env.MAINTAINER_REPO ?? DEFAULT_POLL_OPTS.repo,
    limit: 5,
    baseUrl: process.env.FORGEJO_API_URL ?? "https://git.toyvo.dev/api/v1",
    stateDir: process.env.MAINTAINER_STATE_DIR ?? "./.maintainer-state",
    maxReruns: DEFAULT_POLL_OPTS.maxReruns,
    logDir: process.env.FORGEJO_LOG_DIR ?? "/var/lib/forgejo/data/actions_log",
    workflow: "build.yml",
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--dry-run") args.dryRun = true;
    else if (a === "--repo") args.repo = argv[++i];
    else if (a === "--limit") args.limit = Number(argv[++i]);
    else if (a === "--base-url") args.baseUrl = argv[++i];
    else if (a === "--state-dir") args.stateDir = argv[++i];
    else if (a === "--max-reruns") args.maxReruns = Number(argv[++i]);
    else if (a === "--forgejo-log-dir") args.logDir = argv[++i];
    else if (a === "--workflow") args.workflow = argv[++i];
  }
  return args;
}

function fileState(stateDir: string): StateStore {
  mkdirSync(stateDir, { recursive: true });
  const path = join(stateDir, "attempts.json");
  let pre: Record<string, number> = {};
  if (existsSync(path)) {
    try {
      pre = JSON.parse(readFileSync(path, "utf8")) as Record<string, number>;
    } catch {
      pre = {};
    }
  }
  const mem = memoryState(pre);
  return {
    getAttempts: (r, j) => mem.getAttempts(r, j),
    recordAttempt: (r, j) => {
      mem.recordAttempt(r, j);
      pre[`${r}:${j}`] = mem.getAttempts(r, j);
      writeFileSync(path, JSON.stringify(pre, null, 2));
    },
  };
}

type TaskEntry = {
  id: number;
  name: string;
  head_branch: string;
  status: string;
};

const FAILED = new Set(["failure", "cancelled"]);

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const token = process.env.FORGEJO_TOKEN ?? "";
  if (!args.dryRun && token === "") {
    console.error("FORGEJO_TOKEN is required (or use --dry-run)");
    process.exit(1);
  }
  const listTasks = async (): Promise<TaskEntry[]> => {
    const res = await fetch(
      `${args.baseUrl}/repos/${args.repo}/actions/tasks?limit=${args.limit}`,
      {
        headers: token === "" ? {} : { Authorization: `token ${token}` },
      },
    );
    if (!res.ok) throw new Error(`tasks list failed: ${res.status}`);
    const data = (await res.json()) as { workflow_runs: TaskEntry[] };
    return (data.workflow_runs ?? []).filter((t) => FAILED.has(t.status));
  };
  const live: PollForgejo = {
    listRuns: async (repo, _limit) => {
      void repo;
      const tasks = await listTasks();
      return tasks.map((t) => ({
        id: t.id,
        ref: t.head_branch,
        jobs: [{ id: t.id }],
      }));
    },
    getLogTail: (runId, jobId, maxLines) =>
      readTaskLogTail(args.logDir, args.repo, jobId, maxLines).then((t) => {
        void runId;
        return t;
      }),
    rerun: (runId, jobId) =>
      listTasks().then(async (tasks) => {
        const ref = tasks.find((t) => t.id === runId)?.head_branch ?? "main";
        void jobId;
        await dispatchWorkflow(
          args.baseUrl,
          args.repo,
          token,
          args.workflow,
          ref,
        );
      }),
  };
  const dry: PollForgejo = {
    listRuns: (repo, limit) => live.listRuns(repo, limit),
    getLogTail: (runId, jobId, maxLines) =>
      live.getLogTail(runId, jobId, maxLines),
    rerun: async (runId, jobId) => {
      console.log(
        `DRY-RUN dispatch ${args.workflow} for run=${runId} job=${jobId}`,
      );
    },
  };
  const forgejo = args.dryRun ? dry : live;
  const actions = await runPollOnce({
    forgejo,
    state: fileState(args.stateDir),
    opts: {
      repo: args.repo,
      maxReruns: args.maxReruns,
      pollIntervalSec: DEFAULT_POLL_OPTS.pollIntervalSec,
    },
  });
  for (const a of actions) {
    const prefix = args.dryRun ? "DRY-RUN " : "";
    console.log(
      `${prefix}${a.kind} run=${a.runId} job=${a.jobId} reason=${a.reason}`,
    );
  }
}

await main();
