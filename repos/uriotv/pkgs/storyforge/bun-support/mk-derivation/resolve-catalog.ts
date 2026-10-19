// bun2nix: resolve `catalog:` specifiers to exact versions for offline install.
//
// bun re-resolves `catalog:` dependency specifiers against the npm registry on
// every `bun install`, even with a fully populated cache and
// `--frozen-lockfile` / `--offline`. In the Nix sandbox this fails. The
// lockfile already records the exact resolved version for every package, so
// rewrite every `catalog:` reference (in bun.lock's `workspaces` section and
// in every workspace package.json) to that exact version (or `workspace:*`
// for workspace packages) before `bun install` runs.
//
// Invoked as: bun resolve-catalog.ts <bunRoot>

import { join, resolve } from "node:path";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { pathToFileURL } from "node:url";

type Deps = Record<string, string>;
type DepHolder = Partial<
  Record<
    | "dependencies"
    | "devDependencies"
    | "peerDependencies"
    | "optionalDependencies",
    Deps
  >
>;
interface BunLock {
  workspaces?: Record<string, DepHolder>;
  catalog?: Deps;
  catalogs?: Record<string, Deps>;
  packages?: Record<string, [string, ...unknown[]]>;
}

const depSections = [
  "dependencies",
  "devDependencies",
  "peerDependencies",
  "optionalDependencies",
] as const;

const root = process.argv[2] ?? ".";
const lockPath = join(root, "bun.lock");

if (!existsSync(lockPath)) process.exit(0);
if (!readFileSync(lockPath, "utf8").includes('"catalog:')) process.exit(0);

// bun.lock is JSON-with-trailing-commas. Bun's module loader has a built-in
// JSONC parser (used for tsconfig.json / bun.lock) that we can reach via
// `import(..., { with: { type: "jsonc" } })`. This works on every bun
// version supported by nixos-25.11+ (>= 1.3.3), unlike `Bun.JSONC` which
// only appeared in 1.3.6.
const lock = (
  (await import(pathToFileURL(resolve(lockPath)).href, {
    with: { type: "jsonc" },
  })) as { default: BunLock }
).default;

const catalog = lock.catalog ?? {};
const catalogs = lock.catalogs ?? {};
const packages = lock.packages ?? {};
const workspaces = lock.workspaces ?? {};

// Build name -> exact-version map from .packages. Only keep entries whose
// spec starts with "<name>@", i.e. the top-level resolution for that name.
const resolved: Deps = {};
for (const [name, entry] of Object.entries(packages)) {
  const spec = entry?.[0];
  if (typeof spec !== "string") continue;
  const prefix = `${name}@`;
  if (!spec.startsWith(prefix)) continue;
  resolved[name] = spec.slice(prefix.length);
}

function cresolve(name: string, spec: string): string {
  const cname = spec.slice("catalog:".length);
  const table = cname === "" ? catalog : (catalogs[cname] ?? {});
  const cv = table[name];
  const rv = resolved[name];
  if (typeof cv === "string" && cv.startsWith("workspace:")) return cv;
  if (typeof rv === "string" && rv.startsWith("workspace:"))
    return "workspace:*";
  if (typeof rv === "string") return rv;
  if (typeof cv === "string") return cv;
  return spec;
}

function rewriteDeps(holder: DepHolder): boolean {
  let changed = false;
  for (const section of depSections) {
    const deps = holder[section];
    if (!deps || typeof deps !== "object") continue;
    for (const [name, spec] of Object.entries(deps)) {
      if (typeof spec === "string" && spec.startsWith("catalog:")) {
        deps[name] = cresolve(name, spec);
        changed = true;
      }
    }
  }
  return changed;
}

console.log("bun2nix: resolving catalog: specifiers from bun.lock");

// Rewrite the lockfile's workspaces section.
let lockChanged = false;
for (const ws of Object.values(workspaces)) {
  if (rewriteDeps(ws)) lockChanged = true;
}
if (lockChanged) {
  writeFileSync(lockPath, JSON.stringify(lock, null, 2) + "\n");
}

// Rewrite every workspace package.json (root "" + each workspace dir).
for (const wsDir of Object.keys(workspaces)) {
  const pkgJson = join(root, wsDir, "package.json");
  if (!existsSync(pkgJson)) continue;
  const text = readFileSync(pkgJson, "utf8");
  if (!text.includes('"catalog:')) continue;
  const pkg = JSON.parse(text) as DepHolder;
  if (rewriteDeps(pkg)) {
    writeFileSync(pkgJson, JSON.stringify(pkg, null, 2) + "\n");
  }
}
