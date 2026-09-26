//! Minimal raw-cdylib wasm export wrapper around [`sasso::compile`].
//!
//! No wasm-bindgen: the ABI is a hand-rolled `alloc` / `free` / `compile` set
//! so the module stays tiny and dependency-free. The JS loader
//! (`npm/_loader.mjs`) marshals UTF-8 in and out of linear memory by hand.
//!
//! Protocol: JS calls `sasso_alloc(len)` for a buffer, writes the SCSS bytes,
//! then calls `sasso_compile3(...)` (`sasso_compile2` where an older module
//! does not export it). That returns a pointer to a UTF-8 result
//! (the CSS — or, with `want_map`, a framed `[cssLen u32][css][sourceMap json]`
//! — on success, or the error message on failure); the byte length is written
//! to `*out_len_ptr` and a `1`/`0` ok flag to `*ok_ptr`. JS reads the bytes,
//! then frees the input, the result, and any scratch with `sasso_free`.
//!
//! Importers (`@use`/`@forward`/`@import`) are resolved by calling back into the
//! host: when `use_importer != 0`, [`HostImporter`] bridges the core two-phase
//! [`sasso::Importer`] trait to the imported `host_canonicalize` / `host_load`
//! functions (wasm has no filesystem, so all file access lives in JS). This is
//! the wasm analogue of the C-ABI `FfiImporter` in `../../ffi/src/lib.rs`.

// These are FFI entry points: they dereference raw pointers by contract (the
// JS loader in npm/_loader.mjs upholds the invariants documented per function).
// Keeping the C ABI signatures pointer-typed (not `unsafe fn`) is intentional.
#![allow(clippy::not_unsafe_ptr_arg_deref)]

use std::alloc::{alloc, dealloc, Layout};

use sasso::{
    CanonicalUrl, CanonicalizeContext, DependencySet, Importer, ImporterError, ImporterResult, Options,
    OutputStyle, Syntax,
};

// Install sasso's scoped bump arena as the wasm global allocator. Every
// allocation inside a `compile()` scope becomes a pointer bump from a single
// pre-grown region that is reset (not freed) when the compile ends. The FFI
// buffers (sasso_alloc / the boxed result) allocated OUTSIDE any scope route to
// the system allocator and outlive the reset. Buffers the host allocates DURING
// a compile (importer results — see `take_host_bytes`) come from the arena and
// are reclaimed at scope reset; freeing them mid-compile is a no-op there and a
// real free if the arena was disabled/spilled, so we always free them.
#[global_allocator]
static GLOBAL: sasso::ScopedAlloc = sasso::ScopedAlloc;

/// Override the bump arena's reservation size, in **bytes**, before the first
/// compile. `0` disables the arena (every allocation forwards to the system
/// allocator: lower memory, slower). The region is reserved on the first
/// compile and then fixed, so this is a no-op once compilation started. The
/// compile-time default is 32 MiB (or `SASSO_WASM_ARENA_MB` at build time).
#[no_mangle]
pub extern "C" fn sasso_set_arena_bytes(bytes: usize) {
    sasso::set_arena_bytes(bytes);
}

/// Allocate `len` bytes in linear memory (align 1, for UTF-8 byte buffers).
///
/// Returns null for `len == 0`. Free with [`sasso_free`].
#[no_mangle]
pub extern "C" fn sasso_alloc(len: usize) -> *mut u8 {
    if len == 0 {
        return std::ptr::null_mut();
    }
    match Layout::from_size_align(len, 1) {
        // SAFETY: len > 0, so the layout is non-zero-sized.
        Ok(layout) => unsafe { alloc(layout) },
        Err(_) => std::ptr::null_mut(),
    }
}

/// Free a buffer returned by [`sasso_alloc`] or [`sasso_compile3`].
///
/// `(ptr, len)` must be exactly a pair previously handed to JS by this module.
#[no_mangle]
pub extern "C" fn sasso_free(ptr: *mut u8, len: usize) {
    if ptr.is_null() || len == 0 {
        return;
    }
    if let Ok(layout) = Layout::from_size_align(len, 1) {
        // SAFETY: the caller passes back a (ptr, len) pair this module
        // allocated with the matching align-1 layout.
        unsafe { dealloc(ptr, layout) };
    }
}

// --- Host importer bridge -------------------------------------------------

// Functions the host (JS) supplies in the wasm import object under the module
// name `sasso_host`. Each returns a tri-state:
//   1  = handled (the `out` cells point at a `sasso_alloc`-owned result buffer),
//   0  = not handled by this importer (a plain miss),
//   <0 = handled but failed (the `out` cells point at a UTF-8 error message).
// On `0` the host leaves `*out_ptr` null. The host allocates result buffers via
// `sasso_alloc`; this module copies them out and frees them (`take_host_bytes`).
#[link(wasm_import_module = "sasso_host")]
extern "C" {
    /// Map `url` (with the `from_import` flag and optional containing URL) to a
    /// canonical URL. On success the `out` buffer is FRAMED: one byte that is
    /// `1` when the host resolved this load through a load path or a custom
    /// importer (dart's "dependency", what `quiet_deps` silences) and `0`
    /// otherwise, then the canonical URL's UTF-8. The host owns that rule
    /// because the host does the resolving.
    fn host_canonicalize(
        url_ptr: *const u8,
        url_len: usize,
        from_import: u32,
        containing_ptr: *const u8,
        containing_len: usize,
        out_ptr: *mut *mut u8,
        out_len: *mut usize,
    ) -> i32;

    /// Load a canonical URL previously returned by `host_canonicalize`. On
    /// success the `out` buffer is a framed load result (see `parse_load_frame`):
    /// `[syntax: u8][smu_present: u8][smu_len: u32 LE][smu bytes][contents bytes]`.
    fn host_load(canon_ptr: *const u8, canon_len: usize, out_ptr: *mut *mut u8, out_len: *mut usize) -> i32;

    /// Invoke the host's custom function `index` (registered via
    /// `sasso_register_function`) with the serialized arguments. Returns `1` on
    /// success (the `out` buffer is the serialized return value) or `<0` on
    /// error (the `out` buffer is a UTF-8 message). With the asyncify'd module
    /// this may suspend the compile while the host awaits an async function.
    fn host_call_function(
        index: u32,
        args_ptr: *const u8,
        args_len: usize,
        out_ptr: *mut *mut u8,
        out_len: *mut usize,
    ) -> i32;

    /// Deliver a `@warn` / `@debug` / deprecation diagnostic to the host's logger
    /// (dart-sass `logger`). `buf` is
    /// `[kind: u8 (0 warn, 1 debug)][deprecation: u8][line: u32 LE]` followed by
    /// four `[u32 LE len][UTF-8]` strings: deprecation id, url, raw message, and
    /// the full formatted block. Never fails the compile.
    fn host_warn(buf_ptr: *const u8, buf_len: usize);
}

// Custom-function signatures the host registers before a compile (cleared
// after). `sasso_compile3` turns each into an `Options::with_function` whose
// callback bridges to `host_call_function` by index.
thread_local! {
    static FUNCTIONS: std::cell::RefCell<Vec<String>> = const { std::cell::RefCell::new(Vec::new()) };
}

/// Register a custom-function signature (`"pow($base, $exponent)"`); returns its
/// index, which the callback passes to `host_call_function`. Call before
/// `sasso_compile3`; pair with `sasso_clear_functions`.
#[no_mangle]
pub extern "C" fn sasso_register_function(sig_ptr: *const u8, sig_len: usize) -> u32 {
    let sig = if sig_ptr.is_null() || sig_len == 0 {
        String::new()
    } else {
        // SAFETY: JS passes a live UTF-8 buffer it just allocated.
        String::from_utf8_lossy(unsafe { std::slice::from_raw_parts(sig_ptr, sig_len) }).into_owned()
    };
    FUNCTIONS.with(|f| {
        let mut v = f.borrow_mut();
        v.push(sig);
        (v.len() - 1) as u32
    })
}

/// Drop all registered custom-function signatures.
#[no_mangle]
pub extern "C" fn sasso_clear_functions() {
    FUNCTIONS.with(|f| f.borrow_mut().clear());
}

/// Build the byte-protocol callback for custom function `index`, bridging to the
/// host's `host_call_function`.
fn make_host_callback(index: u32) -> sasso::HostFunction {
    std::rc::Rc::new(move |args: &[u8]| -> Result<Vec<u8>, String> {
        let mut out_ptr: *mut u8 = std::ptr::null_mut();
        let mut out_len: usize = 0;
        // SAFETY: `args` is a live slice; the host writes the result (ptr, len)
        // into the two out cells.
        let rc = unsafe { host_call_function(index, args.as_ptr(), args.len(), &mut out_ptr, &mut out_len) };
        let bytes = take_host_bytes(out_ptr, out_len);
        match rc {
            1 => Ok(bytes),
            _ => Err(if bytes.is_empty() {
                format!("sasso: custom function #{index} failed")
            } else {
                String::from_utf8_lossy(&bytes).into_owned()
            }),
        }
    })
}

/// Frame a compile error for the host: `[line: u32 LE][col: u32 LE]` then three
/// `[u32 LE len][UTF-8]` strings — the source url, the raw `sassMessage`, and the
/// fully rendered diagnostic block. `line`/`col` are 1-based (0 when unknown);
/// `url` is the entry url (`""` when none). The JS side rebuilds an `Exception`
/// with `.sassMessage` + `.span` from this.
fn frame_error(line: u32, col: u32, url: &str, message: &str, rendered: &str) -> Vec<u8> {
    fn put_str(buf: &mut Vec<u8>, s: &str) {
        buf.extend_from_slice(&(s.len() as u32).to_le_bytes());
        buf.extend_from_slice(s.as_bytes());
    }
    let mut buf = Vec::new();
    buf.extend_from_slice(&line.to_le_bytes());
    buf.extend_from_slice(&col.to_le_bytes());
    put_str(&mut buf, url);
    put_str(&mut buf, message);
    put_str(&mut buf, rendered);
    buf
}

/// Frame a [`sasso::Error`] (raw message + position + entry url + rendered block).
fn frame_sass_error(err: &sasso::Error, url: Option<&str>) -> Vec<u8> {
    frame_error(
        err.line as u32,
        err.col as u32,
        url.unwrap_or(""),
        &err.message,
        &err.to_string(),
    )
}

/// Build the diagnostic handler that forwards every `@warn`/`@debug`/deprecation
/// to the host's `host_warn` (see its wire format).
fn make_host_warn() -> sasso::WarnHandler {
    fn put_str(buf: &mut Vec<u8>, s: &str) {
        buf.extend_from_slice(&(s.len() as u32).to_le_bytes());
        buf.extend_from_slice(s.as_bytes());
    }
    std::rc::Rc::new(|ev: &sasso::WarnEvent<'_>| {
        let mut buf = Vec::new();
        buf.push(match ev.kind {
            sasso::WarnKind::Warn => 0u8,
            sasso::WarnKind::Debug => 1u8,
        });
        buf.push(ev.deprecation as u8);
        buf.extend_from_slice(&(ev.line as u32).to_le_bytes());
        put_str(&mut buf, ev.deprecation_id);
        put_str(&mut buf, ev.url);
        put_str(&mut buf, ev.message);
        put_str(&mut buf, ev.formatted);
        // SAFETY: `buf` is live for the call; the host copies it before returning.
        unsafe { host_warn(buf.as_ptr(), buf.len()) };
    })
}

/// Copy a host-delivered `(ptr, len)` buffer out to an owned `Vec`, then free
/// the original. Returns an empty `Vec` for a null/empty buffer.
fn take_host_bytes(ptr: *mut u8, len: usize) -> Vec<u8> {
    if ptr.is_null() || len == 0 {
        return Vec::new();
    }
    // SAFETY: the host wrote `len` readable bytes at `ptr` (a `sasso_alloc`
    // buffer) before returning; we copy them out immediately.
    let bytes = unsafe { std::slice::from_raw_parts(ptr, len) }.to_vec();
    sasso_free(ptr, len);
    bytes
}

/// Turn a tri-state host return code + the delivered bytes into an error
/// message string when the code signals failure.
fn host_error(bytes: Vec<u8>, what: &str) -> ImporterError {
    let message = if bytes.is_empty() {
        format!("sasso: importer {what} failed")
    } else {
        String::from_utf8_lossy(&bytes).into_owned()
    };
    ImporterError { message }
}

/// Parse a `host_load` success frame into an [`ImporterResult`].
fn parse_load_frame(bytes: &[u8]) -> Result<ImporterResult, ImporterError> {
    let bad = || ImporterError {
        message: "sasso: importer load returned a malformed result".to_string(),
    };
    if bytes.len() < 6 {
        return Err(bad());
    }
    let syntax = match bytes[0] {
        0 => Syntax::Scss,
        1 => Syntax::Sass,
        2 => Syntax::Css,
        _ => return Err(bad()),
    };
    let smu_present = bytes[1] != 0;
    let smu_len = u32::from_le_bytes([bytes[2], bytes[3], bytes[4], bytes[5]]) as usize;
    let smu_end = 6usize.checked_add(smu_len).ok_or_else(bad)?;
    if smu_end > bytes.len() {
        return Err(bad());
    }
    let source_map_url = if smu_present {
        Some(String::from_utf8_lossy(&bytes[6..smu_end]).into_owned())
    } else {
        None
    };
    let contents = String::from_utf8_lossy(&bytes[smu_end..]).into_owned();
    Ok(ImporterResult {
        contents,
        syntax,
        source_map_url,
    })
}

/// Bridges the core two-phase [`Importer`] trait to the host's
/// `host_canonicalize` / `host_load` import functions.
struct HostImporter {
    /// The loads the host flagged as dependencies (see `host_canonicalize`),
    /// handed to [`Options::with_quiet_deps`] when `quiet_deps` is on.
    deps: DependencySet,
}

impl Importer for HostImporter {
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        let (cptr, clen) = match ctx.containing_url {
            Some(c) => (c.as_str().as_ptr(), c.as_str().len()),
            None => (std::ptr::null(), 0),
        };
        let mut out_ptr: *mut u8 = std::ptr::null_mut();
        let mut out_len: usize = 0;
        // SAFETY: pointers/lengths describe live wasm-memory slices; the host
        // writes the result `(ptr, len)` into the two out cells.
        let rc = unsafe {
            host_canonicalize(
                url.as_ptr(),
                url.len(),
                ctx.from_import as u32,
                cptr,
                clen,
                &mut out_ptr,
                &mut out_len,
            )
        };
        let bytes = take_host_bytes(out_ptr, out_len);
        match rc {
            1 => {
                // [dependency: u8][canonical URL bytes] — see `host_canonicalize`.
                let dep = bytes.first().copied().unwrap_or(0) != 0;
                let url = String::from_utf8_lossy(bytes.get(1..).unwrap_or_default()).into_owned();
                if dep {
                    self.deps.mark(&url);
                }
                Ok(Some(CanonicalUrl::new(url)))
            }
            0 => Ok(None),
            _ => Err(host_error(bytes, "canonicalize")),
        }
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        let s = canonical.as_str();
        let mut out_ptr: *mut u8 = std::ptr::null_mut();
        let mut out_len: usize = 0;
        // SAFETY: as above; the host writes the framed result into the out cells.
        let rc = unsafe { host_load(s.as_ptr(), s.len(), &mut out_ptr, &mut out_len) };
        let bytes = take_host_bytes(out_ptr, out_len);
        match rc {
            1 => Ok(Some(parse_load_frame(&bytes)?)),
            0 => Ok(None),
            _ => Err(host_error(bytes, "load")),
        }
    }
}

// --- Compile entry point --------------------------------------------------

/// Compile the SCSS in `[input_ptr, input_ptr + input_len)` to CSS.
///
/// - `compressed != 0` selects compressed output.
/// - `syntax`: `0` SCSS, `1` indented `.sass`, `2` plain CSS.
/// - `use_importer != 0` installs [`HostImporter`], so `@use`/`@forward`/
///   `@import` call back into the host; `0` disables file imports.
/// - `(url_ptr, url_len)`: the entry's URL for diagnostics, source-map sources,
///   and as the base for the first level of relative imports (`0`/`0` = none).
/// - `quiet_deps != 0` drops deprecation warnings raised inside the stylesheets
///   the host flagged as dependencies (dart-sass `quietDeps`); a dependency's
///   own `@warn`/`@debug` still reaches the logger, as in dart.
/// - `(silenced_ptr, silenced_len)`: deprecation ids to drop, comma-separated
///   (`import,global-builtin`), `0`/`0` for none (dart-sass
///   `silenceDeprecations`). Dropped inside the compiler beside `quiet_deps`,
///   so a silenced id never reaches the per-id repetition cap either.
/// - `unicode == 0` renders diagnostics with the ASCII glyph set (`,`/`|`/`'`
///   instead of `╷`/`│`/`╵`), as dart-sass's `--no-unicode` does.
/// - `want_map != 0` also produces a Source Map v3 — the result buffer is then
///   FRAMED: a little-endian `u32` CSS byte length, the CSS bytes, then the
///   source-map JSON bytes. `include_sources != 0` embeds source text in the
///   map's `sourcesContent`.
///
/// Writes the result byte length to `*out_len_ptr` and `1` (ok) / `0` (error)
/// to `*ok_ptr`, and returns a pointer to the UTF-8 result (CSS / framed map on
/// success, error message on failure). Free it with `sasso_free(ptr, *out_len_ptr)`.
///
/// Each generation is a NEW entry point rather than more parameters on the old
/// one, so a host built against an older signature keeps linking, and the older
/// ones delegate here so there is a single body to keep correct.
/// `compile3` added `silenced_ptr`/`silenced_len`; `compile4` adds
/// `cwd_ptr`/`cwd_len`, because this target has no `getcwd` and a diagnostic
/// path has to be relative to something the host knows (#153).
#[no_mangle]
#[allow(clippy::too_many_arguments)]
pub extern "C" fn sasso_compile4(
    input_ptr: *const u8,
    input_len: usize,
    compressed: u8,
    syntax: u8,
    use_importer: u8,
    url_ptr: *const u8,
    url_len: usize,
    want_map: u8,
    include_sources: u8,
    charset: u8,
    quiet_deps: u8,
    unicode: u8,
    silenced_ptr: *const u8,
    silenced_len: usize,
    cwd_ptr: *const u8,
    cwd_len: usize,
    out_len_ptr: *mut usize,
    ok_ptr: *mut u8,
) -> *mut u8 {
    let input: &[u8] = if input_ptr.is_null() || input_len == 0 {
        &[]
    } else {
        // SAFETY: JS guarantees [input_ptr, input_len) is a live buffer it
        // just allocated via sasso_alloc and filled.
        unsafe { std::slice::from_raw_parts(input_ptr, input_len) }
    };
    let url: Option<&str> = if url_ptr.is_null() || url_len == 0 {
        None
    } else {
        // SAFETY: JS guarantees [url_ptr, url_len) is a live UTF-8 buffer.
        std::str::from_utf8(unsafe { std::slice::from_raw_parts(url_ptr, url_len) }).ok()
    };

    // SAFETY: the host wrote `silenced_len` bytes at `silenced_ptr`, as for
    // the url above. Invalid UTF-8 means "silence nothing" rather than an
    // error: the ids are a filter, and losing one only prints more.
    let silenced: &str = if silenced_ptr.is_null() || silenced_len == 0 {
        ""
    } else {
        std::str::from_utf8(unsafe { std::slice::from_raw_parts(silenced_ptr, silenced_len) }).unwrap_or("")
    };

    // There is no `getcwd` on this target, so the host says what diagnostic
    // paths are relative to. Empty means "nothing known", and a frame then
    // keeps the absolute path rather than guessing.
    //
    // SAFETY: the host wrote `cwd_len` bytes at `cwd_ptr`, as for the url.
    let cwd: &str = if cwd_ptr.is_null() || cwd_len == 0 {
        ""
    } else {
        std::str::from_utf8(unsafe { std::slice::from_raw_parts(cwd_ptr, cwd_len) }).unwrap_or("")
    };

    let syntax = match syntax {
        1 => Syntax::Sass,
        2 => Syntax::Css,
        _ => Syntax::Scss,
    };
    let importer = HostImporter {
        deps: DependencySet::default(),
    };

    let (bytes, ok): (Vec<u8>, u8) = match std::str::from_utf8(input) {
        Ok(scss) => {
            let mut opts = Options::default()
                .with_syntax(syntax)
                .with_source_map_include_sources(include_sources != 0)
                .with_charset(charset != 0)
                .with_unicode(unicode != 0);
            if compressed != 0 {
                opts = opts.with_style(OutputStyle::Compressed);
            }
            if let Some(u) = url {
                opts = opts.with_url(u);
            }
            if !cwd.is_empty() {
                opts = opts.with_cwd(cwd);
            }
            if use_importer != 0 {
                opts = opts.with_importer(&importer);
            }
            if quiet_deps != 0 {
                // The record fills in as the host resolves each load, and the
                // compiler consults it when a deprecation fires — so a file is
                // judged by how it was REACHED, not by where it sits.
                opts = opts.with_quiet_deps(importer.deps.clone());
            }
            if !silenced.is_empty() {
                // Dropped inside the compiler, like `quiet_deps`, so a
                // silenced deprecation never reaches the per-id cap and the
                // run cannot end by counting warnings the caller silenced.
                opts = opts.with_silenced_deprecations(silenced.split(','));
            }
            // Register host custom functions (each bridges to host_call_function).
            let sigs: Vec<String> = FUNCTIONS.with(|f| f.borrow().clone());
            for (i, sig) in sigs.iter().enumerate() {
                opts = opts.with_function(sig, make_host_callback(i as u32));
            }
            // Route @warn/@debug/deprecation diagnostics to the host's logger
            // (the JS side always supplies a default that prints to stderr).
            opts = opts.with_warn_handler(make_host_warn());
            if want_map != 0 {
                match sasso::compile_with_source_map(scss, &opts) {
                    Ok(result) => {
                        let css = result.css.into_bytes();
                        let map = result.source_map.to_json().into_bytes();
                        let mut framed = Vec::with_capacity(4 + css.len() + map.len());
                        framed.extend_from_slice(&(css.len() as u32).to_le_bytes());
                        framed.extend_from_slice(&css);
                        framed.extend_from_slice(&map);
                        (framed, 1)
                    }
                    Err(err) => (frame_sass_error(&err, url), 0),
                }
            } else {
                match sasso::compile(scss, &opts) {
                    Ok(css) => (css.into_bytes(), 1),
                    Err(err) => (frame_sass_error(&err, url), 0),
                }
            }
        }
        Err(_) => (
            frame_error(
                0,
                0,
                "",
                "input is not valid UTF-8",
                "Error: input is not valid UTF-8",
            ),
            0,
        ),
    };

    into_result(bytes, ok, out_len_ptr, ok_ptr)
}

/// The pre-`cwd` entry point, kept so a host built against it still links.
/// Delegates with no working directory, which is what it always had.
#[no_mangle]
#[allow(clippy::too_many_arguments)]
pub extern "C" fn sasso_compile3(
    input_ptr: *const u8,
    input_len: usize,
    compressed: u8,
    syntax: u8,
    use_importer: u8,
    url_ptr: *const u8,
    url_len: usize,
    want_map: u8,
    include_sources: u8,
    charset: u8,
    quiet_deps: u8,
    unicode: u8,
    silenced_ptr: *const u8,
    silenced_len: usize,
    out_len_ptr: *mut usize,
    ok_ptr: *mut u8,
) -> *mut u8 {
    sasso_compile4(
        input_ptr,
        input_len,
        compressed,
        syntax,
        use_importer,
        url_ptr,
        url_len,
        want_map,
        include_sources,
        charset,
        quiet_deps,
        unicode,
        silenced_ptr,
        silenced_len,
        std::ptr::null(),
        0,
        out_len_ptr,
        ok_ptr,
    )
}

/// The pre-`silenceDeprecations` entry point, kept so a host built against it
/// still links. Delegates with an empty id list.
#[no_mangle]
#[allow(clippy::too_many_arguments)]
pub extern "C" fn sasso_compile2(
    input_ptr: *const u8,
    input_len: usize,
    compressed: u8,
    syntax: u8,
    use_importer: u8,
    url_ptr: *const u8,
    url_len: usize,
    want_map: u8,
    include_sources: u8,
    charset: u8,
    quiet_deps: u8,
    unicode: u8,
    out_len_ptr: *mut usize,
    ok_ptr: *mut u8,
) -> *mut u8 {
    sasso_compile3(
        input_ptr,
        input_len,
        compressed,
        syntax,
        use_importer,
        url_ptr,
        url_len,
        want_map,
        include_sources,
        charset,
        quiet_deps,
        unicode,
        std::ptr::null(),
        0,
        out_len_ptr,
        ok_ptr,
    )
}

/// Run an engine-routed `Value` method (e.g. `SassNumber.convert`,
/// `SassColor.toSpace`) — forwards to [`sasso::host_value_op`]. `in` is the
/// serialized operands; the result is returned like `sasso_compile3` (a pointer
/// plus `*out_len_ptr`/`*ok_ptr`): on `ok` the buffer is the serialized result
/// value, otherwise a UTF-8 error message. This is independent of any in-flight
/// compile, so JS `Value` methods work standalone and re-entrantly.
#[no_mangle]
pub extern "C" fn sasso_value_op(
    op: u32,
    in_ptr: *const u8,
    in_len: usize,
    out_len_ptr: *mut usize,
    ok_ptr: *mut u8,
) -> *mut u8 {
    let input: &[u8] = if in_ptr.is_null() || in_len == 0 {
        &[]
    } else {
        // SAFETY: JS guarantees [in_ptr, in_len) is a live buffer it allocated.
        unsafe { std::slice::from_raw_parts(in_ptr, in_len) }
    };
    let (bytes, ok) = match sasso::host_value_op(op, input) {
        Ok(b) => (b, 1u8),
        Err(e) => (e.into_bytes(), 0u8),
    };
    into_result(bytes, ok, out_len_ptr, ok_ptr)
}

/// Box a result buffer, write its length + ok flag to the scratch cells, and
/// return a pointer JS frees with `sasso_free(ptr, *out_len_ptr)`.
fn into_result(bytes: Vec<u8>, ok: u8, out_len_ptr: *mut usize, ok_ptr: *mut u8) -> *mut u8 {
    let len = bytes.len();
    let mut boxed = bytes.into_boxed_slice();
    let ptr = boxed.as_mut_ptr();
    std::mem::forget(boxed);
    // SAFETY: out_len_ptr / ok_ptr are valid 4-byte / 1-byte scratch cells
    // that JS allocated before the call.
    unsafe {
        *out_len_ptr = len;
        *ok_ptr = ok;
    }
    ptr
}
