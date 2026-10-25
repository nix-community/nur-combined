import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";

const [prefix] = process.argv.slice(2);
const cwd = mkdtempSync(join(tmpdir(), "vite-plus-test-"));
const run = (command, args) =>
  execFileSync(join(prefix, "bin", command), args, { cwd, encoding: "utf8", timeout: 30_000 });
const vp = (args) => run("vp", args);

after(() => rmSync(cwd, { recursive: true, force: true }));

test("the global CLI loads its bundled toolchain and native tools offline", () => {
  const toolchain = JSON.parse(vp(["toolchain", "--global", "--json"]));
  assert.equal(toolchain.source.scope, "global");
  assert.ok(toolchain.nodes.some((node) => node.id === "vite-plus"));

  writeFileSync(
    join(cwd, "package.json"),
    JSON.stringify({
      private: true,
      scripts: { greeting: "node -p '40 + 2'", tracked: "node task.mjs" },
    }),
  );
  writeFileSync(join(cwd, "example.js"), "const answer=42;console.log(answer)\n");
  vp(["fmt", "example.js"]);
  assert.match(readFileSync(join(cwd, "example.js"), "utf8"), /const answer = 42;/);
  vp(["lint", "example.js"]);

  writeFileSync(join(cwd, "index.html"), '<script type="module" src="/example.js"></script>\n');
  vp(["build"]);
  assert.match(readFileSync(join(cwd, "dist/index.html"), "utf8"), /assets\/index-.*\.js/);

  writeFileSync(join(cwd, "example.test.js"), 'test("arithmetic", () => expect(2 + 2).toBe(4));\n');
  assert.match(vp(["test", "run", "--globals"]), /1 passed/);

  assert.equal(run("vpx", ["node", "-p", "40 + 2"]).trim(), "42");
  assert.match(run("vpr", ["greeting"]), /\b42\b/);
});

test("task caching restores outputs and tracks changes to inputs", () => {
  writeFileSync(join(cwd, "input.txt"), "first");
  writeFileSync(
    join(cwd, "task.mjs"),
    `import { readFileSync, writeFileSync } from "node:fs";
import { randomUUID } from "node:crypto";
writeFileSync("output.txt", readFileSync("input.txt", "utf8") + ":" + randomUUID());
`,
  );

  vp(["run", "--cache", "tracked"]);
  const first = readFileSync(join(cwd, "output.txt"), "utf8");
  assert.match(first, /^first:/);

  rmSync(join(cwd, "output.txt"));
  vp(["run", "--cache", "tracked"]);
  assert.equal(readFileSync(join(cwd, "output.txt"), "utf8"), first);

  writeFileSync(join(cwd, "input.txt"), "changed");
  vp(["run", "--cache", "tracked"]);
  assert.match(readFileSync(join(cwd, "output.txt"), "utf8"), /^changed:/);
});
