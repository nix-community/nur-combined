//! The `sasso::include!` macro: compile Sass to CSS at Rust compile time.
//!
//! Use it through `sasso`, which re-exports it under the `macro` feature:
//!
//! ```toml
//! [dependencies]
//! sasso = { version = "0.22", features = ["macro"] }
//! ```
//!
//! ```ignore
//! static CSS: &str = sasso::include!("static/main.scss");
//! ```
//!
//! [`include!`] reads a stylesheet, compiles it with [`sasso_core`], and
//! expands to the CSS as a `&'static str`. A Sass error fails the build,
//! rendered the way the `sasso` CLI renders it. Every file the compile loaded
//! is tracked, so editing a partial rebuilds the crate that includes it.
//!
//! Like sasso itself this crate has no dependencies beyond the compiler: the
//! macro input is parsed with `proc_macro`'s own token API, without `syn`.

use std::cell::RefCell;
use std::path::{Path, PathBuf};

use proc_macro::{Delimiter, Group, Ident, Literal, Punct, Spacing, Span, TokenStream, TokenTree};
use sasso_core::{
    CanonicalUrl, CanonicalizeContext, FsImporter, Importer, ImporterError, ImporterResult, Options,
    OutputStyle, Syntax,
};

/// Compile a Sass file to CSS at compile time, expanding to a `&'static str`.
///
/// Needs `sasso`'s `macro` feature.
///
/// ```ignore
/// // Paths are relative to the including crate's root (`CARGO_MANIFEST_DIR`).
/// static CSS: &str = sasso::include!("static/main.scss");
///
/// // Options follow the path, as `key = value` pairs:
/// static MIN: &str = sasso::include!(
///     "static/main.scss",
///     style = "compressed",
///     load_paths = ["node_modules", "vendor/scss"],
/// );
/// ```
///
/// - `style`: `"expanded"` (the default) or `"compressed"`.
/// - `load_paths`: directories searched for `@use`/`@forward`/`@import` URLs
///   that do not resolve relative to the file using them, each relative to
///   `CARGO_MANIFEST_DIR` unless absolute.
///
/// The syntax follows the file's extension: `.sass` is the indented syntax,
/// `.css` plain CSS, anything else SCSS.
///
/// The paths are relative to the crate root rather than to the source file
/// (as `include_str!`'s are) because a procedural macro on stable Rust cannot
/// learn which file invoked it.
#[proc_macro]
pub fn include(input: TokenStream) -> TokenStream {
    match expand(input) {
        Ok(tokens) => tokens,
        Err((span, message)) => compile_error(span, &message),
    }
}

/// A failure to report, and the input token to point it at.
type Failure = (Span, String);

/// The parsed macro input.
struct Args {
    path: String,
    path_span: Span,
    style: OutputStyle,
    load_paths: Vec<String>,
}

fn expand(input: TokenStream) -> Result<TokenStream, Failure> {
    let args = parse_args(input)?;
    let (css, files) = compile_tracked(&manifest_dir(), &args.path, args.style, &args.load_paths)
        .map_err(|message| (args.path_span, message))?;

    // `include_bytes!` of each file read is how a macro on stable Rust tells
    // Cargo what to watch: rustc records every file it includes in the
    // crate's dep-info, so an edit to any of them reruns the expansion. The
    // bytes land in an unnamed constant nobody reads, which costs nothing.
    //
    // Every name is spelled from the crate root: the expansion resolves in
    // the caller's scope, where `u8` or `include_bytes` may be rebound.
    let mut code = String::from("{");
    for f in &files {
        code.push_str(&format!(
            "const _: &[::core::primitive::u8] = ::core::include_bytes!({});",
            Literal::string(f)
        ));
    }
    code.push_str(&Literal::string(&css).to_string());
    code.push('}');
    Ok(code.parse().expect("generated tokens parse"))
}

/// Compile `path` (relative to `root` unless absolute) and return the CSS with
/// every file the compile read: the entry first, then each loaded file once,
/// in load order. Those are the files the expansion must track.
///
/// Kept apart from the `proc_macro` API, which works only inside a macro
/// expansion, so the tracking contract can be unit-tested.
fn compile_tracked(
    root: &Path,
    path: &str,
    style: OutputStyle,
    load_paths: &[String],
) -> Result<(String, Vec<String>), String> {
    let entry = root.join(path);
    let source =
        std::fs::read_to_string(&entry).map_err(|e| format!("couldn't read {}: {e}", entry.display()))?;

    let importer = RecordingImporter {
        inner: FsImporter::new(load_paths.iter().map(|p| root.join(p)).collect()),
        loaded: RefCell::new(Vec::new()),
    };
    let url = entry.to_string_lossy().into_owned();
    let options = Options::new()
        .with_style(style)
        .with_syntax(syntax_for(&entry))
        .with_importer(&importer)
        .with_url(&url);
    let css = sasso_core::compile(&source, &options).map_err(|e| {
        // rustc already heads the diagnostic with `error: `.
        let text = e.to_string();
        text.strip_prefix("Error: ").unwrap_or(&text).to_owned()
    })?;

    let mut files = vec![url];
    for f in importer.loaded.into_inner() {
        if !files.contains(&f) {
            files.push(f);
        }
    }
    Ok((css, files))
}

fn manifest_dir() -> PathBuf {
    // Cargo sets it for every crate it compiles; a bare `rustc` invocation
    // gets the working directory, which is what relative paths meant there.
    // Absolute either way: the expansion's `include_bytes!` resolves a
    // relative path against the invoking source file, not the working
    // directory, and would name a different file than the one compiled.
    std::env::var_os("CARGO_MANIFEST_DIR")
        .map(PathBuf::from)
        .or_else(|| std::env::current_dir().ok())
        .unwrap_or_else(|| PathBuf::from("."))
}

fn syntax_for(path: &Path) -> Syntax {
    match path.extension().and_then(|e| e.to_str()) {
        Some("sass") => Syntax::Sass,
        Some("css") => Syntax::Css,
        _ => Syntax::Scss,
    }
}

/// [`FsImporter`], remembering every file it loads.
///
/// `FsImporter::dependencies` is not this list: it holds only the files
/// reached through a load path (what `--quiet-deps` silences), not the ones
/// loaded relatively — and those are just as much inputs to the CSS.
struct RecordingImporter {
    inner: FsImporter,
    loaded: RefCell<Vec<String>>,
}

impl Importer for RecordingImporter {
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        self.inner.canonicalize(url, ctx)
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        let result = self.inner.load(canonical)?;
        if result.is_some() {
            // FsImporter's canonical URL is the file's absolute path.
            self.loaded.borrow_mut().push(canonical.as_str().to_owned());
        }
        Ok(result)
    }
}

// ---- input parsing -------------------------------------------------------

/// `"path" (, key = value)* ,?`
fn parse_args(input: TokenStream) -> Result<Args, Failure> {
    let mut tokens = flatten(input).into_iter().peekable();
    let (path, path_span) = match tokens.next() {
        Some(TokenTree::Literal(lit)) => (string_value(&lit)?, lit.span()),
        Some(other) => return Err((other.span(), "expected a string literal path".into())),
        None => {
            return Err((
                Span::call_site(),
                "expected a path: include!(\"style.scss\")".into(),
            ))
        }
    };
    let mut args = Args {
        path,
        path_span,
        style: OutputStyle::Expanded,
        load_paths: Vec::new(),
    };
    let mut seen: Vec<String> = Vec::new();
    loop {
        match tokens.next() {
            None => break,
            Some(TokenTree::Punct(p)) if p.as_char() == ',' => {}
            Some(other) => return Err((other.span(), "expected `,`".into())),
        }
        let key = match tokens.next() {
            None => break, // trailing comma
            Some(TokenTree::Ident(key)) => key,
            Some(other) => return Err((other.span(), "expected an option name".into())),
        };
        let name = key.to_string();
        if seen.contains(&name) {
            return Err((key.span(), format!("`{name}` is given twice")));
        }
        match tokens.next() {
            Some(TokenTree::Punct(p)) if p.as_char() == '=' => {}
            Some(other) => return Err((other.span(), format!("expected `=` after `{name}`"))),
            None => return Err((key.span(), format!("expected `=` after `{name}`"))),
        }
        let value = tokens
            .next()
            .ok_or_else(|| (key.span(), format!("expected a value for `{name}`")))?;
        match name.as_str() {
            "style" => args.style = parse_style(&value)?,
            "load_paths" => args.load_paths = parse_string_list(&value)?,
            _ => {
                return Err((
                    key.span(),
                    format!("unknown option `{name}`; expected `style` or `load_paths`"),
                ))
            }
        }
        seen.push(name);
    }
    Ok(args)
}

fn parse_style(value: &TokenTree) -> Result<OutputStyle, Failure> {
    let TokenTree::Literal(lit) = value else {
        return Err((value.span(), "expected \"expanded\" or \"compressed\"".into()));
    };
    match string_value(lit)?.as_str() {
        "expanded" => Ok(OutputStyle::Expanded),
        "compressed" => Ok(OutputStyle::Compressed),
        other => Err((
            lit.span(),
            format!("unknown style \"{other}\"; expected \"expanded\" or \"compressed\""),
        )),
    }
}

fn parse_string_list(value: &TokenTree) -> Result<Vec<String>, Failure> {
    let TokenTree::Group(group) = value else {
        return Err((value.span(), "expected a list of paths: [\"dir\", ...]".into()));
    };
    if group.delimiter() != Delimiter::Bracket {
        return Err((group.span(), "expected a list of paths: [\"dir\", ...]".into()));
    }
    let mut out = Vec::new();
    let mut tokens = flatten(group.stream()).into_iter();
    while let Some(token) = tokens.next() {
        match token {
            TokenTree::Literal(lit) => out.push(string_value(&lit)?),
            other => return Err((other.span(), "expected a string literal path".into())),
        }
        match tokens.next() {
            None => break,
            Some(TokenTree::Punct(p)) if p.as_char() == ',' => {}
            Some(other) => return Err((other.span(), "expected `,`".into())),
        }
    }
    Ok(out)
}

/// The input's tokens, with invisible groups opened: a literal that reached
/// the macro through a `macro_rules!` `$x:expr` arrives wrapped in one.
fn flatten(stream: TokenStream) -> Vec<TokenTree> {
    let mut out = Vec::new();
    for token in stream {
        match token {
            TokenTree::Group(g) if g.delimiter() == Delimiter::None => out.extend(flatten(g.stream())),
            other => out.push(other),
        }
    }
    out
}

/// The value of a string literal (`"..."` or `r#"..."#`), from its source
/// text — `proc_macro` offers no accessor on stable.
fn string_value(lit: &Literal) -> Result<String, Failure> {
    let text = lit.to_string();
    let err = || (lit.span(), "expected a string literal".to_string());
    if let Some(raw) = text.strip_prefix('r') {
        let hashes = raw.len() - raw.trim_start_matches('#').len();
        let fence = &raw[..hashes];
        return raw[hashes..]
            .strip_prefix('"')
            .and_then(|s| s.strip_suffix(fence))
            .and_then(|s| s.strip_suffix('"'))
            .map(str::to_owned)
            .ok_or_else(err);
    }
    let body = text
        .strip_prefix('"')
        .and_then(|s| s.strip_suffix('"'))
        .ok_or_else(err)?;
    unescape(body).ok_or_else(|| (lit.span(), "unsupported escape in string literal".into()))
}

/// Rust's string-literal escapes. The lexer has already rejected malformed
/// ones, so this only has to decode what it accepted.
fn unescape(body: &str) -> Option<String> {
    let mut out = String::with_capacity(body.len());
    let mut chars = body.chars().peekable();
    while let Some(c) = chars.next() {
        if c != '\\' {
            out.push(c);
            continue;
        }
        match chars.next()? {
            'n' => out.push('\n'),
            'r' => out.push('\r'),
            't' => out.push('\t'),
            '0' => out.push('\0'),
            '\\' => out.push('\\'),
            '\'' => out.push('\''),
            '"' => out.push('"'),
            'x' => {
                let hex: String = chars.by_ref().take(2).collect();
                out.push(char::from(u8::from_str_radix(&hex, 16).ok()?));
            }
            'u' => {
                if chars.next()? != '{' {
                    return None;
                }
                let hex: String = chars
                    .by_ref()
                    .take_while(|&c| c != '}')
                    .filter(|&c| c != '_')
                    .collect();
                out.push(char::from_u32(u32::from_str_radix(&hex, 16).ok()?)?);
            }
            // A line continuation: the newline and the next line's leading
            // whitespace are dropped — only the four characters Rust's lexer
            // skips there, not every Unicode space (a U+00A0 is kept).
            '\n' => {
                while chars
                    .peek()
                    .is_some_and(|c| matches!(c, ' ' | '\t' | '\n' | '\r'))
                {
                    chars.next();
                }
            }
            _ => return None,
        }
    }
    Some(out)
}

/// `::core::compile_error!("message")`, every token spanned at `span` so the
/// error points at the offending input.
///
/// The path is absolute because the tokens resolve in the caller's scope: a
/// bare `compile_error!` would pick up a `macro_rules! compile_error` the
/// caller defined, which could expand to anything — and turn a failed
/// compile into a successful build.
fn compile_error(span: Span, message: &str) -> TokenStream {
    let punct = |c, spacing| {
        let mut p = Punct::new(c, spacing);
        p.set_span(span);
        TokenTree::Punct(p)
    };
    let mut lit = Literal::string(message);
    lit.set_span(span);
    let mut group = Group::new(Delimiter::Parenthesis, TokenTree::Literal(lit).into());
    group.set_span(span);
    [
        punct(':', Spacing::Joint),
        punct(':', Spacing::Alone),
        TokenTree::Ident(Ident::new("core", span)),
        punct(':', Spacing::Joint),
        punct(':', Spacing::Alone),
        TokenTree::Ident(Ident::new("compile_error", span)),
        punct('!', Spacing::Alone),
        TokenTree::Group(group),
    ]
    .into_iter()
    .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fixtures() -> PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/scss")
    }

    fn compile_main(load_paths: &[&str]) -> Result<(String, Vec<String>), String> {
        let load_paths: Vec<String> = load_paths.iter().map(|p| p.to_string()).collect();
        compile_tracked(&fixtures(), "main.scss", OutputStyle::Expanded, &load_paths)
    }

    /// The rebuild contract: what `compile_tracked` returns is what the
    /// expansion `include_bytes!`es, and rustc puts each of those in the
    /// crate's dep-info. A partial missing here would compile once and then
    /// never rebuild when edited.
    #[test]
    fn tracks_the_entry_and_every_partial_it_loads() {
        let (_, files) = compile_main(&["lib"]).unwrap();
        let tracked = |name: &str| files.iter().filter(|f| Path::new(f).ends_with(name)).count();
        assert_eq!(files.len(), 3, "{files:?}");
        assert!(
            Path::new(&files[0]).ends_with("main.scss"),
            "entry first: {files:?}"
        );
        assert_eq!(tracked("_colors.scss"), 1, "loaded relatively: {files:?}");
        assert_eq!(
            tracked("lib/_theme.scss"),
            1,
            "loaded through a load path: {files:?}"
        );
    }

    /// Every tracked path must be absolute: `include_bytes!` resolves a
    /// relative one against the invoking source file, not against `root`.
    #[test]
    fn tracked_paths_are_absolute() {
        let (_, files) = compile_main(&["lib"]).unwrap();
        for f in &files {
            assert!(Path::new(f).is_absolute(), "{f}");
        }
    }

    #[test]
    fn a_partial_it_cannot_find_fails_the_compile() {
        let err = compile_main(&[]).unwrap_err();
        assert!(err.starts_with("Can't find stylesheet to import."), "{err}");
    }
}
