// Delete packages gated by `os`/`cpu`/`libc`: bun unpacks only the matching one, so an unpruned tree hashes differently per system.
// None of them takes part in bundling.
import {readdirSync, readFileSync, rmSync} from "node:fs";
import {join} from "node:path";

const roots = process.argv.slice(2);
if (roots.length === 0) {
  throw new Error("usage: prune-platform-packages.mjs <node_modules>...");
}

const isPlatformGated = (packageDir) => {
  let manifest;
  try {
    manifest = JSON.parse(readFileSync(join(packageDir, "package.json"), "utf8"));
  } catch {
    return false;
  }
  return manifest.os !== undefined || manifest.cpu !== undefined || manifest.libc !== undefined;
};

const visitPackage = (packageDir) => {
  if (isPlatformGated(packageDir)) {
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
