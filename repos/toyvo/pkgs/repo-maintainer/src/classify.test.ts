import { describe, expect, test } from "bun:test";
import { classifyFailure } from "./classify";
describe("classifyFailure", () => {
  test("SIGTERM tail is infra-cancel", () => {
    expect(
      classifyFailure("ctx: context canceled, exec: RUN signal: terminated"),
    ).toBe("infra-cancel");
  });
  test("option removal is eval-break", () => {
    expect(
      classifyFailure(
        "Failed assertions:\n- Running forgejo-runner via `services.gitea-actions-runner` is no longer supported.\nPlease use `services.forgejo-runner` instead.",
      ),
    ).toBe("eval-break");
  });
  test("empty log is unknown", () => {
    expect(classifyFailure("")).toBe("unknown");
  });
  test("unrelated text is unknown", () => {
    expect(classifyFailure("nix: building all good")).toBe("unknown");
  });
});
