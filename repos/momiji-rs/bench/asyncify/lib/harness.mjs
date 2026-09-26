// Shared harness core for the wasm async-path benchmarks (bench/asyncify/).
//
// Every scenario script in this directory follows the same contract:
//   • one *measurement configuration* per child process (JIT/wasm-instance
//     isolation — see docs/HANDOFF_ASYNC_IMPORTER_PERF.md, E1 methodology);
//   • an orchestrator mode that spawns those children, aggregates, and writes
//     one JSON result file under results/ carrying full environment metadata
//     (commit, node, machine, loadavg, wasm hashes) so before/after
//     comparisons stay attributable;
//   • a machine-load guard that FAILS by default on a noisy machine
//     (`--force` overrides and tags the result) — the original 1.9–4.5 s
//     "regression" in the handoff was contamination from load-avg 40–70.
//
// Engines are pluggable via --impl <path-to-sasso.mjs> so the same scenarios
// score: the working tree, a baseline git worktree, a published npm tarball,
// or a future native addon exposing the same modern API.

import { execFileSync, execFile } from "node:child_process";
import { createHash } from "node:crypto";
import { readFileSync, writeFileSync, mkdirSync, readdirSync } from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

export const SCHEMA = "sasso-asyncify-bench/1";

const HERE = path.dirname(fileURLToPath(import.meta.url));
export const BENCH_DIR = path.dirname(HERE); // bench/asyncify
export const REPO_ROOT = path.resolve(BENCH_DIR, "..", ".."); // repo root
export const DEFAULT_IMPL = path.join(REPO_ROOT, "wasm", "npm", "sasso.mjs");
export const RESULTS_DIR = path.join(BENCH_DIR, "results");
export const CORPUS_DIR = path.join(REPO_ROOT, "bench", "corpus");

// ---------------------------------------------------------------- arguments

/**
 * Parse the flags shared by every scenario script. Returns
 * `{ impl, reps, warmup, json, out, label, force, quick, maxLoad, rest }`;
 * unrecognized tokens land in `rest` (positional args / scenario flags).
 * Flags: --impl <p> --reps <n> --warmup <n> --json --out <dir> --label <s>
 *        --force --quick --max-load <n>
 */
export function parseCommonArgs(argv, defaults = {}) {
  const opts = {
    impl: DEFAULT_IMPL,
    reps: null, // scenario picks its own default (and may lower it for --quick)
    warmup: null,
    json: false,
    out: null,
    label: null,
    force: false,
    quick: false,
    maxLoad: null,
    rest: [],
    ...defaults,
  };
  const takes = new Set(["--impl", "--reps", "--warmup", "--out", "--label", "--max-load"]);
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (takes.has(a)) {
      const v = argv[++i];
      if (v === undefined) throw new Error(`harness: ${a} requires a value`);
      if (a === "--impl") opts.impl = path.resolve(v);
      else if (a === "--reps") opts.reps = parseInt(v, 10);
      else if (a === "--warmup") opts.warmup = parseInt(v, 10);
      else if (a === "--out") opts.out = path.resolve(v);
      else if (a === "--label") opts.label = v;
      else if (a === "--max-load") opts.maxLoad = parseFloat(v);
    } else if (a === "--json") opts.json = true;
    else if (a === "--force") opts.force = true;
    else if (a === "--quick") opts.quick = true;
    else opts.rest.push(a);
  }
  return opts;
}

/** Read the value following `flag` out of a rest-args array (or `dflt`). */
export function restFlag(rest, flag, dflt = null) {
  const i = rest.indexOf(flag);
  if (i === -1 || i + 1 >= rest.length) return dflt;
  return rest[i + 1];
}

/** True when `flag` is present in a rest-args array. */
export function restHas(rest, flag) {
  return rest.includes(flag);
}

// -------------------------------------------------------------- environment

function git(args) {
  try {
    return execFileSync("git", args, { cwd: REPO_ROOT, encoding: "utf8" }).trim();
  } catch {
    return null;
  }
}

function sha256(file) {
  try {
    return createHash("sha256").update(readFileSync(file)).digest("hex").slice(0, 16);
  } catch {
    return null;
  }
}

/**
 * Snapshot everything needed to attribute a result later: commit (+dirty),
 * node/OS/CPU, current loadavg, and content hashes of the wasm binaries next
 * to the impl entry point (the binaries are the thing actually measured —
 * a stale build silently invalidates a comparison; hashes make that visible).
 */
export function captureEnv(implPath = DEFAULT_IMPL) {
  const implDir = path.dirname(implPath);
  const wasm = {};
  try {
    for (const f of readdirSync(implDir)) {
      // .node too: a napi --impl's measured binary is the addon, not a wasm.
      if (f.endsWith(".wasm") || f.endsWith(".node")) wasm[f] = sha256(path.join(implDir, f));
    }
  } catch {
    // non-directory impl (e.g. a package specifier) — leave hashes empty
  }
  return {
    ts: new Date().toISOString(),
    node: process.version,
    platform: `${process.platform}-${process.arch}`,
    osRelease: os.release(),
    cpu: os.cpus()[0]?.model ?? "unknown",
    cores: os.availableParallelism(),
    loadavg: os.loadavg().map((x) => +x.toFixed(2)),
    commit: git(["rev-parse", "--short", "HEAD"]),
    // git() is null outside a repo — that is "unknown", not "dirty".
    dirty: (() => {
      const p = git(["status", "--porcelain"]);
      return p === null ? null : p !== "";
    })(),
    impl: implPath,
    wasm,
  };
}

/**
 * Machine-load guard. Default threshold: half the cores (an M-series arm64
 * box compiling rustc fleets at load 40 ruins wall-clock medians). Returns
 * `{ ok, load, threshold, warnings }`; when `!ok && !force` the caller should
 * abort (use `enforceLoadGuard` for the standard behavior).
 */
export function checkLoad({ maxLoad = null, force = false } = {}) {
  const threshold = maxLoad ?? Math.max(2, os.availableParallelism() / 2);
  const load = os.loadavg()[0];
  const ok = load <= threshold;
  const warnings = ok ? [] : [`load-avg ${load.toFixed(1)} exceeds threshold ${threshold} — wall-clock medians untrustworthy`];
  return { ok, load: +load.toFixed(2), threshold, warnings, forced: !ok && force };
}

/** Standard guard behavior: abort loudly unless quiet or --force. */
export function enforceLoadGuard(opts) {
  const g = checkLoad({ maxLoad: opts.maxLoad, force: opts.force });
  if (!g.ok && !opts.force) {
    process.stderr.write(
      `ABORT: ${g.warnings[0]}\n` +
        `       re-run with --force to record anyway (result will be tagged), or wait for a quiet machine.\n`,
    );
    process.exit(2);
  }
  if (!g.ok) process.stderr.write(`WARNING (--force): ${g.warnings[0]}\n`);
  return g;
}

// ---------------------------------------------------------------- statistics

/** Robust summary of a sample array (ms). MAD is unscaled (raw median |x-med|). */
export function stats(samples) {
  if (!samples.length) return null;
  const s = [...samples].sort((a, b) => a - b);
  const q = (p) => {
    const idx = (s.length - 1) * p;
    const lo = Math.floor(idx);
    const hi = Math.ceil(idx);
    return lo === hi ? s[lo] : s[lo] + (s[hi] - s[lo]) * (idx - lo);
  };
  const median = q(0.5);
  // MAD via the same interpolated median as the samples (a raw upper-middle
  // element biases MAD high for even n, widening every "within noise" band).
  const dev = s.map((x) => Math.abs(x - median)).sort((a, b) => a - b);
  const dq = (dev.length - 1) * 0.5;
  const dlo = Math.floor(dq);
  const mad = dlo === dq ? dev[dlo] : dev[dlo] + (dev[dlo + 1] - dev[dlo]) * (dq - dlo);
  const mean = s.reduce((a, b) => a + b, 0) / s.length;
  const r = (x) => +x.toFixed(4);
  return {
    n: s.length,
    min: r(s[0]),
    p10: r(q(0.1)),
    median: r(median),
    p90: r(q(0.9)),
    max: r(s[s.length - 1]),
    mean: r(mean),
    mad: r(mad),
  };
}

/** Least-squares fit y = slope*x + intercept, with r². For marginal-cost slopes. */
export function linfit(xs, ys) {
  const n = xs.length;
  const mx = xs.reduce((a, b) => a + b, 0) / n;
  const my = ys.reduce((a, b) => a + b, 0) / n;
  let sxy = 0;
  let sxx = 0;
  let syy = 0;
  for (let i = 0; i < n; i++) {
    sxy += (xs[i] - mx) * (ys[i] - my);
    sxx += (xs[i] - mx) ** 2;
    syy += (ys[i] - my) ** 2;
  }
  const slope = sxy / sxx;
  const intercept = my - slope * mx;
  const r2 = syy === 0 ? 1 : (sxy * sxy) / (sxx * syy);
  return { slope, intercept, r2 };
}

// ------------------------------------------------------------------- results

/**
 * Assemble and write one result file. `name` should be
 * `<scenario>--<label>` — label defaults to `<commit><-dirty?>` so re-runs on
 * the same tree overwrite (a result is a *measurement of a tree*, not a log).
 * Returns the path.
 */
export function writeResult({ scenario, opts, env, params, results, warnings = [] }) {
  const dir = opts.out ?? RESULTS_DIR;
  mkdirSync(dir, { recursive: true });
  const label = opts.label ?? `${env.commit ?? "nogit"}${env.dirty ? "-dirty" : ""}`;
  const file = path.join(dir, `${scenario}--${label}.json`);
  const doc = { schema: SCHEMA, scenario, label, env, params, results, warnings };
  writeFileSync(file, JSON.stringify(doc, null, 1) + "\n");
  return file;
}

// -------------------------------------------------------------- child runner

/**
 * Run one measurement child: `node <script> <args...>` with `--json` output
 * on stdout. Serialized execution (one child at a time) is the point — child
 * processes must not compete with each other. stderr is passed through for
 * progress. Returns the parsed JSON.
 */
export function runChild(script, args, { env = {} } = {}) {
  return new Promise((resolve, reject) => {
    execFile(
      process.execPath,
      [script, ...args, "--json"],
      { env: { ...process.env, ...env }, maxBuffer: 64 * 1024 * 1024 },
      (err, stdout, stderr) => {
        if (stderr) process.stderr.write(stderr);
        if (err) return reject(new Error(`child ${path.basename(script)} ${args.join(" ")} failed: ${err.message}`));
        try {
          resolve(JSON.parse(stdout));
        } catch (e) {
          reject(new Error(`child ${path.basename(script)} emitted non-JSON stdout: ${String(stdout).slice(0, 400)}`));
        }
      },
    );
  });
}

// --------------------------------------------------------------- engine load

/** Import a sasso-modern-API module from a filesystem path (or bare specifier). */
export async function importImpl(implPath) {
  const spec = implPath.includes("/") || implPath.includes("\\") ? pathToFileURL(implPath).href : implPath;
  return import(spec);
}

/** High-resolution monotonic milliseconds. */
export function nowMs() {
  return performance.now();
}

/** Format a stats row for stderr human output. */
export function fmtStats(label, st, unit = "ms") {
  if (!st) return `${label}: (no samples)`;
  return `${label}: median=${st.median}${unit} p10=${st.p10} p90=${st.p90} mad=${st.mad} n=${st.n}`;
}
