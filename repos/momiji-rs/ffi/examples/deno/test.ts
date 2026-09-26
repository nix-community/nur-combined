// Deno binding + live test for sasso's C ABI (FFI v2), via the built-in
// `Deno.dlopen` FFI. Loads the prebuilt libsasso.dylib directly (no link step),
// declares the five-plus entry points, mirrors the C structs with ArrayBuffer +
// DataView (minding 8-byte pointer/size_t alignment), and asserts checks 1-5.
//
//   deno run --allow-ffi --allow-read --allow-env test.ts
//
// Ownership (Model 2): callbacks never hand sasso an owned pointer — they call
// one sasso_importer_set_* with the sink; sasso copies the bytes immediately, so
// Deno keeps ownership of its own (GC'd) buffers. UnsafeCallbacks are kept alive
// until after sasso_compile() returns.

// Resolve the prebuilt dylib relative to this file (ffi/examples/deno/ ->
// ffi/target/release/), with an optional SASSO_DYLIB env override.
const libName = Deno.build.os === "windows"
  ? "sasso.dll"
  : Deno.build.os === "darwin"
    ? "libsasso.dylib"
    : "libsasso.so";
const DYLIB =
  Deno.env.get("SASSO_DYLIB") ??
  new URL(`../../target/release/${libName}`, import.meta.url).pathname;

const SASSO_STYLE_EXPANDED = 0;
const SASSO_STYLE_COMPRESSED = 1;
const SASSO_SYNTAX_SCSS = 0;
const SASSO_IMPORTER_OK = 1;
const SASSO_IMPORTER_NOT_FOUND = 0;
const SASSO_IMPORTER_ERROR = -1;

const lib = Deno.dlopen(DYLIB, {
  sasso_version: { parameters: [], result: "pointer" },
  sasso_compile: {
    // (const char* src, size_t len, const SassoOptions* opts)
    parameters: ["buffer", "usize", "pointer"],
    result: "pointer",
  },
  sasso_result_free: { parameters: ["pointer"], result: "void" },
  sasso_options_init: {
    // (SassoOptions*, size_t struct_size)
    parameters: ["buffer", "usize"],
    result: "void",
  },
  sasso_importer_set_canonical: {
    parameters: ["pointer", "buffer", "usize"],
    result: "void",
  },
  sasso_importer_set_result: {
    parameters: ["pointer", "buffer", "usize", "i32", "pointer", "usize"],
    result: "void",
  },
  sasso_importer_set_error: {
    parameters: ["pointer", "buffer", "usize"],
    result: "void",
  },
} as const);

const enc = new TextEncoder();
const dec = new TextDecoder();

/** NUL-terminated UTF-8 buffer (host paths must be NUL-terminated). */
function cstr(s: string): Uint8Array {
  return enc.encode(s + "\0");
}

/** Read a NUL-terminated C string from a raw pointer. */
function readCString(ptr: Deno.PointerValue): string | null {
  if (ptr === null) return null;
  return new Deno.UnsafePointerView(ptr).getCString();
}

/** Read `len` bytes at `ptr` as UTF-8 (binary-safe; uses explicit length). */
function readBytes(ptr: Deno.PointerValue, len: number | bigint): string {
  const n = Number(len);
  if (ptr === null || n === 0) return "";
  const view = new Deno.UnsafePointerView(ptr);
  const buf = new Uint8Array(n);
  view.copyInto(buf);
  return dec.decode(buf);
}

// --- struct layouts (arm64 / LP64; pointers + size_t are 8-byte aligned) -----
//
// SassoOptions (48 bytes):
//   u32  struct_size @0
//   i32  style       @4
//   i32  syntax      @8
//   i32  unicode     @12
//   ptr  url         @16
//   ptr  load_paths  @24
//   usize load_paths_len @32
//   ptr  importer    @40
const OPT_SIZE = 48;
const OPT_STRUCT_SIZE = 0;
const OPT_STYLE = 4;
const OPT_SYNTAX = 8;
const OPT_UNICODE = 12;
const OPT_URL = 16;
const OPT_LOAD_PATHS = 24;
const OPT_LOAD_PATHS_LEN = 32;
const OPT_IMPORTER = 40;

// SassoResult (48 bytes):
//   i32  ok           @0  (+4 pad)
//   ptr  css          @8
//   usize css_len     @16
//   ptr  error        @24
//   usize error_len   @32
//   u32  error_line   @40
//   u32  error_column @44
const RES_OK = 0;
const RES_CSS = 8;
const RES_CSS_LEN = 16;
const RES_ERROR = 24;
const RES_ERROR_LEN = 32;
const RES_ERROR_LINE = 40;
const RES_ERROR_COLUMN = 44;

// SassoImporter (24 bytes):
//   ptr user_data    @0
//   ptr canonicalize @8
//   ptr load         @16
const IMP_SIZE = 24;
const IMP_USER_DATA = 0;
const IMP_CANONICALIZE = 8;
const IMP_LOAD = 16;

const LE = true; // little-endian (arm64)

interface CompileOut {
  ok: boolean;
  css: string | null;
  error: string | null;
  errorLine: number;
  errorColumn: number;
}

/**
 * Compile `src`. `opts` is an optional configurator that receives the
 * SassoOptions DataView (already initialized to defaults via sasso_options_init)
 * plus a `keep` array — push any buffers/callbacks that must outlive the call.
 */
function compile(
  src: string,
  configure?: (dv: DataView, optsBuf: Uint8Array, keep: unknown[]) => void,
): CompileOut {
  const keep: unknown[] = [];
  let optsBuf: Uint8Array | null = null;
  let optsArg: Deno.PointerValue = null;

  if (configure) {
    optsBuf = new Uint8Array(OPT_SIZE);
    lib.symbols.sasso_options_init(optsBuf, BigInt(OPT_SIZE));
    const dv = new DataView(optsBuf.buffer);
    configure(dv, optsBuf, keep);
    keep.push(optsBuf);
    optsArg = Deno.UnsafePointer.of(optsBuf);
  }

  const srcBytes = enc.encode(src);
  const resPtr = lib.symbols.sasso_compile(
    srcBytes,
    BigInt(srcBytes.length),
    optsArg, // null => all-defaults
  );
  if (resPtr === null) throw new Error("sasso_compile returned NULL");

  try {
    const rv = new Deno.UnsafePointerView(resPtr);
    const ok = rv.getInt32(RES_OK) === 1;
    const cssLen = rv.getBigUint64(RES_CSS_LEN);
    const cssPtr = rv.getPointer(RES_CSS);
    const errLen = rv.getBigUint64(RES_ERROR_LEN);
    const errPtr = rv.getPointer(RES_ERROR);
    const errorLine = rv.getUint32(RES_ERROR_LINE);
    const errorColumn = rv.getUint32(RES_ERROR_COLUMN);
    return {
      ok,
      css: ok ? readBytes(cssPtr, cssLen) : null,
      error: ok ? null : readBytes(errPtr, errLen),
      errorLine,
      errorColumn,
    };
  } finally {
    lib.symbols.sasso_result_free(resPtr);
    // `keep` (callbacks/buffers) stays referenced until here.
    if (keep.length) { /* alive through compile */ }
  }
}

// --- custom importer over an in-memory file map -------------------------------

function dirname(p: string): string {
  const i = p.lastIndexOf("/");
  return i <= 0 ? "/" : p.slice(0, i);
}

function asPartial(p: string): string {
  // /sub/mod -> /sub/_mod (dart's partial spelling)
  const i = p.lastIndexOf("/");
  return p.slice(0, i + 1) + "_" + p.slice(i + 1);
}

/**
 * Build a SassoImporter buffer over `files` (keys are canonical paths like
 * "/sub/_mod"). Returns the importer buffer plus a `keep` array of the two
 * UnsafeCallbacks; both must stay referenced for the whole compile.
 */
function makeImporter(files: Record<string, string>): {
  buf: Uint8Array;
  keep: unknown[];
} {
  const resolve = (url: string, containing: string | null): string | null => {
    const base = containing ? dirname(containing) : "";
    const joined = (base === "/" ? "" : base.replace(/\/+$/, "")) + "/" + url;
    for (const cand of [joined, asPartial(joined)]) {
      if (cand in files) return cand;
    }
    return null;
  };

  const canonicalize = new Deno.UnsafeCallback(
    {
      parameters: ["pointer", "pointer", "pointer", "pointer"],
      result: "i32",
    } as const,
    (_ud, urlPtr, ctxPtr, sink): number => {
      const url = readCString(urlPtr) ?? "";
      // SassoCanonicalizeContext { i32 from_import @0; const char* containing_url @8 }
      let containing: string | null = null;
      if (ctxPtr !== null) {
        const cv = new Deno.UnsafePointerView(ctxPtr);
        const cPtr = cv.getPointer(8);
        containing = readCString(cPtr);
      }
      const canon = resolve(url, containing);
      if (canon === null) return SASSO_IMPORTER_NOT_FOUND;
      const b = enc.encode(canon);
      lib.symbols.sasso_importer_set_canonical(sink, b, BigInt(b.length));
      return SASSO_IMPORTER_OK;
    },
  );

  const load = new Deno.UnsafeCallback(
    {
      parameters: ["pointer", "pointer", "pointer"],
      result: "i32",
    } as const,
    (_ud, canonPtr, sink): number => {
      const canon = readCString(canonPtr) ?? "";
      const src = files[canon];
      if (src === undefined) return SASSO_IMPORTER_NOT_FOUND;
      const b = enc.encode(src);
      lib.symbols.sasso_importer_set_result(
        sink,
        b,
        BigInt(b.length),
        SASSO_SYNTAX_SCSS,
        null, // source_map_url
        0n,
      );
      return SASSO_IMPORTER_OK;
    },
  );

  const buf = new Uint8Array(IMP_SIZE);
  const dv = new DataView(buf.buffer);
  // user_data = NULL
  dv.setBigUint64(IMP_USER_DATA, 0n, LE);
  dv.setBigUint64(
    IMP_CANONICALIZE,
    BigInt(Deno.UnsafePointer.value(canonicalize.pointer)),
    LE,
  );
  dv.setBigUint64(IMP_LOAD, BigInt(Deno.UnsafePointer.value(load.pointer)), LE);

  return { buf, keep: [canonicalize, load] };
}

// --- checks -------------------------------------------------------------------

let failed = false;
function check(name: string, cond: boolean, detail = "") {
  const tag = cond ? "PASS" : "FAIL";
  console.log(`  [${tag}] ${name}${cond || !detail ? "" : "  — " + detail}`);
  if (!cond) failed = true;
}

console.log("sasso C ABI — Deno (Deno.dlopen) binding test\n");

// Check 1: version
{
  const vPtr = lib.symbols.sasso_version();
  const v = readCString(vPtr);
  check(`1. sasso_version() looks like a version`, /^\d+\.\d+\.\d+/.test(v), `got ${JSON.stringify(v)}`);
}

// Check 2: default compile (NULL opts), nesting expanded
{
  const out = compile(".a { color: red; &:hover { color: blue; } }");
  const want = ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}";
  check(
    "2. default compile expands nesting",
    out.ok && out.css === want,
    JSON.stringify(out.css),
  );
}

// Check 3: compressed compile
{
  const out = compile(".a { color: #336699; }", (dv) => {
    dv.setInt32(OPT_STYLE, SASSO_STYLE_COMPRESSED, LE);
  });
  const want = ".a{color:#369}";
  check(
    "3. compressed compile",
    out.ok && out.css === want,
    JSON.stringify(out.css),
  );
}

// Check 4: error path
{
  const out = compile(".a { color: ");
  check(
    "4. error path (ok==0, error set, line>=1)",
    !out.ok && out.error !== null && out.error.length > 0 && out.errorLine >= 1,
    JSON.stringify({ ok: out.ok, line: out.errorLine, error: out.error }),
  );
  if (out.error) {
    console.log("       first error line: " + out.error.split("\n")[0]);
  }
}

// Check 5: v2 custom importer
{
  const files: Record<string, string> = { "/sub/_mod": "$c: #336699;\n" };
  const entry = '@use "sub/mod" as m;\n.out { color: m.$c; }\n';
  const out = compile(entry, (dv, _buf, keep) => {
    dv.setInt32(OPT_STYLE, SASSO_STYLE_EXPANDED, LE);
    const urlBuf = cstr("/entry");
    keep.push(urlBuf);
    dv.setBigUint64(
      OPT_URL,
      BigInt(Deno.UnsafePointer.value(Deno.UnsafePointer.of(urlBuf))),
      LE,
    );
    const { buf: impBuf, keep: impKeep } = makeImporter(files);
    keep.push(impBuf, ...impKeep);
    dv.setBigUint64(
      OPT_IMPORTER,
      BigInt(Deno.UnsafePointer.value(Deno.UnsafePointer.of(impBuf))),
      LE,
    );
  });
  const want = ".out {\n  color: #336699;\n}";
  check(
    "5. v2 custom importer resolves @use",
    out.ok && out.css === want,
    JSON.stringify({ ok: out.ok, css: out.css, error: out.error }),
  );
}

console.log("\nRESULT: " + (failed ? "FAIL" : "PASS"));
lib.close();
Deno.exit(failed ? 1 : 0);
