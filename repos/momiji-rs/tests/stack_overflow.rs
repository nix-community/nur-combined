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

// ---- #314: depth that building the tree does not show ----------------------

/// A chain built in a loop (`a and b and …`, `1 + 1 + …`) does not grow the
/// parser's stack, but every later walk of it recurses once per operator.
#[test]
fn a_long_supports_chain_fails_instead_of_aborting() {
    let chain = vec!["(a: b)"; 500_000].join(" and ");
    assert_overflows(format!("@supports {chain} {{ a {{ b: c; }} }}"), Syntax::Scss);
}

#[test]
fn a_long_sum_fails_even_when_it_is_never_evaluated() {
    // Never called, so nothing evaluates it, but diagnostics walk it and
    // dropping the stylesheet does.
    let sum = vec!["1"; 500_000].join(" + ");
    let src = format!("@function f() {{ @return {sum}; }}\na {{ b: c; }}\n");
    let err = on_stack(8 << 20, move || {
        compile(
            &src,
            &Options::new().with_url("input.scss").with_stack_limit(6 << 20),
        )
    })
    .expect_err("must fail");
    assert_eq!(err.message, "Stack Overflow");
}

#[test]
fn long_operator_chains_fail_instead_of_aborting() {
    for op in ["-", "*", "/", "%", "==", "<", "and", "or"] {
        let chain = vec!["1"; 500_000].join(&format!(" {op} "));
        assert_overflows(format!("a {{ b: {chain}; }}"), Syntax::Scss);
    }
}

#[test]
fn a_long_filter_argument_chain_fails_instead_of_aborting() {
    let chain = vec!["a"; 500_000].join("=");
    assert_overflows(format!("a {{ b: alpha({chain}); }}"), Syntax::Scss);
}

#[test]
fn a_parenthesized_if_condition_fails_instead_of_aborting() {
    let n = 200_000;
    assert_overflows(
        format!(
            "a {{ b: if({}sass(true){}: 1; else: 0); }}",
            "(".repeat(n),
            ")".repeat(n)
        ),
        Syntax::Scss,
    );
}

/// Selector text is parsed by recursive functions that answer `Option`, so
/// reaching the limit there trips the guard and the compile still ends in
/// `Stack Overflow`, never in a selector quietly treated as unparsable.
#[test]
fn deeply_nested_pseudo_selectors_fail_instead_of_aborting() {
    let n = 20_000;
    assert_overflows(
        format!("{}a{} {{ b: c; }}", ":is(".repeat(n), ")".repeat(n)),
        Syntax::Scss,
    );
}

#[test]
fn a_nested_selector_built_at_run_time_fails_instead_of_aborting() {
    // No parser check sees this nesting: the text is assembled by the loop.
    assert_overflows(
        "$s: a;\n@for $i from 1 through 20000 { $s: \":is(\" + $s + \")\"; }\n#{$s} { b: c; }\n".into(),
        Syntax::Scss,
    );
}

/// Ordinary depth is untouched: a 100-term chain, and selectors nested a
/// realistic few levels.
#[test]
fn ordinary_chains_and_selectors_still_compile() {
    let sum = vec!["1"; 100].join(" + ");
    let css = compile_deep(format!("a {{ b: {sum}; }}\n"), Syntax::Scss).expect("100 terms");
    assert!(css.contains("b: 100;"), "{css}");
    let css =
        compile_deep(":is(:not(:where(.a, .b))) .c { d: e; }\n".into(), Syntax::Scss).expect("3 levels");
    assert!(css.contains(":is(:not(:where(.a, .b))) .c"), "{css}");
}

/// The default no longer trusts a thread's name: a 1 MiB thread named `main`
/// gets the same 768 KiB as any other, and fails cleanly.
#[test]
fn the_default_limit_ignores_the_thread_name() {
    let err = std::thread::Builder::new()
        .name("main".into())
        .stack_size(1 << 20)
        .spawn(|| {
            compile(
                "@function f($n) { @return f($n + 1); }\na { b: f(0); }\n",
                &Options::new(),
            )
        })
        .expect("spawn")
        .join()
        .expect("join")
        .expect_err("must fail");
    assert_eq!(err.message, "Stack Overflow");
}

/// `::slotted()` is scanned by its own recursive checks, which never reach the
/// charged selector parser.
#[test]
fn nested_slotted_selectors_fail_cleanly_on_a_one_mib_thread_by_default() {
    for pseudo in ["::slotted(", ":slotted("] {
        let src = format!("{}a{} {{ b: c; }}", pseudo.repeat(3000), ")".repeat(3000));
        let err = on_stack(1 << 20, move || compile(&src, &Options::new())).expect_err("must fail");
        assert_eq!(err.message, "Stack Overflow");
    }
    let built = "$s: a;\n@for $i from 1 through 3000 { $s: \"::slotted(#{$s})\"; }\n#{$s} { b: c; }\n";
    let err = on_stack(1 << 20, move || compile(built, &Options::new())).expect_err("must fail");
    assert_eq!(err.message, "Stack Overflow");
}

/// The selector case on a 1 MiB thread with the default limit: before #314
/// this aborted at about 1000 levels.
#[test]
fn nested_selectors_fail_cleanly_on_a_one_mib_thread_by_default() {
    let src = format!("{}a{} {{ b: c; }}", ":is(".repeat(3000), ")".repeat(3000));
    let err = on_stack(1 << 20, move || compile(&src, &Options::new())).expect_err("must fail");
    assert_eq!(err.message, "Stack Overflow");
}

/// A warn handler that runs a nested compile and handles its overflow leaves
/// the outer compile untouched: the outer one never reached its limit.
#[test]
fn a_handled_nested_overflow_does_not_fail_the_outer_compile() {
    let css = on_stack(8 << 20, || {
        let handler = std::rc::Rc::new(|_: &sasso::WarnEvent<'_>| {
            let inner = compile(
                "@function f($n) { @return f($n + 1); }\na { b: f(0); }\n",
                &Options::new(),
            );
            assert_eq!(
                inner.expect_err("the inner compile overflows").message,
                "Stack Overflow"
            );
        });
        compile(
            "@warn \"w\";\na { b: c; }\n",
            &Options::new()
                .with_stack_limit(6 << 20)
                .with_warn_handler(handler),
        )
    })
    .expect("the outer compile is fine");
    assert!(css.contains("b: c;"), "{css}");
}

/// `((g) and g) and g …`: each group `g` is a chain short enough to pass on
/// its own, but the tree nests them, so it is as deep as all of them
/// together. Before the chains carried their depth out, this aborted a
/// 1 MiB thread at the default limit in a release build.
fn composed(unit: &str, op: &str) -> String {
    let group = vec![unit; 1000].join(op);
    let nesting = 200;
    let mut out = "(".repeat(nesting);
    out.push_str(&group);
    for _ in 0..nesting {
        out.push(')');
        out.push_str(op);
        out.push_str(&group);
    }
    out
}

#[test]
fn chains_composed_through_parentheses_fail_instead_of_aborting() {
    let supports = format!("@supports {} {{ a {{ b: c; }} }}\n", composed("(a: b)", " and "));
    // Never called, so no evaluation fails first.
    let sum = format!(
        "@function f() {{ @return {}; }}\na {{ b: c; }}\n",
        composed("1", " + ")
    );
    for src in [supports, sum] {
        let err = on_stack(64 << 20, move || {
            compile(&src, &Options::new().with_stack_limit(60 << 20))
        })
        .expect_err("must fail");
        assert_eq!(err.message, "Stack Overflow");
    }
}

/// Sibling chains are not added up: an expression as wide as it likes is
/// only as deep as its deepest part.
#[test]
fn many_sibling_chains_still_compile() {
    let group = format!("({})", vec!["1"; 100].join(" + "));
    let list = vec![group.as_str(); 1000].join(" ");
    let css = compile_deep(format!("a {{ b: {list}; }}\n"), Syntax::Scss).expect("1000 groups");
    assert!(css.contains("b: 100 100"), "{css}");
}

/// Deep sibling groups joined by an operator, `(g) + (g) + (g)`: the tree is
/// no deeper than one group, so adding groups never makes it fail.
#[test]
fn deep_sibling_groups_joined_by_an_operator_still_compile() {
    // About 60% of the 6 MiB limit each (32 KiB a level in debug, 2.5 KiB
    // in release).
    let terms = if cfg!(debug_assertions) { 120 } else { 1500 };
    let group = format!("({})", vec!["1"; terms].join(" + "));
    let product = vec!["1"; terms].join(" * ");
    for (operand, want) in [(group, terms * 4), (product, 4)] {
        let sum = [operand.as_str(); 4].join(" + ");
        let css = compile_deep(format!("a {{ b: {sum}; }}\n"), Syntax::Scss).expect("4 groups");
        assert!(css.contains(&format!("b: {want};")), "{css}");
    }
}

/// A value nested at run time (#312): a loop builds it in a few bytes of
/// source, so no parse-time charge covers it. Each line builds `$x` (and an
/// equal `$y`) `DEPTH` levels deep: a list, a map, a calculation, and a
/// calculation function.
const DEPTH: usize = 100_000;

fn deep_values() -> [String; 4] {
    let build = |seed: &str, step: &str| {
        format!(
            "@use \"sass:list\"; @use \"sass:map\"; @use \"sass:meta\";\n\
             $x: {seed}; $y: {seed};\n\
             @for $i from 1 through {DEPTH} {{ $x: {x}; $y: {y}; }}\n",
            x = step.replace('_', "$x"),
            y = step.replace('_', "$y"),
        )
    };
    [
        build("1", "(_, 1)"),
        build("(k: 1)", "(k: _)"),
        build("1px", "calc(_ + 1%)"),
        build("1px", "min(_, 1%)"),
    ]
}

/// Compile on a 1 MiB thread with the default limit, the smallest stack a
/// compile commonly gets.
fn on_one_mib(src: String) -> Result<String, sasso::Error> {
    on_stack(1 << 20, move || compile(&src, &Options::new()))
}

/// Building, reading and dropping a deep value walks none of it, so it
/// compiles, as in dart-sass. Before #312 dropping one recursed once per
/// level and aborted the process.
#[test]
fn a_deeply_nested_value_builds_and_drops_without_aborting() {
    for prelude in deep_values() {
        for body in [
            "a { b: list.length($x); }",
            "a { b: meta.type-of(list.nth($x, 1)); }",
            "@each $i in $x { a { b: meta.type-of($i); } }",
            "a { b: list.length(list.append($x, 1)); }",
            // The same value equals itself without a walk (dart checks
            // identity first). A calculation does not: dart has no identity
            // check there, and `calc(NaN)` must stay unequal to itself.
            "a { b: if(meta.type-of($x) == calculation or $x == $x, ok, no); }",
        ] {
            let src = format!("{prelude}{body}\n");
            let css = on_one_mib(src.clone()).unwrap_or_else(|e| panic!("{body}: {e}\n{prelude}"));
            assert!(css.contains("a {"), "{body}: {css}");
        }
    }
}

/// A value whose levels share their children (`$l: ($l, $l)`) is as deep as
/// one that does not, and drops just as flat: a child held twice by the same
/// parent is released by the parent's last reference, not by a walk.
#[test]
fn a_deep_value_with_shared_children_drops_without_aborting() {
    for (step, length) in [
        ("($x, $x)", 2),
        ("(k: $x, j: $x)", 2),
        ("[$x $x]", 2),
        // A calculation's operands are separate `Rc`s around shared subtrees.
        ("calc($x + $x * var(--a))", 1),
        ("min($x, $x, 1%)", 1),
    ] {
        let src = format!(
            "@use \"sass:list\";\n$x: 1px;\n@for $i from 1 through {DEPTH} {{ $x: {step}; }}\n\
             a {{ b: list.length($x); }}\n"
        );
        let css = on_one_mib(src).unwrap_or_else(|e| panic!("{step}: {e}"));
        assert!(css.contains(&format!("b: {length};")), "{step}: {css}");
    }
}

/// Anything that walks a deep value fails with `Stack Overflow`, as dart-sass
/// does, instead of aborting: serializing, inspecting, interpolating,
/// comparing, writing it into a diagnostic, merging it.
#[test]
fn walking_a_deeply_nested_value_fails_instead_of_aborting() {
    for prelude in deep_values() {
        for body in [
            "a { b: $x; }",
            "a { b: meta.inspect($x); }",
            "a { b: \"#{$x}\"; }",
            "@debug $x;",
            "a { b: $x == $y; }",
            "a { b: $x + 1; }",
            "a { b: -$x; }",
            "a { b: list.index(($y, 1), $x); }",
            "a { b: unquote($x); }",
            "a { b: map.deep-merge((k: $x), (k: $y)); }",
        ] {
            let src = format!("{prelude}{body}\n");
            let err = on_one_mib(src).expect_err(body);
            assert_eq!(err.message, "Stack Overflow", "{body}: {err}");
        }
    }
}

/// A deep value handed to a custom function is serialized for the host: that
/// walk is guarded too, and the callback is never reached. The compile would
/// end in `Stack Overflow` either way, so the test counts the calls: a host
/// handed a truncated payload has already run on it by then.
#[test]
fn a_deeply_nested_value_passed_to_a_custom_function_fails_cleanly() {
    for prelude in deep_values() {
        let src = format!("{prelude}a {{ b: f($x); }}\n");
        let (err, calls) = on_stack(1 << 20, move || {
            let calls = std::rc::Rc::new(std::cell::Cell::new(0));
            let seen = calls.clone();
            let f: sasso::HostFunction = std::rc::Rc::new(move |_: &[u8]| {
                seen.set(seen.get() + 1);
                Err("reached the callback".into())
            });
            let result = compile(&src, &Options::new().with_function("f($v)", f));
            (result.expect_err("must fail"), calls.get())
        });
        assert_eq!(err.message, "Stack Overflow", "{prelude}");
        assert_eq!(calls, 0, "the callback ran on a truncated payload:\n{prelude}");
    }
}

/// Values of ordinary depth are unaffected, and serializing a nested list is
/// no longer quadratic: every level asked whether each of its elements was
/// blank, and that walked the whole nested list first.
#[test]
fn nested_values_of_ordinary_depth_still_serialize() {
    let css = on_one_mib(
        "$l: 1;\n@for $i from 1 through 3 { $l: ($l, 2) 3; }\n\
         $m: (k: 1);\n@for $i from 1 through 3 { $m: (k: $m); }\n\
         $c: 1px;\n@for $i from 1 through 3 { $c: calc($c + 1%); }\n\
         a { l: $l; m: inspect($m); c: $c; e: $l == $l; }\n"
            .into(),
    )
    .expect("shallow values");
    // dart-sass 1.104.1's output, byte for byte.
    assert!(css.contains("l: 1, 2 3, 2 3, 2 3;"), "{css}");
    assert!(css.contains("m: (k: (k: (k: (k: 1))));"), "{css}");
    assert!(css.contains("c: calc(1px + 1% + 1% + 1%);"), "{css}");
    assert!(css.contains("e: true;"), "{css}");
}
