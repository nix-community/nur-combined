//! `sasso` — a pure-Rust SCSS → CSS compiler.
//!
//! A small, zero-dependency, embeddable Sass engine aiming at byte-exact
//! parity with **current** dart-sass on the subset it implements (e.g.
//! computed colors serialize as `rgb(25%, 50%, 75%)`, not rounded
//! hex). It is sandbox-friendly: `@import` resolution goes through a
//! caller-supplied [`Importer`], so an embedder controls all file access.
//!
//! # Example
//!
//! ```
//! use sasso::{compile, Options};
//!
//! let css = compile("$c: #333; a { color: $c; &:hover { color: $c; } }", &Options::default()).unwrap();
//! assert!(css.contains("a {"));
//! assert!(css.contains("a:hover {"));
//! ```
//!
//! ## Scope
//!
//! This covers a large slice of Sass: variables (`!default`/`!global`),
//! nesting and the `&` parent selector, `#{}` interpolation, `//` and
//! `/* */` comments, unit arithmetic, the color functions, control flow,
//! mixins/functions, `@extend`, `@import`, and the `@use`/`@forward` module
//! system. Both input syntaxes are supported — the brace/semicolon SCSS
//! syntax and the indented `.sass` syntax (selected via [`Options::with_syntax`]
//! or, in the CLI, the input file's extension) — parsing into the same AST and
//! sharing the evaluator and emitter. The north-star target is 100% of the
//! official `sass-spec` suite, tracked by the harness in `spec/`.

// The library's `unsafe` is confined to one audited module — `arena`, the
// scoped bump allocator (perf #5), verified by unit tests + Miri. Every other
// module is `deny(unsafe_code)` (see Cargo.toml `[lints]`); `arena` is the only
// `#[allow]`. The wasm wrapper (`/wasm`, a separate crate) has its own FFI unsafe.
mod arena;

mod ast;
mod ast_writer;
mod builtins;
mod deprecation;
mod diag;
mod emit;
mod error;
mod eval;
mod fxhash;
mod host_fn;
mod importer;
mod musl_math;
mod parser;
// Path spelling by platform, as a value rather than a `#[cfg]`: the binary
// includes this same file (see `main.rs`) so both relativisations share one
// set of rules.
mod pathstyle;
mod ryu;
mod sass_parser;
mod scanner;
mod selector;
// Source Map v3 generation: the encoding primitives + JSON model (Phase A),
// wired into emit (Phase B/C) and surfaced through `compile_with_source_map`.
mod sourcemap;
mod value;

/// This compiler's version, as in `Cargo.toml`.
///
/// Exposed so a wrapper can report the version of the compiler it actually
/// bundles rather than its own: the FFI crate (`ffi/`) is versioned separately,
/// and its `sasso_version()` used to return `CARGO_PKG_VERSION`, i.e. the
/// wrapper's number. Reading it from here cannot drift.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

pub use arena::{set_arena_bytes, ScopedAlloc};
pub use error::Error;
pub use host_fn::{host_value_op, HostFunction};
pub use importer::{
    CanonicalUrl, CanonicalizeContext, DependencySet, FsImporter, Importer, ImporterError, ImporterResult,
};
pub use sourcemap::SourceMap;

/// The local filesystem path a `file:` URL names, or `None` when it names
/// no local file.
///
/// Handles what every caller of such a thing has to: the `file://` prefix,
/// the empty authority and `localhost` (both mean this machine), percent
/// escapes, a Windows drive letter arriving as `/C:/`, and a UNC authority
/// that only Windows can spell.
///
/// STRICT about UTF-8 — `None` rather than replacement characters — because
/// a caller of this is about to open the path, and a name with U+FFFD
/// substituted into it is a different name. The lossy reading belongs to
/// whoever is about to PRINT the path, and lives beside it in `pathstyle`.
///
/// This exists because `napi/` had its own copy of the same rule and the
/// two had already drifted (#161, #163): its copy accepted a `localhost`
/// authority that this one declined, so a `file://localhost/…` entry was
/// read happily and then printed as a URL in the frame.
pub fn file_url_to_path(url: &str) -> Option<String> {
    String::from_utf8(pathstyle::file_url_bytes(pathstyle::HOST, url)?).ok()
}

/// Output formatting style.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum OutputStyle {
    /// Human-readable, indented output (the default).
    #[default]
    Expanded,
    /// Minified, single-line output.
    Compressed,
}

/// The input syntax flavour.
///
/// Both flavours parse into the same AST and share the evaluator and emitter;
/// only the *block structure* differs (`{}`/`;` for SCSS, indentation +
/// newlines for the indented `.sass` syntax).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Syntax {
    /// The brace/semicolon SCSS syntax (the default).
    #[default]
    Scss,
    /// The indented `.sass` syntax: blocks come from indentation, statements
    /// end at a newline.
    Sass,
    /// Plain CSS (a `.css` file loaded via `@use`/`@forward`): the brace/semicolon
    /// grammar, but Sass features are rejected, nesting is preserved verbatim,
    /// and values are emitted without SassScript evaluation.
    Css,
}

/// Compilation options.
pub struct Options<'a> {
    /// Output style.
    pub style: OutputStyle,
    /// Input syntax (SCSS or indented `.sass`).
    pub syntax: Syntax,
    /// Importer used to resolve `@import`; `None` disables file imports.
    pub importer: Option<&'a dyn Importer>,
    /// The input's path/URL as it should appear in diagnostics (e.g.
    /// `input.scss`). `None` disables byte-exact diagnostic snippets (errors
    /// then render as the legacy `Error: <msg> (line:col)` one-liner).
    ///
    /// A `file://` URL is accepted and SHOWN as a path — the JS API passes
    /// one because its importer bridge resolves relative `@use` against it,
    /// and a frame reading `file:///Users/…/src/a.scss` names a file nobody
    /// can paste into an editor. See [`Options::cwd`] for what it is spelled
    /// relative to.
    pub url: Option<&'a str>,
    /// The directory diagnostic paths are spelled relative to, as dart's
    /// `p.prettyUri` does. `None` asks the operating system.
    ///
    /// It exists because one target cannot be asked: `wasm32-unknown-unknown`
    /// has no `getcwd`, so `std::env::current_dir()` there always fails and
    /// every frame kept an absolute path — or, for a `file://` key, only the
    /// file's own name. A host that knows better says so.
    pub cwd: Option<&'a str>,
    /// Whether to draw diagnostic snippets with Unicode box-drawing glyphs
    /// (`true`, the default) or the ASCII fallback (`false`, dart's
    /// `--no-unicode`).
    pub unicode: bool,
    /// Whether [`compile_with_source_map`] populates the source map's
    /// `sourcesContent` field with the full text of each source (dart-sass
    /// `--embed-sources`). Default `false` (the map references sources by URL
    /// only). Ignored by the plain [`compile`] path.
    pub source_map_include_sources: bool,
    /// Host-defined custom functions (dart-sass `functions`), registered via
    /// [`Options::with_function`]. Consulted after user `@function`s and module
    /// members but before built-in global functions.
    pub(crate) functions: Vec<host_fn::HostFn>,
    /// Diagnostic handler (dart-sass `logger`). When set, every `@warn`/`@debug`/
    /// deprecation warning is delivered here instead of printed to stderr.
    pub(crate) warn: Option<WarnHandler>,
    /// dart-sass `quietDeps`: deprecation warnings raised inside a dependency
    /// (a file this set marks, see [`FsImporter::dependencies`]) are dropped
    /// before they are counted or delivered.
    pub(crate) quiet_deps: Option<DependencySet>,
    /// dart-sass `silenceDeprecations`: deprecation ids dropped before they
    /// are counted or delivered. Empty means every deprecation is emitted.
    pub(crate) silenced_deprecations: Vec<String>,
    /// Emit a `@charset "UTF-8";` (expanded) / U+FEFF BOM (compressed) prefix
    /// when the output contains non-ASCII (dart-sass `charset`, default `true`).
    /// `false` suppresses it.
    pub charset: bool,
}

/// The kind of a diagnostic delivered to a [`WarnHandler`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WarnKind {
    /// A `@warn` directive (or a deprecation warning).
    Warn,
    /// A `@debug` directive.
    Debug,
}

/// A `@warn` / `@debug` / deprecation diagnostic delivered to an embedder's
/// [`WarnHandler`] (dart-sass `logger`).
///
/// Produced by the compiler and read by handlers; `#[non_exhaustive]` so a
/// future field is not a breaking change for anyone matching on it.
#[non_exhaustive]
pub struct WarnEvent<'a> {
    /// Warning vs debug.
    pub kind: WarnKind,
    /// True for a deprecation warning.
    pub deprecation: bool,
    /// The deprecation id (e.g. `"slash-div"`), or `""` when not a deprecation.
    pub deprecation_id: &'a str,
    /// The raw message text (the `@warn`/`@debug` value, or deprecation message).
    pub message: &'a str,
    /// The full dart-style block sasso would otherwise print to stderr (header +
    /// snippet + stack trace), for a faithful default logger.
    pub formatted: &'a str,
    /// The source URL for the diagnostic's span, as dart-sass displays it in a
    /// stack frame: the entry's [`Options::url`] as given, or a loaded file's
    /// path from the working directory (absolute when that would be longer;
    /// a custom importer's non-path key shows its last segment). For an entry
    /// compiled without [`Options::url`] it is `""` under [`compile`] and
    /// `"stdin"` under [`compile_with_source_map`] (the source map has to name
    /// the entry somehow, like dart's `-`); the line is still set. `""` for the
    /// "repetitive deprecation warnings omitted" footer, which has no span.
    pub url: &'a str,
    /// The 1-based line for the diagnostic's span; `0` when not available.
    pub line: usize,
    /// The canonical URL of the stylesheet being evaluated when the diagnostic
    /// fired, or `""` when not available. For a file the importer loaded this
    /// is the importer's canonical URL — the resolved absolute path with
    /// [`FsImporter`] — which is what [`DependencySet::is_dependency`] keys on.
    /// For the entry stylesheet it is [`Options::url`] exactly as supplied
    /// (the library never canonicalizes the entry). Unlike `url` (dart's display
    /// form, relative to the working directory) it is stable across working
    /// directories and identifies the file.
    pub path: &'a str,
}

/// An embedder's diagnostic handler (dart-sass `logger`). Receives every
/// `@warn` / `@debug` / deprecation warning that the options do not suppress;
/// if unset, they print to stderr.
///
/// Two options suppress before this point, because both decide what is worth
/// reporting rather than how to report it, and dart-sass applies them in the
/// compiler for the same reason: [`Options::with_quiet_deps`] drops
/// deprecations raised inside dependencies, and
/// [`Options::with_silenced_deprecations`] drops the ids it names. A
/// suppressed deprecation is not merely withheld from the handler — it is not
/// counted either, so it cannot turn up in the "N repetitive deprecation
/// warnings omitted" tally.
pub type WarnHandler = std::rc::Rc<dyn Fn(&WarnEvent<'_>)>;

/// How the entry names itself in a parse error's lone `root stylesheet`
/// frame. A parse error never reaches the evaluator, so it cannot use the
/// evaluator's rule and needs the same one applied here — see
/// [`Options::url`] for why a `file://` URL arrives at all.
fn entry_frame_name(url: &str, cwd: Option<&str>) -> String {
    let from_os;
    let cwd = match cwd {
        Some(c) => Some(c),
        None => {
            // Lossily, as the evaluator's own lookup does. `to_str` would
            // hand back `None` for a directory with one non-UTF-8 component
            // and leave a PARSE error absolute while an evaluation error in
            // the same file came out relative.
            from_os = std::env::current_dir()
                .ok()
                .map(|p| p.to_string_lossy().into_owned());
            from_os.as_deref()
        }
    };
    pathstyle::pretty_name(pathstyle::style_for(cwd, url), url, cwd).unwrap_or_else(|| url.to_string())
}

impl Default for Options<'_> {
    fn default() -> Self {
        Options {
            style: OutputStyle::default(),
            syntax: Syntax::default(),
            importer: None,
            url: None,
            cwd: None,
            unicode: true,
            source_map_include_sources: false,
            functions: Vec::new(),
            warn: None,
            quiet_deps: None,
            silenced_deprecations: Vec::new(),
            charset: true,
        }
    }
}

impl<'a> Options<'a> {
    /// Create default options (expanded, SCSS, no importer).
    pub fn new() -> Self {
        Self::default()
    }

    /// Builder: set the output style.
    #[must_use]
    pub fn with_style(mut self, style: OutputStyle) -> Self {
        self.style = style;
        self
    }

    /// Builder: set the input syntax.
    #[must_use]
    pub fn with_syntax(mut self, syntax: Syntax) -> Self {
        self.syntax = syntax;
        self
    }

    /// Builder: set the importer.
    #[must_use]
    pub fn with_importer(mut self, importer: &'a dyn Importer) -> Self {
        self.importer = Some(importer);
        self
    }

    /// Builder: set the diagnostic display URL (enables byte-exact snippets).
    #[must_use]
    pub fn with_url(mut self, url: &'a str) -> Self {
        self.url = Some(url);
        self
    }

    /// Builder: the directory diagnostic paths are spelled relative to.
    ///
    /// Only a host that knows better than `getcwd` needs this — see
    /// [`Options::cwd`]. On `wasm32-unknown-unknown` there is no `getcwd` at
    /// all, so without it every frame keeps an absolute path.
    #[must_use]
    pub fn with_cwd(mut self, cwd: &'a str) -> Self {
        self.cwd = Some(cwd);
        self
    }

    /// Builder: select the diagnostic glyph set (`false` = ASCII / `--no-unicode`).
    #[must_use]
    pub fn with_unicode(mut self, unicode: bool) -> Self {
        self.unicode = unicode;
        self
    }

    /// Builder: whether [`compile_with_source_map`] embeds each source's full
    /// text in the map's `sourcesContent` (default `false`).
    #[must_use]
    pub fn with_source_map_include_sources(mut self, include: bool) -> Self {
        self.source_map_include_sources = include;
        self
    }

    /// Register a host-defined custom function (dart-sass `functions`).
    ///
    /// `signature` is a Sass function signature — a name and parameter list,
    /// e.g. `"pow($base, $exponent)"` or `"to-list($args...)"`. `callback`
    /// receives the bound arguments serialized to sasso's host-value wire format
    /// and returns the result serialized the same way (or an `Err(message)` that
    /// becomes a compile error). This byte-oriented boundary lets embedders
    /// (wasm/FFI) bridge to their own value system without exposing sasso's
    /// internal `Value` type.
    ///
    /// Custom functions take precedence over built-in global functions but not
    /// over user `@function` definitions or `@use`d module members. A malformed
    /// signature is reported only if the function is actually called.
    ///
    /// That precedence is where sasso is deliberately more permissive than
    /// dart-sass 1.103.1, whose `functions` do not shadow a built-in global at
    /// all (registering `type-of($v)` there leaves the built-in running and the
    /// callback never invoked). The `[global-builtin]` deprecation follows
    /// dart: writing a deprecated global's name warns whether or not a custom
    /// function of that name is registered.
    #[must_use]
    pub fn with_function(mut self, signature: &str, callback: host_fn::HostFunction) -> Self {
        let (name, params) = host_fn::parse_signature(signature);
        self.functions.push(host_fn::HostFn {
            name,
            params,
            callback,
        });
        self
    }

    /// Set the diagnostic handler (dart-sass `logger`). Each `@warn`/`@debug`/
    /// deprecation warning is delivered to `handler` instead of being printed to
    /// stderr (the default when unset).
    ///
    /// Deprecations suppressed by [`Options::with_quiet_deps`] or
    /// [`Options::with_silenced_deprecations`] never reach `handler`: both are
    /// applied in the compiler, ahead of the repetition cap, so a suppressed
    /// deprecation is not counted either. See [`WarnHandler`].
    #[must_use]
    pub fn with_warn_handler(mut self, handler: WarnHandler) -> Self {
        self.warn = Some(handler);
        self
    }

    /// Silence deprecation warnings from dependencies (dart-sass `quietDeps`):
    /// files that `deps` — normally [`FsImporter::dependencies`] of the importer
    /// in use — marks as reached through a load path. Applied before the
    /// repetition cap, so silenced warnings do not surface as "N repetitive
    /// deprecation warnings omitted" either. `@warn`/`@debug` are unaffected,
    /// as in dart.
    #[must_use]
    pub fn with_quiet_deps(mut self, deps: DependencySet) -> Self {
        self.quiet_deps = Some(deps);
        self
    }

    /// dart-sass `silenceDeprecations` / `--silence-deprecation`: drop these
    /// deprecations by id, keeping every other warning.
    ///
    /// Applied where `quiet_deps` is, which is before the per-id cap — so a
    /// silenced deprecation neither consumes one of the five printed slots nor
    /// counts towards the "N repetitive deprecation warnings omitted" footer.
    /// Filtering in a warn handler instead leaves that footer behind, counting
    /// warnings the caller asked not to see (dart prints nothing at all).
    ///
    /// Ids sasso never emits are accepted and do nothing: a build script
    /// written for `sass` should not fail here for naming one.
    #[must_use]
    pub fn with_silenced_deprecations<I, S>(mut self, ids: I) -> Self
    where
        I: IntoIterator<Item = S>,
        S: Into<String>,
    {
        self.silenced_deprecations = ids.into_iter().map(Into::into).collect();
        self
    }

    /// Set whether to emit the `@charset`/BOM prefix for non-ASCII output
    /// (dart-sass `charset`, default `true`).
    #[must_use]
    pub fn with_charset(mut self, charset: bool) -> Self {
        self.charset = charset;
        self
    }
}

/// Compile SCSS source to CSS.
///
/// # Errors
///
/// Returns [`Error`] on a parse or evaluation failure (with a 1-based
/// source position when known).
///
/// # Allocator scope
///
/// When the binary installs [`ScopedAlloc`] as its `#[global_allocator]`, this
/// function brackets the whole compile in a bump-arena scope: every allocation
/// `compile_inner` makes is a pointer bump from a per-thread arena that is freed
/// wholesale when the scope ends. The returned `Result` is allocated *in* the
/// arena, so it is deep-cloned out to the system allocator *before* the arena is
/// reset — the value handed back to the caller never points into the arena. When
/// no `ScopedAlloc` is installed the scope primitives are inert (depth tracking
/// only) and every allocation goes to the system allocator as usual, so this
/// wrapper is correct (just with a redundant clone) under any global allocator.
pub fn compile(source: &str, options: &Options<'_>) -> Result<String, Error> {
    // Enter the arena scope. The RAII guard's `Drop` leaves + resets the arena
    // on the *panic* path; the success path below finishes manually and forgets
    // the guard, so there is no double-leave.
    let guard = arena::Scope::enter();
    // All allocations here bump from the arena (when ScopedAlloc is installed).
    let result = compile_inner(source, options);
    // Leave the scope WITHOUT resetting yet: depth drops to 0, so the arena is
    // now inactive and subsequent allocations route to the system allocator —
    // but the arena memory is still intact and `result` may point into it.
    let outermost = arena::leave_no_reset();
    // Deep-clone the result to the system allocator while the scope is inactive.
    // `Error` derives `Clone`, so both the `Ok(String)` and `Err(message)` cases
    // are copied out byte-for-byte to system-owned memory.
    let owned = result.clone();
    // Drop the arena-resident original (in-arena `dealloc` is a no-op) before
    // the region it lives in is reclaimed.
    drop(result);
    // Only the outermost scope owns the arena's lifetime; reset frees it all.
    if outermost {
        arena::reset();
    }
    // We finished the scope manually; suppress the guard's `Drop` to avoid a
    // second leave/reset.
    std::mem::forget(guard);
    owned
}

/// The CSS plus its source map, returned by [`compile_with_source_map`].
#[derive(Clone, Debug)]
pub struct CompileResult {
    /// The compiled CSS (identical to what [`compile`] would return for the
    /// same `source`/`options` — the map is generated alongside, not instead).
    pub css: String,
    /// The Source Map v3 describing `css`. Serialize it with
    /// [`SourceMap::to_json`].
    pub source_map: SourceMap,
}

/// Compile SCSS source to CSS *and* a [Source Map v3](SourceMap).
///
/// The `css` field is byte-for-byte what [`compile`] returns; the map is built
/// alongside it. The map's `file` is the basename of [`Options::url`] (or
/// `"stdin"` when no URL is set) and its `sources` are the source URLs.
/// [`Options::with_source_map_include_sources`] controls whether each source's
/// full text is embedded in `sourcesContent`.
///
/// Maps the start of each selector, declaration property name, declaration
/// value, at-rule keyword, and comment. A value that is a bare `$name` maps
/// back to where that variable was DEFINED, like dart-sass.
///
/// # Errors
///
/// Returns [`Error`] on a parse or evaluation failure, like [`compile`].
pub fn compile_with_source_map(source: &str, options: &Options<'_>) -> Result<CompileResult, Error> {
    // Mirror `compile`'s arena bracketing so the returned value is deep-cloned
    // out to the system allocator before the arena is reset.
    let guard = arena::Scope::enter();
    let result = compile_inner_sm(source, options);
    let outermost = arena::leave_no_reset();
    let owned = result.clone();
    drop(result);
    if outermost {
        arena::reset();
    }
    std::mem::forget(guard);
    owned
}

/// The basename of a path/URL (everything after the last `/`), used for the
/// source map's `file` field.
fn basename(url: &str) -> &str {
    url.rsplit('/').next().unwrap_or(url)
}

/// The source-map compile pipeline: parse + evaluate exactly like
/// [`compile_inner`], then emit with the source-map collector and assemble the
/// [`SourceMap`].
fn compile_inner_sm(source: &str, options: &Options<'_>) -> Result<CompileResult, Error> {
    // dart's `quietDeps` is a per-compilation notion: scope the record to this
    // compile — it starts empty, and a nested compile (a warn handler running
    // `compile` with the same importer) hands the enclosing record back when
    // it ends — so provenance cannot leak between compiles sharing an importer.
    // Entered before parsing, so a compile that fails early still leaves the
    // record in its per-compilation state.
    let _dep_scope = options.quiet_deps.as_ref().map(|d| d.enter_compile());
    let glyphs = if options.unicode {
        diag::GlyphSet::Unicode
    } else {
        diag::GlyphSet::Ascii
    };
    // Reject `@function`/`@mixin` declarations in control directives or
    // function/mixin bodies, and a misplaced `@import` (a compile-time
    // restriction, checked before eval and rendered like a parse error).
    let sheet = match options.syntax {
        Syntax::Scss => parser::parse(source),
        Syntax::Css => parser::parse_plain_css(source),
        Syntax::Sass => sass_parser::parse(source),
    }
    .and_then(|sheet| {
        if !matches!(options.syntax, Syntax::Css) {
            eval::validate_declarations(&sheet)?;
        }
        Ok(sheet)
    });
    let sheet = match sheet {
        Ok(s) => s,
        Err(mut e) => {
            if let Some(url) = options.url {
                if e.rendered.is_none() && e.has_position() {
                    let span = diag::trim_empty_span_to_content(
                        source,
                        diag::Span {
                            line: e.line,
                            col: e.col,
                            length: e.length,
                        },
                    );
                    e.line = span.line;
                    e.col = span.col;
                    e.rendered = Some(diag::render_error(
                        &e.message,
                        source,
                        &entry_frame_name(url, options.cwd),
                        span,
                        glyphs,
                    ));
                }
            }
            return Err(e);
        }
    };
    // The entry name labels the entry source in the map (its `sources` entry,
    // once a mapping references it; an import-only entry has none). It is also
    // the evaluator's `current_url`, so every entry-file node is stamped with a
    // non-zero file id; its source text is kept for `sourcesContent`. The
    // source-map path always passes the real source (so
    // `sourcesContent` works even without a diagnostic URL); this only enriches
    // the *error* path with snippets — the CSS/map success path is unaffected.
    let entry_name = options.url.unwrap_or("stdin");
    let mut ev = eval::Evaluator::new(eval::EvalOptions {
        style: options.style,
        importer: options.importer,
        functions: &options.functions,
        cwd: options.cwd,
        source,
        url: entry_name,
        glyphs,
        warn: options.warn.as_ref(),
        quiet_deps: options.quiet_deps.as_ref(),
        silenced_deprecations: &options.silenced_deprecations,
        plain_css: matches!(options.syntax, Syntax::Css),
        source_map: true,
    });
    let mut out = Vec::new();
    ev.eval_sheet(&sheet, &mut out)?;
    let (css, body_off, collector) = emit::emit_with_map(&out, options.style, options.charset);
    let mappings = collector.finalize(&css, body_off);
    let (sources, sources_content) =
        ev.source_table(mappings.source_ids(), options.source_map_include_sources);
    let mappings = mappings.encode();
    let source_map = SourceMap {
        file: Some(basename(entry_name).to_string()),
        sources,
        sources_content,
        mappings,
    };
    Ok(CompileResult { css, source_map })
}

/// The actual compile pipeline. Runs inside the arena scope established by
/// [`compile`]; all of its allocations may be arena-resident, so its result is
/// copied out by the wrapper before the arena is reset.
fn compile_inner(source: &str, options: &Options<'_>) -> Result<String, Error> {
    // dart's `quietDeps` is a per-compilation notion: scope the record to this
    // compile — it starts empty, and a nested compile (a warn handler running
    // `compile` with the same importer) hands the enclosing record back when
    // it ends — so provenance cannot leak between compiles sharing an importer.
    // Entered before parsing, so a compile that fails early still leaves the
    // record in its per-compilation state.
    let _dep_scope = options.quiet_deps.as_ref().map(|d| d.enter_compile());
    let glyphs_for = || {
        if options.unicode {
            diag::GlyphSet::Unicode
        } else {
            diag::GlyphSet::Ascii
        }
    };
    // Reject `@function`/`@mixin` declarations in control directives or
    // function/mixin bodies, and a misplaced `@import` (a compile-time
    // restriction, checked before eval and rendered like a parse error).
    let sheet = match options.syntax {
        Syntax::Scss => parser::parse(source),
        Syntax::Css => parser::parse_plain_css(source),
        Syntax::Sass => sass_parser::parse(source),
    }
    .and_then(|sheet| {
        if !matches!(options.syntax, Syntax::Css) {
            eval::validate_declarations(&sheet)?;
        }
        Ok(sheet)
    });
    // A parse error never reached the evaluator, so render its snippet here
    // (single `root stylesheet` frame) when a diagnostic URL is configured.
    let sheet = match sheet {
        Ok(s) => s,
        Err(mut e) => {
            if let Some(url) = options.url {
                if e.rendered.is_none() && e.has_position() {
                    let span = diag::trim_empty_span_to_content(
                        source,
                        diag::Span {
                            line: e.line,
                            col: e.col,
                            length: e.length,
                        },
                    );
                    e.line = span.line;
                    e.col = span.col;
                    e.rendered = Some(diag::render_error(
                        &e.message,
                        source,
                        &entry_frame_name(url, options.cwd),
                        span,
                        glyphs_for(),
                    ));
                }
            }
            return Err(e);
        }
    };
    // Diagnostics are enabled only when the caller supplies a display URL; then
    // the evaluator renders byte-exact `Error:`/`WARNING:` blocks against the
    // source. Without a URL it falls back to the legacy one-liner.
    let (diag_source, diag_url) = match options.url {
        Some(url) => (source, url),
        None => ("", ""),
    };
    let glyphs = if options.unicode {
        diag::GlyphSet::Unicode
    } else {
        diag::GlyphSet::Ascii
    };
    let mut ev = eval::Evaluator::new(eval::EvalOptions {
        style: options.style,
        importer: options.importer,
        functions: &options.functions,
        cwd: options.cwd,
        source: diag_source,
        url: diag_url,
        glyphs,
        warn: options.warn.as_ref(),
        quiet_deps: options.quiet_deps.as_ref(),
        silenced_deprecations: &options.silenced_deprecations,
        plain_css: matches!(options.syntax, Syntax::Css),
        source_map: false,
    });
    let mut out = Vec::new();
    ev.eval_sheet(&sheet, &mut out)?;
    Ok(emit::emit(&out, options.style, options.charset))
}

/// The two readings of one `file:` URL decoder, and why they differ.
///
/// `pathstyle::file_url_path` produces a name to SHOW; `file_url_to_path`
/// produces a path to OPEN. Everything else about them — the `file://`
/// prefix, the empty and `localhost` authorities, percent escapes, a
/// Windows drive letter, a UNC authority — is one function since #163,
/// after two copies of it had drifted apart twice.
///
/// Here rather than in `pathstyle.rs` because that file is also compiled
/// into the BINARY (see `main.rs`), where `crate::` is the bin root and
/// has no `file_url_to_path`.
#[cfg(test)]
mod file_url_tests {
    use crate::pathstyle::{file_url_path, Style, HOST};

    #[test]
    fn an_undecodable_byte_is_shown_and_not_opened() {
        // Shown with the replacement character: a frame naming the file is
        // still better than no frame.
        //
        // Both styles spelled out rather than `HOST`, which is the whole
        // point of `Style` being a value: an assertion written against the
        // host passes here and fails on the Windows job, where the same
        // URL comes back `\a\u{fffd}b.scss`.
        assert_eq!(
            file_url_path(Style::Posix, "file:///a%FFb.scss").as_deref(),
            Some("/a\u{fffd}b.scss")
        );
        assert_eq!(
            file_url_path(Style::Windows, "file:///a%FFb.scss").as_deref(),
            Some("\\a\u{fffd}b.scss")
        );
        // …and refused for opening, because a name with U+FFFD substituted
        // into it is a different name. Host-independent: the strict reading
        // fails at the UTF-8 step, before any separator is chosen.
        assert_eq!(super::file_url_to_path("file:///a%FFb.scss"), None);
    }

    #[test]
    fn and_they_agree_about_everything_decodable() {
        for url in [
            "file:///a/b.scss",
            "file://localhost/a/b.scss",
            "file:///my%20docs/a.scss",
            "data:;base64,YQ==",
            "file://",
            "/a/b.scss",
        ] {
            assert_eq!(
                file_url_path(HOST, url),
                super::file_url_to_path(url),
                "the two readings disagreed about {url}",
            );
        }
    }
}
