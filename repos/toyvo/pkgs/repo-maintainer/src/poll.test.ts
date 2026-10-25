import { expect, test } from "bun:test";
import { runPollOnce, type PollForgejo, type StateStore } from "./harness";

const INFRA_LOG = "ctx: context canceled, exec: RUN signal: terminated";
const EVAL_LOG =
  "Failed assertions:\n- Running forgejo-runner via `services.gitea-actions-runner` is no longer supported.\nPlease use `services.forgejo-runner` instead.";
const OK_LOG = "nix: building all good";

function fakeForgejo(calls: string[]): PollForgejo {
  return {
    async listRuns() {
      return [
        { id: 1, ref: "main", jobs: [{ id: 1 }] },
        { id: 2, ref: "main", jobs: [{ id: 2 }] },
        { id: 3, ref: "main", jobs: [{ id: 3 }] },
        { id: 7, ref: "main", jobs: [{ id: 3 }] },
      ];
    },
    async getLogTail(runId: number, _jobId: number) {
      if (runId === 1 || runId === 7) return INFRA_LOG;
      if (runId === 2) return EVAL_LOG;
      return OK_LOG;
    },
    async rerun(runId: number, jobId: number) {
      calls.push("rerun");
      void runId;
      void jobId;
    },
  };
}

function fakeState(pre: Record<string, number>): StateStore {
  const attempts = new Map<string, number>(Object.entries(pre));
  return {
    getAttempts: (runId: number, jobId: number) =>
      attempts.get(`${runId}:${jobId}`) ?? 0,
    recordAttempt: (runId: number, jobId: number) => {
      const k = `${runId}:${jobId}`;
      attempts.set(k, (attempts.get(k) ?? 0) + 1);
    },
  };
}

test("infra-cancel under cap yields rerun; eval-break yields fix; unknown yields needs-human; at-cap yields skip", async () => {
  const calls: string[] = [];
  const actions = await runPollOnce({
    forgejo: fakeForgejo(calls), // one infra run, one eval run, one unknown run, one at-cap run
    state: fakeState({ "7:3": 3 }), // run 7 job 3 already at maxReruns=3
    opts: { repo: "toyvo/nixcfg", maxReruns: 3, pollIntervalSec: 420 },
  });
  expect(actions.map((a) => a.kind).sort()).toEqual([
    "fix",
    "needs-human",
    "rerun",
    "skip",
  ]);
  expect(calls.filter((c) => c === "rerun").length).toBe(1);
});
