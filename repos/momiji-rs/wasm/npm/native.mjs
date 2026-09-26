// sasso/native — the dart-sass *modern* API on the NATIVE Node addon
// (no wasm, no asyncify). Same API and byte-identical output as the default
// wasm entries; each async compile runs on its own OS thread, so concurrent
// compiles scale across cores. `loadPaths`/relative resolution run natively in
// Rust; only user importers, custom functions, and the logger cross into JS.
//
// The compiled addon (`sasso.node`) resolves in order:
//   1. `SASSO_NATIVE_BINARY` — explicit path override (dev/tests);
//   2. the platform package `sasso-native-<platform>-<arch>[-<libc>]`
//      (published alongside `sasso` as an optionalDependency, so `npm install
//      sasso` fetches exactly the one matching this machine);
//   3. the repo-local build `../../napi/npm/sasso.node` (a git checkout after
//      `bash napi/build.sh`; never present in the published tarball).
// A miss throws with the supported-platform list and points at the wasm
// entries, which work everywhere.
//
// Shares `_importer.mjs` (user-importer chain), `_value.mjs` (custom-function
// byte protocol over the native valueOp), and `_loader.mjs`'s Exception with
// the wasm entries — one source of truth for API semantics.

import { createRequire } from "node:module";
import { readFileSync } from "node:fs";
import { resolve as resolvePath, isAbsolute } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";
import {
  isThenable,
  normalizeImporter,
  syntaxCode,
  syntaxForPath,
  decodeUtf8,
} from "./_importer.mjs";
import { Exception, Logger } from "./_loader.mjs";
import { deserializeArgs, serializeValue, setEngine, valueApi } from "./_value.mjs";
import { normalizeSilenced } from "./_deprecations.mjs";
import { assertAddonVersion, platformKey, SUPPORTED } from "./_addon.mjs";

const require_ = createRequire(import.meta.url);

// This package's own version, for the pairing check below. The published
// package.json carries the release version (the publish workflow writes it
// from the tag); a repo checkout's is stale, which is why a checkout has no
// platform package to disagree with it.
function ownVersion() {
  try {
    return JSON.parse(readFileSync(new URL("./package.json", import.meta.url), "utf8")).version ?? null;
  } catch {
    return null;
  }
}

// Returns the binding plus where it came from: only the platform package is a
// published pairing with a version to check. `SASSO_NATIVE_BINARY` and the
// repo-local build are development paths and report `null`.
function loadNativeBinding() {
  const override = process.env.SASSO_NATIVE_BINARY;
  if (override) return { binding: require_(override), version: null, pkg: null };
  const key = platformKey();
  const pkg = SUPPORTED[key];
  const tried = [];
  if (pkg) {
    try {
      const binding = require_(pkg);
      let version = null;
      try {
        version = require_(`${pkg}/package.json`).version ?? null;
      } catch {
        // No readable manifest: nothing to compare, so nothing to refuse.
      }
      return { binding, version, pkg };
    } catch (e) {
      tried.push(`${pkg}: ${e.code ?? e.message}`);
    }
  }
  try {
    // Repo-checkout dev fallback (not part of the published package).
    return {
      binding: require_(new URL("../../napi/npm/sasso.node", import.meta.url).pathname),
      version: null,
      pkg: null,
    };
  } catch (e) {
    tried.push(`repo build: ${e.code ?? e.message}`);
  }
  throw new Error(
    `sasso/native: no native binding for ${key}. ` +
      `Prebuilt platforms: ${Object.keys(SUPPORTED).join(", ")}. ` +
      `The wasm entries ("sasso", "sasso/speed") work everywhere. ` +
      `(tried: ${tried.join("; ") || "nothing — unsupported platform"})`,
  );
}

const { binding: native, version: addonVersion, pkg: addonPkg } = loadNativeBinding();
// Before anything uses it: a mismatched addon compiles happily and drops the
// options it does not recognise, so the failure has to happen here or not at
// all. See _addon.mjs and #114.
assertAddonVersion(ownVersion(), addonVersion, addonPkg);

// Route the Value-method engine (SassNumber.convert, SassColor.toSpace, …)
// through the native valueOp. Module-global by design (same caveat as the
// wasm entries: in a process importing several sasso entries, the last import
// wins the engine slot — all engines are equivalent).
setEngine((op, argsBytes) => {
  try {
    return new Uint8Array(native.valueOp(op, Buffer.from(argsBytes)));
  } catch (e) {
    throw new Error(e.message);
  }
});

export { Exception, Logger };
// The addon's own `nativeVersion()` is `napi/Cargo.toml`'s version, which is
// not the released one and reads here as though it were; prefer the platform
// package's, and keep the old field for a dev build that has no manifest.
export const info = `dart-sass\t1.101.0\t(sasso-native ${addonVersion ?? native.nativeVersion()})\t[Rust native]`;

function errMessage(e) {
  return e && e.message ? String(e.message) : String(e);
}

/**
 * A Windows drive-letter path would false-positive a naive scheme test.
 *
 * Style-INDEPENDENT on purpose, unlike `isAbsolute` below: this one guards a
 * URL parse, and `new URL("C:\\x")` builds a `c:` URL on every platform.
 */
function hasScheme(s) {
  return /^[a-z][a-z0-9+.-]*:/i.test(s) && !/^[A-Za-z]:[\\/]/.test(s);
}

/** Coerce a path or URL to a URL for `loadedUrls` (scheme-aware). */
function toUrl(s) {
  return hasScheme(s) ? new URL(s) : pathToFileURL(s);
}

/**
 * Containing canonical → href for user importers. Only real containers count:
 * an absolute path (→ file: URL) or a URL with a scheme; anything else (the
 * engine's synthetic entry names) means "no containing url", like wasm.
 *
 * "Absolute" is `node:path`'s — the platform's rule, asked of the platform.
 * Every value reaching here was produced by the addon, whose Rust asked
 * `Path::is_absolute` to build it, so the two agree by construction; a
 * hand-written list of spellings would be a third copy of the rule, and the
 * one it kept leaving out was `\\server\share`, which has neither a leading
 * `/` nor a colon. A UNC-reached file crossed as "no containing url" and
 * every relative `@use` beside it fell through to the load paths.
 */
function containingHref(s) {
  if (s == null || s === "") return null;
  if (hasScheme(s)) return s;
  if (isAbsolute(s)) return pathToFileURL(s).href;
  return null;
}

/** Rebuild the wasm loader's Exception from the native structured-JSON error. */
function toException(e, origHref, urlForCore) {
  try {
    const parsed = JSON.parse(errMessage(e));
    if (parsed && parsed.sassoError) {
      const se = parsed.sassoError;
      const url = se.url && se.url === urlForCore && origHref ? origHref : se.url || undefined;
      const pos = { line: Math.max(0, se.line - 1), column: Math.max(0, se.col - 1), offset: 0 };
      const span = se.line > 0 ? { url, start: pos, end: pos, text: "", context: "" } : undefined;
      return new Exception(se.rendered, se.sassMessage, span);
    }
  } catch {
    // not a structured sasso error — fall through
  }
  return e instanceof Error ? e : new Error(String(e));
}

/** Dispatch one decoded warn event to the user logger (dart shape) or stderr. */
function dispatchWarn(logger, ev) {
  const spanOf = () => {
    if (!ev.url && !ev.line) return undefined;
    const start = { line: ev.line > 0 ? ev.line - 1 : 0, column: 0 };
    return { url: ev.url || undefined, start, end: start, text: "", context: "" };
  };
  try {
    if (ev.kind === 1) {
      if (logger && typeof logger.debug === "function") return logger.debug(ev.message, { span: spanOf() });
    } else if (logger && typeof logger.warn === "function") {
      return logger.warn(ev.message, {
        deprecation: ev.deprecation,
        deprecationType: ev.deprecationId || undefined,
        span: spanOf(),
        stack: undefined,
      });
    }
    if (typeof process !== "undefined" && process.stderr) process.stderr.write(ev.formatted + "\n");
    else console.error(ev.formatted);
  } catch {
    // A logging failure must never fail the compile.
  }
}

/**
 * Build the per-compile bridge. In async mode the native side calls it via a
 * ThreadsafeFunction and it ANSWERS through `native.bridgeReply(id, …)`
 * (possibly after awaiting a thenable). In sync mode the native side calls it
 * directly and it RETURNS `[rc, syntax, s1, s2, buf]` — user callbacks must
 * settle synchronously (`normalizeImporter(imp, false)` already throws on a
 * Promise, same contract as the wasm sync path).
 */
function makeBridge(options, asyncMode) {
  const resolvers = (options.importers || []).map((i) => normalizeImporter(i, asyncMode));
  const byCanonical = new Map();
  const callbacks = options.functions ? Object.values(options.functions) : [];
  const logger = options.logger ?? null;

  // Maybe-async walk over USER resolvers only (fs is native; the native chain
  // consults us first, mirroring the wasm chain's user-then-fs precedence).
  const walk = (i, url, fromImport, containing) => {
    for (; i < resolvers.length; i++) {
      const r = resolvers[i];
      const canon = r.canonicalize(url, fromImport, containing);
      if (isThenable(canon)) {
        return canon.then((c) => {
          if (c != null) {
            byCanonical.set(c, r);
            return c;
          }
          return walk(i + 1, url, fromImport, containing);
        });
      }
      if (canon != null) {
        byCanonical.set(canon, r);
        return canon;
      }
    }
    return null;
  };

  // kind handlers produce a settled-or-thenable [rc, syntax, s1, s2, buf].
  const handlers = {
    0: (a, b, c) => {
      const v = walk(0, a, c !== 0, containingHref(b));
      return mapMaybe(v, (canon) => (canon == null ? [0, 0, null, null, null] : [1, 0, String(canon), null, null]));
    },
    1: (a) => {
      const r = byCanonical.get(a);
      const v = r ? r.load(a) : null;
      return mapMaybe(v, (res) => {
        if (res == null) return [0, 0, null, null, null];
        // Validate BEFORE crossing the bridge: a non-string reaching
        // bridgeReply's Option<String> is a native type error (crashes the
        // TSFN callback); the wasm engine surfaces this as a compile error.
        if (typeof res.contents !== "string") {
          throw new Error("sasso: an importer's load() must return string contents");
        }
        return [1, res.syntax, res.contents, res.sourceMapUrl == null ? null : String(res.sourceMapUrl), null];
      });
    },
    2: (a) => {
      dispatchWarn(logger, JSON.parse(a));
      return null; // no reply expected
    },
    3: (a, b, c, buf) => {
      const fn = callbacks[c];
      if (!fn) throw new Error(`sasso: custom function #${c} is not registered`);
      const r = fn(deserializeArgs(buf ? new Uint8Array(buf) : new Uint8Array(0)));
      if (isThenable(r)) {
        if (!asyncMode) throw new Error("sasso: asynchronous custom functions require compileStringAsync / compileAsync");
        return r.then((v) => {
          if (v == null) throw new Error("sasso: a custom function returned no value");
          return [1, 0, null, null, Buffer.from(serializeValue(v))];
        });
      }
      if (r == null) throw new Error("sasso: a custom function returned no value");
      return [1, 0, null, null, Buffer.from(serializeValue(r))];
    },
  };

  const mapMaybe = (v, f) => (isThenable(v) ? v.then(f) : f(v));
  const errReply = (e) => [-1, 0, errMessage(e), null, null];

  if (!asyncMode) {
    // Direct synchronous call; exceptions map to rc=-1 (never thrown across).
    return (id, kind, a, b, c, buf) => {
      try {
        const out = handlers[kind](a, b, c, buf);
        if (out === null) return [0, 0, null, null, null]; // warn: ignored
        if (isThenable(out)) return errReply(new Error("sasso: importer callbacks must be synchronous on the sync API"));
        return out;
      } catch (e) {
        return errReply(e);
      }
    };
  }
  // Every path MUST reply (a lost reply parks the compile thread), and the
  // reply itself must never throw — a marshal failure falls back to an
  // all-plain-strings error reply.
  const reply = (id, r) => {
    try {
      native.bridgeReply(id, ...sliceReply(r));
    } catch (e) {
      native.bridgeReply(id, -1, 0, `sasso: bridge reply failed to marshal: ${errMessage(e)}`, null, null);
    }
  };
  return (id, kind, a, b, c, buf) => {
    let out;
    try {
      out = handlers[kind](a, b, c, buf);
    } catch (e) {
      reply(id, errReply(e));
      return;
    }
    if (out === null) return; // warn
    if (isThenable(out)) {
      out.then(
        (r) => reply(id, r),
        (e) => reply(id, errReply(e)),
      );
      return;
    }
    reply(id, out);
  };
}

const sliceReply = (r) => [r[0], r[1], r[2] ?? null, r[3] ?? null, r[4] ?? null];

// ------------------------------------------------------------- option mapping

/**
 * `process.cwd()` throws `ENOENT` once the process's directory is gone, and
 * this runs before EVERY compile — so reading it unguarded turned a deleted
 * working directory into a total failure, `compileString` included. `null`
 * is a supported answer: the core then leaves a frame's path absolute.
 */
function currentDirectory() {
  try {
    return process.cwd();
  } catch {
    return undefined; // napi Option<String>: `null` is a type error
  }
}

function buildCfg(options, syntax, urlForCore) {
  return {
    syntax,
    compressed: options.style === "compressed",
    // napi Option<String> maps `undefined` to None; `null` is a type error.
    url: urlForCore ?? undefined,
    // The wasm engine has no `getcwd` (wasm32-unknown-unknown), so a frame
    // would keep an absolute path there and a relative one under the addon.
    // Both are told the same directory instead.
    cwd: currentDirectory(),
    wantMap: !!options.sourceMap,
    includeSources: !!options.sourceMapIncludeSources,
    charset: options.charset !== false,
    quietDeps: !!options.quietDeps,
    // An id dart does not know warns through the caller's own logger and
    // compiles anyway, as dart's JS API does — its CLI is the half that
    // rejects. See _deprecations.mjs for the measurement.
    //
    // Through `dispatchWarn` rather than calling the logger here, so it lands
    // on stderr the same way when there is no logger AND inherits the catch
    // that keeps a throwing logger from failing the compile.
    silenceDeprecations: normalizeSilenced(options.silenceDeprecations, (message) =>
      dispatchWarn(options.logger ?? null, {
        kind: 0,
        message,
        formatted: `WARNING: ${message}`,
        deprecation: false,
        deprecationId: "",
        url: "",
        line: 0,
      }),
    ),
    unicode: options.unicode !== false,
    loadPaths: (options.loadPaths || []).map(String),
    hasUserImporters: !!(options.importers && options.importers.length),
    functionSignatures: options.functions ? Object.keys(options.functions) : [],
    wantWarn: true,
  };
}

/**
 * Entry url → its href, passed to the core VERBATIM: diagnostics then render
 * the same file: URL text the wasm engine renders, and the native chain
 * decodes file: containers back to paths for fs resolution. An empty string
 * is absent (wasm's `options.url ? …` semantics).
 */
function entryUrls(url) {
  if (url == null || url === "") return { origHref: null, urlForCore: null };
  const u = url instanceof URL ? url : hasScheme(String(url)) ? new URL(url) : pathToFileURL(String(url));
  return { origHref: u.href, urlForCore: u.href };
}

function makeResult(nat, origHref) {
  const urls = [];
  const seen = new Set();
  const add = (u) => {
    const href = u instanceof URL ? u.href : u;
    if (href && !seen.has(href)) {
      seen.add(href);
      urls.push(u instanceof URL ? u : new URL(href));
    }
  };
  if (origHref) add(new URL(origHref));
  for (const s of nat.loadedUrls) add(toUrl(s));
  const result = { css: nat.css, loadedUrls: urls };
  if (nat.sourceMap != null) {
    const map = JSON.parse(nat.sourceMap);
    // The core relativizes map sources against the entry for BOTH engines, so
    // they normally match the wasm output as-is. An ABSOLUTE path source (an
    // unrelativizable file) is the one native-specific case — the wasm engine
    // would carry a file: URL there, so normalize just those.
    if (Array.isArray(map.sources)) {
      map.sources = map.sources.map((s) =>
        typeof s === "string" && isAbsolute(s) ? pathToFileURL(s).href : s,
      );
    }
    result.sourceMap = map;
  }
  return result;
}

// --------------------------------------------------------- dart-sass modern API

export function compileString(source, options = {}) {
  if (typeof source !== "string") {
    throw new TypeError("compileString(source): source must be a string");
  }
  const { origHref, urlForCore } = entryUrls(options.url);
  const cfg = buildCfg(options, syntaxCode(options.syntax), urlForCore);
  const bridge = makeBridge(options, false);
  let nat;
  try {
    nat = native.compileStringSync(source, cfg, bridge);
  } catch (e) {
    throw toException(e, origHref, urlForCore);
  }
  return makeResult(nat, origHref);
}

export function compileStringAsync(source, options = {}) {
  if (typeof source !== "string") {
    return Promise.reject(new TypeError("compileStringAsync(source): source must be a string"));
  }
  const { origHref, urlForCore } = entryUrls(options.url);
  const cfg = buildCfg(options, syntaxCode(options.syntax), urlForCore);
  const bridge = makeBridge(options, true);
  return native.compileStringAsync(source, cfg, bridge).then(
    (nat) => makeResult(nat, origHref),
    (e) => {
      throw toException(e, origHref, urlForCore);
    },
  );
}

function entryFor(path, options) {
  const fsPath = path instanceof URL || String(path).startsWith("file:") ? fileURLToPath(path) : String(path);
  // Refused rather than substituted — see `decodeUtf8`. The addon reads
  // DEPENDENCIES itself and already refuses them; the entry comes through
  // here, so without this the two halves of one compile disagreed.
  const source = decodeUtf8(readFileSync(fsPath));
  if (source === null) throw new Exception("Error: Invalid UTF-8.");
  // As in the wasm loader: absolute and normalized, symlinks intact, so a map
  // names the path the file was reached through (see `canonicalHrefFor`).
  const realPath = resolvePath(fsPath);
  const syntax = options.syntax != null ? syntaxCode(options.syntax) : syntaxForPath(realPath);
  return { source, realPath, entryHref: pathToFileURL(realPath).href, syntax };
}

export function compile(path, options = {}) {
  const { source, entryHref, syntax } = entryFor(path, options);
  const cfg = buildCfg(options, syntax, entryHref);
  const bridge = makeBridge(options, false);
  let nat;
  try {
    nat = native.compileStringSync(source, cfg, bridge);
  } catch (e) {
    throw toException(e, entryHref, entryHref);
  }
  return makeResult(nat, entryHref);
}

export function compileAsync(path, options = {}) {
  let entry;
  try {
    entry = entryFor(path, options);
  } catch (e) {
    return Promise.reject(e);
  }
  const { source, entryHref, syntax } = entry;
  const cfg = buildCfg(options, syntax, entryHref);
  const bridge = makeBridge(options, true);
  return native.compileStringAsync(source, cfg, bridge).then(
    (nat) => makeResult(nat, entryHref),
    (e) => {
      throw toException(e, entryHref, entryHref);
    },
  );
}

/** Accepted for API parity; the native engine has no arena/pool knobs (each
 * async compile is its own OS thread; memory is the process allocator). */
export function configure() {}

export function initCompiler() {
  return { compile, compileString, dispose() {} };
}
export async function initAsyncCompiler() {
  return { compileAsync, compileStringAsync, async dispose() {} };
}

export {
  Value,
  SassBoolean,
  SassColor,
  SassList,
  SassArgumentList,
  SassMap,
  SassNumber,
  SassString,
  SassCalculation,
  CalculationOperation,
  SassFunction,
  SassMixin,
  sassTrue,
  sassFalse,
  sassNull,
} from "./_value.mjs";

export default {
  compile,
  compileAsync,
  compileString,
  compileStringAsync,
  initCompiler,
  initAsyncCompiler,
  configure,
  info,
  Exception,
  Logger,
  ...valueApi,
};
