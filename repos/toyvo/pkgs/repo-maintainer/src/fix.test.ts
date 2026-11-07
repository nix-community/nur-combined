import { expect, test } from "bun:test";
import { buildFixPrBody, planFixBranch } from "./fix";
test("branch name is fix/ci-<runId>", () => {
  expect(planFixBranch(176)).toBe("fix/ci-176");
});
test("PR body carries run id and excerpt, no secrets", () => {
  const body = buildFixPrBody({
    runId: 176,
    logExcerpt: "no longer supported",
    explanation: "rename option",
  });
  expect(body).toContain("Automated fix for run 176");
  expect(body).toContain("no longer supported");
  expect(body).not.toContain("oc_sk_");
});
