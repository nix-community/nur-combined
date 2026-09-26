// sasso C ABI (FFI v2) binding + test for Bun via `bun:ffi`.
//
// Loads the prebuilt libsasso.dylib directly with dlopen, declares the C ABI
// from ffi/include/sasso.h, and asserts the 5 checks from the shared spec —
// including a v2 custom importer driven by JSCallback trampolines.
//
// Run:  bun run test.ts   (from this directory)
//
// Ownership model: a callback never hands sasso an owned pointer; it calls one
// of the sasso_importer_set_* fns with its sink (sasso copies the bytes
// immediately), and JS keeps ownership of its own buffers. The JSCallbacks must
// stay referenced (rooted in `keepAlive`) for the duration of the compile, or
// the GC could collect the trampolines mid-call.

import {
  dlopen,
  FFIType,
  JSCallback,
  ptr,
  read,
  CString,
  type Pointer,
} from "bun:ffi";
import { resolve as pathResolve } from "node:path";

const libName = process.platform === "win32"
  ? "sasso.dll"
  : process.platform === "darwin"
    ? "libsasso.dylib"
    : "libsasso.so";
const DYLIB =
  process.env.SASSO_DYLIB ??
  pathResolve(import.meta.dir, `../../target/release/${libName}`);

// ── ABI constants ─────────────────────────────────────────────────────────
const SASSO_STYLE_EXPANDED = 0;
const SASSO_STYLE_COMPRESSED = 1;
const SASSO_SYNTAX_SCSS = 0;

const SASSO_IMPORTER_OK = 1;
const SASSO_IMPORTER_NOT_FOUND = 0;
const SASSO_IMPORTER_ERROR = -1;

// ── Symbol table ────────────────────────────────────────────────────────────
const { symbols: lib } = dlopen(DYLIB, {
  sasso_version: { args: [], returns: FFIType.cstring },
  sasso_options_init: {
    args: [FFIType.ptr, FFIType.u64], // (SassoOptions*, size_t struct_size)
    returns: FFIType.void,
  },
  sasso_compile: {
    args: [FFIType.ptr, FFIType.u64, FFIType.ptr], // (src, len, opts)
    returns: FFIType.ptr, // SassoResult*
  },
  sasso_result_free: { args: [FFIType.ptr], returns: FFIType.void },
  sasso_importer_set_canonical: {
    args: [FFIType.ptr, FFIType.ptr, FFIType.u64], // (sink, ptr, len)
    returns: FFIType.void,
  },
  sasso_importer_set_result: {
    args: [
      FFIType.ptr, // sink
      FFIType.ptr, // contents
      FFIType.u64, // contents_len
      FFIType.i32, // syntax
      FFIType.ptr, // source_map_url (may be NULL)
      FFIType.u64, // source_map_url_len
    ],
    returns: FFIType.void,
  },
  sasso_importer_set_error: {
    args: [FFIType.ptr, FFIType.ptr, FFIType.u64], // (sink, ptr, len)
    returns: FFIType.void,
  },
});

// ── Struct layouts (arm64 / x86-64, natural alignment) ──────────────────────
// SassoOptions {
//   0  u32 struct_size; 4 i32 style; 8 i32 syntax; 12 i32 unicode;
//   16 ptr url; 24 ptr load_paths; 32 size_t load_paths_len; 40 ptr importer;
// } size 48
const OPT_SIZE = 48;
const OPT_STRUCT_SIZE = 0;
const OPT_STYLE = 4;
const OPT_SYNTAX = 8;
const OPT_UNICODE = 12;
const OPT_URL = 16;
const OPT_LOAD_PATHS = 24;
const OPT_LOAD_PATHS_LEN = 32;
const OPT_IMPORTER = 40;

// SassoResult {
//   0 i32 ok; (pad) 8 ptr css; 16 size_t css_len; 24 ptr error;
//   32 size_t error_len; 40 u32 error_line; 44 u32 error_column;
// } size 48
const RES_OK = 0;
const RES_CSS = 8;
const RES_CSS_LEN = 16;
const RES_ERROR = 24;
const RES_ERROR_LEN = 32;
const RES_ERROR_LINE = 40;
const RES_ERROR_COLUMN = 44;

// SassoImporter { 0 ptr user_data; 8 ptr canonicalize; 16 ptr load; } size 24
const IMP_SIZE = 24;
const IMP_USER_DATA = 0;
const IMP_CANONICALIZE = 8;
const IMP_LOAD = 16;

// SassoCanonicalizeContext { 0 i32 from_import; (pad) 8 ptr containing_url; } size 16
const CTX_FROM_IMPORT = 0;
const CTX_CONTAINING_URL = 8;

// ── Helpers ──────────────────────────────────────────────────────────────────
const enc = new TextEncoder();

/** Encode a JS string into a NUL-terminated UTF-8 buffer (for host paths). */
function cstr(s: string): Uint8Array {
  const body = enc.encode(s);
  const buf = new Uint8Array(body.length + 1);
  buf.set(body, 0);
  buf[body.length] = 0; // NUL terminator
  return buf;
}

/** Read a NUL-terminated C string from a raw pointer (NULL -> null). */
function readCString(p: number | bigint): string | null {
  const n = typeof p === "bigint" ? p : BigInt(p);
  if (n === 0n) return null;
  return new CString(Number(n) as unknown as Pointer).toString();
}

/** Read a length-bounded UTF-8 string at a raw pointer (binary-safe). */
function readSized(p: number | bigint, len: number | bigint): string {
  const n = typeof p === "bigint" ? p : BigInt(p);
  const l = typeof len === "bigint" ? Number(len) : len;
  if (n === 0n || l === 0) return "";
  return new CString(Number(n) as unknown as Pointer, 0, l).toString();
}

type CompileOutcome =
  | { ok: true; css: string }
  | { ok: false; error: string; line: number; column: number };

interface CompileOpts {
  style?: number;
  url?: string;
  importerBuf?: Uint8Array; // a SassoImporter struct buffer
}

function compile(src: string, opts: CompileOpts = {}): CompileOutcome {
  // Build the SassoOptions struct (or pass NULL for all-defaults).
  let optsPtr: Pointer | null = null;
  // Keepalives so the GC doesn't reclaim backing buffers mid-call.
  const keep: unknown[] = [];

  if (opts.style !== undefined || opts.url !== undefined || opts.importerBuf) {
    const ob = new Uint8Array(OPT_SIZE);
    const dv = new DataView(ob.buffer);
    lib.sasso_options_init(ptr(ob), BigInt(OPT_SIZE)); // fills defaults + struct_size
    if (opts.style !== undefined) dv.setInt32(OPT_STYLE, opts.style, true);
    if (opts.url !== undefined) {
      const u = cstr(opts.url);
      keep.push(u);
      dv.setBigUint64(OPT_URL, BigInt(ptr(u)), true);
    }
    if (opts.importerBuf) {
      keep.push(opts.importerBuf);
      dv.setBigUint64(OPT_IMPORTER, BigInt(ptr(opts.importerBuf)), true);
    }
    keep.push(ob);
    optsPtr = ptr(ob);
  }

  const srcBuf = enc.encode(src); // need NOT be NUL-terminated
  keep.push(srcBuf);
  const resPtr = lib.sasso_compile(
    ptr(srcBuf),
    BigInt(srcBuf.length),
    optsPtr,
  );
  if (!resPtr) throw new Error("sasso_compile returned NULL");

  try {
    const ok = read.i32(resPtr as Pointer, RES_OK);
    if (ok === 1) {
      const cssPtr = read.ptr(resPtr as Pointer, RES_CSS);
      const cssLen = read.u64(resPtr as Pointer, RES_CSS_LEN);
      return { ok: true, css: readSized(cssPtr, cssLen) };
    }
    const errPtr = read.ptr(resPtr as Pointer, RES_ERROR);
    const errLen = read.u64(resPtr as Pointer, RES_ERROR_LEN);
    const line = read.u32(resPtr as Pointer, RES_ERROR_LINE);
    const column = read.u32(resPtr as Pointer, RES_ERROR_COLUMN);
    return { ok: false, error: readSized(errPtr, errLen), line, column };
  } finally {
    lib.sasso_result_free(resPtr);
    // `keep` stays reachable until here so backing buffers survive the call.
    void keep.length;
  }
}

// ── v2 custom importer over an in-memory file map ────────────────────────────
function dirOf(p: string): string {
  const i = p.lastIndexOf("/");
  return i <= 0 ? "/" : p.slice(0, i);
}
function asPartial(p: string): string {
  const i = p.lastIndexOf("/");
  return p.slice(0, i + 1) + "_" + p.slice(i + 1);
}

/**
 * Build a SassoImporter struct buffer over an in-memory {canonical: source}
 * map. Returns { buf, keepAlive } — keepAlive (the JSCallbacks) MUST stay
 * referenced for as long as the importer is used.
 */
function makeImporter(files: Record<string, string>) {
  const resolveUrl = (url: string, containing: string | null): string | null => {
    const base = containing ? dirOf(containing) : "";
    const joined = (base === "/" ? "" : base.replace(/\/$/, "")) + "/" + url;
    for (const cand of [joined, asPartial(joined)]) {
      if (cand in files) return cand;
    }
    return null;
  };

  const canonicalize = new JSCallback(
    (_ud: Pointer, urlPtr: Pointer, ctxPtr: Pointer, sink: Pointer): number => {
      const url = readCString(urlPtr) ?? "";
      // Read the containing_url out of the ctx struct.
      const containingPtr = read.ptr(ctxPtr, CTX_CONTAINING_URL);
      const containing = readCString(containingPtr);
      const canon = resolveUrl(url, containing);
      if (canon === null) return SASSO_IMPORTER_NOT_FOUND;
      const b = enc.encode(canon);
      lib.sasso_importer_set_canonical(sink, ptr(b), BigInt(b.length));
      return SASSO_IMPORTER_OK;
    },
    {
      args: [FFIType.ptr, FFIType.ptr, FFIType.ptr, FFIType.ptr],
      returns: FFIType.i32,
    },
  );

  const load = new JSCallback(
    (_ud: Pointer, canonPtr: Pointer, sink: Pointer): number => {
      const canon = readCString(canonPtr) ?? "";
      const src = files[canon];
      if (src === undefined) return SASSO_IMPORTER_NOT_FOUND;
      const b = enc.encode(src);
      lib.sasso_importer_set_result(
        sink,
        ptr(b),
        BigInt(b.length),
        SASSO_SYNTAX_SCSS,
        null, // source_map_url
        0n,
      );
      return SASSO_IMPORTER_OK;
    },
    {
      args: [FFIType.ptr, FFIType.ptr, FFIType.ptr],
      returns: FFIType.i32,
    },
  );

  const buf = new Uint8Array(IMP_SIZE);
  const dv = new DataView(buf.buffer);
  dv.setBigUint64(IMP_USER_DATA, 0n, true); // NULL user_data
  dv.setBigUint64(IMP_CANONICALIZE, BigInt(canonicalize.ptr ?? 0), true);
  dv.setBigUint64(IMP_LOAD, BigInt(load.ptr ?? 0), true);

  return { buf, keepAlive: [canonicalize, load] as JSCallback[] };
}

// ── Test harness ──────────────────────────────────────────────────────────
let failed = false;
function check(name: string, cond: boolean, detail = "") {
  const tag = cond ? "PASS" : "FAIL";
  if (!cond) failed = true;
  const extra = !cond && detail ? `  — ${detail}` : "";
  console.log(`  ${tag}  ${name}${extra}`);
}

console.log("sasso C ABI binding test (Bun / bun:ffi)\n");

// 1. version
const version = lib.sasso_version().toString();
check(`1. sasso_version() looks like a version`, /^\d+\.\d+\.\d+/.test(version), `got ${JSON.stringify(version)}`);

// 2. default compile (NULL opts) with nesting
{
  const r = compile(".a { color: red; &:hover { color: blue; } }");
  const expected = ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}";
  check(
    "2. default compile (nesting) matches",
    r.ok && r.css === expected,
    JSON.stringify(r),
  );
}

// 3. compressed compile
{
  const r = compile(".a { color: #336699; }", { style: SASSO_STYLE_COMPRESSED });
  check(
    "3. compressed compile matches",
    r.ok && r.css === ".a{color:#369}",
    JSON.stringify(r),
  );
}

// 4. error path
{
  const r = compile(".a { color: ");
  const ok = !r.ok && r.error.length > 0 && r.line >= 1;
  check("4. error path (ok==0, error, line>=1)", ok, JSON.stringify(r));
  if (!r.ok) {
    const firstLine = r.error.split("\n", 1)[0];
    console.log(`       first error line: ${firstLine}`);
  }
}

// 5. v2 custom importer
{
  const files: Record<string, string> = { "/sub/_mod": "$c: #336699;\n" };
  const { buf, keepAlive } = makeImporter(files);
  const r = compile('@use "sub/mod" as m;\n.out { color: m.$c; }\n', {
    url: "/entry",
    importerBuf: buf,
  });
  check(
    "5. v2 custom importer resolves @use",
    r.ok && r.css === ".out {\n  color: #336699;\n}",
    JSON.stringify(r),
  );
  // keepAlive referenced past the compile call.
  if (keepAlive.length !== 2) failed = true;
  for (const cb of keepAlive) cb.close();
}

console.log(`\nRESULT: ${failed ? "FAIL" : "PASS"}`);
process.exit(failed ? 1 : 0);
