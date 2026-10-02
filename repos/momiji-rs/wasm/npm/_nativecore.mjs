// The native engine's core: loading and checking the addon, the option
// mapping, and the result and error shapes. `native.mjs` builds the public
// API on top of it (importers, custom functions, the Value classes), and the
// CLI imports it ALONE: a command line has no importers and no functions, so
// it has no use for `_importer.mjs`, `_value.mjs` or the wasm loader, and
// loading them was most of the 11.7 ms the CLI spent choosing its engine
// before a one-entry compile (measured 2026-10-02, Linux/x86_64; #272).

import { createRequire } from "node:module";
import { resolve as resolvePath, isAbsolute } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";
import { decodeUtf8 } from "./_utf8.mjs";
import { syntaxCode, syntaxForPath } from "./_syntax.mjs";
import { Exception } from "./_exception.mjs";
import { normalizeSilenced } from "./_deprecations.mjs";
import { assertAddonVersion, platformKey, SUPPORTED } from "./_addon.mjs";

const require_ = createRequire(import.meta.url);
// `require`, not `import`: see `require_` in _addon.mjs.
const { readFileSync } = require_("node:fs");

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

export function errMessage(e) {
  return e && e.message ? String(e.message) : String(e);
}

/**
 * A Windows drive-letter path would false-positive a naive scheme test.
 *
 * Style-INDEPENDENT on purpose, unlike `isAbsolute` below: this one guards a
 * URL parse, and `new URL("C:\\x")` builds a `c:` URL on every platform.
 */
export function hasScheme(s) {
  return /^[a-z][a-z0-9+.-]*:/i.test(s) && !/^[A-Za-z]:[\\/]/.test(s);
}

/** Coerce a path or URL to a URL for `loadedUrls` (scheme-aware). */
function toUrl(s) {
  return hasScheme(s) ? new URL(s) : pathToFileURL(s);
}

/** Rebuild the wasm loader's Exception from the native structured-JSON error. */
export function toException(e, origHref, urlForCore) {
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
export function dispatchWarn(logger, ev) {
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

export function buildCfg(options, syntax, urlForCore) {
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
export function entryUrls(url) {
  if (url == null || url === "") return { origHref: null, urlForCore: null };
  const u = url instanceof URL ? url : hasScheme(String(url)) ? new URL(url) : pathToFileURL(String(url));
  return { origHref: u.href, urlForCore: u.href };
}

export function makeResult(nat, origHref) {
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
    if (Array.isArray(map.sources)) map.sources = mapSources(map.sources);
    result.sourceMap = map;
  }
  return result;
}

/**
 * The core relativizes map sources against the entry for BOTH engines, so
 * they normally match the wasm output as-is. An ABSOLUTE path source (an
 * unrelativizable file) is the one native-specific case — the wasm engine
 * would carry a file: URL there, so normalize just those.
 */
function mapSources(sources) {
  return sources.map((s) => (typeof s === "string" && isAbsolute(s) ? pathToFileURL(s).href : s));
}

export function entryFor(path, options) {
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

/**
 * The CLI's multi-job build, for `cli.mjs` alone — not part of the API, and
 * absent (`undefined`) from an addon that predates it.
 *
 * Every entry `{ path, sourceMap }` is compiled with the same `options` on
 * `threads` of the addon's own threads; see `compile_batch` in
 * `../../napi/src/lib.rs` for why. `options` carries what the CLI builds
 * (`commonOptions`): no importers, no functions, and a logger only to be
 * silent. The compiles start at once. Each `next()` waits for one to finish
 * and returns `{ i, settle }` — `i` the entry, `settle()` sending its
 * warnings where `compile` would have sent them and then returning its
 * result or throwing its error, so a caller that captures stderr around it
 * gets the job's own block — and `undefined` once every job that will run
 * has been returned. With `stopOnError`, a failure keeps the jobs after it
 * from starting, and those are never returned. `finish()` stops whatever has
 * not started, once the caller has taken what it wants.
 */
function compileBatch(entries, options, threads, stopOnError) {
  // One config for the batch; the entry, its syntax and the map differ per job.
  const base = buildCfg(options, 0, undefined);
  const logger = options.logger ?? null;
  // The addon's job i is entry i. One that cannot be read goes in without a
  // source and keeps its read error here: it fails where the addon claims it,
  // so with --stop-on-error a compile failure before it still skips it, and
  // it still stops what comes after.
  const sent = [];
  const jobs = [];
  for (let i = 0; i < entries.length; i++) {
    let entry;
    try {
      entry = entryFor(entries[i].path, options);
    } catch (error) {
      sent.push({ error });
      // Present and `undefined`: the addon's object decoding rejects a missing
      // field, and a `null` one as "not a string".
      jobs.push({ source: undefined, cfg: base });
      continue;
    }
    sent.push({ href: entry.entryHref });
    jobs.push({
      source: entry.source,
      cfg: { ...base, syntax: entry.syntax, url: entry.entryHref, wantMap: !!entries[i].sourceMap },
    });
  }
  const run = jobs.length ? native.compileBatch(jobs, threads, !!stopOnError) : null;
  return {
    next() {
      const out = run?.next();
      if (!out) return undefined;
      const i = out.index;
      const { href, error } = sent[i];
      return {
        i,
        settle() {
          if (error) throw error;
          for (const w of out.warnings) dispatchWarn(logger, JSON.parse(w));
          if (out.error != null) throw toException(out.error, href, href);
          const result = makeResult(out.result, href);
          // The map as `makeResult` would build it, except `sourcesContent`:
          // that stays the JSON text it arrived as, for `mapJson` to splice.
          if (out.map) {
            const { sources, mappings } = out.map;
            result.sourceMap = { version: 3, sources: mapSources(sources), names: [], mappings };
            if (out.map.sourcesContent != null) result.sourceMap.sourcesContentJson = out.map.sourcesContent;
          }
          return result;
        },
      };
    },
    // Stop claiming; what is already running still comes back from `next`.
    stop() {
      run?.stop();
    },
    finish() {
      run?.finish();
    },
  };
}
export const _cliBatch = typeof native.compileBatch === "function" ? compileBatch : undefined;

export { native, addonVersion };
export { Exception, Logger } from "./_exception.mjs";

// The bridge of a compile with no importers and no functions, the CLI's: the
// addon only ever calls it to deliver a warning.
const plainBridge = (logger) => (id, kind, a) => {
  if (kind === 2) dispatchWarn(logger, JSON.parse(a));
  return [0, 0, null, null, null];
};

/**
 * `compile` and `compileString` for the CLI, which passes neither importers
 * nor functions. The config, the result and the errors are native.mjs's own;
 * only the bridge differs, and only in calls it is never asked to answer.
 */
export function compile(path, options = {}) {
  const { source, entryHref, syntax } = entryFor(path, options);
  const cfg = buildCfg(options, syntax, entryHref);
  let nat;
  try {
    nat = native.compileStringSync(source, cfg, plainBridge(options.logger ?? null));
  } catch (e) {
    throw toException(e, entryHref, entryHref);
  }
  return makeResult(nat, entryHref);
}

export function compileString(source, options = {}) {
  const { origHref, urlForCore } = entryUrls(options.url);
  const cfg = buildCfg(options, syntaxCode(options.syntax), urlForCore);
  let nat;
  try {
    nat = native.compileStringSync(source, cfg, plainBridge(options.logger ?? null));
  } catch (e) {
    throw toException(e, origHref, urlForCore);
  }
  return makeResult(nat, origHref);
}
