//! Blank lines between top-level groups when unextended placeholder rules are
//! dropped: dart-sass separates the previous VISIBLE group from the next
//! visible node by its own group end, however many invisible nodes sat
//! between — a dropped placeholder takes only its own separator with it.

use sasso::{compile, Options};

fn css(src: &str) -> String {
    compile(src, &Options::default()).expect("compile")
}

#[test]
fn a_dropped_placeholder_with_an_empty_nested_rule_keeps_the_previous_groups_blank_line() {
    // `%video` yields two invisible nodes (its own rule and the empty
    // `%video > *`); dropping both used to remove one blank line each — the
    // group separator after `.m` as well as `%video`'s own — so the comment
    // packed tight against `.m` (the Lichess `analyse.forecast` bundle, via
    // `_extends.scss`'s `%video`).
    assert_eq!(
        css(".m {\n  a: 1;\n}\n%video {\n  width: 100%;\n  > * {\n  }\n}\n/* helps */\n.f {\n  f: 1;\n}\n"),
        ".m {\n  a: 1;\n}\n\n/* helps */\n.f {\n  f: 1;\n}"
    );
    // The same with the blank owed to an extended placeholder's group.
    assert_eq!(
        css("%metal {\n  a: 1;\n}\n%video {\n  width: 100%;\n  > * {\n  }\n}\n/* helps */\n.f {\n  @extend %metal;\n}\n"),
        ".f {\n  a: 1;\n}\n\n/* helps */"
    );
    // Two dropped placeholder statements in a row, then a visible rule.
    assert_eq!(
        css(".m {\n  a: 1;\n}\n%p {\n  p: 1;\n}\n%q {\n  q: 1;\n}\n.f {\n  f: 1;\n}\n"),
        ".m {\n  a: 1;\n}\n\n.f {\n  f: 1;\n}"
    );
    // A dropped placeholder right after a comment: the comment packs tight,
    // so no blank appears from the placeholder's own group end.
    assert_eq!(
        css("/* c */\n%p {\n  p: 1;\n}\n.f {\n  f: 1;\n}\n"),
        "/* c */\n.f {\n  f: 1;\n}"
    );
    // Leading and trailing placeholders leave no stray blank line.
    assert_eq!(
        css("%p {\n  p: 1;\n}\n.f {\n  f: 1;\n}\n%q {\n  q: 1;\n}\n"),
        ".f {\n  f: 1;\n}"
    );
    // A trailing run of dropped rules whose last member is preceded by an
    // earlier dropped group's end marker: the run's separator still goes.
    assert_eq!(
        css(".f {\n  f: 1;\n}\n%p {\n  p: 1;\n  > * {\n  }\n}\n%q {\n  q: 1;\n}\n"),
        ".f {\n  f: 1;\n}"
    );
    assert_eq!(
        css(".f {\n  f: 1;\n}\n%p {\n  p: 1;\n}\n%q {\n  q: 1;\n}\n"),
        ".f {\n  f: 1;\n}"
    );
}
