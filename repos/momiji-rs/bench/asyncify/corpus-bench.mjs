// corpus-bench.mjs — scenario "corpus": full-compile cost of the import-heavy
// modular corpus (bench/corpus/modular, 36 files per entry via the loadPaths
// FS chain) across engine variants, plus a concurrent cold-build repro.
//
// Formalizes E2 and E4 of docs/HANDOFF_ASYNC_IMPORTER_PERF.md:
//   • concurrency 1 — sequential full compiles of entry_01 per engine (the
//     watch-rebuild shape; E2 measured 16.3 ms sync vs 21.6 ms async wasm on
//     the real tailwind corpus of the same shape);
//   • concurrency 8 (sasso-async) — entry_01..entry_08 compiled concurrently
//     per round via Promise.all (the bundler multi-entry cold-build fan-out of
//     E4, where `asyncLock` in wasm/npm/_loader.mjs serializes everything).
//     serializationFactor = median(makespan) / median(solo entry_01 wall).
//
// ACCEPTANCE (maps to the handoff's fix list):
//   F2 (asyncify -O3 build) lands when sasso-speed-async's median approaches
//      sasso-speed-sync × (a small asyncify tax) instead of tracking the -Oz
//      module — today sasso-speed-async ≈ sasso-async because "sasso/speed"'s
//      async APIs share the size-optimized sasso.async.wasm.
//   F1 (concurrent async compiles) lands when the concurrency-8
//      serializationFactor drops from ~8 (asyncLock queueing) to ~1-2.
//
// Modes (per-process isolation per configuration is mandatory — JIT/wasm
// instance state pollutes cross-config numbers):
//   orchestrator (default) — load-guards the machine, spawns one child per
//     (engine, concurrency) configuration, aggregates, writes
//     results/corpus--<label>.json, prints a summary table on stderr;
//   --worker — runs exactly ONE configuration in-process and prints ONE JSON
//     object on stdout (all progress on stderr).
//
// Engines: sasso-sync | sasso-async | sasso-speed-sync | sasso-speed-async
//   (speed = the sibling sasso.speed.mjs of --impl) | embedded-sync |
//   embedded-async (optional comparator: when `sass-embedded` cannot be
//   imported the worker reports {skipped, reason} and the sweep continues).
//
// Every compile is sanity-checked: the corpus marker ".sasso-corpus-sanity"
// (or --marker) must appear in the CSS, else exit 1 — a benchmark that
// silently compiles the wrong thing is worse than none.
//
// Run:
//   node bench/asyncify/corpus-bench.mjs                    # full sweep
//   node bench/asyncify/corpus-bench.mjs --quick            # sasso sync/async, c=1
//   node bench/asyncify/corpus-bench.mjs --external-rails <apps/rails-path>
//       # adds "external-tailwind" configs compiling the handoff's real corpus
//       # (<path>/app/javascript/stylesheets/tailwind.scss with loadPaths
//       # [<path>/node_modules]); silently skipped when the path is absent
//   node bench/asyncify/corpus-bench.mjs --worker --engine sasso-async \
//       --concurrency 1 --reps 20 --warmup 5                # one config
// Worker flags: --engine <e> --concurrency <N> [--entry <scss> --load-path <dir>
//   --marker <s>]. At concurrency > 1, --reps means measured ROUNDS and
//   --warmup means warmup rounds. Common flags (--impl --reps --warmup --quick
//   --force --label --out --json) per lib/harness.mjs.

import { existsSync, readFileSync } from "node:fs";
import * as path from "node:path";
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
  fmtStats,
  CORPUS_DIR,
} from "./lib/harness.mjs";

const SCRIPT = fileURLToPath(import.meta.url);
const MODULAR_DIR = path.join(CORPUS_DIR, "modular");
const VENDOR_DIR = path.join(MODULAR_DIR, "vendor");
const DEFAULT_MARKER = ".sasso-corpus-sanity";
const EXTERNAL_MARKER = "@keyframes typingDots";

const ENGINES = {
  "sasso-sync": { kind: "sasso", speed: false, async: false },
  "sasso-async": { kind: "sasso", speed: false, async: true },
  "sasso-speed-sync": { kind: "sasso", speed: true, async: false },
  "sasso-speed-async": { kind: "sasso", speed: true, async: true },
  "embedded-sync": { kind: "embedded", async: false },
  "embedded-async": { kind: "embedded", async: true },
};

function die(msg) {
  process.stderr.write(`corpus-bench: ${msg}\n`);
  process.exit(1);
}

// ------------------------------------------------------------------ worker

/** Resolve and import the module implementing the modern API for `engine`. */
async function loadEngine(spec, implPath, params) {
  if (spec.kind === "embedded") {
    try {
      return await import("sass-embedded");
    } catch (e) {
      // Optional comparator: report the skip as valid worker JSON and bow out.
      const reason = `sass-embedded unavailable: ${e && e.message ? e.message : e}`;
      process.stdout.write(JSON.stringify({ params, skipped: true, reason }) + "\n");
      process.exit(0);
    }
  }
  const p = spec.speed ? path.join(path.dirname(implPath), "sasso.speed.mjs") : implPath;
  if (!existsSync(p)) die(`engine module not found: ${p}`);
  return importImpl(p);
}

async function worker(opts) {
  const engineName = restFlag(opts.rest, "--engine");
  if (!engineName) die(`--worker requires --engine <${Object.keys(ENGINES).join("|")}>`);
  const spec = ENGINES[engineName];
  if (!spec) die(`unknown engine '${engineName}' (expected ${Object.keys(ENGINES).join(", ")})`);
  const concurrency = parseInt(restFlag(opts.rest, "--concurrency", "1"), 10);
  if (!Number.isInteger(concurrency) || concurrency < 1) die("--concurrency must be a positive integer");
  const entry = path.resolve(restFlag(opts.rest, "--entry", path.join(MODULAR_DIR, "entry_01.scss")));
  const loadPath = path.resolve(restFlag(opts.rest, "--load-path", VENDOR_DIR));
  const marker = restFlag(opts.rest, "--marker", DEFAULT_MARKER);
  if (!existsSync(entry)) {
    die(`entry not found: ${entry}` + (entry.startsWith(MODULAR_DIR) ? " — run `node bench/scripts/gen_modular_corpus.mjs` first" : ""));
  }

  // At concurrency > 1, --reps counts measured ROUNDS and --warmup warmup rounds.
  const reps = opts.reps ?? (concurrency > 1 ? (opts.quick ? 2 : 5) : opts.quick ? 8 : 20);
  const warmup = opts.warmup ?? (concurrency > 1 ? 1 : opts.quick ? 2 : 5);
  if (!Number.isInteger(reps) || reps < 1) die("--reps must be a positive integer");

  const params = { engine: engineName, concurrency, reps, warmup, entry, loadPath, marker, impl: opts.impl };
  const api = await loadEngine(spec, opts.impl, params);
  const options = { loadPaths: [loadPath], style: "expanded" };
  const compileOne = spec.async
    ? (file) => api.compileAsync(file, options)
    : async (file) => api.compile(file, options);

  const sanity = (res, file) => {
    if (!res || typeof res.css !== "string" || !res.css.includes(marker)) {
      process.stderr.write(
        `corpus-bench: SANITY FAIL — marker '${marker}' missing from the output of ${file} ` +
          `(engine ${engineName}); refusing to record a measurement of the wrong compile.\n`,
      );
      process.exit(1);
    }
  };
  const emit = (obj) => process.stdout.write(JSON.stringify(obj) + "\n");

  if (concurrency === 1) {
    process.stderr.write(`worker ${engineName} c=1 reps=${reps} warmup=${warmup} entry=${path.basename(entry)}\n`);
    let last = null;
    for (let i = 0; i < warmup; i++) {
      last = await compileOne(entry);
      sanity(last, entry);
    }
    const samples = [];
    for (let i = 0; i < reps; i++) {
      const t0 = nowMs();
      last = await compileOne(entry);
      samples.push(nowMs() - t0);
      sanity(last, entry);
    }
    const st = stats(samples);
    process.stderr.write(`  ${fmtStats(engineName, st)}\n`);
    emit({ params, stats: st, cssBytes: Buffer.byteLength(last.css), loadedFiles: last.loadedUrls.length });
    return;
  }

  // ---- concurrency > 1: multi-entry cold-build fan-out (async engines only)
  if (!spec.async) die(`engine ${engineName} is synchronous — concurrency ${concurrency} requires an async engine`);
  const entryDir = path.dirname(entry);
  const entries = [];
  for (let i = 1; i <= concurrency; i++) {
    const f = path.join(entryDir, `entry_${String(i).padStart(2, "0")}.scss`);
    if (!existsSync(f)) die(`missing ${f} — the corpus has fewer entries than --concurrency ${concurrency}`);
    entries.push(f);
  }
  const soloReps = opts.quick ? 3 : 5;
  process.stderr.write(
    `worker ${engineName} c=${concurrency} rounds=${reps} warmupRounds=${warmup} soloReps=${soloReps}\n`,
  );

  // Warmup rounds: full concurrent fan-out, untimed but sanity-checked.
  for (let w = 0; w < warmup; w++) {
    const rs = await Promise.all(entries.map((f) => compileOne(f)));
    rs.forEach((r, j) => sanity(r, entries[j]));
  }

  // Solo baseline: entry_01 alone, sequential — the serializationFactor denominator.
  const soloSamples = [];
  let last = null;
  for (let i = 0; i < soloReps; i++) {
    const t0 = nowMs();
    last = await compileOne(entries[0]);
    soloSamples.push(nowMs() - t0);
    sanity(last, entries[0]);
  }

  const wallSamples = []; // per-compile wall clock under fan-out (queueing shows up here)
  const makespanSamples = []; // whole-round Promise.all duration
  for (let r = 0; r < reps; r++) {
    const t0 = nowMs();
    const settled = await Promise.all(
      entries.map(async (f) => {
        const s0 = nowMs();
        const res = await compileOne(f);
        return { wall: nowMs() - s0, res, f };
      }),
    );
    makespanSamples.push(nowMs() - t0);
    for (const { wall, res, f } of settled) {
      wallSamples.push(wall);
      sanity(res, f);
    }
  }
  const soloSt = stats(soloSamples);
  const makespanSt = stats(makespanSamples);
  const serializationFactor = +(makespanSt.median / soloSt.median).toFixed(3);
  process.stderr.write(
    `  ${fmtStats("wall/compile", stats(wallSamples))}\n` +
      `  ${fmtStats("makespan", makespanSt)}\n` +
      `  ${fmtStats("solo entry_01", soloSt)}\n` +
      `  serializationFactor=${serializationFactor} (~${concurrency} = fully serialized, ~1-2 = F1 landed)\n`,
  );
  emit({
    params: { ...params, soloReps },
    wall: stats(wallSamples),
    makespan: makespanSt,
    solo: soloSt,
    serializationFactor,
    cssBytes: Buffer.byteLength(last.css),
    loadedFiles: last.loadedUrls.length,
  });
}

// ------------------------------------------------------------ orchestrator

async function orchestrate(opts) {
  const guard = enforceLoadGuard(opts);
  const env = captureEnv(opts.impl);
  const quick = opts.quick;
  const reps1 = opts.reps ?? (quick ? 8 : 20);
  const warm1 = opts.warmup ?? (quick ? 2 : 5);
  const rounds = quick ? 2 : 5;

  const configs = [];
  const c1Engines = quick
    ? ["sasso-sync", "sasso-async"]
    : ["sasso-sync", "sasso-async", "sasso-speed-sync", "sasso-speed-async", "embedded-sync", "embedded-async"];
  for (const e of c1Engines) configs.push({ name: e, engine: e, concurrency: 1, reps: reps1, warmup: warm1 });
  if (!quick) {
    configs.push({ name: "sasso-async@c8", engine: "sasso-async", concurrency: 8, reps: rounds, warmup: 1 });
  }

  // E2's real corpus, reproduced exactly when the rails worktree is around.
  const warnings = [...guard.warnings];
  if (guard.forced) warnings.push("recorded under --force on a loaded machine");
  const rails = restFlag(opts.rest, "--external-rails");
  if (rails) {
    const railsEntry = path.join(path.resolve(rails), "app", "javascript", "stylesheets", "tailwind.scss");
    if (existsSync(railsEntry)) {
      for (const e of ["sasso-sync", "sasso-async"]) {
        configs.push({
          name: `external-tailwind:${e}`,
          engine: e,
          concurrency: 1,
          reps: reps1,
          warmup: warm1,
          entry: railsEntry,
          loadPath: path.join(path.resolve(rails), "node_modules"),
          marker: EXTERNAL_MARKER,
        });
      }
    } else {
      warnings.push(`--external-rails: ${railsEntry} not found — external-tailwind configs skipped`);
      process.stderr.write(`note: ${warnings[warnings.length - 1]}\n`);
    }
  }

  const results = [];
  for (const cfg of configs) {
    process.stderr.write(`\n=== corpus config: ${cfg.name} (concurrency ${cfg.concurrency}) ===\n`);
    const args = [
      "--worker",
      "--engine",
      cfg.engine,
      "--concurrency",
      String(cfg.concurrency),
      "--reps",
      String(cfg.reps),
      "--warmup",
      String(cfg.warmup),
      "--impl",
      opts.impl,
    ];
    if (cfg.entry) args.push("--entry", cfg.entry, "--load-path", cfg.loadPath, "--marker", cfg.marker);
    results.push({ config: cfg.name, ...(await runChild(SCRIPT, args)) });
  }

  const file = writeResult({
    scenario: "corpus",
    opts,
    env,
    params: { quick, corpus: MODULAR_DIR, marker: DEFAULT_MARKER, externalRails: rails ?? null, configs },
    results,
    warnings,
  });

  printTable(results);
  process.stderr.write(`\nresult: ${file}\n`);
  if (opts.json) process.stdout.write(readFileSync(file, "utf8"));
}

/** Human summary (stderr): engine → median ms (+ ratio vs sasso-sync), and the
 * concurrent rows' serializationFactor. */
function printTable(results) {
  const median = (name) => {
    const r = results.find((x) => x.config === name);
    return r && r.stats ? r.stats.median : null;
  };
  const baseFor = (r) => median(r.config.startsWith("external-tailwind") ? "external-tailwind:sasso-sync" : "sasso-sync");

  process.stderr.write("\nengine/config              c   median ms   vs sasso-sync   notes\n");
  process.stderr.write("-------------------------  -  ----------  --------------  ------------------------------\n");
  for (const r of results) {
    const name = r.config.padEnd(26);
    const c = String(r.params?.concurrency ?? "?").padEnd(2);
    let med = "-";
    let ratio = "-";
    let notes = "";
    if (r.skipped) {
      notes = `skipped: ${r.reason}`;
    } else if (r.stats) {
      med = r.stats.median.toFixed(2);
      const base = baseFor(r);
      if (base) ratio = `${(r.stats.median / base).toFixed(2)}x`;
      notes = `css=${r.cssBytes}B files=${r.loadedFiles}`;
    } else if (r.makespan) {
      med = r.wall.median.toFixed(2);
      notes =
        `wall/compile; makespan=${r.makespan.median.toFixed(2)}ms ` +
        `serializationFactor=${r.serializationFactor} (F1 target: ~1-2)`;
    }
    process.stderr.write(`${name} ${c} ${med.padStart(10)}  ${ratio.padStart(14)}  ${notes}\n`);
  }
}

// -------------------------------------------------------------------- main

const opts = parseCommonArgs(process.argv.slice(2));
if (restHas(opts.rest, "--worker")) {
  await worker(opts);
} else {
  await orchestrate(opts);
}
