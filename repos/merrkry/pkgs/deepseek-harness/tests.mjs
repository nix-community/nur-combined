import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdtemp, rm } from "node:fs/promises";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

test("the installed web profile serves its frontend", { timeout: 60_000 }, async (t) => {
  const home = await mkdtemp(join(tmpdir(), "dsh-install-check-"));

  const child = spawn(
    join(process.env.DSH_TEST_PACKAGE, "bin/dsh"),
    ["web", "--host", "127.0.0.1", "--port", "0", "--no-open"],
    {
      cwd: home,
      env: { ...process.env, HOME: home, DSH_HOME: join(home, ".dsh") },
      stdio: ["ignore", "pipe", "pipe"],
    },
  );
  const closed = new Promise((resolve) => child.once("close", resolve));
  t.after(async () => {
    const timer = setTimeout(() => child.kill("SIGKILL"), 5_000);
    child.kill("SIGTERM");
    await closed;
    clearTimeout(timer);
    await rm(home, { recursive: true, force: true });
  });

  let output = "";
  const url = await new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("exit", (code) => reject(new Error(`dsh exited with ${code}:\n${output}`)));
    for (const stream of [child.stdout, child.stderr]) {
      stream.on("data", (chunk) => {
        output += chunk;
        const match = output.match(/dsh web: (http:\/\/127\.0\.0\.1:\d+\/\S*)\r?\n/);
        if (match) resolve(match[1]);
      });
    }
  });

  const login = await fetch(url, { redirect: "manual", signal: t.signal });
  assert.equal(login.status, 303);
  const cookie = login.headers.get("set-cookie").split(";")[0];
  const location = new URL(login.headers.get("location"), url);
  const response = await fetch(location, { headers: { cookie }, signal: t.signal });
  assert.equal(response.status, 200);
  const html = await response.text();
  const script = html.match(/<script[^>]+src="([^"]+)"/);
  assert.ok(script, "the frontend HTML contains a script entry");

  const scriptUrl = new URL(script[1].replaceAll("&amp;", "&"), location);
  const asset = await fetch(scriptUrl, { headers: { cookie }, signal: t.signal });
  assert.equal(asset.status, 200, `frontend asset ${asset.url}`);
  assert.match(asset.headers.get("content-type"), /javascript/);
  assert.ok((await asset.text()).length > 0, "the frontend script is not empty");
});

test("packaged image processing survives ELF fixup", async () => {
  const require = createRequire(
    join(process.env.DSH_TEST_PACKAGE, "lib/deepseek-harness/package.json"),
  );
  const baseRequire = createRequire(require.resolve("@deepseek-ai/dsh-base/package.json"));
  const attachmentRequire = createRequire(
    baseRequire.resolve("@deepseek-ai/dsh-attachment-local/package.json"),
  );
  const sharp = attachmentRequire("sharp");
  const image = await sharp({
    create: { width: 1, height: 1, channels: 3, background: "white" },
  })
    .png()
    .toBuffer();
  assert.ok(image.length > 0);
});
