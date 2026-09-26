// A/B comparator for the bench/asyncify scenario scripts — turns "I applied
// fix F1/F2/F3" into a defensible before/after verdict on a machine that may
// not be perfectly quiet.
//
// `run` executes one scenario's WORKER mode at that scenario's CANONICAL
// configuration, one child process per measurement (per-process isolation),
// alternating implementation order per pair in an ABBA scheme
// (pair 1: A,B; pair 2: B,A; ...) so slow thermal/load drift cancels out of
// the per-pair deltas. The deltas (B−A) feed an exact two-sided binomial SIGN
// TEST; the verdict is only 'A faster' / 'B faster' when p ≤ 0.1 AND the
// median change is ≥ 2% — otherwise 'within noise'. This is the noise
// discipline of docs/HANDOFF_ASYNC_IMPORTER_PERF.md: under background load,
// the *direction* of interleaved deltas survives; absolute magnitudes do not.
//
// Canonical configs and primary metric (all time-based; lower = faster):
//   suspension  --mode async-syncimp --k 50 --reps 20 --warmup 5      stats.median            (F3)
//   concurrent  --n 8 --k 12 --delay 2 --rounds 3 --warmup-rounds 1   derived.makespan.median (F1)
//   corpus      --engine sasso-async --concurrency 1 --reps 10 --warmup 3  stats.median       (F2)
// (--quick shrinks the reps/rounds; the config shape stays canonical.)
//
// Run (from the repo root; scenario scripts live next to this file):
//   node bench/asyncify/ab-compare.mjs run --scenario <suspension|concurrent|corpus> \
//     --impl-a <baseline sasso.mjs> --impl-b <candidate sasso.mjs> \
//     [--pairs N=6] [--quick] [--force] [--label-a s] [--label-b s] [--json] [--out dir]
//   node bench/asyncify/ab-compare.mjs diff <a.json> <b.json>
//     Metric-by-metric % table of two result files written by the SAME
//     scenario script; a |delta| ≤ 2·max(MAD_a, MAD_b) is flagged 'within
//     noise'. Config keys become 0-delta rows — a NONZERO delta on one means
//     the two runs are not comparable.
//
// stdout is DATA (JSON, only with --json); humans read stderr. `run` writes
// results/ab-<scenario>--<label>.json. Sanity: each child's primary metric
// must exist and be finite (the scenario workers themselves sanity-check the
// compiled CSS); anything else exits 1 loudly.

import { existsSync, readFileSync } from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import {
  SCHEMA,
  captureEnv,
  checkLoad,
  enforceLoadGuard,
  parseCommonArgs,
  restFlag,
  runChild,
  stats,
  writeResult,
} from "./lib/harness.mjs";

const HERE = path.dirname(fileURLToPath(import.meta.url));

// Scenario registry: worker script (sibling file), canonical worker args, and
// the dotted path of the primary metric inside the worker's JSON output.
const SCENARIOS = {
  suspension: {
    script: "suspension-bench.mjs",
    metric: "stats.median",
    fix: "F3",
    args: (quick) =>
      quick
        ? ["--mode", "async-syncimp", "--k", "50", "--reps", "8", "--warmup", "2"]
        : ["--mode", "async-syncimp", "--k", "50", "--reps", "20", "--warmup", "5"],
  },
  concurrent: {
    script: "concurrent-bench.mjs",
    metric: "derived.makespan.median",
    fix: "F1",
    args: (quick) =>
      quick
        ? ["--n", "8", "--k", "12", "--delay", "2", "--rounds", "2", "--warmup-rounds", "1"]
        : ["--n", "8", "--k", "12", "--delay", "2", "--rounds", "3", "--warmup-rounds", "1"],
  },
  corpus: {
    script: "corpus-bench.mjs",
    metric: "stats.median",
    fix: "F2",
    args: (quick) =>
      quick
        ? ["--engine", "sasso-async", "--concurrency", "1", "--reps", "4", "--warmup", "1"]
        : ["--engine", "sasso-async", "--concurrency", "1", "--reps", "10", "--warmup", "3"],
  },
};

const err = (msg) => {
  process.stderr.write(`ab-compare: ${msg}\n`);
  process.exit(1);
};
const say = (s) => process.stderr.write(s + "\n");

function usage() {
  say(
    "usage: node ab-compare.mjs run --scenario <suspension|concurrent|corpus> --impl-a <sasso.mjs> --impl-b <sasso.mjs>\n" +
      "                              [--pairs 6] [--quick] [--force] [--label-a s] [--label-b s] [--json] [--out dir]\n" +
      "       node ab-compare.mjs diff <a.json> <b.json> [--json]",
  );
}

// ------------------------------------------------------------------ helpers

function getPath(obj, dotted) {
  let cur = obj;
  for (const part of dotted.split(".")) {
    if (cur == null || typeof cur !== "object") return undefined;
    cur = cur[part];
  }
  return cur;
}

// Workers may put the metric at the top level or under results/result — the
// three scenario scripts are authored independently, so probe defensively.
function extractMetric(doc, dotted) {
  for (const root of [doc, doc?.results, doc?.result]) {
    if (root == null) continue;
    const v = getPath(root, dotted);
    if (typeof v === "number" && Number.isFinite(v)) return v;
  }
  return null;
}

function choose(n, k) {
  let r = 1;
  for (let i = 1; i <= k; i++) r = (r * (n - k + i)) / i;
  return r;
}

// Exact two-sided binomial sign test on the signs of `deltas` (zeros dropped).
function signTestP(deltas) {
  const nz = deltas.filter((d) => d !== 0);
  const n = nz.length;
  if (n === 0) return 1;
  const pos = nz.filter((d) => d > 0).length;
  const m = Math.min(pos, n - pos);
  let tail = 0;
  for (let i = 0; i <= m; i++) tail += choose(n, i);
  return Math.min(1, (2 * tail) / 2 ** n);
}

function fmtNum(x) {
  if (x == null || Number.isNaN(x)) return "-";
  if (!Number.isFinite(x)) return String(x);
  const ax = Math.abs(x);
  if (ax >= 1000) return x.toFixed(0);
  if (ax >= 100) return x.toFixed(1);
  if (ax >= 1) return x.toFixed(3);
  return x.toFixed(4);
}

function fmtPct(x) {
  return x == null ? "-" : `${x >= 0 ? "+" : ""}${x.toFixed(1)}%`;
}

const pad = (s, w) => String(s).padStart(w);
const padr = (s, w) => String(s).padEnd(w);

// -------------------------------------------------------------------- `run`

async function runCmd(argv) {
  const opts = parseCommonArgs(argv);
  const scenario = restFlag(opts.rest, "--scenario");
  if (!scenario || !SCENARIOS[scenario]) {
    usage();
    err(`--scenario must be one of: ${Object.keys(SCENARIOS).join(", ")}`);
  }
  const cfg = SCENARIOS[scenario];
  const script = path.join(HERE, cfg.script);
  if (!existsSync(script)) {
    err(
      `scenario script not found: ${script}\n` +
        `  the run subcommand drives the worker mode of suspension-bench.mjs / concurrent-bench.mjs / corpus-bench.mjs;\n` +
        `  make sure the scenario scripts exist next to ab-compare.mjs.`,
    );
  }

  const implA = restFlag(opts.rest, "--impl-a");
  const implB = restFlag(opts.rest, "--impl-b");
  if (!implA || !implB) err("run requires both --impl-a and --impl-b (paths to sasso.mjs entry points)");
  const a = path.resolve(implA);
  const b = path.resolve(implB);
  for (const [flag, p] of [["--impl-a", a], ["--impl-b", b]]) {
    if (!existsSync(p)) err(`${flag}: no such file: ${p}`);
  }
  const labelA = restFlag(opts.rest, "--label-a", "A");
  const labelB = restFlag(opts.rest, "--label-b", "B");
  const nPairs = parseInt(restFlag(opts.rest, "--pairs", "6"), 10);
  if (!Number.isInteger(nPairs) || nPairs < 1) err("--pairs must be a positive integer");

  const guard = enforceLoadGuard(opts);
  const warnings = [...guard.warnings];
  if (guard.forced) warnings.push("forced: ran despite load guard failure");
  if (nPairs < 5) {
    const w = `only ${nPairs} pairs: an exact sign test cannot reach p<=0.1 with n<5; verdict will be 'within noise'`;
    warnings.push(w);
    say(`WARNING: ${w}`);
  }

  const env = captureEnv(a); // machine + impl-a wasm hashes
  const envB = captureEnv(b); // impl-b wasm hashes (same machine snapshot)
  if (JSON.stringify(env.wasm) === JSON.stringify(envB.wasm) && Object.keys(env.wasm).length) {
    const w = "impl-a and impl-b have identical wasm hashes — comparing a build to itself?";
    warnings.push(w);
    say(`WARNING: ${w}`);
  }

  const workerArgs = cfg.args(opts.quick);
  // Children run their own load guard: forward both the override and the
  // relaxed threshold, or an explicitly-permitted run dies in the first child.
  const childArgs = (impl) => [
    "--worker",
    ...workerArgs,
    "--impl",
    impl,
    ...(opts.force ? ["--force"] : []),
    ...(opts.maxLoad != null ? ["--max-load", String(opts.maxLoad)] : []),
  ];

  say(`== ab-compare run: scenario=${scenario} (${cfg.fix})  metric=${cfg.metric}  pairs=${nPairs}${opts.quick ? "  [quick]" : ""}`);
  say(`   A = ${labelA}  ${a}`);
  say(`   B = ${labelB}  ${b}`);
  say(`   worker config: ${workerArgs.join(" ")}`);

  async function measure(which, impl) {
    const doc = await runChild(script, childArgs(impl));
    const v = extractMetric(doc, cfg.metric);
    if (v == null) {
      err(
        `worker for ${which} did not report a finite '${cfg.metric}'.\n` +
          `  top-level keys: ${JSON.stringify(Object.keys(doc ?? {}))}\n` +
          `  results keys:   ${JSON.stringify(Object.keys(doc?.results ?? {}))}`,
      );
    }
    return v;
  }

  const pairs = [];
  for (let i = 0; i < nPairs; i++) {
    const aFirst = i % 2 === 0; // ABBA: pair1 A,B; pair2 B,A; ...
    const order = aFirst ? "A,B" : "B,A";
    say(`-- pair ${i + 1}/${nPairs} (${order})`);
    let va;
    let vb;
    if (aFirst) {
      va = await measure("A", a);
      vb = await measure("B", b);
    } else {
      vb = await measure("B", b);
      va = await measure("A", a);
    }
    const delta = vb - va;
    const pct = va !== 0 ? (delta / va) * 100 : null;
    const load = +os.loadavg()[0].toFixed(2);
    const mid = checkLoad({ maxLoad: opts.maxLoad, force: true });
    if (!mid.ok) warnings.push(`pair ${i + 1}: ${mid.warnings[0]}`);
    pairs.push({ pair: i + 1, order, a: va, b: vb, delta, pct, load });
  }

  const deltas = pairs.map((p) => p.delta);
  const pcts = pairs.map((p) => p.pct).filter((v) => v != null);
  const medianDelta = stats(deltas).median;
  const medianPct = pcts.length ? stats(pcts).median : null;
  const nPos = deltas.filter((d) => d > 0).length;
  const nNeg = deltas.filter((d) => d < 0).length;
  const p = signTestP(deltas);
  const verdict =
    p > 0.1 || medianPct === null || Math.abs(medianPct) < 2
      ? "within noise"
      : medianDelta < 0
        ? "B faster"
        : "A faster";

  // Human table (stderr).
  say("");
  say(` pair  order ${pad("A", 10)} ${pad("B", 10)} ${pad("B-A", 10)} ${pad("%", 8)} ${pad("load", 6)}`);
  for (const r of pairs) {
    say(
      ` ${pad(r.pair, 4)}  ${padr(r.order, 5)} ${pad(fmtNum(r.a), 10)} ${pad(fmtNum(r.b), 10)} ${pad(fmtNum(r.delta), 10)} ${pad(fmtPct(r.pct), 8)} ${pad(r.load, 6)}`,
    );
  }
  say("");
  say(
    ` median delta: ${fmtNum(medianDelta)} ms (${fmtPct(medianPct)})   sign test: +${nPos}/-${nNeg} p=${p.toFixed(4)}`,
  );
  say(` verdict: ${verdict}  (B = ${labelB})`);

  const params = {
    scenario,
    fix: cfg.fix,
    script: cfg.script,
    metric: cfg.metric,
    workerArgs: workerArgs.join(" "),
    pairs: nPairs,
    quick: opts.quick,
    a: { label: labelA, impl: a, wasm: env.wasm },
    b: { label: labelB, impl: b, wasm: envB.wasm },
  };
  const results = {
    pairs,
    a: stats(pairs.map((r) => r.a)),
    b: stats(pairs.map((r) => r.b)),
    medianDelta,
    medianPct,
    nPos,
    nNeg,
    signTestP: +p.toFixed(6),
    verdict,
  };
  // Distinct A/B runs must not overwrite each other: fold the side labels into
  // the filename (successive runs against different baselines share a commit).
  const abOpts = { ...opts, label: opts.label ?? `${labelA}-vs-${labelB}` };
  const file = writeResult({ scenario: `ab-${scenario}`, opts: abOpts, env, params, results, warnings });
  say(` wrote: ${file}`);

  if (opts.json) {
    const label = abOpts.label;
    process.stdout.write(
      JSON.stringify({ schema: SCHEMA, scenario: `ab-${scenario}`, label, env, params, results, warnings }, null, 1) + "\n",
    );
  }
}

// ------------------------------------------------------------------- `diff`

function isStatsBlock(v) {
  return v != null && typeof v === "object" && !Array.isArray(v) && typeof v.median === "number";
}

// Walk two `results` trees in parallel; every stats block collapses to its
// median (MADs kept for the noise flag), every bare number becomes a row.
function walkDiff(a, b, prefix, rows) {
  const keys = [...new Set([...Object.keys(a ?? {}), ...Object.keys(b ?? {})])];
  for (const k of keys) {
    const va = a?.[k];
    const vb = b?.[k];
    const p = prefix ? `${prefix}.${k}` : k;
    if (isStatsBlock(va) || isStatsBlock(vb)) {
      rows.push(mkRow(`${p}.median`, va?.median, vb?.median, va?.mad, vb?.mad));
    } else if (typeof va === "number" || typeof vb === "number") {
      rows.push(mkRow(p, va, vb, null, null));
    } else if ((va != null && typeof va === "object") || (vb != null && typeof vb === "object")) {
      walkDiff(va, vb, p, rows);
    } else if (typeof va === "string" || typeof vb === "string" || typeof va === "boolean" || typeof vb === "boolean") {
      // Config strings (engine, mode, entry, …) are the comparability
      // tripwire: unequal values mean the runs measured different things.
      if (va !== vb) rows.push({ metric: p, a: va ?? null, b: vb ?? null, delta: null, pct: null, madA: null, madB: null, flag: "CONFIG MISMATCH" });
    }
  }
}

function mkRow(metric, a, b, madA, madB) {
  const both = typeof a === "number" && typeof b === "number";
  const delta = both ? b - a : null;
  const pct = both && a !== 0 ? ((b - a) / a) * 100 : null;
  let flag = "";
  if (!both) flag = typeof a !== "number" ? "missing in A" : "missing in B";
  else if (typeof madA === "number" || typeof madB === "number") {
    if (Math.abs(delta) <= 2 * Math.max(madA ?? 0, madB ?? 0)) flag = "within noise";
  } else if (delta === 0) flag = "equal";
  return { metric, a: a ?? null, b: b ?? null, delta, pct, madA: madA ?? null, madB: madB ?? null, flag };
}

function loadDoc(file) {
  let raw;
  try {
    raw = readFileSync(file, "utf8");
  } catch (e) {
    err(`cannot read ${file}: ${e.message}`);
  }
  try {
    return JSON.parse(raw);
  } catch {
    err(`${file} is not valid JSON (expected a ${SCHEMA} result document)`);
  }
}

async function diffCmd(argv) {
  const opts = parseCommonArgs(argv);
  const files = opts.rest;
  if (files.length !== 2 || files.some((f) => f.startsWith("--"))) {
    usage();
    err("diff takes exactly two result-file paths");
  }
  const [fa, fb] = files.map((f) => path.resolve(f));
  const da = loadDoc(fa);
  const db = loadDoc(fb);
  for (const [f, d] of [[fa, da], [fb, db]]) {
    if (d.schema !== SCHEMA) say(`WARNING: ${path.basename(f)} schema=${d.schema ?? "?"} (expected ${SCHEMA})`);
  }
  if (da.scenario !== db.scenario) {
    err(
      `scenario mismatch: ${path.basename(fa)} is '${da.scenario}', ${path.basename(fb)} is '${db.scenario}' — ` +
        `diff only compares result files from the same scenario script`,
    );
  }

  const rows = [];
  walkDiff(da.results ?? {}, db.results ?? {}, "", rows);

  say(`== ab-compare diff: scenario=${da.scenario}`);
  say(`   A: ${path.basename(fa)}  label=${da.label ?? "?"}  commit=${da.env?.commit ?? "?"}${da.env?.dirty ? "-dirty" : ""}  load=${JSON.stringify(da.env?.loadavg ?? [])}`);
  say(`   B: ${path.basename(fb)}  label=${db.label ?? "?"}  commit=${db.env?.commit ?? "?"}${db.env?.dirty ? "-dirty" : ""}  load=${JSON.stringify(db.env?.loadavg ?? [])}`);
  if (JSON.stringify(da.env?.wasm ?? {}) === JSON.stringify(db.env?.wasm ?? {})) {
    say("   note: identical wasm hashes on both sides — same binaries were measured");
  }
  const wa = (da.warnings ?? []).length;
  const wb = (db.warnings ?? []).length;
  if (wa || wb) say(`   WARNING: result files carry warnings (A:${wa} B:${wb}) — check them before trusting deltas`);
  say("   note: config keys appear as rows; a nonzero delta on one means the runs are NOT comparable");
  say("");
  const w0 = Math.max(6, ...rows.map((r) => r.metric.length));
  say(` ${padr("metric", w0)} ${pad("A", 10)} ${pad("B", 10)} ${pad("B-A", 10)} ${pad("%", 8)}  flag`);
  for (const r of rows) {
    say(
      ` ${padr(r.metric, w0)} ${pad(fmtNum(r.a), 10)} ${pad(fmtNum(r.b), 10)} ${pad(fmtNum(r.delta), 10)} ${pad(fmtPct(r.pct), 8)}  ${r.flag}`,
    );
  }
  if (!rows.length) say(" (no numeric metrics found in either results tree)");

  if (opts.json) {
    process.stdout.write(
      JSON.stringify(
        {
          schema: `${SCHEMA}+diff`,
          scenario: da.scenario,
          a: { file: fa, label: da.label ?? null, env: da.env ?? null },
          b: { file: fb, label: db.label ?? null, env: db.env ?? null },
          rows,
        },
        null,
        1,
      ) + "\n",
    );
  }
}

// -------------------------------------------------------------------- main

const [sub, ...argvRest] = process.argv.slice(2);
if (sub === "run") await runCmd(argvRest);
else if (sub === "diff") await diffCmd(argvRest);
else {
  usage();
  process.exit(1);
}
