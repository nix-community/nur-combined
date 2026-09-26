#!/usr/bin/env python3
"""Custom-importer check of the sasso C ABI from Python via ctypes (FFI v2).

Build the library first:  cargo build --release   (in ffi/)
Then:                     python3 examples/importer.py

It supplies a userland importer (SassoOptions.importer) whose two callbacks
resolve `@use`/`@forward` URLs against an in-memory file map — demonstrating
directory-relative resolution driven by `containing_url`, the not-found path,
and error propagation. Exits non-zero on any mismatch, so it doubles as a CI
test alongside smoke.py.

Ownership model (Model 2): a callback never hands sasso an owned pointer. It
calls one of the sasso_importer_set_* functions with its sink; sasso copies the
bytes immediately, and Python keeps ownership of its own (GC'd) buffers.
"""
import ctypes
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

SASSO_SYNTAX_SCSS = 0
SASSO_IMPORTER_OK = 1
SASSO_IMPORTER_NOT_FOUND = 0
SASSO_IMPORTER_ERROR = -1


def find_lib():
    names = ["libsasso.dylib", "libsasso.so"]
    for base in (os.path.join(ROOT, "target", "release"), ROOT):
        for n in names:
            p = os.path.join(base, n)
            if os.path.exists(p):
                return p
    sys.exit("could not find libsasso.{dylib,so}; run `cargo build --release` in ffi/ first")


class SassoCanonicalizeContext(ctypes.Structure):
    _fields_ = [
        ("from_import", ctypes.c_int32),
        ("containing_url", ctypes.c_char_p),
    ]


CANONICALIZE_FN = ctypes.CFUNCTYPE(
    ctypes.c_int32,
    ctypes.c_void_p,                              # user_data
    ctypes.c_char_p,                              # url (NUL-terminated)
    ctypes.POINTER(SassoCanonicalizeContext),     # ctx
    ctypes.c_void_p,                              # sink (opaque)
)
LOAD_FN = ctypes.CFUNCTYPE(
    ctypes.c_int32,
    ctypes.c_void_p,    # user_data
    ctypes.c_char_p,    # canonical (NUL-terminated)
    ctypes.c_void_p,    # sink (opaque)
)


class SassoImporter(ctypes.Structure):
    _fields_ = [
        ("user_data", ctypes.c_void_p),
        ("canonicalize", CANONICALIZE_FN),
        ("load", LOAD_FN),
    ]


class SassoOptions(ctypes.Structure):
    _fields_ = [
        ("struct_size", ctypes.c_uint32),
        ("style", ctypes.c_int32),
        ("syntax", ctypes.c_int32),
        ("unicode", ctypes.c_int32),
        ("url", ctypes.c_char_p),
        ("load_paths", ctypes.POINTER(ctypes.c_char_p)),
        ("load_paths_len", ctypes.c_size_t),
        ("importer", ctypes.POINTER(SassoImporter)),
    ]


class SassoResult(ctypes.Structure):
    _fields_ = [
        ("ok", ctypes.c_int32),
        ("css", ctypes.c_void_p),
        ("css_len", ctypes.c_size_t),
        ("error", ctypes.c_void_p),
        ("error_len", ctypes.c_size_t),
        ("error_line", ctypes.c_uint32),
        ("error_column", ctypes.c_uint32),
    ]


lib = ctypes.CDLL(find_lib())
lib.sasso_options_init.argtypes = [ctypes.POINTER(SassoOptions), ctypes.c_size_t]
lib.sasso_compile.restype = ctypes.POINTER(SassoResult)
lib.sasso_compile.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.POINTER(SassoOptions)]
lib.sasso_result_free.argtypes = [ctypes.POINTER(SassoResult)]
lib.sasso_importer_set_canonical.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t]
lib.sasso_importer_set_canonical.restype = None
lib.sasso_importer_set_result.argtypes = [
    ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t,
    ctypes.c_int32, ctypes.c_char_p, ctypes.c_size_t,
]
lib.sasso_importer_set_result.restype = None
lib.sasso_importer_set_error.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t]
lib.sasso_importer_set_error.restype = None


def _dirname(p):
    i = p.rfind("/")
    return "/" if i <= 0 else p[:i]


def _as_partial(p):
    """/sub/mod -> /sub/_mod (dart's partial spelling)."""
    i = p.rfind("/")
    return p[: i + 1] + "_" + p[i + 1:]


def make_importer(files, *, fail=None):
    """Build a SassoImporter over an in-memory {canonical: source} map.

    `files` keys are canonical paths like "/sub/_mod". `canonicalize` resolves a
    URL against the importing file's directory (from `containing_url`) with the
    partial fallback; `load` returns the source. If `fail` is set, canonicalizing
    that exact URL returns an error instead — to exercise the error path.

    Returns (SassoImporter, keepalive) — keepalive MUST stay referenced for as
    long as the importer is used, or ctypes will collect the trampolines.
    """
    def resolve(url, containing):
        base = _dirname(containing) if containing else ""
        joined = base.rstrip("/") + "/" + url
        for cand in (joined, _as_partial(joined)):
            if cand in files:
                return cand
        return None

    def canonicalize(_ud, url_bytes, ctx_ptr, sink):
        url = url_bytes.decode("utf-8")
        ctx = ctx_ptr.contents
        containing = ctx.containing_url.decode("utf-8") if ctx.containing_url else None
        if fail is not None and url == fail:
            msg = f"importer refused {url!r}".encode("utf-8")
            lib.sasso_importer_set_error(sink, msg, len(msg))
            return SASSO_IMPORTER_ERROR
        canon = resolve(url, containing)
        if canon is None:
            return SASSO_IMPORTER_NOT_FOUND
        b = canon.encode("utf-8")
        lib.sasso_importer_set_canonical(sink, b, len(b))
        return SASSO_IMPORTER_OK

    def load(_ud, canon_bytes, sink):
        src = files.get(canon_bytes.decode("utf-8"))
        if src is None:
            return SASSO_IMPORTER_NOT_FOUND
        b = src.encode("utf-8")
        lib.sasso_importer_set_result(sink, b, len(b), SASSO_SYNTAX_SCSS, None, 0)
        return SASSO_IMPORTER_OK

    cb_canon = CANONICALIZE_FN(canonicalize)
    cb_load = LOAD_FN(load)
    imp = SassoImporter(user_data=None, canonicalize=cb_canon, load=cb_load)
    return imp, (cb_canon, cb_load, imp)


def compile_with_importer(src, importer, url="/entry"):
    opts = SassoOptions()
    lib.sasso_options_init(ctypes.byref(opts), ctypes.sizeof(opts))
    opts.url = url.encode("utf-8")
    opts.importer = ctypes.pointer(importer)
    raw = src.encode("utf-8")
    res_ptr = lib.sasso_compile(raw, len(raw), ctypes.byref(opts))
    res = res_ptr.contents
    try:
        if res.ok:
            return True, ctypes.string_at(res.css, res.css_len).decode("utf-8"), None
        return False, None, ctypes.string_at(res.error, res.error_len).decode("utf-8")
    finally:
        lib.sasso_result_free(res_ptr)


def check(name, cond, detail=""):
    print(f"  {'ok  ' if cond else 'FAIL'} {name}{('  — ' + detail) if detail and not cond else ''}")
    if not cond:
        check.failed = True


check.failed = False
print("sasso C ABI custom-importer test")

# A nested, directory-relative module graph kept entirely in memory:
#   /entry      @use "sub/mod"         (resolved relative to /  -> /sub/_mod)
#   /sub/_mod   @use "dep"             (resolved relative to /sub -> /sub/_dep)
#   /sub/_dep   $x: #336699;
FILES = {
    "/sub/_mod": '@use "dep" as d;\n$c: d.$x;\n',
    "/sub/_dep": "$x: #336699;\n",
}
imp, keep = make_importer(FILES)
ok, css, err = compile_with_importer('@use "sub/mod" as m;\n.out { color: m.$c; }\n', imp)
check("relative @use resolves via containing_url", ok and css == ".out {\n  color: #336699;\n}", str((ok, css, err)))

# Not-found: the importer returns NOT_FOUND -> a clean compile error.
imp2, keep2 = make_importer(FILES)
ok, css, err = compile_with_importer('@use "does/not/exist";\n', imp2)
check("missing import surfaces a compile error", (not ok) and err is not None, str((ok, css, err)))

# Error: the importer returns ERROR with a message -> it propagates.
imp3, keep3 = make_importer(FILES, fail="sub/mod")
ok, css, err = compile_with_importer('@use "sub/mod" as m;\n.out { color: m.$c; }\n', imp3)
check("importer error propagates its message", (not ok) and err is not None and "refused" in err, str((ok, css, err)))

print("RESULT:", "FAIL" if check.failed else "PASS")
sys.exit(1 if check.failed else 0)
