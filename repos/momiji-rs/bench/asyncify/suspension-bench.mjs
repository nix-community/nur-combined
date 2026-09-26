// Scenario `suspension`: per-suspension marginal cost of the asyncify path.
//
// Formalizes E1 of docs/HANDOFF_ASYNC_IMPORTER_PERF.md (supersedes
// asyncify-bench-one.mjs — same core methodology, plus JSON results, a
// per-mode fs chain, and marginal-cost slopes).
//
// WHAT IS MEASURED. One compile of an entry with K synthetic `@use "m<i>";`
// modules; each (mode, K) configuration runs in its OWN child process
// (JIT/wasm-instance isolation — cross-config state pollutes numbers).
// Five modes cover the sync/async-module × importer matrix:
//   • sync           — sync module, `compileString`, sync in-memory importer
//   • async-syncimp  — asyncify module, `compileStringAsync`, importer
//                      returns PLAIN values (the sync-resolving chain)
//   • async-asyncimp — asyncify module, `compileStringAsync`, importer
//                      returns Promise.resolve-wrapped values
//   • sync-fs        — sync module, NO user importer: K on-disk partials
//                      resolved via `loadPaths` (the built-in Node-fs chain)
//   • async-fs       — asyncify module, same `loadPaths` chain
// Every module costs two host calls (canonicalize + load), so the least-
// squares slope of median-ms over K (ms/module) divided by two is the µs
// cost per host call — for the async modes that is the unwind + microtask +
// rewind suspension cost (`asyncHostFn` / `compileRawAsync` drive loop in
// wasm/npm/_loader.mjs).
//
// ACCEPTANCE CRITERION (F3 — sync-delivery fast path in `asyncHostFn`).
// Today the asyncify module unwinds on EVERY host call, so a synchronous
// importer pays nearly the async price — E1's middle column (~38 µs/module
// vs sync ~20 µs). F3 lands when async-syncimp's slope collapses onto sync's
// (and async-fs onto sync-fs — the loadPaths chain is the most common
// bundler-less usage). Slopes are load-sensitive: the mode ORDERING and the
// collapse RATIO are the signal, absolute µs are not.
//
// HOW TO RUN
//   node bench/asyncify/suspension-bench.mjs                  # full sweep -> results/
//   node bench/asyncify/suspension-bench.mjs --quick          # 3 modes × K∈{0,20}
//   node bench/asyncify/suspension-bench.mjs --impl <path/to/sasso.mjs> --label after-f3
//   node bench/asyncify/suspension-bench.mjs --worker --mode async-syncimp --k 50
// Common flags: --reps N --warmup N --json --out DIR --force --max-load N.
// stdout is DATA (worker JSON; the final result doc with --json); humans
// read stderr.

import { mkdtempSync, writeFileSync, rmSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  parseCommonArgs,
  restFlag,
  restHas,
  captureEnv,
  enforceLoadGuard,
  stats,
  linfit,
  writeResult,
  runChild,
  importImpl,
  nowMs,
} from "./lib/harness.mjs";

const SELF = fileURLToPath(import.meta.url);

const MODES = ["sync", "async-syncimp", "async-asyncimp", "sync-fs", "async-fs"];
const QUICK_MODES = ["sync", "async-syncimp", "async-asyncimp"];
const FULL_KS = [0, 10, 50, 200];
const QUICK_KS = [0, 20];
const HOST_CALLS_PER_MODULE = 2; // canonicalize + load

const opts = parseCommonArgs(process.argv.slice(2));
const reps = opts.reps ?? (opts.quick ? 15 : 50);
const warmup = opts.warmup ?? (opts.quick ? 5 : 10);

if (restHas(opts.rest, "--worker")) {
  await workerMain();
} else {
  await orchestratorMain();
}

// ---------------------------------------------------------------- worker
// Runs exactly ONE (mode, K) configuration in-process and prints one JSON
// object ({ params, samples, stats }) to stdout.

async function workerMain() {
  const mode = restFlag(opts.rest, "--mode");
  const k = parseInt(restFlag(opts.rest, "--k", "0"), 10);
  if (!MODES.includes(mode)) {
    process.stderr.write(`suspension worker: --mode must be one of ${MODES.join("|")} (got ${mode})\n`);
    process.exit(1);
  }
  if (!Number.isInteger(k) || k < 0) {
    process.stderr.write("suspension worker: --k must be a non-negative integer\n");
    process.exit(1);
  }
  const guard = enforceLoadGuard(opts);
  const api = await importImpl(opts.impl);

  let src = "";
  for (let i = 0; i < k; i++) src += `@use "m${i}";\n`;
  src += "a { b: c; }\n";
  // Sanity marker: the LAST module's rule must appear in the output (K=0:
  // the entry's own rule). A benchmark that silently compiles the wrong
  // thing is worse than none.
  const marker = k > 0 ? `.m${k - 1} {` : "a {";
  const isAsync = mode.startsWith("async");

  let run;
  let cleanup = () => {};
  if (mode === "sync-fs" || mode === "async-fs") {
    // K on-disk partials resolved by the built-in loadPaths chain — no user
    // importer, so this measures the path most bundler-less usage takes.
    const dir = mkdtempSync(join(tmpdir(), "sasso-susp-"));
    cleanup = () => rmSync(dir, { recursive: true, force: true });
    process.on("exit", cleanup); // process.exit(1) skips finally blocks
    for (let i = 0; i < k; i++) writeFileSync(join(dir, `_m${i}.scss`), `.m${i} { d: e; }\n`);
    const o = { loadPaths: [dir] };
    run = mode === "sync-fs" ? () => api.compileString(src, o) : () => api.compileStringAsync(src, o);
  } else {
    // In-memory importer (asyncify-bench-one.mjs methodology): plain return
    // values for sync/async-syncimp, Promise.resolve-wrapped for
    // async-asyncimp.
    const wrapAsync = mode === "async-asyncimp";
    const imp = {
      canonicalize(url) {
        const u = new URL(url.startsWith("bench:") ? url : "bench:" + url);
        return wrapAsync ? Promise.resolve(u) : u;
      },
      load(canonicalUrl) {
        const name = canonicalUrl.href.slice("bench:".length);
        const r = { contents: `.${name} { d: e; }`, syntax: "scss" };
        return wrapAsync ? Promise.resolve(r) : r;
      },
    };
    const o = { importers: [imp] };
    run = mode === "sync" ? () => api.compileString(src, o) : () => api.compileStringAsync(src, o);
  }

  const check = (css) => {
    if (!css.includes(marker)) {
      process.stderr.write(
        `suspension worker: SANITY FAIL — mode=${mode} K=${k}: marker '${marker}' missing from output CSS\n`,
      );
      process.exit(1);
    }
  };

  process.stderr.write(`  worker mode=${mode} K=${k} reps=${reps} warmup=${warmup}\n`);
  try {
    for (let i = 0; i < warmup; i++) check((isAsync ? await run() : run()).css);
    const samples = [];
    for (let i = 0; i < reps; i++) {
      const t0 = nowMs();
      const res = isAsync ? await run() : run();
      const dt = nowMs() - t0;
      check(res.css); // sanity-check every rep, outside the timed window
      samples.push(dt);
    }
    const doc = {
      params: { mode, k, reps, warmup, impl: opts.impl, load: guard.load, forced: guard.forced },
      samples: samples.map((x) => +x.toFixed(4)),
      stats: stats(samples),
    };
    process.stdout.write(JSON.stringify(doc) + "\n");
  } finally {
    cleanup();
  }
}

// ------------------------------------------------------------ orchestrator
// Sweeps mode × K, one child process per cell, fits per-mode slopes, writes
// one result doc, and prints a human summary table to stderr.

async function orchestratorMain() {
  const guard = enforceLoadGuard(opts);
  const env = captureEnv(opts.impl);
  const modes = opts.quick ? QUICK_MODES : MODES;
  const ks = opts.quick ? QUICK_KS : FULL_KS;

  const grid = {};
  const slopes = {};
  const total = modes.length * ks.length;
  let done = 0;
  for (const mode of modes) {
    grid[mode] = {};
    for (const k of ks) {
      done++;
      process.stderr.write(`[${done}/${total}] mode=${mode} K=${k}\n`);
      const args = [
        "--worker",
        "--mode", mode,
        "--k", String(k),
        "--reps", String(reps),
        "--warmup", String(warmup),
        "--impl", opts.impl,
      ];
      if (opts.force) args.push("--force");
      if (opts.maxLoad != null) args.push("--max-load", String(opts.maxLoad));
      const res = await runChild(SELF, args);
      grid[mode][k] = res.stats;
      process.stderr.write(`  median=${res.stats.median}ms mad=${res.stats.mad} n=${res.stats.n}\n`);
    }
    const fit = linfit(ks, ks.map((k) => grid[mode][k].median));
    slopes[mode] = {
      slopeMsPerModule: +fit.slope.toFixed(6),
      usPerHostCall: +((fit.slope * 1000) / HOST_CALLS_PER_MODULE).toFixed(2),
      r2: +fit.r2.toFixed(4),
    };
  }

  const file = writeResult({
    scenario: "suspension",
    opts,
    env,
    params: { modes, ks, reps, warmup, quick: opts.quick },
    results: { grid, slopes },
    warnings: guard.forced ? guard.warnings : [],
  });

  printSummary(modes, ks, grid, slopes);
  process.stderr.write(`\nresult: ${file}\n`);
  if (opts.json) process.stdout.write(readFileSync(file, "utf8"));
}

function printSummary(modes, ks, grid, slopes) {
  const w1 = Math.max(...modes.map((m) => m.length), 4) + 2;
  let header = "mode".padEnd(w1);
  for (const k of ks) header += `K=${k}`.padStart(9);
  header += "slope ms/mod".padStart(14) + "us/hostcall".padStart(13) + "r2".padStart(8);
  process.stderr.write(
    `\nsuspension: median ms/compile by (mode, K); slope = marginal cost per @use module\n${header}\n`,
  );
  for (const mode of modes) {
    let row = mode.padEnd(w1);
    for (const k of ks) row += grid[mode][k].median.toFixed(3).padStart(9);
    const s = slopes[mode];
    row +=
      s.slopeMsPerModule.toFixed(4).padStart(14) +
      s.usPerHostCall.toFixed(1).padStart(13) +
      s.r2.toFixed(4).padStart(8);
    process.stderr.write(row + "\n");
  }
  const ratio = (a, b) =>
    slopes[a] && slopes[b] && slopes[b].slopeMsPerModule !== 0
      ? (slopes[a].slopeMsPerModule / slopes[b].slopeMsPerModule).toFixed(2)
      : null;
  const rImp = ratio("async-syncimp", "sync");
  const rFs = ratio("async-fs", "sync-fs");
  if (rImp) {
    process.stderr.write(
      `\nF3 signal: async-syncimp/sync slope ratio = ${rImp}x (F3 lands when this collapses to ~1x)\n`,
    );
  }
  if (rFs) {
    process.stderr.write(`           async-fs/sync-fs slope ratio    = ${rFs}x (loadPaths chain)\n`);
  }
}
