#!/usr/bin/env bun
// Run every per-package `update.ts` script, sequentially.
//
// Sequential (never parallel): each updater already rate-limits itself to
// one request/download at a time, and running them one after another keeps
// the total load on upstreams to a gentle trickle. Every updater is
// cache-first via its `versions.json`, so a no-change run is a handful of
// small metadata requests and zero artifact downloads.
//
// Usage:
//   bun ./scripts/update-all.ts    # from the repo root (bun is in the dev shell)
//
// Exit status is the number of failed updaters (0 = all green). A failure
// aborts nothing: every updater is attempted so one flaky upstream can't
// hide the results of the rest, but CI treats any failure as fatal so a
// broken updater goes red instead of silently going stale.

import { join } from "node:path";

const ROOT = join(import.meta.dir, "..");

// Per-updater timeout in ms. Generous: a full fabric rehash (~50 small
// jars) or a new Vintagestory tarball (~100MB) finishes in minutes on the
// nas; this only bounds truly stuck runs. CI also has a job-level timeout.
const UPDATER_TIMEOUT_MS = 15 * 60 * 1000;

const UPDATERS = [
  "pkgs/fabricServers/update.ts",
  "pkgs/purpurServers/update.ts",
  "pkgs/neoforgeServers/update.ts",
  "pkgs/papermcServers/update.ts",
  "pkgs/VintagestoryServers/update.ts",
  "pkgs/tinycast/update.ts",
  "pkgs/ghostex/update.ts",
];

const failed: string[] = [];

for (const updater of UPDATERS) {
  console.log(`\n=== ${updater} ===`);
  try {
    const proc = Bun.spawn(["bun", join(ROOT, updater)], {
      cwd: ROOT,
      stdout: "inherit",
      stderr: "inherit",
      timeout: UPDATER_TIMEOUT_MS,
    });
    const code = await proc.exited;
    if (code !== 0) {
      console.error(`!! ${updater} exited with code ${code}`);
      failed.push(`${updater} (exit ${code})`);
    }
  } catch (e) {
    console.error(`!! ${updater} failed: ${e}`);
    failed.push(`${updater} (${e})`);
  }
}

console.log("\n=== update-all summary ===");
if (failed.length === 0) {
  console.log(`all ${UPDATERS.length} updaters succeeded`);
} else {
  console.error(`${failed.length}/${UPDATERS.length} updaters failed:`);
  for (const f of failed) console.error(`  - ${f}`);
}
process.exit(failed.length);
