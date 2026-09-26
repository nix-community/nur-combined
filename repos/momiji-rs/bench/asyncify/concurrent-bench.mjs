// Concurrent async-compile bench — the deterministic in-repo reproduction of
// the asyncLock serialization pathology (scenario "concurrent"; E4/F1 in
// docs/HANDOFF_ASYNC_IMPORTER_PERF.md).
//
// WHAT IS MEASURED. wasm/npm/_loader.mjs has exactly one asyncify stack, so
// `runAsyncLocked` (:638-645) serializes every `compileStringAsync` behind
// `asyncLock` (:467): N concurrent compiles execute strictly one after
// another. Bundlers fan out (an rspack cold build submits ~10 sass entries
// at once), so per-compile wall time inflates ~N× — the handoff's E4 rows
// with `engineMs=2792ms, calls:{}` were compiles *queued on the lock*, not
// compiling. Until now no in-repo bench issued overlapping async compiles;
// this one does.
//
// METHOD. Each compile pulls K modules through an in-memory importer on the
// `bench:` scheme whose canonicalize and load each `await sleep(delay)`
// before returning (delay=0 still yields, via setImmediate). The latency is
// PROGRAMMED, not incidental, which makes the serialization signal
// machine-load-robust: under the current asyncLock the round makespan is
// ~N·K·2·delay regardless of CPU contention. Each concurrent compile gets
// its OWN importer whose canonicalize records performance.now() of the
// FIRST host callback for that compile, so startLag = firstCall − submit
// exposes queueing directly (the in-repo equivalent of the E4 signature).
//
// Per configuration the worker measures a SOLO reference (3 sequential
// compiles, median wall = soloMs), then W warmup + R measured rounds of
// N-way `Promise.all` fan-out, reporting per-round makespan, per-compile
// wall and startLag, and factors derived against soloMs.
//
// ACCEPTANCE (F1). Baseline (asyncLock): serializationFactor ≈ N, and
// startLag grows staircase-like across the N compiles of a round (compile i
// waits ~i·soloMs for its first host callback). After F1 (instance pool of
// size ≥ N): serializationFactor ≈ 1 + ε for delay-dominated compiles and
// queuedCompiles ≈ 0.
//
// RUN.
//   node bench/asyncify/concurrent-bench.mjs                    # sweep N × delay
//   node bench/asyncify/concurrent-bench.mjs --quick
//   node bench/asyncify/concurrent-bench.mjs --n 8 --delay 2    # single config
//   node bench/asyncify/concurrent-bench.mjs --worker --n 4 --k 12 --delay 2 \
//     --rounds 7 --warmup-rounds 2                              # one child; JSON on stdout
// Orchestrator flags (lib/harness.mjs): --impl <sasso.mjs> --reps <R>
//   --warmup <W> --label <s> --out <dir> --json --quick --force --max-load <n>
// stdout is DATA (worker JSON / --json result doc); humans read stderr.

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import {
  parseCommonArgs,
  restFlag,
  restHas,
  captureEnv,
  enforceLoadGuard,
  stats,
  writeResult,
  runChild,
  importImpl,
  nowMs,
} from "./lib/harness.mjs";

const SELF = fileURLToPath(import.meta.url);
const opts = parseCommonArgs(process.argv.slice(2));
const log = (s) => process.stderr.write(s + "\n");

// ------------------------------------------------------------------ shared

function makeSource(k) {
  let src = "";
  for (let i = 0; i < k; i++) src += `@use "m${i}";\n`;
  return src + "a { b: c; }\n";
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// delay=0 must still be asynchronous — the importer result must not be
// available synchronously, or a future sync fast-path (F3) would skip the
// suspension this bench exists to overlap.
function makeWait(delay) {
  return delay > 0 ? () => sleep(delay) : () => new Promise((r) => setImmediate(r));
}

// One importer object PER COMPILE: `rec.firstCall` is the performance.now()
// of the first host callback for that compile — a compile queued on
// asyncLock gets no host calls until the lock frees, so
// startLag = firstCall − submit is the queueing detector.
function makeImporter(wait, rec) {
  return {
    async canonicalize(url) {
      if (rec.firstCall === null) rec.firstCall = nowMs();
      await wait();
      return new URL(url.startsWith("bench:") ? url : "bench:" + url);
    },
    async load(canonicalUrl) {
      await wait();
      const name = canonicalUrl.href.slice("bench:".length);
      return { contents: `.${name} { d: e; }`, syntax: "scss" };
    },
  };
}

// Submit one compile; sanity-check the output AFTER capturing timestamps
// (a benchmark that silently compiles the wrong thing is worse than none).
async function compileOnce(compileStringAsync, src, wait, marker) {
  const rec = { firstCall: null };
  const importer = makeImporter(wait, rec);
  const submit = nowMs();
  const result = await compileStringAsync(src, { importers: [importer] });
  const settle = nowMs();
  if (!result.css.includes(marker)) {
    process.stderr.write(`SANITY FAIL: compiled CSS is missing marker ${JSON.stringify(marker)}\n`);
    process.exit(1);
  }
  return { submit, settle, wall: settle - submit, firstCall: rec.firstCall ?? settle };
}

function intFlag(flag, dflt) {
  const v = parseInt(restFlag(opts.rest, flag, dflt), 10);
  if (!Number.isInteger(v) || v < 0) {
    process.stderr.write(`concurrent: ${flag} must be a non-negative integer\n`);
    process.exit(1);
  }
  return v;
}

// ------------------------------------------------------------------- worker
// Exactly ONE configuration in-process (JIT/wasm-instance isolation); one
// JSON object on stdout, progress on stderr.

async function workerMain() {
  const n = intFlag("--n", "4");
  const k = intFlag("--k", "12");
  const delay = parseFloat(restFlag(opts.rest, "--delay", "2"));
  const rounds = intFlag("--rounds", "3");
  const warmupRounds = intFlag("--warmup-rounds", "1");
  if (n < 1 || rounds < 1 || !(delay >= 0)) {
    process.stderr.write("concurrent worker: need --n >= 1, --rounds >= 1, --delay >= 0\n");
    process.exit(1);
  }

  const { compileStringAsync } = await importImpl(opts.impl);
  if (typeof compileStringAsync !== "function") {
    process.stderr.write(`concurrent worker: ${opts.impl} exports no compileStringAsync\n`);
    process.exit(1);
  }
  const src = makeSource(k);
  const wait = makeWait(delay);
  const marker = k > 0 ? `.m${k - 1} {` : "a {";

  // Warm the asyncify instance + JIT once (also the first sanity check).
  await compileOnce(compileStringAsync, src, wait, marker);

  // SOLO reference: sequential compiles never contend on asyncLock, so
  // soloMs ≈ K·2·delay + engine time. Everything below is scored against it.
  const soloWalls = [];
  for (let i = 0; i < 3; i++) {
    soloWalls.push((await compileOnce(compileStringAsync, src, wait, marker)).wall);
  }
  const soloMs = stats(soloWalls).median;
  log(`worker n=${n} k=${k} delay=${delay}ms: solo=${soloMs.toFixed(2)}ms`);

  // One round = N concurrent submissions (all within the same tick).
  async function round() {
    const outcomes = await Promise.all(
      Array.from({ length: n }, () => compileOnce(compileStringAsync, src, wait, marker)),
    );
    const first = Math.min(...outcomes.map((o) => o.submit));
    const last = Math.max(...outcomes.map((o) => o.settle));
    return {
      makespan: +(last - first).toFixed(4),
      walls: outcomes.map((o) => +o.wall.toFixed(4)),
      startLags: outcomes.map((o) => +(o.firstCall - o.submit).toFixed(4)),
    };
  }

  for (let i = 0; i < warmupRounds; i++) await round();
  const perRound = [];
  for (let i = 0; i < rounds; i++) {
    const r = await round();
    perRound.push(r);
    log(`  round ${i + 1}/${rounds}: makespan=${r.makespan.toFixed(1)}ms`);
  }

  const makespans = perRound.map((r) => r.makespan);
  const walls = perRound.flatMap((r) => r.walls);
  const startLags = perRound.flatMap((r) => r.startLags);
  const derived = {
    makespan: stats(makespans),
    wall: stats(walls),
    startLag: stats(startLags),
    // ≈ N under asyncLock; ≈ 1 + ε once concurrent compiles truly overlap.
    serializationFactor: +(stats(makespans).median / soloMs).toFixed(3),
    wallFactor: +(stats(walls).median / soloMs).toFixed(3),
    // A compile whose first host callback comes later than a WHOLE solo
    // compile was queued, not running (the E4 `calls:{}` signature).
    queuedCompiles: startLags.filter((x) => x > soloMs).length,
    totalCompiles: startLags.length,
  };

  process.stdout.write(
    JSON.stringify({
      params: { n, k, delay, rounds, warmupRounds },
      soloMs: +soloMs.toFixed(4),
      perRound,
      derived,
    }) + "\n",
  );
}

// ------------------------------------------------------------- orchestrator
// One child process per (N, delay) configuration, run serially.

async function orchestratorMain() {
  const guard = enforceLoadGuard(opts);
  const env = captureEnv(opts.impl);

  const k = intFlag("--k", "12");
  const rounds = opts.reps ?? (opts.quick ? 3 : 7);
  const warmupRounds = opts.warmup ?? (opts.quick ? 1 : 2);

  // --n/--delay collapse the sweep to a single configuration.
  const nOverride = restFlag(opts.rest, "--n");
  const dOverride = restFlag(opts.rest, "--delay");
  let configs;
  if (nOverride !== null || dOverride !== null) {
    configs = [{ n: parseInt(nOverride ?? "4", 10), delay: parseFloat(dOverride ?? "2") }];
  } else {
    const ns = opts.quick ? [1, 4] : [1, 2, 4, 8];
    const delays = opts.quick ? [2] : [0, 2];
    configs = delays.flatMap((delay) => ns.map((n) => ({ n, delay })));
  }

  log(`concurrent: impl=${opts.impl}`);
  log(
    `concurrent: K=${k} rounds=${rounds} warmup=${warmupRounds} ` +
      `configs=[${configs.map((c) => `N${c.n}/d${c.delay}`).join(" ")}]`,
  );

  const results = [];
  for (const { n, delay } of configs) {
    log(`--- config N=${n} delay=${delay}ms`);
    results.push(
      await runChild(SELF, [
        "--worker",
        "--n", String(n),
        "--k", String(k),
        "--delay", String(delay),
        "--rounds", String(rounds),
        "--warmup-rounds", String(warmupRounds),
        "--impl", opts.impl,
      ]),
    );
  }

  // Human summary (stderr): baseline shows serial-x climbing with N;
  // a fixed tree shows serial-x pinned near 1 and queued near 0.
  const pad = (s, w) => String(s).padStart(w);
  log("");
  log(
    pad("N", 3) + pad("delay", 7) + pad("solo ms", 10) + pad("serial-x", 10) +
      pad("wall-x", 8) + pad("lag p90", 10) + pad("queued", 9),
  );
  for (const r of results) {
    const d = r.derived;
    log(
      pad(r.params.n, 3) +
        pad(`${r.params.delay}ms`, 7) +
        pad(r.soloMs.toFixed(2), 10) +
        pad(d.serializationFactor.toFixed(2), 10) +
        pad(d.wallFactor.toFixed(2), 8) +
        pad(d.startLag.p90.toFixed(1), 10) +
        pad(`${d.queuedCompiles}/${d.totalCompiles}`, 9),
    );
  }
  log("");

  const file = writeResult({
    scenario: "concurrent",
    opts,
    env,
    params: { k, rounds, warmupRounds, quick: opts.quick, configs, loadGuard: guard },
    results,
    warnings: guard.warnings,
  });
  log(`result: ${file}`);
  if (opts.json) process.stdout.write(readFileSync(file, "utf8"));
}

try {
  if (restHas(opts.rest, "--worker")) await workerMain();
  else await orchestratorMain();
} catch (e) {
  process.stderr.write(`concurrent: ${e?.stack ?? e}\n`);
  process.exit(1);
}
