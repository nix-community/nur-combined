//! C ABI for the [`sasso`](https://crates.io/crates/sasso) pure-Rust SCSS → CSS
//! compiler.
//!
//! This is a thin, stable `extern "C"` surface so any language with a C FFI
//! (PHP FFI, Python `ctypes`/`cffi`, Ruby `Fiddle`, Go `cgo`, LuaJIT, …) can
//! drive sasso in-process — one ABI, many languages, no per-language native
//! extension. The generated/curated header is [`include/sasso.h`](../include/sasso.h).
//!
//! ## Contract (read before binding)
//!
//! - **Strings in** are UTF-8 `(pointer, length)` pairs (NOT required to be
//!   NUL-terminated), except host paths (`url`, `load_paths`) which are
//!   NUL-terminated C strings.
//! - **Strings out** ([`SassoResult::css`] / [`SassoResult::error`]) are
//!   NUL-terminated AND carry an explicit byte length; they are owned by sasso
//!   and **must** be released with [`sasso_result_free`] — never with the
//!   caller's own `free()`.
//! - Every entry point is panic-safe: a Rust panic is caught at the boundary
//!   and turned into an error result (a panic unwinding across the C ABI is
//!   undefined behavior).
//! - [`SassoOptions`] is `#[repr(C)]` with a leading `struct_size` for forward
//!   compatibility; fill it with [`sasso_options_init`] and override fields.

use std::ffi::{c_char, c_void, CStr, CString};
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::path::PathBuf;
use std::ptr;
use std::slice;

use sasso_core::{
    compile, CanonicalUrl, CanonicalizeContext, FsImporter, Importer, ImporterError, ImporterResult, Options,
    OutputStyle, Syntax,
};

/// Output style: human-readable, indented CSS (`SassoOptions::style`).
pub const SASSO_STYLE_EXPANDED: i32 = 0;
/// Output style: minified, single-line CSS.
pub const SASSO_STYLE_COMPRESSED: i32 = 1;

/// Input syntax: brace/semicolon SCSS (`SassoOptions::syntax`).
pub const SASSO_SYNTAX_SCSS: i32 = 0;
/// Input syntax: indented `.sass`.
pub const SASSO_SYNTAX_SASS: i32 = 1;
/// Input syntax: plain CSS (Sass features rejected, values emitted verbatim).
pub const SASSO_SYNTAX_CSS: i32 = 2;

/// Importer callback return: handled — the host called `sasso_importer_set_canonical`
/// (from `canonicalize`) or `sasso_importer_set_result` (from `load`).
pub const SASSO_IMPORTER_OK: i32 = 1;
/// Importer callback return: this importer does not handle the URL (try the next
/// resolution step / treat as not-found). The host need not set anything.
pub const SASSO_IMPORTER_NOT_FOUND: i32 = 0;
/// Importer callback return: handled but failed — the host called
/// `sasso_importer_set_error` with a diagnostic message.
pub const SASSO_IMPORTER_ERROR: i32 = -1;

/// Compile options. `#[repr(C)]`; a `NULL` pointer means "all defaults".
///
/// The leading `struct_size` lets the ABI grow without breaking older callers:
/// initialize with `sasso_options_init(opts, sizeof(SassoOptions))` (which sets
/// it), then set the fields you care about.
#[repr(C)]
pub struct SassoOptions {
    /// `sizeof(SassoOptions)` as the caller sees it — set by [`sasso_options_init`].
    pub struct_size: u32,
    /// One of the `SASSO_STYLE_*` constants. Default `SASSO_STYLE_EXPANDED`.
    pub style: i32,
    /// One of the `SASSO_SYNTAX_*` constants. Default `SASSO_SYNTAX_SCSS`.
    pub syntax: i32,
    /// Non-zero to use Unicode box-drawing glyphs in diagnostics; `0` for ASCII.
    pub unicode: i32,
    /// Optional NUL-terminated UTF-8 display path for diagnostics (enables
    /// byte-exact error snippets). `NULL` to disable.
    pub url: *const c_char,
    /// Optional array of NUL-terminated UTF-8 load paths searched for
    /// `@import`/`@use`/`@forward`. `NULL` (or `load_paths_len == 0`) for none.
    pub load_paths: *const *const c_char,
    /// Number of entries in `load_paths`.
    pub load_paths_len: usize,
    /// Optional custom [`SassoImporter`] driving `@use`/`@forward`/`@import`
    /// resolution. `NULL` uses the built-in filesystem importer (`load_paths`).
    /// A non-NULL importer takes precedence over `load_paths`. The pointee must
    /// stay valid for the duration of the [`sasso_compile`] call.
    pub importer: *const SassoImporter,
}

/// The outcome of a compile. Allocated by [`sasso_compile`]; release with
/// [`sasso_result_free`]. On success `ok == 1` and `css` is set; on failure
/// `ok == 0` and `error` (plus `error_line`/`error_column`) is set.
#[repr(C)]
pub struct SassoResult {
    /// `1` on success, `0` on failure.
    pub ok: i32,
    /// NUL-terminated UTF-8 CSS on success, else `NULL`. Owned by sasso.
    pub css: *mut c_char,
    /// Byte length of `css` (excluding the NUL), or `0`.
    pub css_len: usize,
    /// NUL-terminated UTF-8 diagnostic on failure, else `NULL`. Owned by sasso.
    pub error: *mut c_char,
    /// Byte length of `error` (excluding the NUL), or `0`.
    pub error_len: usize,
    /// 1-based line of the error, or `0` if unknown.
    pub error_line: u32,
    /// 1-based column of the error, or `0` if unknown.
    pub error_column: u32,
}

/// Context passed to a [`SassoImporter::canonicalize`] callback.
#[repr(C)]
pub struct SassoCanonicalizeContext {
    /// Non-zero when this resolution is for a legacy `@import` (as opposed to
    /// `@use`/`@forward`), so the importer may prefer an import-only partial.
    pub from_import: i32,
    /// The canonical URL of the file that contains the `@use`/`@import`, as a
    /// NUL-terminated UTF-8 string, or `NULL` for the entry stylesheet.
    pub containing_url: *const c_char,
}

/// `canonicalize` callback: map `url` to a canonical key. Return one of the
/// `SASSO_IMPORTER_*` codes; on `OK` the host must have called
/// [`sasso_importer_set_canonical`]; on `ERROR`, [`sasso_importer_set_error`].
pub type SassoCanonicalizeFn = extern "C" fn(
    user_data: *mut c_void,
    url: *const c_char,
    ctx: *const SassoCanonicalizeContext,
    sink: *mut SassoImporterSink,
) -> i32;

/// `load` callback: fetch the source for a canonical key previously produced by
/// `canonicalize`. On `OK` the host must have called [`sasso_importer_set_result`].
pub type SassoLoadFn =
    extern "C" fn(user_data: *mut c_void, canonical: *const c_char, sink: *mut SassoImporterSink) -> i32;

/// A userland importer: two callbacks plus an opaque `user_data` threaded back
/// into each. Set [`SassoOptions::importer`] to use it. The two phases mirror
/// dart-sass: `canonicalize` resolves a (possibly relative, extension-less) URL
/// to a stable key WITHOUT loading; `load` then fetches that key's source.
#[repr(C)]
pub struct SassoImporter {
    /// Opaque pointer passed verbatim as the first argument of each callback.
    pub user_data: *mut c_void,
    /// Resolve a URL to its canonical key (`NULL` = no importer; resolution fails).
    pub canonicalize: Option<SassoCanonicalizeFn>,
    /// Load a canonical key's source (`NULL` = no importer; loading fails).
    pub load: Option<SassoLoadFn>,
}

// ABI layout lock. These sizes/offsets are what `include/sasso.h` and every
// language binding encode by hand; a change here is a BREAKING ABI change, so it
// must fail to compile until `sasso.h` and the bindings are updated in lockstep.
// (Gated to 64-bit, the only width the prebuilt library ships for; the i32+
// pointer layout is identical across our LP64/LLP64 64-bit targets.)
#[cfg(target_pointer_width = "64")]
const _: () = {
    assert!(std::mem::size_of::<SassoOptions>() == 48);
    assert!(std::mem::offset_of!(SassoOptions, importer) == 40);
    assert!(std::mem::size_of::<SassoResult>() == 48);
    assert!(std::mem::offset_of!(SassoResult, error_line) == 40);
    assert!(std::mem::size_of::<SassoImporter>() == 24);
    assert!(std::mem::size_of::<SassoCanonicalizeContext>() == 16);
};

/// An opaque, sasso-owned collector handed to an importer callback. The host
/// delivers its result by calling one of the `sasso_importer_set_*` functions
/// with it; those COPY the bytes immediately, so the host keeps ownership of its
/// own buffers. The pointer is valid ONLY for the duration of that one callback.
pub struct SassoImporterSink {
    canonical: Option<String>,
    result: Option<ImporterResult>,
    error: Option<String>,
}

impl SassoImporterSink {
    fn new() -> Self {
        SassoImporterSink {
            canonical: None,
            result: None,
            error: None,
        }
    }
}

/// Copy a host `(ptr, len)` buffer, distinguishing the three cases a setter must
/// handle separately: `None` = NULL pointer (nothing delivered); `Some(Ok(s))` =
/// valid UTF-8; `Some(Err(()))` = non-UTF-8 bytes (an actionable host error, not
/// a silent miss). `len == 0` with a non-NULL pointer yields an empty string —
/// `slice::from_raw_parts(ptr, 0)` is valid for any non-NULL `c_char` pointer.
unsafe fn read_utf8(ptr: *const c_char, len: usize) -> Option<Result<String, ()>> {
    if ptr.is_null() {
        return None;
    }
    let bytes = slice::from_raw_parts(ptr as *const u8, len);
    Some(std::str::from_utf8(bytes).map(|s| s.to_owned()).map_err(|_| ()))
}

/// Deliver the canonical URL from a `canonicalize` callback (copied immediately).
/// Call once, then return [`SASSO_IMPORTER_OK`]. A NULL pointer delivers nothing;
/// non-UTF-8 bytes record an error (surfaced as the compile failure).
///
/// # Safety
/// `sink` must be the pointer passed to the current callback; `ptr` must point to
/// `len` readable bytes (or be NULL).
#[no_mangle]
pub unsafe extern "C" fn sasso_importer_set_canonical(
    sink: *mut SassoImporterSink,
    ptr: *const c_char,
    len: usize,
) {
    // Invoked from inside the host's C callback frame, so a Rust panic must never
    // unwind across it — guard the whole body (mirrors `sasso_result_free`).
    let _ = catch_unwind(AssertUnwindSafe(|| {
        if let Some(sink) = sink.as_mut() {
            match read_utf8(ptr, len) {
                None => {} // NULL: delivered nothing
                Some(Ok(s)) => sink.canonical = Some(s),
                Some(Err(())) => {
                    sink.error = Some("sasso: importer delivered a non-UTF-8 canonical URL".to_string());
                }
            }
        }
    }));
}

/// Deliver the loaded stylesheet from a `load` callback (copied immediately).
/// `syntax` is one of `SASSO_SYNTAX_*` (an unknown value records an error);
/// `source_map_url` may be `NULL`. Call once, then return [`SASSO_IMPORTER_OK`].
///
/// # Safety
/// `sink` must be the pointer passed to the current callback; `contents` /
/// `source_map_url` must point to their stated lengths of readable bytes (or be NULL).
#[no_mangle]
pub unsafe extern "C" fn sasso_importer_set_result(
    sink: *mut SassoImporterSink,
    contents: *const c_char,
    contents_len: usize,
    syntax: i32,
    source_map_url: *const c_char,
    source_map_url_len: usize,
) {
    let _ = catch_unwind(AssertUnwindSafe(|| {
        let sink = match sink.as_mut() {
            Some(s) => s,
            None => return,
        };
        let contents = match read_utf8(contents, contents_len) {
            Some(Ok(c)) => c,
            None => return, // NULL contents: delivered nothing
            Some(Err(())) => {
                sink.error = Some("sasso: importer delivered non-UTF-8 contents".to_string());
                return;
            }
        };
        let syntax = match syntax_from_i32(syntax) {
            Some(s) => s,
            None => {
                // Consistent with sasso_compile: an out-of-range syntax is a host
                // bug, surfaced as an error (via interpret) rather than silently
                // parsed as SCSS — which would emit subtly wrong CSS.
                sink.error = Some(format!(
                    "sasso: importer delivered an invalid syntax value {syntax}"
                ));
                return;
            }
        };
        // The source-map URL is optional: a NULL or non-UTF-8 value just means
        // "no override" rather than an error.
        let source_map_url = match read_utf8(source_map_url, source_map_url_len) {
            Some(Ok(u)) => Some(u),
            _ => None,
        };
        sink.result = Some(ImporterResult {
            contents,
            syntax,
            source_map_url,
        });
    }));
}

/// Deliver an error message from either callback (copied immediately). Call, then
/// return [`SASSO_IMPORTER_ERROR`]. A NULL, empty, or non-UTF-8 message falls back
/// to a generic string so the failure always carries some diagnostic text.
///
/// # Safety
/// `sink` must be the pointer passed to the current callback; `ptr` must point to
/// `len` readable bytes (or be NULL).
#[no_mangle]
pub unsafe extern "C" fn sasso_importer_set_error(
    sink: *mut SassoImporterSink,
    ptr: *const c_char,
    len: usize,
) {
    let _ = catch_unwind(AssertUnwindSafe(|| {
        if let Some(sink) = sink.as_mut() {
            let msg = match read_utf8(ptr, len) {
                Some(Ok(s)) if !s.is_empty() => s,
                _ => "importer error".to_string(),
            };
            sink.error = Some(msg);
        }
    }));
}

/// Bridges a C [`SassoImporter`] to the core [`Importer`] trait. Holds a pointer
/// to the caller's struct, which the host guarantees valid for the compile.
struct FfiImporter {
    inner: *const SassoImporter,
}

impl FfiImporter {
    /// Map a tri-state callback return + the sink's collected value/error into the
    /// trait's `Result<Option<T>, ImporterError>`.
    fn interpret<T>(
        rc: i32,
        value: Option<T>,
        error: Option<String>,
        what: &str,
    ) -> Result<Option<T>, ImporterError> {
        match rc {
            SASSO_IMPORTER_OK => match value {
                Some(v) => Ok(Some(v)),
                // OK without a delivered value is a contract violation; if the
                // host left an error message (e.g. it hit a problem but returned
                // OK, or a setter rejected its input), surface THAT — it is far
                // more actionable than the generic note.
                None => Err(ImporterError {
                    message: error.unwrap_or_else(|| {
                        format!("sasso: importer {what} returned OK but delivered no value")
                    }),
                }),
            },
            SASSO_IMPORTER_NOT_FOUND => Ok(None),
            // ERROR, and any out-of-range code, are failures.
            _ => Err(ImporterError {
                message: error.unwrap_or_else(|| format!("sasso: importer {what} failed")),
            }),
        }
    }
}

impl Importer for FfiImporter {
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        // SAFETY: the caller's `SassoImporter` is valid for the compile (the
        // documented contract for `SassoOptions::importer`).
        let inner = unsafe { &*self.inner };
        let cb = match inner.canonicalize {
            Some(f) => f,
            None => {
                return Err(ImporterError {
                    message: "sasso: importer has no canonicalize callback".to_string(),
                })
            }
        };
        let url_c = match CString::new(url) {
            Ok(c) => c,
            Err(_) => {
                return Err(ImporterError {
                    message: "sasso: url contains an interior NUL byte".to_string(),
                })
            }
        };
        // Keep the containing-url CString alive across the call.
        let containing_c = match ctx.containing_url {
            Some(c) => match CString::new(c.as_str()) {
                Ok(s) => Some(s),
                Err(_) => {
                    return Err(ImporterError {
                        message: "sasso: containing url contains an interior NUL byte".to_string(),
                    })
                }
            },
            None => None,
        };
        let c_ctx = SassoCanonicalizeContext {
            from_import: ctx.from_import as i32,
            containing_url: containing_c.as_ref().map_or(ptr::null(), |s| s.as_ptr()),
        };
        let mut sink = SassoImporterSink::new();
        let rc = cb(inner.user_data, url_c.as_ptr(), &c_ctx, &mut sink);
        FfiImporter::interpret(
            rc,
            sink.canonical.map(CanonicalUrl::new),
            sink.error,
            "canonicalize",
        )
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        let inner = unsafe { &*self.inner };
        let cb = match inner.load {
            Some(f) => f,
            None => {
                return Err(ImporterError {
                    message: "sasso: importer has no load callback".to_string(),
                })
            }
        };
        let canon_c = match CString::new(canonical.as_str()) {
            Ok(c) => c,
            Err(_) => {
                return Err(ImporterError {
                    message: "sasso: canonical url contains an interior NUL byte".to_string(),
                })
            }
        };
        let mut sink = SassoImporterSink::new();
        let rc = cb(inner.user_data, canon_c.as_ptr(), &mut sink);
        FfiImporter::interpret(rc, sink.result, sink.error, "load")
    }
}

/// The bundled compiler's version with a trailing NUL, for the C ABI.
///
/// Built from `sasso_core::VERSION` — the CORE crate's version — deliberately
/// NOT this crate's `CARGO_PKG_VERSION`. `sasso-ffi` is versioned independently
/// of the compiler it wraps, so the old `concat!(env!("CARGO_PKG_VERSION"), …)`
/// reported the WRAPPER's number: it had drifted to 0.6.1 while the bundled
/// compiler was 0.8.1, even though `sasso_version()` is documented as the
/// compiler version. Reading the core const cannot drift.
///
/// `concat!` is not usable here — it takes literals only, and
/// `sasso_core::VERSION` is a const — so the NUL is appended in const code. The
/// array is sized from the input, so it cannot overflow or truncate.
const VERSION_NUL: [u8; sasso_core::VERSION.len() + 1] = {
    let src = sasso_core::VERSION.as_bytes();
    let mut buf = [0u8; sasso_core::VERSION.len() + 1];
    let mut i = 0;
    while i < src.len() {
        buf[i] = src[i];
        i += 1;
    }
    // buf[src.len()] stays 0: the terminator.
    buf
};

/// Return the bundled compiler version as a static NUL-terminated string.
///
/// The returned pointer is `'static` and must **not** be freed.
#[no_mangle]
pub extern "C" fn sasso_version() -> *const c_char {
    VERSION_NUL.as_ptr() as *const c_char
}

/// The all-defaults `SassoOptions` (expanded, SCSS, Unicode diagnostics, no url /
/// load paths / importer). `struct_size` is the only field that differs between
/// callers, so it is a parameter — keeping a single source of truth for the
/// defaults shared by `sasso_options_init` and `read_options`.
fn default_options(struct_size: u32) -> SassoOptions {
    SassoOptions {
        struct_size,
        style: SASSO_STYLE_EXPANDED,
        syntax: SASSO_SYNTAX_SCSS,
        unicode: 1,
        url: ptr::null(),
        load_paths: ptr::null(),
        load_paths_len: 0,
        importer: ptr::null(),
    }
}

/// Fill `options` with defaults (expanded, SCSS, Unicode diagnostics, no url /
/// load paths). `struct_size` is the caller's `sizeof(SassoOptions)`: only that
/// many bytes are written (capped at this build's size), so a smaller/older
/// caller is never written past. Pass `sizeof(SassoOptions)`.
///
/// # Safety
/// `options` must be `NULL` or point to at least `struct_size` writable bytes.
#[no_mangle]
pub unsafe extern "C" fn sasso_options_init(options: *mut SassoOptions, struct_size: usize) {
    if options.is_null() {
        return;
    }
    // Saturate rather than truncate: a buggy caller passing > u32::MAX must not
    // wrap to a small value (which read_options would then trust).
    let defaults = default_options(saturate_u32(struct_size));
    // Write only what the caller's struct can hold — never past their buffer.
    let n = struct_size.min(std::mem::size_of::<SassoOptions>());
    ptr::copy_nonoverlapping(
        (&defaults as *const SassoOptions).cast::<u8>(),
        options.cast::<u8>(),
        n,
    );
}

/// Read a caller-supplied `SassoOptions` in a version-tolerant way: the leading
/// `struct_size` says how many bytes the caller actually provided, so we copy
/// only that prefix over a defaults-filled local. A caller with an older,
/// smaller struct gets our defaults for the missing tail, and we never read past
/// their allocation. `NULL` yields all defaults.
///
/// # Safety
/// `options` must be `NULL` or point to at least its own leading `struct_size`
/// bytes (the minimal contract a `SassoOptions` pointer already implies).
unsafe fn read_options(options: *const SassoOptions) -> SassoOptions {
    let size = std::mem::size_of::<SassoOptions>();
    let mut local = default_options(size as u32);
    if options.is_null() {
        return local;
    }
    let caller_size = ptr::read_unaligned(ptr::addr_of!((*options).struct_size)) as usize;
    let n = caller_size.min(size);
    ptr::copy_nonoverlapping(
        options.cast::<u8>(),
        (&mut local as *mut SassoOptions).cast::<u8>(),
        n,
    );
    // Drop any tail field the caller's `struct_size` did not FULLY cover, so we
    // never dereference a half-copied pointer. Gated per field (not "any time
    // n < size") so that if a future version appends fields *after* these
    // pointers, an older caller that did provide url/load_paths keeps them.
    // Gate each pointer on the end of its OWN field (offset + size), not the
    // offset of the next field — so inserting a non-pointer field later cannot
    // silently widen this guard and leave a half-copied pointer non-null.
    if caller_size < std::mem::offset_of!(SassoOptions, url) + std::mem::size_of::<*const c_char>() {
        local.url = ptr::null();
    }
    if caller_size
        < std::mem::offset_of!(SassoOptions, load_paths) + std::mem::size_of::<*const *const c_char>()
    {
        local.load_paths = ptr::null();
    }
    if caller_size < std::mem::offset_of!(SassoOptions, load_paths_len) + std::mem::size_of::<usize>() {
        local.load_paths_len = 0;
    }
    if caller_size
        < std::mem::offset_of!(SassoOptions, importer) + std::mem::size_of::<*const SassoImporter>()
    {
        local.importer = ptr::null();
    }
    local
}

/// Compile `source` (a UTF-8 buffer of `source_len` bytes) to CSS.
///
/// Returns a heap-allocated [`SassoResult`] (never `NULL` under normal
/// operation) that the caller must release with [`sasso_result_free`]. A panic
/// inside the compiler is caught and reported as an error result.
///
/// # Safety
/// `source` must point to `source_len` readable bytes. `options` must be `NULL`
/// or a valid `SassoOptions` whose `url`/`load_paths` (when non-null) point to
/// valid NUL-terminated strings for the duration of the call.
#[no_mangle]
pub unsafe extern "C" fn sasso_compile(
    source: *const c_char,
    source_len: usize,
    options: *const SassoOptions,
) -> *mut SassoResult {
    match catch_unwind(AssertUnwindSafe(|| compile_inner(source, source_len, options))) {
        Ok(result) => result,
        Err(_) => make_error("sasso: internal panic during compilation", 0, 0),
    }
}

/// Release a [`SassoResult`] returned by [`sasso_compile`] (frees the struct and
/// its `css`/`error` strings). Passing `NULL` is a no-op.
///
/// # Safety
/// `result` must be `NULL` or a pointer obtained from [`sasso_compile`] that has
/// not already been freed.
#[no_mangle]
pub unsafe extern "C" fn sasso_result_free(result: *mut SassoResult) {
    if result.is_null() {
        return;
    }
    // Reclaim the box and its owned strings; ignore any (impossible) panic so
    // free never unwinds across the boundary.
    let _ = catch_unwind(AssertUnwindSafe(|| {
        let r = Box::from_raw(result);
        if !r.css.is_null() {
            drop(CString::from_raw(r.css));
        }
        if !r.error.is_null() {
            drop(CString::from_raw(r.error));
        }
    }));
}

/// The real body of [`sasso_compile`], run inside `catch_unwind`.
unsafe fn compile_inner(
    source: *const c_char,
    source_len: usize,
    options: *const SassoOptions,
) -> *mut SassoResult {
    if source.is_null() && source_len != 0 {
        return make_error("sasso: source pointer is null", 0, 0);
    }
    let src_bytes = if source_len == 0 {
        &[][..]
    } else {
        slice::from_raw_parts(source as *const u8, source_len)
    };
    let src = match std::str::from_utf8(src_bytes) {
        Ok(s) => s,
        Err(_) => return make_error("sasso: source is not valid UTF-8", 0, 0),
    };

    // Read the options version-tolerantly (defaults if NULL / for any field the
    // caller's `struct_size` doesn't cover); never reads past the caller's struct.
    let opts = read_options(options);
    let style = match opts.style {
        SASSO_STYLE_EXPANDED => OutputStyle::Expanded,
        SASSO_STYLE_COMPRESSED => OutputStyle::Compressed,
        other => return make_error(&format!("sasso: invalid style {other}"), 0, 0),
    };
    let syntax = match syntax_from_i32(opts.syntax) {
        Some(s) => s,
        None => return make_error(&format!("sasso: invalid syntax {}", opts.syntax), 0, 0),
    };
    let unicode = opts.unicode != 0;
    let url_owned: Option<String> = if opts.url.is_null() {
        None
    } else {
        match CStr::from_ptr(opts.url).to_str() {
            Ok(u) => Some(u.to_owned()),
            Err(_) => return make_error("sasso: url is not valid UTF-8", 0, 0),
        }
    };
    let mut load_paths: Vec<PathBuf> = Vec::new();
    if !opts.load_paths.is_null() && opts.load_paths_len > 0 {
        let arr = slice::from_raw_parts(opts.load_paths, opts.load_paths_len);
        for &p in arr {
            if p.is_null() {
                continue;
            }
            match CStr::from_ptr(p).to_str() {
                Ok(s) => load_paths.push(PathBuf::from(s)),
                Err(_) => return make_error("sasso: a load path is not valid UTF-8", 0, 0),
            }
        }
    }

    let mut o = Options::new()
        .with_style(style)
        .with_syntax(syntax)
        .with_unicode(unicode);
    if let Some(u) = &url_owned {
        o = o.with_url(u);
    }
    // A custom importer (if supplied) wins over `load_paths`/`FsImporter`. Both
    // bridge objects must outlive the `compile` borrow, so bind them here.
    let fs;
    let ffi_imp;
    if !opts.importer.is_null() {
        ffi_imp = FfiImporter { inner: opts.importer };
        o = o.with_importer(&ffi_imp);
    } else if !load_paths.is_empty() {
        fs = FsImporter::new(load_paths);
        o = o.with_importer(&fs);
    }

    match compile(src, &o) {
        Ok(css) => make_success(css),
        Err(e) => make_error(&e.to_string(), saturate_u32(e.line), saturate_u32(e.col)),
    }
}

/// Decode a `SASSO_SYNTAX_*` integer to a core [`Syntax`], or `None` for an
/// out-of-range value. Single source of truth shared by `sasso_compile` and the
/// importer's `sasso_importer_set_result`, so both treat a bad value identically.
fn syntax_from_i32(v: i32) -> Option<Syntax> {
    match v {
        SASSO_SYNTAX_SCSS => Some(Syntax::Scss),
        SASSO_SYNTAX_SASS => Some(Syntax::Sass),
        SASSO_SYNTAX_CSS => Some(Syntax::Css),
        _ => None,
    }
}

/// Narrow a core `usize` line/column to the ABI's `u32`, saturating instead of
/// wrapping. Truncation needs a >4-billion-line/column source (>4 GiB), so this
/// is defensive only — but a silent wraparound would report a wrong small
/// position, whereas saturating keeps it unmistakably large.
fn saturate_u32(v: usize) -> u32 {
    u32::try_from(v).unwrap_or(u32::MAX)
}

/// Box a success result, moving `css` into an owned C string.
fn make_success(css: String) -> *mut SassoResult {
    let len = css.len();
    let css_c = match CString::new(css) {
        Ok(c) => c.into_raw(),
        Err(_) => return make_error("sasso: output contained an interior NUL byte", 0, 0),
    };
    Box::into_raw(Box::new(SassoResult {
        ok: 1,
        css: css_c,
        css_len: len,
        error: ptr::null_mut(),
        error_len: 0,
        error_line: 0,
        error_column: 0,
    }))
}

/// Box an error result. A message with an interior NUL (not expected from
/// sasso) falls back to a fixed string so a result is always produced.
fn make_error(message: &str, line: u32, col: u32) -> *mut SassoResult {
    let (err_c, len) = match CString::new(message) {
        Ok(c) => (c.into_raw(), message.len()),
        Err(_) => {
            let fallback = "sasso: error (message contained an interior NUL byte)";
            (CString::new(fallback).unwrap().into_raw(), fallback.len())
        }
    };
    Box::into_raw(Box::new(SassoResult {
        ok: 0,
        css: ptr::null_mut(),
        css_len: 0,
        error: err_c,
        error_len: len,
        error_line: line,
        error_column: col,
    }))
}
