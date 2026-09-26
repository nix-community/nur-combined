// Importer machinery for the `sasso` npm package.
//
// wasm has no filesystem, so every `@use`/`@forward`/`@import` is resolved here
// in JS and bridged into the engine through the wasm host functions (see
// `_loader.mjs`). This module provides the two resolver kinds sasso merges into
// one chain per compile:
//
//   • a Node-fs importer (`makeFsImporter`) for `loadPaths` and relative-to-
//     containing-file resolution — a faithful JS port of the dart-sass
//     partial / index / import-only precedence in `../../src/importer.rs`; it
//     also records which loads came through a load path (`quietDeps`); and
//   • a bridge (`normalizeImporter`) for user-supplied dart-sass *modern*
//     importers — both `{ canonicalize, load }` Importers and `{ findFileUrl }`
//     FileImporters.
//
// The internal resolver interface is string-based and MAYBE-ASYNC:
//   canonicalize(url, fromImport, containingHref|null) -> canonicalHref|null (or a Promise of it)
//   load(canonicalHref) -> { contents, syntax: 0|1|2, sourceMapUrl: string|null } | null (or a Promise)
// `syntax`: 0 = SCSS, 1 = indented `.sass`, 2 = plain CSS.
//
// In sync mode (`compileString`/`compile`) a user importer that returns a
// Promise throws a clear error — the sync engine cannot await. In async mode
// results stay PLAIN VALUES whenever the user callback returned one and become
// Promises only when it actually returned a thenable: the asyncify engine
// delivers a plain value without suspending (`_loader.mjs` `asyncHostFn`), so
// keeping sync resolutions synchronous is a performance contract, not style.

import { existsSync, statSync, readFileSync } from "node:fs";
import { pathToFileURL, fileURLToPath } from "node:url";
import * as nodePath from "node:path";

const SYNTAX_SCSS = 0;
const SYNTAX_SASS = 1;
const SYNTAX_CSS = 2;

export function isThenable(x) {
  return x != null && typeof x.then === "function";
}

const ASYNC_UNSUPPORTED =
  "sasso: asynchronous importers are not supported — the wasm engine is " +
  "synchronous, so importer callbacks must return synchronously (even under " +
  "compileStringAsync).";

/** Map a dart-sass syntax string to the wasm syntax code. */
export function syntaxCode(syntax) {
  if (syntax === "indented" || syntax === "sass") return SYNTAX_SASS;
  if (syntax === "css") return SYNTAX_CSS;
  return SYNTAX_SCSS;
}

/** The syntax code for a resolved file path, from its extension. */
export function syntaxForPath(p) {
  const ext = nodePath.extname(p).toLowerCase();
  if (ext === ".sass") return SYNTAX_SASS;
  if (ext === ".css") return SYNTAX_CSS;
  return SYNTAX_SCSS;
}

function isFile(p) {
  try {
    return statSync(p).isFile();
  } catch {
    return false;
  }
}

// --- dart-sass filesystem resolution (port of src/importer.rs) -------------

/** Lexically remove `.` / `..` segments from a URL path (no fs access). */
function lexicalNormalize(path) {
  const out = [];
  for (const seg of path.split("/")) {
    if (seg === "" || seg === ".") continue;
    if (seg === "..") {
      if (out.length && out[out.length - 1] !== "..") out.pop();
      else out.push("..");
    } else {
      out.push(seg);
    }
  }
  let s = out.join("/");
  if (path.startsWith("/")) s = "/" + s;
  if (s === "") s = ".";
  return s;
}

// One precedence tier: collect existing candidates, returning a single match,
// `"ambiguous"` for >1 at the same tier, or `null` for none.
function tierExact(dir, stem, exts, importOnly) {
  const found = [];
  const suffix = importOnly ? ".import" : "";
  for (const ext of exts) {
    for (const name of [`_${stem}${suffix}.${ext}`, `${stem}${suffix}.${ext}`]) {
      const cand = nodePath.join(dir, name);
      if (isFile(cand)) found.push(cand);
    }
  }
  if (found.length === 0) return null;
  if (found.length > 1) return "ambiguous";
  return found[0];
}

function tierWithExtensions(dir, stem, importOnly) {
  return tierExact(dir, stem, ["scss", "sass"], importOnly);
}

// Resolve `path` against `base` following dart-sass precedence. Returns an
// absolute path, the sentinel `"ambiguous"`, or `null` (not found here).
function resolveInBase(base, path, allowImportOnly) {
  const normalized = lexicalNormalize(path);
  const parsed = nodePath.posix.parse(normalized.replace(/\\/g, "/"));
  // The directory portion of the (normalized) import path, joined onto `base`.
  const subDir = parsed.dir && parsed.dir !== "" ? parsed.dir : "";
  const dir = subDir ? nodePath.join(base, subDir) : base;
  const file = parsed.base || normalized;

  // Explicit `.css`: only the plain-CSS candidate.
  if (file.endsWith(".css")) {
    return tierExact(dir, file.slice(0, -4), ["css"], false);
  }

  // Explicit `.scss`/`.sass`: only that extension (+ import-only override).
  const explicitExt = [".scss", ".sass"].find((e) => file.endsWith(e));
  if (explicitExt) {
    const stem = file.slice(0, -explicitExt.length);
    const ext = explicitExt.slice(1);
    if (allowImportOnly) {
      const r = tierExact(dir, stem, [ext], true);
      if (r) return r;
    }
    return tierExact(dir, stem, [ext], false);
  }

  // Extensionless: scss/sass equal precedence, then css, then index dirs.
  const nonIndex = [];
  if (allowImportOnly) nonIndex.push([file, true]);
  nonIndex.push([file, false]);
  for (const [stem, importOnly] of nonIndex) {
    const r = tierWithExtensions(dir, stem, importOnly);
    if (r) return r;
  }

  const cssr = tierExact(dir, file, ["css"], false);
  if (cssr) return cssr;

  const indexDir = nodePath.join(dir, file);
  const indexModes = allowImportOnly ? [true, false] : [false];
  for (const importOnly of indexModes) {
    const r = tierWithExtensions(indexDir, "index", importOnly);
    if (r) return r;
  }

  return null;
}

/** Canonical key for a resolved path: its realpath as a `file:` URL href. */
/**
 * The canonical URL for a resolved path: absolute and lexically normalized, so
 * two spellings of one file (`a.scss`, `./a.scss`, `dir/../a.scss`) are one
 * module — but symlinks are NOT resolved, exactly as `absolute_normalized` in
 * ../../src/importer.rs leaves them. dart-sass keeps the path a file was
 * REACHED through: a source map then names the link (a pnpm
 * `node_modules/<pkg>` path, not its `.pnpm` target), and a file reached
 * through two links is two modules.
 */
function canonicalHrefFor(path) {
  return pathToFileURL(nodePath.resolve(path)).href;
}

/**
 * Decode bytes that are supposed to be UTF-8, or `null` when they are not.
 *
 * `readFileSync(path, "utf8")` does NOT reject invalid UTF-8 — it substitutes
 * U+FFFD and returns a string — so every read that went through it accepted a
 * file dart-sass refuses, and compiled it into replacement characters without
 * a word. Measured (#179): `$c: \xff\xfered;` gave `.a { color: ��red; }`
 * on the npm CLI while dart, the binary and the native addon's own reads all
 * errored.
 *
 * Exported because the entry, every dependency and standard input needed
 * the same rule — a copy at each read is how they drift. What each caller
 * SAYS about a failure differs, so only the decoding lives here.
 */
export function decodeUtf8(bytes) {
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    return null;
  }
}

/** Read a resolved file as an importer result (`null` if it vanished). */
function loadFsPath(path) {
  let bytes;
  try {
    bytes = readFileSync(path);
  } catch (e) {
    if (e && e.code === "ENOENT") return null; // raced between resolve and load
    throw new Error(`Cannot read ${path}: ${e && e.message ? e.message : e}`);
  }
  const contents = decodeUtf8(bytes);
  // The wording the binary's importer uses for the same refusal, so the two
  // engines answer a build script the same way.
  if (contents === null) throw new Error(`Cannot read ${path}: stream did not contain valid UTF-8`);
  return { contents, syntax: syntaxForPath(path), sourceMapUrl: null };
}

/**
 * A Node-fs importer searching, in order, the containing file's directory then
 * `loadPaths`, with dart-faithful partial/index/import-only precedence.
 */
export function makeFsImporter(loadPaths, deps) {
  const bases = (loadPaths || []).map((p) => String(p));
  return {
    canonicalize(url, fromImport, containingHref) {
      // Base directories: the containing file's dir (when it is a file: URL),
      // then the configured load paths. Unlike the CLI's FsImporter we do NOT
      // fall back to the CWD when there is no containing file — dart-sass's
      // `compileString` only resolves relative URLs when given a `url` (or via
      // `loadPaths`), so an import with neither simply misses.
      const baseDirs = [];
      let firstLoadPath = 0; // index in baseDirs where the load paths begin
      if (containingHref) {
        try {
          baseDirs.push(nodePath.dirname(fileURLToPath(containingHref)));
          firstLoadPath = 1;
        } catch {
          // containing URL isn't a file: URL — skip relative resolution
        }
      }
      for (const b of bases) baseDirs.push(b);

      for (let i = 0; i < baseDirs.length; i++) {
        const r = resolveInBase(baseDirs[i], url, fromImport);
        if (r === "ambiguous") return null; // dart errors; we treat as a miss
        if (r) {
          const href = canonicalHrefFor(r);
          // dart's `quietDeps` rule is about how a file was REACHED, not where
          // it lives: a file found through a load path is a dependency, and so
          // is anything a dependency loads relatively — but a file the entry
          // loads relatively is not, even when it sits under a load path.
          // (Measured against dart-sass 1.104.1 on 2026-09-17; the same rule
          // the native CLI's FsImporter applies in ../../src/importer.rs.)
          if (deps && (i >= firstLoadPath || (containingHref && deps.has(containingHref)))) {
            deps.add(href);
          }
          return href;
        }
      }
      return null;
    },
    load(canonicalHref) {
      let path;
      try {
        path = fileURLToPath(canonicalHref);
      } catch {
        return null;
      }
      return loadFsPath(path);
    },
  };
}

// --- user (dart-sass modern) importer bridging -----------------------------

function ctxFor(fromImport, containingHref) {
  return {
    fromImport,
    containingUrl: containingHref ? new URL(containingHref) : undefined,
  };
}

function toHref(urlOrString) {
  return urlOrString instanceof URL ? urlOrString.href : new URL(urlOrString).href;
}

// Settle a possibly-thenable user return into the chain interface. A plain
// value maps through synchronously in BOTH modes — in async mode that lets the
// asyncify engine deliver it without a suspension (the maybe-async contract);
// only an actual thenable becomes a Promise. In sync mode a thenable is a hard
// error (the sync engine can't await it).
function settle(raw, map, async) {
  if (isThenable(raw)) {
    if (!async) throw new Error(ASYNC_UNSUPPORTED);
    return Promise.resolve(raw).then((v) => (v == null ? null : map(v)));
  }
  return raw == null ? null : map(raw);
}

const loadMap = (r) => ({
  contents: r.contents,
  syntax: syntaxCode(r.syntax),
  sourceMapUrl: r.sourceMapUrl != null ? String(r.sourceMapUrl) : null,
});

/** Wrap a user `{ canonicalize, load }` dart-sass Importer (`async` = await Promises). */
function wrapImporter(imp, async) {
  return {
    canonicalize(url, fromImport, containingHref) {
      return settle(imp.canonicalize(url, ctxFor(fromImport, containingHref)), toHref, async);
    },
    load(canonicalHref) {
      return settle(imp.load(new URL(canonicalHref)), loadMap, async);
    },
  };
}

/**
 * Wrap a user `{ findFileUrl }` dart-sass FileImporter: `findFileUrl` returns a
 * `file:` URL, which we then resolve on disk with the standard partial/index
 * precedence and read. (`async` = await an async `findFileUrl`.)
 */
function wrapFileImporter(imp, async) {
  const finish = (r, fromImport) => {
    if (r == null) return null;
    const fileUrl = r instanceof URL ? r : new URL(r);
    if (fileUrl.protocol !== "file:") {
      throw new Error(
        `sasso: FileImporter.findFileUrl must return a file: URL, got ${fileUrl.protocol}`,
      );
    }
    const target = fileURLToPath(fileUrl);
    const resolved = resolveInBase(nodePath.dirname(target), nodePath.basename(target), fromImport);
    return !resolved || resolved === "ambiguous" ? null : canonicalHrefFor(resolved);
  };
  return {
    canonicalize(url, fromImport, containingHref) {
      const raw = imp.findFileUrl(url, ctxFor(fromImport, containingHref));
      if (isThenable(raw)) {
        if (!async) throw new Error(ASYNC_UNSUPPORTED);
        return Promise.resolve(raw).then((r) => finish(r, fromImport));
      }
      return finish(raw, fromImport);
    },
    load(canonicalHref) {
      // `loadFsPath` returns null on ENOENT and throws on a bad read,
      // including invalid UTF-8. A catch here turned that into a miss.
      return loadFsPath(fileURLToPath(canonicalHref));
    },
  };
}

/**
 * Normalize one user importer (Importer or FileImporter) to the chain interface.
 * Pass `async = true` for the asyncified engine (callbacks may return Promises);
 * the default (sync engine) rejects Promises with a clear error.
 */
export function normalizeImporter(imp, async = false) {
  if (imp && typeof imp.canonicalize === "function" && typeof imp.load === "function") {
    return wrapImporter(imp, async);
  }
  if (imp && typeof imp.findFileUrl === "function") {
    return wrapFileImporter(imp, async);
  }
  throw new Error(
    "sasso: each importer must be a dart-sass Importer ({ canonicalize, load }) " +
      "or FileImporter ({ findFileUrl }).",
  );
}
