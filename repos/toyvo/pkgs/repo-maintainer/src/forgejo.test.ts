import { afterEach, expect, test } from "bun:test";
import { listRecentRuns } from "./forgejo";

const realFetch = globalThis.fetch;

afterEach(() => {
  globalThis.fetch = realFetch;
});

test("listRecentRuns parses forgejo workflow_runs envelope", async () => {
  globalThis.fetch = (async (_url: unknown) => ({
    ok: true,
    json: async () => ({
      total_count: 1,
      workflow_runs: [
        {
          id: 176,
          head_branch: "main",
          status: "completed",
          conclusion: "failure",
        },
      ],
    }),
  })) as unknown as typeof fetch;
  const runs = await listRecentRuns(
    "https://git.toyvo.dev/api/v1",
    "toyvo/nixcfg",
    "",
    5,
  );
  expect(runs.length).toBe(1);
  expect(runs[0].id).toBe(176);
  expect(runs[0].headBranch).toBe("main");
});
