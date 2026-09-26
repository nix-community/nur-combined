/* sasso.h — C ABI for the sasso pure-Rust SCSS -> CSS compiler.
 *
 * One ABI, many languages: load the prebuilt `libsasso.{so,dylib}` from PHP
 * FFI, Python ctypes/cffi, Ruby Fiddle, Go cgo, LuaJIT, etc.
 *
 * Ownership & safety contract:
 *   - Source is a UTF-8 (pointer, length) buffer; it need NOT be
 *     NUL-terminated. Host paths (`url`, `load_paths`) ARE NUL-terminated.
 *   - A SassoResult* returned by sasso_compile() is owned by sasso; release it
 *     (and its css/error strings) with sasso_result_free(). Never free the
 *     css/error pointers with your own free().
 *   - The css/error strings are NUL-terminated AND carry an explicit byte
 *     length (css_len/error_len) so binary-safe callers can avoid strlen().
 *   - Every entry point is panic-safe: an internal Rust panic becomes an error
 *     result rather than crossing the C boundary.
 *   - Thread-safety: independent sasso_compile() calls are self-contained and
 *     may run concurrently on separate threads. A SassoImporterSink is valid
 *     ONLY during the one callback it is passed to — never store it, use it
 *     after the callback returns, or touch it from another thread. Do not call
 *     sasso_compile() re-entrantly from inside an importer callback.
 *   - Forward-compat: SassoOptions grows by APPENDING fields only (the leading
 *     struct_size lets older callers stay compatible — the library copies just
 *     min(your struct_size, its own) bytes); existing fields are never reordered
 *     or resized.
 *
 * This header is curated to match the ABI exactly; it can also be regenerated
 * with `cbindgen` (see cbindgen.toml).
 */
#ifndef SASSO_H
#define SASSO_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* SassoOptions.style */
#define SASSO_STYLE_EXPANDED   0
#define SASSO_STYLE_COMPRESSED 1

/* SassoOptions.syntax */
#define SASSO_SYNTAX_SCSS 0
#define SASSO_SYNTAX_SASS 1
#define SASSO_SYNTAX_CSS  2

/* SassoImporter callback return codes. Effect on the overall compile:
 *   SASSO_IMPORTER_ERROR     -> the message you passed to sasso_importer_set_error
 *                               becomes the compile error and ABORTS the compile.
 *   SASSO_IMPORTER_NOT_FOUND -> this importer can't resolve the URL; with a single
 *                               importer (no fallback chain) the load is unresolved
 *                               and the compile fails with a "can't find stylesheet"
 *                               error. */
#define SASSO_IMPORTER_OK         1   /* handled: host called set_canonical / set_result */
#define SASSO_IMPORTER_NOT_FOUND  0   /* this importer doesn't handle the URL */
#define SASSO_IMPORTER_ERROR    (-1)  /* handled but failed: host called set_error */

/* Context passed to a canonicalize() callback. */
typedef struct SassoCanonicalizeContext {
  /* Non-zero when resolving a legacy @import (vs @use/@forward). */
  int32_t from_import;
  /* Canonical URL of the importing file (NUL-terminated UTF-8), or NULL at entry. */
  const char *containing_url;
} SassoCanonicalizeContext;

/* Opaque, sasso-owned collector handed to an importer callback. Deliver your
 * result by calling one sasso_importer_set_*() with it; the bytes are COPIED
 * immediately — this is SQLite's SQLITE_TRANSIENT convention, so you keep and
 * free your own buffers and there is deliberately NO free callback (a string
 * made inside a ctypes/PHP-FFI/managed callback isn't C-malloc'd, so a foreign
 * free would be undefined). Valid ONLY for the duration of the one callback it
 * was passed to. */
typedef struct SassoImporterSink SassoImporterSink;

/* A userland importer (set SassoOptions.importer to use it). Two dart-sass-style
 * phases: canonicalize() resolves a (possibly relative, extension-less) URL to a
 * stable key WITHOUT loading; load() then fetches that key's source. Each returns
 * a SASSO_IMPORTER_* code. */
typedef struct SassoImporter {
  /* Passed verbatim as the first argument of each callback. */
  void *user_data;
  /* Resolve `url` to its canonical key. On SASSO_IMPORTER_OK, first call
   * sasso_importer_set_canonical(); on SASSO_IMPORTER_ERROR, sasso_importer_set_error();
   * SASSO_IMPORTER_NOT_FOUND delivers nothing. NULL = resolution fails. */
  int32_t (*canonicalize)(void *user_data, const char *url,
                          const SassoCanonicalizeContext *ctx,
                          SassoImporterSink *sink);
  /* Load `canonical`'s source. On SASSO_IMPORTER_OK, first call
   * sasso_importer_set_result(). NULL = loading fails. */
  int32_t (*load)(void *user_data, const char *canonical, SassoImporterSink *sink);
} SassoImporter;

/* Compile options. Pass NULL to sasso_compile() for all-defaults, or fill one
 * with sasso_options_init() (which sets struct_size) and override fields. */
typedef struct SassoOptions {
  /* sizeof(SassoOptions) as the caller sees it (forward-compat anchor). */
  uint32_t struct_size;
  /* One of SASSO_STYLE_*. Default SASSO_STYLE_EXPANDED. */
  int32_t style;
  /* One of SASSO_SYNTAX_*. Default SASSO_SYNTAX_SCSS. */
  int32_t syntax;
  /* Non-zero = Unicode diagnostic glyphs; 0 = ASCII. Default non-zero. */
  int32_t unicode;
  /* Optional NUL-terminated UTF-8 display path (enables error snippets), or NULL. */
  const char *url;
  /* Optional array of NUL-terminated UTF-8 load paths, or NULL. */
  const char *const *load_paths;
  /* Number of entries in load_paths. */
  size_t load_paths_len;
  /* Optional custom importer for @use/@forward/@import; NULL = built-in
   * filesystem importer (load_paths). A non-NULL importer takes precedence over
   * load_paths, and must stay valid for the duration of the sasso_compile() call. */
  const SassoImporter *importer;
} SassoOptions;

/* Result of a compile. Allocated by sasso_compile(); free with
 * sasso_result_free(). */
typedef struct SassoResult {
  /* 1 = success (css set), 0 = failure (error set). */
  int32_t ok;
  /* NUL-terminated UTF-8 CSS on success, else NULL. Owned by sasso. */
  char *css;
  /* Byte length of css (excluding NUL), or 0. */
  size_t css_len;
  /* NUL-terminated UTF-8 diagnostic on failure, else NULL. Owned by sasso. */
  char *error;
  /* Byte length of error (excluding NUL), or 0. */
  size_t error_len;
  /* 1-based error line, or 0 if unknown. */
  uint32_t error_line;
  /* 1-based error column, or 0 if unknown. */
  uint32_t error_column;
} SassoResult;

/* Bundled compiler version as a static NUL-terminated string. Do NOT free. */
const char *sasso_version(void);

/* Fill *options with defaults and set struct_size to the caller's
 * sizeof(SassoOptions). Only that many bytes are written, so an older/smaller
 * caller is never written past — pass sizeof(SassoOptions). No-op if NULL. */
void sasso_options_init(SassoOptions *options, size_t struct_size);

/* Compile a UTF-8 source buffer (source_len bytes) to CSS. Returns a heap
 * SassoResult* the caller must release with sasso_result_free(). options may be
 * NULL for defaults. */
SassoResult *sasso_compile(const char *source, size_t source_len,
                           const SassoOptions *options);

/* Release a SassoResult* from sasso_compile() (and its css/error). NULL-safe. */
void sasso_result_free(SassoResult *result);

/* Deliver the canonical URL from a canonicalize() callback (copied immediately).
 * Call once, then return SASSO_IMPORTER_OK. NULL sink / invalid UTF-8 is ignored. */
void sasso_importer_set_canonical(SassoImporterSink *sink, const char *ptr, size_t len);

/* Deliver the loaded stylesheet from a load() callback (copied immediately).
 * syntax is SASSO_SYNTAX_* (an unknown value falls back to SCSS); source_map_url
 * may be NULL. Call once, then return SASSO_IMPORTER_OK. */
void sasso_importer_set_result(SassoImporterSink *sink,
                               const char *contents, size_t contents_len,
                               int32_t syntax,
                               const char *source_map_url, size_t source_map_url_len);

/* Deliver an error message from either callback (copied immediately). Call, then
 * return SASSO_IMPORTER_ERROR. A NULL/invalid message still marks the failure. */
void sasso_importer_set_error(SassoImporterSink *sink, const char *ptr, size_t len);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* SASSO_H */
