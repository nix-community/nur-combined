//! Runaway recursion fails the compile with `Stack Overflow` instead of
//! overflowing the native stack, which aborts the process (#308).
//!
//! Every compile here runs on a thread whose stack size the test sets, so the
//! limits are deterministic whatever the harness's own threads get, and in
//! debug builds, whose frames are several times the size of release ones.

use std::process::Command;

use sasso::{compile, Options, Syntax};

/// Run `f` on a thread with `stack` bytes of stack and return its result. A
/// stack overflow aborts the whole test binary, which fails the test as loudly
/// as it should.
fn on_stack<T: Send + 'static>(stack: usize, f: impl FnOnce() -> T + Send + 'static) -> T {
    std::thread::Builder::new()
        .stack_size(stack)
        .spawn(f)
        .expect("spawn")
        .join()
        .expect("join")
}

/// Compile `src` on an 8 MiB thread with a 6 MiB limit.
fn compile_deep(src: String, syntax: Syntax) -> Result<String, sasso::Error> {
    on_stack(8 << 20, move || {
        compile(
            &src,
            &Options::new().with_syntax(syntax).with_stack_limit(6 << 20),
        )
    })
}

fn assert_overflows(src: String, syntax: Syntax) {
    let err = compile_deep(src, syntax).expect_err("runaway recursion must fail");
    assert_eq!(err.message, "Stack Overflow", "dart-sass's message: {err}");
}

#[test]
fn a_recursive_function_fails_instead_of_aborting() {
    assert_overflows(
        "@function f($n) { @return f($n + 1); }\na { b: f(0); }\n".into(),
        Syntax::Scss,
    );
}

#[test]
fn a_recursive_mixin_fails_instead_of_aborting() {
    assert_overflows(
        "@mixin m { a { @include m; } }\n@include m;\n".into(),
        Syntax::Scss,
    );
}

#[test]
fn a_recursive_mixin_through_content_fails_instead_of_aborting() {
    assert_overflows(
        "@mixin m($n) { @include m($n + 1) { @content; } }\na { @include m(0) { b: c; } }\n".into(),
        Syntax::Scss,
    );
}

#[test]
fn deeply_nested_rules_fail_instead_of_aborting() {
    let n = 200_000;
    assert_overflows(format!("{}b: c{}", "a{".repeat(n), "}".repeat(n)), Syntax::Scss);
}

#[test]
fn deeply_nested_parentheses_fail_instead_of_aborting() {
    let n = 200_000;
    assert_overflows(
        format!("a {{ b: {}1{}; }}", "(".repeat(n), ")".repeat(n)),
        Syntax::Scss,
    );
}

#[test]
fn a_deeply_nested_media_query_fails_instead_of_aborting() {
    let n = 200_000;
    assert_overflows(
        format!("@media {}a{} {{ a {{ b: c; }} }}", "(".repeat(n), ")".repeat(n)),
        Syntax::Scss,
    );
}

#[test]
fn a_deeply_nested_supports_condition_fails_instead_of_aborting() {
    let n = 200_000;
    assert_overflows(
        format!(
            "@supports {}a: b{} {{ a {{ b: c; }} }}",
            "(".repeat(n),
            ")".repeat(n)
        ),
        Syntax::Scss,
    );
}

#[test]
fn deeply_nested_unary_operators_fail_instead_of_aborting() {
    // `not` is the unary operator that nests: `-----1` is one identifier.
    assert_overflows(
        format!("a {{ b: {}true; }}", "not ".repeat(200_000)),
        Syntax::Scss,
    );
}

#[test]
fn deeply_nested_plain_css_fails_instead_of_aborting() {
    let n = 200_000;
    assert_overflows(format!("{}b: c{}", "a{".repeat(n), "}".repeat(n)), Syntax::Css);
}

#[test]
fn deeply_nested_indented_syntax_fails_instead_of_aborting() {
    // Indentation makes the source quadratic in its depth, so this stays at
    // 3000 levels and lowers the limit to meet it.
    let depth = 3000;
    let mut src = String::new();
    for d in 0..depth {
        src.push_str(&" ".repeat(d));
        src.push_str("a\n");
    }
    src.push_str(&" ".repeat(depth));
    src.push_str("b: c\n");
    let err = on_stack(8 << 20, move || {
        compile(
            &src,
            &Options::new()
                .with_syntax(Syntax::Sass)
                .with_stack_limit(256 << 10),
        )
    })
    .expect_err("must fail");
    assert_eq!(err.message, "Stack Overflow");
}

/// An importer that answers every load with a file importing the next one.
struct Chain;

impl sasso::Importer for Chain {
    fn canonicalize(
        &self,
        url: &str,
        _ctx: &sasso::CanonicalizeContext<'_>,
    ) -> Result<Option<sasso::CanonicalUrl>, sasso::ImporterError> {
        Ok(Some(sasso::CanonicalUrl::new(format!("chain:{url}"))))
    }
    fn load(
        &self,
        canonical: &sasso::CanonicalUrl,
    ) -> Result<Option<sasso::ImporterResult>, sasso::ImporterError> {
        let n: u64 = canonical
            .as_str()
            .trim_start_matches("chain:")
            .parse()
            .unwrap_or(0);
        Ok(Some(sasso::ImporterResult {
            contents: format!("@import \"{}\";\n", n + 1),
            syntax: Syntax::Scss,
            source_map_url: None,
        }))
    }
}

#[test]
fn an_endless_import_chain_fails_instead_of_aborting() {
    let err = on_stack(8 << 20, || {
        compile(
            "@import \"0\";\n",
            &Options::new().with_importer(&Chain).with_stack_limit(6 << 20),
        )
    })
    .expect_err("an endless chain must fail");
    assert_eq!(err.message, "Stack Overflow");
}

/// The error points at the call that recursed one level too deep, with the
/// call stack under it, as dart-sass renders it.
#[test]
fn the_error_points_at_the_recursive_call() {
    let rendered = on_stack(8 << 20, || {
        compile(
            "@function f($n) { @return f($n + 1); }\na { b: f(0); }\n",
            &Options::new().with_url("input.scss").with_stack_limit(6 << 20),
        )
        .expect_err("must fail")
        .to_string()
    });
    assert!(rendered.starts_with("Error: Stack Overflow\n"), "{rendered}");
    assert!(
        rendered.contains("^^^^^^^^^"),
        "the call is underlined: {rendered}"
    );
    assert!(
        rendered.contains("input.scss 1:27  f()"),
        "the recursion's frames: {rendered}"
    );
    let root = rendered.lines().last().unwrap_or_default();
    assert!(
        root.contains("input.scss 2:8") && root.ends_with("root stylesheet"),
        "{rendered}"
    );
}

/// Recursion within the limit still compiles: the guard costs nothing until
/// it is needed.
#[test]
fn bounded_recursion_still_compiles() {
    let css = compile_deep(
        "@function f($n) { @if $n <= 0 { @return 0; } @return f($n - 1) + 1; }\na { b: f(50); }\n".into(),
        Syntax::Scss,
    )
    .expect("50 levels is fine");
    assert!(css.contains("b: 50;"), "{css}");
}

/// With no limit set, a compile on a 1 MiB thread (a Ruby worker's stack, the
/// smallest common one) fails cleanly rather than overflowing it.
#[test]
fn the_default_limit_fits_a_one_mib_thread() {
    let err = on_stack(1 << 20, || {
        compile(
            "@function f($n) { @return f($n + 1); }\na { b: f(0); }\n",
            &Options::new(),
        )
    })
    .expect_err("must fail");
    assert_eq!(err.message, "Stack Overflow");
}

/// A compile that overflowed leaves nothing behind: the next one on the same
/// thread gets the whole limit again.
#[test]
fn a_failed_compile_does_not_shrink_the_next_ones_limit() {
    on_stack(8 << 20, || {
        let opts = Options::new().with_stack_limit(6 << 20);
        let deep = "@function f($n) { @if $n <= 0 { @return 0; } @return f($n - 1) + 1; }\na { b: f(60); }\n";
        assert!(compile(deep, &opts).is_ok());
        assert!(compile("@function g($n) { @return g($n + 1); }\na { b: g(0); }\n", &opts).is_err());
        assert!(compile(deep, &opts).is_ok(), "the same depth still compiles");
    });
}

/// The CLI reports the error and exits like any compile error (65), not with
/// an abort.
#[test]
fn the_cli_reports_a_stack_overflow_and_exits_65() {
    let dir = std::env::temp_dir().join(format!("sasso-stack-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let input = dir.join("recur.scss");
    std::fs::write(&input, "@function f($n) { @return f($n + 1); }\na { b: f(0); }\n").unwrap();
    let out = Command::new(env!("CARGO_BIN_EXE_sasso"))
        .arg(&input)
        .output()
        .unwrap();
    std::fs::remove_dir_all(&dir).ok();
    assert_eq!(
        out.status.code(),
        Some(65),
        "stderr: {}",
        String::from_utf8_lossy(&out.stderr)
    );
    assert!(String::from_utf8_lossy(&out.stderr).starts_with("Error: Stack Overflow"));
}
