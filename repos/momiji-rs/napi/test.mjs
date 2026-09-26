// Test suite for the sasso-napi native addon (F4). Two pillars:
//
//   1. OUTPUT CORRECTNESS BY CONSTRUCTION: the wasm engine's output is
//      byte-exact against dart-sass (the sass-spec ratchet + parity CI jobs),
//      so the native engine is verified by BYTE-PARITY AGAINST THE WASM
//      ENGINE over the real corpora (modular incl. loadPaths + all 10
//      entries, handwritten, generated/large), expanded and compressed, sync
//      and async, plus sourceMap and loadedUrls equivalence.
//
//   2. BEHAVIOR GUARDS mirroring wasm/test.mjs's async-path guards: importer
//      bridging (sync/async/FileImporter/mixed chains), error mapping
//      (Exception shape, sync-throwing importers, mixed outcomes under
//      concurrency), logger routing, custom functions over the byte
//      protocol, concurrent isolation (thread-per-compile), and true
//      overlap (a compile completes while another is suspended).
//
// Run: bash napi/build.sh && node napi/test.mjs   (wasm/npm must be built too)
import assert from "node:assert/strict";
import { writeFileSync, readFileSync, mkdtempSync, mkdirSync, realpathSync, rmSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";

import * as napi from "./npm/index.mjs";
import * as wasm from "../wasm/npm/sasso.mjs";

const delay = (ms) => new Promise((r) => setTimeout(r, ms));
const REPO = fileURLToPath(new URL("..", import.meta.url));

// ============================ 1. wasm byte-parity ============================

const MODULAR = join(REPO, "bench", "corpus", "modular");
const VENDOR = join(MODULAR, "vendor");

async function parityCase(label, run) {
  const [n, w] = await Promise.all([run(napi), run(wasm)]);
  assert.equal(n.css, w.css, `${label}: native CSS is byte-identical to the wasm engine`);
  assert.deepEqual(
    n.loadedUrls.map((u) => u.href),
    w.loadedUrls.map((u) => u.href),
    `${label}: loadedUrls identical (same URLs, same order)`,
  );
  if (n.sourceMap || w.sourceMap) {
    assert.deepEqual(n.sourceMap.sources, w.sourceMap.sources, `${label}: sourceMap sources identical`);
    assert.equal(n.sourceMap.mappings, w.sourceMap.mappings, `${label}: sourceMap mappings identical`);
    assert.deepEqual(n.sourceMap.sourcesContent, w.sourceMap.sourcesContent, `${label}: sourcesContent identical`);
    assert.deepEqual(n.sourceMap.names, w.sourceMap.names, `${label}: sourceMap names identical`);
  }
  return n;
}

// All ten modular-corpus entries, async, expanded (the realistic bundler shape).
for (const i of ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10"]) {
  const entry = join(MODULAR, `entry_${i}.scss`);
  const r = await parityCase(`modular entry_${i} (async)`, (eng) =>
    eng.compileAsync(entry, { loadPaths: [VENDOR], style: "expanded" }),
  );
  assert.ok(r.css.includes(".sasso-corpus-sanity"), `entry_${i}: sanity marker present`);
  assert.ok(r.loadedUrls.length >= 20, `entry_${i}: loaded a real module graph (${r.loadedUrls.length} files)`);
}
// Entry 01 again: sync, compressed, and with a source map.
await parityCase("modular entry_01 (sync)", (eng) => eng.compile(join(MODULAR, "entry_01.scss"), { loadPaths: [VENDOR] }));
await parityCase("modular entry_01 (compressed)", (eng) =>
  eng.compileAsync(join(MODULAR, "entry_01.scss"), { loadPaths: [VENDOR], style: "compressed" }),
);
await parityCase("modular entry_01 (sourceMap)", (eng) =>
  eng.compileAsync(join(MODULAR, "entry_01.scss"), { loadPaths: [VENDOR], sourceMap: true, sourceMapIncludeSources: true }),
);
// The other in-repo corpora, compileString round (url + loadPaths chain).
for (const [label, path, loadPaths] of [
  ["handwritten", join(REPO, "bench", "corpus", "handwritten", "main.scss"), [join(REPO, "bench", "corpus", "handwritten")]],
  ["generated/large", join(REPO, "bench", "corpus", "generated", "large.scss"), []],
]) {
  const src = (await import("node:fs")).readFileSync(path, "utf8");
  await parityCase(`${label} (compileString async)`, (eng) =>
    eng.compileStringAsync(src, { url: pathToFileURL(path), loadPaths, style: "expanded" }),
  );
  await parityCase(`${label} (compileString compressed sync)`, (eng) =>
    Promise.resolve(eng.compileString(src, { url: pathToFileURL(path), loadPaths, style: "compressed" })),
  );
}
// Indented syntax, plain CSS via @use, and the charset/BOM non-ASCII paths.
await parityCase("indented syntax", (eng) =>
  eng.compileStringAsync(".a\n  b: c\n  .n\n    d: e\n", { syntax: "indented" }),
);
{
  const cssDir = realpathSync(mkdtempSync(join(tmpdir(), "sasso-cssuse-")));
  writeFileSync(join(cssDir, "plain.css"), ".raw { keep: me }\n");
  await parityCase("plain CSS via @use", (eng) =>
    eng.compileStringAsync('@use "plain";\n.x { y: 1 }\n', { loadPaths: [cssDir] }),
  );
}
for (const style of ["expanded", "compressed"]) {
  const r = await parityCase(`charset non-ASCII (${style})`, (eng) =>
    eng.compileStringAsync('.uni::before { content: "こんにちは"; }', { style }),
  );
  if (style === "expanded") assert.ok(r.css.startsWith('@charset "UTF-8";'), "expanded @charset prefix present");
  else assert.ok(r.css.startsWith("﻿"), "compressed BOM preserved");
}
// Error parity: the same broken inputs produce the same Exception on both
// engines (the napi error transport is a separate hand-rolled path).
{
  const errOf = (eng, fn) => {
    try {
      fn(eng);
      return null;
    } catch (e) {
      return { message: e.message, sassMessage: e.sassMessage, span: e.span };
    }
  };
  for (const [label, fn] of [
    ["parse error", (eng) => eng.compileString("a { b: ", { url: "file:///x/in.scss" })],
    ["undefined variable", (eng) => eng.compileString(".a { c: $nope; }", { url: "file:///x/vars.scss" })],
    ["missing import", (eng) => eng.compileString('@use "ghost";', { url: "file:///x/imp.scss" })],
  ]) {
    assert.deepEqual(errOf(napi, fn), errOf(wasm, fn), `error parity: ${label}`);
  }
}
console.log("ok: wasm byte-parity — corpora + indented/css/charset + error parity");

// =========================== 2. behavior guards =============================

// --- fixtures on disk (shared) ---
// realpath: tmpdir is often a symlink (/var -> /private/var on macOS) and the
// wrapper realpaths entries, so expectations must use the resolved form.
const root = realpathSync(mkdtempSync(join(tmpdir(), "sasso-napi-")));
mkdirSync(join(root, "sub"), { recursive: true });
writeFileSync(join(root, "_dep.scss"), "$w: 42px;\n");
writeFileSync(join(root, "sub", "_inner.scss"), '@use "../dep" as d;\n.inner { width: d.$w; }\n');
writeFileSync(join(root, "entry.scss"), '@use "sub/inner";\n.top { t: 1; }\n');
writeFileSync(join(root, "fi.scss"), "$s: 10px;\n");

// (a) entry-relative + nested-relative native fs resolution, sync === async.
{
  const rs = napi.compile(join(root, "entry.scss"));
  const ra = await napi.compileAsync(join(root, "entry.scss"));
  assert.equal(rs.css, ra.css, "compile(path): sync equals async");
  assert.ok(rs.css.includes("width: 42px"), "nested relative @use resolved natively");
  assert.equal(rs.loadedUrls[0].href, pathToFileURL(join(root, "entry.scss")).href, "entry first in loadedUrls");
  assert.ok(rs.loadedUrls.every((u) => u.protocol === "file:"), "fs loadedUrls are file: URLs");
}

// (b) user importer precedence over fs + containing URL delivery.
{
  const seen = [];
  const imp = {
    canonicalize(url, ctx) {
      seen.push([url, ctx.containingUrl ? ctx.containingUrl.protocol : null]);
      return url === "virtual" ? new URL("custom:v") : null;
    },
    load: (u) => (u.href === "custom:v" ? { contents: ".v { ok: 1 }", syntax: "scss" } : null),
  };
  const r = await napi.compileAsync(join(root, "entry.scss"), { importers: [imp] });
  assert.ok(r.css.includes(".top"), "compile succeeds with a missing-everything importer in front");
  assert.ok(seen.some(([u]) => u === "sub/inner"), "user importer consulted BEFORE native fs");
  assert.ok(seen.every(([, p]) => p === null || p === "file:"), "containing urls arrive as file: URLs");
  const r2 = await napi.compileStringAsync('@use "virtual";', { importers: [imp] });
  assert.ok(r2.css.includes(".v"), "user importer hit resolves");
  assert.deepEqual(r2.loadedUrls.map((u) => u.href), ["custom:v"], "user canonical in loadedUrls");
}

// (c) FileImporter (findFileUrl) sync + async.
{
  const fi = { findFileUrl: (url) => (url === "shared" ? pathToFileURL(join(root, "fi")) : null) };
  const src = '@use "shared" as s;\n.a { height: s.$s; }\n';
  const rs = napi.compileString(src, { importers: [fi] });
  const ra = await napi.compileStringAsync(src, {
    importers: [{ findFileUrl: async (url) => (url === "shared" ? pathToFileURL(join(root, "fi")) : null) }],
  });
  assert.equal(rs.css, ra.css, "FileImporter: sync equals async");
  assert.ok(rs.css.includes("height: 10px"), "FileImporter resolved on disk");
}

// (d) mixed chains: async-miss -> sync-hit and sync-miss -> async-hit.
{
  const asyncMiss = { canonicalize: async () => null, load: async () => null };
  const syncHit = { canonicalize: (u) => (u === "mx" ? new URL("custom:mx1") : null), load: () => ({ contents: ".mx { from: sync }", syntax: "scss" }) };
  const syncMiss = { canonicalize: () => null, load: () => null };
  const asyncHit = { canonicalize: async (u) => (u === "mx" ? new URL("custom:mx2") : null), load: async () => ({ contents: ".mx { from: async }", syntax: "scss" }) };
  const m1 = await napi.compileStringAsync('@use "mx";', { importers: [asyncMiss, syncHit] });
  const m2 = await napi.compileStringAsync('@use "mx";', { importers: [syncMiss, asyncHit] });
  assert.ok(m1.css.includes("from: sync") && m2.css.includes("from: async"), "mixed chains walk correctly");
}

// (e) errors: Exception shape, sync API rejects Promise importers, sync throws.
{
  assert.throws(
    () => napi.compileString("a { b: ", { url: "file:///x/in.scss" }),
    (e) => e instanceof napi.Exception && typeof e.sassMessage === "string" && e.span && e.span.start.line >= 0,
    "parse error throws an Exception with sassMessage + span",
  );
  await assert.rejects(
    () => napi.compileStringAsync('@use "q";', { importers: [{ canonicalize() { throw new Error("napi-canon-throw"); }, load: () => null }] }),
    (e) => e instanceof napi.Exception && e.message.includes("napi-canon-throw"),
    "sync-throwing canonicalize rejects with the message",
  );
  await assert.rejects(
    () => napi.compileStringAsync('@use "q";', { importers: [{ canonicalize: () => new URL("custom:q"), load: () => Promise.reject(new Error("napi-load-boom")) }] }),
    (e) => e instanceof napi.Exception && e.message.includes("napi-load-boom"),
    "rejecting load rejects with the message",
  );
  assert.throws(
    () => napi.compileString('@use "p";', { importers: [{ canonicalize: async () => new URL("custom:p"), load: () => null }] }),
    /asynchronous importers are not supported/,
    "sync API rejects Promise-returning importers (wasm parity)",
  );
}

// (f) logger: @warn/@debug routed on both APIs, deprecation flagged.
{
  for (const mode of ["sync", "async"]) {
    const logged = [];
    const logger = {
      warn: (m, o) => logged.push(["warn", m, o.deprecation]),
      debug: (m) => logged.push(["debug", m]),
    };
    const src = '@warn "nwmsg"; @debug 40 + 2; .a { b: c; }';
    const r = mode === "sync" ? napi.compileString(src, { logger }) : await napi.compileStringAsync(src, { logger });
    assert.ok(r.css.includes(".a"), `${mode} logger compile emits CSS`);
    assert.deepEqual(logged, [["warn", "nwmsg", false], ["debug", "42"]], `${mode}: @warn + @debug routed`);
  }
  // Deprecation flag parity with the wasm engine (@import is deprecated).
  const depOf = (eng) => {
    const dep = [];
    const imp = { canonicalize: (u) => (u === "legacy" ? new URL("custom:legacy") : null), load: () => ({ contents: ".l { i: 1 }", syntax: "scss" }) };
    eng.compileString('@import "legacy";', { importers: [imp], logger: { warn: (m, o) => dep.push([o.deprecation, o.deprecationType ?? null]) } });
    return dep;
  };
  assert.deepEqual(depOf(napi), depOf(wasm), "deprecation warnings (flag + type) match the wasm engine");
}

// (g) custom functions over the byte protocol (native valueOp engine).
{
  const powFns = { "pow($base, $exp)": (args) => new napi.SassNumber(args[0].value ** args[1].value) };
  const src = ".a { x: pow(2, 10); }";
  assert.equal(napi.compileString(src, { functions: powFns }).css, wasm.compileString(src, { functions: powFns }).css, "sync custom function matches wasm");
  const tag = { "tag()": async () => { await delay(1); return new napi.SassString("t-async", { quotes: false }); } };
  const ra = await napi.compileStringAsync(".b { y: tag(); }", { functions: tag });
  assert.ok(ra.css.includes("t-async"), "async custom function on the async API");
  await assert.rejects(
    () => napi.compileStringAsync(".c { z: nil(); }", { functions: { "nil()": () => null } }),
    (e) => e instanceof napi.Exception && e.message.includes("returned no value"),
    "null-returning custom function rejects",
  );
  assert.throws(
    () => napi.compileString(".d { w: later(); }", { functions: { "later()": async () => new napi.SassNumber(1) } }),
    /asynchronous custom functions require/,
    "async custom function rejected on the sync API",
  );
}

// (h) concurrent ISOLATION: 4 threads, distinct importers/loggers/functions.
{
  const isoLogs = [[], [], [], []];
  const iso = await Promise.all(
    [0, 1, 2, 3].map((i) =>
      napi.compileStringAsync(`@use "isomod";\n@warn "w${i}";\n.o-${i} { t: tag(); }\n`, {
        importers: [{
          async canonicalize(url) { await delay(1); return url === "isomod" ? new URL(`custom:iso-${i}`) : null; },
          async load(u) { await delay(1); return u.href === `custom:iso-${i}` ? { contents: `.uniq-${i} { v: ${i}; }`, syntax: "scss" } : null; },
        }],
        logger: { warn: (m) => isoLogs[i].push(m) },
        functions: { "tag()": async () => { await delay(1); return new napi.SassString(`t${i}`, { quotes: false }); } },
      }),
    ),
  );
  for (let i = 0; i < 4; i++) {
    assert.ok(iso[i].css.includes(`.uniq-${i}`) && iso[i].css.includes(`t${i}`), `concurrent #${i} got its own importer + function`);
    for (let j = 0; j < 4; j++) {
      if (j !== i) assert.ok(!iso[i].css.includes(`.uniq-${j}`) && !iso[i].css.includes(`t${j}`), `#${i} has no leakage from #${j}`);
    }
    assert.deepEqual(isoLogs[i], [`w${i}`], `logger #${i} isolated`);
    assert.deepEqual(iso[i].loadedUrls.map((u) => u.href), [`custom:iso-${i}`], `loadedUrls #${i} isolated`);
  }
}

// (i) TRUE overlap: B completes while A is suspended (thread-per-compile).
{
  let releaseGate;
  const gate = new Promise((r) => (releaseGate = r));
  const blocked = napi.compileStringAsync('@use "g";', {
    importers: [{
      canonicalize: async (u) => (u === "g" ? new URL("custom:gated") : null),
      load: async () => { await gate; return { contents: ".gated { ok: 1 }", syntax: "scss" }; },
    }],
  });
  const quick = await napi.compileStringAsync(".q { fast: 1 }");
  assert.ok(quick.css.includes(".q"), "a compile completes while another is suspended");
  releaseGate();
  assert.ok((await blocked).css.includes(".gated"), "the suspended compile completes after its gate opens");
}

// (j) mixed outcomes under concurrency: middle rejects, flanks fulfill.
{
  const ok = (tag) => ({
    canonicalize: async (u) => (u === "mix" ? new URL(`custom:mix-${tag}`) : null),
    load: async () => { await delay(2); return { contents: `.mix-${tag} { m: 1; }`, syntax: "scss" }; },
  });
  const bad = { canonicalize: async (u) => (u === "mix" ? new URL("custom:mix-bad") : null), load: () => Promise.reject(new Error("napi-mid-boom")) };
  const settled = await Promise.allSettled([
    napi.compileStringAsync('@use "mix";', { importers: [ok("a")] }),
    napi.compileStringAsync('@use "mix";', { importers: [bad] }),
    napi.compileStringAsync('@use "mix";', { importers: [ok("b")] }),
  ]);
  assert.equal(settled[0].status, "fulfilled");
  assert.ok(settled[0].value.css.includes(".mix-a"));
  assert.equal(settled[1].status, "rejected");
  assert.ok(settled[1].reason instanceof napi.Exception && settled[1].reason.message.includes("napi-mid-boom"));
  assert.equal(settled[2].status, "fulfilled");
  assert.ok(settled[2].value.css.includes(".mix-b"));
}

// (j2) MALFORMED importer results must be compile errors, never a process
// crash (async: uncaught TSFN exception) or a silent empty stylesheet (sync).
{
  const badImp = { canonicalize: (u) => (u === "bad" ? new URL("custom:bad") : null), load: () => ({ contents: 123, syntax: "scss" }) };
  await assert.rejects(
    () => napi.compileStringAsync('@use "bad";', { importers: [badImp] }),
    (e) => e instanceof napi.Exception && e.message.includes("string contents"),
    "async: non-string contents rejects with an Exception (no crash)",
  );
  assert.throws(
    () => napi.compileString('@use "bad";', { importers: [badImp] }),
    (e) => e instanceof napi.Exception && e.message.includes("string contents"),
    "sync: non-string contents throws (never an empty stylesheet)",
  );
}

// (j3) CWD must NEVER be a resolution base (hermeticity — wasm parity). A trap
// partial sits in the CWD; url-less entries and custom-scheme containers must
// fail to resolve it exactly like the wasm engine, not silently load it.
{
  const trapDir = realpathSync(mkdtempSync(join(tmpdir(), "sasso-cwdtrap-")));
  writeFileSync(join(trapDir, "_trap.scss"), ".trapped { by: cwd; }\n");
  const prevCwd = process.cwd();
  process.chdir(trapDir);
  try {
    for (const [label, run] of [
      ["url-less compileString", (eng) => eng.compileStringAsync('@use "trap";')],
      ["custom-scheme container", (eng) =>
        eng.compileStringAsync('@use "v";', {
          importers: [{
            canonicalize: (u) => (u === "v" ? new URL("custom:v") : null),
            load: (u) => (u.href === "custom:v" ? { contents: '@use "trap";\n.v { ok: 1 }', syntax: "scss" } : null),
          }],
        })],
    ]) {
      const [n, w] = await Promise.allSettled([run(napi), run(wasm)]);
      assert.equal(n.status, "rejected", `napi ${label}: CWD trap NOT resolved`);
      assert.equal(w.status, "rejected", `wasm ${label}: CWD trap NOT resolved (control)`);
    }
  } finally {
    process.chdir(prevCwd);
  }
}

// (j4) relative imports inside a user-canonicalized file: module resolve via
// the native fs against the module's own directory (wasm parity).
{
  const fiDir = realpathSync(mkdtempSync(join(tmpdir(), "sasso-firel-")));
  writeFileSync(join(fiDir, "mod.scss"), '@use "./sibling" as s;\n.mod { v: s.$k; }\n');
  writeFileSync(join(fiDir, "_sibling.scss"), "$k: 7;\n");
  const fi = { findFileUrl: (url) => (url === "mod" ? pathToFileURL(join(fiDir, "mod")) : null) };
  await parityCase("file:-container relative import", (eng) =>
    eng.compileStringAsync('@use "mod";', { importers: [fi] }),
  );
}

// (j5) the same physical file reached via a FileImporter AND via loadPaths is
// ONE module (canonical-namespace unification — wasm parity).
{
  const dupDir = realpathSync(mkdtempSync(join(tmpdir(), "sasso-dup-")));
  writeFileSync(join(dupDir, "_shared.scss"), ".sh { s: 1; }\n");
  const fi = { findFileUrl: (url) => (url === "sh" ? pathToFileURL(join(dupDir, "shared")) : null) };
  const r = await parityCase("same file via FileImporter + loadPaths", (eng) =>
    eng.compileStringAsync('@use "sh";\n@use "shared";\n', { importers: [fi], loadPaths: [dupDir] }),
  );
  assert.equal(r.css.match(/\.sh /g).length, 1, "the shared module's CSS is emitted exactly once");
}

// (k) re-entrant sync compile from inside a custom function (nested bridge).
{
  const r = napi.compileString(".outer { n: inner(); }", {
    functions: {
      "inner()": () => {
        const nested = napi.compileString(".x { y: 7 }");
        return new napi.SassNumber(nested.css.includes("y: 7") ? 1 : 0);
      },
    },
  });
  assert.ok(r.css.includes("n: 1"), "re-entrant sync compile inside a custom function");
}

// (l) Value-op engine smoke (SassNumber.convert routes through native valueOp).
{
  const n = new napi.SassNumber(1, "in").convert(["px"], []);
  assert.equal(n.value, 96, "SassNumber.convert via the native valueOp engine");
}

// (m-arena) The addon installs the bump arena as its global allocator, and the
// arena resets at the end of every compile. std heap-allocates the stdio locks
// lazily on FIRST USE: if that first use is inside a compile scope, the lock
// lands in the arena, the reset frees it, and the next print dies with
// `failed to lock mutex: Invalid argument` — taking the process with it.
//
// The library prints a diagnostic itself only when no warn handler is set.
// `native.mjs` always sets one, so the shipped client does not take this path
// today; the addon export is public and a future caller may. Driving the
// export directly is the only way to reach it, which is why this is here and
// not in wasm/test.mjs.
//
// A fresh process each time, because the hazard is about the FIRST use in the
// process — a second compile in this one would find the locks already warm.
{
  const { execFileSync } = await import("node:child_process");
  const addon = fileURLToPath(new URL("./npm/sasso.node", import.meta.url));
  // `@import` is deprecated, so compiling this emits a diagnostic; with
  // wantWarn false the library prints it from inside the compile scope.
  const dir = mkdtempSync(join(realpathSync(tmpdir()), "sasso-arena-"));
  writeFileSync(join(dir, "dep.scss"), ".d { color: red }\n");
  // A real `url`: the deprecation carries a source span, and without one the
  // library emits nothing at all — the first version of this test passed for
  // that reason rather than because the addon was sound.
  const entry = '@import "dep";\n.e { v: 1 + 1 }\n';
  const code = `
    const { createRequire } = require("node:module");
    const addon = createRequire(${JSON.stringify(import.meta.url)})(${JSON.stringify(addon)});
    const cfg = {
      compressed: false, charset: true, unicode: true, quietDeps: false, syntax: 0,
      url: ${JSON.stringify(join(dir, "entry.scss"))}, loadPaths: [${JSON.stringify(dir)}], hasUserImporters: false,
      wantWarn: false, wantMap: false, includeSources: false, functionSignatures: [],
    };
    // Several times, and that is the whole point. The first compile's
    // diagnostic ALLOCATES the stdio lock inside the arena scope; the reset
    // rewinds the cursor over it. The lock only becomes unusable once a later
    // compile's allocations overwrite that memory — measured here at the
    // third. One compile proves nothing, two proved nothing either, and a JS
    // console.log proves less still: V8's stdout is not the lock that was
    // freed. The count is deliberately past the observed threshold.
    let css = "";
    for (let i = 0; i < 6; i++) {
      css = addon.compileStringSync(${JSON.stringify(entry)}, cfg, undefined).css;
    }
    console.log(css.includes("v: 2") ? "ARENA-OK" : "BAD-CSS");
  `;
  const out = execFileSync(process.execPath, ["-e", code], { encoding: "utf8", stdio: "pipe" });
  assert.ok(
    out.includes("ARENA-OK"),
    "a diagnostic printed from inside a compile scope must not poison the stdio locks",
  );
}

// (m) binding resolution tiers of sasso/native (wasm/npm/native.mjs): the
// SASSO_NATIVE_BINARY override wins, and an unresolvable setup fails with the
// guidance error (not a bare MODULE_NOT_FOUND from some inner require).
{
  const { execFileSync } = await import("node:child_process");
  const wrapper = fileURLToPath(new URL("../wasm/npm/native.mjs", import.meta.url));
  const addon = fileURLToPath(new URL("./npm/sasso.node", import.meta.url));
  const run = (env, code) =>
    execFileSync(process.execPath, ["--input-type=module", "-e", code], {
      env: { ...process.env, ...env },
      encoding: "utf8",
    });
  const out = run(
    { SASSO_NATIVE_BINARY: addon },
    `import { compileString, info } from ${JSON.stringify(wrapper)};
     console.log(info.includes("sasso-native") && compileString(".e { v: 1 + 1 }").css.includes("v: 2") ? "OVERRIDE-OK" : "BAD");`,
  );
  assert.ok(out.includes("OVERRIDE-OK"), "SASSO_NATIVE_BINARY override tier resolves and compiles");
}

// (n) `quietDeps` behaves as it does on the wasm engine — the two entry points
// share one type declaration, so an option one of them silently ignored would
// be a promise the package does not keep. dart's rule is about how a file was
// REACHED: through a load path or a user importer it is a dependency (its
// deprecations are dropped); loaded relatively by the entry it is not, even
// from inside a load path. A dependency's own @warn still reaches the logger.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-napi-qd-"));
  mkdirSync(join(dir, "lib"), { recursive: true });
  writeFileSync(join(dir, "lib", "dep.scss"), '@warn "dep-warn";\n.d{color: lighten(#036, 10%)}\n');
  writeFileSync(join(dir, "lib", "rel.scss"), ".r{color: lighten(#036, 30%)}\n");

  const collect = (mod, source, options) => {
    const seen = [];
    mod.compileString(source, {
      url: pathToFileURL(join(dir, "entry.scss")).href,
      loadPaths: [join(dir, "lib")],
      logger: {
        warn: (m, o) => seen.push(`${o.deprecation ? "DEPRECATION" : "WARNING"} ${o.span && o.span.url}`),
      },
      ...options,
    });
    return seen;
  };

  for (const [name, mod] of [["native", napi], ["wasm", wasm]]) {
    const loud = collect(mod, '@use "dep";\n', { quietDeps: false });
    assert.ok(
      loud.some((w) => w.startsWith("DEPRECATION") && w.includes("dep.scss")),
      `quietDeps(${name}): a dependency's deprecations print by default`,
    );
    const quiet = collect(mod, '@use "dep";\n', { quietDeps: true });
    assert.ok(
      !quiet.some((w) => w.startsWith("DEPRECATION")),
      `quietDeps(${name}): a load-path dependency's deprecations are dropped`,
    );
    assert.ok(quiet.some((w) => w.startsWith("WARNING")), `quietDeps(${name}): its @warn still prints`);
    // The same file, loaded relatively by the entry: not a dependency.
    const rel = collect(mod, '@use "lib/rel";\n', { quietDeps: true });
    assert.ok(
      rel.some((w) => w.startsWith("DEPRECATION") && w.includes("rel.scss")),
      `quietDeps(${name}): a relatively-loaded file is not a dependency`,
    );
  }

  // A user importer's stylesheet counts as a dependency too (dart 1.104.1).
  const importer = {
    canonicalize: (u) => (u.startsWith("virt:") ? new URL(u) : null),
    load: () => ({ contents: ".v{color: lighten(#036, 10%)}", syntax: "scss" }),
  };
  for (const [name, mod] of [["native", napi], ["wasm", wasm]]) {
    const seen = collect(mod, '@use "virt:a" as v;\n', { quietDeps: true, importers: [importer] });
    assert.ok(!seen.some((w) => w.startsWith("DEPRECATION")), `quietDeps(${name}): an importer's stylesheet is a dependency`);
  }
}

console.log("ok: quietDeps — native and wasm agree on dart's provenance rule");

// (o) `silenceDeprecations`, native vs wasm. This is where it belongs rather
// than in wasm/test.mjs: that suite runs in the CI job that builds no addon, so
// its native leg skips there and the addon's copy of this option would be
// covered nowhere. It has already been wrong once — mid-development the native
// path accepted the option and ignored it, printing all six warnings while wasm
// printed none — and the two entry points share one type declaration, so an
// option one of them quietly drops is a promise the package does not keep.
//
// One entry raising THREE deprecations, so "silenced" can be told apart from
// "warnings stopped": every case names some ids and asserts the rest survive.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-napi-sd-"));
  writeFileSync(join(dir, "dep.scss"), ".d { color: lighten(#036, 10%) }\n");
  const entryUrl = pathToFileURL(join(dir, "entry.scss")).href;

  const IMPORT = /@import rules are deprecated/;
  const GLOBAL = /Global built-in functions are deprecated/;
  const LIGHTEN = /lighten\(\) is deprecated/;

  const collect = (mod, silenceDeprecations) => {
    const seen = [];
    mod.compileString('@import "dep";\n', {
      url: entryUrl,
      silenceDeprecations,
      logger: { warn: (m) => seen.push(m.split("\n")[0]) },
    });
    return seen.join("\n");
  };

  const byEngine = {};
  for (const [name, mod] of [["native", napi], ["wasm", wasm]]) {
    const loud = collect(mod, undefined);
    assert.match(loud, IMPORT, `silenceDeprecations(${name}): @import warns by default`);
    assert.match(loud, GLOBAL, `silenceDeprecations(${name}): global-builtin warns by default`);
    assert.match(loud, LIGHTEN, `silenceDeprecations(${name}): color-functions warns by default`);

    const one = collect(mod, ["import"]);
    assert.doesNotMatch(one, IMPORT, `silenceDeprecations(${name}): the named id is gone`);
    assert.match(one, GLOBAL, `silenceDeprecations(${name}): the others are not`);

    const two = collect(mod, ["global-builtin", "color-functions"]);
    assert.doesNotMatch(two, GLOBAL, `silenceDeprecations(${name}): two ids, first gone`);
    assert.doesNotMatch(two, LIGHTEN, `silenceDeprecations(${name}): two ids, second gone`);
    assert.match(two, IMPORT, `silenceDeprecations(${name}): two ids, the third kept`);

    // An id sasso never emits is accepted and does nothing, so a build written
    // for `sass` does not fail for naming one.
    assert.match(collect(mod, ["mixed-decls"]), IMPORT, `silenceDeprecations(${name}): an unemitted id is inert`);
    assert.equal(collect(mod, []), loud, `silenceDeprecations(${name}): an empty list changes nothing`);

    byEngine[name] = { loud, one, two };
  }

  // The engines must not merely each be self-consistent: byte-for-byte the same
  // warnings, which is what caught the native path ignoring the option.
  for (const key of ["loud", "one", "two"]) {
    assert.equal(byEngine.native[key], byEngine.wasm[key], `silenceDeprecations: the engines agree (${key})`);
  }

  // The async API is a different code path in both engines.
  for (const [name, mod] of [["native", napi], ["wasm", wasm]]) {
    const seen = [];
    await mod.compileStringAsync('@import "dep";\n', {
      url: entryUrl,
      silenceDeprecations: ["import"],
      logger: { warn: (m) => seen.push(m.split("\n")[0]) },
    });
    const text = seen.join("\n");
    assert.doesNotMatch(text, IMPORT, `silenceDeprecations(async ${name}): silenced`);
    assert.match(text, GLOBAL, `silenceDeprecations(async ${name}): others kept`);
  }

  // An id dart does not know: its JS API warns and compiles, where its CLI
  // exits 64. Both measured against 1.104.1; the addon builds its config in
  // native.mjs rather than in the loader, so it needs its own proof.
  for (const [name, mod] of [["native", napi], ["wasm", wasm]]) {
    const seen = [];
    const r = mod.compileString(".a{b:c}", {
      silenceDeprecations: ["nope", "import", "nope"],
      logger: { warn: (m, o) => seen.push([m, o?.deprecation]) },
    });
    assert.deepEqual(
      seen,
      [['Invalid deprecation "nope".', false], ['Invalid deprecation "nope".', false]],
      `silenceDeprecations(${name}): one plain warning per unknown occurrence, known ids silent`,
    );
    assert.ok(r.css.includes("b: c"), `silenceDeprecations(${name}): an unknown id does not fail the compile`);

    // An unknown id containing a comma. wasm marshals this list as one
    // comma-separated string, so forwarding invalid ids let a single bad id
    // split into two good ones there while native silenced nothing. Both now
    // drop unknown ids, so the engines agree with each other and with dart.
    const smuggled = [];
    mod.compileString('@import "dep";\n', {
      url: entryUrl,
      silenceDeprecations: ["import,global-builtin"],
      logger: { warn: (m) => smuggled.push(m.split("\n")[0]) },
    });
    assert.ok(
      smuggled.includes('Invalid deprecation "import,global-builtin".'),
      `silenceDeprecations(${name}): a comma inside one id is one invalid id`,
    );
    assert.ok(
      smuggled.some((w) => IMPORT.test(w)) && smuggled.some((w) => GLOBAL.test(w)),
      `silenceDeprecations(${name}): … and it silences neither of them`,
    );

    // A logger that throws must not fail the compile, as for every other
    // diagnostic in this package.
    const survived = mod.compileString(".a{b:c}", {
      silenceDeprecations: ["nope"],
      logger: { warn: () => { throw new Error("logger exploded"); } },
    });
    assert.ok(
      survived.css.includes("b: c"),
      `silenceDeprecations(${name}): a throwing logger does not fail the compile`,
    );
  }
}
console.log("ok: silenceDeprecations — native and wasm agree, per id, sync + async");

// (p) A version-skewed addon is refused (#114).
//
// Here rather than only in wasm/test.mjs for the same reason (o) is: that
// suite runs in the CI job that builds no addon, so its copy of this skips
// there and the check would be exercised nowhere. This job has an addon.
//
// The skew matters because napi ignores config fields it does not know without
// erroring — an addon one release behind accepts every option the newer JS
// sends and applies only the ones it recognises, so the compile succeeds and
// quietly does something else.
{
  const addonBin = fileURLToPath(new URL("./npm/sasso.node", import.meta.url));
  // The loader's own naming. Spelling it `platform-arch` here is right on
  // macOS and wrong on Linux, where the prebuilds carry a libc suffix, and the
  // failure is silent: the loader never looks for that name, so it falls
  // through to the repo build and loads happily. A platform with no prebuild
  // (musl, Windows) has no name to fabricate and skips.
  const { platformKey, SUPPORTED } = await import("../wasm/npm/_addon.mjs");
  const pkgName = SUPPORTED[platformKey()];
  if (!pkgName) {
    console.log(`  (addon pairing: skipping — no prebuild for ${platformKey()})`);
  } else {
  const nodePath = mkdtempSync(join(tmpdir(), "sasso-napi-skew-"));
  const pkgDir = join(nodePath, pkgName);
  mkdirSync(pkgDir, { recursive: true });
  writeFileSync(join(pkgDir, "sasso.node"), readFileSync(addonBin));
  const manifest = (version) =>
    writeFileSync(
      join(pkgDir, "package.json"),
      JSON.stringify({ name: pkgName, version, main: "sasso.node" }),
    );

  // A fabricated platform package on NODE_PATH is what the loader really
  // resolves, so this exercises the wiring rather than the rule in isolation.
  const nativeUrl = new URL("../wasm/npm/native.mjs", import.meta.url).href;
  const load = () =>
    spawnSync(
      process.execPath,
      [
        "--input-type=module",
        "-e",
        `import(${JSON.stringify(nativeUrl)}).then(() => console.log("LOADED"), (e) => console.log(e.code))`,
      ],
      { encoding: "utf8", env: { ...process.env, NODE_PATH: nodePath } },
    ).stdout.trim();

  manifest("9.9.9");
  assert.equal(load(), "SASSO_ADDON_VERSION_MISMATCH", "addon skew: a mismatched addon is refused");

  // The matching case, so the assertion above cannot pass against a loader
  // that simply refuses every addon.
  const ours = JSON.parse(
    readFileSync(new URL("../wasm/npm/package.json", import.meta.url), "utf8"),
  ).version;
  manifest(ours);
  assert.equal(load(), "LOADED", "addon skew: a matching addon is accepted");

  rmSync(nodePath, { recursive: true, force: true });
  }
}
console.log("ok: addon pairing — a skewed addon is refused where an addon exists");

// (o) `unicode: false` — the CLI's `--no-unicode` — selects the ASCII glyph set
// for rendered diagnostics, on both engines. Same reason as quietDeps: one
// shared type declaration, so neither engine may quietly ignore it.
{
  const render = (mod, unicode) => {
    let out = "";
    try {
      mod.compileString(".d{color: lighten(#036, 10%)}", {
        url: "file:///x.scss",
        unicode,
        logger: { warn: (m) => (out += m) },
      });
    } catch (e) {
      out += e.message;
    }
    return out;
  };
  for (const [name, mod] of [["native", napi], ["wasm", wasm]]) {
    // A rendered error carries the gutter whether or not a warning does.
    const fail = (unicode) => {
      try {
        mod.compileString(".a{b: }", { url: "file:///x.scss", unicode });
        return "";
      } catch (e) {
        return e.message;
      }
    };
    assert.match(fail(true), /╷/, `unicode(${name}): the Unicode gutter by default`);
    assert.ok(!/[╷│╵]/.test(fail(false)), `unicode(${name}): --no-unicode renders ASCII`);
    assert.match(fail(false), /^\s*,$/m, `unicode(${name}): … opening with a comma, as dart does`);
    render(mod, true); // exercises the warning path with the same option
  }
}

console.log("ok: unicode — native and wasm render the same ASCII/Unicode gutters");

console.log("ok: behavior guards — importers, errors, logger, functions, isolation, overlap, re-entrancy, valueOp");
console.log("all sasso-napi native-addon tests passed");
