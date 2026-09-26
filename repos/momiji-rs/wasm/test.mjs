// Smoke test for the wasm package's dart-sass *modern* API, against BOTH the
// size (`./npm/sasso.mjs`) and speed (`./npm/sasso.speed.mjs`) builds. Covers
// the Phase-1 surface (compileString / compile(path) / async / source maps /
// loadedUrls / info / Exception) and the Phase-2 importer surface (loadPaths,
// relative imports, partial/index/import-only resolution, user Importer +
// FileImporter, loadedUrls, importer errors, async rejection), plus the
// async-path correctness guards (sync importers/throws on the async API,
// async loggers, concurrent isolation, mixed outcomes) that the F1/F3
// asyncify refactors must preserve (docs/HANDOFF_ASYNC_IMPORTER_PERF.md).
// Run after build.sh: `node wasm/test.mjs`.
import assert from "node:assert/strict";
import { writeFileSync, mkdtempSync, mkdirSync, readFileSync, readdirSync, copyFileSync, existsSync, statSync, lstatSync, symlinkSync, renameSync, rmSync, openSync, closeSync, chmodSync, realpathSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, delimiter } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";
import { execFileSync, spawn, spawnSync } from "node:child_process";
import * as size from "./npm/sasso.mjs";
import * as speed from "./npm/sasso.speed.mjs";

// Every CLI case below is about what `cli.mjs` ITSELF does, so delegation to a
// release binary is off for all of them and switched back on only by the cases
// that are about delegation. Without this, a machine with a version-matched
// `sasso` on PATH — a `brew install`, a `cargo install`, this repo's own
// `target/release` — would have `cli.mjs` hand the whole command line to the
// binary, and every assertion here would pass while testing the other program.
// The flag-parity guard is the one that matters most: it exists because the two
// CLIs drifted apart (#24), and it cannot notice that by interrogating one of
// them twice. Children inherit this; `engineEnv` below deliberately does not
// strip it.
process.env.SASSO_BINARY = "0";

const SCSS = ".a {\n  color: red;\n  .b { width: 10px; }\n}\n";

// --- shared filesystem fixtures (created once, used by both builds) ---
const root = mkdtempSync(join(tmpdir(), "sasso-imp-"));
const write = (rel, body) => {
  const p = join(root, rel);
  mkdirSync(join(p, ".."), { recursive: true });
  writeFileSync(p, body);
  return p;
};
// relative @use + partial
const mainRel = write("proj/main.scss", `@use "vars" as v;\n.a { color: v.$c; }\n`);
write("proj/_vars.scss", `$c: blue;\n`);
// loadPaths target (in a sibling dir, not next to main)
write("inc/_lib.scss", `$w: 7px;\n`);
// @import partial + index dir
const impMain = write("imp/main.scss", `@import "base";\n@import "theme";\n`);
write("imp/_base.scss", `.b { x: 1; }\n`);
write("imp/theme/_index.scss", `.t { y: 2; }\n`);
// FileImporter target partial
write("fi/_shared.scss", `$s: 10px;\n`);
// FileImporter target whose bytes are not UTF-8
write("fi/badutf8.scss", Buffer.from("$c: \xff\xfered;\n", "binary"));

for (const [name, mod] of [["size", size], ["speed", speed]]) {
  // === Phase 1: core modern API ===

  const r = mod.compileString(SCSS);
  assert.equal(typeof r.css, "string", `${name}: compileString.css is a string`);
  assert.ok(r.css.includes(".a .b {"), `${name}: nested selector flattened`);
  assert.deepEqual(r.loadedUrls, [], `${name}: no loadedUrls without url`);
  assert.ok(!("sourceMap" in r), `${name}: no sourceMap unless asked`);

  const ru = mod.compileString(SCSS, { url: "file:///x.scss" });
  assert.ok(ru.loadedUrls[0] instanceof URL, `${name}: loadedUrls are URLs`);
  assert.equal(ru.loadedUrls[0].href, "file:///x.scss", `${name}: url -> loadedUrls`);

  const rm = mod.compileString(SCSS, { sourceMap: true });
  assert.equal(rm.css, r.css, `${name}: .css matches the plain result`);
  assert.equal(rm.sourceMap.version, 3, `${name}: map version 3`);
  assert.deepEqual(rm.sourceMap.names, [], `${name}: names empty`);
  assert.equal(rm.sourceMap.mappings, "AAAA;EACE;;AACA;EAAK", `${name}: mappings byte-exact vs dart`);
  assert.ok(!("sourcesContent" in rm.sourceMap), `${name}: no sourcesContent unless asked`);

  const rs = mod.compileString(".a { color: red; }\n", { sourceMap: true, sourceMapIncludeSources: true });
  assert.equal(rs.sourceMap.sourcesContent.length, rs.sourceMap.sources.length, `${name}: sourcesContent parallel`);

  const rc = mod.compileString(SCSS, { sourceMap: true, style: "compressed" });
  assert.ok(rc.css.length > 0 && rc.sourceMap.mappings.length > 0, `${name}: compressed map`);

  const ra = await mod.compileStringAsync(SCSS);
  assert.equal(ra.css, r.css, `${name}: compileStringAsync matches sync`);

  let threw;
  try { mod.compileString(".a { color: ; }"); } catch (e) { threw = e; }
  assert.ok(threw instanceof Error, `${name}: error is an Error`);
  assert.ok(threw instanceof mod.Exception, `${name}: error is the exported Exception`);
  assert.equal(threw.name, "Exception", `${name}: error name is Exception`);
  assert.ok(threw.sassMessage && !threw.sassMessage.startsWith("Error:"), `${name}: sassMessage has no Error: prefix`);
  await assert.rejects(() => mod.compileStringAsync(".a { color: ; }"), `${name}: async rejects`);

  // === Phase 1: Compiler API (Vite/sass-loader) ===
  const sync = mod.initCompiler();
  assert.equal(sync.compileString(SCSS).css, r.css, `${name}: initCompiler().compileString`);
  sync.dispose();
  const acomp = await mod.initAsyncCompiler();
  const ac = await acomp.compileStringAsync(SCSS, { url: "file:///x.scss", sourceMap: true });
  assert.equal(ac.css, r.css, `${name}: initAsyncCompiler().compileStringAsync`);
  assert.equal(ac.loadedUrls[0].protocol, "file:", `${name}: compiler loadedUrls are file: URLs`);
  await acomp.dispose();

  assert.ok(mod.info.startsWith("dart-sass\t"), `${name}: info passes the sass-loader name gate`);
  assert.ok(mod.info.includes("sasso"), `${name}: info discloses the real engine`);

  // === Phase 2: importers / loadPaths ===

  // compile(path): relative @use resolves the partial from the entry's dir
  const rp = mod.compile(mainRel);
  assert.ok(rp.css.includes("color: blue"), `${name}: compile(path) relative @use partial`);
  const rpHrefs = rp.loadedUrls.map((u) => u.href);
  // Compare by basename — tmpdir is often a symlink (/var -> /private/var) and
  // canonical URLs are realpath'd, so absolute prefixes differ across macOS.
  assert.ok(rpHrefs.every((h) => h.startsWith("file://")), `${name}: loadedUrls are file: URLs`);
  assert.ok(rpHrefs.some((h) => h.endsWith("/main.scss")), `${name}: loadedUrls includes entry`);
  assert.ok(rpHrefs.some((h) => h.endsWith("/_vars.scss")), `${name}: loadedUrls includes the partial`);

  // compileString with url: same relative resolution against the given url
  const rpS = mod.compileString(`@use "vars" as v;\n.a { color: v.$c; }\n`, { url: pathToFileURL(mainRel) });
  assert.ok(rpS.css.includes("color: blue"), `${name}: compileString({url}) relative @use`);

  // loadPaths: a partial found only via a configured load path
  const rl = mod.compileString(`@use "lib" as l;\n.a { width: l.$w; }\n`, {
    url: pathToFileURL(mainRel),
    loadPaths: [join(root, "inc")],
  });
  assert.ok(rl.css.includes("width: 7px"), `${name}: loadPaths resolves the partial`);

  // @import partial + index directory
  const ri = mod.compile(impMain);
  assert.ok(ri.css.includes(".b") && ri.css.includes(".t"), `${name}: @import partial + index dir`);

  // user Importer (custom scheme, in-memory contents)
  const customImporter = {
    canonicalize(url) { return url === "foo" ? new URL("custom:foo") : null; },
    load(u) { return u.href === "custom:foo" ? { contents: "$c: green;", syntax: "scss" } : null; },
  };
  const rui = mod.compileString(`@use "foo" as f;\n.a { color: f.$c; }\n`, { importers: [customImporter] });
  assert.ok(rui.css.includes("color: green"), `${name}: user Importer canonicalize/load`);
  assert.ok(rui.loadedUrls.some((u) => u.href === "custom:foo"), `${name}: loadedUrls includes the custom canonical`);

  // user FileImporter (findFileUrl -> on-disk partial resolution)
  const fileImporter = {
    findFileUrl(url) { return url === "shared" ? pathToFileURL(join(root, "fi", "shared")) : null; },
  };
  const rfi = mod.compileString(`@use "shared" as s;\n.a { height: s.$s; }\n`, { importers: [fileImporter] });
  assert.ok(rfi.css.includes("height: 10px"), `${name}: user FileImporter findFileUrl`);

  // Invalid UTF-8 behind a file: URL is a read error, not a missing import.
  const badUtf8File = {
    findFileUrl(url) {
      return url === "badutf8" ? pathToFileURL(join(root, "fi", "badutf8.scss")) : null;
    },
  };
  assert.throws(
    () => mod.compileString(`@use "badutf8";`, { importers: [badUtf8File] }),
    /stream did not contain valid UTF-8/,
    `${name}: FileImporter invalid UTF-8 is a read error`,
  );

  // importer load error -> reported compile error
  const boom = { canonicalize: () => new URL("custom:boom"), load() { throw new Error("kaboom-load"); } };
  assert.throws(() => mod.compileString(`@use "boom";`, { importers: [boom] }), /kaboom-load/, `${name}: importer load error surfaces`);

  // async importer -> clear, synchronous failure
  const asyncImp = { canonicalize: () => Promise.resolve(new URL("custom:x")), load: () => null };
  assert.throws(() => mod.compileString(`@use "x";`, { importers: [asyncImp] }), /asynchronous importers are not supported/, `${name}: async importer rejected`);

  // unresolved import -> Exception (no importer handles it)
  assert.throws(() => mod.compileString(`@use "definitely-missing";`, { url: pathToFileURL(mainRel) }), mod.Exception, `${name}: unresolved import throws`);

  // imports also work through the async + Compiler API paths
  const rasync = await mod.compileAsync(mainRel);
  assert.ok(rasync.css.includes("color: blue"), `${name}: compileAsync resolves imports`);

  // === Phase 2.5: ASYNC importers (asyncify suspends the engine across await) ===

  const delay = (ms) => new Promise((r) => setTimeout(r, ms));
  const asyncImporter = {
    async canonicalize(url) { await delay(2); return url === "remote" ? new URL("custom:remote") : null; },
    async load(u) { await delay(2); return u.href === "custom:remote" ? { contents: "$c: rebeccapurple;", syntax: "scss" } : null; },
  };

  // compileStringAsync awaits an async importer that the sync API rejects.
  const ar = await mod.compileStringAsync(`@use "remote" as r;\n.a { color: r.$c; }\n`, { importers: [asyncImporter] });
  assert.ok(ar.css.includes("rebeccapurple"), `${name}: async importer suspends/resumes the engine`);
  assert.ok(ar.loadedUrls.some((u) => u.href === "custom:remote"), `${name}: async importer loadedUrls`);
  // the SYNC API still rejects the very same async importer
  assert.throws(() => mod.compileString(`@use "remote";`, { importers: [asyncImporter] }), /asynchronous importers are not supported/, `${name}: sync API rejects async importer`);

  // Compiler API async path (this is exactly how Vite drives it)
  const acompiler = await mod.initAsyncCompiler();
  const cr = await acompiler.compileStringAsync(`@use "remote" as r;\n.b { color: r.$c; }\n`, { importers: [asyncImporter] });
  assert.ok(cr.css.includes("rebeccapurple"), `${name}: Compiler API async importer (Vite path)`);
  await acompiler.dispose();

  // async FileImporter (async findFileUrl -> on-disk resolution)
  const asyncFile = {
    async findFileUrl(url) { await delay(2); return url === "shared" ? pathToFileURL(join(root, "fi", "shared")) : null; },
  };
  const af = await mod.compileStringAsync(`@use "shared" as s;\n.a { height: s.$s; }\n`, { importers: [asyncFile] });
  assert.ok(af.css.includes("height: 10px"), `${name}: async FileImporter`);

  // the async path also resolves plain sync fs imports (loadPaths/relative)
  const amix = await mod.compileStringAsync(`@use "vars" as v;\n.a { color: v.$c; }\n`, { url: pathToFileURL(mainRel) });
  assert.ok(amix.css.includes("color: blue"), `${name}: async path resolves sync fs imports`);

  // concurrent async compiles must serialize on the single asyncify stack
  const [c1, c2] = await Promise.all([
    mod.compileStringAsync(`@use "remote" as r;\n.x { color: r.$c; }\n`, { importers: [asyncImporter] }),
    mod.compileStringAsync(`@use "remote" as r;\n.y { color: r.$c; }\n`, { importers: [asyncImporter] }),
  ]);
  assert.ok(c1.css.includes(".x") && c1.css.includes("rebeccapurple"), `${name}: concurrent async compile #1`);
  assert.ok(c2.css.includes(".y") && c2.css.includes("rebeccapurple"), `${name}: concurrent async compile #2`);

  // async importer error -> rejected promise carrying the message
  const asyncBoom = { canonicalize: async () => new URL("custom:boom2"), load: async () => { throw new Error("async-kaboom"); } };
  await assert.rejects(() => mod.compileStringAsync(`@use "boom2";`, { importers: [asyncBoom] }), /async-kaboom/, `${name}: async importer error rejects`);

  // after an error the asyncify stack is clean — a subsequent async compile works
  const recover = await mod.compileStringAsync(`@use "remote" as r;\n.z { color: r.$c; }\n`, { importers: [asyncImporter] });
  assert.ok(recover.css.includes("rebeccapurple"), `${name}: async engine recovers after an importer error`);

  // --- Async-path correctness guards for the asyncify refactors ---
  // Pins the behavior that F1 (asyncLock -> instance pool) and F3 (sync
  // fast-path in asyncHostFn) must preserve — see
  // docs/HANDOFF_ASYNC_IMPORTER_PERF.md. Today the lock serializes all async
  // compiles so isolation holds trivially; once a pool lands these become the
  // real regression guards.

  // (a) F3: a sync-RETURNING importer on the ASYNC API (plain values, no
  // Promises) must produce exactly the sync API's output — this is the path
  // the sync fast-path rewrites.
  const syncRetImporter = {
    canonicalize(url) { return url === "syncret" ? new URL("custom:syncret") : null; },
    load(u) { return u.href === "custom:syncret" ? { contents: "$c: teal;", syntax: "scss" } : null; },
  };
  const syncRetSrc = `@use "syncret" as s;\n.a { color: s.$c; }\n`;
  const aRet = await mod.compileStringAsync(syncRetSrc, { importers: [syncRetImporter] });
  assert.ok(aRet.css.includes("teal"), `${name}: sync-returning importer works on the async API`);
  assert.equal(aRet.css, mod.compileString(syncRetSrc, { importers: [syncRetImporter] }).css, `${name}: async CSS with a sync importer equals the sync API's CSS`);

  // (b) F3: a SYNC throw in canonicalize/load on the async API must reject
  // with an Exception carrying the thrown text (today the throw is absorbed
  // into pendingDelivery; the fast-path's synchronous branch must keep the
  // rc=-1 delivery identical).
  const syncThrowCanon = { canonicalize() { throw new Error("sync-canon-throw"); }, load: () => null };
  await assert.rejects(
    () => mod.compileStringAsync(`@use "q";`, { importers: [syncThrowCanon] }),
    (e) => e instanceof mod.Exception && e.message.includes("sync-canon-throw"),
    `${name}: sync-throwing canonicalize rejects the async compile with the message`,
  );
  const syncThrowLoad = { canonicalize: () => new URL("custom:sthrow"), load() { throw new Error("sync-load-throw"); } };
  await assert.rejects(
    () => mod.compileStringAsync(`@use "sthrow";`, { importers: [syncThrowLoad] }),
    (e) => e instanceof mod.Exception && e.message.includes("sync-load-throw"),
    `${name}: sync-throwing load rejects the async compile with the message`,
  );

  // (b2) F3: MIXED chains — the maybe-async walk must continue past a missing
  // resolver in both directions: a thenable miss followed by a sync hit, and a
  // sync miss followed by a thenable hit.
  const asyncMiss = { canonicalize: async (url) => { await delay(1); return null; }, load: async () => null };
  const syncHit = {
    canonicalize: (url) => (url === "mx" ? new URL("custom:mx-sync") : null),
    load: (u) => (u.href === "custom:mx-sync" ? { contents: ".mx { from: sync; }", syntax: "scss" } : null),
  };
  const syncMiss = { canonicalize: () => null, load: () => null };
  const asyncHit = {
    canonicalize: async (url) => (url === "mx" ? new URL("custom:mx-async") : null),
    load: async (u) => (u.href === "custom:mx-async" ? { contents: ".mx { from: async; }", syntax: "scss" } : null),
  };
  const mx1 = await mod.compileStringAsync(`@use "mx";`, { importers: [asyncMiss, syncHit] });
  assert.ok(mx1.css.includes("from: sync"), `${name}: async-miss then sync-hit chain resolves`);
  const mx2 = await mod.compileStringAsync(`@use "mx";`, { importers: [syncMiss, asyncHit] });
  assert.ok(mx2.css.includes("from: async"), `${name}: sync-miss then async-hit chain resolves`);

  // (b3) F3: a sync-returning FileImporter on the ASYNC API (findFileUrl
  // returns a plain file: URL) matches the sync API's output.
  const syncFi = { findFileUrl(url) { return url === "shared" ? pathToFileURL(join(root, "fi", "shared")) : null; } };
  const fiSrc = `@use "shared" as s;\n.a { height: s.$s; }\n`;
  const aFi = await mod.compileStringAsync(fiSrc, { importers: [syncFi] });
  assert.equal(aFi.css, mod.compileString(fiSrc, { importers: [syncFi] }).css, `${name}: sync FileImporter on the async API equals the sync API`);

  // (b4) F3: custom functions on the async API — a plain (non-Promise) return
  // takes the fast path with identical output, and a null return is an ERROR
  // ("returned no value"), never a canonicalize-style miss.
  const powSrc = `.a { x: pow(3, 4); }`;
  const powFns = { "pow($base, $exp)": (args) => new mod.SassNumber(args[0].value ** args[1].value) };
  const aPow = await mod.compileStringAsync(powSrc, { functions: powFns });
  assert.equal(aPow.css, mod.compileString(powSrc, { functions: powFns }).css, `${name}: sync-returning custom function on the async API equals the sync API`);
  await assert.rejects(
    () => mod.compileStringAsync(`.a { x: nil(); }`, { functions: { "nil()": () => null } }),
    (e) => e instanceof mod.Exception && e.message.includes("returned no value"),
    `${name}: null-returning custom function rejects the async compile`,
  );

  // (c) logger on the async path: @warn/@debug during compileStringAsync
  // route through asyncHost.host_warn to the user logger (dart shape).
  const aLogged = [];
  const alr = await mod.compileStringAsync('@warn "awmsg"; @debug 40 + 2; .a { b: c; }', {
    logger: {
      warn: (m, o) => aLogged.push(["warn", m, o.deprecation]),
      debug: (m) => aLogged.push(["debug", m]),
    },
  });
  assert.ok(alr.css.includes(".a"), `${name}: async logger compile still emits CSS`);
  assert.deepEqual(aLogged, [["warn", "awmsg", false], ["debug", "42"]], `${name}: async @warn + @debug routed to the logger`);

  // (d) concurrent ISOLATION (pool regression guard): 4 concurrent compiles,
  // each with a DISTINCT importer (same "isomod" specifier, per-compile
  // canonical + content), a DISTINCT logger, and a DISTINCT async custom
  // function — nothing may leak across compiles, including loadedUrls.
  const isoLogs = [[], [], [], []];
  const isoCompile = (i) =>
    mod.compileStringAsync(`@use "isomod";\n@warn "w${i}";\n.o-${i} { t: tag(); }\n`, {
      importers: [{
        async canonicalize(url) { await delay(1); return url === "isomod" ? new URL(`custom:iso-${i}`) : null; },
        async load(u) { await delay(1); return u.href === `custom:iso-${i}` ? { contents: `.uniq-${i} { v: ${i}; }`, syntax: "scss" } : null; },
      }],
      logger: { warn: (m) => isoLogs[i].push(m) },
      functions: { "tag()": async () => { await delay(1); return new mod.SassString(`t${i}`, { quotes: false }); } },
    });
  const iso = await Promise.all([0, 1, 2, 3].map(isoCompile));
  for (let i = 0; i < 4; i++) {
    assert.ok(iso[i].css.includes(`.uniq-${i}`) && iso[i].css.includes(`t${i}`), `${name}: concurrent compile #${i} got its own importer + custom function`);
    for (let j = 0; j < 4; j++) {
      if (j === i) continue;
      assert.ok(!iso[i].css.includes(`.uniq-${j}`) && !iso[i].css.includes(`t${j}`), `${name}: concurrent compile #${i} has no leakage from #${j}`);
    }
    assert.deepEqual(isoLogs[i], [`w${i}`], `${name}: concurrent logger #${i} captured exactly its own warn`);
    assert.deepEqual(iso[i].loadedUrls.map((u) => u.href), [`custom:iso-${i}`], `${name}: loadedUrls #${i} isolated to its own module`);
  }

  // (e) MIXED outcomes under concurrency: the middle compile's load()
  // rejects; the lock (or a future pool slot) must be released on error so
  // the flanking compiles still fulfill with the right CSS.
  const mixOk = (tag) => ({
    canonicalize: async (url) => (url === "mix" ? new URL(`custom:mix-${tag}`) : null),
    load: async () => { await delay(2); return { contents: `.mix-${tag} { m: 1; }`, syntax: "scss" }; },
  });
  const mixBad = {
    canonicalize: async (url) => (url === "mix" ? new URL("custom:mix-bad") : null),
    load: () => Promise.reject(new Error("mid-load-boom")),
  };
  const settled = await Promise.allSettled([
    mod.compileStringAsync(`@use "mix";`, { importers: [mixOk("a")] }),
    mod.compileStringAsync(`@use "mix";`, { importers: [mixBad] }),
    mod.compileStringAsync(`@use "mix";`, { importers: [mixOk("b")] }),
  ]);
  assert.equal(settled[0].status, "fulfilled", `${name}: mixed-outcome compile #0 fulfilled`);
  assert.ok(settled[0].value.css.includes(".mix-a"), `${name}: mixed-outcome compile #0 CSS correct`);
  assert.equal(settled[1].status, "rejected", `${name}: mixed-outcome compile #1 rejected`);
  assert.ok(settled[1].reason instanceof mod.Exception && settled[1].reason.message.includes("mid-load-boom"), `${name}: mixed-outcome rejection carries the load error`);
  assert.equal(settled[2].status, "fulfilled", `${name}: mixed-outcome compile #2 fulfilled`);
  assert.ok(settled[2].value.css.includes(".mix-b"), `${name}: mixed-outcome compile #2 CSS correct`);

  // (f) F1 pool OVERLAP: while compile A is suspended on a gated importer, an
  // independent compile B must run to completion on another engine. Under the
  // old asyncLock this deadlocks (B queued behind A forever), so this is the
  // pool's defining semantic test — keep it FIRST awaiting B, not the gate.
  // Pin the cap >= 2 explicitly: the default is min(4, cores), which is 1 on
  // a cpu-limited CI container — and at cap 1 this test would deadlock.
  mod.configure({ asyncInstances: 2 });
  let releaseGate;
  const gate = new Promise((r) => { releaseGate = r; });
  const blocked = mod.compileStringAsync(`@use "g";`, {
    importers: [{
      canonicalize: async (u) => (u === "g" ? new URL("custom:gated") : null),
      load: async () => { await gate; return { contents: ".gated { ok: 1; }", syntax: "scss" }; },
    }],
  });
  const overlapped = await mod.compileStringAsync(".quick { fast: 1; }");
  assert.ok(overlapped.css.includes(".quick"), `${name}: a compile completes while another is suspended (engine pool overlap)`);
  releaseGate();
  const gated = await blocked;
  assert.ok(gated.css.includes(".gated"), `${name}: the suspended compile completes after its importer resolves`);

  // (g) F1 cap semantics: configure({ asyncInstances: 1 }) serializes again —
  // B must NOT finish while A holds the only engine — and the queue drains in
  // order once the gate opens. Restore the default cap afterwards.
  mod.configure({ asyncInstances: 1 });
  try {
    let release1;
    const gate1 = new Promise((r) => { release1 = r; });
    const holdA = mod.compileStringAsync(`@use "h";`, {
      importers: [{
        canonicalize: async (u) => (u === "h" ? new URL("custom:held") : null),
        load: async () => { await gate1; return { contents: ".held { ok: 1; }", syntax: "scss" }; },
      }],
    });
    let bDone = false;
    const queuedB = mod.compileStringAsync(".b { v: 1; }").then((r) => { bDone = true; return r; });
    await delay(25);
    assert.equal(bDone, false, `${name}: with asyncInstances=1 a second compile queues behind the suspended one`);
    release1();
    const [ra, rb] = await Promise.all([holdA, queuedB]);
    assert.ok(ra.css.includes(".held") && rb.css.includes(".b"), `${name}: the single-engine queue drains after the gate opens`);
  } finally {
    mod.configure({ asyncInstances: 4 });
  }

  // === Phase 4: custom functions (sync path, both builds) ===
  const rfn = mod.compileString(`.a { x: pow(2, 10); }`, {
    functions: { "pow($base, $exp)": (args) => new mod.SassNumber(args[0].value ** args[1].value) },
  });
  assert.ok(rfn.css.includes("x: 1024"), `${name}: sync custom function`);

  console.log(`ok: ${name} build — modern + Compiler API + sync & async importers + custom fns (Phase 1+2+2.5+4)`);
}

// === Packaging guards: what `npm pack` ships must match what the code loads ===
// A .wasm missing from the files array ships a production-broken entry while
// every repo-checkout test stays green (the binaries exist locally); likewise
// the speed entry silently falling back to the size async module is invisible
// to behavior tests. Assert the wiring textually.
{
  const pkg = JSON.parse(readFileSync(new URL("./npm/package.json", import.meta.url), "utf8"));
  const shipped = new Set(pkg.files);
  for (const w of ["sasso.wasm", "sasso.speed.wasm", "sasso.async.wasm", "sasso.speed.async.wasm"]) {
    assert.ok(shipped.has(w), `package.json files array ships ${w}`);
  }
  const speedEntry = readFileSync(new URL("./npm/sasso.speed.mjs", import.meta.url), "utf8");
  assert.ok(speedEntry.includes('"./sasso.speed.wasm"'), "speed entry loads the -O3 sync module");
  assert.ok(speedEntry.includes('"./sasso.speed.async.wasm"'), "speed entry loads the -O3 async module (F2)");

  // sasso/native wiring: subpath exported, wrapper + types shipped, and the
  // runtime platform-package list matches the release generator's target list
  // (a drifted pair ships prebuilds the loader can never resolve).
  assert.ok(pkg.exports["./native"] && pkg.exports["./native"].import === "./native.mjs", "exports map has ./native");
  assert.ok(shipped.has("native.mjs") && shipped.has("native.d.ts"), "files array ships the native wrapper + types");
  const genSrc = readFileSync(new URL("../napi/make-platform-package.mjs", import.meta.url), "utf8");
  // Against the loader's actual table rather than a substring of whichever
  // file happens to hold it — the list moved to _addon.mjs when the tests
  // needed to build the same names, and a grep of native.mjs would have gone
  // quietly vacuous at that point instead of failing.
  const { SUPPORTED: resolvable } = await import("./npm/_addon.mjs");
  assert.ok(shipped.has("_addon.mjs"), "files array ships the shared addon module");
  const targets = ["darwin-arm64", "darwin-x64", "linux-x64-gnu", "linux-arm64-gnu"];
  assert.deepEqual(
    Object.keys(resolvable).sort(),
    [...targets].sort(),
    "the loader's platform table is exactly the released target list",
  );
  for (const target of targets) {
    assert.equal(resolvable[target], `sasso-native-${target}`, `the loader resolves sasso-native-${target}`);
    assert.ok(genSrc.includes(`"${target}"`), `make-platform-package.mjs stages ${target}`);
  }
  console.log("ok: packaging — wasm binaries + speed wiring + sasso/native subpath and platform-target consistency");
}

// === Phase 3: CLI (bin) smoke test ===
const cliPath = fileURLToPath(new URL("./npm/cli.mjs", import.meta.url));
// dart-sass's `sysexits` codes, which the binary already follows and this
// CLI now does too (#91). Named here because "exits non-zero" was what
// twenty of these cases used to say, and the code is the point.
const EXIT_USAGE = 64;
const EXIT_COMPILE = 65;
const EXIT_IO = 66;
const cli = (args, input) =>
  execFileSync(process.execPath, [cliPath, ...args], { input, encoding: "utf8" });

// Not just "version-shaped": the engine's `info` carries dart's compatibility
// version too, and printing THAT looks perfectly valid to a regex.
{
  const pkg = JSON.parse(readFileSync(new URL("./npm/package.json", import.meta.url), "utf8"));
  assert.equal(cli(["--version"]).trim(), pkg.version, "cli: --version prints the package's version");
  assert.equal(
    spawnSync(process.execPath, [cliPath, "--version"], { encoding: "utf8", env: { ...process.env, SASSO_ENGINE: "wasm" } }).stdout.trim(),
    pkg.version,
    "cli: … the same on either engine",
  );
}
assert.ok(cli(["--help"]).includes("Usage: sasso"), "cli: --help");

// --silence-deprecation: drop one deprecation and keep everything else, which
// is the whole reason to reach for it instead of --quiet. lichess asked for it
// (momiji-rs/sasso#24) after moving off --quiet precisely so the warnings they
// still intend to fix keep printing.
//
// ON BOTH ENGINES. The CLI silently falls back to wasm where no native addon
// is prebuilt — musl and Windows today — and a flag that works on one engine
// and does nothing on the other is worse than one that does not exist,
// because nothing says so. This caught exactly that while it was being
// written: the native path ignored the option and printed all six lines.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-silence-"));
  // Twelve imports, so the per-id cap fires: dart prints five warnings and a
  // "7 repetitive deprecation warnings omitted" footer.
  for (let i = 0; i < 12; i++) writeFileSync(join(dir, `dep${i}.scss`), `.d${i} { color: red }\n`);
  const entry = join(dir, "entry.scss");
  writeFileSync(entry, Array.from({ length: 12 }, (_v, i) => `@import "dep${i}";`).join("\n") + "\n");

  const runOf = (args, engine) =>
    spawnSync(process.execPath, [cliPath, ...args], {
      encoding: "utf8",
      env: { ...process.env, SASSO_ENGINE: engine },
    });
  const stderrOf = (args, engine) => runOf(args, engine).stderr;

  // The addon is prebuilt for four targets only, and the wasm-package CI job
  // builds none at all, so the native leg runs where there is one to run and
  // announces itself where there is not. The wasm leg is never optional: a
  // silent skip of both would leave this whole block asserting nothing.
  const engines = ["native", "wasm"].filter((engine) => {
    if (engine === "wasm") return true;
    const probe = runOf([entry, "--no-css"], engine);
    if (probe.status === 0) return true;
    assert.match(probe.stderr, /SASSO_ENGINE=native/, "cli: a demanded engine that is missing says so");
    console.log("  (--silence-deprecation: skipping the native leg, no addon here)");
    return false;
  });
  assert.ok(engines.includes("wasm"), "cli: the wasm leg of --silence-deprecation is not optional");

  for (const engine of engines) {
    const loud = stderrOf([entry, "--no-css"], engine);
    assert.ok(loud.includes("DEPRECATION WARNING [import]"), `cli: the deprecation prints (${engine})`);
    assert.ok(loud.includes("omitted"), `cli: the repetition cap fires (${engine})`);

    const quiet = stderrOf([entry, "--no-css", "--silence-deprecation=import"], engine);
    // Not merely "no DEPRECATION line": the footer has to go too. Filtering in
    // a warn handler instead silences the warnings and still counts them, so
    // the run ends by reporting omissions the caller asked not to hear about —
    // dart prints nothing at all here, and that is what this pins.
    assert.equal(quiet.trim(), "", `cli: --silence-deprecation leaves no trace (${engine})`);

    const other = stderrOf([entry, "--no-css", "--silence-deprecation=color-functions"], engine);
    assert.ok(
      other.includes("DEPRECATION WARNING [import]"),
      `cli: silencing one id leaves the others (${engine})`,
    );
  }

  // An id dart does not know is a usage error there, so a typo is caught
  // rather than quietly leaving the warning in place.
  const bad = spawnSync(process.execPath, [cliPath, entry, "--no-css", "--silence-deprecation=nope"], {
    encoding: "utf8",
  });
  assert.notEqual(bad.status, 0, "cli: an unknown deprecation id is rejected");
  assert.ok(bad.stderr.includes('Invalid deprecation "nope"'), "cli: … with dart's wording");
  // dart exits 64 here and the native CLI matches it; this one exits 1 because
  // every npm-CLI failure does (#91), which is a separate ticket.

  // Ids sasso never emits are accepted and do nothing: a build script written
  // for `sass` must not fail for naming one.
  const unknownToUs = spawnSync(process.execPath, [cliPath, entry, "--no-css", "--silence-deprecation=mixed-decls"], {
    encoding: "utf8",
  });
  assert.equal(unknownToUs.status, 0, "cli: an id we never emit is still accepted");
}
assert.equal(cli(["--stdin"], ".a{b: 1 + 2}\n").trim(), ".a {\n  b: 3;\n}", "cli: --stdin compile");
assert.equal(cli(["--style=compressed", "--stdin"], ".a{b:1+2}\n").trim(), ".a{b:3}", "cli: --style=compressed");
assert.ok(cli([mainRel]).includes("color: blue"), "cli: file compile resolves relative @use");
assert.ok(cli(["-I", join(root, "inc"), "--stdin"], "@use 'lib' as l;\n.a{width: l.$w}\n").includes("width: 7px"), "cli: -I load-path");
let cliErr = false;
try { cli(["--stdin"], ".a{color:}\n"); } catch { cliErr = true; }
assert.ok(cliErr, "cli: a Sass error exits non-zero");
let cliMissing = false;
// The native CLI's wording, verbatim: one CLI in two implementations.
try { cli(["/no/such/file.scss"]); } catch (e) { cliMissing = /Error reading \/no\/such\/file\.scss: Cannot open file\./.test(String(e.stderr || "")); }
assert.ok(cliMissing, "cli: a missing input file errors cleanly");

// CLI polish flags: --embed-source-map / --quiet / multiple input:output / --update
assert.ok(
  // dart writes `Uri.dataFromString` — percent-encoded JSON, not base64.
  cli(["--embed-source-map", "--stdin"], ".a{b:1}\n").includes(
    "sourceMappingURL=data:application/json;charset=utf-8,%7B%22version%22:3",
  ),
  "cli: --embed-source-map inlines the map as dart's data: URI",
);
{
  const warnSrc = '@warn "x"; .a{b:c}\n';
  const loud = spawnSync(process.execPath, [cliPath, "--stdin"], { input: warnSrc, encoding: "utf8" });
  assert.ok(loud.stderr.includes("WARNING"), "cli: @warn prints to stderr by default");
  const quiet = spawnSync(process.execPath, [cliPath, "--quiet", "--stdin"], { input: warnSrc, encoding: "utf8" });
  assert.equal(quiet.stderr.trim(), "", "cli: --quiet suppresses @warn");
}
{
  const mio = mkdtempSync(join(tmpdir(), "sasso-mio-"));
  const ina = join(mio, "a.scss"), inb = join(mio, "b.scss"), outa = join(mio, "a.css"), outb = join(mio, "b.css");
  writeFileSync(ina, ".a{x:1}\n");
  writeFileSync(inb, ".b{y:2}\n");
  cli(["--quiet", `${ina}:${outa}`, `${inb}:${outb}`]);
  assert.ok(existsSync(outa) && existsSync(outb), "cli: multiple input:output pairs");
  assert.ok(readFileSync(outa, "utf8").includes("x: 1") && readFileSync(outb, "utf8").includes("y: 2"), "cli: multi-IO contents");
  const before = statSync(outa).mtimeMs;
  cli(["--quiet", "--update", `${ina}:${outa}`]);
  assert.equal(statSync(outa).mtimeMs, before, "cli: --update leaves a fresh output untouched");
}
{
  // `--update` and the dependency graph (#133). Checking only the ENTRY's
  // mtime left stale CSS on disk whenever a PARTIAL changed — silently, which
  // is worse than a slow build, and on an `@import`-heavy tree it is the
  // common case rather than the corner. dart-sass walks the graph; the test
  // goes two levels deep because one level can pass by accident.
  const dir = mkdtempSync(join(tmpdir(), "sasso-upd-"));
  const deep = join(dir, "_deep.scss");
  const base = join(dir, "_base.scss");
  const entry = join(dir, "entry.scss");
  const out = join(dir, "out.css");
  writeFileSync(deep, "$c: #111;\n");
  writeFileSync(base, '@import "deep";\n.base { color: $c; }\n');
  writeFileSync(entry, '@import "base";\n');

  cli(["--quiet", "--no-source-map", `${entry}:${out}`]);
  assert.match(readFileSync(out, "utf8"), /#111/, "cli: --update fixture compiled");

  // Nothing changed: the output must keep its mtime, which is what downstream
  // watchers key on and the whole reason the flag exists.
  const stamp = statSync(out).mtimeMs;
  cli(["--quiet", "--no-source-map", "--update", `${entry}:${out}`]);
  assert.equal(statSync(out).mtimeMs, stamp, "cli: --update leaves an up-to-date output alone");

  // A partial TWO levels down changes: the output is stale and must be rebuilt.
  writeFileSync(deep, "$c: #444;\n");
  cli(["--quiet", "--no-source-map", "--update", `${entry}:${out}`]);
  assert.match(
    readFileSync(out, "utf8"),
    /#444/,
    "cli: --update rebuilds when a transitively imported partial changes",
  );
}
{
  // `--update` narrates each WRITTEN file on stdout, stamped with the local
  // time — dart's shape, measured 2026-09-19. Same table as the binary's
  // test: written announces, skipped and failed are silent, --quiet
  // suppresses, several pairs report in COMMAND-LINE order (they finish in
  // whatever order the worker pool finishes them).
  const d = mkdtempSync(join(tmpdir(), "sasso-narrate-"));
  writeFileSync(join(d, "one.scss"), "a {b: c}\n");
  writeFileSync(join(d, "two.scss"), "x {y: z}\n");
  const run = (...args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args], { encoding: "utf8", cwd: d });
  const STAMP = /^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] /;

  const first = run("--update", "one.scss:one.css");
  assert.equal(first.status, 0, `cli: ${first.stderr}`);
  // Not `stderr === ""`: an engine-fallback warning legitimately shares
  // that stream, and asserting an empty one failed CI on a runner where
  // the native addon did not load. What matters is that the compile line
  // is not there.
  assert.ok(!first.stderr.includes("Compiled"), `cli: the line belongs on stdout: ${first.stderr}`);
  // A stamp, when present, must be well formed — this CLI gets local time
  // from JS `Date`, so unlike the binary it has one everywhere.
  assert.match(first.stdout, STAMP, "cli: a [YYYY-MM-DD HH:MM:SS] stamp");
  assert.match(first.stdout, /Compiled one\.scss to one\.css\.\n$/, "cli: dart's wording");

  const again = run("--update", "one.scss:one.css");
  assert.equal(again.stdout, "", "cli: a skip says nothing");

  rmSync(join(d, "one.css"), { force: true });
  const both = run("--update", "one.scss:one.css", "two.scss:two.css");
  const lines = both.stdout.trim().split("\n");
  assert.equal(lines.length, 2, `cli: one line per file: ${both.stdout}`);
  assert.ok(lines[0].endsWith("Compiled one.scss to one.css."), `cli: ${lines[0]}`);
  assert.ok(lines[1].endsWith("Compiled two.scss to two.css."), `cli: ${lines[1]}`);

  rmSync(join(d, "one.css"), { force: true });
  assert.equal(run("--quiet", "--update", "one.scss:one.css").stdout, "", "cli: --quiet means quiet");

  writeFileSync(join(d, "bad.scss"), '@use "nope";\n');
  const failed = run("--update", "bad.scss:bad.css");
  assert.notEqual(failed.status, 0, "cli: a missing module is an error");
  assert.ok(!failed.stdout.includes("Compiled"), "cli: a failure is not announced as a compile");

  // A stdin source is named `stdin`, not `-`. This CLI formats the line
  // itself rather than sharing the binary's code, so the binary's test of
  // the same rule does not cover it.
  rmSync(join(d, "o.css"), { force: true });
  const viaStdin = spawnSync(process.execPath, [cliPath, "--no-source-map", "--update", "-:o.css"], {
    encoding: "utf8",
    input: "a {b: c}\n",
    cwd: d,
  });
  assert.equal(viaStdin.status, 0, `cli: ${viaStdin.stderr}`);
  assert.match(
    viaStdin.stdout,
    /Compiled stdin to o\.css\.\n$/,
    `cli: dart names standard input \`stdin\`, not \`-\`: ${viaStdin.stdout}`,
  );

  // --no-css writes nothing, so it announces nothing.
  rmSync(join(d, "one.css"), { force: true });
  const noCss = run("--no-css", "--update", "one.scss:one.css");
  assert.equal(noCss.status, 0, `cli: ${noCss.stderr}`);
  assert.equal(noCss.stdout, "", `cli: --no-css wrote nothing, so it says nothing: ${noCss.stdout}`);
  assert.ok(!existsSync(join(d, "one.css")), "cli: --no-css really wrote nothing");
}
{
  // dart's other `--update` usage error: nowhere to write means nothing to
  // compare, so the flag cannot do anything and dart refuses rather than
  // compile to the terminal (exit 64, measured 2026-09-19). Every shape that
  // names a destination stays allowed, `-o` included — this CLI's own
  // spelling, with no dart equivalent.
  const d = mkdtempSync(join(tmpdir(), "sasso-updout-"));
  writeFileSync(join(d, "t.scss"), "a {b: c}\n");
  const at = (...args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args], { encoding: "utf8", cwd: d });

  const bare = at("--update", "t.scss");
  assert.notEqual(bare.status, 0, "cli: --update with no destination is refused");
  assert.match(
    bare.stderr,
    /--update is not allowed when printing to stdout\./,
    "cli: … in dart's words",
  );
  assert.equal(bare.stdout, "", "cli: … and nothing is compiled to the terminal");

  for (const args of [
    ["--update", "t.scss", "out.css"],
    ["--update", "t.scss:out.css"],
    ["--update", "-o", "out.css", "t.scss"],
  ]) {
    rmSync(join(d, "out.css"), { force: true });
    const ok = at(...args);
    assert.equal(ok.status, 0, `cli: ${args.join(" ")} names a destination: ${ok.stderr}`);
    assert.match(readFileSync(join(d, "out.css"), "utf8"), /b: c/, `cli: ${args.join(" ")} wrote no CSS`);
  }
}
{
  // A `-` INPUT is standard input too, and dart ACCEPTS it with --update
  // (measured 2026-09-19: `sass --update - out.css` and `sass --update
  // -:out.css` both exit 0 and compile stdin). Only the --stdin FLAG is
  // refused. The safety here is not a refusal: with no input mtime nothing
  // can be called fresh, so every run must rewrite.
  for (const form of [["--update", "-", "out.css"], ["--update", "-:out.css"]]) {
    const d = mkdtempSync(join(tmpdir(), "sasso-dash-"));
    const at = (css) =>
      spawnSync(process.execPath, [cliPath, "--no-source-map", ...form], {
        encoding: "utf8",
        input: css,
        cwd: d,
      });
    // A REAL file named `-` next to the output: `statSync("-")` succeeds on
    // it, so a freshness check that stats the string instead of recognising
    // standard input calls an output newer than this decoy fresh.
    writeFileSync(join(d, "-"), ".decoy { color: green; }\n");
    const first = at(".a { color: #111; }\n");
    assert.equal(first.status, 0, `cli: --update accepts a \`-\` input (${form.join(" ")}): ${first.stderr}`);
    assert.match(readFileSync(join(d, "out.css"), "utf8"), /#111/, "cli: first compile");
    const second = at(".a { color: #222; }\n");
    assert.equal(second.status, 0, `cli: ${second.stderr}`);
    assert.match(
      readFileSync(join(d, "out.css"), "utf8"),
      /#222/,
      "cli: --update kept stale CSS for a stdin input",
    );
  }
}
{
  // `--update` with `--stdin` is a usage error in dart, and now in both of
  // ours. This CLI happened to be safe already (statting `-` throws, so
  // nothing looked fresh) while the binary silently kept stale CSS; refusing
  // the pair is what dart does and leaves neither to luck.
  const r = spawnSync(process.execPath, [cliPath, "--stdin", "--update", "out.css"], {
    encoding: "utf8",
    input: ".a { color: red }\n",
  });
  assert.notEqual(r.status, 0, "cli: --update with --stdin is refused");
  assert.match(r.stderr, /--update is not allowed with --stdin\./, "cli: … in dart's words");
}
console.log("ok: cli — version/help/stdin/style/file @use/load-path/errors + embed-map/quiet/multi-IO/update");

// === Phase 3b: the npm CLI must accept every flag the NATIVE CLI accepts ===
// These are two separate implementations of one command. The dart-compatible
// flags were added to the Rust CLI (src/main.rs) and this one was left behind,
// so `sasso@0.13.0` rejected every flag a dart-sass build script passes except
// `--quiet` — reported on momiji-rs/sasso#24 by someone whose build it broke.
// This derives the flag set from the Rust parser rather than a hand-kept list,
// so the next flag added there fails here until this CLI takes it too.
{
  const mainRs = readFileSync(new URL("../src/main.rs", import.meta.url), "utf8");
  // Every flag the native parser handles, taken from the parser's own shape —
  // the `"--x" | "-y" => …` match arms and the `--x=value` forms it strips a
  // prefix for — rather than from a fixed slice of the file. The first version
  // of this guard read 8,000 characters after `match a.as_str()`, which would
  // have quietly stopped covering flags added past the cutoff: a drift guard
  // that drifts.
  const found = new Set();
  for (const line of mainRs.split("\n")) {
    const arm = /^\s*("-[^"]*"(?:\s*\|\s*"-[^"]*")*)\s*=>/.exec(line);
    if (arm) for (const m of arm[1].matchAll(/"(-[^"]*)"/g)) found.add(m[1]);
    for (const m of line.matchAll(/strip_prefix\("(--[a-zA-Z-]+)=/g)) found.add(m[1]);
  }
  const flags = [...found];
  assert.ok(flags.length > 25, `drift: extracted a plausible flag set (got ${flags.length})`);
  // If the extraction itself breaks, the set above goes quietly empty-ish and
  // every "is it accepted?" probe below passes vacuously. These are flags the
  // native CLI has had since 0.10.0: their absence means the guard, not the
  // CLI, is what changed.
  for (const flag of ["-s", "--style", "-I", "--load-path", "-o", "--output", "--quiet-deps", "--no-css", "--source-map-urls", "--loop", "--jobs", "--stop-on-error", "--embed-source-map", "--no-unicode"]) {
    assert.ok(found.has(flag), `drift: the extraction still finds ${flag} in src/main.rs`);
  }

  // Flags that take a value, and a value that is valid for each.
  const withValue = {
    "-s": "expanded", "--style": "expanded",
    "-I": ".", "--load-path": ".",
    "-j": "1", "--jobs": "1",
    "--loop": "1",
    "--source-map-urls": "relative",
  };
  // `-o`/`--output` name the output themselves, so they are probed with a
  // POSITIONAL input rather than an `in:out` pair (which they may not be
  // combined with, here or in the native CLI).
  const outputFlags = new Set(["-o", "--output"]);
  // Flags that exit before compiling, so they cannot be probed this way.
  const terminal = new Set(["-h", "--help", "--version", "--"]);
  // …and the opposite: a flag whose whole job is NOT to exit. Probing `-w`
  // with a valid input starts a watch, and `spawnSync` with no timeout waits
  // for it forever — which is how this guard hung the suite the day the
  // binary grew a watcher and `-w` first appeared in its `--help`. A flag
  // that has to be killed did not say "unknown option", so it counts as
  // accepted, which is exactly what the guard is asking.
  const neverExits = new Set(["-w", "--watch"]);

  const dir = mkdtempSync(join(tmpdir(), "sasso-drift-"));
  const src = join(dir, "in.scss");
  writeFileSync(src, ".a{b:1}\n");

  const rejected = [];
  for (const f of flags) {
    if (terminal.has(f)) continue;
    const argv = outputFlags.has(f)
      ? [cliPath, "--no-source-map", f, join(dir, "out.css"), src]
      : [cliPath, "--no-source-map", ...(f in withValue ? [f, withValue[f]] : [f]), `${src}:${join(dir, "out.css")}`];
    const r = spawnSync(process.execPath, argv, {
      encoding: "utf8",
      timeout: neverExits.has(f) ? 1500 : 30000,
    });
    if (/unknown option/.test(r.stderr || "")) rejected.push(f);
  }
  assert.deepEqual(
    rejected,
    [],
    `cli: these flags are accepted by the native CLI and rejected here: ${rejected.join(" ")}`,
  );

  // The shape that actually broke: the flag set a dart-sass build passes.
  const lila = ["--no-error-css", "--stop-on-error", "--no-color", "--quiet", "--quiet-deps"];
  const a = join(dir, "a.scss"), b = join(dir, "b.scss");
  writeFileSync(a, ".a{x:1}\n");
  writeFileSync(b, ".b{y:2}\n");
  const r = spawnSync(
    process.execPath,
    [cliPath, ...lila, "--style=compressed", "--no-source-map", `${a}:${join(dir, "a.css")}`, `${b}:${join(dir, "b.css")}`],
    { encoding: "utf8" },
  );
  assert.equal(r.status, 0, `cli: a dart-sass build's flag set compiles (stderr: ${r.stderr})`);
  assert.equal(readFileSync(join(dir, "a.css"), "utf8").trim(), ".a{x:1}", "cli: dart flag set output a");
  assert.equal(readFileSync(join(dir, "b.css"), "utf8").trim(), ".b{y:2}", "cli: dart flag set output b");
  // ...and the REVERSE, which is how #86 happened. This guard only ever
  // checked that the npm CLI accepts what the binary does; the binary quietly
  // grew two flags behind — `--watch` and `--update` — so a build script
  // written for `sass` worked under `npm install sasso` and failed with the
  // binary, the mirror image of the #24 report and just as surprising.
  //
  // The npm CLI's own flags come from its parser the same way the native ones
  // do, so neither list is hand-kept. `known` names the differences that are
  // deliberate, each with its reason; anything else fails.
  const cliSrc2 = readFileSync(new URL("./npm/cli.mjs", import.meta.url), "utf8");
  const npmFlags = new Set();
  // `A-Za-z`, not `a-z`: the parser accepts `-I` and would accept a future
  // `-X`, and a lowercase-only pattern drops them from this set silently —
  // which is the failure mode this whole guard exists to prevent.
  for (const m of cliSrc2.matchAll(/a === "(--?[A-Za-z-]+)"/g)) npmFlags.add(m[1]);
  for (const m of cliSrc2.matchAll(/a\.startsWith\("(--?[A-Za-z-]+)=/g)) npmFlags.add(m[1]);
  assert.ok(npmFlags.size > 20, `drift: extracted a plausible npm flag set (got ${npmFlags.size})`);

  // Two lists, not one, because they mean different things. A flag in
  // `byDesign` will never exist on the other side; a flag in `gaps` is one the
  // binary should have and does not, and the entry is a reminder rather than
  // a blessing — deleting it is how the guard starts failing again once the
  // work lands.
  const byDesign = new Map([
    ["--engine", "reports which engine the npm CLI chose; the binary IS the engine"],
  ]);
  // Empty, and that is the point of the entry above it: #86's `-w`/`--watch`
  // lived here until the binary grew a watcher, and the guard only started
  // failing again — asking for this list to shrink — because the entries
  // were removed when the work landed.
  const gaps = new Map([]);
  const onlyNpm = [...npmFlags].filter((f) => !flags.includes(f) && !byDesign.has(f) && !gaps.has(f));
  assert.deepEqual(
    onlyNpm,
    [],
    `cli: these flags are accepted by the npm CLI and rejected by the binary: ${onlyNpm.join(" ")}`,
  );
  // Every entry in BOTH lists claims the same shape of fact — "the npm CLI
  // has this flag and the binary does not" — and differs only in why, which
  // is prose. So both are checked the same way, in a loop, rather than by
  // hand-written assertions per list. Writing them by hand is precisely how
  // this went wrong twice: `onlyNpm` filters both lists OUT, so an entry that
  // has stopped being true is invisible unless something looks for it, and
  // each list ended up with a different subset of the two checks.
  //
  // What the two checks catch, in the two ways an entry rots:
  //   - the npm CLI no longer has the flag: the entry describes no difference
  //     at all. `byDesign` carried `--pkg-importer` this way — a DART flag
  //     neither of ours has, with a description claiming the npm CLI resolves
  //     `pkg:` URLs. That is worse than a missing entry: it reads as a
  //     checked, deliberate divergence.
  //   - the binary has GAINED the flag: for `gaps` the work has landed and
  //     the reminder must go, or it hides the next gap; for `byDesign` the
  //     stated reason ("the binary IS the engine") has become false.
  for (const [label, list] of [
    ["byDesign", byDesign],
    ["gaps", gaps],
  ]) {
    const absent = [...list.keys()].filter((f) => !npmFlags.has(f));
    assert.deepEqual(
      absent,
      [],
      `cli: ${label} names flags the npm CLI does not have: ${absent.join(" ")}`,
    );
    const gained = [...list.keys()].filter((f) => flags.includes(f));
    assert.deepEqual(
      gained,
      [],
      `cli: ${label} names flags the binary now has: ${gained.join(" ")}`,
    );
  }

  console.log(
    `ok: cli flag parity — ${flags.length} native flags and ${npmFlags.size} npm flags, neither side ahead`,
  );
}

// The two `--silence-deprecation` allowlists are the same list written twice,
// so derive this one's from the Rust one rather than comparing two hand-kept
// copies. The first version of BOTH was probed candidate-by-candidate against
// dart and missed seven ids — `if-function` among them, which sasso emits —
// so what matters here is only that they cannot now drift apart.
{
  const mainRs = readFileSync(new URL("../src/main.rs", import.meta.url), "utf8");
  const decl = /const DEPRECATION_IDS: \[&str; (\d+)\] = \[([^\]]*)\]/.exec(mainRs);
  assert.ok(decl, "drift: found DEPRECATION_IDS in src/main.rs");
  const native = [...decl[2].matchAll(/"([a-z0-9-]+)"/g)].map((m) => m[1]);
  assert.equal(native.length, Number(decl[1]), "drift: the Rust list's length matches its own count");
  assert.ok(native.length >= 31, `drift: extracted a plausible id set (got ${native.length})`);

  // The JS side keeps ONE copy, in _deprecations.mjs, shared by cli.mjs, the
  // loader and native.mjs — so this compares two lists, not four.
  const shared = await import("./npm/_deprecations.mjs");
  const ours = [...shared.DEPRECATION_IDS];

  // The wasm ABI's older entry point cannot carry this list, and a .wasm is a
  // build artifact that can be older than the loader beside it. Dropping the
  // list there would recreate the bug the option was added to fix — a flag
  // accepted that does nothing — so it fails instead, loudly enough to name
  // the cause. An empty list is not a request and must still fall back, which
  // is every caller who never passed the option.
  assert.doesNotThrow(() => shared.ensureSilenceSupported(true, 42), "compile3 present: fine");
  assert.doesNotThrow(() => shared.ensureSilenceSupported(false, 0), "no list: still falls back to compile2");
  assert.doesNotThrow(() => shared.ensureSilenceSupported(true, 0), "neither: fine");
  assert.throws(
    () => shared.ensureSilenceSupported(false, 42),
    /sasso_compile3/,
    "a list against a compile2-only module fails rather than being dropped",
  );
  // The loader must consult it, and must do so BEFORE it allocates: nothing
  // frees the marshalled buffers on a throw — `readResult` owns that and is
  // only reached on a completed compile — so a guard after the allocations
  // would trade a silently-ignored option for a leak on every attempt.
  const loaderSrc = readFileSync(new URL("./npm/_loader.mjs", import.meta.url), "utf8");
  const marshal = loaderSrc.slice(
    loaderSrc.indexOf("function marshalIn"),
    loaderSrc.indexOf("function callCompile2"),
  );
  const guardAt = marshal.indexOf("ensureSilenceSupported");
  const allocAt = marshal.indexOf("sasso_alloc");
  assert.ok(guardAt > 0, "marshalIn consults the compile3 guard");
  assert.ok(allocAt > 0 && guardAt < allocAt, "… before it allocates anything that would leak");
  assert.deepEqual([...ours].sort(), [...native].sort(), "cli: the two deprecation allowlists agree");
  for (const f of ["cli.mjs", "_loader.mjs", "native.mjs"]) {
    const text = readFileSync(new URL(`./npm/${f}`, import.meta.url), "utf8");
    assert.ok(
      !/const DEPRECATION_IDS\s*=\s*new Set/.test(text),
      `drift: ${f} declares its own id list again instead of importing the shared one`,
    );
  }

  // Not just the literal: the parser has to take every one of them, and still
  // refuse something that is not on the list.
  const dir = mkdtempSync(join(tmpdir(), "sasso-depids-"));
  const one = join(dir, "in.scss");
  writeFileSync(one, ".a{b:1}\n");
  const refused = native.filter((id) => {
    const r = spawnSync(process.execPath, [cliPath, "--no-source-map", "--silence-deprecation", id, "--stdin"], {
      encoding: "utf8",
      input: ".a{b:1}\n",
    });
    return r.status !== 0;
  });
  assert.deepEqual(refused, [], `cli: these ids are on the list but refused: ${refused.join(" ")}`);

  const bogus = spawnSync(process.execPath, [cliPath, "--silence-deprecation", "not-a-deprecation", "--stdin"], {
    encoding: "utf8",
    input: ".a{b:1}\n",
  });
  assert.notEqual(bogus.status, 0, "cli: an id on neither list is still refused");
  console.log(`ok: deprecation-id parity — ${native.length} ids, both CLIs, all accepted`);
}

// === Pairing `sasso` with its prebuilt addon (#114) ===
//
// `sasso` pins the four `sasso-native-*` packages as exact-version
// optionalDependencies, so a plain install cannot drift. A consumer that names
// them itself has a second place to bump — lichess-org/lila#21712 does — and a
// drift there is invisible: napi ignores config fields it does not know without
// erroring, so an addon one release behind accepts every option the newer JS
// sends and applies only the ones it recognises. The compile succeeds and
// quietly does something else.
{
  const { assertAddonVersion } = await import("./npm/_addon.mjs");
  const P = "sasso-native-linux-x64-gnu";

  assertAddonVersion("0.17.0", "0.17.0", P); // the normal case: identical
  // No manifest to compare is not a mismatch: `SASSO_NATIVE_BINARY` and the
  // repo-local build are dev paths and must keep working unchecked.
  assertAddonVersion(null, "0.17.0", P);
  assertAddonVersion("0.17.0", null, P);
  assertAddonVersion(null, null, P);

  let caught;
  try {
    assertAddonVersion("0.17.0", "0.16.0", P);
  } catch (e) {
    caught = e;
  }
  assert.ok(caught, "addon: a version skew is refused");
  assert.equal(caught.code, "SASSO_ADDON_VERSION_MISMATCH", "addon: … with a code the CLI can branch on");
  assert.match(caught.message, /0\.16\.0/, "addon: … naming the addon's version");
  assert.match(caught.message, /0\.17\.0/, "addon: … and this package's");
  assert.match(caught.message, new RegExp(P), "addon: … and the package to fix");

  // A newer addon than the JS is refused too. It is the rarer direction and
  // the less dangerous one, but "which side is ahead" is not something this
  // can know the consequences of, so it does not guess.
  assert.throws(() => assertAddonVersion("0.16.0", "0.17.0", P), /0\.17\.0/, "addon: skew either way");

  // The unit tests above prove the RULE. They cannot prove it is wired in, and
  // the first version of this block tried to with `nativeSrc.indexOf(...)` —
  // which happily matched the call after it had been commented out. So the
  // wiring is tested by running it: a fabricated platform package on NODE_PATH
  // is what the loader actually resolves, so the skew is real rather than
  // simulated, and nothing is written inside the repo.
  const addonBin = fileURLToPath(new URL("../napi/npm/sasso.node", import.meta.url));
  // The loader's own naming, not a second spelling of it: on Linux the
  // prebuilds carry a libc suffix (`linux-x64-gnu`), so `platform-arch` names a
  // package the loader never looks for — the fabricated skew is then simply
  // not found, the loader falls through to the repo-local build, and the test
  // passes while asserting nothing. That is what happened on CI while it passed
  // on macOS. A platform with no prebuild at all (musl, Windows) has no name to
  // fabricate, and skips rather than fails.
  const { platformKey, SUPPORTED } = await import("./npm/_addon.mjs");
  const pkgName = SUPPORTED[platformKey()];
  if (!existsSync(addonBin) || !pkgName) {
    console.log(`  (addon pairing: skipping the wiring test — ${pkgName ? "no addon built here" : "no prebuild for " + platformKey()})`);
  } else {
    const nodePath = mkdtempSync(join(tmpdir(), "sasso-skew-"));
    const pkgDir = join(nodePath, pkgName);
    mkdirSync(pkgDir, { recursive: true });
    writeFileSync(join(pkgDir, "sasso.node"), readFileSync(addonBin));
    const manifest = (version) =>
      writeFileSync(
        join(pkgDir, "package.json"),
        JSON.stringify({ name: pkgName, version, main: "sasso.node" }),
      );
    const nativeUrl = new URL("./npm/native.mjs", import.meta.url).href;
    // An exported SASSO_ENGINE decides for the child exactly what these
    // cases exist to observe. The skew case below must be free to fall
    // back to wasm, and the demanded case sets the variable itself; with
    // `SASSO_ENGINE=native` in the environment the first one is pinned to
    // the engine it is supposed to be abandoning and exits 1. The same
    // scrub the jobs cases already do.
    const withPath = (extra) => {
      const base = { ...process.env, NODE_PATH: nodePath };
      delete base.SASSO_ENGINE;
      return { ...base, ...extra };
    };

    manifest("9.9.9"); // not this package's version, whatever this package's is
    const probe = spawnSync(
      process.execPath,
      ["--input-type=module", "-e", `import(${JSON.stringify(nativeUrl)}).then(() => console.log("LOADED"), (e) => console.log(e.code))`],
      { encoding: "utf8", env: withPath() },
    );
    assert.equal(
      probe.stdout.trim(),
      "SASSO_ADDON_VERSION_MISMATCH",
      "addon: sasso/native refuses a skewed addon in a real load",
    );

    // The CLI tells a skew apart from a platform with no prebuild: the latter
    // falls back silently by design, the former must say so — output stays
    // correct either way, and silence would trade a wrong compile for a slow
    // one with nothing to read.
    const viaCli = spawnSync(process.execPath, [cliPath, "--stdin"], {
      encoding: "utf8",
      input: ".a{b: 1 + 1}\n",
      env: withPath(),
    });
    assert.equal(viaCli.status, 0, "addon: the CLI still compiles with a skewed addon");
    assert.match(viaCli.stdout, /b: 2/, "addon: … and its output is correct (wasm)");
    assert.match(viaCli.stderr, /sasso-native-/, "addon: … having named the mismatch");
    assert.match(viaCli.stderr, /wasm engine/, "addon: … and said what it fell back to");
    // Said once: the generic "prebuilt addon did not load" warning stays out of
    // the way of this one, which is the same fact with the fix attached.
    assert.equal(
      viaCli.stderr.split("\n").filter((l) => l.trim()).length,
      2,
      "addon: … and not doubled by the fallback warning",
    );

    // And `--engine` calls it a refusal rather than an unexplained miss, which
    // is the difference between "reinstall" and "unpin the platform package".
    const skewEngine = spawnSync(process.execPath, [cliPath, "--engine"], { encoding: "utf8", env: withPath() });
    assert.match(skewEngine.stdout, /^engine: +wasm .*refused/m, "addon: --engine names the refusal");

    // A demanded engine still fails rather than falling back.
    const demanded = spawnSync(process.execPath, [cliPath, "--stdin"], {
      encoding: "utf8",
      input: ".a{b: 1 + 1}\n",
      env: withPath({ SASSO_ENGINE: "native" }),
    });
    assert.notEqual(demanded.status, 0, "addon: SASSO_ENGINE=native with a skewed addon fails");

    // And the matching version is accepted — otherwise the test above would
    // pass just as well against a loader that refused every addon.
    manifest(JSON.parse(readFileSync(new URL("./npm/package.json", import.meta.url), "utf8")).version);
    const agreed = spawnSync(
      process.execPath,
      ["--input-type=module", "-e", `import(${JSON.stringify(nativeUrl)}).then(() => console.log("LOADED"), (e) => console.log(e.code))`],
      { encoding: "utf8", env: withPath() },
    );
    assert.equal(agreed.stdout.trim(), "LOADED", "addon: a matching version is accepted");
    rmSync(nodePath, { recursive: true, force: true });
  }
  console.log("ok: addon pairing — a version skew is refused, both directions, dev paths exempt");
}

// === Phase 3c: directory pairs, --no-css, --stop-on-error ===
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-dir-"));
  mkdirSync(join(dir, "src", "sub"), { recursive: true });
  writeFileSync(join(dir, "src", "one.scss"), ".a{x:1}\n");
  writeFileSync(join(dir, "src", "sub", "two.scss"), ".b{y:2}\n");
  writeFileSync(join(dir, "src", "_partial.scss"), ".c{z:3}\n");
  cli(["--quiet", "--no-source-map", `${join(dir, "src")}:${join(dir, "out")}`]);
  assert.ok(existsSync(join(dir, "out", "one.css")), "cli: directory pair compiles a top-level file");
  assert.ok(existsSync(join(dir, "out", "sub", "two.css")), "cli: directory pair preserves the tree");
  assert.ok(!existsSync(join(dir, "out", "_partial.css")), "cli: directory pair skips partials");

  // --no-css compiles and writes nothing.
  const nocss = join(dir, "nocss.css");
  cli(["--quiet", "--no-source-map", "--no-css", `${join(dir, "src", "one.scss")}:${nocss}`]);
  assert.ok(!existsSync(nocss), "cli: --no-css writes no output");

  // --stop-on-error stops at the first failure; the default keeps going. Both
  // exit non-zero.
  const bad = join(dir, "bad.scss");
  writeFileSync(bad, ".a{b:}\n");
  const second = join(dir, "second.css");
  // `--stop-on-error` is "don't START more files once one fails", so what it
  // skips depends on how many are already running. At `-j 1` the second job
  // never starts; with the default one-per-CPU it may already have, and the
  // NATIVE CLI behaves the same way (measured 2026-09-17: `sasso
  // --stop-on-error bad:a good:b` writes b, `-j 1` does not). So the
  // deterministic claim is pinned at -j 1, and the parallel case is pinned on
  // what it does guarantee: a non-zero exit.
  const stop = spawnSync(
    process.execPath,
    [cliPath, "--no-source-map", "-j", "1", "--stop-on-error", `${bad}:${join(dir, "s1.css")}`, `${join(dir, "src", "one.scss")}:${second}`],
    { encoding: "utf8" },
  );
  assert.equal(stop.status, EXIT_COMPILE, "cli: --stop-on-error exits 65 for a broken stylesheet");
  assert.ok(!existsSync(second), "cli: --stop-on-error -j 1 skips the rest");
  const stopParallel = spawnSync(
    process.execPath,
    [cliPath, "--no-source-map", "--stop-on-error", `${bad}:${join(dir, "s3.css")}`, `${join(dir, "src", "one.scss")}:${join(dir, "s4.css")}`],
    { encoding: "utf8" },
  );
  assert.equal(stopParallel.status, EXIT_COMPILE, "cli: --stop-on-error exits 65 in parallel too");
  const go = spawnSync(
    process.execPath,
    [cliPath, "--no-source-map", `${bad}:${join(dir, "s2.css")}`, `${join(dir, "src", "one.scss")}:${second}`],
    { encoding: "utf8" },
  );
  assert.equal(go.status, EXIT_COMPILE, "cli: a failed job still exits 65 without --stop-on-error");
  assert.ok(existsSync(second), "cli: without --stop-on-error the rest still compiles");
  console.log("ok: cli — directory pairs, --no-css, --stop-on-error");
}

// === Phase 3d: directory mode follows dart's tree, not Node's Dirent ===
// dart compiles `.css` sources too and FOLLOWS symlinked directories (measured
// against dart-sass 1.104.1 on 2026-09-17); `Dirent.isDirectory()` reports
// false for a directory symlink, which silently dropped whole subtrees.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-tree-"));
  mkdirSync(join(dir, "src", "sub"), { recursive: true });
  mkdirSync(join(dir, "outside"), { recursive: true });
  writeFileSync(join(dir, "src", "a.scss"), ".a{x:1}\n");
  writeFileSync(join(dir, "src", "sub", "b.sass"), ".b\n  y: 2\n");
  writeFileSync(join(dir, "src", "plain.css"), ".p{z:3}\n");
  writeFileSync(join(dir, "src", "_partial.scss"), ".c{q:4}\n");
  writeFileSync(join(dir, "src", "UPPER.SCSS"), ".u{r:5}\n");
  writeFileSync(join(dir, "outside", "c.scss"), ".o{w:6}\n");
  symlinkSync(join(dir, "outside"), join(dir, "src", "link"));
  cli(["--quiet", "--no-source-map", `${join(dir, "src")}:${join(dir, "built")}`]);
  const built = (rel) => existsSync(join(dir, "built", rel));
  assert.ok(built("a.css"), "cli: directory mode compiles .scss");
  assert.ok(built(join("sub", "b.css")), "cli: directory mode compiles .sass and keeps the tree");
  assert.ok(built("plain.css"), "cli: directory mode compiles a plain .css source");
  assert.ok(built(join("link", "c.css")), "cli: directory mode follows a symlinked directory");
  assert.ok(!built("_partial.css"), "cli: directory mode skips partials");
  assert.ok(!built("UPPER.css"), "cli: directory mode's suffixes are exact-lowercase");

  // A symlink back to an ancestor must not loop: each directory is visited
  // once by canonical identity.
  symlinkSync(join(dir, "src"), join(dir, "src", "sub", "loop"));
  cli(["--quiet", "--no-source-map", `${join(dir, "src")}:${join(dir, "cyc")}`]);
  assert.ok(existsSync(join(dir, "cyc", "a.css")), "cli: a symlink cycle still compiles the tree");
  assert.ok(!existsSync(join(dir, "cyc", "sub", "loop", "a.css")), "cli: a symlink cycle is visited once");

  // A destination nested in the source tree does not mirror itself.
  cli(["--quiet", "--no-source-map", `${join(dir, "src")}:${join(dir, "src", "css")}`]);
  cli(["--quiet", "--no-source-map", `${join(dir, "src")}:${join(dir, "src", "css")}`]);
  assert.ok(existsSync(join(dir, "src", "css", "a.css")), "cli: nested destination compiles the tree");
  assert.ok(!existsSync(join(dir, "src", "css", "css")), "cli: a nested destination is not mirrored into itself");
  console.log("ok: cli — directory mode: .css, symlinks, cycles, nested destination");
}

// === Phase 3e: source maps as dart writes them ===
// The npm CLI used to write absolute `sources`, a base64 data: URI and no blank
// line before the footer — none of which is what dart-sass (or the native CLI)
// produces. Worse, it wrote the `.map` BEFORE creating the output directory, so
// a `<dir>:<dir>` job into a fresh tree died with ENOENT unless --no-source-map
// was passed.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-map-"));
  mkdirSync(join(dir, "sub"), { recursive: true });
  writeFileSync(join(dir, "in.scss"), '@use "sub/x";\n.e{a:1}\n');
  writeFileSync(join(dir, "sub", "_x.scss"), ".x{b:2}\n");
  const out = join(dir, "deep", "out.css");
  cli([join(dir, "in.scss"), out]); // no --no-source-map: the map is the point
  const map = JSON.parse(readFileSync(out + ".map", "utf8"));
  assert.deepEqual(
    map.sources,
    ["../sub/_x.scss", "../in.scss"],
    "cli: map sources are relative to the .map file (dart's default)",
  );
  assert.equal(map.file, "out.css", "cli: map file field");
  assert.equal(map.sourceRoot, "", "cli: map sourceRoot, as dart writes it");
  assert.ok(
    readFileSync(out, "utf8").endsWith("}\n\n/*# sourceMappingURL=out.css.map */\n"),
    "cli: expanded output has dart's blank line before the footer",
  );

  const abs = join(dir, "abs.css");
  cli(["--source-map-urls=absolute", join(dir, "in.scss"), abs]);
  const absMap = JSON.parse(readFileSync(abs + ".map", "utf8"));
  assert.ok(
    absMap.sources.every((u) => u.startsWith("file://")),
    "cli: --source-map-urls=absolute writes file: URLs",
  );
  assert.notDeepEqual(absMap.sources, map.sources, "cli: --source-map-urls actually changes the map");

  const cmp = join(dir, "cmp.css");
  cli(["--style=compressed", join(dir, "in.scss"), cmp]);
  assert.ok(
    readFileSync(cmp, "utf8").endsWith("}/*# sourceMappingURL=cmp.css.map */\n"),
    "cli: compressed output has no blank line before the footer",
  );

  // An empty stylesheet still terminates a FILE with exactly one newline.
  writeFileSync(join(dir, "empty.scss"), "// nothing\n");
  const emptyOut = join(dir, "empty.css");
  cli(["--no-source-map", join(dir, "empty.scss"), emptyOut]);
  assert.equal(readFileSync(emptyOut, "utf8"), "\n", "cli: an empty stylesheet writes a lone newline to a file");

  // Printing a map to stdout is an error unless it is embedded (dart's rules).
  for (const args of [["--source-map"], ["--embed-sources"], ["--source-map-urls=relative"], ["--source-map-urls=absolute"]]) {
    const r = spawnSync(process.execPath, [cliPath, ...args, join(dir, "in.scss")], { encoding: "utf8" });
    assert.equal(r.status, EXIT_USAGE, `cli: ${args[0]} to stdout is rejected`);
    assert.match(r.stderr, /stdout/, `cli: ${args[0]} to stdout explains why`);
  }
  console.log("ok: cli — source maps: relative sources, --source-map-urls, footers, stdout rules");
}

// === Phase 3f: -o/--output, stale output, --no-css on every path ===
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-out-"));
  const src = join(dir, "in.scss");
  writeFileSync(src, ".a{b:1}\n");

  // -o names the output, exactly like a second positional.
  const viaFlag = join(dir, "flag.css"), viaPos = join(dir, "pos.css");
  cli(["--no-source-map", "-o", viaFlag, src]);
  cli(["--no-source-map", src, viaPos]);
  assert.equal(readFileSync(viaFlag, "utf8"), readFileSync(viaPos, "utf8"), "cli: -o matches a positional output");
  cli(["--no-source-map", `--output=${join(dir, "eq.css")}`, src]);
  assert.ok(existsSync(join(dir, "eq.css")), "cli: --output=<file>");
  const bothForms = spawnSync(process.execPath, [cliPath, "-o", viaFlag, `${src}:${viaPos}`], { encoding: "utf8" });
  assert.equal(bothForms.status, EXIT_USAGE, "cli: --output with an in:out pair is rejected");
  // Repeating the flag is an assignment in the native parser, not an error:
  // the last one wins. (Naming the output twice in DIFFERENT ways — `-o` plus
  // a second positional — is what it rejects.)
  const first = join(dir, "first.css"), second = join(dir, "second.css");
  cli(["--no-source-map", `--output=${first}`, `--output=${second}`, src]);
  assert.ok(!existsSync(first), "cli: a repeated --output does not write the earlier one");
  assert.ok(existsSync(second), "cli: … it writes the last one");
  const twoWays = spawnSync(process.execPath, [cliPath, "-o", first, src, second], { encoding: "utf8" });
  assert.equal(twoWays.status, EXIT_USAGE, "cli: but --output plus a positional output is still rejected");

  // A failed compile REPLACES the output with a stylesheet describing the
  // error, as dart does by default. This asserted the opposite until
  // --error-css was implemented — the test pinned the divergence, which
  // is how it survived being documented as NOT IMPLEMENTED in --help.
  const stale = join(dir, "stale.css");
  cli(["--no-source-map", src, stale]);
  assert.ok(existsSync(stale), "cli: the first build wrote an output");
  writeFileSync(src, ".a{b:}\n");
  const failed = spawnSync(process.execPath, [cliPath, "--no-source-map", src, stale], { encoding: "utf8" });
  assert.equal(failed.status, EXIT_COMPILE, "cli: the second build fails");
  assert.match(
    readFileSync(stale, "utf8"),
    /^\/\* Error: /,
    "cli: a failed compile leaves error CSS where the stale output was",
  );
  // …and --no-error-css is how you ask for the old behaviour: rebuild
  // from a good source, break it again, and the output goes rather than
  // being replaced.
  writeFileSync(src, ".a{b:1}\n");
  cli(["--no-source-map", src, stale]);
  writeFileSync(src, ".a{b:}\n");
  spawnSync(process.execPath, [cliPath, "--no-source-map", "--no-error-css", src, stale], { encoding: "utf8" });
  assert.ok(!existsSync(stale), "cli: --no-error-css removes it instead");

  // ... unless --no-css, which means no output-side effects at all.
  const kept = join(dir, "kept.css");
  writeFileSync(src, ".a{b:1}\n");
  cli(["--no-source-map", src, kept]);
  writeFileSync(src, ".a{b:}\n");
  spawnSync(process.execPath, [cliPath, "--no-source-map", "--no-css", src, kept], { encoding: "utf8" });
  assert.ok(existsSync(kept), "cli: --no-css leaves an existing output alone, even on failure");

  // --no-css discards stdout output too, not just a file.
  const nocssStdin = spawnSync(process.execPath, [cliPath, "--no-source-map", "--no-css", "--stdin"], {
    input: ".a{b:1}\n",
    encoding: "utf8",
  });
  assert.equal(nocssStdin.status, 0, "cli: --no-css --stdin compiles");
  assert.equal(nocssStdin.stdout, "", "cli: --no-css --stdin writes no CSS");
  console.log("ok: cli — -o/--output, stale output dropped on failure, --no-css everywhere");
}

// === Phase 3g: --quiet-deps silences dependencies, by PROVENANCE ===
// dart's rule is about how a file was REACHED, not where it lives: a stylesheet
// found through a load path is a dependency (and so is whatever it loads
// relatively), but one the entry loads relatively is not — even when it sits
// inside a load-path directory. Only deprecation warnings are dropped; a
// dependency's own @warn still prints. All four measured against dart-sass
// 1.104.1 on 2026-09-17.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-qd-"));
  mkdirSync(join(dir, "lib"), { recursive: true });
  writeFileSync(join(dir, "lib", "dep.scss"), '@warn "dep-warn";\n.d{color: lighten(#036, 10%)}\n');
  writeFileSync(join(dir, "entry.scss"), '@use "dep";\n.e{color: lighten(#036, 20%)}\n');
  // The same directory, reached relatively from the entry instead.
  writeFileSync(join(dir, "lib", "rel.scss"), ".r{color: lighten(#036, 30%)}\n");
  writeFileSync(join(dir, "entry2.scss"), '@use "lib/rel";\n');

  const run = (args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", "-I", join(dir, "lib"), ...args], {
      encoding: "utf8",
      cwd: dir,
    }).stderr;

  // One diagnostic runs from its heading line to the next one (a deprecation
  // block has blank lines INSIDE it, so blank lines do not separate them), and
  // ends in a stack whose FIRST frame is where it was raised. The entry appears
  // in a dependency's stack too, so a diagnostic cannot be attributed by
  // searching it for a file name — an earlier draft of this test did, and could
  // not fail.
  const diagnostics = (out) => {
    const found = [];
    for (const line of out.split("\n")) {
      if (/^(DEPRECATION WARNING|WARNING|DEBUG)\b/.test(line)) found.push(line);
      else if (found.length > 0) found[found.length - 1] += `\n${line}`;
    }
    return found;
  };
  const originOf = (diag) => {
    const m = /^\s+(\S+)\s+\d+:\d+/m.exec(diag);
    return m ? m[1].split(/[\\/]/).pop() : "";
  };
  const deprecationsFrom = (out, file) =>
    diagnostics(out).filter((d) => d.startsWith("DEPRECATION WARNING") && originOf(d) === file);

  const loud = run([join(dir, "entry.scss")]);
  assert.ok(deprecationsFrom(loud, "dep.scss").length > 0, "cli: a dependency's deprecations print by default");
  assert.ok(deprecationsFrom(loud, "entry.scss").length > 0, "cli: the entry's deprecations print by default");

  const quiet = run(["--quiet-deps", join(dir, "entry.scss")]);
  assert.equal(deprecationsFrom(quiet, "dep.scss").length, 0, "cli: --quiet-deps drops a dependency's deprecations");
  assert.ok(deprecationsFrom(quiet, "entry.scss").length > 0, "cli: --quiet-deps keeps the entry's own");
  assert.match(quiet, /WARNING: dep-warn/, "cli: --quiet-deps keeps a dependency's @warn (as dart does)");
  assert.match(quiet, /╷/, "cli: a warning that survives keeps its formatted source snippet");

  const rel = run(["--quiet-deps", join(dir, "entry2.scss")]);
  assert.ok(
    deprecationsFrom(rel, "rel.scss").length > 0,
    "cli: a file loaded relatively is not a dependency, wherever it lives",
  );
  console.log("ok: cli — --quiet-deps by provenance (load path vs relative), @warn kept");
}

// === Phase 3h: the argument grammar the native CLI enforces ===
// Accepting a flag is not implementing it, and accepting an ARGUMENT SHAPE the
// native CLI rejects is its own kind of drift: the same command line then means
// different things depending on which sasso is installed. Every message below
// is the native CLI's, and all but the empty-pair sides are dart-sass 1.104.1's
// own wording (measured 2026-09-17; dart answers an empty side with an I/O
// error instead, which the native CLI deliberately improves on).
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-args-"));
  mkdirSync(join(dir, "src"), { recursive: true });
  mkdirSync(join(dir, "empty"), { recursive: true });
  mkdirSync(join(dir, "partials"), { recursive: true });
  const src = join(dir, "in.scss");
  writeFileSync(src, ".a{b:1}\n");
  writeFileSync(join(dir, "two.scss"), ".b{c:2}\n");
  writeFileSync(join(dir, "src", "a.scss"), ".x{y:2}\n");
  writeFileSync(join(dir, "partials", "_p.scss"), ".p{q:3}\n");
  // A timeout, because half of what this block asserts is that the CLI REFUSES
  // to start work: a count it should have rejected (`--loop=4294967296`) would
  // otherwise run four billion compiles and wedge the suite instead of failing
  // it.
  const run = (args, input) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args], {
      encoding: "utf8",
      input: input ?? "",
      cwd: dir,
      timeout: 20000,
    });
  const rejects = (args, wanted) => {
    const r = run(args);
    assert.equal(r.status, EXIT_USAGE, `cli: ${args.join(" ")} is rejected`);
    assert.ok(r.stderr.includes(wanted), `cli: ${args.join(" ")} says "${wanted}" (got: ${r.stderr.split("\n")[0]})`);
  };

  rejects(["in.scss", "a.css", "b.css"], "Only two positional args may be passed.");
  rejects(["--stdin", "a.css", "b.css"], "Only one argument is allowed with --stdin.");
  rejects([":out.css"], "expected <source>:<destination>");
  rejects(["in.scss:"], "expected <source>:<destination>");
  rejects(["in.scss:out:other.css"], 'may only contain one ":".');
  rejects(["in.scss:one.css", "in.scss:two.css"], 'Duplicate source "in.scss".');
  rejects(["--no-source-map", "--embed-sources", "in.scss", "out.css"], "--embed-sources isn't allowed with --no-source-map.");
  rejects(["--no-source-map", "--embed-source-map", "in.scss", "out.css"], "--embed-source-map isn't allowed with --no-source-map.");
  rejects(["--no-source-map", "--source-map-urls=absolute", "in.scss", "out.css"], "--source-map-urls isn't allowed with --no-source-map.");
  rejects(["--jobs", "0"], "--jobs expects a positive integer");
  rejects(["--loop", "nope"], "--loop expects a positive integer");

  // --- the drive-letter pair grammar (#172) ---------------------------------
  //
  // A colon at index 1 after an ASCII letter is a drive letter's, not the pair
  // separator, on EVERY platform — dart asks the same question everywhere and
  // so must both sasso CLIs, or one command line means three things. Measured
  // against dart-sass 1.104.1 on macOS, all three before the fix:
  //
  //   operand                 dart            binary          this CLI
  //   C:\in.scss              one path        pair C+\in...   one path
  //   C:in.scss               one path        pair C+in...    pair C+in...
  //   a:b                     one path        pair a+b        pair a+b
  //   a:b:c                   pair a:b+c      one-":" error   one-":" error
  //   in.scss:C:\out.css      pair            one-":" error   pair
  //
  // (measured on macOS, where every spelling above is an ordinary relative
  // filename; `driveArg` below re-spells the ones that need a REAL drive)
  //
  // The binary was `cfg!(windows)`-gated (so POSIX took the false branch and
  // no test ran on Windows); this CLI asked for a separator after the drive
  // colon, which dart does not. Both read the rule the same way now.
  //
  // A backslash is an ordinary filename byte on POSIX, so the drive-shaped
  // operands below run here as written — which is the point: the grammar is
  // no longer a Windows-only branch nobody can reach. Where a real drive
  // letter is needed, `driveArg` spells one the way THIS platform can.
  {
    // A path carrying a drive letter, in the only form each platform has one.
    //
    // On Windows the temp directory is already drive-qualified
    // (`C:\Users\…\Temp\sasso-args-…`), so the operand exercises the rule
    // with a real path. On POSIX no path carries a drive, so the fixture is a
    // FILE WHOSE NAME IS `C:\out.css` — legal there, and the same string the
    // parser sees.
    //
    // Writing the POSIX spelling on Windows would build
    // `…\sasso-args-…\C:\out.css`, which `path.join` produces happily and
    // Windows cannot create (`:` is reserved), and passing `C:\out.css` as an
    // operand there is ABSOLUTE — it addresses the root of the real C:, not
    // the fixture. Neither would test the parser; one would write outside the
    // temp directory.
    const WIN = process.platform === "win32";
    const driveArg = (name) => (WIN ? join(dir, name) : `C:\\${name}`);
    const driveFile = (name) => (WIN ? join(dir, name) : join(dir, `C:\\${name}`));

    writeFileSync(driveFile("drive.scss"), ".drive{a:1}\n");
    mkdirSync(join(dir, "a"), { recursive: true });
    writeFileSync(join(dir, "a", "one.scss"), ".one{b:2}\n");

    // One path, not a pair: it compiles to stdout rather than being read as
    // the pair `C` + the rest.
    const whole = run([driveArg("drive.scss")]);
    assert.equal(whole.status, 0, `cli: a drive-spelled path is one path (stderr: ${whole.stderr})`);
    assert.ok(whole.stdout.includes(".drive"), "cli: …and it is the file that was compiled");

    // No separator after the drive colon is required — `Q:in.scss` is
    // drive-RELATIVE, and dart reads it as one path too. The proof is WHICH
    // name the read error carries: the whole operand, not the `Q` a pair
    // would have split off.
    //
    // `Q:`, not `C:`: on Windows a drive-relative path is resolved against
    // that drive's own current directory, and the cwd here IS on C:, so
    // `C:no-such.scss` would name a file in this very fixture directory.
    const rel = run(["Q:no-such-drive-relative.scss"]);
    assert.equal(rel.status, EXIT_IO, "cli: a drive-relative path is one path that is missing");
    assert.ok(
      rel.stderr.includes("Q:no-such-drive-relative.scss"),
      `cli: …named whole, not split (got: ${rel.stderr.split("\n")[0]})`,
    );

    // Both sides may carry a drive, and that is not "more than one colon".
    const two = run([`${driveArg("drive.scss")}:${driveArg("out.css")}`]);
    assert.equal(two.status, 0, `cli: two drive colons are one pair (stderr: ${two.stderr})`);
    assert.ok(existsSync(driveFile("out.css")), "cli: …written to the drive-spelled destination");

    // The destination carries the only drive.
    const destOnly = run([`in.scss:${driveArg("dest.css")}`]);
    assert.equal(destOnly.status, 0, `cli: a drive on the destination alone (stderr: ${destOnly.stderr})`);
    assert.ok(existsSync(driveFile("dest.css")), "cli: …written there");

    // Past the skipped drive colon the NEXT colon separates, so this is the
    // pair `a:b` + `c` and fails at READ time, not as a grammar error.
    const past = run(["a:b:c"]);
    assert.equal(past.status, EXIT_IO, "cli: a:b:c splits after the drive colon");
    assert.ok(past.stderr.includes("a:b"), `cli: …source a:b (got: ${past.stderr.split("\n")[0]})`);

    // The cost of parity, pinned: a one-letter source directory is read as a
    // drive, so `a:b` is one path. dart answers `Error reading a:b`.
    const oneLetter = run(["a:b"]);
    assert.equal(oneLetter.status, EXIT_IO, "cli: a:b is one path, not a pair");
    assert.ok(!existsSync(join(dir, "b")), "cli: …so nothing was compiled into b/");

    // Two letters is not a drive: still a pair.
    const twoLetters = run(["src:outdir"]);
    assert.equal(twoLetters.status, 0, `cli: ab:cd is still a pair (stderr: ${twoLetters.stderr})`);
    assert.ok(existsSync(join(dir, "outdir", "a.css")), "cli: …and it compiled the directory");

    // A digit is not a drive letter, so this splits at index 1 and the
    // destination carries the extra colon.
    rejects(["1:\\in.scss:out.css"], 'may only contain one ":".');
    // The operand is quoted as the user typed it — `{arg:?}` in the binary
    // escaped the backslash and printed `"C:\\\\in.scss…"`.
    const quoted = run(["C:\\in.scss:out.css:x"]);
    assert.ok(
      quoted.stderr.includes('"C:\\in.scss:out.css:x" may only contain one ":".'),
      `cli: the operand is quoted raw (got: ${quoted.stderr.split("\n")[0]})`,
    );
  }

  // The same file named by a directory pair AND an explicit pair compiles once,
  // to the destination named last — dart keeps its sources in a path-keyed map.
  // (Spellings are compared lexically against the cwd, as the native CLI does,
  // so these stay relative: on macOS an absolute /var path and the cwd's
  // /private/var realpath are two different keys, there as here.)
  const both = run(["src:out", "src/a.scss:elsewhere.css"]);
  assert.equal(both.status, 0, `cli: a directory pair plus an explicit pair compiles (stderr: ${both.stderr})`);
  assert.ok(existsSync(join(dir, "elsewhere.css")), "cli: the LAST destination wins");
  assert.ok(!existsSync(join(dir, "out", "a.css")), "cli: the earlier destination is not written too");
  // Two spellings of one path are one source (and not a "duplicate" either).
  const spellings = run(["src/a.scss:first.css", "./src/a.scss:second.css"]);
  assert.equal(spellings.status, 0, `cli: two spellings of one source compile (stderr: ${spellings.stderr})`);
  assert.ok(!existsSync(join(dir, "first.css")), "cli: two spellings coalesce …");
  assert.ok(existsSync(join(dir, "second.css")), "cli: … to the later destination");

  // A directory that expands to nothing is not an error (dart exits 0); no
  // input at all still is.
  assert.equal(run([`empty:${join(dir, "e1")}`]).status, 0, "cli: an empty directory pair succeeds");
  assert.equal(run([`partials:${join(dir, "e2")}`]).status, 0, "cli: a directory of only partials succeeds");
  const noInput = run([]);
  assert.equal(noInput.status, EXIT_USAGE, "cli: no input at all is an error");
  assert.match(noInput.stderr, /no input file/, "cli: and says so");

  // `-` is standard input, in both the positional and the pair form.
  assert.match(run(["-"], ".s{t:1}\n").stdout, /\.s/, "cli: `-` reads standard input");
  const pairDash = run([`-:${join(dir, "dash.css")}`], ".u{v:2}\n");
  assert.equal(pairDash.status, 0, `cli: \`-\` as a pair source (stderr: ${pairDash.stderr})`);
  assert.match(readFileSync(join(dir, "dash.css"), "utf8"), /\.u/, "cli: and writes its output");
  // A count is a decimal integer TOKEN, not whatever `Number()` will coerce:
  // the native CLI parses it as Rust does, taking `+3` and `03` but refusing
  // `1.0`, `1e3`, `0x2` and anything padded with spaces.
  for (const flag of ["--jobs", "--loop"]) {
    for (const value of ["1.0", "1e3", "0x2", " 3", "3 ", "2_0", "-1", ""]) {
      rejects([`${flag}=${value}`, "in.scss"], `${flag} expects a positive integer`);
    }
    for (const value of ["+3", "03"]) {
      const r = run([`${flag}=${value}`, "in.scss"]);
      assert.equal(r.status, 0, `cli: ${flag}=${value} is accepted, as Rust's parse is (stderr: ${r.stderr})`);
    }
  }

  // A DIRECTORY may not be the output, however it is named. The --stdin path
  // does not go through parseJobs, and used to die with an uncaught EISDIR.
  mkdirSync(join(dir, "adir"), { recursive: true });
  rejects(["in.scss", "adir"], 'Directory "adir" may not be a positional arg.');
  rejects(["-o", "adir", "in.scss"], 'Directory "adir" may not be a positional arg.');
  const stdinDir = run(["--stdin", "adir"], ".a{b:1}\n");
  assert.equal(stdinDir.status, EXIT_USAGE, "cli: --stdin with a directory output is rejected");
  assert.match(stdinDir.stderr, /may not be a positional arg\./, "cli: … with the native CLI's message");
  // A pair destination that is a directory only fails on the write, as it does
  // natively — but it fails as an ERROR, not as a raw stack trace.
  const pairDir = run(["in.scss:adir"]);
  assert.equal(pairDir.status, EXIT_IO, "cli: a directory as a pair destination exits 66");
  assert.match(pairDir.stderr, /^error: cannot write adir: /m, "cli: … reporting the write, not throwing");
  assert.ok(!/at \w+ \(node:/.test(pairDir.stderr), "cli: … with no Node stack trace");
  // --indented is documented for stdin, but dart applies it to FILE inputs too
  // (measured 2026-09-17), and so does the native CLI: the extension does not
  // get a vote once it is passed.
  writeFileSync(join(dir, "indented.scss"), ".a\n  b: 1\n");
  const indented = run(["--indented", "indented.scss"]);
  assert.equal(indented.status, 0, `cli: --indented parses a .scss file as Sass (stderr: ${indented.stderr})`);
  assert.match(indented.stdout, /b: 1/, "cli: … and compiles it");
  const notIndented = run(["indented.scss"]);
  assert.equal(notIndented.status, EXIT_COMPILE, "cli: without --indented the extension decides, and this file is not SCSS");
  // Short options with an ATTACHED value (`-Ilib`, `-j4`). dart's own parser
  // takes them — `sass -Ilib in.scss` compiles, measured against 1.104.1 on
  // 2026-09-17 — so this CLI takes them too, and is pinned here because the
  // NATIVE CLI currently rejects them (momiji-rs/sasso#78): if that parser
  // gains the form, these stay true; if this one ever loses it, a build script
  // written for `sass` breaks.
  mkdirSync(join(dir, "lib"), { recursive: true });
  writeFileSync(join(dir, "lib", "_v.scss"), "$w: 7px;\n");
  writeFileSync(join(dir, "uses.scss"), '@use "v" as v;\n.a{width: v.$w}\n');
  for (const args of [["-I", "lib"], ["-Ilib"], ["--load-path=lib"], ["--load-path", "lib"]]) {
    const r = run([...args, "uses.scss"]);
    assert.equal(r.status, 0, `cli: ${args.join(" ")} resolves the load path (stderr: ${r.stderr})`);
    assert.match(r.stdout, /width: 7px/, `cli: ${args.join(" ")} compiles`);
  }
  assert.equal(run(["-j4", "in.scss"]).status, 0, "cli: -j4 (attached) is accepted, like dart's short options");
  // What dart does NOT take: a value attached to a flag that has none, and a
  // bundle. Both CLIs reject them.
  rejects(["-scompressed", "in.scss"], "unknown option -scompressed");
  rejects(["-qc", "in.scss"], "unknown option -qc");

  // A count that overflows the Rust integer the native parser uses is a
  // rejection, not four billion compiles.
  rejects(["--loop=4294967296", "in.scss"], "--loop expects a positive integer");
  assert.equal(run(["--jobs=4294967296", "in.scss"]).status, 0, "cli: --jobs is a usize natively, so this fits");
  // Mixing the two operand forms, and naming the output twice.
  rejects(["in.scss:out.css", "two.scss"], 'Positional and ":" arguments may not both be used.');
  rejects(["--stdin", "-o", "a.css", "b.css"], "--output requires a single input");
  rejects(["--loop", "2", "--stdin", "out.css"], "--loop compiles to stdout only");
  console.log("ok: cli — the argument grammar: arity, pairs, duplicates, `-`, counts, directories, --indented");
}

// === Phase 3k: symlinks keep the path they were REACHED through ===
// dart-sass resolves a load lexically and leaves symlinks alone: a map names
// the link, not its target — a pnpm `node_modules/<pkg>` path rather than the
// `.pnpm` store it points into, which is what makes such a map navigable. The
// npm package used to `realpathSync` every entry and every resolved import, so
// all three of these named the physical file (measured against dart-sass
// 1.104.1 on 2026-09-17).
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-link-"));
  mkdirSync(join(dir, "real"), { recursive: true });
  mkdirSync(join(dir, "src"), { recursive: true });
  writeFileSync(join(dir, "real", "c.scss"), ".c{d:1}\n");
  symlinkSync(join(dir, "real"), join(dir, "src", "link"));
  symlinkSync(join(dir, "real", "c.scss"), join(dir, "linkfile.scss"));
  const sourcesOf = (mapPath) => JSON.parse(readFileSync(mapPath, "utf8")).sources;

  cli([`${join(dir, "src")}:${join(dir, "out")}`]);
  assert.deepEqual(
    sourcesOf(join(dir, "out", "link", "c.css.map")),
    ["../../src/link/c.scss"],
    "cli: a directory job through a symlink mirrors the logical tree",
  );
  cli([join(dir, "src", "link", "c.scss"), join(dir, "one", "x.css")]);
  assert.deepEqual(
    sourcesOf(join(dir, "one", "x.css.map")),
    ["../src/link/c.scss"],
    "cli: a file reached through a symlinked directory keeps that path",
  );
  cli([join(dir, "linkfile.scss"), join(dir, "two", "y.css")]);
  assert.deepEqual(
    sourcesOf(join(dir, "two", "y.css.map")),
    ["../linkfile.scss"],
    "cli: a symlinked file keeps its own name",
  );

  // The JS API answers the same way — this is the loader's rule, not the CLI's.
  for (const [name, mod] of [["size", size], ["speed", speed]]) {
    const result = mod.compile(join(dir, "linkfile.scss"), { sourceMap: true });
    assert.equal(
      result.loadedUrls[0].href,
      pathToFileURL(join(dir, "linkfile.scss")).href,
      `loadedUrls(${name}): a symlinked entry is named by its link`,
    );
  }
  console.log("ok: symlinks — maps and loadedUrls name the path taken, not the target");
}

// === Phase 3i: --no-unicode, dart's URL encoding, the stdin data: URI ===
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-diag-"));
  mkdirSync(join(dir, "sub"), { recursive: true });
  const dep = join(dir, "dep.scss");
  writeFileSync(dep, ".d{color: lighten(#036, 10%)}\n");
  const glyphs = (args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args, dep], { encoding: "utf8" }).stderr;
  assert.match(glyphs([]), /╷/, "cli: diagnostics use the Unicode gutter by default");
  const ascii = glyphs(["--no-unicode"]);
  assert.ok(!/[╷│╵]/.test(ascii), "cli: --no-unicode renders the ASCII glyph set");
  assert.match(ascii, /^\s*,$/m, "cli: … which opens the snippet with a comma, as dart does");

  // dart's URL encoder keeps the sub-delims `!$&'()*+,;=@`; encodeURIComponent
  // escapes `+` and `,`, which would spell these sources differently.
  writeFileSync(join(dir, "sub", "_the+me,1.scss"), ".x{y:2}\n");
  writeFileSync(join(dir, "ent.scss"), '@use "sub/the+me,1" as t;\n.e{a:1}\n');
  const out = join(dir, "out", "a+b,c.css");
  cli([join(dir, "ent.scss"), out]);
  const map = JSON.parse(readFileSync(out + ".map", "utf8"));
  assert.ok(
    map.sources.includes("../sub/_the+me,1.scss"),
    `cli: a source's sub-delims survive the map (got ${JSON.stringify(map.sources)})`,
  );
  assert.equal(map.file, "a+b,c.css", "cli: and so do the output's");
  assert.ok(
    readFileSync(out, "utf8").includes("sourceMappingURL=a+b,c.css.map"),
    "cli: and the footer's",
  );

  // A stdin entry has no path: dart records its TEXT as a data: URI.
  const stdinOut = join(dir, "stdin.css");
  spawnSync(process.execPath, [cliPath, "--stdin", stdinOut], { encoding: "utf8", input: ".a{b:1}\n" });
  const stdinMap = JSON.parse(readFileSync(stdinOut + ".map", "utf8"));
  assert.deepEqual(
    stdinMap.sources,
    ["data:;charset=utf-8,.a%7Bb:1%7D%0A"],
    "cli: a --stdin map names its source by the text, as dart does",
  );

  // --no-css builds no map for an output it is about to discard, and writes
  // neither the CSS nor the sidecar.
  const discarded = join(dir, "none.css");
  const nocss = spawnSync(process.execPath, [cliPath, "--no-css", "--source-map", join(dir, "ent.scss"), discarded], {
    encoding: "utf8",
  });
  assert.equal(nocss.status, 0, `cli: --no-css --source-map compiles (stderr: ${nocss.stderr})`);
  assert.ok(!existsSync(discarded) && !existsSync(discarded + ".map"), "cli: --no-css writes neither CSS nor map");
  console.log("ok: cli — --no-unicode, dart's URL encoding, the stdin data: URI");
}

// === Phase 3j: --loop measures the compiler, on stdout only ===
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-loop-"));
  const src = join(dir, "in.scss");
  writeFileSync(src, '@warn "said once";\n.a{b: 1 + 1}\n');
  const looped = spawnSync(process.execPath, [cliPath, "--loop", "3", src], { encoding: "utf8" });
  assert.equal(looped.status, 0, `cli: --loop compiles (stderr: ${looped.stderr})`);
  assert.match(looped.stdout, /b: 2/, "cli: --loop prints the last CSS");
  assert.match(looped.stderr, /sasso: 3 compiles in .* ms\/compile, .* compiles\/sec/, "cli: --loop reports throughput");
  // An untimed WARM pass runs first and is the one that talks; the timed
  // iterations are silent. So a warning appears exactly once however many
  // times the loop runs — and the number measures compiling rather than the
  // engine's first-compile costs (measured: 3.699 -> 0.114 ms/compile here).
  assert.equal(
    (looped.stderr.match(/said once/g) || []).length,
    1,
    "cli: --loop reports a warning once, from the warm pass",
  );
  const looped9 = spawnSync(process.execPath, [cliPath, "--loop", "9", src], { encoding: "utf8" });
  assert.equal(
    (looped9.stderr.match(/said once/g) || []).length,
    1,
    "cli: … once whatever N is, so the timed loop really is silent",
  );
  // A failure is reported by that same pass, before anything is timed.
  const badLoop = join(dir, "bad.scss");
  writeFileSync(badLoop, ".a{b:}\n");
  const failed = spawnSync(process.execPath, [cliPath, "--loop", "3", badLoop], { encoding: "utf8" });
  assert.equal(failed.status, EXIT_COMPILE, "cli: --loop on a broken stylesheet exits 65");
  assert.match(failed.stderr, /^Error: /m, "cli: … with the compile error");
  assert.ok(!/compiles in/.test(failed.stderr), "cli: … and no throughput line");
  const quietLoop = spawnSync(process.execPath, [cliPath, "--loop", "2", "--no-css", src], { encoding: "utf8" });
  assert.equal(quietLoop.stdout, "", "cli: --loop --no-css prints no CSS");
  assert.match(quietLoop.stderr, /2 compiles/, "cli: … but still reports throughput");
  for (const [args, wanted] of [
    [[`${src}:${join(dir, "out.css")}`], "--loop compiles to stdout only"],
    [["-o", join(dir, "out.css"), src], "--loop compiles to stdout only"],
    [["--source-map", src], "--loop does not generate source maps"],
  ]) {
    const r = spawnSync(process.execPath, [cliPath, "--loop", "2", ...args], { encoding: "utf8" });
    assert.equal(r.status, EXIT_USAGE, `cli: --loop ${args.join(" ")} is rejected`);
    assert.ok(r.stderr.includes(wanted), `cli: --loop ${args.join(" ")} says "${wanted}"`);
  }
  console.log("ok: cli — --loop: warm pass, silent timing, stdout only");
}

// === Phase 3l: the CLI's engine choice and its worker pool ===
// The CLI picks the native addon when the platform package is installed and
// falls back to wasm, and it compiles jobs across worker threads. Both are
// invisible in the output BY DESIGN — which is exactly why they need a test
// that pins the output rather than the mechanism.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-engine-"));
  mkdirSync(join(dir, "src"), { recursive: true });
  // Enough jobs that the pool actually splits them, and varied enough that a
  // shared-state bug would show up as crossed output.
  const expected = new Map();
  for (let i = 0; i < 24; i++) {
    writeFileSync(join(dir, "src", `s${i}.scss`), `.s${i}{a: ${i} + 1; b: "x${i}"}\n`);
    expected.set(`s${i}.css`, `.s${i}{a:${i + 1};b:"x${i}"}`);
  }
  // The engine variables are CLEARED and only what a case asks for is put
  // back. Inheriting them would turn the unforced runs into forced ones: an
  // exported `SASSO_ENGINE=wasm` makes the "default jobs" case test the
  // override, and `SASSO_ENGINE=native` makes the fallback case fail instead
  // of exercising the fallback. Both are supported things to have in a shell.
  const engineEnv = (env) => {
    const base = { ...process.env };
    delete base.SASSO_ENGINE;
    delete base.SASSO_NATIVE_BINARY;
    return { ...base, ...env };
  };
  const compileAll = (out, extra, env) => {
    const args = [cliPath, "--no-source-map", "--style=compressed", ...extra];
    for (const [name] of expected) args.push(`${join(dir, "src", name.replace(".css", ".scss"))}:${join(out, name)}`);
    return spawnSync(process.execPath, args, { encoding: "utf8", env: engineEnv(env), timeout: 60000 });
  };
  const check = (label, out, r) => {
    assert.equal(r.status, 0, `cli: ${label} compiles (stderr: ${r.stderr})`);
    for (const [name, css] of expected) {
      assert.equal(readFileSync(join(out, name), "utf8").trim(), css, `cli: ${label} — ${name} is its own output`);
    }
  };

  const seq = join(dir, "seq");
  check("-j 1", seq, compileAll(seq, ["-j", "1"], {}));
  const par = join(dir, "par");
  check("-j 4 (worker pool)", par, compileAll(par, ["-j", "4"], {}));
  const def = join(dir, "def");
  check("default jobs", def, compileAll(def, [], {}));

  // Both engines, forced, must agree with each other byte for byte.
  const wasm = join(dir, "wasm");
  check("SASSO_ENGINE=wasm", wasm, compileAll(wasm, [], { SASSO_ENGINE: "wasm" }));
  const native = join(dir, "native");
  const nativeRun = compileAll(native, [], { SASSO_ENGINE: "native" });
  if (nativeRun.status === 0) {
    check("SASSO_ENGINE=native", native, nativeRun);
    for (const [name] of expected) {
      assert.equal(
        readFileSync(join(wasm, name), "utf8"),
        readFileSync(join(native, name), "utf8"),
        `cli: the two engines agree on ${name}`,
      );
    }
  } else {
    // No prebuild for this platform: the CLI must still say so clearly rather
    // than falling back silently when the engine was demanded by name.
    assert.match(nativeRun.stderr, /SASSO_ENGINE=native/, "cli: a demanded engine that is missing says so");
  }
  // The same path, forced on EVERY platform: `SASSO_NATIVE_BINARY` is
  // native.mjs's own override, so pointing it at nothing makes the addon
  // unloadable here too. A DEMANDED engine must fail loudly; the default falls
  // back and compiles, and says on stderr that it did (see below).
  const demanded = compileAll(join(dir, "nope"), [], {
    SASSO_ENGINE: "native",
    SASSO_NATIVE_BINARY: join(dir, "no-such-addon.node"),
  });
  assert.equal(demanded.status, EXIT_USAGE, "cli: SASSO_ENGINE=native with an unloadable addon exits 64");
  assert.match(demanded.stderr, /SASSO_ENGINE=native/, "cli: … naming the engine that was demanded");
  const fellBack = join(dir, "fallback");
  check("the default engine falls back to wasm", fellBack, compileAll(fellBack, [], {
    SASSO_NATIVE_BINARY: join(dir, "no-such-addon.node"),
  }));

  // Which engine a run used was completely unobservable: the fallback above
  // costs roughly half the throughput and printed nothing, so "am I on wasm?"
  // was answerable only by bisecting an install (momiji-rs/sasso#24). Two
  // surfaces, tested here against the SAME table native.mjs resolves from, so
  // a new prebuilt target cannot make the CLI's idea of "expected" stale.
  {
    const { nativePackage, platformKey } = await import("./npm/_addon.mjs");
    const key = platformKey();
    const prebuilt = nativePackage();
    const blind = join(dir, "no-such-addon.node");
    const engineOf = (env) =>
      spawnSync(process.execPath, [cliPath, "--engine"], { encoding: "utf8", env: engineEnv(env), timeout: 20000 });

    // The report names the engine, why it is that one, and this platform.
    const def = engineOf({});
    assert.equal(def.status, 0, `cli: --engine reports (stderr: ${def.stderr})`);
    assert.match(def.stdout, /^engine: +(native \(Node addon\)|wasm \(speed build\)) — /m, "cli: --engine names the engine");
    assert.match(def.stdout, new RegExp(`^platform: +${key}( |$)`, "m"), "cli: … and the platform key it decided from");
    assert.match(def.stdout, /^sasso: +\d+\.\d+\.\d+/m, "cli: … and the package version");

    // A forced engine reports as forced rather than as a default or a fallback:
    // the distinction is the whole point when a CI pipeline sets the variable.
    const forced = engineOf({ SASSO_ENGINE: "wasm" });
    assert.match(forced.stdout, /^engine: +wasm .*SASSO_ENGINE=wasm/m, "cli: --engine says when the engine was forced");
    assert.doesNotMatch(forced.stdout, /FELL BACK/, "cli: … and an asked-for engine is not a fallback");

    // The unloadable-addon case, which is the one worth reporting.
    const broken = engineOf({ SASSO_NATIVE_BINARY: blind });
    assert.equal(broken.status, 0, "cli: --engine reports a fallback rather than failing");
    assert.match(broken.stdout, /^engine: +wasm /m, "cli: … as wasm");
    if (prebuilt) {
      assert.match(broken.stdout, /FELL BACK/, "cli: … calling it a fallback where a prebuild exists");
      assert.match(broken.stdout, new RegExp(`^platform: .*${prebuilt}`, "m"), "cli: … naming the addon package");
      assert.match(broken.stdout, /^addon: +did not load: /m, "cli: … and why the addon did not load");
      // One line, however deep Node's require stack was: a pasteable report.
      assert.equal(
        broken.stdout.split("\n").filter((l) => l.startsWith("addon:")).length,
        1,
        "cli: … on one line",
      );
    } else {
      assert.match(broken.stdout, /no addon is prebuilt/, "cli: … the expected engine where none is prebuilt");
    }

    // And a DEMANDED engine still fails instead of reporting, even here.
    const demandedReport = engineOf({ SASSO_ENGINE: "native", SASSO_NATIVE_BINARY: blind });
    assert.equal(demandedReport.status, EXIT_USAGE, "cli: --engine does not paper over SASSO_ENGINE=native failing");

    // Surface two: a compile that fell back says so on stderr, ONCE — every
    // worker loads its own engine, and one warning per core would bury the
    // output. Only where a prebuild exists: on musl or Windows wasm is the
    // supported engine, and a warning nobody can act on is noise.
    const warned = compileAll(join(dir, "loud"), ["-j", "4"], { SASSO_NATIVE_BINARY: blind });
    assert.equal(warned.status, 0, `cli: the fallback still compiles (stderr: ${warned.stderr})`);
    const hits = warned.stderr.split("\n").filter((l) => l.includes("did not load")).length;
    if (prebuilt) {
      assert.equal(hits, 1, `cli: the wasm fallback warns exactly once (stderr: ${warned.stderr})`);
      assert.match(warned.stderr, /roughly half the throughput/, "cli: … saying what it costs");
      assert.match(warned.stderr, /--engine|SASSO_ENGINE=wasm/, "cli: … and how to diagnose or accept it");
    } else {
      assert.equal(hits, 0, "cli: the expected engine does not warn");
    }
    // An engine the caller ASKED for is never news, prebuilt addon or not.
    const asked = compileAll(join(dir, "quiet"), [], { SASSO_ENGINE: "wasm", SASSO_NATIVE_BINARY: blind });
    assert.equal(asked.status, 0, `cli: SASSO_ENGINE=wasm compiles (stderr: ${asked.stderr})`);
    assert.equal(asked.stderr, "", "cli: … silently, because wasm was the request");

    // And `--quiet` silences it, like any other warning: the flag's contract is
    // that stderr stays empty, and this CLI keeps it to the letter. Pinned here
    // as well as by the @warn tests above, because a fallback only happens where
    // no addon is installed — an environment the machine writing the code
    // usually is not, which is exactly how this reached CI as a surprise once.
    const hushed = compileAll(join(dir, "hushed"), ["-q"], { SASSO_NATIVE_BINARY: blind });
    assert.equal(hushed.status, 0, `cli: --quiet compiles (stderr: ${hushed.stderr})`);
    assert.equal(hushed.stderr, "", "cli: --quiet silences the fallback warning too");
    // Which loses no observability: asking directly still answers under -q.
    const askedQuiet = spawnSync(process.execPath, [cliPath, "--engine", "-q"], {
      encoding: "utf8",
      env: engineEnv({ SASSO_NATIVE_BINARY: blind }),
      timeout: 20000,
    });
    assert.equal(askedQuiet.status, 0, `cli: --engine under -q (stderr: ${askedQuiet.stderr})`);
    assert.match(askedQuiet.stdout, /^engine: +wasm /m, "cli: --engine reports even when warnings are off");
  }

  // `--help` and `--version` answer from the package alone, so they must work
  // where no engine can be loaded at all — a metadata question must not need a
  // compiler.
  {
    const blind = { ...process.env, SASSO_ENGINE: "native", SASSO_NATIVE_BINARY: join(dir, "no-such-addon.node") };
    const pkg = JSON.parse(readFileSync(new URL("./npm/package.json", import.meta.url), "utf8"));
    const v = spawnSync(process.execPath, [cliPath, "--version"], { encoding: "utf8", env: blind, timeout: 20000 });
    assert.equal(v.status, 0, `cli: --version without a loadable engine (stderr: ${v.stderr})`);
    assert.equal(v.stdout.trim(), pkg.version, "cli: … and it is still the package's version");
    const h = spawnSync(process.execPath, [cliPath, "--help"], { encoding: "utf8", env: blind, timeout: 20000 });
    assert.equal(h.status, 0, `cli: --help without a loadable engine (stderr: ${h.stderr})`);
    // The help prints the negatable spelling, `--[no-]stop-on-error` — the
    // bare flag name matches nothing (this assertion caught itself).
    assert.match(h.stdout, /--\[no-\]stop-on-error/, "cli: … and it is the real help text");
    // And it describes what the flag does now that files run concurrently:
    // the ones already running finish. dart's own wording says exactly that,
    // so use dart's (measured from 1.104.1's --help, 2026-09-17).
    assert.match(
      h.stdout,
      /Don't compile more files once an error is\s+encountered\./,
      "cli: … and --stop-on-error is described as dart describes it",
    );
  }

  // With no output file the CSS goes to the terminal the warnings are on, so
  // the order between them is what the user sees under `2>&1`: dart and the
  // native binary both print the warning during the compile, ahead of the CSS
  // (measured 2026-09-17). Buffering a job's diagnostics must not reverse it.
  //
  // Both streams go to ONE file descriptor — the same thing `2>&1` does — so
  // this reads the real interleaving. Reading two pipes and concatenating them
  // would order the streams by hand and could never fail.
  {
    const sodir = join(dir, "stdout-order");
    mkdirSync(sodir, { recursive: true });
    const src = join(sodir, "warns.scss");
    writeFileSync(src, `@warn "before-the-css";\n.a{x:1}\n`);
    const merged = join(sodir, "merged.log");
    const fd = openSync(merged, "w");
    const r = spawnSync(process.execPath, [cliPath, "--style=compressed", "--no-source-map", src], {
      stdio: ["ignore", fd, fd],
      timeout: 20000,
    });
    closeSync(fd);
    const text = readFileSync(merged, "utf8");
    assert.equal(r.status, 0, `cli: a stdout job with a warning (output: ${text})`);
    assert.ok(text.includes("before-the-css") && text.includes(".a{x:1}"), `cli: both reached the terminal (${text})`);
    assert.ok(
      text.indexOf("before-the-css") < text.indexOf(".a{x:1}"),
      `cli: a stdout job's warning is written before its CSS (got: ${text})`,
    );
  }

  // The same job, but it FAILS after warning. Three things now share the
  // one descriptor, and dart puts them in this order (measured against
  // 1.104.1, one file that warns then fails, `2>&1`):
  //
  //   dart    warn -> css -> error
  //   binary  warn -> error -> css   (#160: the binary is the odd one)
  //
  // The success path above flushes a job's diagnostics before its CSS;
  // the failure path has to flush only the WARNINGS, because the error
  // belongs after the stylesheet. Flushing the whole block instead is
  // the plausible fix that quietly adopts the binary's order.
  {
    const fodir = join(dir, "stdout-order-fail");
    mkdirSync(fodir, { recursive: true });
    const src = join(fodir, "warns-then-fails.scss");
    writeFileSync(src, `@warn "said-during-the-compile";\n.a { width: 1px + 1em; }\n`);
    const merged = join(fodir, "merged.log");
    const fd = openSync(merged, "w");
    const r = spawnSync(process.execPath, [cliPath, "--no-source-map", "--error-css", src], {
      stdio: ["ignore", fd, fd],
      timeout: 20000,
    });
    closeSync(fd);
    const text = readFileSync(merged, "utf8");
    assert.notEqual(r.status, 0, `cli: the job failed (output: ${text})`);
    const atWarn = text.indexOf("said-during-the-compile");
    const atCss = text.indexOf("/* Error:");
    const atError = text.search(/^Error: /m);
    assert.ok(atWarn >= 0 && atCss >= 0 && atError >= 0, `cli: all three reached the terminal (${text})`);
    assert.ok(atWarn < atCss, `cli: the warning comes before the error stylesheet (got: ${text})`);
    assert.ok(
      atCss < atError,
      `cli: … and the stylesheet before the diagnostic, as dart does and the binary does not (got: ${text})`,
    );
  }

  // The headline of the engine work is that the DEFAULT picks the addon. No
  // output test can see that — the two engines are byte-identical on purpose,
  // which is the point — so the only honest observable is throughput, and
  // `--loop` reports it per compile with process start-up and file I/O already
  // out of the way.
  //
  // Measured 2026-09-17 on one 300-rule stylesheet, three runs each:
  // default 0.362-0.376 ms/compile, native 0.374-0.385, wasm 1.403-1.458. The
  // default tracks native and wasm is ~3.9x slower, so the 0.7 threshold below
  // sits about 5x away from both sides. A regression that always loaded
  // `sasso.speed.mjs` would land at the wasm number and fail.
  {
    const ldir = join(dir, "engine-speed");
    mkdirSync(ldir, { recursive: true });
    const big = join(ldir, "big.scss");
    writeFileSync(
      big,
      `@use "sass:math";\n@for $i from 1 through 300 { .c#{$i} { width: math.div($i,3)*1px; color: rgba(0,0,0,math.div($i,100)) } }\n`,
    );
    // `engineEnv` for the same reason as above: inheriting `SASSO_ENGINE=wasm`
    // would make the "default" run measure wasm and fail the comparison below.
    // `undefined` means ONE thing: this platform has no prebuilt addon, which
    // `loadEngine` reports by name. Any other failure is a failure — treating
    // it as "no addon" would skip the default-engine assertions below and let
    // the guard pass while the thing it guards is broken.
    const perCompile = (env) => {
      let best = Infinity;
      for (let k = 0; k < 3; k++) {
        const r = spawnSync(process.execPath, [cliPath, "--loop", "60", "--no-css", big], {
          encoding: "utf8",
          env: engineEnv(env),
          timeout: 60000,
        });
        if (r.status !== 0) {
          assert.match(
            r.stderr,
            /SASSO_ENGINE=native but the addon is unavailable/,
            `cli: --loop failed for a reason other than a missing addon (status ${r.status}: ${r.stderr})`,
          );
          return undefined;
        }
        const m = /=> ([\d.]+) ms\/compile/.exec(r.stderr);
        assert.ok(m, `cli: --loop reports a per-compile time (stderr: ${r.stderr})`);
        best = Math.min(best, Number(m[1]));
      }
      return best;
    };

    const native = perCompile({ SASSO_ENGINE: "native" });
    if (native === undefined) {
      // No prebuild for this platform: there is no addon to prefer, and the
      // "demanded engine is missing" path above already covers saying so.
      console.log("  (no native addon here — default-engine preference not checked)");
    } else {
      const wasm = perCompile({ SASSO_ENGINE: "wasm" });
      const dflt = perCompile({});
      assert.ok(wasm !== undefined && dflt !== undefined, "cli: --loop runs on both engines");
      assert.ok(
        native < wasm * 0.7,
        `cli: the addon is the faster engine here (native ${native} ms, wasm ${wasm} ms) — otherwise this test proves nothing`,
      );
      assert.ok(
        dflt < wasm * 0.7,
        `cli: the DEFAULT engine is the addon, not wasm (default ${dflt} ms, native ${native} ms, wasm ${wasm} ms)`,
      );
    }
  }

  // `-j` must actually run jobs AT THE SAME TIME. Correct output cannot show
  // that, and neither can the "exactly once" guard below — a sequential run
  // satisfies both — so a regression that ignored `-j` and kept the batch in
  // this thread would pass the whole suite.
  //
  // The observable is WRITE ORDER, not a stopwatch: make the first job the
  // slow one and the rest trivial. In order, its output is written first; with
  // workers pulling from the shared index, the others overtake it and it is
  // written last. Measured 2026-09-17, three runs each: `-j 1` wrote
  // `0 1 2 3 4 5 6 7` every time, `-j 4` ended `… 0` every time.
  {
    const cdir = join(dir, "concurrent");
    mkdirSync(cdir, { recursive: true });
    writeFileSync(
      join(cdir, "j0.scss"),
      `@use "sass:math";\n@for $i from 1 through 30000 { .slow-#{$i} { width: math.div($i,3)*1px } }\n`,
    );
    for (let i = 1; i < 8; i++) writeFileSync(join(cdir, `j${i}.scss`), `.j${i}{a:${i}}\n`);
    const writeTimes = (jobs) => {
      for (let i = 0; i < 8; i++) rmSync(join(cdir, `j${i}.css`), { force: true });
      const args = [cliPath, "--no-source-map", "--style=compressed", "-j", String(jobs)];
      for (let i = 0; i < 8; i++) args.push(`${join(cdir, `j${i}.scss`)}:${join(cdir, `j${i}.css`)}`);
      const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
      assert.equal(r.status, 0, `cli: the -j ${jobs} run compiles (stderr: ${r.stderr})`);
      const times = [];
      for (let i = 0; i < 8; i++) times.push(statSync(join(cdir, `j${i}.css`)).mtimeMs);
      return times;
    };

    const seqTimes = writeTimes(1);
    if (!(seqTimes[0] < seqTimes[7])) {
      // A filesystem whose timestamps are too coarse to separate two writes
      // milliseconds apart cannot answer this question either way.
      console.log("  (file timestamps too coarse to order writes — concurrency not checked)");
    } else {
      for (let attempt = 0; attempt < 3; attempt++) {
        const par = writeTimes(4);
        const last = par.indexOf(Math.max(...par));
        assert.equal(
          last,
          0,
          `cli: -j 4 runs jobs at the same time — the slow FIRST job finishes last (attempt ${attempt}, write times ${par.map((t) => Math.round(t - Math.min(...par))).join(",")})`,
        );
      }
    }
  }

  // `a.scss:a.scss` writes over its own input — dart compiles it and leaves
  // the CSS there (exit 0, measured 2026-09-17, as do both sasso CLIs). It
  // reads before it writes inside ONE job, so there is no order between
  // threads to get wrong and it must not serialize the batch. Same write-order
  // observable as above: the slow first job still has to finish last.
  {
    const sdir = join(dir, "self-write");
    mkdirSync(sdir, { recursive: true });
    for (let attempt = 0; attempt < 3; attempt++) {
      writeFileSync(
        join(sdir, "j0.scss"),
        `@use "sass:math";\n@for $i from 1 through 30000 { .slow-#{$i} { width: math.div($i,3)*1px } }\n`,
      );
      for (let i = 1; i < 8; i++) writeFileSync(join(sdir, `j${i}.scss`), `.j${i}{a:${i}}\n`);
      writeFileSync(join(sdir, "self.scss"), `$c: #2a7ae2;\n.self{color: $c}\n`);
      for (let i = 0; i < 8; i++) rmSync(join(sdir, `j${i}.css`), { force: true });
      const args = [cliPath, "--no-source-map", "--style=compressed", "-j", "4", `${join(sdir, "self.scss")}:${join(sdir, "self.scss")}`];
      for (let i = 0; i < 8; i++) args.push(`${join(sdir, `j${i}.scss`)}:${join(sdir, `j${i}.css`)}`);
      const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
      assert.equal(r.status, 0, `cli: a self-writing job compiles (stderr: ${r.stderr})`);
      assert.equal(
        readFileSync(join(sdir, "self.scss"), "utf8").trim(),
        ".self{color:#2a7ae2}",
        `cli: the self-writing job replaced its own file (attempt ${attempt})`,
      );
      const times = [];
      for (let i = 0; i < 8; i++) times.push(statSync(join(sdir, `j${i}.css`)).mtimeMs);
      assert.equal(
        times.indexOf(Math.max(...times)),
        0,
        `cli: … and the rest of the batch kept the pool (attempt ${attempt})`,
      );
    }
  }

  // `package.json`'s `files` is a WHITELIST: a module the CLI imports but the
  // list omits is missing from the published tarball, and `npx sasso` dies on
  // start with a resolution error that no test in this repo would see, because
  // every test runs against the working tree where the file is present.
  // Adding `_jobs.mjs` nearly shipped exactly that.
  {
    const pkgDir = new URL("./npm/", import.meta.url);
    const pkg = JSON.parse(readFileSync(new URL("package.json", pkgDir), "utf8"));
    const shipped = new Set(pkg.files);

    // The roots come from the manifest rather than a list kept by hand, so a
    // new export subpath is covered the day it is added: every `./…` the
    // manifest points at is a file the installed package must contain.
    const roots = new Set();
    const collect = (node) => {
      if (typeof node === "string") {
        if (node.startsWith("./")) roots.add(node.slice(2));
      } else if (node && typeof node === "object") {
        for (const value of Object.values(node)) collect(value);
      }
    };
    for (const field of ["bin", "main", "module", "types", "exports"]) collect(pkg[field]);
    assert.ok(roots.has("cli.mjs") && roots.size >= 5, `packaging: found only ${[...roots]}`);

    // `from "./x"` rather than a whole import statement: an import clause may
    // span lines, and a matcher that stops at the first newline silently skips
    // those — which is how `_importer.mjs`, reached only through the multiline
    // imports in `_loader.mjs` and `native.mjs`, went unchecked here.
    //
    // `gap` is whatever may sit between the keyword and the specifier:
    // whitespace, and comments, which are legal there and carry meaning to
    // bundlers (`import(/* webpackChunkName: "x" */ "./dep.mjs")`).
    //
    // These run over raw source and track no lexical state, so import-shaped
    // text inside a string or a comment matches too: `const s = 'from
    // \"./x.mjs\"'` looks exactly like an import from here. That is a known
    // limitation and a deliberate one.
    //
    // The two ways to be wrong are not equally bad. Matching text that is not
    // an import is a FALSE POSITIVE: the guard fails, names the file and the
    // specifier, and whoever wrote that string sees immediately what happened.
    // Missing a real import is a FALSE NEGATIVE: the suite stays green and a
    // package that cannot start is published — which is the failure this guard
    // exists to catch, and which it has already let through twice.
    //
    // A tokenizer or an AST walk would remove the false positives and buy a
    // new way to produce false negatives, because it has to know where strings
    // and regex literals are (`/[\"']/` is a regex, not the start of a string)
    // and it fails silently when it does not. So: loud over silent. No file in
    // the package contains such text today, and the case below pins the
    // behaviour so a later reader does not quietly trade it the other way.
    const gap = String.raw`(?:\s|/\*[\s\S]*?\*/|//[^\n]*\n)*`;
    // `./dep.mjs` and `../dep.mjs` both. `${` is left to the matcher loop
    // rather than excluded here, because whether it interpolates depends on
    // the delimiter: in a template it names no single file, in a quoted string
    // it is an ordinary (if unhinged) filename.
    const rel = String.raw`\.\.?/[^"'\`]+`;
    // The delimiter is captured and backreferenced so a template literal is
    // accepted on the same footing as a quote — `import(\`./x.mjs\`)` is a
    // perfectly ordinary dynamic import, and skipping it would be a silent
    // miss, which is the one failure mode this guard cannot afford.
    const q = String.raw`(?<q>["'\`])`;
    const spec = String.raw`(?<spec>${rel})\k<q>`;
    const statics = new RegExp(String.raw`\bfrom${gap}${q}${spec}`, "g");
    // `import ("./x")` — whitespace before the parenthesis is legal too, and
    // so is a second argument: `import("./x", { with: { type: "json" } })`.
    // The closing parenthesis is still required, so `import("./x" + suffix)`
    // stays unmatched — that path is not the module, and demanding it be
    // shipped would be a false failure.
    // What follows the specifier has to be the end of an argument — `)` or a
    // comma — which accepts `import("./x", { with: … })` and
    // `import("./x", makeOptions())` alike without this having to understand
    // the options expression, and still rejects `import("./x" + suffix)`,
    // whose path is not a module name.
    const dynamics = new RegExp(String.raw`\bimport${gap}\(${gap}${q}${spec}${gap}(?=[,)])`, "g");
    // `import "./x.mjs"` has no `from` to key on. Nothing in the package does
    // this today, which is exactly why the matcher has to exist: the first one
    // added would otherwise be invisible here.
    // A lookbehind rather than a list of allowed preceding characters: the
    // list missed `/* banner */import "./dep.mjs";` and a BOM-prefixed file,
    // both of which are legal and both of which would have gone unchecked.
    const sideEffects = new RegExp(String.raw`(?<![\w$.])import${gap}${q}${spec}`, "g");

    // A template literal with `${` in it names no single file, so there is
    // nothing to check; the same characters inside quotes are just a filename.
    const interpolated = (m) => m.groups.q === "`" && m.groups.spec.includes("${");

    // The matchers are the whole guard, so prove they see each shape rather
    // than trusting that they do. A matcher that silently matches nothing
    // satisfies every assertion below it.
    {
      const sample = [
        'import { a } from "./one.mjs";',
        'import {\n  b,\n  c,\n} from "./two.mjs";',
        'export * from "./three.mjs";',
        'const d = await import("./four.mjs");',
        'import "./five.mjs";',
        'const e = await import ("./six.mjs");',
        'const f = await import(/* webpackChunkName: "seven" */ "./seven.mjs");',
        'import /* webpackIgnore: true */ "./eight.mjs";',
        'export { z } from /* a note */ "./nine.mjs";',
        'const h = await import("./ten.mjs", { with: { type: "json" } });',
        'import { k } from "../eleven.mjs";',
        "const i = await import(`./twelve.mjs`);", // a template specifier
        '/* banner */import "./thirteen.mjs";', // a keyword straight after a comment
        "const j = await import(`./mod-${name}.mjs`);", // must NOT match: interpolated
        // …but the same characters in quotes are a filename, not a template.
        'import { p } from "./mod-${literal}.mjs";',
        // An options argument this matcher deliberately does not parse.
        'const q = await import("./fourteen.mjs", makeOptions());',
        'import fs from "node:fs";', // must NOT match: bare specifier
        'const url = "https://example.com/not-an-import.mjs";', // nor a URL
      ].join("\n");
      const found = new Set();
      for (const re of [statics, dynamics, sideEffects]) {
        for (const m of sample.matchAll(re)) {
          if (interpolated(m)) continue;
          found.add(m.groups.spec);
        }
      }
      // Known limitation, pinned on purpose: import-shaped text inside a
      // string matches, because nothing here tracks lexical state. It is a
      // loud failure rather than a silent miss — see the note above.
      const inAString = [...'const s = \'from "./in-a-string.mjs"\';'.matchAll(statics)];
      assert.equal(
        inAString.length,
        1,
        "packaging: the string case is a known false positive; if this ever stops matching, " +
          "make sure it stopped by tracking lexical state and not by missing imports",
      );

      assert.deepEqual(
        [...found].sort(),
        [
          "../eleven.mjs",
          "./eight.mjs",
          "./five.mjs",
          "./four.mjs",
          "./fourteen.mjs",
          "./mod-${literal}.mjs",
          "./nine.mjs",
          "./one.mjs",
          "./seven.mjs",
          "./six.mjs",
          "./ten.mjs",
          "./thirteen.mjs",
          "./three.mjs",
          "./twelve.mjs",
          "./two.mjs",
        ],
        "packaging: the import matchers miss a shape the package may legally use",
      );
    }

    const resolveFrom = (importer, spec) => {
      const parts = importer.includes("/") ? importer.slice(0, importer.lastIndexOf("/")).split("/") : [];
      for (const segment of spec.split("/")) {
        if (segment === "" || segment === ".") continue;
        if (segment === "..") {
          // Climbing past the package root resolves outside the tarball
          // entirely. Popping an empty path would quietly turn
          // `cli.mjs` + `../sasso.mjs` into `sasso.mjs`, which IS shipped, so
          // the guard would pass on an import Node resolves somewhere else.
          assert.ok(parts.length > 0, `packaging: ${importer} imports ${spec}, which escapes the package`);
          parts.pop();
        } else parts.push(segment);
      }
      return parts.join("/");
    };
    // Pinned directly, because the package is flat today and no real import
    // exercises these: a branch nothing can reach is a branch nothing holds
    // honest, and this one decides which file the guard checks.
    assert.equal(resolveFrom("cli.mjs", "./_jobs.mjs"), "_jobs.mjs");
    assert.equal(resolveFrom("sub/entry.mjs", "./dep.mjs"), "sub/dep.mjs");
    assert.equal(resolveFrom("sub/entry.mjs", "../dep.mjs"), "dep.mjs");
    assert.equal(resolveFrom("a/b/entry.mjs", "../c/dep.mjs"), "a/c/dep.mjs");
    // Climbing out of the package must not resolve to a shipped basename:
    // `cli.mjs` + `../sasso.mjs` is not `sasso.mjs`, it is outside the tarball.
    assert.throws(
      () => resolveFrom("cli.mjs", "../sasso.mjs"),
      /escapes the package/,
      "packaging: an import above the package root is rejected, not flattened",
    );

    const seen = new Set();
    const queue = [...roots];
    let checked = 0;
    while (queue.length) {
      const name = queue.pop();
      if (seen.has(name)) continue;
      seen.add(name);
      assert.ok(
        shipped.has(name),
        `packaging: the package points at ./${name}, which package.json's "files" does not ship`,
      );
      let text;
      try {
        text = readFileSync(new URL(name, pkgDir), "utf8");
      } catch {
        // Listing a file in `files` does not make it exist. A `.wasm` is
        // absent until something builds it, so an unreadable one is expected
        // here — but an unreadable module is a package that cannot start, and
        // swallowing that is how this guard would pass on a broken tree.
        assert.ok(
          !/\.(mjs|js|cjs|d\.ts)$/.test(name),
          `packaging: ${name} is listed in "files" but cannot be read`,
        );
        continue;
      }
      for (const re of [statics, dynamics, sideEffects]) {
        for (const m of text.matchAll(re)) {
          if (interpolated(m)) continue;
          // Inside a `.d.ts`, TypeScript resolves a `./x.js` specifier to
          // `x.d.ts` — following it literally would demand a file that neither
          // exists nor needs to, while skipping the declaration graph entirely.
          const found = m.groups.spec;
          const spec = name.endsWith(".d.ts") ? found.replace(/\.js$/, ".d.ts") : found;
          // `resolveFrom` handles `..` segments, so a parent-relative import
          // from a subdirectory lands on the right file rather than being
          // skipped for not starting with `./`.
          // Resolved against the importer's directory, not the package root.
          // Everything is flat today, so this changes nothing — but the day an
          // entry moves into a subdirectory, `./dep.mjs` stops meaning
          // `dep.mjs`, and a guard that looked at the root would check the
          // wrong file or silently find nothing.
          const dep = resolveFrom(name, spec);
          assert.ok(
            shipped.has(dep),
            `packaging: ${name} imports ./${dep}, which package.json's "files" does not ship`,
          );
          queue.push(dep);
          checked += 1;
        }
      }
    }
    // The traversal is only a guard if it actually reached the module graph;
    // a matcher that quietly matched nothing would pass every assertion above.
    assert.ok(seen.has("_importer.mjs"), "packaging: the walk never reached _importer.mjs");
    assert.ok(checked >= 10, `packaging: followed only ${checked} imports, the walk is not working`);
  }

  // The pool's default size is PHYSICAL cores, not SMT threads: a compile is
  // pure computation, so two hyperthreads on one core contend for the same
  // execution units instead of overlapping stalls. Measured on Linux / x86_64
  // with 8 cores and 16 threads, 138 Lichess stylesheets: `-j 8` beat
  // `-j 16` — 366 ms against 425 ms here, 208 against 235 through the native
  // binary — and the default taking the core count moved that corpus from
  // 444 ms to 364 ms. (Times, not percentages: "faster by" reads differently
  // depending on which of the two you divide by.)
  //
  // The host's own topology cannot be asserted, so the detector is fed
  // synthetic `/proc/cpuinfo` text instead — the shapes that matter are an SMT
  // machine, a dual-socket one (where `core id` repeats per socket), and the
  // containers that publish no topology at all.
  {
    const jobs = await import("./npm/_jobs.mjs");
    const logical = jobs.logicalCpus();

    const smt = Array.from({ length: 8 }, (_v, i) =>
      `processor\t: ${i}\nphysical id\t: 0\ncore id\t: ${i >> 1}\n`,
    ).join("\n");
    assert.equal(jobs.physicalCoresFromCpuinfo(smt), 4, "cli: 8 threads on 4 cores reads as 4");

    // Two sockets, four cores each: `core id` 0-3 appears twice and must not
    // collapse into four.
    const dual = [];
    for (const pkg of [0, 1]) {
      for (let c = 0; c < 4; c++) dual.push(`processor\t: ${pkg * 4 + c}\nphysical id\t: ${pkg}\ncore id\t: ${c}\n`);
    }
    assert.equal(jobs.physicalCoresFromCpuinfo(dual.join("\n")), 8, "cli: two sockets of 4 read as 8, not 4");

    assert.equal(
      jobs.physicalCoresFromCpuinfo("processor\t: 0\nmodel name\t: Whatever\n"),
      undefined,
      "cli: no topology reported means no answer, not zero",
    );

    // A file that names the socket for some processors and not others must not
    // file the later ones under whichever socket happened to come before: two
    // sockets' worth of `core id: 0` are two cores, however incomplete the file.
    assert.equal(
      jobs.physicalCoresFromCpuinfo(
        "processor\t: 0\nphysical id\t: 0\ncore id\t: 0\n\nprocessor\t: 1\ncore id\t: 0\n",
      ),
      2,
      "cli: the socket resets at each processor record",
    );
    // Nothing promises `physical id` is printed before `core id`; two sockets
    // of two cores written the other way round are still four cores.
    {
      let text = "";
      for (const pkg of [0, 1]) {
        for (const core of [0, 1]) {
          text += `processor\t: 0\ncore id\t: ${core}\nphysical id\t: ${pkg}\n\n`;
        }
      }
      assert.equal(jobs.physicalCoresFromCpuinfo(text), 4, "cli: either field order reads the same");
    }

    // But a file that names no socket at all is still usable: every core lands
    // under one unnamed socket, which is what a single-socket VM reports.
    assert.equal(
      jobs.physicalCoresFromCpuinfo("processor\t: 0\ncore id\t: 0\n\nprocessor\t: 1\ncore id\t: 0\n"),
      1,
      "cli: no socket named at all is one socket, not a giving-up",
    );

    // A cgroup CPU *quota* is not an affinity mask: `docker run --cpus=2`
    // leaves the mask at the whole machine and writes `cpu.max` instead
    // (verified 2026-09-17 — the container reported `Cpus_allowed_list: 0-15`
    // and `cpu.max: 200000 100000`). Node 22 answers 2 there; 18 and 20 answer
    // 16, so this covers two current LTS lines and not only the ancient ones.
    assert.equal(jobs.quotaCpusFromCgroup({ v2: "200000 100000\n" }), 2, "cli: v2 quota");
    assert.equal(jobs.quotaCpusFromCgroup({ v2: "max 100000\n" }), undefined, "cli: v2 unlimited");
    assert.equal(jobs.quotaCpusFromCgroup({ v2: "150000 100000\n" }), 2, "cli: a fraction rounds up");
    assert.equal(
      jobs.quotaCpusFromCgroup({ v1Quota: "400000\n", v1Period: "100000\n" }),
      4,
      "cli: v1 quota",
    );
    assert.equal(
      jobs.quotaCpusFromCgroup({ v1Quota: "-1\n", v1Period: "100000\n" }),
      undefined,
      "cli: v1 -1 is no limit",
    );
    assert.equal(jobs.quotaCpusFromCgroup({}), undefined, "cli: no cgroup files, no answer");

    // cgroup v1 mounts the controller as `cpu` on some distributions and
    // `cpu,cpuacct` on others; a quota only in the second place still counts.
    const onlyCpuacct = (path) =>
      path === "/sys/fs/cgroup/cpu,cpuacct/cpu.cfs_quota_us"
        ? "400000\n"
        : path === "/sys/fs/cgroup/cpu,cpuacct/cpu.cfs_period_us"
          ? "100000\n"
          : undefined;
    assert.equal(
      jobs.tightestQuota(jobs.cgroupFiles(onlyCpuacct)),
      4,
      "cli: a v1 quota under cpu,cpuacct is found",
    );

    // The limit is not necessarily at the root. A systemd scope on a host puts
    // it on the process's own cgroup, where the root file does not even exist
    // — measured under `systemd-run -p CPUQuota=200%` on 2026-09-17:
    //
    //   /proc/self/cgroup   0::/user.slice/…/run-p166821.scope
    //   root cpu.max        unavailable
    //   own cgroup cpu.max  200000 100000
    //
    // Reading only the root answers "no limit" and starts the host's core
    // count, which is what this pins.
    const scope = "0::/user.slice/user-1000.slice/app.slice/run-p1.scope\n";
    const own = "/sys/fs/cgroup/user.slice/user-1000.slice/app.slice/run-p1.scope/cpu.max";
    const nested = (path) =>
      path === "/proc/self/cgroup" ? scope : path === own ? "200000 100000\n" : undefined;
    assert.equal(
      jobs.tightestQuota(jobs.cgroupFiles(nested)),
      2,
      "cli: a quota on this process's own cgroup, not the root, is found",
    );

    // A container with its own cgroup namespace reports `0::/`, and then the
    // root really is the answer — the shape verified against docker.
    const container = (path) =>
      path === "/proc/self/cgroup"
        ? "0::/\n"
        : path === "/sys/fs/cgroup/cpu.max"
          ? "200000 100000\n"
          : undefined;
    assert.equal(
      jobs.tightestQuota(jobs.cgroupFiles(container)),
      2,
      "cli: the container shape still resolves to the root file",
    );

    // An unreadable `/proc/self/cgroup` leaves the root as the only guess…
    {
      const files = jobs.cgroupQuotaFiles(undefined);
      assert.ok(files.v2.includes("/sys/fs/cgroup/cpu.max"), "cli: v2 root is guessed");
      assert.ok(
        files.v1.some((f) => f.quota === "/sys/fs/cgroup/cpu,cpuacct/cpu.cfs_quota_us"),
        "cli: v1 roots are guessed",
      );
    }
    // …but a file that WAS read and names no cpu hierarchy is an answer, not a
    // gap: this process is in no such hierarchy, and the root's limit belongs
    // to someone else.
    {
      const files = jobs.cgroupQuotaFiles("4:memory:/some/slice\n");
      assert.deepEqual(files.v2, [], "cli: no v2 line, no v2 probe");
      assert.deepEqual(files.v1, [], "cli: no cpu controller, no v1 probe");
    }
    // A v2 line names its own hierarchy, so the walk stays inside it.
    {
      const files = jobs.cgroupQuotaFiles("0::/a/b\n");
      assert.deepEqual(
        files.v2,
        ["/sys/fs/cgroup/a/b/cpu.max", "/sys/fs/cgroup/a/cpu.max", "/sys/fs/cgroup/cpu.max"],
        "cli: the v2 walk is the process's own path and its parents",
      );
      assert.deepEqual(files.v1, [], "cli: a v2-only process probes no v1 paths");
    }

    // A parent slice's limit applies to everything under it, so the tightest
    // along the path wins rather than the first one found.
    const parentTighter = (path) => {
      if (path === "/proc/self/cgroup") return scope;
      if (path === own) return "800000 100000\n"; // the leaf allows 8
      if (path === "/sys/fs/cgroup/user.slice/cpu.max") return "200000 100000\n"; // a parent allows 2
      return undefined;
    };
    assert.equal(
      jobs.tightestQuota(jobs.cgroupFiles(parentTighter)),
      2,
      "cli: the tightest limit along the hierarchy wins",
    );

    // `logicalCpus` has two branches and this suite runs on one Node, so the
    // `os` it asks is injectable. The fallback is not dead code: it is what
    // answers on Node 16 to 18.13, where `availableParallelism` does not exist
    // — and `os.cpus().length` is the HOST's count, which is the whole reason
    // the mask and quota are read separately.
    assert.equal(
      jobs.logicalCpus({ availableParallelism: () => 4, cpus: () => new Array(16) }),
      4,
      "cli: availableParallelism wins when it exists",
    );
    assert.equal(
      jobs.logicalCpus({ cpus: () => new Array(16) }),
      16,
      "cli: without it, the host's CPU count is the starting point",
    );

    // `Cpus_allowed_list` is the affinity mask this process actually has.
    assert.equal(jobs.allowedCpusFromStatus("Cpus_allowed_list:\t0-1,8-9\n"), 4, "cli: ranges and lists");
    assert.equal(jobs.allowedCpusFromStatus("Cpus_allowed_list:\t3\n"), 1, "cli: a single cpu");
    assert.equal(jobs.allowedCpusFromStatus("Name:\tnode\n"), undefined, "cli: absent means no answer");
    assert.equal(jobs.allowedCpusFromStatus("Cpus_allowed_list:\t9-3\n"), undefined, "cli: a backwards range");

    // …and the default that is built on it.
    const readFake = (text) => () => text;
    // These tests are about the topology, so the rest of the host is held
    // still: left real, they would read THIS machine's affinity mask and
    // cgroup, and a run inside a restricted container would fail assertions
    // that have nothing to do with what they are testing.
    const unrestricted = {
      readStatus: () => undefined,
      readCgroup: () => [],
    };
    assert.equal(
      jobs.defaultJobs({ platform: "linux", readCpuinfo: readFake(smt), ...unrestricted }),
      Math.min(4, logical),
      "cli: on Linux the default is the core count",
    );
    assert.equal(
      jobs.defaultJobs({ platform: "linux", readCpuinfo: () => undefined, ...unrestricted }),
      logical,
      "cli: an unreadable /proc/cpuinfo falls back to the kernel's count",
    );

    // `os.availableParallelism` only exists on Node >= 18.14, and the package
    // supports >= 16; below it `os.cpus().length` answers the HOST's count and
    // knows nothing of the affinity mask (16 against 4 under `taskset -c
    // 0,1,8,9`, measured 2026-09-17). `Cpus_allowed_list` is what makes the cap
    // hold on every supported Node, so it has to bind even when the reported
    // count is the whole machine.
    const eightCores = Array.from(
      { length: 16 },
      (_v, i) => `processor\t: ${i}\nphysical id\t: 0\ncore id\t: ${i >> 1}\n`,
    ).join("\n");
    assert.equal(
      jobs.defaultJobs({
        platform: "linux",
        readCpuinfo: readFake(eightCores),
        readStatus: readFake("Cpus_allowed_list:\t0-1,8-9\n"),
        readCgroup: () => [],
      }),
      Math.min(4, logical),
      "cli: the affinity mask caps the default even when the CPU count does not",
    );
    assert.equal(
      jobs.defaultJobs({
        platform: "linux",
        readCpuinfo: readFake(eightCores),
        readStatus: () => undefined,
        readCgroup: () => [],
      }),
      Math.min(8, logical),
      "cli: an unreadable /proc/self/status leaves the core count alone",
    );
    // The whole Node 16 shape, end to end and independent of this host: the
    // runtime reports the machine's 16, the process may use 4 of them, and the
    // topology says 8 physical cores. The mask has to win.
    assert.equal(
      jobs.defaultJobs({
        platform: "linux",
        reportedCpus: () => 16,
        readCpuinfo: readFake(eightCores),
        readStatus: readFake("Cpus_allowed_list:\t0-1,8-9\n"),
        readCgroup: () => [],
      }),
      4,
      "cli: on a Node without availableParallelism the mask still caps the default",
    );
    // …and the same with a quota instead of a mask.
    assert.equal(
      jobs.defaultJobs({
        platform: "linux",
        reportedCpus: () => 16,
        readCpuinfo: readFake(eightCores),
        readStatus: readFake("Cpus_allowed_list:\t0-15\n"),
        readCgroup: () => [{ v2: "200000 100000\n" }],
      }),
      2,
      "cli: on a Node without availableParallelism the quota still caps the default",
    );

    // The container shape that has no mask to find: quota only.
    assert.equal(
      jobs.defaultJobs({
        platform: "linux",
        readCpuinfo: readFake(eightCores),
        readStatus: readFake("Cpus_allowed_list:\t0-15\n"),
        readCgroup: () => [{ v2: "200000 100000\n" }],
      }),
      Math.min(2, logical),
      "cli: a cgroup quota caps the default even with the whole machine in the mask",
    );
    assert.equal(
      jobs.defaultJobs({ platform: "darwin", readCpuinfo: readFake(smt), ...unrestricted }),
      logical,
      "cli: off Linux the logical count stands — Apple silicon has no SMT",
    );
    // A cgroup- or taskset-restricted process sees fewer CPUs than the machine
    // has cores; the smaller number has to win.
    // Sized from the host: a fixed number would stop being "more cores than
    // this process may use" on a big enough machine, and the assertion would
    // then be testing the opposite of what it says.
    const many = Array.from(
      { length: logical + 8 },
      (_v, i) => `physical id\t: 0\ncore id\t: ${i}\n`,
    ).join("\n");
    assert.equal(
      jobs.defaultJobs({ platform: "linux", readCpuinfo: readFake(many), ...unrestricted }),
      logical,
      "cli: never more workers than the kernel offers this process",
    );
  }

  // Each job must run EXACTLY once. Correct output does not prove that — a pool
  // where every worker walks the whole list from 0 produces the same files,
  // just N times over — so make the repetition audible: one `@warn` per
  // stylesheet, counted on stderr.
  {
    const wdir = join(dir, "warn");
    mkdirSync(wdir, { recursive: true });
    const args = [cliPath, "--no-source-map", "--style=compressed", "-j", "4"];
    for (let i = 0; i < 12; i++) {
      writeFileSync(join(wdir, `w${i}.scss`), `@warn "once-${i}";\n.w${i}{a:1}\n`);
      args.push(`${join(wdir, `w${i}.scss`)}:${join(wdir, `w${i}.css`)}`);
    }
    const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
    assert.equal(r.status, 0, `cli: the warning run compiles (stderr: ${r.stderr})`);
    for (let i = 0; i < 12; i++) {
      const seen = (r.stderr.match(new RegExp(`once-${i}\\b`, "g")) || []).length;
      assert.equal(seen, 1, `cli: job w${i} ran exactly once (saw its @warn ${seen} times)`);
    }
  }

  // A `-` job reads the one stdin there is — and does not drag the other jobs
  // out of the pool with it.
  {
    const sdir = join(dir, "stdin");
    mkdirSync(sdir, { recursive: true });
    const args = [cliPath, "--no-source-map", "--style=compressed", "-j", "4", `-:${join(sdir, "from-stdin.css")}`];
    for (let i = 0; i < 6; i++) {
      writeFileSync(join(sdir, `f${i}.scss`), `.f${i}{a:${i}}\n`);
      args.push(`${join(sdir, `f${i}.scss`)}:${join(sdir, `f${i}.css`)}`);
    }
    // Not ASCII: standard input reaches the worker as shared BYTES, so the
    // content has the same round trip to get wrong as the job paths do.
    const stdin = `.stdin{content:"\u65e5\u672c\u8a9e \u{1f3a8} caf\u00e9";b:1}\n`;
    const r = spawnSync(process.execPath, args, { encoding: "utf8", input: stdin, timeout: 60000 });
    assert.equal(r.status, 0, `cli: a stdin job alongside file jobs (stderr: ${r.stderr})`);
    assert.equal(
      readFileSync(join(sdir, "from-stdin.css"), "utf8").trim(),
      stdin.trim(),
      "cli: the `-` job read stdin, byte for byte",
    );
    for (let i = 0; i < 6; i++) {
      assert.equal(readFileSync(join(sdir, `f${i}.css`), "utf8").trim(), `.f${i}{a:${i}}`, `cli: f${i} compiled too`);
    }
  }

  // Several sources naming one destination: dart compiles them all and the
  // LAST on the command line wins, the same file every run (1.104.1, measured
  // both orders). Run them in parallel and the winner is whoever finishes
  // last, so a collision has to serialize the batch.
  {
    const cdir = join(dir, "collide");
    mkdirSync(cdir, { recursive: true });
    for (const name of ["a", "b", "c"]) writeFileSync(join(cdir, `${name}.scss`), `.${name}{x:"${name}"}\n`);
    const target = join(cdir, "out.css");
    const order = (names) => [
      cliPath, "--no-source-map", "--style=compressed", "-j", "4",
      ...names.map((n) => `${join(cdir, `${n}.scss`)}:${target}`),
    ];
    for (let attempt = 0; attempt < 5; attempt++) {
      for (const names of [["a", "b", "c"], ["c", "b", "a"]]) {
        rmSync(target, { force: true });
        const r = spawnSync(process.execPath, order(names), { encoding: "utf8", timeout: 60000 });
        assert.equal(r.status, 0, `cli: colliding destinations compile (stderr: ${r.stderr})`);
        const last = names[names.length - 1];
        assert.equal(
          readFileSync(target, "utf8").trim(),
          `.${last}{x:"${last}"}`,
          `cli: the LAST source on the command line wins (${names.join(" ")}, attempt ${attempt})`,
        );
      }
    }
  }

  // Diagnostics belong to their job and print in COMMAND-LINE order, never in
  // completion order — which is what a dozen threads writing to one stderr
  // gives you. The first stylesheet is deliberately the slow one, so its
  // warning finishes LAST: an unordered run cannot pass by luck.
  //
  // (Order measured 2026-09-17 against the native binary, which reports each
  // job in input order at every `-j`. dart-sass prints every warning first and
  // its errors at the end; the native CLI has never done that and this does
  // not change it.)
  {
    const odir = join(dir, "order");
    mkdirSync(odir, { recursive: true });
    // The warning comes AFTER the slow loop, so in completion order it is the
    // last one written, not the first.
    writeFileSync(join(odir, "j0.scss"), `@for $i from 1 through 4000 { .slow-#{$i} { a: $i * 2 } }\n@warn "mark-0";\n`);
    for (let i = 1; i < 8; i++) writeFileSync(join(odir, `j${i}.scss`), `@warn "mark-${i}";\n.j${i}{a:${i}}\n`);
    // One failure in the middle: its Error takes the failing job's place in
    // the sequence, rather than being hoisted or trailed.
    writeFileSync(join(odir, "j4.scss"), `.j4{a:}\n`);
    const args = [cliPath, "--no-source-map", "--style=compressed", "-j", "4"];
    for (let i = 0; i < 8; i++) args.push(`${join(odir, `j${i}.scss`)}:${join(odir, `j${i}.css`)}`);

    for (let attempt = 0; attempt < 3; attempt++) {
      const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
      assert.equal(r.status, EXIT_COMPILE, "cli: the batch with one bad job exits 65");
      const seq = (r.stderr.match(/mark-\d|^Error: /gm) || []).map((m) => (m === "Error: " ? "E" : m));
      assert.deepEqual(
        seq,
        ["mark-0", "mark-1", "mark-2", "mark-3", "E", "mark-5", "mark-6", "mark-7"],
        `cli: diagnostics print in command-line order (attempt ${attempt})`,
      );
      // The block, not just the message: a warning carries its stack frame and
      // ends in a blank line, the shape dart prints.
      assert.match(r.stderr, /WARNING: mark-1\n\s+\S*j1\.scss 1:1\s+root stylesheet\n\n/, "cli: … as whole blocks");
    }
  }

  // The same collision through the sourcemap SIDECAR: `a.scss:out.css` writes
  // `out.css.map` too, which is exactly what `b.scss:out.css.map` writes. The
  // command-line order and the completion order are made to disagree — a.scss
  // is first and slow — so a run that ignores the sidecar writes a's map over
  // b's CSS (measured: dart and `-j 1` keep b's CSS, `-j 4` did not).
  {
    const mdir = join(dir, "sidecar");
    mkdirSync(mdir, { recursive: true });
    writeFileSync(join(mdir, "a.scss"), `@for $i from 1 through 4000 { .slow-#{$i}{a:$i} }\n.a{x:"a"}\n`);
    writeFileSync(join(mdir, "b.scss"), `.b{x:"b"}\n`);
    const target = join(mdir, "out.css.map");
    for (let attempt = 0; attempt < 3; attempt++) {
      rmSync(target, { force: true });
      rmSync(join(mdir, "out.css"), { force: true });
      const r = spawnSync(
        process.execPath,
        [cliPath, "--style=compressed", "-j", "4", `${join(mdir, "a.scss")}:${join(mdir, "out.css")}`, `${join(mdir, "b.scss")}:${target}`],
        { encoding: "utf8", timeout: 60000 },
      );
      assert.equal(r.status, 0, `cli: the sidecar collision compiles (stderr: ${r.stderr})`);
      assert.match(
        readFileSync(target, "utf8"),
        /\.b\{x:"b"\}/,
        `cli: the last job on the command line owns out.css.map, sidecar or not (attempt ${attempt})`,
      );
    }
  }

  // The job list reaches a worker as shared BYTES, decoded on claim, so a path
  // that is not ASCII has to survive the round trip — and a worker must get
  // the right job, not its neighbour's, when the byte lengths differ.
  {
    const udir = join(dir, "unicode");
    mkdirSync(udir, { recursive: true });
    const names = ["\u65e5\u672c\u8a9e", "caf\u00e9", "\u00f6\u00df\u00e9-\u00fc", "emoji-\u{1f3a8}", "plain"];
    const args = [cliPath, "--no-source-map", "--style=compressed", "-j", "4"];
    names.forEach((name, i) => {
      writeFileSync(join(udir, `${name}.scss`), `.n${i}{content:"${name}"}\n`);
      args.push(`${join(udir, `${name}.scss`)}:${join(udir, `${name}.css`)}`);
    });
    const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
    assert.equal(r.status, 0, `cli: non-ASCII paths compile in the pool (stderr: ${r.stderr})`);
    names.forEach((name, i) => {
      assert.equal(
        readFileSync(join(udir, `${name}.css`), "utf8").trim(),
        `.n${i}{content:"${name}"}`,
        `cli: ${name}.css holds its own output`,
      );
    });
  }

  // Under `--no-css` a repeated destination is not a collision: nothing is
  // written, so there is no last-writer to get right and the batch keeps its
  // parallelism. What must not change is the compiling and the reporting.
  {
    const ndir = join(dir, "nocss");
    mkdirSync(ndir, { recursive: true });
    const target = join(ndir, "out.css");
    const args = [cliPath, "--no-css", "--no-source-map", "-j", "4"];
    for (let i = 0; i < 6; i++) {
      writeFileSync(join(ndir, `n${i}.scss`), `@warn "nocss-${i}";\n.n${i}{a:${i}}\n`);
      args.push(`${join(ndir, `n${i}.scss`)}:${target}`);
    }
    const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
    assert.equal(r.status, 0, `cli: --no-css with a repeated destination (stderr: ${r.stderr})`);
    assert.ok(!existsSync(target), "cli: --no-css wrote nothing, collision or not");
    const seq = (r.stderr.match(/nocss-\d/g) || []);
    assert.deepEqual(
      seq,
      ["nocss-0", "nocss-1", "nocss-2", "nocss-3", "nocss-4", "nocss-5"],
      "cli: every job still ran, exactly once, reported in command-line order",
    );

    // …and that it KEPT the pool, which the assertions above cannot show: a
    // serialized run produces the same files (none) and the same warnings.
    // Nothing is written under `--no-css`, so write order is no help either.
    //
    // `--stop-on-error` is: run in order, a failing FIRST job stops the rest
    // before they warn; in the pool the others have already started and do
    // warn. Job 0 is slow, so the workers are certainly past their claim by
    // the time it fails. Measured 2026-09-17, five runs each: `-j 1` saw 0
    // warnings every time, `-j 4` saw 5.
    const cdir2 = join(dir, "nocss-conc");
    mkdirSync(cdir2, { recursive: true });
    writeFileSync(
      join(cdir2, "j0.scss"),
      `@for $i from 1 through 30000 { .slow-#{$i}{a:$i} }\n.bad{a: 1px + #fff}\n`,
    );
    for (let i = 1; i < 6; i++) writeFileSync(join(cdir2, `j${i}.scss`), `@warn "conc-${i}";\n.n${i}{a:${i}}\n`);
    const shared = join(cdir2, "out.css");
    const concArgs = (jobs) => {
      const a = [cliPath, "--no-css", "--no-source-map", "--stop-on-error", "-j", String(jobs)];
      for (let i = 0; i < 6; i++) a.push(`${join(cdir2, `j${i}.scss`)}:${shared}`);
      return a;
    };
    const warnCount = (jobs) => {
      const run = spawnSync(process.execPath, concArgs(jobs), { encoding: "utf8", timeout: 60000 });
      assert.notEqual(run.status, 0, `cli: the --no-css -j ${jobs} run fails on its first job`);
      return (run.stderr.match(/conc-\d/g) || []).length;
    };
    // The control: in order, nothing after the failure gets to warn. If this
    // ever stopped being true the comparison below would prove nothing.
    assert.equal(warnCount(1), 0, "cli: --stop-on-error at -j 1 stops the rest before they warn");
    for (let attempt = 0; attempt < 3; attempt++) {
      assert.ok(
        warnCount(4) > 0,
        `cli: a --no-css batch with one destination keeps the pool (attempt ${attempt})`,
      );
    }
  }

  // One job WRITES a path another job READS: `a.scss:b.scss b.scss:out.css`.
  // dart compiles a into b.scss and then b.scss into out.css, so out.css holds
  // a's output; the pool read whichever b.scss it found first. a.scss is the
  // slow one, so a run that does not serialize reads the ORIGINAL b.scss every
  // time (measured 2026-09-17: dart and `-j 1` say a, the pool said b).
  {
    const wdir = join(dir, "write-read");
    mkdirSync(wdir, { recursive: true });
    for (let attempt = 0; attempt < 3; attempt++) {
      writeFileSync(join(wdir, "a.scss"), `@for $i from 1 through 4000 { .slow-#{$i}{a:$i} }\n.from-a{x:1}\n`);
      writeFileSync(join(wdir, "b.scss"), `.original-b{y:2}\n`);
      rmSync(join(wdir, "out.css"), { force: true });
      const r = spawnSync(
        process.execPath,
        [cliPath, "--no-source-map", "--style=compressed", "-j", "4",
         `${join(wdir, "a.scss")}:${join(wdir, "b.scss")}`, `${join(wdir, "b.scss")}:${join(wdir, "out.css")}`],
        { encoding: "utf8", timeout: 60000 },
      );
      assert.equal(r.status, 0, `cli: write-then-read compiles (stderr: ${r.stderr})`);
      const out = readFileSync(join(wdir, "out.css"), "utf8");
      assert.match(out, /from-a/, `cli: the second job read what the first job wrote (attempt ${attempt})`);
      assert.doesNotMatch(out, /original-b/, `cli: … not the file as it was before the batch (attempt ${attempt})`);
    }
  }

  // Diagnostics have to survive the exit. `process.stderr.write` on a PIPE is
  // asynchronous and `process.exit` discards whatever has not reached the
  // kernel, so a batch that printed a lot and then exited non-zero lost the
  // tail of it (measured 2026-09-17: 374 of 400 warnings through a pipe, and
  // a 480 KB error cut to exactly 131072 bytes).
  //
  // The pipe is the point: to a FILE both paths were always whole, so a test
  // that redirects to a file proves nothing. `stdio: "pipe"` is what spawnSync
  // gives us, and the payload has to be bigger than the 64 KB pipe buffer or
  // the write finishes in one go and nothing can be lost.
  {
    const tdir = join(dir, "drain");
    mkdirSync(tdir, { recursive: true });
    const args = [cliPath, "--no-source-map", "--style=compressed"];
    // 400 x ~2 KB is several times the 64 KB pipe buffer. At 400 bytes each the
    // loss was intermittent (374 of 400 once in three runs); at 2 KB the
    // broken version came back with 31-54 of 400, every run.
    const padding = "x".repeat(2000);
    for (let i = 0; i < 400; i++) {
      writeFileSync(join(tdir, `w${i}.scss`), `@warn "mark-${i} ${padding}";\n.w${i}{a:1}\n`);
      args.push(`${join(tdir, `w${i}.scss`)}:${join(tdir, `w${i}.css`)}`);
    }
    // One failure at the end, so the run exits 1 right after the flush.
    writeFileSync(join(tdir, "bad.scss"), `.bad{a:}\n`);
    args.push(`${join(tdir, "bad.scss")}:${join(tdir, "bad.css")}`);
    const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 120000 });
    assert.equal(r.status, EXIT_COMPILE, "cli: the batch with one bad job exits 65");
    const seen = (r.stderr.match(/WARNING: mark-\d+/g) || []).length;
    assert.equal(seen, 400, `cli: every warning survived the non-zero exit through a pipe (saw ${seen})`);

    // The same for the single-error path, which exits from `fail` and cannot
    // wait for a stream to drain — its write has to be synchronous.
    const huge = join(tdir, "huge.scss");
    writeFileSync(huge, `.x{${"a:1;".repeat(60000)}b:}\n`);
    const one = spawnSync(process.execPath, [cliPath, "--no-source-map", huge], {
      encoding: "utf8",
      timeout: 120000,
      maxBuffer: 64 * 1024 * 1024,
    });
    assert.equal(one.status, EXIT_COMPILE, "cli: the huge broken stylesheet fails");
    assert.ok(
      one.stderr.length > 200_000,
      `cli: a diagnostic larger than the pipe buffer is not cut short (got ${one.stderr.length} bytes)`,
    );
    assert.match(one.stderr, /root stylesheet/, "cli: … and it ends with the stack frame, not mid-line");

    // The single-job paths do not go through the pool, so they have their own
    // copy of this hazard: the engine's logger writes a warning through the
    // asynchronous stream and `fail` then exits at once. Measured 2026-09-17,
    // a 1.2 MB warning followed by an evaluation error: `--stdin` gave 65584
    // bytes through a pipe against 1200070 to a file, `--loop` 65808 against
    // 1200469. The error must arrive, the warning must arrive WHOLE, and the
    // warning must come first.
    const warnThenFail = join(tdir, "warn-then-fail.scss");
    const bigWarning = "w".repeat(1_200_000);
    writeFileSync(warnThenFail, `@warn "kept ${bigWarning}";\n.bad{a: 1px + #fff}\n`);
    const direct = [
      ["--stdin", [cliPath, "--stdin", "--no-source-map"], readFileSync(warnThenFail, "utf8")],
      ["--loop", [cliPath, "--loop", "2", "--no-css", warnThenFail], undefined],
      // A lone positional compiles to stdout and reports through the pool's
      // path; kept here so all three single-job shapes are covered together.
      ["positional", [cliPath, "--no-source-map", warnThenFail], undefined],
    ];
    for (const [label, argv, input] of direct) {
      const d = spawnSync(process.execPath, argv, {
        encoding: "utf8",
        input,
        timeout: 120000,
        maxBuffer: 64 * 1024 * 1024,
      });
      assert.equal(d.status, EXIT_COMPILE, `cli: ${label} reports the evaluation error`);
      assert.match(d.stderr, /Undefined operation/, `cli: ${label} — the error reached stderr`);
      assert.ok(
        d.stderr.includes(`kept ${bigWarning}`),
        `cli: ${label} — the whole warning reached stderr, not the first 64 KB of it (got ${d.stderr.length} bytes)`,
      );
      assert.ok(
        d.stderr.indexOf("WARNING: kept") < d.stderr.indexOf("Undefined operation"),
        `cli: ${label} — the warning comes before the error that followed it`,
      );
    }
  }

  // Outputs conflict without matching: `a.scss:out` writes the FILE `out` while
  // `b.scss:out/sub.css` needs `out` to be a DIRECTORY, so on a fresh tree
  // whichever job runs first decides which one fails. dart writes the file and
  // then fails the nested job, the same way every run; the pool alternated
  // (measured 2026-09-17: four runs of six left a directory, two left a file).
  {
    const ndir = join(dir, "nested-out");
    for (let attempt = 0; attempt < 4; attempt++) {
      rmSync(ndir, { recursive: true, force: true });
      mkdirSync(ndir, { recursive: true });
      writeFileSync(join(ndir, "a.scss"), `@for $i from 1 through 4000 { .slow-#{$i}{a:$i} }\n.from-a{x:1}\n`);
      writeFileSync(join(ndir, "b.scss"), `.from-b{y:2}\n`);
      const r = spawnSync(
        process.execPath,
        [cliPath, "--no-source-map", "--style=compressed", "-j", "4",
         `${join(ndir, "a.scss")}:${join(ndir, "out")}`, `${join(ndir, "b.scss")}:${join(ndir, "out", "sub.css")}`],
        { encoding: "utf8", timeout: 60000 },
      );
      assert.notEqual(r.status, 0, `cli: the nested-output batch fails, as dart's does (attempt ${attempt})`);
      assert.ok(
        statSync(join(ndir, "out")).isFile(),
        `cli: the first job wrote the file and the nested one lost, as in dart (attempt ${attempt})`,
      );
      const out = readFileSync(join(ndir, "out"), "utf8");
      assert.match(out, /\.from-a\{x:1\}/, "cli: … and it is a's output");
      assert.doesNotMatch(out, /from-b/, "cli: … not b's");
    }
  }

  // The promise of the SHARED index — a heavy stylesheet must not leave other
  // workers idle — is not what "exactly once" checks: fixed contiguous slices
  // also run every job once and write every file correctly.
  //
  // Four heavy jobs first, eight trivial after, `-j 4`. Sharing the index,
  // every worker takes a heavy job, so no trivial output can be written before
  // the first heavy one finishes. Splitting the list into slices leaves two
  // workers holding only trivial jobs, which they write at once. Measured
  // 2026-09-17, five runs each: with the shared index the first trivial write
  // came 0-1 ms AFTER the first heavy one; with slices, 22-23 ms BEFORE it.
  {
    const bdir = join(dir, "balance");
    mkdirSync(bdir, { recursive: true });
    const HEAVY = 4;
    const TOTAL = 12;
    for (let i = 0; i < TOTAL; i++) {
      writeFileSync(
        join(bdir, `j${i}.scss`),
        i < HEAVY
          ? `@use "sass:math";\n@for $j from 1 through 20000 { .h${i}-#{$j} { width: math.div($j,3)*1px } }\n`
          : `.t${i}{a:${i}}\n`,
      );
    }
    for (let attempt = 0; attempt < 3; attempt++) {
      for (let i = 0; i < TOTAL; i++) rmSync(join(bdir, `j${i}.css`), { force: true });
      const args = [cliPath, "--no-source-map", "--style=compressed", "-j", "4"];
      for (let i = 0; i < TOTAL; i++) args.push(`${join(bdir, `j${i}.scss`)}:${join(bdir, `j${i}.css`)}`);
      const r = spawnSync(process.execPath, args, { encoding: "utf8", timeout: 60000 });
      assert.equal(r.status, 0, `cli: the load-balancing run compiles (stderr: ${r.stderr})`);
      const times = [];
      for (let i = 0; i < TOTAL; i++) times.push(statSync(join(bdir, `j${i}.css`)).mtimeMs);
      const firstHeavy = Math.min(...times.slice(0, HEAVY));
      const firstTrivial = Math.min(...times.slice(HEAVY));
      // `>=`, not `>`: with the shared index the two can land in the same
      // millisecond, and that is fine. What must not happen is a trivial
      // output appearing while every heavy job is still running.
      assert.ok(
        firstTrivial >= firstHeavy,
        `cli: no worker was left holding only cheap jobs (attempt ${attempt}, first trivial ${Math.round(
          firstTrivial - firstHeavy,
        )} ms before the first heavy one)`,
      );
    }
  }

  // A failure inside the pool is still reported and still exits non-zero.
  writeFileSync(join(dir, "src", "s7.scss"), ".s7{a:}\n");
  const broken = compileAll(join(dir, "broken"), ["-j", "4"], {});
  assert.equal(broken.status, EXIT_COMPILE, "cli: a job that fails in a worker exits 65");
  assert.match(broken.stderr, /Error: /, "cli: … and its diagnostic reaches stderr");
  console.log("ok: cli — engine selection (wasm/native agree) and the worker pool");
}

// === Phase 3m: handing the whole command line to the release binary ===
// The fastest engine this CLI can reach is not one: on 40 entry points the
// release binary takes 15.1 ms where this package needs 104.1 ms on the native
// addon and 48.2 ms handing the command line over (macOS/arm64, published
// artifacts, 2026-09-18). So when a `sasso` on PATH reports EXACTLY this
// package's version, `cli.mjs` execs it and ends with its exit code
// (momiji-rs/sasso#24 asked for this).
//
// None of that is visible in the CSS — the two front ends are byte-identical on
// purpose — so most of these cases run against STAND-IN binaries chosen for what
// they make observable: `echo` prints the argv it was handed, so the command line
// can be pinned exactly; `env` exits 127 on a command it cannot find, so the
// child's status can be told apart from this CLI's own exit 1 (#91); and a
// `#!/usr/bin/env node` script that is really this file is the `npm install -g
// sasso` shape, whose fork bomb is the reason the check reads magic bytes rather
// than trusting the name. A real binary, where this machine has one, then
// confirms the whole path end to end.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-deleg-"));
  const src = join(dir, "in.scss");
  writeFileSync(src, ".a{b: 1 + 2}\n");
  const CSS = ".a{b:3}";
  const pkgVersion = JSON.parse(readFileSync(new URL("./npm/package.json", import.meta.url), "utf8")).version;

  // Delegation is off for this whole file (top of it); every case here turns it
  // back on deliberately. The engine variables are cleared for the reason Phase
  // 3l clears them, and here it is sharper: an exported `SASSO_ENGINE` disables
  // delegation outright, so inheriting one would leave every assertion below
  // passing while testing nothing at all. `SASSO_DEBUG_ENGINE` is on throughout
  // — the decisions are silent by design, and this is the only way to read them.
  const env = (extra) => {
    const base = { ...process.env };
    delete base.SASSO_BINARY;
    delete base.SASSO_ENGINE;
    delete base.SASSO_NATIVE_BINARY;
    delete base.SASSO_CLI_DELEGATED;
    return { ...base, SASSO_DEBUG_ENGINE: "1", ...extra };
  };
  const runWith = (cli, argv, extra, input) =>
    spawnSync(process.execPath, [cli, ...argv], { encoding: "utf8", env: env(extra), input, timeout: 60000 });
  const run = (argv, extra, input) => runWith(cliPath, argv, extra, input);
  const argv = (name, ...rest) => ["--no-source-map", "--style=compressed", ...rest, `${src}:${join(dir, name)}`];
  const compiles = (label, r, name) => {
    assert.equal(r.status, 0, `cli: ${label} — exits 0 (stderr: ${r.stderr})`);
    // Existence first: a run that delegated when it should not have leaves NO
    // output at all (the stand-ins write none), and reading a missing file
    // reports that as an ENOENT stack trace instead of as this assertion.
    assert.ok(existsSync(join(dir, name)), `cli: ${label} — wrote ${name} (stderr: ${r.stderr})`);
    assert.equal(readFileSync(join(dir, name), "utf8").trim(), CSS, `cli: ${label} — compiled here, in-process`);
  };
  const dirWith = (name, make) => {
    const d = join(dir, name);
    mkdirSync(d, { recursive: true });
    if (make) make(d);
    return d;
  };
  // The automatic gate compares the binary's version against the PACKAGE's, and
  // in a working tree they never agree: `wasm/npm/package.json` carries the npm
  // line's last published version and `npm version` sets the real one from the
  // tag at publish time (release-wasm.yml, whose `version-match` job is what
  // guarantees a published package and a released binary agree). So the cases
  // that need them equal run against a COPY of the package saying what a
  // published one would. The wasm modules are symlinked rather than copied —
  // megabytes each, and nothing here rewrites them.
  const npmDir = fileURLToPath(new URL("./npm/", import.meta.url));
  const pkgJson = JSON.parse(readFileSync(join(npmDir, "package.json"), "utf8"));
  let pkgCopies = 0;
  const packageSaying = (version) => {
    const d = dirWith(`pkg-${++pkgCopies}`);
    for (const entry of readdirSync(npmDir)) {
      const from = join(npmDir, entry), to = join(d, entry);
      if (!statSync(from).isFile()) continue;
      if (entry === "package.json") writeFileSync(to, JSON.stringify({ ...pkgJson, version }, null, 2));
      else if (entry.endsWith(".wasm")) symlinkSync(from, to);
      else copyFileSync(from, to);
    }
    return join(d, "cli.mjs");
  };

  // Nothing named sasso anywhere on PATH: the ordinary case, and the one that
  // must not become slower or louder for the sake of the others.
  compiles("no sasso on PATH", run(argv("a.css"), { PATH: dirWith("empty") }), "a.css");
  {
    // …and `--engine` says so, rather than reporting an engine as if nothing had
    // been looked for: "why am I not getting the fast path?" is the question that
    // follows the answer, so it is answered in the same breath.
    const r = run(["--engine"], { PATH: dirWith("empty") });
    assert.equal(r.status, 0, `cli: --engine with nothing on PATH (stderr: ${r.stderr})`);
    assert.match(r.stdout, /^binary: +not used — no sasso binary on PATH$/m, `cli: … says what it looked for (stdout: ${r.stdout})`);
  }

  // `npm install -g sasso` puts a `sasso` on PATH that IS this file behind a
  // `#!/usr/bin/env node` line. Handing it the command line would fork bomb, so
  // it has to be passed over — and passed over silently, because a global
  // install of this package is a perfectly normal thing to have.
  const shim = join(dirWith("shim"), "sasso");
  writeFileSync(shim, `#!/usr/bin/env node\nimport(${JSON.stringify(pathToFileURL(cliPath).href)});\n`);
  chmodSync(shim, 0o755);
  {
    const r = run(argv("b.css"), { PATH: dirWith("shim") });
    compiles("a JS shim named sasso on PATH", r, "b.css");
    assert.ok(!/handing the command line to/.test(r.stderr), `cli: … and nothing was handed the command line (stderr: ${r.stderr})`);
  }

  // An explicit `SASSO_BINARY` that is not an executable image is an error, not
  // a quiet fallback: a build that configured a binary and got the in-process
  // engine instead would be measuring something other than what it asked for.
  {
    const r = run(argv("c.css"), { SASSO_BINARY: shim });
    assert.notEqual(r.status, 0, "cli: SASSO_BINARY pointing at a script fails");
    assert.match(r.stderr, /is not an executable sasso binary/, "cli: … naming what is wrong with it");
    assert.ok(!existsSync(join(dir, "c.css")), "cli: … and it did not quietly compile instead");
  }

  // `0/off/false/no` is the way out for a machine where the binary on PATH is
  // wrong for the project, and it is read before anything else is looked at.
  {
    const r = run(argv("d.css"), { SASSO_BINARY: "off", PATH: dirWith("empty") });
    compiles("SASSO_BINARY=off", r, "d.css");
    assert.match(r.stderr, /SASSO_BINARY declines the binary/, "cli: … and says so under SASSO_DEBUG_ENGINE");
  }

  // The POSIX stand-ins. Both are native images (so they get past the magic-byte
  // check) and neither is sasso, which is exactly what makes them useful.
  const firstOf = (paths) => paths.find((p) => existsSync(p));
  const echo = firstOf(["/bin/echo", "/usr/bin/echo"]);
  const envBin = firstOf(["/usr/bin/env", "/bin/env"]);
  if (!echo || !envBin) {
    console.log("  (no /bin/echo or /usr/bin/env here — the stand-in delegation cases are skipped)");
  } else {
    // THE WHOLE command line, in order, and not a byte of it interpreted here:
    // `echo` prints its argv and writes no CSS, so both halves are pinned at
    // once. A binary that received a rewritten command line would compile the
    // right stylesheet with the wrong options, which no output test would catch.
    const line = argv("e.css");
    const r = run(line, { SASSO_BINARY: echo });
    assert.equal(r.status, 0, `cli: a delegated run exits with the child's status (stderr: ${r.stderr})`);
    assert.equal(r.stdout.trim(), line.join(" "), "cli: the binary got the whole command line, in order");
    assert.ok(!existsSync(join(dir, "e.css")), "cli: … and this process compiled nothing itself");

    // Every failure in this CLI exits 1 (#91). A delegated failure must NOT be
    // flattened into that: 127 is what `env` returns for a command it cannot
    // find, so reading it here means the status came from the child untouched.
    const code = run(["/no/such/file.scss"], { SASSO_BINARY: envBin });
    assert.equal(code.status, 127, `cli: the child's exit code is this process's (got ${code.status})`);

    // `--watch` and `--update` are BOTH in the binary now (#86), and neither
    // delegates — for different reasons. `--update` only exists in a binary
    // of THIS version and `SASSO_BINARY` is documented as version-unchecked;
    // `--watch` stays because this CLI's event watcher is measurably faster
    // than the binary's poll. Either way the command line must stay here
    // rather than be handed to whatever that variable names: delegating
    // would give `echo` a working build and compile nothing, which is what
    // the file check below would catch.
    {
      const upd = run(argv("f.css", "--update"), { SASSO_BINARY: echo });
      compiles("--update with a binary configured", upd, "f.css");
      assert.match(upd.stderr, /version is unchecked/, "cli: … and the reason is readable");
    }
    {
      // `--watch <input>` with no output: the guard runs before the engine, so
      // the error that comes back proves whose argument grammar was in force.
      const w = run(["--watch", src], { SASSO_BINARY: echo });
      assert.notEqual(w.status, 0, "cli: --watch still needs an output file");
      assert.match(w.stderr, /--watch requires <input> <output>/, "cli: … in this CLI's words, not a child's");
      assert.match(
        w.stderr,
        /--watch is faster in-process/,
        "cli: … because --watch never delegates, and the reason is no longer that the binary lacks one",
      );
    }

    // Metadata answers from this file alone, as it does when no engine can load
    // at all (Phase 3l): `echo` would print the flag back, and the version the
    // binary prints is not even formatted the same way (`sasso 0.16.0` against
    // dart's bare `0.16.0`).
    assert.equal(run(["--version"], { SASSO_BINARY: echo }).stdout.trim(), pkgVersion, "cli: --version never delegates");
    assert.ok(run(["--help"], { SASSO_BINARY: echo }).stdout.includes("Usage: sasso"), "cli: --help never delegates");

    // A demanded in-process engine is a demand for an engine, and a subprocess
    // is not one.
    for (const engine of ["wasm", "native"]) {
      const r2 = run(argv(`g-${engine}.css`), { SASSO_BINARY: echo, SASSO_ENGINE: engine });
      if (engine === "native" && r2.status !== 0) {
        assert.match(r2.stderr, /SASSO_ENGINE=native/, "cli: a demanded engine that is missing says so");
        continue;
      }
      compiles(`SASSO_ENGINE=${engine} keeps the compile in-process`, r2, `g-${engine}.css`);
    }

    // The mark the child is started with. The magic-byte check is what stops the
    // `npm i -g sasso` loop, but a wrapper reached some other way would slip
    // past it, so a second hop is refused outright.
    compiles(
      "the delegation mark stops a second hop",
      run(argv("h.css"), { SASSO_BINARY: echo, SASSO_CLI_DELEGATED: "1" }),
      "h.css",
    );

    // A native `sasso` on PATH that is not sasso is passed over, and silently:
    // another project's binary under that name is a normal state of the world,
    // not a build-breaking one.
    const strangerDir = dirWith("stranger", (d) => symlinkSync(echo, join(d, "sasso")));
    const stranger = run(argv("i.css"), { PATH: strangerDir });
    compiles("a native `sasso` on PATH that is not sasso", stranger, "i.css");
    assert.match(stranger.stderr, /compiling in-process/, "cli: … and what it asked is on the record");

    // …and the version alone is NOT what identifies it. `sasso --version` prints
    // exactly `sasso <version>`, so the whole line has to match that shape: a
    // stranger whose version output happens to equal this package's version
    // would otherwise be handed the project's command line. `echo` prints back
    // whatever it is given, which makes it a stranger claiming to be any version
    // asked for — here, the package's own.
    const claimed = runWith(packageSaying("--version"), argv("i2.css"), { PATH: strangerDir });
    compiles("a stranger whose --version output equals the package version", claimed, "i2.css");
    assert.match(claimed.stderr, /does not answer --version with `sasso <version>`/, "cli: … declined on the shape of the line, not its last field");
  }

  // And now the real thing, wherever this machine keeps one: no stand-in can
  // show that the CSS is the same CSS.
  const exe = process.platform === "win32" ? "sasso.exe" : "sasso";
  const binaryVersionOf = (p) => {
    const r = spawnSync(p, ["--version"], { encoding: "utf8", timeout: 10000 });
    if (r.status !== 0) return undefined;
    // The binary prints `sasso <v>` and nothing else; this CLI prints a bare
    // `<v>`, dart's format. Deliberately the same whole-output test `cli.mjs`
    // applies, character for character: a helper that accepted more than the
    // gate does would pick a candidate the gate then declines, and the
    // end-to-end assertions below would be measuring the wrong executable —
    // differently on each machine, depending on PATH.
    const m = /^sasso (\S+)$/.exec(String(r.stdout || "").trim());
    return m ? m[1] : undefined;
  };
  const candidates = [];
  if (process.env.SASSO_TEST_BINARY) candidates.push(process.env.SASSO_TEST_BINARY);
  for (const root of [process.env.CARGO_TARGET_DIR, fileURLToPath(new URL("../target/", import.meta.url))]) {
    if (root) for (const profile of ["release", "debug"]) candidates.push(join(root, profile, exe));
  }
  for (const d of (process.env.PATH || "").split(delimiter)) if (d) candidates.push(join(d, exe));
  const binary = candidates.find((p) => existsSync(p) && binaryVersionOf(p) !== undefined);

  if (!binary) {
    // Normal in CI: no job in the wasm workflow builds the Rust CLI. Point
    // `SASSO_TEST_BINARY` at one, or have one on PATH, to run these.
    console.log("  (no sasso binary here — delegation checked with stand-ins only)");
  } else {
    const binVersion = binaryVersionOf(binary);

    // Explicit and version-unchecked, which is how an unreleased build gets
    // driven.
    const exp = run(argv("j.css"), { SASSO_BINARY: binary });
    assert.equal(exp.status, 0, `cli: SASSO_BINARY=<binary> compiles (stderr: ${exp.stderr})`);
    assert.equal(readFileSync(join(dir, "j.css"), "utf8").trim(), CSS, "cli: … and the binary wrote the CSS this CLI would have");
    assert.ok(exp.stderr.includes(`SASSO_BINARY=${binary}`), `cli: … on the record (stderr: ${exp.stderr})`);

    // Delegating fixes the exit codes on the way: dart exits 65 on a compile
    // error and the binary matches it (README, "CLI usage"), where this CLI
    // exits 1 for everything (#91). A run that came back 1 here would mean the
    // child's status was thrown away, or that nothing was delegated to at all.
    const bad = join(dir, "bad.scss");
    writeFileSync(bad, ".a{color:}\n");
    const failed = run([bad], { SASSO_BINARY: binary });
    assert.equal(failed.status, 65, `cli: a delegated compile error exits 65, dart's code (got ${failed.status})`);

    // stdin is INHERITED, not read here and forwarded: the binary reads the
    // same pipe this process was handed.
    const piped = run(["--style=compressed", "--stdin"], { SASSO_BINARY: binary }, ".a{b:1+2}\n");
    assert.equal(piped.status, 0, `cli: a delegated --stdin run (stderr: ${piped.stderr})`);
    assert.equal(piped.stdout.trim(), CSS, "cli: … reads this process's stdin");

    // A version-matched `sasso` is the first thing on PATH and gets the job
    // without being asked for. `packageSaying` is why it can be: see above.
    const autoDir = dirWith("auto", (d) => symlinkSync(binary, join(d, exe)));
    const matchedCli = packageSaying(binVersion);
    const auto = runWith(matchedCli, argv("k.css"), { PATH: autoDir });
    assert.equal(auto.status, 0, `cli: a version-matched sasso on PATH compiles (stderr: ${auto.stderr})`);
    assert.equal(readFileSync(join(dir, "k.css"), "utf8").trim(), CSS, "cli: … byte for byte what this CLI compiles");
    assert.match(auto.stderr, /handing the command line to/, "cli: … and it was the binary that did it");

    // `--engine` REPORTS the hand-off instead of taking it, and this is the one
    // place it can be checked against a binary that would really have been used:
    // the binary has no `--engine` at all, so a delegated one would either fail
    // or answer about something else.
    const asked = runWith(matchedCli, ["--engine"], { PATH: autoDir });
    assert.equal(asked.status, 0, `cli: --engine with a matched binary on PATH (stderr: ${asked.stderr})`);
    assert.match(asked.stdout, /^binary: +.*every compile is handed to it/m, `cli: … names the binary it would hand to (stdout: ${asked.stdout})`);
    assert.match(asked.stdout, /^engine: .*unused while the binary above is there/m, "cli: … and says the engine it loaded is idle");

    // The exit code again, this time on the path nobody asked for: the automatic
    // hand-off has to be as faithful as the explicit one.
    const autoFailed = runWith(matchedCli, [bad], { PATH: autoDir });
    assert.equal(autoFailed.status, 65, `cli: an automatic hand-off keeps the binary's exit code (got ${autoFailed.status})`);

    // The escape hatch and the mark, against a binary that really would have
    // been used — the `echo` cases above cannot show that, because `echo` was
    // never going to be picked up automatically in the first place.
    compiles(
      "SASSO_BINARY=0 with a matched binary right there",
      runWith(matchedCli, argv("l.css"), { PATH: autoDir, SASSO_BINARY: "0" }),
      "l.css",
    );
    compiles(
      "the mark, against a matched binary",
      runWith(matchedCli, argv("m.css"), { PATH: autoDir, SASSO_CLI_DELEGATED: "1" }),
      "m.css",
    );

    // And the gate itself, against the real binary rather than a stranger: one
    // patch version apart is exactly the case that must be declined, because
    // this is #114 (a version-skewed engine used anyway, quietly dropping
    // options it could not apply) one process further out.
    const skewed = runWith(packageSaying(`${binVersion}-not`), argv("n.css"), { PATH: autoDir });
    compiles("a real sasso on PATH that is a version apart", skewed, "n.css");
    assert.match(skewed.stderr, /compiling in-process/, "cli: … and the versions it compared are on the record");
  }
  console.log("ok: cli — delegating to the release binary (version gate, argv, exit codes, no recursion)");
}

// === The `quietDeps` option, on the JS API and on both engines ===
{
  const importer = {
    canonicalize: (u) => (u.startsWith("virt:") ? new URL(u) : null),
    load: () => ({ contents: '@warn "dep-warn";\n.v{color: lighten(#036, 10%)}', syntax: "scss" }),
  };
  const collect = (mod, quietDeps) => {
    const seen = [];
    mod.compileString('@use "virt:a" as v;\n', {
      url: "file:///entry.scss",
      importers: [importer],
      quietDeps,
      logger: {
        warn: (m, o) => seen.push(`${o.deprecation ? "DEPRECATION" : "WARNING"}:${m.split("\n")[0]}`),
        debug: (m) => seen.push(`DEBUG:${m}`),
      },
    });
    return seen;
  };
  for (const [name, mod] of [["size", size], ["speed", speed]]) {
    const loud = collect(mod, false);
    assert.ok(loud.some((w) => w.startsWith("DEPRECATION")), `quietDeps(${name}): deprecations warn by default`);
    const quiet = collect(mod, true);
    assert.ok(!quiet.some((w) => w.startsWith("DEPRECATION")), `quietDeps(${name}): silenced for an importer's stylesheet`);
    assert.ok(quiet.some((w) => w.includes("dep-warn")), `quietDeps(${name}): @warn still reaches the logger`);
  }
  // The asyncify engine takes the same path (a separate wasm instance).
  {
    const seen = [];
    await size.compileStringAsync('@use "virt:a" as v;\n', {
      url: "file:///entry.scss",
      importers: [importer],
      quietDeps: true,
      logger: { warn: (m, o) => seen.push(`${o.deprecation ? "DEPRECATION" : "WARNING"}:${m.split("\n")[0]}`) },
    });
    assert.ok(!seen.some((w) => w.startsWith("DEPRECATION")), "quietDeps(async): silenced");
    assert.ok(seen.some((w) => w.includes("dep-warn")), "quietDeps(async): @warn kept");
  }
  console.log("ok: quietDeps — dependencies silenced, @warn kept, sync + async engines");
}

// === `silenceDeprecations`, on the JS API and on every engine ===
//
// The CLI block above covers the flag; this covers the option behind it, which
// is what a build tool (Vite, webpack) actually passes. One entry raising THREE
// deprecations, so "silenced" can be told apart from "warnings stopped": each
// case names one id and the other two must survive.
{
  const dir = mkdtempSync(join(tmpdir(), "sasso-silence-api-"));
  writeFileSync(join(dir, "dep.scss"), ".d { color: lighten(#036, 10%) }\n");
  const entry = join(dir, "entry.scss");
  writeFileSync(entry, '@import "dep";\n');

  const IMPORT = /@import rules are deprecated/;
  const GLOBAL = /Global built-in functions are deprecated/;
  const LIGHTEN = /lighten\(\) is deprecated/;

  const collect = (mod, silenceDeprecations) => {
    const seen = [];
    mod.compile(entry, {
      silenceDeprecations,
      logger: { warn: (m, o) => seen.push(`${o.deprecation ? "DEP" : "WARN"}|${m.split("\n")[0]}`) },
    });
    return seen.join("\n");
  };

  const engines = [["size", size], ["speed", speed]];
  // The addon is prebuilt for four targets only; cover its JS API too where
  // there is one, since it is a different implementation of the same option.
  try {
    engines.push(["native", await import("./npm/native.mjs")]);
  } catch {
    console.log("  (silenceDeprecations: skipping the native engine, no addon here)");
  }

  for (const [name, mod] of engines) {
    const loud = collect(mod, undefined);
    assert.match(loud, IMPORT, `silenceDeprecations(${name}): @import warns by default`);
    assert.match(loud, GLOBAL, `silenceDeprecations(${name}): global-builtin warns by default`);
    assert.match(loud, LIGHTEN, `silenceDeprecations(${name}): color-functions warns by default`);

    const noImport = collect(mod, ["import"]);
    assert.doesNotMatch(noImport, IMPORT, `silenceDeprecations(${name}): the named id is gone`);
    assert.match(noImport, GLOBAL, `silenceDeprecations(${name}): … and the others are not`);
    assert.match(noImport, LIGHTEN, `silenceDeprecations(${name}): … either of them`);

    // Two ids at once, and the leftover proves it is not silencing everything.
    const noColor = collect(mod, ["global-builtin", "color-functions"]);
    assert.doesNotMatch(noColor, GLOBAL, `silenceDeprecations(${name}): two ids, first gone`);
    assert.doesNotMatch(noColor, LIGHTEN, `silenceDeprecations(${name}): two ids, second gone`);
    assert.match(noColor, IMPORT, `silenceDeprecations(${name}): two ids, the third kept`);

    // An id we never emit is accepted and changes nothing — a build written
    // for `sass` must not fail here for naming one.
    const inert = collect(mod, ["mixed-decls"]);
    assert.match(inert, IMPORT, `silenceDeprecations(${name}): an id we never emit is inert`);

    assert.equal(collect(mod, []), loud, `silenceDeprecations(${name}): an empty list changes nothing`);
  }

  // The async API is a separate wasm instance (asyncify) and a separate code
  // path in the addon, so it gets the option proved on it rather than assumed.
  for (const [name, mod] of engines) {
    const seen = [];
    await mod.compileAsync(entry, {
      silenceDeprecations: ["import"],
      logger: { warn: (m) => seen.push(m.split("\n")[0]) },
    });
    const text = seen.join("\n");
    assert.doesNotMatch(text, IMPORT, `silenceDeprecations(async ${name}): silenced`);
    assert.match(text, GLOBAL, `silenceDeprecations(async ${name}): others kept`);
  }

  // compileString takes the same option, via a different entry point.
  {
    const seen = [];
    size.compileString('@import "dep";\n', {
      url: pathToFileURL(entry).href,
      silenceDeprecations: ["import"],
      logger: { warn: (m) => seen.push(m.split("\n")[0]) },
    });
    const text = seen.join("\n");
    assert.doesNotMatch(text, IMPORT, "silenceDeprecations(compileString): silenced");
    assert.match(text, GLOBAL, "silenceDeprecations(compileString): others kept");
  }

  console.log(`ok: silenceDeprecations — per-id on the JS API, ${engines.length} engines, sync + async + compileString`);

  // An id dart-sass does not know. The CLI and the JS API deliberately differ,
  // and both follow dart 1.104.1, measured: `sass` the command exits 64, while
  // its JS API warns `Invalid deprecation "nope".` through the caller's own
  // logger and compiles anyway. Throwing here would be stricter than dart and
  // would break builds dart accepts; staying silent — what this did first —
  // contradicts the documented option and leaves a typo doing nothing at all.
  for (const [name, mod] of engines) {
    const seen = [];
    const r = mod.compileString(".a{b:c}", {
      silenceDeprecations: ["nope"],
      logger: { warn: (m, o) => seen.push({ m, dep: o?.deprecation, span: o?.span }) },
    });
    assert.equal(seen.length, 1, `silenceDeprecations(${name}): an unknown id warns exactly once`);
    assert.equal(seen[0].m, 'Invalid deprecation "nope".', `silenceDeprecations(${name}): dart's wording`);
    assert.equal(seen[0].dep, false, `silenceDeprecations(${name}): it is a plain warning, not a deprecation`);
    assert.equal(seen[0].span, undefined, `silenceDeprecations(${name}): no span, as in dart`);
    assert.ok(r.css.includes("b: c"), `silenceDeprecations(${name}): … and the compile still succeeds`);

    // Once per occurrence, duplicates included, in the order given — dart's
    // behaviour, not a de-duplicated set.
    const dup = [];
    mod.compileString(".a{b:c}", {
      silenceDeprecations: ["nope", "import", "nope", ""],
      logger: { warn: (m) => dup.push(m) },
    });
    assert.deepEqual(
      dup,
      ['Invalid deprecation "nope".', 'Invalid deprecation "nope".', 'Invalid deprecation "".'],
      `silenceDeprecations(${name}): one warning per occurrence, known ids silent`,
    );

    // An unknown id that CONTAINS A COMMA. The wasm ABI carries this list as
    // one comma-separated string and the core splits it again, so forwarding
    // an invalid id let `["import,global-builtin"]` arrive as two valid ones
    // and silence both — while native, which passes an array, silenced
    // nothing. dart warns and silences nothing; unknown ids are now dropped
    // before marshalling, so the two engines agree with it and each other.
    const smuggled = [];
    mod.compile(entry, {
      silenceDeprecations: ["import,global-builtin"],
      logger: { warn: (m) => smuggled.push(m.split("\n")[0]) },
    });
    assert.ok(
      smuggled.some((w) => w === 'Invalid deprecation "import,global-builtin".'),
      `silenceDeprecations(${name}): a comma inside one id is one invalid id`,
    );
    assert.ok(
      smuggled.some((w) => IMPORT.test(w)) && smuggled.some((w) => GLOBAL.test(w)),
      `silenceDeprecations(${name}): … and it silences neither of them`,
    );

    // A logger that throws must not fail the compile — the package's rule for
    // every other diagnostic (`host_warn` swallows it), and this warning is
    // raised before the compile reaches that guard.
    const r2 = mod.compile(entry, {
      silenceDeprecations: ["nope"],
      logger: { warn: () => { throw new Error("logger exploded"); } },
    });
    assert.ok(r2.css.includes("color"), `silenceDeprecations(${name}): a throwing logger does not fail the compile`);
  }
}

// === Trailing-newline parity: the JS API omits it, the CLI appends one ===
// dart-sass's `compileString().css` carries NO trailing newline (either style);
// the CLI terminates NON-empty output with exactly one (empty output stays
// empty). These pin both halves so the wasm package stays byte-identical to
// dart-sass on both the sass-loader/Vite path (JS API) and the CLI path.
{
  for (const style of ["expanded", "compressed"]) {
    for (const mod of [size, speed]) {
      const out = mod.compileString(".a { color: red; }", { style }).css;
      assert.ok(out.length > 0, `nl: ${style} css non-empty`);
      assert.ok(!out.endsWith("\n"), `nl: JS API ${style} css has NO trailing newline`);
    }
    // CLI: exactly one trailing newline on non-empty output.
    const styleArg = style === "compressed" ? ["--style=compressed"] : [];
    const cliOut = cli([...styleArg, "--stdin"], ".a { color: red; }\n");
    assert.ok(cliOut.endsWith("\n") && !cliOut.endsWith("\n\n"), `nl: CLI ${style} ends with exactly one newline`);
  }
  // Empty-output stylesheet: JS API "" and CLI 0 bytes (no lone newline) — dart parity.
  assert.equal(size.compileString("$x: 1;").css, "", "nl: empty-output JS API css is empty");
  assert.equal(cli(["--stdin"], "$x: 1;\n"), "", "nl: empty-output CLI emits nothing");
  console.log("ok: trailing-newline parity — JS API omits, CLI appends one (empty stays empty)");
}

// Polish: structured Exception (sassMessage + span), shape verified vs dart-sass
{
  let caught;
  try {
    size.compileString(".a { color: ; }", { url: "file:///x.scss" });
  } catch (e) {
    caught = e;
  }
  assert.equal(caught.name, "Exception", "error: name is Exception");
  assert.ok(caught instanceof Error, "error: instanceof Error");
  assert.equal(caught.span.url, "file:///x.scss", "error: span.url");
  assert.equal(caught.span.start.line, 0, "error: span.start.line is 0-based");
  assert.equal(caught.span.start.column, 12, "error: span.start.column (matches dart)");
  assert.ok(caught.message.startsWith("Error:"), "error: message is the rendered block");
  assert.ok(caught.sassMessage.length > 0 && !caught.sassMessage.includes("\n"), "error: sassMessage is a raw one-liner");
  console.log("ok: structured Exception (sassMessage + span)");
}

// === Exit codes say WHICH kind of failure (#91) ===
//
// dart-sass and the native CLI both use the `sysexits` codes, and they
// agree with each other. This CLI exited 1 for everything, so a build
// script that switches on the code to tell "your stylesheet is wrong"
// from "I could not write where you told me" got neither from the
// package advertised as a drop-in.
//
// Measured 2026-09-22 against dart-sass 1.104.1 and the binary:
//
//                            dart   binary   npm before   npm after
//   compile error             65      65         1           65
//   input does not exist      66      66         1           66
//   output is a directory     66      66         1           66
//   usage error               64      64         1           64
//   a batch with both         66      66         1           66
//
// The mixed batch is the one worth pinning: 66 wins in EITHER
// command-line order, so it is severity that decides and not recency.
// That is the same rule `worse()` spells out in `src/main.rs`, and it is
// why `worst` is a numeric maximum — 66 > 65 > 0 is the order already.
{
  const xdir = mkdtempSync(join(tmpdir(), "sasso-exitcodes-"));
  writeFileSync(join(xdir, "good.scss"), ".a { color: red; }\n");
  writeFileSync(join(xdir, "bad.scss"), ".bad { a: 1px + #fff; }\n");
  mkdirSync(join(xdir, "adir"));

  const run = (...args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args], { cwd: xdir, encoding: "utf8" }).status;

  assert.equal(run("good.scss:ok.css"), 0, "a compile that works exits 0");
  assert.equal(run("bad.scss:o.css"), 65, "a compile error exits 65");
  assert.equal(run("nosuch.scss:o.css"), 66, "an input that is not there exits 66");
  assert.equal(run("good.scss:adir"), 66, "an output that cannot be written exits 66");
  assert.equal(run("--frobnicate", "good.scss"), 64, "an unknown flag exits 64");
  assert.equal(run(), 64, "no input at all exits 64");

  // Both causes in one batch, both orders, in-thread and across workers.
  for (const jobs of [["-j", "1"], ["-j", "4"]]) {
    assert.equal(
      run(...jobs, "bad.scss:m1.css", "good.scss:adir"),
      66,
      `a batch with both causes exits 66 (${jobs.join(" ")})`,
    );
    assert.equal(
      run(...jobs, "good.scss:adir", "bad.scss:m2.css"),
      66,
      `…in either order (${jobs.join(" ")})`,
    );
    assert.equal(
      run(...jobs, "good.scss:m3.css", "bad.scss:m4.css"),
      65,
      `a batch with only a compile error exits 65 (${jobs.join(" ")})`,
    );
  }

  // A compile error whose ERROR-CSS WRITE also fails is an I/O failure:
  // the output could not be produced. Measured 2026-09-23,
  // `bad.scss:adir` — dart 66, binary 66.
  assert.equal(run("bad.scss:adir"), EXIT_IO, "a compile error whose error CSS cannot be written exits 66");

  // …and a failed REMOVAL under --no-error-css is NOT. There was no
  // output to produce, and the cleanup failing does not change what went
  // wrong with the stylesheet: dart stays at 65 and says nothing about
  // the removal at all.
  //
  // This is the case that makes the pair worth having. "Use the write
  // result for the code" passes the one above and fails this one — the
  // binary does exactly that and answers 66 here, which is a divergence
  // from dart of its own (#182).
  assert.equal(
    run("--no-error-css", "bad.scss:adir"),
    EXIT_COMPILE,
    "a compile error whose stale-output removal fails still exits 65",
  );

  // The write half again through --stdin, which has its own copy of the
  // rule. The output is a path UNDER a regular file, because `--stdin`
  // with a directory output is a usage error before anything compiles
  // (64 on both front ends) — measured, along with dart answering 66 for
  // this shape too.
  //
  // Its removal half is not reachable: `rmSync` is called with `force`,
  // so a destination that is not there is not a failure, and the one
  // destination whose removal WOULD fail is the directory the parser
  // already refused. Said rather than faked.
  {
    writeFileSync(join(xdir, "afile"), "x\n");
    const viaStdin = (...args) =>
      spawnSync(process.execPath, [cliPath, "--no-source-map", "--stdin", ...args], {
        cwd: xdir,
        encoding: "utf8",
        input: ".bad { a: 1px + #fff; }\n",
      }).status;
    assert.equal(
      viaStdin("-o", join("afile", "out.css")),
      EXIT_IO,
      "--stdin: error CSS that cannot be written exits 66",
    );
  }

  // A directory INPUT the filesystem will not list is 66 too. It is its
  // own code path — the walk, not a compile — and without this the only
  // thing that noticed the code changing there was an unrelated timing
  // case, which is not a guard.
  //
  // Skipped for root, who can read it anyway, and on Windows, where
  // `chmod` does not bite. Both would otherwise assert the opposite of
  // what they measure.
  if (process.platform !== "win32" && (process.getuid?.() ?? 0) !== 0) {
    const locked = join(xdir, "locked");
    mkdirSync(locked);
    writeFileSync(join(locked, "a.scss"), ".a { color: red; }\n");
    chmodSync(locked, 0o000);
    try {
      // The PAIR form, because two positionals with a directory are a
      // usage error before any walk happens ("Directory … may not be a
      // positional arg.", 64 on both front ends).
      //
      // dart exits 255 here — an uncaught crash, not a code — so this
      // one pins the binary and this CLI agreeing with each other rather
      // than agreeing with dart.
      assert.equal(run(`${locked}:${join(xdir, "outdir")}`), EXIT_IO, "a directory that cannot be listed exits 66");
    } finally {
      chmodSync(locked, 0o755);
    }
  }

  rmSync(xdir, { recursive: true, force: true });
  console.log("ok: exit codes — 64 usage, 65 compile, 66 I/O, and I/O wins a mixed batch");
}

// === Bytes that are not UTF-8 are refused, on every engine (#179) ===
//
// `readFileSync(path, "utf8")` does not reject invalid UTF-8 — it puts
// U+FFFD in and hands back a string — so the npm CLI compiled a file dart
// refuses and said nothing:
//
//   dart-sass 1.104.1   Error: Invalid UTF-8.
//   sasso binary        Error: Invalid UTF-8.
//   npm, before         @charset "UTF-8"; .a { color: ??red; }
//
// BOTH engines are exercised where both exist. That is the whole lesson
// of this bug: the dependency half was wrong only on wasm, the entry half
// was wrong on both, and a suite that runs one engine at a time saw
// neither until CI ran the other one (#176).
{
  const utf8dir = mkdtempSync(join(tmpdir(), "sasso-badutf8-"));
  // Valid SCSS, invalid UTF-8.
  const badBytes = Buffer.from("$c: \xff\xfered;\n", "binary");
  writeFileSync(join(utf8dir, "entry.scss"), Buffer.from(".a { color: \xff\xfered; }\n", "binary"));
  writeFileSync(join(utf8dir, "viadep.scss"), `@use "v" as v;\n.a { color: v.$c; }\n`);
  writeFileSync(join(utf8dir, "_v.scss"), badBytes);

  // An ambient SASSO_ENGINE=wasm skips the native leg; SASSO_ENGINE=native
  // without the addon makes the default ("") leg fail instead of testing wasm.
  const envBase = { ...process.env };
  delete envBase.SASSO_ENGINE;
  delete envBase.SASSO_NATIVE_BINARY;
  const hasNative = /^engine:\s+native/m.test(
    spawnSync(process.execPath, [cliPath, "--engine"], { encoding: "utf8", env: envBase }).stdout || "",
  );
  // Where the addon is absent (the wasm CI job) there is one engine to
  // try; where it is present, both.
  const engines = hasNative ? ["native", "wasm"] : [""];

  for (const engine of engines) {
    const env = engine ? { ...envBase, SASSO_ENGINE: engine } : envBase;
    const name = engine || "default";
    for (const [what, file] of [
      ["the entry", "entry.scss"],
      ["a dependency", "viadep.scss"],
    ]) {
      const r = spawnSync(process.execPath, [cliPath, "--no-source-map", join(utf8dir, file)], {
        encoding: "utf8",
        env,
      });
      // Non-zero, not 65: this CLI exits 1 for every failure, which is
      // #91 and not this bug. Asserting 65 here would fail for the right
      // reason on the wrong ticket.
      assert.notEqual(r.status, 0, `${name}/${what}: it succeeded: ${JSON.stringify(r.stdout)}`);
      assert.ok(
        !r.stdout.includes("�"),
        `${name}/${what}: replacement characters reached the output: ${JSON.stringify(r.stdout)}`,
      );
      assert.ok(
        /UTF-8/.test(r.stderr),
        `${name}/${what}: nothing was said about the encoding: ${JSON.stringify(r.stderr)}`,
      );
    }
  }
  // Standard input is an entry too. The file cases above never touch it,
  // and `readFileSync(0, "utf8")` substituted U+FFFD, so `--stdin` and
  // `-:out.css` compiled bytes a file refuses. The binary reports
  // `Error: Invalid UTF-8.` and writes error CSS
  // (`invalid_utf8_on_stdin_fails_like_a_file`).
  const badStdin = Buffer.from("a { b: c }\n\xff\xfe\n", "binary");
  // wasm, not "whichever addon loaded": the refusal happens in cli.mjs
  // before either engine, and a missing addon would prefix a fallback
  // warning that is not this assertion. `SASSO_BINARY=0` is already set.
  const stdinEnv = { ...process.env, SASSO_ENGINE: "wasm" };
  const stdinRun = (args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args], { input: badStdin, env: stdinEnv });
  const stdinCss = join(utf8dir, "stdin.css");
  const viaFlag = stdinRun(["--stdin", stdinCss]);
  assert.notEqual(viaFlag.status, 0, `stdin: --stdin succeeded: ${viaFlag.stdout}`);
  assert.equal(
    viaFlag.stderr.toString("utf8"),
    "Error: Invalid UTF-8.\n",
    `stdin: --stdin said ${JSON.stringify(viaFlag.stderr.toString("utf8"))}`,
  );
  assert.ok(
    readFileSync(stdinCss, "utf8").startsWith("/* Error: Invalid UTF-8. */"),
    "stdin: error stylesheet for a --stdin file target",
  );
  const stale = join(utf8dir, "stale.css");
  writeFileSync(stale, "old { css: yes }\n");
  const viaPair = stdinRun(["--no-error-css", `-:${stale}`]);
  assert.notEqual(viaPair.status, 0, "stdin: -:out succeeded");
  assert.equal(viaPair.stderr.toString("utf8"), "Error: Invalid UTF-8.\n", "stdin: -:out wording");
  assert.equal(existsSync(stale), false, "stdin: stale CSS removed like any compile error");
  const viaStdout = stdinRun(["-"]);
  assert.notEqual(viaStdout.status, 0, "stdin: bare - succeeded");
  assert.equal(viaStdout.stdout.length, 0, "stdin: CSS reached stdout");
  assert.equal(viaStdout.stderr.toString("utf8"), "Error: Invalid UTF-8.\n", "stdin: bare - wording");
  const viaLoop = stdinRun(["--loop", "1", "--stdin"]);
  assert.notEqual(viaLoop.status, 0, "stdin: --loop succeeded");
  assert.equal(viaLoop.stdout.length, 0, "stdin: --loop printed CSS");
  assert.equal(viaLoop.stderr.toString("utf8"), "Error: Invalid UTF-8.\n", "stdin: --loop wording");
  // And a valid multibyte stdin still round-trips. The fatal decoder must
  // not reject bytes that merely are not ASCII.
  const okStdin = Buffer.from("$c: \"café\";\n.a{color:$c}\n", "utf8");
  const viaOk = spawnSync(process.execPath, [cliPath, "--style=compressed", "--no-source-map", "--stdin"], {
    input: okStdin,
    env: stdinEnv,
  });
  assert.equal(viaOk.status, 0, `stdin: valid UTF-8 failed: ${viaOk.stderr}`);
  assert.ok(viaOk.stdout.toString("utf8").includes("café"), `stdin: valid UTF-8 lost: ${viaOk.stdout}`);

  rmSync(utf8dir, { recursive: true, force: true });
  console.log(`ok: invalid UTF-8 is refused, entry and dependency, on ${engines.length === 2 ? "both engines" : "the engine present here"}`);
}

// === Phase 3: CLI --watch (recompiles on dependency change) ===
{
  const waitFor = async (pred, timeoutMs) => {
    const deadline = Date.now() + timeoutMs;
    while (Date.now() < deadline) {
      if (pred()) return true;
      await new Promise((r) => setTimeout(r, 50));
    }
    return false;
  };
  const wdir = mkdtempSync(join(tmpdir(), "sasso-watch-"));
  writeFileSync(join(wdir, "main.scss"), `@use "v" as v;\n.a { color: v.$c; }\n`);
  writeFileSync(join(wdir, "_v.scss"), `$c: red;\n`);
  const outFile = join(wdir, "out.css");
  const proc = spawn(process.execPath, [cliPath, "--watch", join(wdir, "main.scss"), outFile], { stdio: "ignore" });
  try {
    assert.ok(await waitFor(() => existsSync(outFile) && readFileSync(outFile, "utf8").includes("red"), 10000), "cli --watch: initial compile");
    writeFileSync(join(wdir, "_v.scss"), `$c: blue;\n`); // change a DEPENDENCY, not the entry
    assert.ok(await waitFor(() => readFileSync(outFile, "utf8").includes("blue"), 10000), "cli --watch: recompiles on dependency change");
    console.log("ok: cli --watch — initial + recompile on dependency change");
  } finally {
    proc.kill();
  }
}

// === Phase 3a: CLI --watch --poll, the sweep with no watcher under it ===
//
// `--poll` turns node's `fs.watch` OFF, so nothing but the sweep can see
// this save. That makes it the guard for the wiring: `_poller.mjs`'s own
// tests drive a fake clock and know nothing about whether `cli.mjs` ever
// starts one, and every other `--watch` case here would still pass on
// events alone.
//
// It is also the flag a macOS user reaches for, and before #164 it was
// accepted and ignored.
{
  const waitFor = async (pred, timeoutMs) => {
    const deadline = Date.now() + timeoutMs;
    while (Date.now() < deadline) {
      if (pred()) return true;
      await new Promise((r) => setTimeout(r, 25));
    }
    return false;
  };
  const wdir = mkdtempSync(join(tmpdir(), "sasso-watchpoll-"));
  writeFileSync(join(wdir, "main.scss"), `@use "v" as v;\n.a { color: v.$c; }\n`);
  writeFileSync(join(wdir, "_v.scss"), `$c: red;\n`);
  const outFile = join(wdir, "out.css");
  const css = () => {
    try {
      return readFileSync(outFile, "utf8");
    } catch {
      return "";
    }
  };
  const proc = spawn(process.execPath, [cliPath, "--no-source-map", "-I", join(wdir, "gen"), "--poll", "--watch", join(wdir, "main.scss"), outFile], {
    stdio: "ignore",
  });
  try {
    assert.ok(await waitFor(() => css().includes("red"), 20000), "cli --watch --poll: initial compile");
    // Settled, so this cannot ride the catch-up that follows every
    // provisional run — measuring that timer instead of the sweep is how
    // the 12.4ms in the old bench came about.
    await new Promise((r) => setTimeout(r, 500));
    writeFileSync(join(wdir, "_v.scss"), `$c: blue;\n`);
    assert.ok(
      await waitFor(() => css().includes("blue"), 20000),
      "cli --watch --poll: the sweep alone sees a dependency change",
    );
    // …and a file that did not exist when the watch started, which is the
    // directory half of the sweep rather than the stamp half.
    await new Promise((r) => setTimeout(r, 500));
    writeFileSync(join(wdir, "main.scss"), `@use "v" as v;\n@use "extra";\n.a { color: v.$c; }\n`);
    assert.ok(await waitFor(() => /error/i.test(css()) || css().includes("blue"), 20000), "cli --watch --poll: still alive");
    await new Promise((r) => setTimeout(r, 500));
    writeFileSync(join(wdir, "_extra.scss"), `.z { color: lime; }\n`);
    assert.ok(
      await waitFor(() => css().includes("lime"), 20000),
      "cli --watch --poll: the sweep sees a dependency ARRIVE",
    );
    // …and a LOAD PATH that does not exist yet. This was the probes'
    // job, and `makeProbe` is `fs.watch` underneath, so under `--poll`
    // they are not armed at all — the sweep has to cover it, because an
    // absent load path is already in the watched set and its entries
    // appear the moment it does.
    //
    // Not guarded, and worth saying rather than pretending: nothing here
    // can assert that no `fs.watch` was OPENED. On this machine the
    // difference showed up as latency — 516-4064 ms through the probe
    // against 11-23 ms through the sweep — but on Linux `fs.watch` is
    // 0.2 ms and a timing assertion would tell the two apart nowhere.
    await new Promise((r) => setTimeout(r, 500));
    writeFileSync(join(wdir, "main.scss"), `@use "v" as v;
@use "viaload" as l;
.a { color: v.$c; b: l.$d; }
`);
    await new Promise((r) => setTimeout(r, 500));
    mkdirSync(join(wdir, "gen"));
    writeFileSync(join(wdir, "gen", "_viaload.scss"), `$d: olive;
`);
    assert.ok(
      await waitFor(() => css().includes("olive"), 20000),
      "cli --watch --poll: the sweep sees a load path that did not exist",
    );
    console.log("ok: cli --watch --poll — the sweep alone sees a change, an arrival, and a created load path");
  } finally {
    proc.kill();
  }
}

// === Phase 3a2: an idle --watch compiles ONCE ===
//
// A spurious recompile is silent — identical CSS skips the write and the
// narration — so counting `Compiled` lines cannot see one. A `@warn` in the
// entry fires on every compile, which is what makes this countable at all.
//
// The case that needs it: `@use "sub/dep"` puts `sub/` in the watched set
// only AFTER the first compile resolves it, so the sweep's pre-compile
// baseline has never seen anything in there. Carrying that baseline across
// unchanged makes every file in `sub/` an arrival — measured at three
// compiles per idle startup instead of one.
{
  const wdir = mkdtempSync(join(tmpdir(), "sasso-watchidle-"));
  mkdirSync(join(wdir, "sub"));
  writeFileSync(join(wdir, "main.scss"), `@use "sub/dep" as d;\n@warn "COMPILED";\n.a { color: d.$c; }\n`);
  writeFileSync(join(wdir, "sub", "_dep.scss"), `$c: red;\n`);
  // Neighbours in the newly-scoped directory, so its arrival would show.
  for (let k = 0; k < 3; k++) writeFileSync(join(wdir, "sub", `other${k}.txt`), "x\n");

  const outFile = join(wdir, "out.css");
  const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
    cwd: wdir,
    stdio: ["ignore", "pipe", "pipe"],
  });
  let log = "";
  proc.stdout.on("data", (b) => (log += b));
  proc.stderr.on("data", (b) => (log += b));
  const compiles = () => log.split("\n").filter((l) => l.includes("COMPILED")).length;

  try {
    // Asserted, not merely waited for. Falling out of this loop at the
    // deadline and carrying on would make a startup regression PASS: a
    // compile that ran and produced the wrong CSS still leaves
    // `compiles()` at 1, which is what the assertion below wants to see.
    const deadline = Date.now() + 20000;
    let started = false;
    while (Date.now() < deadline) {
      try {
        if (readFileSync(outFile, "utf8").includes("red")) {
          started = true;
          break;
        }
      } catch {
        /* not yet */
      }
      await new Promise((r) => setTimeout(r, 25));
    }
    assert.ok(started, `the first compile never landed: ${JSON.stringify(log)}`);
    // Nothing is touched from here. Several sweep intervals (50ms floor)
    // and several coalescing windows.
    await new Promise((r) => setTimeout(r, 1500));
    assert.equal(compiles(), 1, `an idle watch compiled more than once: ${JSON.stringify(log)}`);
    console.log("ok: cli --watch --poll — an idle watch with a subdirectory dependency compiles once");
  } finally {
    proc.kill();
  }
}

// === Phase 3a3: one save, one `@warn` (#165) ===
//
// A burst is a provisional run plus a catch-up, and both used to report,
// so every diagnostic a successful compile produced appeared twice.
// Measured against dart-sass 1.104.1 and the binary, one `@warn` and
// three saves:
//
//   dart          WARNING x4   (one at startup, one per save)
//   binary        WARNING x4
//   npm, before   WARNING x7
//   npm, after    WARNING x4
//
// `--poll` because the native watcher on macOS delivers a save twice,
// seconds apart (#164), which is real work the count cannot predict; the
// ratio below holds either way and the absolute number only under a
// watcher that fires once.
{
  const wdir = mkdtempSync(join(tmpdir(), "sasso-watchwarn-"));
  const sheet = (c) => `@warn "the warning";\n.a { color: ${c}; }\n`;
  writeFileSync(join(wdir, "main.scss"), sheet("red"));
  const outFile = join(wdir, "out.css");
  const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
    cwd: wdir,
    stdio: ["ignore", "pipe", "pipe"],
  });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (b) => (stdout += b));
  proc.stderr.on("data", (b) => (stderr += b));
  const warns = () => stderr.split("\n").filter((l) => l.includes("the warning")).length;
  const compiled = () => stdout.split("\n").filter((l) => l.includes("Compiled")).length;
  const css = () => {
    try {
      return readFileSync(outFile, "utf8");
    } catch {
      return "";
    }
  };
  const until = async (pred, ms) => {
    const deadline = Date.now() + ms;
    while (Date.now() < deadline) {
      if (pred()) return true;
      await new Promise((r) => setTimeout(r, 25));
    }
    return false;
  };

  try {
    assert.ok(await until(() => css().includes("red"), 20000), "cli --watch @warn: the first compile never landed");
    await new Promise((r) => setTimeout(r, 600));
    assert.equal(warns(), 1, `the first compile warned more than once: ${JSON.stringify(stderr)}`);

    writeFileSync(join(wdir, "main.scss"), sheet("navy"));
    assert.ok(await until(() => css().includes("navy"), 20000), "cli --watch @warn: the save never landed");
    // Past the catch-up, so a second report would have arrived by now.
    await new Promise((r) => setTimeout(r, 600));
    assert.equal(warns(), 2, `one save printed the warning ${warns() - 1} times: ${JSON.stringify(stderr)}`);
    // …and the invariant that survives a watcher firing twice: the
    // warning belongs to the run that announces the write, so there is
    // exactly one of each.
    assert.equal(warns(), compiled(), `a warning per written file: ${warns()} warnings, ${compiled()} lines`);

    // A save that produces exactly what is already on disk reports
    // NOTHING — no line, and no warning either. That is this CLI's rule
    // rather than dart's (dart recompiles and says so), and it is the
    // one that makes the macOS double-notification harmless: the second
    // burst for a save produces nothing, so it says nothing.
    //
    // It is also why the diagnostics are captured instead of let
    // through. Without that they reach stderr during `compile()`, before
    // anything knows whether the run produced anything.
    writeFileSync(join(wdir, "main.scss"), sheet("navy"));
    await new Promise((r) => setTimeout(r, 900));
    assert.equal(warns(), 2, `a save that changed nothing warned again: ${JSON.stringify(stderr)}`);
    assert.equal(compiled(), 2, `a save that changed nothing was narrated: ${JSON.stringify(stdout)}`);
    console.log("ok: cli --watch — one save prints one @warn, and a save that changes nothing prints none");
  } finally {
    proc.kill();
  }
}

// === Phase 3a4: the output is a source by another name (#168) ===
//
// `out.css -> main.scss` and then `--watch main.scss out.css`. The
// lexical guard compares path strings and a symlink is the same file
// under a different one, so the stylesheet was replaced by its own CSS.
//
// dart has a guard here too and it is RACY: measured 2026-09-22, 29 runs
// of exactly this, dart declined 26 times and destroyed the stylesheet 3.
// So matching dart would mean destroying the file one time in ten. The
// binary took the deterministic side in #166; this is the same rule.
//
// Both shapes, because they take different paths through the guard: the
// entry is compared directly and a dependency comes out of `known`.
{
  for (const target of ["main.scss", "_v.scss"]) {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchlink-"));
    const MAIN = `@use "v" as v;\n.a { color: v.$c; }\n`;
    const DEP = `$c: red;\n`;
    writeFileSync(join(wdir, "main.scss"), MAIN);
    writeFileSync(join(wdir, "_v.scss"), DEP);
    symlinkSync(join(wdir, target), join(wdir, "out.css"));

    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      // The banner is the synchronisation point. A fixed sleep is not
      // one: a watch that never started would satisfy every assertion
      // below — "it wrote nothing" is trivially true of a process that
      // did nothing — and this case would pass while testing nothing.
      assert.ok(
        await until(() => log.includes("watching for changes"), 20000),
        `${target}: the watch never started, so the guard was never reached: ${JSON.stringify(log)}`,
      );
      // The banner is printed AFTER the first compile, so by here the
      // decision this case is about has already been made. The pause is
      // for the burst behind it, not for the compile.
      await new Promise((r) => setTimeout(r, 800));
      assert.equal(readFileSync(join(wdir, "main.scss"), "utf8"), MAIN, `${target}: the entry was overwritten`);
      assert.equal(readFileSync(join(wdir, "_v.scss"), "utf8"), DEP, `${target}: the dependency was overwritten`);
      // Silent, because dart is silent when it declines.
      assert.ok(!log.includes("Compiled"), `${target}: it narrated a write it should not have made: ${JSON.stringify(log)}`);
    } finally {
      proc.kill();
    }
  }

  // The link still points at a source when that source is DELETED.
  //
  // `realpath` answers nothing for a dangling link, and "nothing" must
  // not read as "not a source": the failure path writes the error
  // stylesheet through the link and RECREATES the file it is complaining
  // about. Measured before this — `_v.scss` came back holding
  // `/* Error: Can't find stylesheet to import. */`.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchdangle-"));
    writeFileSync(join(wdir, "main.scss"), `@use "v" as v;
.a { color: v.$c; }
`);
    writeFileSync(join(wdir, "_v.scss"), `$c: red;
`);
    symlinkSync(join(wdir, "_v.scss"), join(wdir, "out.css"));
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      assert.ok(
        await until(() => log.includes("watching for changes"), 20000),
        `dangling: the watch never started: ${JSON.stringify(log)}`,
      );
      rmSync(join(wdir, "_v.scss"));
      // Wait for the watch to NOTICE, so the assertion is about what it
      // did rather than about it not having looked yet.
      assert.ok(
        await until(() => /Error|error/.test(log), 20000),
        `dangling: the broken import was never reported: ${JSON.stringify(log)}`,
      );
      await new Promise((r) => setTimeout(r, 400));
      assert.ok(!existsSync(join(wdir, "_v.scss")), "the deleted dependency was recreated through the dangling symlink");
    } finally {
      proc.kill();
    }
  }

  // The same, through a CHAIN, and with the dependency missing from the
  // very first moment.
  //
  // `out.css -> middle.scss -> _v.scss` answers `middle.scss` after one
  // `readlink`, which matches no source — and the write then follows the
  // rest of the chain and recreates `_v.scss` anyway.
  //
  // The startup shape is not the same question: the first compile throws
  // before it reports what it loaded, so `known` holds the entry alone
  // and no amount of comparing can recognise `_v.scss`. What settles it
  // is the failure path refusing to follow a link that goes nowhere.
  for (const shape of ["chain", "startup"]) {
    const wdir = mkdtempSync(join(tmpdir(), `sasso-watchdangle-${shape}-`));
    writeFileSync(join(wdir, "main.scss"), `@use "v" as v;\n.a { color: v.$c; }\n`);
    if (shape === "chain") {
      writeFileSync(join(wdir, "_v.scss"), `$c: red;\n`);
      symlinkSync(join(wdir, "_v.scss"), join(wdir, "middle.scss"));
      symlinkSync(join(wdir, "middle.scss"), join(wdir, "out.css"));
    } else {
      symlinkSync(join(wdir, "_v.scss"), join(wdir, "out.css")); // dangling already
    }
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      assert.ok(
        await until(() => log.includes("watching for changes"), 20000),
        `${shape}: the watch never started: ${JSON.stringify(log)}`,
      );
      if (shape === "chain") rmSync(join(wdir, "_v.scss"));
      assert.ok(
        await until(() => /error/i.test(log), 20000),
        `${shape}: the broken import was never reported: ${JSON.stringify(log)}`,
      );
      await new Promise((r) => setTimeout(r, 400));
      assert.ok(!existsSync(join(wdir, "_v.scss")), `${shape}: the missing source was created through the link`);
    } finally {
      proc.kill();
    }
  }

  // …and the two shapes the refusal must NOT break. A failing compile
  // still writes its error stylesheet into a tree that was never there —
  // dart does, and it is the one thing the browser would have had — and a
  // SUCCEEDING compile still creates the target of a dangling link,
  // because `out.css -> dist/out.css` before a first build is an ordinary
  // way to arrange things.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchtree-"));
    writeFileSync(join(wdir, "main.scss"), ".a { color: ; }\n"); // broken
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "dist/css/out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const out = join(wdir, "dist", "css", "out.css");
    try {
      const deadline = Date.now() + 20000;
      let wrote = false;
      while (Date.now() < deadline && !wrote) {
        try {
          wrote = readFileSync(out, "utf8").startsWith("/* Error:");
        } catch {
          /* not yet */
        }
        if (!wrote) await new Promise((r) => setTimeout(r, 25));
      }
      assert.ok(wrote, `the error stylesheet was not written into a tree that did not exist: ${JSON.stringify(log)}`);
    } finally {
      proc.kill();
    }
  }
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchmake-"));
    writeFileSync(join(wdir, "main.scss"), ".a { color: red; }\n");
    mkdirSync(join(wdir, "dist"));
    symlinkSync(join(wdir, "dist", "out.css"), join(wdir, "out.css")); // dangling
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: "ignore",
    });
    const target = join(wdir, "dist", "out.css");
    try {
      const deadline = Date.now() + 20000;
      let made = false;
      while (Date.now() < deadline && !made) {
        try {
          made = readFileSync(target, "utf8").includes("red");
        } catch {
          /* not yet */
        }
        if (!made) await new Promise((r) => setTimeout(r, 25));
      }
      assert.ok(made, "a successful compile did not create the target of a dangling output link");
    } finally {
      proc.kill();
    }
  }

  // A symlinked output gets its error stylesheet once the watch has
  // WRITTEN it — and not before.
  //
  // That is the whole rule, and it is narrower than "never write through
  // a symlink": a link this watch has written through is demonstrably an
  // output, whatever it points at. Before the first successful build it
  // is only a link, and `aliasesASource` cannot always tell what is on
  // the other end — a dependency that exists and fails to LOAD never
  // reaches `known`, because the compile throws before it says what it
  // loaded.
  //
  // Both halves are here because either alone is satisfiable by a rule
  // that is wrong: "always refuse" passes the first, "always allow"
  // passes the second.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchlivelink-"));
    const GOOD = ".a { color: red; }\n";
    const BROKEN = ".a { color: ; }\n";
    writeFileSync(join(wdir, "main.scss"), BROKEN);
    mkdirSync(join(wdir, "dist"));
    writeFileSync(join(wdir, "dist", "out.css"), "/* stale */\n"); // the target EXISTS
    symlinkSync(join(wdir, "dist", "out.css"), join(wdir, "out.css"));
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const target = join(wdir, "dist", "out.css");
    const css = () => {
      try {
        return readFileSync(target, "utf8");
      } catch {
        return "";
      }
    };
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      // Nothing written yet, so the stale target is left exactly alone.
      assert.ok(await until(() => /error/i.test(log), 20000), `livelink: the break was never reported: ${JSON.stringify(log)}`);
      await new Promise((r) => setTimeout(r, 500));
      assert.equal(css(), "/* stale */\n", "a symlinked output was written before the watch had ever written it");

      // One successful build, and the link is demonstrably an output.
      writeFileSync(join(wdir, "main.scss"), GOOD);
      assert.ok(await until(() => css().includes("red"), 20000), "livelink: the fix never landed");
      await new Promise((r) => setTimeout(r, 400));

      // Now a failure DOES leave the error stylesheet there, as dart does.
      writeFileSync(join(wdir, "main.scss"), BROKEN);
      assert.ok(
        await until(() => css().startsWith("/* Error:"), 20000),
        `a symlinked output the watch had written was refused its error stylesheet: ${JSON.stringify(css())}`,
      );

      // …and a SECOND consecutive failure behaves like the first. What
      // the watch has written is a fact about the run, not something a
      // failure undoes — `onDisk` is cleared by one, and sharing that
      // reset would silence every failure after the first.
      await new Promise((r) => setTimeout(r, 400));
      writeFileSync(target, "/* wiped */\n");
      writeFileSync(join(wdir, "main.scss"), ".b { color: ; }\n"); // a different break
      assert.ok(
        await until(() => css().startsWith("/* Error:"), 20000),
        `the second failure in a row was refused its error stylesheet: ${JSON.stringify(css())}`,
      );
    } finally {
      proc.kill();
    }
  }

  // The dependency EXISTS and fails to LOAD, so it never reaches
  // `known` — the compile throws before it reports what it loaded — and
  // the link to it resolves perfectly well, so nothing about the link
  // looks wrong either.
  //
  // A parse error rather than a permission bit, for the reason #159
  // recorded: the file has to stay WRITABLE for the bug to be reachable
  // at all, so a `chmod 000` dependency would pass for the wrong reason.
  //
  // And rather than invalid UTF-8, which was the first choice here and
  // is ENGINE-DEPENDENT: the native addon refuses to read such a file
  // ("stream did not contain valid UTF-8") while wasm reads it lossily
  // and compiles, so the case simply did not fail on the wasm path and
  // the test timed out waiting for an error that was never coming. CI
  // caught that, this machine did not — the addon loads here and not
  // there. See #179.
  //
  // The error that reaches the write does not name the dependency either
  // — it is `Undefined variable` in `main.scss`, the second failure, not
  // the parse error in `_v.scss`. So the span is no help and this is
  // settled by "the watch has never written this output" instead.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchbadload-"));
    writeFileSync(join(wdir, "main.scss"), `@use "v" as v;\n.a { color: v.$c; }\n`);
    const dep = join(wdir, "_v.scss");
    const bytes = Buffer.from("$c: ;\n");
    writeFileSync(dep, bytes);
    symlinkSync(dep, join(wdir, "out.css"));
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      assert.ok(await until(() => /error/i.test(log), 20000), `badload: nothing was reported: ${JSON.stringify(log)}`);
      await new Promise((r) => setTimeout(r, 500));
      assert.ok(
        readFileSync(dep).equals(bytes),
        "a dependency that failed to LOAD was overwritten by the error stylesheet about it",
      );
    } finally {
      proc.kill();
    }
  }

  // Refusing the WRITE is not refusing the branch. The first version of
  // this skipped the whole failure path for a broken link and took two
  // unrelated things with it.
  //
  // `onDisk` is the serious one: the watch remembers the CSS it last
  // wrote so a catch-up does not write it again. Forgetting to forget it
  // means "break the file, then fix it back to exactly what it was"
  // matches the remembered value, skips the write, and the output never
  // comes back — #159, measured again here.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchondisk-"));
    const GOOD = ".a { color: red; }\n";
    writeFileSync(join(wdir, "main.scss"), GOOD);
    mkdirSync(join(wdir, "dist"));
    const target = join(wdir, "dist", "out.css");
    symlinkSync(target, join(wdir, "out.css"));
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    const css = () => {
      try {
        return readFileSync(target, "utf8");
      } catch {
        return "";
      }
    };
    try {
      assert.ok(await until(() => css().includes("red"), 20000), "onDisk: the first compile never landed");
      await new Promise((r) => setTimeout(r, 400));
      rmSync(target); // the link now dangles
      writeFileSync(join(wdir, "main.scss"), ".a { color: ; }\n");
      assert.ok(await until(() => /error/i.test(log), 20000), `onDisk: the break was never reported: ${JSON.stringify(log)}`);
      await new Promise((r) => setTimeout(r, 400));
      writeFileSync(join(wdir, "main.scss"), GOOD); // back to EXACTLY the old bytes
      assert.ok(
        await until(() => css().includes("red"), 20000),
        "fixing the source back to what it was left the output missing for good",
      );
    } finally {
      proc.kill();
    }
  }

  // …and `--no-error-css` still removes the output even when the watch
  // has never written it, which is the case that separates "refuse the
  // WRITE" from "skip the branch": the second takes the removal with it.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchunlink0-"));
    writeFileSync(join(wdir, "main.scss"), ".a { color: ; }\n"); // broken from the start
    mkdirSync(join(wdir, "dist"));
    writeFileSync(join(wdir, "dist", "out.css"), "/* stale */\n");
    symlinkSync(join(wdir, "dist", "out.css"), join(wdir, "out.css"));
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--no-error-css", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      assert.ok(await until(() => /error/i.test(log), 20000), `unlink0: nothing was reported: ${JSON.stringify(log)}`);
      await new Promise((r) => setTimeout(r, 500));
      let stillThere = true;
      try {
        lstatSync(join(wdir, "out.css"));
      } catch {
        stillThere = false;
      }
      assert.ok(!stillThere, "--no-error-css left an output link the watch had never written");
    } finally {
      proc.kill();
    }
  }

  // …and the same after it HAS written it, where the link dangles.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchunlink-"));
    writeFileSync(join(wdir, "main.scss"), ".a { color: red; }\n");
    mkdirSync(join(wdir, "dist"));
    const target = join(wdir, "dist", "out.css");
    symlinkSync(target, join(wdir, "out.css"));
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--no-error-css", "--poll", "--watch", "main.scss", "out.css"], {
      cwd: wdir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      assert.ok(
        await until(() => {
          try {
            return readFileSync(target, "utf8").includes("red");
          } catch {
            return false;
          }
        }, 20000),
        "unlink: the first compile never landed",
      );
      await new Promise((r) => setTimeout(r, 400));
      rmSync(target); // the link now dangles
      writeFileSync(join(wdir, "main.scss"), ".a { color: ; }\n");
      assert.ok(await until(() => /error/i.test(log), 20000), `unlink: the break was never reported: ${JSON.stringify(log)}`);
      await new Promise((r) => setTimeout(r, 400));
      let stillThere = true;
      try {
        lstatSync(join(wdir, "out.css"));
      } catch {
        stillThere = false;
      }
      assert.ok(!stillThere, "--no-error-css left a dangling output link in place");
    } finally {
      proc.kill();
    }
  }

  // …and the ordinary case is untouched by all of this: a real output,
  // reached through a symlinked DIRECTORY, is still written. Without
  // this the guard could be satisfied by refusing to write anything.
  {
    const wdir = mkdtempSync(join(tmpdir(), "sasso-watchlinkok-"));
    mkdirSync(join(wdir, "real"));
    writeFileSync(join(wdir, "real", "main.scss"), `.a { color: red; }\n`);
    symlinkSync(join(wdir, "real"), join(wdir, "link"));
    const outFile = join(wdir, "link", "out.css");
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--poll", "--watch", join(wdir, "link", "main.scss"), outFile], {
      stdio: "ignore",
    });
    try {
      const deadline = Date.now() + 20000;
      let wrote = false;
      while (Date.now() < deadline && !wrote) {
        try {
          wrote = readFileSync(outFile, "utf8").includes("red");
        } catch {
          /* not yet */
        }
        if (!wrote) await new Promise((r) => setTimeout(r, 25));
      }
      assert.ok(wrote, "a real output under a symlinked directory was not written");
    } finally {
      proc.kill();
    }
  }

  console.log("ok: cli --watch — an output that is a source by another name is declined, dangling or not, and a real one is not");
}

// === Phase 3b: CLI --watch, what it SAYS ===
//
// The functional watch test above starts the child with `stdio: "ignore"`
// and only waits for the output file, so every property of the narration
// was untested: a regression to stderr, to the old wording, to no
// timestamp, or to suppressing the banner under --quiet would all have
// passed. #141 changed all four, so all four are pinned here.
{
  const wdir = mkdtempSync(join(tmpdir(), "sasso-watchsay-"));
  const src = join(wdir, "one.scss");
  const out = join(wdir, "one.css");
  writeFileSync(src, ".a { color: red; }\n");

  const capture = async (extra) => {
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", ...extra, "--watch", src, out], {
      stdio: ["ignore", "pipe", "pipe"],
    });
    let stdout = "", stderr = "";
    proc.stdout.on("data", (b) => (stdout += b));
    proc.stderr.on("data", (b) => (stderr += b));
    const until = async (pred, ms) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        if (pred()) return true;
        await new Promise((r) => setTimeout(r, 25));
      }
      return false;
    };
    try {
      // Asserted rather than awaited. `until` returns false at its
      // deadline, and dropping that lets a watch that never started reach
      // the narration assertions below, where it fails as "the banner is
      // missing" — a true statement about the wrong thing.
      assert.ok(await until(() => stdout.includes("watching for changes"), 15000), `the watch never announced itself: ${stderr}`);
      writeFileSync(src, ".a { color: blue; }\n"); // one recompile
      assert.ok(await until(() => readFileSync(out, "utf8").includes("blue"), 15000), `the recompile never landed: ${stderr}`);
      await new Promise((r) => setTimeout(r, 250)); // let the line land
    } finally {
      proc.kill();
    }
    return { stdout, stderr };
  };

  // Seconds, like the binary: dart's native build prints them and its
  // dart2js build drops them by a truncation bug (#190).
  const STAMPED = /^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] Compiled .*one\.scss to .*one\.css\.$/;
  const loud = await capture([]);
  const lines = loud.stdout.split("\n");
  assert.ok(STAMPED.test(lines[0]), `cli --watch: the first compile is stamped: ${lines[0]}`);
  assert.equal(
    lines[1],
    "Sass is watching for changes. Press Ctrl-C to stop.",
    "cli --watch: dart's banner, word for word",
  );
  assert.equal(lines[2], "", "cli --watch: dart leaves one blank line after the banner");
  assert.ok(
    lines.slice(3).some((l) => STAMPED.test(l)),
    `cli --watch: the recompile is announced too: ${loud.stdout}`,
  );
  assert.ok(
    !loud.stderr.includes("Compiled") && !loud.stderr.includes("watching"),
    `cli --watch: none of it belongs on stderr: ${loud.stderr}`,
  );

  // --quiet silences the compile lines and keeps the banner, which is the
  // only sign the process is alive — dart's behaviour, measured.
  writeFileSync(src, ".a { color: red; }\n");
  rmSync(out, { force: true });
  const quiet = await capture(["--quiet"]);
  assert.ok(
    !quiet.stdout.includes("Compiled"),
    `cli --watch --quiet: no compile lines: ${quiet.stdout}`,
  );
  assert.ok(
    quiet.stdout.includes("Sass is watching for changes. Press Ctrl-C to stop."),
    `cli --watch --quiet: the banner still prints: ${quiet.stdout}`,
  );
  console.log("ok: cli --watch — stdout, dart's banner and stamp, --quiet keeps the banner");
}

// === --error-css: what a failure leaves behind ===
//
// This CLI accepted `--error-css` and ignored it, so a failing compile
// always removed the output where dart replaces it with a stylesheet
// describing the error. In a --watch loop that is the whole mechanism
// for seeing the error: the page went unstyled instead of saying why.
//
// Measured against dart-sass 1.104.1 and the native binary, which agree
// on all four:
//
//   a compile error, default   -> the output becomes error CSS
//   the same, --no-error-css   -> the output is removed
//   a file that cannot be READ -> the output is left exactly as it was
//   --no-css                   -> the output is left exactly as it was
//
// The third is the one this CLI also had wrong in the other direction:
// an unreadable entry is not a compile error, there is nothing to
// render, and the previous build stays.
{
  const { asciiGutter, errorCss } = await import("./npm/_errorcss.mjs");

  // The gutter swap, which is how the ASCII half of the comment is
  // derived from the Unicode message the engine hands over.
  {
    const unicode = 'Error: oops\n  ╷\n1 │ .a { b: c; }\n  │        ^\n  ╵\n  x.scss 1:8  root stylesheet';
    assert.equal(
      asciiGutter(unicode),
      "Error: oops\n  ,\n1 | .a { b: c; }\n  |        ^\n  '\n  x.scss 1:8  root stylesheet",
      "error-css: the gutter becomes , | '",
    );
    // Anchored to the gutter, NOT a blanket replace: a stylesheet that
    // contains a box-drawing character keeps it when the diagnostic
    // quotes the line back.
    assert.equal(
      asciiGutter('  ╷\n1 │ .a { content: "│"; }\n  ╵'),
      '  ,\n1 | .a { content: "│"; }\n  \'',
      "error-css: a box character in the SOURCE line is left alone",
    );
  }

  // `*/` in the message would close the comment; dart swaps the slash.
  assert.match(errorCss("Error: a */ b"), /\* Error: a \*∕ b \*\//, "error-css: */ cannot close the comment");
  // Non-ASCII in `content:` is escaped as `\hex `.
  assert.match(errorCss("Error: x\n  ╷"), /\\2577 /, "error-css: the box character is escaped for content");

  // And end to end, all four rules.
  const dir = mkdtempSync(join(tmpdir(), "sasso-errcss-"));
  writeFileSync(join(dir, "good.scss"), ".ok { a: b; }\n");
  writeFileSync(join(dir, "bad.scss"), '@use "nope";\n');
  const out = join(dir, "o.css");
  const run = (...args) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", ...args], { encoding: "utf8", cwd: dir });
  const rebuild = () => {
    rmSync(out, { force: true });
    run("good.scss", "o.css");
  };

  rebuild();
  run("bad.scss", "o.css");
  const css = readFileSync(out, "utf8");
  assert.match(css, /^\/\* Error: Can't find stylesheet to import\./, "error-css: the comment leads");
  assert.match(css, /^ \* +,$/m, "error-css: the comment's gutter is ASCII");
  assert.match(css, /body::before \{/, "error-css: and the rule follows");
  assert.match(css, /content: "Error: [^"]*\\2577 /, "error-css: content keeps the Unicode gutter, escaped");

  // A FIRST failure into a tree that does not exist yet. `emit` creates
  // parents for a successful write; this branch did not, so the one case
  // where the error stylesheet is the only thing the browser would have
  // had reported ENOENT and wrote nothing. dart and the binary both
  // create the directory.
  rmSync(join(dir, "dist"), { recursive: true, force: true });
  run("bad.scss", "dist/css/out.css");
  assert.match(
    readFileSync(join(dir, "dist", "css", "out.css"), "utf8"),
    /^\/\* Error: /,
    "error-css: a nested destination is created, as it is for a successful write",
  );

  rebuild();
  run("--no-error-css", "bad.scss", "o.css");
  assert.ok(!existsSync(out), "error-css: --no-error-css removes the output instead");

  rebuild();
  run("/no/such/file.scss", "o.css");
  assert.equal(
    readFileSync(out, "utf8"),
    ".ok {\n  a: b;\n}\n",
    "error-css: an unreadable entry is not a compile error — the last build stays",
  );

  rebuild();
  run("--no-css", "bad.scss", "o.css");
  assert.equal(readFileSync(out, "utf8"), ".ok {\n  a: b;\n}\n", "error-css: --no-css touches nothing");

  // Writing to STDOUT rather than a file, the flag is three-valued: the
  // default is silent and only an explicit --error-css prints. Measured:
  //   sass bad.scss                 stdout 0B
  //   sass --error-css bad.scss     stdout 546B
  //   sass --no-error-css bad.scss  stdout 0B
  assert.equal(run("bad.scss").stdout, "", "error-css: to stdout, the default is silent");
  assert.match(
    run("--error-css", "bad.scss").stdout,
    /^\/\* Error: /,
    "error-css: …and an explicit --error-css prints the stylesheet",
  );
  assert.equal(run("--no-error-css", "bad.scss").stdout, "", "error-css: --no-error-css stays silent");

  rmSync(dir, { recursive: true, force: true });
  console.log("ok: --error-css — written, removed, or left alone, as dart does");
}

// === the watch event filter, including the branch this platform cannot reach ===
//
// `fs.watch` may call back with no filename. macOS and Linux always name
// their events, so no amount of writing files here reaches that branch —
// which is exactly why the decision lives in its own pure module and is
// tested as a table rather than through a subprocess.
//
// The case that matters: a nameless event must NOT bypass the self-output
// check, or the compile that writes out.css triggers the compile that
// writes out.css.
{
  const { triggersRecompile } = await import("./npm/_watchfilter.mjs");
  const known = new Set(["/p/main.scss", "/p/_v.scss"]);
  const ours = new Set(["/p/out.css", "/p/out.css.map"]);
  const ask = (path, { failing = false, moved = false, elseChanged = moved } = {}) =>
    triggersRecompile({
      path,
      known,
      ours,
      failing,
      anyKnownMoved: () => moved,
      anythingElseChanged: () => elseChanged,
    });

  // Named events, compiling normally.
  assert.equal(ask("/p/_v.scss"), true, "filter: a dependency changed");
  assert.equal(ask("/p/main.scss"), true, "filter: the entry changed");
  assert.equal(ask("/p/unrelated.txt"), false, "filter: something else in the directory");
  assert.equal(ask("/p/out.css"), false, "filter: our own output never retriggers");
  assert.equal(ask("/p/out.css.map"), false, "filter: nor its source map");

  // Named events while the last compile failed: the fix may be a file
  // that did not exist when `known` was taken.
  assert.equal(ask("/p/_new.scss", { failing: true }), true, "filter: any file may be the fix");
  assert.equal(ask("/p/out.css", { failing: true }), false, "filter: except still not ours");

  // Nameless events — the branch no test on this platform can provoke.
  assert.equal(ask(null, { moved: false }), false, "filter: nameless and nothing moved — do not loop");
  assert.equal(ask(null, { moved: true }), true, "filter: nameless but a dependency moved");
  assert.equal(
    ask(null, { failing: true, elseChanged: true }),
    true,
    "filter: nameless while failing, and a neighbour moved — that may be the fix",
  );
  // The one that loops: the error path DELETES the output, and on a
  // platform reporting that removal without a filename, `failing` alone
  // would take it for the user's fix — recompile, fail, delete, repeat.
  assert.equal(
    ask(null, { failing: true, elseChanged: false }),
    false,
    "filter: nameless while failing with nothing but ours changed — do not chase our own removal",
  );

  console.log("ok: watch event filter — named, nameless, ours, and failing");
}

// === waiting for a directory that does not exist yet ===
//
// The invariant is one open handle per target however many times the
// probe re-arms. Breaking it is not a slow leak: each new watcher also
// sees the events that spawned it, so twenty unrelated writes in the
// ancestor directory produced `EMFILE: too many open files, watch`. No
// --watch test provokes that without becoming a stress test, and a
// stress test that passes at nineteen writes says nothing.
{
  const { makeProbe } = await import("./npm/_probe.mjs");

  /** A filesystem the test decides the contents of. */
  const fake = (present) => {
    const handles = [];
    const watchers = new Map(); // dir -> callbacks
    const watch = (dir, cb) => {
      const h = { dir, cb, closed: false, close: () => (h.closed = true) };
      handles.push(h);
      const list = watchers.get(dir) ?? [];
      list.push(h);
      watchers.set(dir, list);
      return h;
    };
    return {
      handles,
      open: () => handles.filter((h) => !h.closed).length,
      fire: (dir) => (watchers.get(dir) ?? []).filter((h) => !h.closed).forEach((h) => h.cb()),
      watch,
      exists: (p) => present.has(p),
      dirname: (p) => p.slice(0, p.lastIndexOf("/")) || "/",
    };
  };

  // The ancestor is busy and the target never appears.
  {
    const present = new Set(["/", "/p"]);
    const appeared = [];
    const fs = fake(present);
    const probe = makeProbe({ ...fs, onAppear: (t) => appeared.push(t) });
    probe.arm("/p/a/b/generated");
    assert.equal(probe.size, 1, "probe: one handle to start");
    for (let i = 0; i < 20; i++) fs.fire("/p");
    assert.equal(probe.size, 1, `probe: still one handle after 20 events (had ${probe.size})`);
    assert.equal(fs.open(), 1, `probe: and only one is left open (had ${fs.open()})`);
    assert.deepEqual(appeared, [], "probe: the target never appeared, so nothing fired");
  }

  // The chain fills in one level at a time: re-arm deeper each time,
  // still one handle, and fire only when the target itself exists.
  {
    const present = new Set(["/", "/p"]);
    const appeared = [];
    const fs = fake(present);
    const probe = makeProbe({ ...fs, onAppear: (t) => appeared.push(t) });
    probe.arm("/p/a/b");
    present.add("/p/a");
    fs.fire("/p");
    assert.equal(probe.size, 1, "probe: one handle after re-arming deeper");
    assert.deepEqual(appeared, [], "probe: /p/a is not the target");
    present.add("/p/a/b");
    fs.fire("/p/a");
    assert.deepEqual(appeared, ["/p/a/b"], "probe: the target appeared");
  }

  // closeAll leaves nothing behind — rewatch calls it on every compile.
  {
    const fs = fake(new Set(["/", "/p"]));
    const probe = makeProbe({ ...fs, onAppear: () => {} });
    probe.arm("/p/x/one");
    probe.arm("/p/y/two");
    assert.equal(probe.size, 2, "probe: one per target");
    probe.closeAll();
    assert.equal(probe.size, 0, "probe: closeAll forgets them");
    assert.equal(fs.open(), 0, "probe: and actually closes them");
  }

  console.log("ok: probe — one handle per target, re-arms deeper, closes cleanly");
}

// === one live handle per directory, and what happens when one dies ===
//
// None of this is reachable from a --watch test on a healthy machine:
// an fs.watch handle does not fail to order. The failures are real
// though, and the way they present is silence — the session keeps
// running and stops noticing saves in one directory.
//
// The fake copies node's actual behaviour, from `internal/fs/watchers`
// in the runtime this suite runs on (v22.22.3): before emitting `error`
// node closes and nulls the handle and deliberately does NOT emit
// `close`, and a watch that cannot be STARTED throws synchronously
// instead.
//
// It also copies what the platforms do to a watched directory that is
// deleted, measured with the same probe on both:
//
//              handle after the delete   recreated: still delivers?
//   macOS      alive (FSEvents is by     YES
//              path, not inode)
//   Linux      dead                      NO
//
// and on NEITHER an `error` or a `close`. So the fake's handle for a
// deleted directory goes quiet without announcing anything, which is
// the case that makes `sync` look at the filesystem.
{
  const { makeWatchers } = await import("./npm/_watchers.mjs");

  /** A `watch` the test decides the fate of, over a filesystem it owns. */
  const fake = ({ startError = null, present = null } = {}) => {
    const all = [];
    const exists = (dir) => present === null || present.has(dir);
    const watch = (dir, cb) => {
      if (startError && startError.dir === dir) {
        const e = new Error(startError.message);
        e.code = startError.code;
        throw e;
      }
      if (!exists(dir)) {
        const e = new Error(`ENOENT: no such file or directory, watch '${dir}'`);
        e.code = "ENOENT";
        throw e;
      }
      const listeners = new Map();
      const h = {
        dir,
        cb,
        closed: false,
        close() {
          h.closed = true;
          // A real `close` event does not have to arrive before the
          // next statement. `deferClose` lets a test hold it back.
          if (!h.deferClose) h.emit("close");
        },
        emit: (name, ...args) => (listeners.get(name) ?? []).forEach((f) => f(...args)),
        on: (name, f) => {
          const list = listeners.get(name) ?? [];
          list.push(f);
          listeners.set(name, list);
          return h;
        },
        /** What node does: close, null the handle, emit only `error`. */
        die(message = "EPERM") {
          h.closed = true;
          h.emit("error", new Error(message));
        },
      };
      all.push(h);
      return h;
    };
    return {
      watch,
      exists,
      all,
      openHandles: () => all.filter((h) => !h.closed),
      of: (dir) => all.filter((h) => h.dir === dir),
      liveOf: (dir) => all.filter((h) => h.dir === dir && !h.closed),
    };
  };

  const setup = (opts) => {
    const fs = fake(opts);
    const events = [];
    const said = [];
    const missing = [];
    const w = makeWatchers({
      watch: fs.watch,
      exists: fs.exists,
      onEvent: (d, _e, fn) => events.push(`${d}/${fn}`),
      onMissing: (d) => missing.push(d),
      report: (line) => said.push(line),
      retries: opts?.retries ?? 3,
    });
    return { fs, w, events, said, missing };
  };

  // Steady state: syncing the same set again must touch nothing. This is
  // the 1-in-30 lost save — rebuilding every watcher on every compile
  // leaves a gap in which a save is not seen.
  {
    const { fs, w } = setup();
    w.sync(new Set(["/a", "/b"]));
    assert.equal(w.size, 2, "watchers: one per directory");
    const first = [...fs.all];
    w.sync(new Set(["/a", "/b"]));
    w.sync(new Set(["/a", "/b"]));
    assert.deepEqual(fs.all, first, "watchers: an unchanged set opens nothing new");
    assert.equal(fs.openHandles().length, 2, "watchers: and closes nothing");
  }

  // A directory that leaves is closed; one that arrives is opened.
  {
    const { fs, w } = setup();
    w.sync(new Set(["/a", "/b"]));
    w.sync(new Set(["/b", "/c"]));
    assert.equal(w.size, 2, "watchers: the set is what was asked for");
    assert.equal(fs.liveOf("/a").length, 0, "watchers: the departed one is closed");
    assert.equal(fs.liveOf("/b").length, 1, "watchers: the kept one is untouched");
    assert.equal(fs.of("/b").length, 1, "watchers: … not reopened");
    assert.equal(fs.liveOf("/c").length, 1, "watchers: the new one is open");
  }

  // A handle that errors is REPLACED, not merely forgotten. Forgetting
  // it is what the first version of this did: the directory is then
  // unwatched for the life of the session and nothing says so.
  {
    const { fs, w, events } = setup();
    w.sync(new Set(["/a"]));
    fs.of("/a")[0].die("EPERM");
    assert.equal(w.size, 1, "watchers: still watching after an error");
    assert.equal(fs.liveOf("/a").length, 1, "watchers: with a live handle, not a dead one");
    assert.notEqual(fs.of("/a")[1], fs.of("/a")[0], "watchers: a NEW handle, re-armed");
    fs.liveOf("/a")[0].cb("change", "x.scss");
    assert.deepEqual(events, ["/a/x.scss"], "watchers: and the new one delivers");
  }

  // node does not fire `close` on the error path, so the `error`
  // listener cannot be left to the `close` one. Without its own
  // listener the entry is never dropped AND the event throws.
  {
    const { fs, w } = setup();
    w.sync(new Set(["/a"]));
    const h = fs.of("/a")[0];
    let closeFired = false;
    h.on("close", () => (closeFired = true));
    h.die();
    assert.equal(closeFired, false, "watchers: node's error path fires no close (the fake copies it)");
    assert.equal(w.size, 1, "watchers: the error listener is what re-armed it");
  }

  // A directory that fails forever is given up on — once, out loud,
  // naming the directory — rather than re-armed in a hot loop.
  {
    const { fs, w, said } = setup({ retries: 3 });
    w.sync(new Set(["/bad"]));
    for (let i = 0; i < 25; i++) fs.liveOf("/bad")[0]?.die("EPERM");
    assert.equal(fs.of("/bad").length, 4, `watchers: 1 + 3 re-arms and no more (opened ${fs.of("/bad").length})`);
    assert.equal(w.size, 0, "watchers: the dead directory is not claimed as covered");
    assert.equal(said.length, 1, `watchers: said once, not ${said.length} times`);
    assert.match(said[0], /gave up watching \/bad/, "watchers: … and named the directory");
    assert.match(said[0], /will be missed/, "watchers: … and what it costs");
  }

  // A rewatch is a fresh chance — the next compile reopens a directory
  // that was given up on — but a directory that is simply broken must
  // not produce a line per compile for the rest of the session.
  {
    const { fs, w, said } = setup({ retries: 1 });
    const kill = () => {
      let h;
      while ((h = fs.liveOf("/bad")[0])) h.die("EPERM");
    };
    w.sync(new Set(["/bad"]));
    kill();
    assert.equal(said.length, 1, "watchers: the first give-up is said");
    for (let compile = 0; compile < 5; compile++) {
      w.sync(new Set(["/bad"])); // every later compile tries again
      assert.ok(fs.liveOf("/bad").length > 0, "watchers: a rewatch does retry it");
      kill();
    }
    assert.equal(said.length, 1, `watchers: and still said once, not ${said.length} times`);
  }

  // The budget is for a burst, not for the life of the process: a
  // delivered event proves the watcher works.
  {
    const { fs, w, said } = setup({ retries: 2 });
    w.sync(new Set(["/a"]));
    fs.liveOf("/a")[0].die();
    fs.liveOf("/a")[0].cb("change", "ok.scss"); // it works again
    fs.liveOf("/a")[0].die();
    fs.liveOf("/a")[0].die();
    assert.equal(w.size, 1, "watchers: an event reset the failure budget");
    assert.deepEqual(said, [], "watchers: and nothing was given up on");
  }

  // A late `close` from OUR teardown must not evict a newer handle for
  // the same directory — that is the teardown gap coming back.
  {
    const { fs, w } = setup();
    w.sync(new Set(["/a"]));
    const first = fs.of("/a")[0];
    first.deferClose = true; // its close event lands later, as a real one can
    w.sync(new Set([])); // drops /a, closing the first handle
    w.sync(new Set(["/a"])); // and immediately wants it back
    const second = fs.liveOf("/a")[0];
    assert.notEqual(second, first, "watchers: a new handle for the reopened directory");
    first.emit("close"); // the old handle's close finally lands
    assert.equal(w.size, 1, "watchers: the late close did not evict the new handle");
    assert.equal(fs.liveOf("/a")[0], second, "watchers: … and it is still the live one");
  }

  // A directory that is not there is not a fault — the probe waits for
  // it. ENOSPC is, and swallowing it means a watch that looks fine and
  // sees nothing.
  {
    const { w, said } = setup({ startError: { dir: "/gone", code: "ENOENT", message: "ENOENT" } });
    w.sync(new Set(["/gone"]));
    assert.equal(w.size, 0, "watchers: a missing directory is simply not watched");
    assert.deepEqual(said, [], "watchers: … and is not worth a warning");
  }
  {
    const { w, said } = setup({
      startError: { dir: "/full", code: "ENOSPC", message: "System limit for number of file watchers reached" },
    });
    w.sync(new Set(["/full"]));
    assert.equal(w.size, 0, "watchers: a directory that cannot be watched is not claimed");
    assert.equal(said.length, 1, "watchers: ENOSPC is said out loud");
    assert.match(said[0], /System limit/, "watchers: … with the reason the user can act on");
  }

  // A watched directory deleted out from under a live handle. On Linux
  // that handle is dead; on macOS it still works; on neither does it
  // say so. Without a look at the filesystem the entry claims the
  // directory is covered for the rest of the session.
  {
    const present = new Set(["/a", "/b"]);
    const { fs, w, missing } = setup({ present });
    w.sync(new Set(["/a", "/b"]));
    const doomed = fs.of("/a")[0];
    present.delete("/a"); // rm -rf a

    w.sync(new Set(["/a", "/b"])); // the next compile
    assert.equal(w.size, 1, "watchers: the vanished directory is no longer claimed");
    assert.equal(doomed.closed, true, "watchers: and its handle is let go");
    assert.deepEqual(missing, ["/a"], "watchers: something is now waiting for it to come back");

    present.add("/a"); // and it is back
    w.sync(new Set(["/a", "/b"]));
    assert.equal(w.size, 2, "watchers: the recreated directory is watched again");
    assert.equal(fs.liveOf("/a").length, 1, "watchers: with exactly one live handle");
    fs.liveOf("/a")[0].cb("change", "v.scss");
    assert.equal(fs.liveOf("/a").length, 1, "watchers: … that delivers");
  }

  // An `error` from a handle `sync` has already dropped must not put
  // the directory back. Re-arming for a handle nobody holds resurrects
  // a directory that was deliberately let go.
  {
    const { fs, w, missing } = setup();
    w.sync(new Set(["/a"]));
    const dropped = fs.of("/a")[0];
    w.sync(new Set([])); // /a is no longer wanted
    assert.equal(w.size, 0, "watchers: dropped");
    dropped.die("EPERM"); // its error lands afterwards
    assert.equal(w.size, 0, "watchers: a stale error did not resurrect it");
    assert.equal(fs.of("/a").length, 1, "watchers: and opened no new handle");
    assert.deepEqual(missing, [], "watchers: nor asked anyone to wait for it");
  }

  // The same, when the directory has been REOPENED in the meantime:
  // re-arming here would leave two live handles on one directory, every
  // event delivered twice, and the replacement leaked.
  {
    const { fs, w } = setup();
    w.sync(new Set(["/a"]));
    const first = fs.of("/a")[0];
    first.deferClose = true;
    w.sync(new Set([]));
    w.sync(new Set(["/a"]));
    const second = fs.liveOf("/a")[0];
    first.die("EPERM"); // the old handle's error, long after it was replaced
    assert.equal(fs.liveOf("/a").length, 1, `watchers: one live handle, not ${fs.liveOf("/a").length}`);
    assert.equal(fs.liveOf("/a")[0], second, "watchers: and it is the replacement");
    assert.equal(w.size, 1, "watchers: still exactly one entry");
  }

  console.log("ok: watchers — steady state, re-arm on error, give up once, ENOSPC is not ENOENT");
}

// === how a stack frame names a file, on BOTH engines ===
//
// The entry reached the compiler as a `file://` URL — it has to, because the
// importer bridge resolves relative `@use` against it — and went straight into
// the frame, scheme and all. Measured against dart-sass 1.104.1 before the fix
// (#153), one error with a dependency frame and an entry frame:
//
//   dart         src/_dep.scss 2:10  m()      src/main.scss 2:6  root stylesheet
//   binary       src/_dep.scss 2:14  m()      src/main.scss 2:6  root stylesheet
//   npm native   src/_dep.scss 2:14  m()      file:///…/src/main.scss 2:6
//   npm wasm     _dep.scss 2:14      m()      file:///…/src/main.scss 2:6
//
// Two npm engines, two different answers, neither dart's. The wasm one had no
// `getcwd` to relativise against (wasm32-unknown-unknown, not wasip1) and fell
// back to the bare filename, so the bridges hand it the directory now.
//
// (`2:10` vs `2:14` is #157 — dart underlines the whole expression and we
// underline the operator. The column is not what this case is about.)
{
  const fdir = mkdtempSync(join(tmpdir(), "sasso-frames-"));
  mkdirSync(join(fdir, "src"), { recursive: true });
  writeFileSync(join(fdir, "src", "_dep.scss"), "@mixin m {\n  width: 1px + 1em;\n}\n");
  writeFileSync(join(fdir, "src", "main.scss"), '@use "dep";\n.a { @include dep.m; }\n');
  // The temp root can be reached through a symlink (/var -> /private/var on
  // macOS), and then no spelling of the entry matches the working directory.
  // That is a property of the fixture, not of the compiler: resolve it, or
  // this case cannot tell a missed relativisation from an impossible one.
  const real = realpathSync(fdir);

  const run = (engine, entry) =>
    spawnSync(process.execPath, [cliPath, "--no-source-map", entry, "out.css"], {
      cwd: real,
      encoding: "utf8",
      env: { ...process.env, SASSO_ENGINE: engine },
      timeout: 30000,
    });
  const framesOf = (r) =>
    `${r.stdout}${r.stderr}`
      .split("\n")
      .filter((l) => /\.scss \d+:\d+/.test(l))
      .map((l) => l.trim().replace(/\s+/g, " "));
  const frames = (engine, entry) => framesOf(run(engine, entry));

  // The prebuilt addon is not there in every job — the wasm package's own CI
  // builds no addon — and demanding an engine that cannot load is a refusal,
  // not a fallback: the run exits non-zero with NO frames at all, which
  // reads as "the rule is broken" rather than "there was nothing to test".
  // Same shape as the jobs cases above: run it, and if it could not, assert
  // WHY before skipping.
  const engines = ["wasm"];
  // A stylesheet that COMPILES, because the fixture above is a deliberate
  // error: a non-zero exit there says nothing about whether the engine
  // loaded.
  const nativeProbe = spawnSync(process.execPath, [cliPath, "--stdin"], {
    input: ".a{b:1}\n",
    encoding: "utf8",
    env: { ...process.env, SASSO_ENGINE: "native" },
    timeout: 30000,
  });
  if (nativeProbe.status === 0) {
    engines.push("native");
  } else {
    assert.match(
      nativeProbe.stderr,
      /SASSO_ENGINE=native/,
      `frames: native was skipped, and the reason must be a missing addon (stderr: ${nativeProbe.stderr})`,
    );
  }

  for (const engine of engines) {
    const rel = frames(engine, join("src", "main.scss"));
    assert.deepEqual(
      rel.map((l) => l.split(" ")[0]),
      // `join`, not a literal: the compiler spells a frame with the
      // PLATFORM's separator, as dart does (#151), so `src\_dep.scss` is the
      // right answer on Windows and hard-coding `/` would fail there the
      // first time this suite runs on it.
      [join("src", "_dep.scss"), join("src", "main.scss")],
      `frames (${engine}): both files named as paths relative to the cwd, got ${JSON.stringify(rel)}`,
    );
    assert.ok(
      !rel.some((l) => l.includes("file://")),
      `frames (${engine}): no frame shows a URL scheme, got ${JSON.stringify(rel)}`,
    );

    // dart relativises an ABSOLUTE entry too — the frame names a file, not the
    // spelling the user typed.
    const abs = frames(engine, join(real, "src", "main.scss"));
    assert.deepEqual(
      abs,
      rel,
      `frames (${engine}): an absolute entry names the same file as a relative one`,
    );
  }

  // The two engines are the pair that drifted. Compare them to each other as
  // well as to the expectation: that is the assertion no existing test made.
  if (engines.includes("native")) {
    assert.deepEqual(
      frames("wasm", join("src", "main.scss")),
      frames("native", join("src", "main.scss")),
      "frames: the wasm and native engines name files identically",
    );
  }

  rmSync(fdir, { recursive: true, force: true });
  console.log(
    `ok: stack frames — paths not file:// URLs, relative entry or absolute (${engines.join(" + ")})`,
  );
}

// === a compile whose working directory has been deleted ===
//
// `process.cwd()` THROWS `ENOENT` once the directory the process started in
// is gone — a build script that cleans up its own temp directory, a watcher
// that outlives a `git clean`. Asking for it before every compile, to tell
// the core what diagnostic paths are relative to, turned that into a total
// failure on both engines:
//
//   compileString (wasm):   FAILED ENOENT: no such file or directory, uv_cwd
//   compileString (native): FAILED ENOENT: no such file or directory, uv_cwd
//
// …for `compileString`, which touches no files at all. `null` is a supported
// answer all the way down, so a lost directory costs a nicer frame and
// nothing else.
//
// One child process PER ENGINE: the suite cannot delete its own working
// directory and carry on. And which engine runs is decided by WHICH MODULE
// is imported, not by `SASSO_ENGINE` — that variable is the CLI's. Setting
// it and importing `sasso.mjs` twice runs wasm twice and leaves the native
// bridge untested, which is exactly what the first version of this did:
// reverting only the native half kept the case green.
{
  const script = `
    import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
    import { tmpdir } from "node:os";
    import { join } from "node:path";
    const base = mkdtempSync(join(tmpdir(), "sasso-deadcwd-"));
    const doomed = join(base, "gone");
    mkdirSync(doomed);
    process.chdir(doomed);
    rmSync(doomed, { recursive: true, force: true });
    const api = await import(process.env.SASSO_TEST_MODULE);
    const css = api.compileString(".a { b: 1 + 1 }").css;
    process.chdir(tmpdir());
    rmSync(base, { recursive: true, force: true });
    console.log(JSON.stringify(css));
  `;
  const modules = {
    wasm: new URL("./npm/sasso.mjs", import.meta.url).href,
    native: new URL("./npm/native.mjs", import.meta.url).href,
  };
  // The prebuilt addon is not there in every job, and importing
  // `sasso/native` without one throws by design ("no native binding for
  // …"). Ask first, and assert the REASON, so a skip cannot hide a break.
  for (const [engine, mod] of Object.entries(modules)) {
    if (engine === "native") {
      const probe = spawnSync(
        process.execPath,
        ["--input-type=module", "-e", `await import(${JSON.stringify(mod)});`],
        { encoding: "utf8", timeout: 60000 },
      );
      if (probe.status !== 0) {
        assert.match(
          probe.stderr,
          /no native binding/,
          `deleted cwd: native was skipped, and the reason must be a missing addon (${probe.stderr.slice(0, 200)})`,
        );
        continue;
      }
    }
    const r = spawnSync(process.execPath, ["--input-type=module", "-e", script], {
      encoding: "utf8",
      env: { ...process.env, SASSO_TEST_MODULE: mod },
      timeout: 60000,
    });
    assert.equal(
      r.status,
      0,
      `deleted cwd (${engine}): a compile must survive it (stderr: ${r.stderr.slice(0, 300)})`,
    );
    // Normalised HERE: `\s` inside the child's template literal is just `s`.
    const css = JSON.parse(r.stdout.trim().split("\n").at(-1)).replace(/\s+/g, " ").trim();
    assert.equal(css, ".a { b: 2; }", `deleted cwd (${engine}): and compile correctly (${r.stdout})`);
  }

  console.log("ok: a deleted working directory costs a nicer frame, not the compile");
}

// === the coalescing rule, on a fake clock ===
//
// How many compiles a burst costs cannot be asserted from a --watch test.
// Measured on this machine, 8 saves at a given spacing:
//
//   10ms apart, WITH coalescing   -> 3 compiles
//   10ms apart, WITHOUT it        -> 6 or 7
//   0ms apart, either way         -> 1  (the OS coalesces the events)
//
// There is no bound that both catches the regression and survives a
// loaded CI machine stretching those gaps — the first version of the
// burst test asserted `< 8` and did not notice coalescing being removed
// entirely. With a fake clock there is no gap to stretch.
// === What the sweep may treat as "what the compile read" (#164) ===
//
// The end-to-end case is a race — a save has to land between the
// compile's read of a file and the snapshot taken after it — so it is
// MEASURED rather than pinned here, the same call `_coalesce.mjs` makes
// about its own property. A 900k-rule entry so the compile takes seconds,
// `sub/_dep.scss` saved five seconds in, `--poll` so nothing but the
// sweep can answer:
//
//   trusting the post-compile mtime    6 saves lost out of 6
//   this rule                          0 lost out of 6
//
// What is pinned is the rule.
{
  const { baselineFor } = await import("./npm/_baseline.mjs");

  // No compile in progress: there is nothing to distrust.
  assert.equal(baselineFor(1000, undefined), 1000, "baseline: with no compile, the reading stands");
  assert.equal(baselineFor(null, undefined), null, "baseline: …including for a file that is not there");

  // Older than the compile: the compile read THIS, so it is the baseline.
  assert.equal(baselineFor(999, 1000), 999, "baseline: a file older than the compile is trusted");
  assert.equal(baselineFor(0, 1000), 0, "baseline: however much older");

  // At or after it: the compile may have read the bytes before this save,
  // so the reading cannot be the baseline — `null`, which the sweep reads
  // as a difference and answers with one catch-up compile.
  assert.equal(baselineFor(1000, 1000), null, "baseline: the same millisecond is not trusted");
  assert.equal(baselineFor(1001, 1000), null, "baseline: a file that moved after the compile began is not trusted");

  // A file that is gone is `null` either way, and that is not the same
  // statement — but it lands on the same value, and the sweep treats a
  // missing file as unchanged only while it stays missing.
  assert.equal(baselineFor(null, 1000), null, "baseline: an absent file has no reading to trust");

  console.log("ok: baseline — a reading taken after the compile began is not what the compile read");
}

// === The poll beside the watcher (#164) ===
//
// `fs.watch` is the fast path, and on macOS it cannot be trusted on its
// own. Measured with no sasso involved — a directory watched, settled,
// one file written, the callback timed, 20 samples 1200ms apart:
//
//   macOS 26, Apple Silicon   node v22.22.3   20/20 delivered   median  552ms
//   macOS 26, Intel           node v26.7.0     8/20 delivered   median 9132ms
//   Linux, inotify            node v26.8.1    20/20 delivered   median  0.2ms
//
// Twelve of twenty events never arrived at all on the Intel Mac, inside
// fifteen seconds. So the sweep is what GUARANTEES a save is seen, and the
// watcher only makes the common case instant.
//
// Its interval rule is tested here rather than from a `--watch` test for
// the same reason `_coalesce.mjs`'s is: the alternative measures the
// machine. With a clock the test drives, a 2ms sweep earns exactly 100ms,
// every time.
{
  const { makePoller, nextInterval, MIN_INTERVAL_MS, MAX_INTERVAL_MS, SWEEP_BUDGET } = await import("./npm/_poller.mjs");

  assert.equal(SWEEP_BUDGET, 50, "poller: a sweep may have 2% of a core");
  // 0.054ms is the measured ten-file sweep; 13.184ms the 5000-file one.
  assert.equal(nextInterval(0.054), MIN_INTERVAL_MS, "poller: ten files poll at the floor");
  assert.equal(nextInterval(0), MIN_INTERVAL_MS, "poller: a free sweep does not busy-loop");
  assert.equal(nextInterval(2), 100, "poller: the wait is the sweep times the budget");
  assert.equal(nextInterval(13.184), MAX_INTERVAL_MS, "poller: 5000 files are capped, not unbounded");
  assert.equal(nextInterval(4, 25), 100, "poller: the budget is a parameter");

  /** One pending timer, driven by hand. */
  const rig = ({ sweep, onChange = () => {} }) => {
    let t = 0;
    let queued = null;
    let armed = 0;
    const poller = makePoller({
      sweep: () => sweep(() => t, (ms) => (t += ms)),
      onChange,
      setTimer: (fn, ms) => (armed++, (queued = { fn, ms }), armed),
      clearTimer: () => (queued = null),
      now: () => t,
    });
    return {
      poller,
      waited: () => queued?.ms,
      armedCount: () => armed,
      pending: () => queued !== null,
      tick: () => {
        const q = queued;
        queued = null;
        q.fn();
      },
      raw: () => queued,
    };
  };

  // A sweep that reports a change wakes the caller exactly once.
  {
    let moved = false;
    const seen = [];
    const r = rig({ sweep: () => moved, onChange: () => seen.push("change") });
    r.poller.start();
    assert.equal(r.waited(), MIN_INTERVAL_MS, "poller: the first wait is the floor");
    r.tick();
    assert.deepEqual(seen, [], "poller: a quiet sweep says nothing");
    moved = true;
    r.tick();
    assert.deepEqual(seen, ["change"], "poller: a sweep that moved reports once");
    moved = false;
    r.tick();
    assert.deepEqual(seen, ["change"], "poller: and not again once it is quiet");
  }

  // The interval grows with what a sweep COSTS — the property that keeps
  // a 5000-file tree from burning a core all afternoon.
  {
    let cost = 0.054;
    const r = rig({
      sweep: (_now, advance) => {
        advance(cost);
        return false;
      },
    });
    r.poller.start();
    r.tick();
    assert.equal(r.waited(), MIN_INTERVAL_MS, "poller: ten files stay at the floor");
    cost = 2;
    r.tick();
    assert.equal(r.waited(), 100, "poller: a 2ms sweep earns a 100ms wait");
    cost = 40;
    r.tick();
    assert.equal(r.waited(), MAX_INTERVAL_MS, "poller: and an enormous one is capped");
  }

  // A sweep that throws is not the end of the watch: the next one is an
  // interval away, and `fs.watch` is still live underneath. A safety net
  // that can take the process down is worse than no safety net.
  {
    const seen = [];
    const r = rig({
      sweep: () => {
        throw new Error("EIO");
      },
      onChange: () => seen.push("change"),
    });
    r.poller.start();
    r.tick(); // must not throw
    assert.ok(r.pending(), "poller: a thrown sweep still rearms");
    assert.deepEqual(seen, [], "poller: and reports nothing it did not see");
  }

  // …and neither is a compile that throws out of `onChange`: the timer
  // is rearmed BEFORE the callback, so the error reaches the caller with
  // the next sweep already scheduled.
  {
    const r = rig({
      sweep: () => true,
      onChange: () => {
        throw new Error("compile blew up");
      },
    });
    r.poller.start();
    assert.throws(() => r.tick(), /compile blew up/, "poller: the caller's error is not swallowed");
    assert.ok(r.pending(), "poller: but the next sweep is already armed");
  }

  // Stopping stops it, and starting twice does not run two.
  {
    const r = rig({ sweep: () => false });
    r.poller.start();
    r.poller.start();
    assert.equal(r.armedCount(), 1, "poller: start is idempotent");
    r.poller.stop();
    assert.equal(r.raw(), null, "poller: stop disarms");
    r.poller.stop(); // must not throw
  }

  // …including a stop decided DURING a tick. `timer` is null for the whole
  // of one, so it cannot answer "are we still running": a `stop()` from
  // inside the sweep found nothing to clear and the tick rearmed on top of
  // it. Nothing in `cli.mjs` stops a poller today, which is exactly why
  // this needs a guard rather than a reader noticing.
  {
    let stopped = 0;
    let queued = null;
    let armed = 0;
    const { makePoller: mk } = await import("./npm/_poller.mjs");
    const poller = mk({
      sweep: () => {
        if (stopped++ === 0) poller.stop();
        return false;
      },
      onChange: () => {},
      setTimer: (fn, ms) => (armed++, (queued = { fn, ms }), armed),
      clearTimer: () => (queued = null),
      now: () => 0,
    });
    poller.start();
    const first = queued;
    queued = null;
    first.fn();
    assert.equal(queued, null, "poller: stop() from inside the sweep is not rearmed over");
  }

  // …and a stop from inside onChange, where the rearm has already
  // happened, must still take.
  {
    let queued = null;
    const { makePoller: mk } = await import("./npm/_poller.mjs");
    const poller = mk({
      sweep: () => true,
      onChange: () => poller.stop(),
      setTimer: (fn, ms) => ((queued = { fn, ms }), 1),
      clearTimer: () => (queued = null),
      now: () => 0,
    });
    poller.start();
    const first = queued;
    queued = null;
    first.fn();
    assert.equal(queued, null, "poller: stop() from inside onChange clears the rearm");
  }

  console.log("ok: poller — floor, budget, ceiling, a sweep that throws, start/stop");
}

{
  const { coalesce } = await import("./npm/_coalesce.mjs");

  /** A clock the test drives by hand. */
  const clock = () => {
    const queued = [];
    const setTimer = (fn) => {
      queued.push(fn);
      return queued.length;
    };
    return { setTimer, tick: () => queued.splice(0).forEach((fn) => fn()) };
  };

  // Eight events inside one window: one run at the head, one catch-up.
  {
    const { setTimer, tick } = clock();
    const calls = [];
    const on = coalesce({ windowMs: 50, run: (p) => (calls.push(p), true), setTimer });
    for (let i = 0; i < 8; i++) on();
    assert.deepEqual(calls, [true], "coalesce: the head of a burst runs at once, alone");
    tick();
    assert.deepEqual(calls, [true, false], "coalesce: one catch-up for the other seven");
    tick();
    assert.deepEqual(calls, [true, false], "coalesce: and then it stops");
  }

  // One event, nothing after it: the head runs IMMEDIATELY — that is the
  // latency this design exists for, and the old trailing debounce made
  // it wait 50ms for a window that stayed empty — and a catch-up
  // follows.
  //
  // The catch-up is not waste and is not optional. What the head reads
  // is not always what the save finally leaves on disk, and a head that
  // succeeds on already-stale content would otherwise schedule nothing:
  // measured at 1 save in 30 going permanently stale before this. The
  // caller makes the second run free when nothing changed by not
  // writing identical CSS, so the cost is one extra compile off the
  // critical path, not an extra write or an extra reported line.
  {
    const { setTimer, tick } = clock();
    const calls = [];
    const on = coalesce({ windowMs: 50, run: (p) => (calls.push(p), true), setTimer });
    on();
    assert.deepEqual(calls, [true], "coalesce: a lone save runs at once, before any window");
    tick();
    assert.deepEqual(calls, [true, false], "coalesce: and is confirmed by one catch-up");
    tick();
    assert.deepEqual(calls, [true, false], "coalesce: which is not itself confirmed — it stops");
  }

  // Separate windows are separate bursts: each gets its own head.
  {
    const { setTimer, tick } = clock();
    const calls = [];
    const on = coalesce({ windowMs: 50, run: (p) => (calls.push(p), true), setTimer });
    on();
    tick(); // the first save's catch-up
    tick();
    on();
    assert.deepEqual(
      calls,
      [true, false, true],
      "coalesce: the second save is a head of its own, not a catch-up",
    );
  }

  // A PROVISIONAL failure asks for a catch-up even with no further
  // events — the finishing write usually sends one, but "usually" is not
  // something the user's output should rest on.
  {
    const { setTimer, tick } = clock();
    const calls = [];
    const on = coalesce({
      windowMs: 50,
      run: (p) => (calls.push(p), calls.length > 1),
      setTimer,
    });
    on();
    assert.deepEqual(calls, [true], "coalesce: the provisional run happened");
    tick();
    assert.deepEqual(calls, [true, false], "coalesce: it failed, so a catch-up follows unasked");
    tick();
    assert.deepEqual(calls, [true, false], "coalesce: the catch-up succeeded, so it ends");
  }

  // An AUTHORITATIVE failure must not ask for another. When it did, the
  // error was reported, re-run, reported again, forever.
  {
    const { setTimer, tick } = clock();
    const calls = [];
    const on = coalesce({ windowMs: 50, run: (p) => (calls.push(p), false), setTimer });
    on();
    tick();
    tick();
    tick();
    assert.deepEqual(
      calls,
      [true, false],
      "coalesce: a persistent error is reported once, not on a loop",
    );
  }

  console.log("ok: coalesce — one head per burst, one catch-up, and no loop on a real error");
}

// === Phase 3c: CLI --watch, what it SURVIVES ===
//
// The functional test above proves a recompile happens; the one before
// this proves what it says. Neither covered what a watch has to live
// through, and two of these were broken in the shipped CLI:
//
//   a compile FAILS, then the dependency is fixed   -> never recovered
//   a missing dependency is created                 -> never noticed
//
// Both for one reason. A failed compile reports no `loadedUrls`, and the
// error path re-watched `[entry]` alone, so the directory watcher stayed
// but the filename filter stopped recognising the dependency. You broke a
// partial, saw the error, fixed it, and nothing happened — with the output
// file already deleted. dart recovers from both (measured 2026-09-19).
{
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

  /** Start a watch in a fresh directory, run `body`, always kill it. */
  // `maps` because one case needs them ON: the watch default is source
  // maps, and the bug it covers is invisible without the sidecar.
  const withWatch = async (setup, body, extra = [], entry = "main.scss", maps = false) => {
    const dir = mkdtempSync(join(tmpdir(), "sasso-watchcase-"));
    setup(dir);
    const proc = spawn(
      process.execPath,
      [cliPath, ...(maps ? [] : ["--no-source-map"]), ...extra, "--watch", entry, "out.css"],
      { cwd: dir, stdio: ["ignore", "pipe", "pipe"] },
    );
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    const css = () => {
      try {
        return readFileSync(join(dir, "out.css"), "utf8");
      } catch {
        return "";
      }
    };
    const until = async (pred, ms = 20000) => {
      const deadline = Date.now() + ms;
      while (Date.now() < deadline) {
        try {
          if (pred()) return true;
        } catch {}
        await sleep(20);
      }
      return false;
    };
    try {
      return await body({ dir, css, until, log: () => log, clear: () => (log = "") });
    } finally {
      proc.kill();
      rmSync(dir, { recursive: true, force: true });
    }
  };

  const withDep = (d) => {
    writeFileSync(join(d, "main.scss"), '@use "v";\n.a { color: v.$c; }\n');
    writeFileSync(join(d, "_v.scss"), "$c: red;\n");
  };

  // A burst: the LAST save must win, and it must not cost one compile per
  // save. Checking only the final colour — which is all the first version
  // of this did — would pass at eight compiles, leaving the coalescing
  // this whole change rests on unguarded.
  //
  // Measured on this machine, 8 saves at a given spacing:
  //
  //             with coalescing   without it
  //   0ms apart       1               1     (the OS coalesces the events)
  //   5ms apart       2               4
  //  10ms apart       3             6 or 7
  //  25ms apart       5               6
  //
  // Which is why the REAL guard is the fake-clock table against
  // `_coalesce.mjs` above, not this: there is no bound here that both
  // catches the regression and survives a loaded CI machine stretching
  // those gaps. `< 8` is a smoke check that the rule is wired into the
  // watch at all — removing coalescing entirely yields 6 or 7 and slips
  // past it, and the unit test is what notices.
  await withWatch(withDep, async ({ dir, css, until, log, clear }) => {
    assert.ok(await until(() => css().includes("red")), "watch: initial compile");
    await sleep(300);
    clear();
    for (let i = 1; i <= 8; i++) {
      writeFileSync(join(dir, "_v.scss"), `$c: #0000${String(i).padStart(2, "0")};\n`);
      await sleep(10);
    }
    assert.ok(await until(() => css().includes("000008")), "watch: a burst settles on the last save");
    await sleep(400); // let any trailing catch-up land before counting
    const compiles = (log().match(/Compiled/g) || []).length;
    assert.ok(compiles >= 1, "watch: the burst compiled at all");
    assert.ok(
      compiles < 8,
      `watch: a burst of 8 saves must coalesce, not compile once each (saw ${compiles})`,
    );
  });

  // An atomic save replaces the inode, which is why the watcher watches
  // DIRECTORIES: a file watch would follow the file that was renamed away.
  await withWatch(withDep, async ({ dir, css, until }) => {
    assert.ok(await until(() => css().includes("red")), "watch: initial compile");
    await sleep(300);
    writeFileSync(join(dir, ".v.tmp"), "$c: blue;\n");
    renameSync(join(dir, ".v.tmp"), join(dir, "_v.scss"));
    assert.ok(await until(() => css().includes("blue")), "watch: an atomic save is seen");
  });

  // Break the dependency, then fix it. This is the one that was broken.
  await withWatch(withDep, async ({ dir, css, until, log, clear }) => {
    assert.ok(await until(() => css().includes("red")), "watch: initial compile");
    await sleep(300);
    clear();
    writeFileSync(join(dir, "_v.scss"), "$c: ;\n");
    assert.ok(await until(() => /Error/i.test(log())), "watch: a broken dependency is reported");
    await sleep(300);
    writeFileSync(join(dir, "_v.scss"), "$c: teal;\n");
    assert.ok(
      await until(() => css().includes("teal")),
      "watch: fixing the dependency you broke brings the output back",
    );
  });

  // A dependency that does not exist yet: the first compile fails, so
  // there is no `loadedUrls` naming the file to wait for.
  await withWatch(
    (d) => writeFileSync(join(d, "main.scss"), '@use "later";\n.a { color: later.$c; }\n'),
    async ({ dir, css, until, log }) => {
      assert.ok(await until(() => /Error/i.test(log())), "watch: a missing dependency is reported");
      await sleep(300);
      writeFileSync(join(dir, "_later.scss"), "$c: green;\n");
      assert.ok(await until(() => css().includes("green")), "watch: creating it compiles");
    },
  );

  // Deleted, then restored.
  await withWatch(withDep, async ({ dir, css, until, log, clear }) => {
    assert.ok(await until(() => css().includes("red")), "watch: initial compile");
    await sleep(300);
    clear();
    rmSync(join(dir, "_v.scss"));
    assert.ok(await until(() => /Error/i.test(log())), "watch: a deleted dependency is reported");
    await sleep(300);
    writeFileSync(join(dir, "_v.scss"), "$c: olive;\n");
    assert.ok(await until(() => css().includes("olive")), "watch: restoring it compiles");
  });

  // The output lands in a watched directory. If it retriggers the compile
  // that wrote it, the watch spins forever — and the permissive filter the
  // error path now uses makes that easier to get wrong.
  await withWatch(
    (d) => writeFileSync(join(d, "main.scss"), ".a { color: red; }\n"),
    async ({ css, until, log, clear }) => {
      assert.ok(await until(() => css().includes("red")), "watch: initial compile");
      await sleep(500);
      clear();
      await sleep(1500);
      const again = (log().match(/Compiled/g) || []).length;
      assert.equal(again, 0, `watch: the output must not retrigger itself (saw ${again} more compiles)`);
    },
  );

  // A missing dependency that resolves through a LOAD PATH rather than
  // beside the entry. The first compile fails, so `known` holds only the
  // entry and only the entry's directory would be watched — the file
  // created later in `inc/` lands where nobody is looking. Widening the
  // filter while failing cannot help: there is no watcher on that
  // directory at all. dart watches load paths whether or not anything has
  // been loaded from them, and so do we now.
  await withWatch(
    (d) => {
      mkdirSync(join(d, "inc"));
      writeFileSync(join(d, "main.scss"), '@use "viaload";\n.a { color: viaload.$c; }\n');
    },
    async ({ dir, css, until, log }) => {
      assert.ok(await until(() => /Error/i.test(log())), "watch: a missing load-path dependency is reported");
      await sleep(300);
      writeFileSync(join(dir, "inc", "_viaload.scss"), "$c: fuchsia;\n");
      assert.ok(
        await until(() => css().includes("fuchsia")),
        "watch: creating it on the load path compiles",
      );
    },
    ["-I", "inc"],
  );

  // A load path that does not EXIST yet. `fs.watch` throws for it, so it
  // is dropped and nothing re-arms — the file created there later
  // produces no event anywhere. dart handles this; we did not.
  await withWatch(
    (d) => {
      mkdirSync(join(d, "src"));
      writeFileSync(join(d, "src", "main.scss"), '@use "gen";\n.a { color: gen.$c; }\n');
    },
    async ({ dir, css, until, log }) => {
      assert.ok(await until(() => /Error/i.test(log())), "watch: a load path that does not exist yet");
      await sleep(300);
      // One level at a time, so the probe has to re-arm deeper rather
      // than waiting on an ancestor that never becomes the target.
      mkdirSync(join(dir, "a"));
      await sleep(200);
      mkdirSync(join(dir, "a", "b"));
      await sleep(200);
      writeFileSync(join(dir, "a", "b", "_gen.scss"), "$c: olive;\n");
      assert.ok(
        await until(() => css().includes("olive")),
        "watch: creating the load path, one level at a time, compiles",
      );
    },
    ["-I", "a/b"],
    "src/main.scss",
  );

  // Error CSS under --watch, which is the whole reason the flag matters:
  // break a partial and the PAGE says what broke, rather than going
  // unstyled until you find the terminal. Every other --error-css test
  // here is a one-shot compile; this is the loop.
  await withWatch(withDep, async ({ dir, css, until, log, clear }) => {
    assert.ok(await until(() => css().includes("red")), "watch: initial compile");
    await sleep(300);
    clear();
    writeFileSync(join(dir, "_v.scss"), "$c: ;\n");
    assert.ok(
      await until(() => css().startsWith("/* Error: ")),
      `watch: a broken save leaves error CSS in the output, not nothing: ${JSON.stringify(css().slice(0, 40))}`,
    );
    await sleep(300);
    writeFileSync(join(dir, "_v.scss"), "$c: teal;\n");
    assert.ok(
      await until(() => css().includes("teal")),
      "watch: and fixing it replaces the error CSS with the real thing",
    );

    // Fixing it back to EXACTLY what it was before the failure. The
    // "skip an unchanged write" shortcut remembers the last CSS it
    // wrote; if a failure does not clear that, this compile matches and
    // is skipped, and the error stylesheet stays on the page forever.
    await sleep(300);
    writeFileSync(join(dir, "_v.scss"), "$c: ;\n");
    assert.ok(await until(() => css().startsWith("/* Error: ")), "watch: broken again");
    await sleep(300);
    writeFileSync(join(dir, "_v.scss"), "$c: teal;\n");
    assert.ok(
      await until(() => css().includes("teal")),
      "watch: fixing it BACK to what it was must write again, not match a stale memory",
    );
  });

  // A whitespace-only edit: the CSS is identical and every mapping
  // moves. Comparing the CSS alone skipped the write and left the
  // sidecar wrong — with source maps ON, which is the watch default.
  await withWatch(withDep, async ({ dir, css, until }) => {
    assert.ok(await until(() => css().includes("red")), "watch: initial compile");
    await sleep(400);
    const mapOf = () => {
      try {
        return readFileSync(join(dir, "out.css.map"), "utf8");
      } catch {
        return "";
      }
    };
    const before = mapOf();
    assert.ok(before.length > 0, "watch: a source map was written to begin with");
    writeFileSync(join(dir, "main.scss"), '@use "v";\n\n\n.a { color: v.$c; }\n');
    assert.ok(
      await until(() => mapOf() !== before),
      "watch: a whitespace-only edit still rewrites the map",
    );
    assert.ok(css().includes("red"), "watch: …and the CSS is unchanged, which is the point");
  }, [], "main.scss", true);

  // A destination that IS a source. `sasso --watch a.scss a.scss` and
  // `--watch main.scss _v.scss` both replaced a stylesheet with its own
  // CSS — at startup and then on every save. dart declines: its
  // transcript is the banner and nothing else, and the file is untouched.
  //
  // A one-shot compile overwrites it on all three engines including dart,
  // so that is not ours to change; this is the watch, where the same
  // mistake repeats for as long as the process lives.
  for (const [label, args, setup, victim, intact] of [
    [
      "the input is the output",
      ["a.scss", "a.scss"],
      (d) => writeFileSync(join(d, "a.scss"), "$c: red;\n.a { color: $c; }\n"),
      "a.scss",
      "$c: red",
    ],
    [
      "the output is a dependency",
      ["main.scss", "_v.scss"],
      (d) => {
        writeFileSync(join(d, "main.scss"), '@use "v";\n.a { color: v.$c; }\n');
        writeFileSync(join(d, "_v.scss"), "$c: red;\n");
      },
      "_v.scss",
      "$c: red",
    ],
  ]) {
    const dir = mkdtempSync(join(tmpdir(), "sasso-alias-"));
    setup(dir);
    const proc = spawn(process.execPath, [cliPath, "--no-source-map", "--watch", ...args], {
      cwd: dir,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let log = "";
    proc.stdout.on("data", (b) => (log += b));
    proc.stderr.on("data", (b) => (log += b));
    try {
      await sleep(2000);
      assert.ok(
        readFileSync(join(dir, victim), "utf8").includes(intact),
        `watch: ${label} — the source must survive, found ${JSON.stringify(readFileSync(join(dir, victim), "utf8").slice(0, 40))}`,
      );
      assert.ok(!log.includes("Compiled"), `watch: ${label} — and nothing is announced: ${log}`);
      // Break it. The success path refuses to WRITE over a source; the
      // error path must not DELETE one either. Unreachable today —
      // an aliased watch never recompiles, in dart as in ours — and one
      // filter change away from being reachable, with worse consequences
      // than the overwrite it sits beside.
      writeFileSync(join(dir, victim), "$c: ;\n");
      await sleep(1200);
      assert.ok(
        existsSync(join(dir, victim)),
        `watch: ${label} — a failing compile must not delete the source either`,
      );
    } finally {
      proc.kill();
      rmSync(dir, { recursive: true, force: true });
    }
  }

  console.log("ok: cli --watch — burst, atomic save, break/fix, missing dep (local, load path, absent load path), delete/restore, no self-trigger, no writing over a source");
}

// === Phase 4: custom functions — full Value coverage (sync + async) ===
{
  const { SassNumber, SassString, SassColor, SassList, SassMap, sassTrue, sassFalse, sassNull } = size;

  // number with units
  const rn = size.compileString(`.a { w: rem(32); }`, {
    functions: { "rem($px)": (a) => new SassNumber(a[0].assertNumber().value / 16, "rem") },
  });
  assert.ok(rn.css.includes("w: 2rem"), "fn: number with unit");

  // string assert + quotes
  const rs = size.compileString(`.a { content: shout("hi"); }`, {
    functions: { "shout($s)": (a) => new SassString(a[0].assertString().text.toUpperCase() + "!", { quotes: true }) },
  });
  assert.ok(rs.css.includes('"HI!"'), "fn: string in/out");

  // color in/out (read channel, build a new color)
  const rc = size.compileString(`.a { color: setred(rgb(1, 2, 3)); }`, {
    functions: { "setred($c)": (a) => { const c = a[0].assertColor(); return new SassColor({ red: 255, green: c.green, blue: c.blue, alpha: c.alpha }); } },
  });
  assert.ok(rc.css.includes("#ff0203"), "fn: color in/out");

  // modern color space round-trip (oklch built in JS)
  const rok = size.compileString(`.a { color: brand(); }`, {
    functions: { "brand()": () => new SassColor({ space: "oklch", lightness: 0.7, chroma: 0.15, hue: 250, alpha: 1 }) },
  });
  assert.ok(rok.css.includes("oklch("), "fn: modern color space");

  // list + map args, boolean/null returns
  // list arg -> immutable List (.size / .get), incl. negative indexing
  const rl = size.compileString(`.a { n: len((a, b, c)); l: last((a, b, c)); }`, {
    functions: {
      "len($l)": (a) => new SassNumber(a[0].asList.size),
      "last($l)": (a) => a[0].get(-1),
    },
  });
  assert.ok(rl.css.includes("n: 3") && rl.css.includes("l: c"), "fn: list arg (immutable List + negative get)");
  // map arg -> value-equality lookup via .contents.get (dart-sass shape)
  const rm = size.compileString(`.a { v: pick((x: 1, y: 2), y); }`, {
    functions: { "pick($m, $k)": (a) => a[0].assertMap().contents.get(a[1]) ?? sassNull },
  });
  assert.ok(rm.css.includes("v: 2"), "fn: map arg + value-equality get");

  // rest args ($args...)
  const rr = size.compileString(`.a { s: total(1, 2, 3, 4); }`, {
    functions: { "total($nums...)": (a) => new SassNumber(a[0].asList.reduce((s, n) => s + n.value, 0)) },
  });
  assert.ok(rr.css.includes("s: 10"), "fn: rest args");

  // Tier 0/1: sassIndexToListIndex (1-based + negative), tryMap, assertNoUnits
  const rt = size.compileString(`.a { x: nth((10, 20, 30), -1); }`, {
    functions: {
      "nth($l, $i)": (a) => a[0].get(a[0].sassIndexToListIndex(a[1], "i")),
    },
  });
  assert.ok(rt.css.includes("x: 30"), "fn: sassIndexToListIndex negative");
  const rempty = size.compileString(`.a { x: ismap(()); }`, {
    functions: { "ismap($v)": (a) => (a[0].tryMap() ? sassTrue : sassFalse) },
  });
  assert.ok(rempty.css.includes("x: true"), "fn: tryMap on empty list");

  // a custom function overrides a builtin global, loses to a user @function
  const rov = size.compileString(`.a { x: type-of(1); }`, {
    functions: { "type-of($v)": () => new SassString("custom", { quotes: false }) },
  });
  assert.ok(rov.css.includes("x: custom"), "fn: overrides builtin");

  // error from a function surfaces as a compile error
  let fnErr;
  try { size.compileString(`.a { x: boom(1); }`, { functions: { "boom($x)": () => { throw new Error("kaboom"); } } }); } catch (e) { fnErr = e; }
  assert.ok(fnErr && /kaboom/.test(fnErr.message), "fn: error surfaces");

  // async custom function suspends/resumes the engine
  const ra = await size.compileStringAsync(`.a { x: aplus(40); }`, {
    functions: { "aplus($n)": async (a) => { await new Promise((r) => setTimeout(r, 2)); return new SassNumber(a[0].value + 2); } },
  });
  assert.ok(ra.css.includes("x: 42"), "fn: async custom function");

  // a Promise-returning function is rejected on the SYNC path
  assert.throws(
    () => size.compileString(`.a { x: ap(1); }`, { functions: { "ap($n)": async () => new SassNumber(1) } }),
    /asynchronous custom functions require/,
    "fn: sync path rejects async function",
  );

  // boolean / sassTrue usable
  const rb = size.compileString(`.a { x: yes(); }`, { functions: { "yes()": () => sassTrue } });
  assert.ok(rb.css.includes("x: true"), "fn: boolean return");

  // Tier 2: engine-routed SassNumber unit conversion (standalone + re-entrant)
  assert.equal(new SassNumber(96, "px").convert(["in"], []).value, 1, "Tier2: convert 96px -> 1in (standalone)");
  assert.equal(new SassNumber(1, "in").convertValue(["px"], []), 96, "Tier2: convertValue 1in -> 96px");
  assert.equal(new SassNumber(5).coerce(["px"], []).toString(), "5px", "Tier2: coerce unitless");
  assert.equal(new SassNumber(1, "in").compatibleWithUnit("px"), true, "Tier2: compatibleWithUnit true");
  assert.equal(new SassNumber(1, "s").compatibleWithUnit("px"), false, "Tier2: compatibleWithUnit false");
  assert.throws(() => new SassNumber(1, "s").convert(["px"], []), /can't be converted/, "Tier2: incompatible convert throws");
  const rconv = size.compileString(`.a { w: topx(2in); }`, {
    functions: { "topx($n)": (a) => a[0].assertNumber().convert(["px"], []) },
  });
  assert.ok(rconv.css.includes("w: 192px"), "Tier2: re-entrant convert inside a custom function");
  const rconvA = await size.compileStringAsync(`.a { w: topx(1in); }`, {
    functions: { "topx($n)": async (a) => a[0].assertNumber().convertToMatch(new SassNumber(0, "px")) },
  });
  assert.ok(rconvA.css.includes("w: 96px"), "Tier2: re-entrant convert in an async custom function");

  // Tier 2b: engine-routed SassColor space conversion (standalone + re-entrant)
  const red = new SassColor({ red: 255, green: 0, blue: 0 });
  assert.equal(red.toSpace("oklch").space, "oklch", "Tier2: toSpace returns target space");
  assert.ok(Math.abs(red.toSpace("oklch").channel("lightness") - 0.628) < 0.01, "Tier2: oklch lightness of red");
  assert.equal(red.channel("lightness", { space: "hsl" }), 50, "Tier2: channel(name,{space})");
  assert.equal(new SassColor({ space: "oklch", lightness: 0.7, chroma: 0.15, hue: 250 }).isInGamut("srgb"), true, "Tier2: isInGamut");
  const rcolor = size.compileString(`.a { l: light(#3366cc); }`, {
    functions: { "light($c)": (a) => new SassNumber(Math.round(a[0].assertColor().toSpace("hsl").channel("lightness"))) },
  });
  assert.ok(rcolor.css.includes("l: 50"), "Tier2: re-entrant toSpace inside a custom function");

  // Tier 2c: change / interpolate / isChannelPowerless
  assert.equal(red.change({ green: 128 }).toSpace("rgb").channels.toArray().join(","), "255,128,0", "Tier2c: change channel");
  assert.equal(red.change({ space: "oklch", lightness: 0.9 }).channel("lightness"), 0.9, "Tier2c: change with space");
  assert.equal(
    red.interpolate(new SassColor({ red: 0, green: 0, blue: 255 }), { weight: 0.5, method: "srgb" }).toSpace("rgb").channels.toArray().map(Math.round).join(","),
    "128,0,128",
    "Tier2c: interpolate",
  );
  assert.equal(new SassColor({ space: "hsl", hue: 0, saturation: 0, lightness: 50 }).isChannelPowerless("hue"), true, "Tier2c: isChannelPowerless");

  // Tier 3a: SassCalculation round-trip (receive + inspect, and return)
  const { SassCalculation, CalculationOperation } = size;
  const rcalcIn = size.compileString(`.a { x: probe(calc(1px + 2%)); }`, {
    functions: {
      "probe($c)": (a) => {
        const c = a[0].assertCalculation();
        const op = c.arguments.get(0);
        return new SassString(`${c.name}|${op.operator}|${op.left}|${op.right}`, { quotes: true });
      },
    },
  });
  assert.ok(rcalcIn.css.includes('"calc|+|1px|2%"'), "Tier3a: receive + inspect calc()");
  const rcalcOut = size.compileString(`.a { width: build(); }`, {
    functions: { "build()": () => SassCalculation.calc(new CalculationOperation("+", new SassNumber(1, "px"), new SassNumber(2, "%"))) },
  });
  assert.ok(rcalcOut.css.includes("width: calc(1px + 2%)"), "Tier3a: return a SassCalculation");
  const rcalcMin = size.compileString(`.a { width: mn(); }`, {
    functions: { "mn()": () => SassCalculation.min([new SassNumber(10, "px"), new SassString("var(--x)", { quotes: false })]) },
  });
  assert.ok(rcalcMin.css.includes("width: min(10px, var(--x))"), "Tier3a: return min() with var()");

  // Tier 3b: first-class function/mixin refs round-trip as opaque handles
  const rfnref = size.compileString(
    `@use "sass:meta";\n@function double($x) { @return $x * 2; }\n.a { x: meta.call(passthru(meta.get-function("double")), 5); }`,
    { functions: { "passthru($f)": (a) => a[0].assertFunction() } },
  );
  assert.ok(rfnref.css.includes("x: 10"), "Tier3b: SassFunction opaque round-trip (meta.call)");
  const rmixref = size.compileString(
    `@use "sass:meta";\n@mixin paint { color: red; }\n.a { @include meta.apply(passmix(meta.get-mixin("paint"))); }`,
    { functions: { "passmix($m)": (a) => a[0].assertMixin() } },
  );
  assert.ok(rmixref.css.includes("color: red"), "Tier3b: SassMixin opaque round-trip (meta.apply)");

  // Polish: unit-aware SassNumber equality + hashCode (verified == dart-sass 1.101)
  const inch = new SassNumber(1, "in");
  assert.equal(inch.equals(new SassNumber(96, "px")), true, "equals: 1in == 96px");
  assert.equal(inch.hashCode() === new SassNumber(96, "px").hashCode(), true, "equals: 1in/96px hash equal");
  assert.equal(inch.equals(new SassNumber(2, "px")), false, "equals: 1in != 2px");
  assert.equal(new SassNumber(1).equals(new SassNumber(1, "px")), false, "equals: 1 != 1px (unitless vs united)");
  assert.equal(inch.equals(new SassNumber(1, "s")), false, "equals: 1in != 1s (incompatible)");
  assert.equal(new SassNumber(0.1 + 0.2).equals(new SassNumber(0.3)), true, "equals: 0.1+0.2 == 0.3 (fuzzy)");
  const mUnit = new SassMap(new Map([[inch, new SassString("hit", { quotes: true })]]));
  assert.equal(mUnit.contents.get(new SassNumber(96, "px"))?.text, "hit", "equals: SassMap key 1in matched by 96px");

  // Polish: assert / index error messages — byte-for-byte vs dart-sass 1.101
  const expectMsg = (fn, want, label) => {
    let msg = null;
    try {
      fn();
    } catch (e) {
      msg = e.message;
    }
    assert.equal(msg, want, label);
  };
  expectMsg(() => new SassString("hi").assertNumber(), '"hi" is not a number.', "msg: assertNumber");
  expectMsg(() => new SassNumber(5).assertString("foo"), "$foo: 5 is not a string.", "msg: assertString named");
  expectMsg(() => new SassNumber(5).assertColor(), "5 is not a color.", "msg: assertColor");
  expectMsg(() => new SassNumber(5).assertFunction(), "5 is not a function reference.", "msg: assertFunction");
  expectMsg(() => new SassNumber(5).assertMixin(), "5 is not a mixin reference.", "msg: assertMixin");
  expectMsg(() => new SassNumber(5.5).assertInt(), "5.5 is not an int.", "msg: assertInt");
  expectMsg(() => new SassNumber(5, "px").assertUnit("em"), 'Expected 5px to have unit "em".', "msg: assertUnit");
  expectMsg(() => new SassNumber(5, "px").assertNoUnits("foo"), "$foo: Expected 5px to have no units.", "msg: assertNoUnits named");
  expectMsg(() => new SassNumber(5).assertInRange(0, 3), "Expected 5 to be within 0 and 3.", "msg: assertInRange");
  const idxList = new SassList([new SassNumber(1), new SassNumber(2)]);
  expectMsg(() => idxList.sassIndexToListIndex(new SassNumber(0)), "List index may not be 0.", "msg: index 0");
  expectMsg(() => idxList.sassIndexToListIndex(new SassNumber(9)), "Invalid index 9 for a list with 2 elements.", "msg: index out of range");
  expectMsg(() => new SassString("hi").sassIndexToStringIndex(new SassNumber(9)), "Invalid index 9 for a string with 2 characters.", "msg: string index out of range");

  // Polish: logger option — @warn / @debug routed to the JS logger (dart shape)
  const logged = [];
  size.compileString('@warn "wmsg"; @debug 1 + 2; .a { b: c; }', {
    logger: {
      warn: (m, o) => logged.push(["warn", m, o.deprecation]),
      debug: (m) => logged.push(["debug", m]),
    },
  });
  assert.deepEqual(logged, [["warn", "wmsg", false], ["debug", "3"]], "logger: @warn + @debug routed");
  assert.equal(typeof size.Logger.silent.warn, "function", "logger: Logger.silent present");

  // Polish: charset option (verified == dart-sass 1.101)
  const nonAscii = '.a { content: "café"; }';
  assert.ok(size.compileString(nonAscii).css.startsWith("@charset"), "charset: default emits @charset");
  assert.ok(!size.compileString(nonAscii, { charset: false }).css.startsWith("@charset"), "charset: false suppresses @charset");
  assert.equal(size.compileString(nonAscii, { style: "compressed" }).css.charCodeAt(0), 0xfeff, "charset: compressed default BOM");
  assert.notEqual(size.compileString(nonAscii, { style: "compressed", charset: false }).css.charCodeAt(0), 0xfeff, "charset: compressed false no BOM");

  console.log("ok: custom functions — number/string/color/list/map/rest, override, error, async (Phase 4)");
}

console.log("all wasm modern-API + importer + CLI + custom-function tests passed");
