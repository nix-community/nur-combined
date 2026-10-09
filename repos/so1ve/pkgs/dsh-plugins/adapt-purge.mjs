import assert from "node:assert/strict";
import { readFileSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";

// Parse whole function bodies so upstream formatting changes do not break patching.
// Use Node's bundled parser; missing or duplicate functions fail the build.
const { parse } = createRequire(import.meta.url)(
  "internal/deps/acorn/acorn/dist/acorn",
);

const managed =
  '{ throw new Error("DSH Purge is managed by Nix. Update or remove it through your Nix configuration."); }';
const replacements = {
  "lib/index.js": { settleInstalledPatches: '{ return "managed-by-nix"; }' },
  "lib/core.js": {
    patchWatchedClientBundlesSync: "{ return []; }",
    applyPatches: managed,
    revertAll: managed,
    patchAllShims: managed,
    revertAllShims: managed,
  },
  "lib/update.js": { applyUpdate: managed },
  "lib/uninstall.js": { uninstallPurge: managed },
};

for (const [file, functions] of Object.entries(replacements)) {
  let source = readFileSync(file, "utf8");
  const tree = parse(source, { ecmaVersion: "latest", sourceType: "module" });
  const edits = [];

  for (const [name, body] of Object.entries(functions)) {
    const matches = tree.body.map((node) => node.declaration ?? node)
      .filter((node) =>
        node.type === "FunctionDeclaration" && node.id.name === name
      );

    assert.equal(matches.length, 1, `${file}: expected one ${name} function`);
    edits.push({
      start: matches[0].body.start,
      end: matches[0].body.end,
      body,
    });
  }

  for (const { start, end, body } of edits.sort((a, b) => b.start - a.start)) {
    source = source.slice(0, start) + body + source.slice(end);
  }

  writeFileSync(file, source);
}
