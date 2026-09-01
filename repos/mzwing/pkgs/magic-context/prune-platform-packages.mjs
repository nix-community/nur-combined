// Delete packages bun unpacks on only some of the targets, since an unpruned tree hashes differently per system.
// A gate that admits every target unpacks identically everywhere and has to stay: `onnxruntime-node` names all three OSes and no CPU, and the CLI bundle resolves through it.
import {readdirSync, readFileSync, rmSync} from "node:fs";
import {join} from "node:path";

const roots = process.argv.slice(2);
if (roots.length === 0) {
  throw new Error("usage: prune-platform-packages.mjs <node_modules>...");
}

// meta.platforms, as node spells them.
const TARGETS = [
  ["linux", "x64"],
  ["linux", "arm64"],
  ["darwin", "arm64"],
];

// A gate lists the values it admits, except entries prefixed with `!`, which deny instead.
const admits = (gate, value) => {
  if (gate === undefined) return true;
  const entries = Array.isArray(gate) ? gate : [gate];
  if (entries.includes(`!${value}`)) return false;
  const allowed = entries.filter((entry) => !entry.startsWith("!"));
  return allowed.length === 0 || allowed.includes(value);
};

const isPlatformVarying = (packageDir) => {
  let manifest;
  try {
    manifest = JSON.parse(readFileSync(join(packageDir, "package.json"), "utf8"));
  } catch {
    return false;
  }
  // `libc` is only evaluated on Linux, so gating on it already splits Linux from Darwin.
  if (manifest.libc !== undefined) return true;
  return !TARGETS.every(([os, cpu]) => admits(manifest.os, os) && admits(manifest.cpu, cpu));
};

const visitPackage = (packageDir) => {
  if (isPlatformVarying(packageDir)) {
    rmSync(packageDir, {recursive: true, force: true});
    return;
  }
  visitTree(join(packageDir, "node_modules"));
};

const visitScope = (scopeDir) => {
  for (const entry of readdirSync(scopeDir, {withFileTypes: true})) {
    // Workspace links point into the source tree.
    if (entry.isSymbolicLink()) continue;
    visitPackage(join(scopeDir, entry.name));
  }
  // An emptied scope dir would survive only where something was installed.
  if (readdirSync(scopeDir).length === 0) {
    rmSync(scopeDir, {recursive: true, force: true});
  }
};

function visitTree(nodeModules) {
  let entries;
  try {
    entries = readdirSync(nodeModules, {withFileTypes: true});
  } catch {
    return;
  }
  for (const entry of entries) {
    const path = join(nodeModules, entry.name);
    if (entry.name === ".cache") {
      rmSync(path, {recursive: true, force: true});
      continue;
    }
    // .bun is the isolated linker's package store; anything else dotted is bun's own bookkeeping.
    if (entry.name === ".bun") {
      visitTree(join(path, "node_modules"));
      continue;
    }
    if (entry.name.startsWith(".")) continue;
    if (entry.isSymbolicLink()) continue;
    if (entry.name.startsWith("@")) {
      visitScope(path);
      continue;
    }
    visitPackage(path);
  }
}

for (const root of roots) visitTree(root);
