# RFC: a dart-faithful `Importer` API (before we freeze it in the FFI)

Status: **implemented.** The core trait shipped in **sasso 0.6.0** (PR #7); the
FFI v2 importer callback this RFC was written to de-risk is implemented in
**PR #5** (the C ABI). Kept as the design record — the trait below is what
shipped; the *FFI v2 mapping* section has been updated to the **as-built** ABI,
which deliberately diverged from the original sketch (see that section).
*"Stable API, then work on how to expose"* — done in that order. (Raised by
@shyim in #4.)

**Decision (per #6, w/ @shyim):** the project is early-stage / pre-1.0 with only
a handful of known, in-house importer implementors, so this is a **clean break**
— replace the old `resolve_*` trait outright and update the implementors in
lockstep. **No backward-compat shim** (a shim would just re-create the lossy old
model we're removing).

## Why

dart-sass's importer is a two-phase interface returning a rich result:

- [`Importer.canonicalize(Uri url)` → `Uri?`](https://pub.dev/documentation/sass/latest/sass/Importer/canonicalize.html)
  — maps a (possibly relative, extension-less) URL to a **canonical identity**,
  *without loading*. The canonical URL is the module-cache key, so the same file
  reached via different spellings is evaluated once.
- [`Importer.load(Uri canonicalUrl)` → `ImporterResult?`](https://pub.dev/documentation/sass/latest/sass/Importer/load.html)
  — fetches the source for a canonical URL.
- [`ImporterResult`](https://pub.dev/documentation/sass/latest/sass/ImporterResult-class.html)
  carries `contents` **plus `syntax` plus `sourceMapUrl`** — not just a string.

## Where sasso is today

The public surface most bindings see (`Importer::resolve(path) -> Option<String>`,
and what the PHP ext / FFI expose) is a **lossy subset**: one string in, one
string out. But the core trait already grew, ad-hoc, most of what dart needs —
just not in dart's shape:

| Capability | dart | sasso core today | exposed in bindings? |
| --- | --- | --- | --- |
| canonical-key dedup (`@use` once) | `canonicalize` | ✅ `resolve_module*` (key, src) | ❌ only `resolve` |
| per-file syntax (`.sass` from `.scss`) | `ImporterResult.syntax` | ✅ `resolve_with_syntax` | ❌ |
| relative-to-containing-file | canonicalize ctx | ✅ `resolve_*_in(base_dir)` | ❌ |
| resolved key + per-file base dir | canonical Uri | ◑ `resolve_import_with_path` — feeds the import cache + `current_file_dir`; `@import` does NOT switch `current_url`/`current_source` to the imported file the way `@use` does, so per-import diagnostic context isn't wired | ❌ |
| **source-map URL of a loaded file** | `ImporterResult.sourceMapUrl` | ❌ **missing** | ❌ |
| **clean canonicalize / load split** | two methods | ❌ accreted `resolve_*` overloads | ❌ |
| `@import` vs `@use` context (import-only files) | `fromImport` | partial (`resolve_import_*` vs `resolve_module_*`) | ❌ |

So the work is **consolidate + complete**, not build-from-zero: fold the
`resolve_*` overload soup into dart's two-phase shape, add `sourceMapUrl`, and
expose *that* (not the lossy `resolve`) to the gem / PHP ext / FFI.

(Wiring confirmed: `@use`/`@forward` → `resolve_module_with_syntax_in`,
`@import` → `resolve_import_with_path`, `FsImporter` dedups via
`std::fs::canonicalize`.)

## Proposed trait

```rust
/// The canonical, absolute identity of a stylesheet (dart's canonical `Uri`).
/// Two import URLs that canonicalize to the same `CanonicalUrl` are the same
/// stylesheet — loaded and evaluated once, shared by every `@use`/`@forward`.
///
/// Opaque newtype: what "canonical" *means* is the importer's to define (any
/// scheme it likes) and sasso only uses it as an `Eq`/`Hash` key — but keeping
/// the field private lets us add normalization/constraints later without an API
/// break.
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub struct CanonicalUrl(String);

impl CanonicalUrl {
    pub fn new(url: impl Into<String>) -> Self {
        Self(url.into())
    }
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

/// What `Importer::load` returns — dart's `ImporterResult`.
pub struct ImporterResult {
    /// The stylesheet source.
    pub contents: String,
    /// Syntax to parse `contents` with (SCSS / indented `.sass` / plain CSS).
    pub syntax: Syntax,
    /// URL to record for this source in generated source maps
    /// (dart `ImporterResult.sourceMapUrl`); `None` ⇒ use the canonical URL.
    pub source_map_url: Option<String>,
}

/// Context for `canonicalize` (dart `CanonicalizeContext`).
pub struct CanonicalizeContext<'a> {
    /// True for `@import` (which also considers import-only files —
    /// `*.import.scss` / `*.import.sass`, plus their `_partial` and index
    /// variants), false for `@use`/`@forward`.
    pub from_import: bool,
    /// Canonical URL of the stylesheet doing the importing, if any — relative
    /// URLs resolve against it first.
    pub containing_url: Option<&'a CanonicalUrl>,
}

/// An importer failure that is NOT a plain miss — an I/O error, a permission
/// error, an ambiguous match (dart: "It's not clear which … to import"), an
/// invalid URL, etc. Surfaced as an actionable compile error, not silently
/// treated as "not found". (Concrete shape TBD — see open questions.)
pub struct ImporterError {
    pub message: String,
}

/// Resolves `@use` / `@forward` / `@import` URLs in dart's two phases.
///
/// Both methods distinguish THREE outcomes (dart's `Uri?` + the ability to
/// throw): `Ok(Some(_))` = handled, here it is; `Ok(None)` = this importer
/// doesn't handle the URL (try the next / fall through to "not found");
/// `Err(_)` = this importer OWNS the URL but failed — a real, reportable error.
pub trait Importer {
    /// Map `url` to its canonical identity. MUST NOT load the file. The returned
    /// `CanonicalUrl` is the module-cache key. `Ok(None)` = not handled;
    /// `Err` = handled but failed (e.g. ambiguous match).
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError>;

    /// Load the source for a `CanonicalUrl` previously returned by
    /// `canonicalize`. `Ok(None)` = vanished; `Err` = found but unreadable.
    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError>;
}
```

## No back-compat shim (clean break)

Per #6 this replaces the old `resolve_*` trait outright — no `LegacyResolver`
adapter, no deprecation window. Keeping a one-method-resolver shim would re-admit
the lossy model this redesign removes, and pre-1.0 with a known implementor set
makes a coordinated break cheap. `FsImporter` implements the new trait
*natively* (it already canonicalizes via `std::fs::canonicalize` and infers
syntax from the extension); the gem / PHP ext are updated to the two-phase trait
in the same change.

## Migration (each step independently shippable, parity-gated)

1. ✅ **Core — shipped (0.6.0 / PR #7).** Added the trait + `ImporterResult` +
   `CanonicalUrl`; made `FsImporter` native; routed `eval` through
   `canonicalize`/`load`; **deleted the old `resolve_*` overloads** (no shim);
   added parity tests for import syntax, `@use` dedup, and `source_map_url`.
   Verified byte-for-byte (ratchet delta +0).
2. ◑ **Bindings.** The Ruby gem is `FsImporter`-only — recompile-only against
   0.6.0, it exposes no userland importer, so nothing changed there. php-sasso's
   `resolve` bridge still needs migrating (shyim's repo; tracked in #4).
3. ✅ **FFI v2 (#5) — implemented.** The two phases are exposed as C function
   pointers + a sink-based result. The shipped shape **differs** from the sketch
   that was here — see "FFI v2 mapping (as implemented)" below.

## FFI v2 mapping (as implemented, PR #5)

The shipped C ABI **diverged from the original sketch in two ways, both for
soundness** (the ownership/re-entrancy rules were exactly the delicate part the
RFC flagged):

1. **No `free_fn`, no host-owned out-pointers** (the sketch's "heap string the
   caller frees via a provided fn" model is unsound). A callback never hands
   sasso an owned `char*`. Instead the host calls a sasso-provided **setter**
   with an opaque sink; sasso **copies the bytes immediately** and the host frees
   its own memory. This avoids cross-allocator `free` — a string produced inside
   a ctypes / PHP-FFI callback is owned by the host runtime, not C `malloc`, so a
   C `free()` on it is UB (and ctypes often has no matching free to hand back) —
   and the dangling-after-return hazard. Each setter is wrapped in its own
   `catch_unwind` because it runs *inside* the host's C callback frame.
2. **Inputs are NUL-terminated; only the sink delivery carries `(ptr, len)`.**
   The `url` / `canonical` / `containing_url` passed *into* the callbacks are
   NUL-terminated C strings (cheap for hosts to read); the values handed *back*
   via the setters take an explicit length.

```c
typedef struct SassoCanonicalizeContext {
  int32_t from_import;          /* non-zero for a legacy @import */
  const char *containing_url;   /* NUL-term canonical URL of the importer, or NULL at entry */
} SassoCanonicalizeContext;

/* Opaque, sasso-owned; valid ONLY for the duration of the one callback. */
typedef struct SassoImporterSink SassoImporterSink;

/* Tri-state return mirroring Result<Option<_>, _>. */
#define SASSO_IMPORTER_OK         1   /* handled: host called a set_* */
#define SASSO_IMPORTER_NOT_FOUND  0   /* this importer doesn't handle the URL */
#define SASSO_IMPORTER_ERROR    (-1)  /* handled but failed: host called set_error */

typedef struct SassoImporter {
  void *user_data;
  int32_t (*canonicalize)(void *user_data, const char *url,
                          const SassoCanonicalizeContext *ctx, SassoImporterSink *sink);
  int32_t (*load)(void *user_data, const char *canonical, SassoImporterSink *sink);
} SassoImporter;

/* Called by the host FROM INSIDE its callback; each copies immediately. */
void sasso_importer_set_canonical(SassoImporterSink *sink, const char *ptr, size_t len);
void sasso_importer_set_result(SassoImporterSink *sink,
                               const char *contents, size_t contents_len,
                               int32_t syntax,            /* SASSO_SYNTAX_* */
                               const char *source_map_url, size_t source_map_url_len /* NULL,0 = none */);
void sasso_importer_set_error(SassoImporterSink *sink, const char *ptr, size_t len);
```

A custom importer is attached via a new trailing `SassoOptions.importer` field
(gated by the existing `struct_size` forward-compat scheme; a non-NULL importer
takes precedence over `load_paths`). Validated end-to-end against the prebuilt
library across **8 languages** — `ffi/examples/{c,go,ruby,swift,deno,bun,luajit,csharp}/`.
See [`../ffi/include/sasso.h`](../ffi/include/sasso.h) for the authoritative header.

## Design questions (all resolved)

These were the open questions raised for discussion with @shyim; all are now settled.

1. **Ergonomics for trivial importers.** ✅ **Resolved: add on demand.** dart eases
   filesystem-like importers with a simpler
   [`FileImporter`](https://pub.dev/documentation/sass/latest/sass/FileImporter-class.html)
   (just `findFileUrl`); the built-in [`FsImporter`] already covers the common
   case, so a helper waits for a real host reporting friction (see *Deliberately
   out of scope*). NOT a back-compat shim; a deliberate forward convenience.
2. **Multiple importers / load-path chain.** ✅ **Resolved: single importer, add a
   list on demand.** dart's semantics are plain first-match-wins with no
   cross-importer ambiguity check, which a host composes inside one
   `canonicalize`/`load` today; promote to a built-in list only if the C ABI
   wants native multi-importer input.
3. **`modificationTime`.** ✅ **Resolved: skip.** It is cross-compile cache
   machinery (dart's import-cache invalidation); sasso is single-shot with no
   such cache. Revisit only with incremental/watch recompilation.
4. **URL vs path type.** ✅ **Resolved: keep the opaque `String` newtype.** For a
   host-defined importer it is a *superset* of a `Uri` type (any scheme allowed),
   and the private field leaves room to add normalization later without an API
   break. A real URI type only earns its keep alongside an importer list +
   non-canonical schemes, which we don't carry.
5. **`sourceMapUrl` plumbing.** ✅ **Resolved** — done in step 1 (PR #7) via the
   evaluator's `file_map_urls` override; `FsImporter` returns `None` so default
   source maps stay byte-identical, and the FFI surfaces it as the
   `source_map_url` arg of `sasso_importer_set_result`.
6. **`ImporterError` shape.** ✅ **Resolved** — shipped as just `{ message }`
   (miss vs failure already distinguished by `Ok(None)` vs `Err`). Over the FFI
   it maps to `sasso_importer_set_error` (a `(ptr, len)` message) + the `-1`
   return. A richer `kind` enum (NotFound / Ambiguous / Io / InvalidUrl) + span
   remains a future, non-breaking addition if a real need shows up.

## dart-sass parity (as implemented)

Compared against dart-sass's
[`Importer`](https://pub.dev/documentation/sass/latest/sass/Importer-class.html)
and
[`ImporterResult`](https://pub.dev/documentation/sass/latest/sass/ImporterResult-class.html).
The two gaps that prompted this redesign (issue #4) are **closed**: the importer
is no longer a single `resolve(path) -> Option<String>` but dart's two-phase
`canonicalize`/`load`, and `load` returns a struct (`contents` + `syntax` +
`source_map_url`) rather than a bare string.

| dart-sass `Importer` | sasso | status |
| --- | --- | --- |
| `canonicalize(Uri) -> Uri?` (may throw) | `canonicalize(&str, &CanonicalizeContext) -> Result<Option<CanonicalUrl>, ImporterError>` | ✅ aligned |
| `load(Uri) -> ImporterResult?` (may throw) | `load(&CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError>` | ✅ aligned |
| `fromImport` / `containingUrl` (zone-scoped) | `CanonicalizeContext { from_import, containing_url }` (explicit arg) | ✅ same info |
| throw → error | `Err(ImporterError)` | ✅ corresponds |
| `Uri` (schemes, `file:`) | `CanonicalUrl` (opaque `String`) | ◑ a superset for a host-defined importer — see [below](#deliberately-out-of-scope-these--are-not-a-backlog) |
| `modificationTime`, `couldCanonicalize`, `isNonCanonicalScheme` / `nonCanonicalSchemes`, `noOp`, `AsyncImporter` | — | ❌ N/A to a sync, single-importer model — see [below](#deliberately-out-of-scope-these--are-not-a-backlog) |
| separate `FileImporter` (`findFileUrl`) convenience | — | deferred — add on demand — see [below](#deliberately-out-of-scope-these--are-not-a-backlog) |

| dart-sass `ImporterResult` | sasso `ImporterResult` | status |
| --- | --- | --- |
| `contents: String` | `contents: String` | ✅ |
| `syntax: Syntax` | `syntax: Syntax` | ✅ |
| `sourceMapUrl: Uri?` | `source_map_url: Option<String>` | ✅ (type `Uri` → `String`) |
| `indented` (deprecated ctor param) | — | ✅ not carried (clean) |

So the **model and the issue-#4 gaps are aligned**; what remains unaligned is
dart's advanced/optional machinery, which is deliberately out of scope or
deferred — not the original "returns a string" mismatch.

## Deliberately out of scope (these `❌` are NOT a backlog)

Each dart-sass importer feature sasso doesn't carry was checked against dart's
actual API/source. Every one is either machinery for a capability sasso
*intentionally* lacks, or a convenience the host already gets another way — none
is a capability gap that blocks real use. **This list is a scope record, not a
TODO list to burn down.**

- **`AsyncImporter`** — would contradict sasso's synchronous, zero-runtime
  identity (dart needs it only for its async `compile()`). A host that needs I/O
  does *blocking* I/O inside the synchronous `load` callback.
- **`modificationTime` / `couldCanonicalize`** — exist only for dart's
  *persistent cross-compile cache* invalidation (used in dart's
  `clearCanonicalize`/import-cache, not the in-compile dedup, which keys on the
  canonical URL alone). sasso is single-shot with no cross-compile module cache,
  so there is nothing to invalidate. Revisit only if sasso grows incremental /
  watch recompilation.
- **`Uri` scheme system / `isNonCanonicalScheme`** — dart forces canonical URLs
  to be absolute, scheme-qualified `Uri`s to keep keys disjoint across an *ordered
  importer list*, and uses non-canonical schemes to decide when to expose
  `containingUrl`. sasso's `CanonicalUrl(String)` is a *superset* (the host may use
  any scheme it likes), and `containing_url` is provided *unconditionally* — so the
  one user-visible benefit is already free, with no scheme-classification API.
- **`noOp`** — an internal dart sentinel (the "no importer" state for a
  string-compiled stylesheet); Rust spells it `Option::None`.

Two items are *convenience, not capability*, and are correctly **deferred (add on
demand)**:

- **`FileImporter` / `findFileUrl`** — lets a host return just a `file:` URL and
  have the compiler do partial / `_index` / extension resolution. The built-in
  [`FsImporter`] already covers the common filesystem case; add a helper only if a
  real host reports friction re-implementing that probing for a *custom* root.
- **Ordered importer list** — dart tries each importer's `canonicalize` in order,
  first match wins, with no cross-importer ambiguity check. A host reproduces this
  exactly today by composing sub-importers inside one `canonicalize`/`load`
  (~20 lines). Promote to a built-in list only if the C ABI wants to accept
  multiple importers natively.
