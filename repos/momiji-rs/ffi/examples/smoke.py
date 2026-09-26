#!/usr/bin/env python3
"""Minimal end-to-end check of the sasso C ABI from Python via ctypes.

Build the library first:  cargo build --release   (in ffi/)
Then:                     python3 examples/smoke.py

It exercises sasso_version, a basic compile, compressed output, an options
struct (NULL = defaults), and the error path (with line/column). Exits non-zero
on any mismatch, so it doubles as a CI smoke test.
"""
import ctypes
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def find_lib():
    names = ["libsasso.dylib", "libsasso.so"]
    for base in (os.path.join(ROOT, "target", "release"), ROOT):
        for n in names:
            p = os.path.join(base, n)
            if os.path.exists(p):
                return p
    sys.exit("could not find libsasso.{dylib,so}; run `cargo build --release` in ffi/ first")


class SassoOptions(ctypes.Structure):
    _fields_ = [
        ("struct_size", ctypes.c_uint32),
        ("style", ctypes.c_int32),
        ("syntax", ctypes.c_int32),
        ("unicode", ctypes.c_int32),
        ("url", ctypes.c_char_p),
        ("load_paths", ctypes.POINTER(ctypes.c_char_p)),
        ("load_paths_len", ctypes.c_size_t),
    ]


class SassoResult(ctypes.Structure):
    # css/error are c_void_p (not c_char_p) so we keep the raw pointer and read
    # exactly css_len/error_len bytes via ctypes.string_at — honoring the ABI's
    # explicit lengths rather than assuming NUL-termination (binary-safe).
    _fields_ = [
        ("ok", ctypes.c_int32),
        ("css", ctypes.c_void_p),
        ("css_len", ctypes.c_size_t),
        ("error", ctypes.c_void_p),
        ("error_len", ctypes.c_size_t),
        ("error_line", ctypes.c_uint32),
        ("error_column", ctypes.c_uint32),
    ]


SASSO_STYLE_COMPRESSED = 1

lib = ctypes.CDLL(find_lib())
lib.sasso_version.restype = ctypes.c_char_p
lib.sasso_options_init.argtypes = [ctypes.POINTER(SassoOptions), ctypes.c_size_t]
lib.sasso_compile.restype = ctypes.POINTER(SassoResult)
lib.sasso_compile.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.POINTER(SassoOptions)]
lib.sasso_result_free.argtypes = [ctypes.POINTER(SassoResult)]


def compile_scss(src: str, options=None):
    raw = src.encode("utf-8")
    res_ptr = lib.sasso_compile(raw, len(raw), options)
    res = res_ptr.contents
    try:
        if res.ok:
            css = ctypes.string_at(res.css, res.css_len).decode("utf-8")
            return True, css, None
        err = ctypes.string_at(res.error, res.error_len).decode("utf-8")
        return False, None, (err, res.error_line, res.error_column)
    finally:
        lib.sasso_result_free(res_ptr)


def check(name, cond):
    print(f"  {'ok  ' if cond else 'FAIL'} {name}")
    if not cond:
        check.failed = True


check.failed = False

print("sasso C ABI smoke test")
print("  version:", lib.sasso_version().decode())

# 1. Basic compile (NULL options => defaults: expanded).
ok, css, _ = compile_scss(".a { color: red; &:hover { color: blue; } }")
check("basic compile", ok and css == ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}")

# 2. The merged community fix (#3): rgba(var()) keeps its name.
ok, css, _ = compile_scss(".a { color: rgba(var(--x), 0.5); }")
check("rgba(var()) passthrough", ok and css.strip() == ".a {\n  color: rgba(var(--x), 0.5);\n}")

# 3. Compressed output via an options struct.
opts = SassoOptions()
lib.sasso_options_init(ctypes.byref(opts), ctypes.sizeof(opts))
opts.style = SASSO_STYLE_COMPRESSED
ok, css, _ = compile_scss(".a { color: #336699; }", ctypes.byref(opts))
check("compressed style", ok and css == ".a{color:#369}")

# 4. Error path carries message + 1-based line/column.
ok, css, err = compile_scss(".a { color: ")
check("error path reports failure", (not ok) and err is not None and err[1] >= 1)
if err:
    print(f"       error line {err[1]} col {err[2]}: {err[0].splitlines()[0]}")

print("RESULT:", "FAIL" if check.failed else "PASS")
sys.exit(1 if check.failed else 0)
