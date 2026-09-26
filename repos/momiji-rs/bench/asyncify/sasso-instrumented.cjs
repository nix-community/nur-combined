// Instrumented `sasso` wrapper for bundlers (sass-loader `api: "modern"`):
// logs which API the loader calls, wall time per compile, time spent inside
// the injected importers (webpack enhanced-resolve) vs inside the wasm engine,
// and `firstCallMs` — ms from compile start to the FIRST importer callback.
//
// What this serves (docs/HANDOFF_ASYNC_IMPORTER_PERF.md):
//   - E3: per-compile attribution inside a real bundler (importerMs/engineMs).
//   - E4 / F1 acceptance: compiles queued behind the loader's `asyncLock`
//     (wasm/npm/_loader.mjs:467) used to show up as the indirect signature
//     "engineMs >> 100 ms with calls: {}". `firstCallMs` makes the queue wait
//     explicit — a compile that spends a long time before its first importer
//     callback (or never makes one: firstCallMs null) with a large total is
//     waiting for the lock, not compiling. After F1 lands, a cold concurrent
//     bundler build must show no such rows. (Caveat: a loadPaths-only compile
//     with no injected importers is legitimately firstCallMs: null.)
//
// CJS on purpose: sass-loader's `implementation:` option takes a require()able
// path, and this file loads the ESM sasso.mjs through Node's require(esm)
// support (stable since Node 22.12 — Node >= 22 required).
//
// Config (env):
//   SASSO_IMPL  path to the sasso.mjs entry to instrument
//               (default: ../../wasm/npm/sasso.mjs relative to this file)
//   SASSO_LOG   JSONL output path (default: <os.tmpdir()>/sasso-timings.jsonl)
//
// Wiring (from the manekineko rails worktree — see the handoff's quickstart):
//   SASSO=1 SASSO_INSTRUMENT=<abs path to this file> \
//   SASSO_LOG=/tmp/sasso-timings.jsonl bin/shakapacker --watch
//
// JSONL record shape (one object per compile; tooling parses it, keep stable):
//   {"api", "total", "importerMs", "engineMs", "firstCallMs",
//    "calls": {"canonicalize": n, "load": n, ...},
//    "src" (source chars, string APIs) | "file" (path APIs), "ts"}
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const sasso = require(
  process.env.SASSO_IMPL || path.join(__dirname, '..', '..', 'wasm', 'npm', 'sasso.mjs'),
);

const LOG = process.env.SASSO_LOG || path.join(os.tmpdir(), 'sasso-timings.jsonl');
const log = (o) => fs.appendFileSync(LOG, JSON.stringify(o) + '\n');

function wrapImporters(list, stats) {
  if (!Array.isArray(list)) return list;
  return list.map((imp) => {
    const w = {};
    for (const key of ['canonicalize', 'load', 'findFileUrl']) {
      if (typeof imp[key] !== 'function') continue;
      w[key] = function (...args) {
        const t0 = performance.now();
        if (stats.firstCallMs === null) stats.firstCallMs = t0 - stats.t0;
        const done = () => {
          stats.importerMs += performance.now() - t0;
          stats.calls[key] = (stats.calls[key] || 0) + 1;
        };
        const r = imp[key].apply(imp, args);
        if (r && typeof r.then === 'function') return r.finally(done);
        done();
        return r;
      };
    }
    // preserve non-function props (e.g. nonCanonicalScheme)
    for (const k of Object.keys(imp)) if (!(k in w)) w[k] = imp[k];
    return w;
  });
}

// `kind` distinguishes the first argument: 'string' APIs log the source size
// as `src`; 'path' APIs (compile/compileAsync) log the file path as `file` —
// a path's character count is not a source size.
function record(api, kind, source, stats) {
  const total = performance.now() - stats.t0;
  log({
    api, total: +total.toFixed(1), importerMs: +stats.importerMs.toFixed(1),
    engineMs: +(total - stats.importerMs).toFixed(1),
    firstCallMs: stats.firstCallMs === null ? null : +stats.firstCallMs.toFixed(1),
    calls: stats.calls,
    ...(kind === 'path' ? { file: String(source) } : { src: typeof source === 'string' ? source.length : null }),
    ts: Date.now(),
  });
}

function instrument(api, fn, kind = 'string') {
  return async function (source, options = {}) {
    const stats = { importerMs: 0, calls: {}, firstCallMs: null, t0: 0 };
    const opts = { ...options, importers: wrapImporters(options.importers, stats) };
    stats.t0 = performance.now();
    try {
      return await fn(source, opts);
    } finally {
      record(api, kind, source, stats);
    }
  };
}

// The sync APIs must stay synchronous (sass-loader's modern sync path calls
// them for their return value) — same record shape, no await.
function instrumentSync(api, fn, kind = 'string') {
  return function (source, options = {}) {
    const stats = { importerMs: 0, calls: {}, firstCallMs: null, t0: 0 };
    const opts = { ...options, importers: wrapImporters(options.importers, stats) };
    stats.t0 = performance.now();
    try {
      return fn(source, opts);
    } finally {
      record(api, kind, source, stats);
    }
  };
}

module.exports = {
  ...sasso,
  info: sasso.info,
  compileString: instrumentSync('compileString', sasso.compileString),
  compile: instrumentSync('compile', sasso.compile, 'path'),
  compileStringAsync: instrument('compileStringAsync', sasso.compileStringAsync),
  compileAsync: instrument('compileAsync', sasso.compileAsync, 'path'),
  initCompiler: () => {
    log({ api: 'initCompiler' });
    const c = sasso.initCompiler();
    return {
      compileString: instrumentSync('compiler.compileString', c.compileString.bind(c)),
      compile: instrumentSync('compiler.compile', c.compile.bind(c), 'path'),
      dispose: () => { log({ api: 'compiler.dispose' }); return c.dispose(); },
    };
  },
  initAsyncCompiler: async () => {
    log({ api: 'initAsyncCompiler' });
    const c = await sasso.initAsyncCompiler();
    return {
      compileStringAsync: instrument('compiler.compileStringAsync', c.compileStringAsync.bind(c)),
      compileAsync: instrument('compiler.compileAsync', c.compileAsync.bind(c), 'path'),
      dispose: () => { log({ api: 'compiler.dispose' }); return c.dispose(); },
    };
  },
};
