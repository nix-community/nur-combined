import { classifyFailure } from "./classify";

export type PollOpts = {
  repo: string;
  maxReruns: number;
  pollIntervalSec: number;
};

export const DEFAULT_POLL_OPTS: PollOpts = {
  repo: "toyvo/nixcfg",
  maxReruns: 3,
  pollIntervalSec: 420,
};

export type PollAction = {
  runId: number;
  jobId: number;
  kind: "rerun" | "fix" | "needs-human" | "skip";
  reason: string;
};

export type StateStore = {
  getAttempts(runId: number, jobId: number): number;
  recordAttempt(runId: number, jobId: number): void;
};

export function memoryState(pre: Record<string, number> = {}): StateStore {
  const attempts = new Map<string, number>(Object.entries(pre));
  return {
    getAttempts: (runId, jobId) => attempts.get(`${runId}:${jobId}`) ?? 0,
    recordAttempt: (runId, jobId) => {
      const k = `${runId}:${jobId}`;
      attempts.set(k, (attempts.get(k) ?? 0) + 1);
    },
  };
}

export type RunRef = { id: number; ref: string; jobs: { id: number }[] };

export type PollForgejo = {
  listRuns(repo: string, limit: number): Promise<RunRef[]>;
  getLogTail(runId: number, jobId: number, maxLines: number): Promise<string>;
  rerun(runId: number, jobId: number): Promise<void>;
};

const LOG_TAIL_LINES = 200;

export type PollDeps = {
  forgejo: PollForgejo;
  state: StateStore;
  opts: PollOpts;
};

// Durable task shells (wired to pi-durable in main.ts):
//   maintainer.poll — sleeps `pollIntervalSec` via sleepUntil between passes.
//   maintainer.diagnose(runId) — classifies the bounded log tail.
//   maintainer.rerun — gated on attempts < maxReruns, checkpointed in state.
export async function runPollOnce(deps: PollDeps): Promise<PollAction[]> {
  const { forgejo, state, opts } = deps;
  const runs = await forgejo.listRuns(opts.repo, 20);
  const actions: PollAction[] = [];
  for (const run of runs) {
    for (const job of run.jobs) {
      const tail = await forgejo.getLogTail(run.id, job.id, LOG_TAIL_LINES);
      const kind = classifyFailure(tail);
      if (kind === "infra-cancel") {
        const attempts = state.getAttempts(run.id, job.id);
        if (attempts < opts.maxReruns) {
          await forgejo.rerun(run.id, job.id);
          state.recordAttempt(run.id, job.id);
          actions.push({
            runId: run.id,
            jobId: job.id,
            kind: "rerun",
            reason: `infra-cancel, attempt ${attempts + 1}/${opts.maxReruns}`,
          });
        } else {
          actions.push({
            runId: run.id,
            jobId: job.id,
            kind: "skip",
            reason: `infra-cancel at cap (${attempts}/${opts.maxReruns})`,
          });
        }
      } else if (kind === "eval-break") {
        actions.push({
          runId: run.id,
          jobId: job.id,
          kind: "fix",
          reason: "eval-break",
        });
      } else {
        actions.push({
          runId: run.id,
          jobId: job.id,
          kind: "needs-human",
          reason: "unknown",
        });
      }
    }
  }
  return actions;
}
