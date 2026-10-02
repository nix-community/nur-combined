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
// byte protocol over the native valueOp), and `_exception.mjs`'s Exception with
// the wasm entries — one source of truth for API semantics. Loading the addon,
// the option mapping and the result shapes are `_nativecore.mjs`'s, which the
// CLI imports without this file.

import { isAbsolute } from "node:path";
import { pathToFileURL } from "node:url";
import { isThenable, normalizeImporter } from "./_importer.mjs";
import { syntaxCode } from "./_syntax.mjs";
import { Exception, Logger } from "./_exception.mjs";
import { deserializeArgs, serializeValue, setEngine, valueApi } from "./_value.mjs";
import {
  native,
  addonVersion,
  errMessage,
  hasScheme,
  toException,
  dispatchWarn,
  buildCfg,
  entryUrls,
  makeResult,
  entryFor,
  _cliBatch,
} from "./_nativecore.mjs";

export { _cliBatch };

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
