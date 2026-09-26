// Shared loader core for the `sasso` npm package's wasm variants.
//
// No wasm-bindgen: this marshals UTF-8 through the module's linear memory by
// hand against the raw `sasso_alloc` / `sasso_free` / `sasso_compile2` /
// `sasso_set_arena_bytes` ABI (see ../src/lib.rs).
//
// The public surface mirrors the dart-sass *modern* JS API — `compileString`,
// `compileStringAsync`, path-based `compile` / `compileAsync`, the
// `CompileResult` shape (`{ css, loadedUrls, sourceMap? }`), an `info` string,
// the Compiler API, and an `Exception` error class — so `sasso` is a drop-in for
// the `sass` npm package (sass-loader `api: "modern"`, Vite).
//
// TWO wasm modules (each lazily instantiated):
//   • a SYNC module (fast) drives the synchronous APIs (`compileString`,
//     `compile`). A custom importer that returns a Promise is rejected here —
//     the engine cannot await.
//   • an ASYNCIFY'd module (built with `wasm-opt --asyncify`) drives the async
//     APIs (`compileStringAsync`, `compileAsync`, the Compiler API's async
//     methods). It can SUSPEND the whole compile across an `await`, so
//     asynchronous importers — the kind sass-loader and Vite inject by default —
//     work. This is the dart-sass async story without a native binary.
//     Concurrent async compiles run on a lazily-grown POOL of asyncify
//     instances (each suspends independently), capped by
//     `configure({ asyncInstances })` — default min(4, cores).
//
// Importers (`@use`/`@forward`/`@import`) are resolved by calling back into JS
// (wasm has no filesystem): the host functions below drive the per-compile
// importer chain in `_importer.mjs` (user importers + a Node-fs importer for
// `loadPaths`/relative loads) and record `loadedUrls`.

import { readFileSync } from "node:fs";
import { resolve as resolvePath } from "node:path";
// Default import, NOT a named one: `availableParallelism` only exists on
// Node >= 18.14, and a missing named export fails ESM *linking* — the whole
// package (sync APIs included) would throw at import time on older Nodes.
import os from "node:os";
import { pathToFileURL, fileURLToPath } from "node:url";
import {
  isThenable,
  makeFsImporter,
  normalizeImporter,
  syntaxCode,
  syntaxForPath,
  decodeUtf8,
} from "./_importer.mjs";
import { deserializeArgs, serializeValue, setEngine } from "./_value.mjs";
import { normalizeSilenced, ensureSilenceSupported } from "./_deprecations.mjs";

const encoder = new TextEncoder();
const decoder = new TextDecoder();
// The default decoder strips a leading BOM; the compressed-output charset prefix
// IS a U+FEFF BOM, so decode CSS with a BOM-preserving decoder to keep it (dart).
const cssDecoder = new TextDecoder("utf-8", { ignoreBOM: true });

// Asyncify runtime states (from `asyncify_get_state`).
const ASYNCIFY_UNWINDING = 1;
const ASYNCIFY_REWINDING = 2;
// Asyncify stack-state region: [curr: u32][end: u32] header + this much stack.
// Sized for a deep compile suspended at a nested import; a spill would corrupt,
// so we reserve generously (one allocation per async instance).
const ASYNCIFY_STACK_BYTES = 1 << 20; // 1 MiB

// Package version, for `info`. Read once from the published package.json (the
// release workflow syncs its `version` to the git tag). Best-effort: outside a
// Node filesystem (e.g. some bundlers) this degrades to a placeholder.
let VERSION = "0.0.0";
try {
  VERSION = JSON.parse(
    readFileSync(new URL("./package.json", import.meta.url), "utf8"),
  ).version;
} catch {
  // ignore — `info` falls back to the placeholder
}

/**
 * A Sass compilation error. Approximates the dart-sass `Exception`:
 * `instanceof Error`, `name === "Exception"`, plus `sassMessage` (the message
 * without the leading `Error: `). Structured `span` data awaits a later release.
 */
export class Exception extends Error {
  constructor(message, sassMessage, span) {
    super(message);
    this.name = "Exception";
    // dart-sass `sassMessage` is the raw one-line message (no "Error:" header /
    // snippet); fall back to stripping the header off the rendered block.
    this.sassMessage = sassMessage ?? message.replace(/^Error:\s*/, "");
    if (span) this.span = span;
  }
  toString() {
    return this.message;
  }
}

// `info` masquerades as dart-sass so build tools that gate on the
// implementation *name* accept sasso as a drop-in. sass-loader hard-rejects any
// `info` whose first tab-field isn't `dart-sass`/`sass-embedded`; Vite ignores
// `info` entirely. The version field claims a recent dart-sass we're
// API-compatible with (bump as the modern API evolves); the descriptive field
// honestly discloses the real engine. See ../../docs/NPM_BARE_NAME_PLAN.md.
const DART_SASS_COMPAT = "1.101.0";
export const info = `dart-sass\t${DART_SASS_COMPAT}\t(sasso ${VERSION})\t[Rust]`;

/** dart-sass `Logger` namespace. `Logger.silent` discards all warnings/debugs. */
export const Logger = {
  silent: { warn() {}, debug() {} },
};

/** Coerce a path or URL to a `file:` (or other-scheme) URL for `loadedUrls`. */
function toFileUrl(pathOrUrl) {
  if (pathOrUrl instanceof URL) return pathOrUrl;
  if (typeof pathOrUrl === "string" && /^[a-z][a-z0-9+.-]*:/i.test(pathOrUrl)) {
    return new URL(pathOrUrl);
  }
  return pathToFileURL(String(pathOrUrl));
}

/**
 * The entry stylesheet, refusing bytes that are not UTF-8.
 *
 * `Invalid UTF-8.` rather than the importer's `Cannot read …` wording,
 * because that is what the binary says for an ENTRY it cannot decode and
 * what dart says for one — see `read_source` in `src/main.rs`.
 */
function readEntry(fsPath) {
  const source = decodeUtf8(readFileSync(fsPath));
  if (source === null) throw new Exception("Error: Invalid UTF-8.");
  return source;
}

/** Coerce a path or `file:` URL to a filesystem path for `readFileSync`. */
function toFsPath(pathOrUrl) {
  if (pathOrUrl instanceof URL) return fileURLToPath(pathOrUrl);
  if (typeof pathOrUrl === "string" && pathOrUrl.startsWith("file:")) {
    return fileURLToPath(pathOrUrl);
  }
  return pathOrUrl;
}

function errMessage(e) {
  return e && e.message ? String(e.message) : String(e);
}

/** Frame an importer load result for the wasm: [syntax][smu?][smuLen][smu][contents]. */
function frameLoad(res) {
  const contents = encoder.encode(res.contents);
  const smu = res.sourceMapUrl != null ? encoder.encode(res.sourceMapUrl) : null;
  const frame = new Uint8Array(6 + (smu ? smu.length : 0) + contents.length);
  frame[0] = res.syntax & 0xff;
  frame[1] = smu ? 1 : 0;
  new DataView(frame.buffer).setUint32(2, smu ? smu.length : 0, true);
  let off = 6;
  if (smu) {
    frame.set(smu, off);
    off += smu.length;
  }
  frame.set(contents, off);
  return frame;
}

/**
 * Build the per-compile importer chain. `async` selects the asyncify path
 * (importer callbacks may return Promises) vs. the sync path (a Promise is a
 * hard error). Tracks the resolver that owns each canonical URL (so `load`
 * routes back) and the URLs actually loaded (for `loadedUrls`).
 *
 * The async chain is MAYBE-ASYNC: its results stay plain values while every
 * step settles synchronously, becoming a Promise only when a resolver actually
 * returns a thenable. `asyncHostFn` delivers a plain value without an asyncify
 * unwind, so fully-sync chains (loadPaths, sync importers) never suspend.
 */
function buildChain(options, async) {
  const userImporters = (options.importers || []).map((i) => normalizeImporter(i, async));
  // dart-sass `quietDeps`: the canonical URLs reached through a load path or a
  // custom importer, plus whatever those load relatively. Filled in as the
  // compile resolves, and read back by `host_canonicalize` — the compiler
  // itself decides what to silence, so a silenced warning does not surface as
  // a "repetitive deprecation warnings omitted" count either.
  const deps = new Set();
  const fsImporter = makeFsImporter(options.loadPaths, deps);
  const resolvers = [...userImporters, fsImporter];
  const byCanonical = new Map();
  const loaded = [];
  // A custom importer's stylesheets are dependencies whatever they are named
  // (measured: dart 1.104.1's JS API silences their deprecations under
  // `quietDeps`); the fs importer decides for itself, by load path.
  const note = (canon, r) => {
    byCanonical.set(canon, r);
    if (r !== fsImporter) deps.add(canon);
  };
  if (async) {
    // Walk the resolver list synchronously; on the first thenable, switch to
    // a Promise continuation that resumes the walk where it left off.
    const walk = (i, url, fromImport, containing) => {
      for (; i < resolvers.length; i++) {
        const r = resolvers[i];
        const canon = r.canonicalize(url, fromImport, containing);
        if (isThenable(canon)) {
          return canon.then((c) => {
            if (c != null) {
              note(c, r);
              return c;
            }
            return walk(i + 1, url, fromImport, containing);
          });
        }
        if (canon != null) {
          note(canon, r);
          return canon;
        }
      }
      return null;
    };
    return {
      loaded,
      deps,
      canonicalize(url, fromImport, containing) {
        return walk(0, url, fromImport, containing);
      },
      load(canon) {
        const r = byCanonical.get(canon);
        const res = r ? r.load(canon) : null;
        if (isThenable(res)) {
          return res.then((v) => {
            if (v != null) loaded.push(canon);
            return v;
          });
        }
        if (res != null) loaded.push(canon);
        return res;
      },
    };
  }
  return {
    loaded,
    deps,
    canonicalize(url, fromImport, containing) {
      for (const r of resolvers) {
        const canon = r.canonicalize(url, fromImport, containing);
        if (canon != null) {
          note(canon, r);
          return canon;
        }
      }
      return null;
    },
    load(canon) {
      const r = byCanonical.get(canon);
      const res = r ? r.load(canon) : null;
      if (res != null) loaded.push(canon);
      return res;
    },
  };
}

/** Assemble a dart-sass `CompileResult` from a raw compile + the loaded URLs. */
function makeResult(raw, entryHref, loaded) {
  const urls = [];
  const seen = new Set();
  const add = (href) => {
    if (href && !seen.has(href)) {
      seen.add(href);
      urls.push(new URL(href));
    }
  };
  add(entryHref);
  for (const h of loaded) add(h);
  const result = { css: raw.css, loadedUrls: urls };
  if (raw.sourceMap !== undefined) result.sourceMap = raw.sourceMap;
  return result;
}

/**
 * Build the public API bound to one SYNC wasm URL and one ASYNCIFY'd wasm URL
 * (both lazily instantiated; the async module is loaded only when an async API
 * is first used).
 * @param {URL} syncWasmUrl
 * @param {URL} asyncWasmUrl
 */
export function makeApi(syncWasmUrl, asyncWasmUrl) {
  let pendingArenaBytes = null; // applied at instantiation, before any compile

  // --- shared marshalling against an instance's exports ---
  function readStr(ex, ptr, len) {
    if (!ptr || !len) return "";
    // .slice() copies out of wasm memory immediately, before any alloc below
    // can grow (and detach) the backing buffer.
    return decoder.decode(new Uint8Array(ex.memory.buffer, ptr, len).slice());
  }
  function deliver(ex, bytes, outPtrCell, outLenCell) {
    const p = bytes.length ? ex.sasso_alloc(bytes.length) : 0;
    // `sasso_alloc` may have grown memory — take fresh views afterwards.
    if (bytes.length) new Uint8Array(ex.memory.buffer, p, bytes.length).set(bytes);
    const view = new DataView(ex.memory.buffer);
    view.setUint32(outPtrCell, p, true); // *out_ptr  (u32 pointer on wasm32)
    view.setUint32(outLenCell, bytes.length, true); // *out_len (usize == u32)
  }

  // Read the result buffer after a sasso_compile2 call, free scratch, and throw
  // on a Sass error. Shared by the sync and async drivers.
  function readResult(w, outPtr, m, wantMap) {
    const { scratch, inPtr, inLen, urlPtr, urlLen, silencedPtr, silencedLen, cwdPtr, cwdLen } = m;
    const view = new DataView(w.memory.buffer);
    const outLen = view.getUint32(scratch, true);
    const ok = view.getUint8(scratch + 4);
    const out = new Uint8Array(w.memory.buffer, outPtr, outLen).slice();
    if (inLen) w.sasso_free(inPtr, inLen);
    if (urlLen) w.sasso_free(urlPtr, urlLen);
    if (silencedLen) w.sasso_free(silencedPtr, silencedLen);
    if (cwdLen) w.sasso_free(cwdPtr, cwdLen);
    w.sasso_free(scratch, 8);
    w.sasso_free(outPtr, outLen);
    if (!ok) {
      // Structured error frame: [line u32][col u32][url str][sassMessage str][rendered str].
      const dv = new DataView(out.buffer, out.byteOffset, out.byteLength);
      let o = 0;
      const line = dv.getUint32(o, true);
      o += 4;
      const col = dv.getUint32(o, true);
      o += 4;
      const rd = () => {
        const n = dv.getUint32(o, true);
        o += 4;
        const s = decoder.decode(out.subarray(o, o + n));
        o += n;
        return s;
      };
      const url = rd();
      const sassMessage = rd();
      const rendered = rd();
      const span = line > 0 ? { url: url || undefined, start: { line: line - 1, column: Math.max(0, col - 1), offset: 0 }, end: { line: line - 1, column: Math.max(0, col - 1), offset: 0 }, text: "", context: "" } : undefined;
      throw new Exception(rendered, sassMessage, span);
    }
    if (!wantMap) return { css: cssDecoder.decode(out) };
    const cssLen = new DataView(out.buffer, out.byteOffset, 4).getUint32(0, true);
    return {
      css: cssDecoder.decode(out.subarray(4, 4 + cssLen)),
      sourceMap: JSON.parse(decoder.decode(out.subarray(4 + cssLen))),
    };
  }

  // Allocate input + url + silenced ids + scratch and write them in. Returns
  // the handles the driver passes to the compile entry and on to readResult.
  function marshalIn(w, scss, opts) {
    const input = encoder.encode(scss);
    const urlBytes = opts.url ? encoder.encode(opts.url) : null;
    const urlLen = urlBytes ? urlBytes.length : 0;
    // One comma-joined string rather than a vector across the boundary: the
    // ABI is positional scalars, and the list is short and never contains a
    // comma (the ids are validated against a fixed set).
    const silBytes =
      opts.silenceDeprecations && opts.silenceDeprecations.length
        ? encoder.encode(opts.silenceDeprecations.join(","))
        : null;
    const silencedLen = silBytes ? silBytes.length : 0;
    // This target has no `getcwd` — it is wasm32-unknown-unknown, not wasip1 —
    // so a diagnostic path has nothing to be relative to unless we say. Left
    // unsaid, a stack frame kept the absolute path here while the native addon
    // printed a relative one: the same error, two answers (#153).
    const cwdBytes = opts.cwd ? encoder.encode(opts.cwd) : null;
    const cwdLen = cwdBytes ? cwdBytes.length : 0;
    // Before the first allocation, deliberately: this throws for a list the
    // module cannot apply, and nothing frees these buffers on the way out —
    // `readResult` owns that and is only reached on a completed compile. A
    // guard placed after the allocations traded a silently-ignored option for
    // a leak on every attempt.
    ensureSilenceSupported(typeof w.sasso_compile3 === "function", silencedLen);
    const inPtr = input.length ? w.sasso_alloc(input.length) : 0;
    const urlPtr = urlLen ? w.sasso_alloc(urlLen) : 0;
    const silencedPtr = silencedLen ? w.sasso_alloc(silencedLen) : 0;
    const cwdPtr = cwdLen ? w.sasso_alloc(cwdLen) : 0;
    const scratch = w.sasso_alloc(8);
    if (input.length) new Uint8Array(w.memory.buffer, inPtr, input.length).set(input);
    if (urlLen) new Uint8Array(w.memory.buffer, urlPtr, urlLen).set(urlBytes);
    if (silencedLen) new Uint8Array(w.memory.buffer, silencedPtr, silencedLen).set(silBytes);
    if (cwdLen) new Uint8Array(w.memory.buffer, cwdPtr, cwdLen).set(cwdBytes);
    return { inPtr, inLen: input.length, urlPtr, urlLen, silencedPtr, silencedLen, cwdPtr, cwdLen, scratch };
  }

  function callCompile2(w, m, opts) {
    // `sasso_compile3` when the module has it — it takes the
    // `silenceDeprecations` list that `compile2` has no parameter for. Older
    // modules keep working through `compile2`, which is why the export is
    // checked rather than assumed: the .wasm files are build artifacts and a
    // stale one next to a new loader would otherwise fail on an undefined call.
    // `sasso_compile4` takes the working directory; `compile3` has no
    // parameter for it and a frame there keeps the absolute path, which is
    // what this build did before. A stale .wasm beside a new loader is the
    // reason each generation is checked rather than assumed — they are build
    // artifacts, not shipped in step with the JS.
    if (typeof w.sasso_compile4 === "function") {
      return w.sasso_compile4(
        m.inPtr, m.inLen, opts.compressed ? 1 : 0, opts.syntax, 1,
        m.urlPtr, m.urlLen, opts.wantMap ? 1 : 0, opts.includeSources ? 1 : 0, opts.charset ? 1 : 0,
        opts.quietDeps ? 1 : 0, opts.unicode ? 1 : 0,
        m.silencedPtr, m.silencedLen,
        m.cwdPtr, m.cwdLen,
        m.scratch, m.scratch + 4,
      );
    }
    if (typeof w.sasso_compile3 === "function") {
      return w.sasso_compile3(
        m.inPtr, m.inLen, opts.compressed ? 1 : 0, opts.syntax, 1,
        m.urlPtr, m.urlLen, opts.wantMap ? 1 : 0, opts.includeSources ? 1 : 0, opts.charset ? 1 : 0,
        opts.quietDeps ? 1 : 0, opts.unicode ? 1 : 0,
        m.silencedPtr, m.silencedLen,
        m.scratch, m.scratch + 4,
      );
    }
    // Unreachable with a non-empty list: `marshalIn` has already refused that
    // combination, before allocating anything there is to leak.
    return w.sasso_compile2(
      m.inPtr, m.inLen, opts.compressed ? 1 : 0, opts.syntax, 1,
      m.urlPtr, m.urlLen, opts.wantMap ? 1 : 0, opts.includeSources ? 1 : 0, opts.charset ? 1 : 0,
      opts.quietDeps ? 1 : 0, opts.unicode ? 1 : 0,
      m.scratch, m.scratch + 4,
    );
  }

  // Register `options.functions` on a freshly-cleared instance registry and
  // return the callbacks array (index -> user function), matching the indices
  // `sasso_register_function` assigns.
  function registerFunctions(w, options) {
    w.sasso_clear_functions();
    const callbacks = [];
    if (options.functions) {
      for (const [sig, fn] of Object.entries(options.functions)) {
        const b = encoder.encode(sig);
        const p = b.length ? w.sasso_alloc(b.length) : 0;
        if (b.length) new Uint8Array(w.memory.buffer, p, b.length).set(b);
        w.sasso_register_function(p, b.length);
        if (b.length) w.sasso_free(p, b.length);
        callbacks.push(fn);
      }
    }
    return callbacks;
  }

  // ============================ SYNC instance ============================
  let syncEx; // cached sync exports
  let syncChain = null; // importer chain for the in-flight sync compile
  let syncFunctions = []; // index -> user custom function for the in-flight compile
  let syncLogger = null; // dart-sass `logger` for the in-flight sync compile

  // Decode a host_warn buffer (see wasm/src/lib.rs make_host_warn).
  function decodeWarn(ex, ptr, len) {
    const view = new DataView(ex.memory.buffer, ptr, len);
    let o = 0;
    const kind = view.getUint8(o);
    o += 1;
    const deprecation = view.getUint8(o) !== 0;
    o += 1;
    const line = view.getUint32(o, true);
    o += 4;
    const rs = () => {
      const n = view.getUint32(o, true);
      o += 4;
      const s = readStr(ex, ptr + o, n);
      o += n;
      return s;
    };
    const deprecationId = rs();
    const url = rs();
    const message = rs();
    const formatted = rs();
    return { kind, deprecation, line, deprecationId, url, message, formatted };
  }
  // A best-effort SourceSpan (full span is a separate item); enough for the
  // common `span.url` / `span.start.line` reads. Lines are 0-based, like dart.
  function spanOf(ev) {
    if (!ev.url && !ev.line) return undefined;
    const start = { line: ev.line > 0 ? ev.line - 1 : 0, column: 0 };
    return { url: ev.url || undefined, start, end: start, text: "", context: "" };
  }
  // Print the formatted block to stderr (matching native sasso/dart output).
  function defaultLog(ev) {
    if (typeof process !== "undefined" && process.stderr) process.stderr.write(ev.formatted + "\n");
    else console.error(ev.formatted);
  }
  // Route a decoded diagnostic to the in-flight `logger`, else print it.
  function dispatchWarn(logger, ev) {
    if (ev.kind === 1) {
      if (logger && typeof logger.debug === "function") return logger.debug(ev.message, { span: spanOf(ev) });
    } else if (logger && typeof logger.warn === "function") {
      return logger.warn(ev.message, {
        deprecation: ev.deprecation,
        deprecationType: ev.deprecationId || undefined,
        span: spanOf(ev),
        stack: undefined,
      });
    }
    defaultLog(ev);
  }

  // `host_canonicalize`'s success frame: [dependency: u8][canonical URL bytes].
  // The flag travels with the URL rather than through a second call, because
  // only the host knows HOW a load resolved, and the compiler needs that to
  // apply `quietDeps` ahead of its deprecation repetition cap.
  function frameCanon(chain, canon) {
    const url = encoder.encode(canon);
    const frame = new Uint8Array(url.length + 1);
    frame[0] = chain && chain.deps && chain.deps.has(canon) ? 1 : 0;
    frame.set(url, 1);
    return frame;
  }

  const syncHost = {
    host_canonicalize(uPtr, uLen, fromImport, cPtr, cLen, outPtr, outLen) {
      const url = readStr(syncEx, uPtr, uLen);
      const containing = cLen ? readStr(syncEx, cPtr, cLen) : null;
      try {
        const canon = syncChain ? syncChain.canonicalize(url, fromImport !== 0, containing) : null;
        if (canon == null) return 0;
        deliver(syncEx, frameCanon(syncChain, canon), outPtr, outLen);
        return 1;
      } catch (e) {
        deliver(syncEx, encoder.encode(errMessage(e)), outPtr, outLen);
        return -1;
      }
    },
    host_load(kPtr, kLen, outPtr, outLen) {
      const canon = readStr(syncEx, kPtr, kLen);
      try {
        const res = syncChain ? syncChain.load(canon) : null;
        if (res == null) return 0;
        deliver(syncEx, frameLoad(res), outPtr, outLen);
        return 1;
      } catch (e) {
        deliver(syncEx, encoder.encode(errMessage(e)), outPtr, outLen);
        return -1;
      }
    },
    host_call_function(index, argsPtr, argsLen, outPtr, outLen) {
      try {
        const argBytes = argsLen ? new Uint8Array(syncEx.memory.buffer, argsPtr, argsLen).slice() : new Uint8Array(0);
        const fn = syncFunctions[index];
        if (!fn) throw new Error(`sasso: custom function #${index} is not registered`);
        const r = fn(deserializeArgs(argBytes));
        if (r && typeof r.then === "function") {
          throw new Error("sasso: asynchronous custom functions require compileStringAsync / compileAsync");
        }
        if (r == null) throw new Error("sasso: a custom function returned no value");
        deliver(syncEx, serializeValue(r), outPtr, outLen);
        return 1;
      } catch (e) {
        deliver(syncEx, encoder.encode(errMessage(e)), outPtr, outLen);
        return -1;
      }
    },
    host_warn(bufPtr, bufLen) {
      try {
        dispatchWarn(syncLogger, decodeWarn(syncEx, bufPtr, bufLen));
      } catch {
        // A logging failure must never fail the compile.
      }
    },
  };

  function syncInstance() {
    if (syncEx) return syncEx;
    const module = new WebAssembly.Module(readFileSync(syncWasmUrl));
    syncEx = new WebAssembly.Instance(module, { sasso_host: syncHost }).exports;
    if (pendingArenaBytes !== null) syncEx.sasso_set_arena_bytes(pendingArenaBytes);
    return syncEx;
  }

  function compileRawSync(scss, opts) {
    const w = syncInstance();
    const m = marshalIn(w, scss, opts);
    const outPtr = callCompile2(w, m, opts);
    return readResult(w, outPtr, m, opts.wantMap);
  }

  // Engine for routed Value methods (SassNumber.convert, SassColor.toSpace, …):
  // runs `sasso_value_op` on the sync instance, independent of any compile, so
  // the methods work standalone and re-entrantly during a compile. Returns the
  // result bytes; throws the engine's message on failure.
  function valueOpEngine(op, argsBytes) {
    const w = syncInstance();
    const inPtr = argsBytes.length ? w.sasso_alloc(argsBytes.length) : 0;
    const scratch = w.sasso_alloc(8);
    if (argsBytes.length) new Uint8Array(w.memory.buffer, inPtr, argsBytes.length).set(argsBytes);
    const outPtr = w.sasso_value_op(op, inPtr, argsBytes.length, scratch, scratch + 4);
    const view = new DataView(w.memory.buffer);
    const outLen = view.getUint32(scratch, true);
    const ok = view.getUint8(scratch + 4);
    const out = new Uint8Array(w.memory.buffer, outPtr, outLen).slice();
    if (argsBytes.length) w.sasso_free(inPtr, argsBytes.length);
    w.sasso_free(scratch, 8);
    w.sasso_free(outPtr, outLen);
    if (!ok) throw new Error(decoder.decode(out));
    return out;
  }
  setEngine(valueOpEngine);

  // ========================= ASYNCIFY engine pool =========================
  // One AsyncEngine = one instantiation of the (cached) asyncify'd module with
  // its own linear memory, its own 1 MiB asyncify stack, and its own in-flight
  // compile state. An engine runs ONE compile at a time (single asyncify stack
  // + the wasm-side custom-function registry), so concurrency comes from a
  // lazily-grown pool: while one compile is SUSPENDED awaiting an importer,
  // another engine's compile runs — a bundler fanning out N entries no longer
  // queues them behind one another. Memory cost per engine = module memory
  // (incl. the arena reservation) + the asyncify stack; the pool grows only on
  // demand, capped at `maxAsyncEngines` (configure({ asyncInstances })).
  let asyncModule = null; // compiled WebAssembly.Module, shared by all engines
  const enginePool = []; // every live engine (busy and idle)
  const engineWaiters = []; // FIFO resolvers awaiting a freed engine
  let maxAsyncEngines = defaultMaxEngines();

  function defaultMaxEngines() {
    try {
      const n = typeof os.availableParallelism === "function" ? os.availableParallelism() : os.cpus().length;
      return Math.max(1, Math.min(4, n || 1));
    } catch {
      return 2; // non-Node host without os support
    }
  }

  const ASYNCIFY_MISSING =
    "sasso: this async module was built without asyncify (wasm-opt was missing " +
    "at build time), so asynchronous importers and custom functions cannot " +
    "suspend the engine — return values synchronously or rebuild with wasm-opt";

  // On a normal call, run the chain lookup SYNCHRONOUSLY: a plain (non-thenable)
  // result is delivered immediately and the final rc returned with the asyncify
  // state left NORMAL — no unwind, no microtask, no rewind. Asyncify imports may
  // suspend only *sometimes*; this fast path is the exact contract the
  // non-asyncified sync module always runs. Only a thenable pays the suspension:
  // stash a Promise<{rc, bytes}> and unwind; on the rewind re-entry, stop the
  // rewind and hand that delivery back to the engine.
  //
  // rc contract (wasm/src/lib.rs): 1 = delivered, 0 = miss, -1 = error. rc 0 is
  // an ERROR for host_call_function, whose lookup therefore never returns null
  // (it throws instead), keeping the miss branch unreachable there.
  //
  // The import object is built PER ENGINE: every host fn closes over its
  // engine's record (exports, asyncify stack, in-flight chain/functions/logger,
  // pending delivery), so concurrent compiles on different engines never touch
  // each other's state.
  function makeAsyncHost(engine) {
    function hostFn(lookup, encodeOk) {
      return (...args) => {
        const outPtr = args[args.length - 2];
        const outLen = args[args.length - 1];
        if (engine.ready && engine.ex.asyncify_get_state() === ASYNCIFY_REWINDING) {
          engine.ex.asyncify_stop_rewind();
          const d = engine.pendingDelivery;
          engine.pendingDelivery = null;
          if (!d || d.rc === 0) return 0;
          deliver(engine.ex, d.bytes, outPtr, outLen);
          return d.rc;
        }
        let v;
        try {
          v = lookup(args);
        } catch (e) {
          deliver(engine.ex, encoder.encode(errMessage(e)), outPtr, outLen);
          return -1;
        }
        if (isThenable(v)) {
          if (!engine.ready) {
            // Degraded module (built without wasm-opt): it cannot suspend, so a
            // genuinely-async result is undeliverable — fail this load clearly.
            // Adopt the abandoned thenable's rejection so it can't surface
            // later as an unhandledRejection.
            Promise.resolve(v).catch(() => {});
            deliver(engine.ex, encoder.encode(ASYNCIFY_MISSING), outPtr, outLen);
            return -1;
          }
          engine.pendingDelivery = Promise.resolve(v)
            .then((r) => (r == null ? { rc: 0 } : { rc: 1, bytes: encodeOk(r) }))
            .catch((e) => ({ rc: -1, bytes: encoder.encode(errMessage(e)) }));
          engine.ex.asyncify_start_unwind(engine.data);
          return 0; // ignored while unwinding
        }
        if (v == null) return 0; // miss (canonicalize/load only — see above)
        let bytes;
        try {
          bytes = encodeOk(v);
        } catch (e) {
          deliver(engine.ex, encoder.encode(errMessage(e)), outPtr, outLen);
          return -1;
        }
        deliver(engine.ex, bytes, outPtr, outLen);
        return 1;
      };
    }
    return {
      host_canonicalize: hostFn(
        (args) => {
          const url = readStr(engine.ex, args[0], args[1]);
          const containing = args[4] ? readStr(engine.ex, args[3], args[4]) : null;
          return engine.chain.canonicalize(url, args[2] !== 0, containing);
        },
        // The dependency flag is read when the frame is built, which is after
        // an async resolver has settled — by then the chain has recorded it.
        (canon) => frameCanon(engine.chain, canon),
      ),
      host_load: hostFn(
        (args) => engine.chain.load(readStr(engine.ex, args[0], args[1])),
        (res) => frameLoad(res),
      ),
      host_call_function: hostFn(
        (args) => {
          const argBytes = args[2] ? new Uint8Array(engine.ex.memory.buffer, args[1], args[2]).slice() : new Uint8Array(0);
          const fn = engine.functions[args[0]];
          if (!fn) throw new Error(`sasso: custom function #${args[0]} is not registered`);
          // Resolve sync or async. A null return is an error (functions must
          // return a value) and must NOT map to the miss rc — throw instead.
          const r = fn(deserializeArgs(argBytes));
          if (isThenable(r)) {
            return Promise.resolve(r).then((v) => {
              if (v == null) throw new Error("sasso: a custom function returned no value");
              return v;
            });
          }
          if (r == null) throw new Error("sasso: a custom function returned no value");
          return r;
        },
        (v) => serializeValue(v),
      ),
      host_warn(bufPtr, bufLen) {
        try {
          dispatchWarn(engine.logger, decodeWarn(engine.ex, bufPtr, bufLen));
        } catch {
          // A logging failure must never fail the compile.
        }
      },
    };
  }

  function makeEngine() {
    if (!asyncModule) asyncModule = new WebAssembly.Module(readFileSync(asyncWasmUrl));
    const engine = {
      ex: null, // exports of this instantiation
      data: 0, // asyncify stack-state struct pointer (in this engine's memory)
      ready: false, // module actually carries the asyncify_* exports
      busy: false, // exactly one compile at a time per engine
      chain: null, // importer chain for the in-flight compile
      functions: [], // index -> user custom function for the in-flight compile
      logger: null, // dart-sass `logger` for the in-flight compile
      pendingDelivery: null, // a Promise<{rc, bytes}>, then its resolved value
    };
    // Host fns read engine.ex lazily at call time, so wiring the import object
    // before the instance exists is safe.
    engine.ex = new WebAssembly.Instance(asyncModule, { sasso_host: makeAsyncHost(engine) }).exports;
    if (pendingArenaBytes !== null) engine.ex.sasso_set_arena_bytes(pendingArenaBytes);
    engine.ready = typeof engine.ex.asyncify_start_unwind === "function";
    if (engine.ready) {
      engine.data = engine.ex.sasso_alloc(8 + ASYNCIFY_STACK_BYTES);
      const v = new DataView(engine.ex.memory.buffer);
      v.setUint32(engine.data, engine.data + 8, true); // current stack pointer
      v.setUint32(engine.data + 4, engine.data + 8 + ASYNCIFY_STACK_BYTES, true); // end
    }
    enginePool.push(engine);
    return engine;
  }

  // FIFO engine checkout: reuse an idle engine, grow the pool up to the cap,
  // else queue. Release hands the engine straight to the next waiter (it stays
  // busy), or drops it when the cap was lowered mid-flight.
  function acquireEngine() {
    const idle = enginePool.find((e) => !e.busy);
    if (idle) {
      idle.busy = true;
      return Promise.resolve(idle);
    }
    if (enginePool.length < maxAsyncEngines) {
      const engine = makeEngine();
      engine.busy = true;
      return Promise.resolve(engine);
    }
    return new Promise((resolve) => engineWaiters.push(resolve));
  }

  function releaseEngine(engine) {
    engine.chain = null;
    engine.functions = [];
    engine.logger = null;
    engine.pendingDelivery = null;
    engine.ex.sasso_clear_functions();
    const next = engineWaiters.shift();
    if (next) {
      next(engine); // handed over still busy
      return;
    }
    if (enginePool.length > maxAsyncEngines) {
      const i = enginePool.indexOf(engine);
      if (i !== -1) enginePool.splice(i, 1); // shrink toward a lowered cap
      return;
    }
    engine.busy = false;
  }

  // Check out an engine for one compile; the finally both frees the slot and
  // clears the per-compile state, so errors release too (no stuck engines).
  async function withEngine(task) {
    const engine = await acquireEngine();
    try {
      return await task(engine);
    } finally {
      releaseEngine(engine);
    }
  }

  // Drives one engine's asyncify unwind/rewind loop so async importers can
  // suspend that compile (other engines keep running during the await).
  async function compileRawAsync(engine, scss, opts) {
    const w = engine.ex;
    const m = marshalIn(w, scss, opts);
    let outPtr = callCompile2(w, m, opts);
    if (engine.ready) {
      while (w.asyncify_get_state() === ASYNCIFY_UNWINDING) {
        w.asyncify_stop_unwind();
        engine.pendingDelivery = await engine.pendingDelivery; // Promise<{rc,bytes}> -> value
        w.asyncify_start_rewind(engine.data);
        outPtr = callCompile2(w, m, opts);
      }
    }
    return readResult(w, outPtr, m, opts.wantMap);
  }

  /**
   * `process.cwd()` THROWS `ENOENT` when the directory the process started in
   * has been deleted — a build script that removes its own temp directory, a
   * watcher outliving a `git clean`. Reading it unguarded made every compile
   * fail there, `compileString` included, which touches no files at all.
   * Measured: `ENOENT: no such file or directory, uv_cwd`.
   *
   * `null` is a supported answer all the way down — the core falls back to an
   * absolute path in a frame — so a lost directory costs a nicer diagnostic
   * and nothing else.
   */
  function currentDirectory() {
    try {
      return typeof process !== "undefined" && process.cwd ? process.cwd() : null;
    } catch {
      return null;
    }
  }

  function rawOpts(options, syntax) {
    return {
      compressed: options.style === "compressed",
      syntax,
      url: options.url ? toFileUrl(options.url).href : null,
      // What that url is SHOWN relative to. It has to be handed over: this
      // module is wasm32-unknown-unknown and has no getcwd of its own.
      cwd: currentDirectory(),
      wantMap: !!options.sourceMap,
      includeSources: !!options.sourceMapIncludeSources,
      charset: options.charset !== false, // dart-sass default: true
      quietDeps: !!options.quietDeps,
      // dart-sass `silenceDeprecations`: ids dropped inside the compiler,
      // beside quietDeps, so they never reach the per-id cap. An id dart does
      // not know warns through the caller's own logger and compiles anyway,
      // as dart's JS API does — its CLI is the half that rejects.
      silenceDeprecations: normalizeSilenced(options.silenceDeprecations, (message) => {
        // Guarded like every other diagnostic in this package: `host_warn`
        // swallows a logger that throws so a broken logger cannot fail a
        // compile, and this warning is raised before the compile reaches it.
        // (dart propagates here, and for ordinary diagnostics too — the
        // package's rule is deliberate and applies to both or to neither.)
        try {
          dispatchWarn(options.logger ?? null, {
            kind: 0,
            message,
            formatted: `WARNING: ${message}`,
            deprecation: false,
            deprecationId: "",
          });
        } catch {
          // A logging failure must never fail the compile.
        }
      }),
      unicode: options.unicode !== false, // sasso extension: the CLI's --no-unicode
    };
  }

  // ------------------------- configure -------------------------
  function configure(options = {}) {
    if (Number.isFinite(options.arenaMiB)) {
      pendingArenaBytes = Math.max(0, Math.floor(options.arenaMiB * 1024 * 1024));
      // Apply to whichever instances already exist (and stash for the rest).
      if (syncEx) syncEx.sasso_set_arena_bytes(pendingArenaBytes);
      for (const engine of enginePool) engine.ex.sasso_set_arena_bytes(pendingArenaBytes);
      if (!syncEx && enginePool.length === 0) syncInstance().sasso_set_arena_bytes(pendingArenaBytes);
    }
    // Number.isFinite, not typeof: NaN passes typeof and would freeze the
    // pool (`length < NaN` never grows it) — every async compile then queues
    // forever. Realistic trigger: Number(unset env var).
    if (Number.isFinite(options.asyncInstances)) {
      maxAsyncEngines = Math.max(1, Math.floor(options.asyncInstances));
      // Shrink toward a lowered cap now (idle engines) and as compiles finish
      // (busy ones — see releaseEngine).
      for (let i = enginePool.length - 1; i >= 0 && enginePool.length > maxAsyncEngines; i--) {
        if (!enginePool[i].busy) enginePool.splice(i, 1);
      }
      // A raised cap must serve the queue: waiters were parked because growth
      // was capped, and nothing else ever grows the pool on their behalf.
      while (engineWaiters.length > 0 && enginePool.length < maxAsyncEngines) {
        const engine = makeEngine();
        engine.busy = true;
        engineWaiters.shift()(engine);
      }
    }
  }

  // --------------------- dart-sass *modern* API ---------------------

  function compileString(source, options = {}) {
    if (typeof source !== "string") {
      throw new TypeError("compileString(source): source must be a string");
    }
    const chain = buildChain(options, false);
    const callbacks = registerFunctions(syncInstance(), options);
    const prevChain = syncChain;
    const prevFns = syncFunctions;
    const prevLog = syncLogger;
    syncChain = chain;
    syncFunctions = callbacks;
    syncLogger = options.logger ?? null;
    let raw;
    try {
      raw = compileRawSync(source, rawOpts(options, syntaxCode(options.syntax)));
    } finally {
      syncChain = prevChain;
      syncFunctions = prevFns;
      syncLogger = prevLog;
      syncEx.sasso_clear_functions();
    }
    return makeResult(raw, options.url ? toFileUrl(options.url).href : null, chain.loaded);
  }

  function compile(path, options = {}) {
    const fsPath = toFsPath(path);
    const source = readEntry(fsPath);
    // The entry keeps the path it was NAMED by (absolute and normalized, but
    // symlinks intact), like every other load — see `canonicalHrefFor`.
    const entryPath = resolvePath(fsPath);
    const entryHref = toFileUrl(entryPath).href;
    const syntax = options.syntax != null ? syntaxCode(options.syntax) : syntaxForPath(entryPath);
    const chain = buildChain(options, false);
    const callbacks = registerFunctions(syncInstance(), options);
    const prevChain = syncChain;
    const prevFns = syncFunctions;
    const prevLog = syncLogger;
    syncChain = chain;
    syncFunctions = callbacks;
    syncLogger = options.logger ?? null;
    let raw;
    try {
      raw = compileRawSync(source, { ...rawOpts(options, syntax), url: entryHref });
    } finally {
      syncChain = prevChain;
      syncFunctions = prevFns;
      syncLogger = prevLog;
      syncEx.sasso_clear_functions();
    }
    return makeResult(raw, entryHref, chain.loaded);
  }

  function compileStringAsync(source, options = {}) {
    return withEngine(async (engine) => {
      if (typeof source !== "string") {
        throw new TypeError("compileStringAsync(source): source must be a string");
      }
      const chain = buildChain(options, true);
      engine.functions = registerFunctions(engine.ex, options);
      engine.chain = chain;
      engine.logger = options.logger ?? null;
      const raw = await compileRawAsync(engine, source, rawOpts(options, syntaxCode(options.syntax)));
      return makeResult(raw, options.url ? toFileUrl(options.url).href : null, chain.loaded);
    });
  }

  function compileAsync(path, options = {}) {
    return withEngine(async (engine) => {
      const fsPath = toFsPath(path);
      const source = readEntry(fsPath);
      const entryPath = resolvePath(fsPath);
      const entryHref = toFileUrl(entryPath).href;
      const syntax = options.syntax != null ? syntaxCode(options.syntax) : syntaxForPath(entryPath);
      const chain = buildChain(options, true);
      engine.functions = registerFunctions(engine.ex, options);
      engine.chain = chain;
      engine.logger = options.logger ?? null;
      const raw = await compileRawAsync(engine, source, { ...rawOpts(options, syntax), url: entryHref });
      return makeResult(raw, entryHref, chain.loaded);
    });
  }

  // dart-sass Compiler API (1.70+). Vite's scss pipeline calls
  // `initAsyncCompiler()` then `compiler.compileStringAsync(...)`. Our engine is
  // stateless, so a "compiler" is just the same entry points with a no-op
  // `dispose()`.
  function initCompiler() {
    return { compile, compileString, dispose() {} };
  }
  async function initAsyncCompiler() {
    return { compileAsync, compileStringAsync, async dispose() {} };
  }

  return {
    compile,
    compileAsync,
    compileString,
    compileStringAsync,
    initCompiler,
    initAsyncCompiler,
    configure,
    info,
  };
}
