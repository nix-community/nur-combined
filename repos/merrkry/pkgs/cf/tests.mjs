import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";

const packageDirectory = process.env.CF_TEST_PACKAGE;
const expectedTelemetry = process.env.CF_TEST_EXPECT_TELEMETRY;
const testDirectory = mkdtempSync(join(tmpdir(), "cf-install-check-"));
const environment = {
  ...process.env,
  HOME: testDirectory,
  XDG_CONFIG_HOME: testDirectory,
  NO_COLOR: "1",
  CF_SEND_TELEMETRY: "false",
};
delete environment.DO_NOT_TRACK;
delete environment.FORCE_COLOR;
delete environment.WRANGLER_SEND_METRICS;

after(() => rmSync(testDirectory, { recursive: true, force: true }));

function runCli(command, args, overrides = {}) {
  return execFileSync(join(packageDirectory, "bin", command), args, {
    cwd: testDirectory,
    env: { ...environment, ...overrides },
    encoding: "utf8",
    timeout: 30_000,
  });
}

for (const command of ["cf", "cloudflare"]) {
  test(`${command} honors the package telemetry policy`, () => {
    const optedIn = runCli(command, ["cli", "telemetry", "status"], {
      CF_SEND_TELEMETRY: "true",
    });
    assert.equal(optedIn.split("\n")[0], `Status: ${expectedTelemetry} (set by CF_SEND_TELEMETRY)`);

    const optedOut = runCli(command, ["cli", "telemetry", "status"]);
    assert.equal(optedOut.split("\n")[0], "Status: Disabled (set by CF_SEND_TELEMETRY)");
  });
}

test("the installed CLI persists local KV data", () => {
  const local = ["--local", "--persist-to", join(testDirectory, "state")];
  const namespace = ["--namespace-id", "install-check"];

  runCli("cf", ["kv", "keys", "put", "greeting", ...namespace, "--body", "hello", ...local]);
  const value = runCli("cf", ["kv", "keys", "get", "greeting", ...namespace, "--text", ...local]);
  assert.equal(value, "hello");
});

test("packaged image processing survives ELF fixup", async () => {
  const require = createRequire(join(packageDirectory, "lib/node_modules/cf/package.json"));
  const requireFromMiniflare = createRequire(require.resolve("miniflare"));
  const sharp = requireFromMiniflare("sharp");
  const image = await sharp({
    create: { width: 1, height: 1, channels: 3, background: "white" },
  })
    .png()
    .toBuffer();
  assert.ok(image.length > 0);
});
