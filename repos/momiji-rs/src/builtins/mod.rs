//! The built-in function library.
//!
//! Each family lives in its own module and exposes `try_call`, returning
//! `Some(result)` for the names it owns and `None` otherwise. The
//! dispatcher tries the families in turn and falls back to preserving an
//! unknown function verbatim as a plain CSS call (`translate(...)`,
//! `var(...)`), matching dart-sass.
//!
//! The modules are disjoint, so new families can be implemented in
//! parallel: an implementer fills one `try_call` without touching another.

mod color;
mod color_ext;
// The plain-CSS filter overloads, in the one spelling both the dispatcher and
// the evaluator's deprecations read them from: the global rule, the narrower
// module rule, and the Microsoft `alpha()` form.
pub(crate) use color::legacy::{ms_filter_args, ms_filter_text};
pub(crate) use color_ext::{is_plain_css_filter_call, module_filter_arg, plain_filter_text, ModuleFilterArg};
mod colorspace;
mod list;
mod map;
mod math;
mod meta;
mod selector;
mod string;

use crate::error::Error;
use crate::fxhash::{FxHashMap, FxHashSet};
use crate::scanner::Pos;
use crate::value::{Color, Number, SassStr, Value};

// dart-sass `inspect()` serialization. The one-rule-wider form a diagnostic
// embeds (`Value::to_inspect_message`) is built on it.
pub(crate) use meta::inspect_value;

// Color-space conversion, needed by `ModernColor::to_css` for the
// out-of-range `color-mix(in …, color(xyz …) 100%, black)` fallback.
pub(crate) use color::convert_modern;
// Color <-> space conversion helpers reused by the host-function value bridge
// (src/host_fn.rs) to serialize/reconstruct colors across the embedder boundary.
pub(crate) use color::{legacy_to_modern, make_modern_in};

// The engine's srgb <-> hsl and hwb -> srgb (dart's exact formulas): the
// legacy out-of-gamut rgb serialization in `value.rs` converts one way, and
// the degenerate-channel `hsl()` constructor the other.
pub(crate) use colorspace::{hsl_to_srgb, hwb_to_srgb, srgb_to_hsl};

/// Dispatch a function call by name across the builtin families.
pub(crate) fn call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<Value, Error> {
    // `_` and `-` are the same character in a Sass identifier, so a global
    // built-in answers to either spelling (`map_get(…)` IS `map-get(…)`), like
    // the module members `call_module` already normalizes. Only the LOOKUP is
    // canonicalized: a name that turns out to be no builtin at all falls
    // through to plain CSS spelled exactly as it was written.
    let written = name;
    let lookup = canonical_name(name);
    let name = lookup.as_ref();
    // dart verifies the arguments against the declaration BEFORE the body runs
    // — measured: `math.abs("a", $x: 1)` is `No parameter named $x.`, not
    // `"a" is not a number.` — so this is the first thing, ahead of every
    // family (#62).
    if let Some(f) = global_member(name) {
        verify_args(f, pos_args, named, pos)?;
        if f.rest().is_some() {
            return reject_leftover(f, named, pos, call_body(name, written, pos_args, named, pos));
        }
    }
    call_body(name, written, pos_args, named, pos)
}

/// [`call`]'s dispatch, split out so the rest-parameter post-check can wrap it.
fn call_body(
    name: &str,
    written: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<Value, Error> {
    if let Some(r) = color::try_call(name, pos_args, named, pos) {
        return r;
    }
    if let Some(r) = color_ext::try_call(name, pos_args, named, pos) {
        return r;
    }
    if let Some(r) = math::try_call(name, pos_args, named, pos) {
        return r;
    }
    if let Some(r) = string::try_call(name, pos_args, named, pos) {
        return r;
    }
    // Map runs before list so `length`/`nth` on a map are handled here; the
    // map family declines those names for non-map arguments, falling through.
    if let Some(r) = map::try_call(name, pos_args, named, pos) {
        return r;
    }
    if let Some(r) = list::try_call(name, pos_args, named, pos) {
        return r;
    }
    if let Some(r) = meta::try_call(name, pos_args, named, pos) {
        return r;
    }
    if let Some(r) = selector::try_call(name, pos_args, named, pos) {
        return r;
    }
    plain_css_function(written, pos_args, named, pos)
}

/// The `[color-functions]` suggestions for a deprecated legacy `sass:color`
/// member, or `None` when the member carries no such deprecation. See
/// [`color::deprecate`].
pub(crate) fn color_function_suggestions(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
) -> Option<Vec<String>> {
    color::deprecate::suggestions(name, pos_args, named)
}

/// The name-only half of [`color_function_suggestions`]: whether `name` is a
/// legacy `sass:color` member that carries a `[color-functions]` deprecation at
/// all. Lets a caller reject a call before evaluating any suggestion text.
pub(crate) fn color_function_deprecates(name: &str) -> bool {
    color::deprecate::deprecates(name)
}

/// A name in its canonical spelling: `_` is `-` in every Sass identifier. The
/// input is borrowed unchanged when it already holds no underscore, so the
/// common case allocates nothing.
fn canonical_name(name: &str) -> std::borrow::Cow<'_, str> {
    if name.contains('_') {
        std::borrow::Cow::Owned(name.replace('_', "-"))
    } else {
        std::borrow::Cow::Borrowed(name)
    }
}

/// Whether `name` is a real Sass builtin function (as opposed to an unknown
/// plain CSS function that is preserved verbatim). Used by the evaluator to
/// decide whether a slash-division argument should collapse to its number:
/// Sass functions collapse it, plain CSS functions keep the `a/b` spelling.
///
/// This is a pure name-only ownership test: each family's `try_call` decides
/// ownership solely from the function name (returning `Some(..)` — possibly an
/// arity/type `Err` — for the names it owns, `None` otherwise). To kill the
/// old two-point sync hazard, each family now declares its owned names in a
/// `pub(super) const NAMES` placed directly above its `try_call` (the source of
/// truth), and this test is exactly the union of those per-family `NAMES`. A new
/// builtin is therefore a single-site change in its family module.
///
/// Two name-only subtleties mirror the dispatch exactly:
/// - the `math` family lowercases the name before matching (its functions
///   double as case-insensitive CSS calc functions like `SiN`), so `math::NAMES`
///   holds the *lowercase* names and is tested against the lowercased input;
/// - `length`/`nth` are owned unconditionally by the `list` family (the `map`
///   family only claims them when the first argument is a map, which never
///   removes them from the builtin set), so they live in `list::NAMES` and are
///   deliberately absent from `map::NAMES`.
pub(crate) fn is_builtin(name: &str) -> bool {
    // Underscore and dash are one character in a Sass identifier, so the test
    // runs on the canonical spelling (`str_index` is `str-index`).
    let canonical = canonical_name(name);
    let name = canonical.as_ref();
    if member_index().builtins.contains(name) {
        return true;
    }
    // The `math` family matches `name.to_ascii_lowercase()`, so it owns its
    // names case-insensitively. The set holds them lowercase, so only a name
    // with an uppercase letter can still be one of them.
    name.bytes().any(|b| b.is_ascii_uppercase()) && is_math_builtin_name(name)
}

/// Every family's `NAMES`, whose union is [`is_builtin`]. `math::NAMES` is the
/// lowercase spelling of names that family owns case-insensitively.
const FAMILY_NAMES: [&[&str]; 9] = [
    math::NAMES,
    color::NAMES,
    color::MODERN_NAMES,
    color_ext::NAMES,
    string::NAMES,
    map::NAMES,
    list::NAMES,
    meta::NAMES,
    selector::NAMES,
];

/// Whether `name` (case-insensitively) is a `math` builtin. `math::NAMES` holds
/// the lowercase spellings, because the family's own dispatcher
/// (`math::try_call`) lowercases before it matches — so `SiN` and `sin` both count.
/// The comparison here folds case in place instead of allocating a lowercase
/// copy of `name` just to compare it.
fn is_math_builtin_name(name: &str) -> bool {
    math::NAMES.iter().any(|n| name.eq_ignore_ascii_case(n))
}

// ---- shared argument helpers, available to every family module --------

/// The argument at index `i`: positional first, then by name (`params[i]`).
pub(super) fn arg<'v>(
    params: &[&str],
    pos_args: &'v [Value],
    named: &'v [(String, Value)],
    i: usize,
) -> Option<&'v Value> {
    if let Some(v) = pos_args.get(i) {
        return Some(v);
    }
    let pname = params.get(i)?;
    named.iter().find(|(n, _)| n == pname).map(|(_, v)| v)
}

/// Like [`arg`] but errors with a "missing argument" message when absent.
///
/// dart names only the PARAMETER (`Missing argument $amount.`) — never the
/// function — because the frame underneath already points at the declaration
/// the parameter belongs to. A user-defined function's message has always read
/// that way here; this is the built-in half of the same sentence.
pub(super) fn require<'v>(
    params: &[&str],
    pos_args: &'v [Value],
    named: &'v [(String, Value)],
    i: usize,
    pos: Pos,
) -> Result<&'v Value, Error> {
    arg(params, pos_args, named, i).ok_or_else(|| {
        let pname = params.get(i).copied().unwrap_or("");
        Error::at(format!("Missing argument ${pname}."), pos)
    })
}

/// dart's `ArgumentDeclaration.verify` for a built-in, in the order dart
/// raises it. Measured 2026-09-28 against dart-sass 1.104.1 across all 116
/// module members; the numbers are how many of them answered each way.
///
/// ```text
///   1. Missing argument $x.                 105 of 116 answer this to f($nope: 1)
///   2. Only N positional arguments allowed, but M were passed.
///   3. No parameter named $x. / No parameters named $x, $y or $z.
/// ```
///
/// Rule 1 outranking rule 3 is why this exists as one function rather than a
/// check bolted on in front: `list.nth($nope: 1)` is `Missing argument $list.`,
/// not `No parameter named $nope.`, and the old `list.rs` copy — the only
/// built-in that checked at all — had rule 3 first and so answered the wrong
/// one (#62).
///
/// Rule 0 is [`argument_passed_twice`], which outranks all three and is shared
/// with the user-callable binder so the two paths cannot disagree (#147).
///
/// A REST parameter is verified elsewhere. dart binds the rest and runs the
/// body, and only complains about a leftover named argument afterwards —
/// measured: `math.max("a" "b", $x: 1)` is `("a" "b") is not a number.`, while
/// the fixed-arity `math.abs("a", $x: 1)` is `No parameter named $x.`. So rules
/// 2 and 3 do not apply before the call, and rule 1 still does.
fn verify_args(f: &Fun, pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<(), Error> {
    let Some(_) = f.params else {
        return Ok(()); // see `no_sig`
    };
    let declared = f.named_params();

    // With no named argument, rules 0 and 3 cannot fire and rule 1 is a count.
    // Nearly every call a stylesheet makes takes this path.
    if named.is_empty() {
        if let Some(param) = declared.iter().take(f.required).nth(pos_args.len()) {
            return Err(Error::at(format!("Missing argument ${param}."), pos));
        }
        if f.rest().is_some() {
            return Ok(());
        }
        return check_arity(declared.len(), pos_args, named, pos);
    }

    // 0. A parameter given both ways outranks everything below — measured, and
    //    `list.nth(1, 2, 3, $list: 4)` is the duplicate rather than the
    //    overflow (#147).
    if let Some(msg) = argument_passed_twice(declared.iter().copied(), pos_args.len(), |name| {
        named.iter().any(|(n, _)| canonical_name(n).as_ref() == name)
    }) {
        return Err(Error::at(msg, pos));
    }

    // 1. A required parameter with no value, positional or named. dart names
    //    the FIRST one.
    for (i, param) in declared.iter().take(f.required).enumerate() {
        if pos_args.len() > i {
            continue;
        }
        if named.iter().any(|(n, _)| canonical_name(n).as_ref() == *param) {
            continue;
        }
        return Err(Error::at(format!("Missing argument ${param}."), pos));
    }

    if f.rest().is_some() {
        return Ok(());
    }

    // 2. Too many positional arguments — only the positional ones count.
    check_arity(declared.len(), pos_args, named, pos)?;

    // 3. Whatever is left over. dart lists them in the order they were
    //    written, and joins with a comma and a final `or` — measured:
    //    `No parameters named $x, $y or $z.`, with no comma before `or`.
    let leftover: Vec<&str> = named
        .iter()
        .map(|(n, _)| n.as_str())
        .filter(|n| {
            let c = canonical_name(n);
            !declared.contains(&c.as_ref())
        })
        .collect();
    if let Some(err) = no_parameter_named(&leftover, pos) {
        return Err(err);
    }
    Ok(())
}

/// dart's FIRST argument rule: a parameter given both positionally and by name.
/// The message, or `None` when no parameter was.
///
/// ```text
///   Argument $x was passed both by position and by name.
/// ```
///
/// Shared by the built-in verifier and the user-callable binder, because it
/// outranks every other argument error in both — measured 2026-09-29 against
/// dart-sass 1.104.1:
///
/// ```text
///   list.nth(1 2 3, $list: 4)               the duplicate, though $n is missing too
///   list.nth(1, 2, 3, $list: 4)             the duplicate, not the overflow
///   list.nth(1 2 3, 1, $list: 4, $nope: 5)  the duplicate, not the unknown name
/// ```
///
/// Three details that a plausible implementation gets wrong:
///
/// - **No plural.** `f(1, 2, 3, $a: 9, $b: 9, $c: 9)` names `$a` alone, where
///   the unrecognized-name rule would have said `$a, $b or $c`.
/// - **DECLARATION order, not written order.** `f(1, 2, $b: 9, $a: 9)` also
///   names `$a`.
/// - **The call's spelling does not matter.** `string.slice("abc", 1, 2,
///   $start_at: 9)` is reported against the declaration's `$start-at`, so the
///   comparison canonicalizes the ARGUMENT and the message quotes the
///   PARAMETER.
///
/// The comparison canonicalizes the declared name and the message quotes it as
/// WRITTEN. Two of the three callers cannot tell the difference — the member
/// table declares every parameter with dashes
/// (`every_declared_parameter_is_already_canonical`) and a user `@function`'s
/// parameters are normalized by the parser — which is why an earlier draft left
/// the canonicalization out and two mutation cases survived.
///
/// `host_fn` is the caller that needs it: `Options::with_function("foo($a_b)")`
/// keeps the signature's own spelling, so without canonicalizing
/// `foo(1, $a-b: 2)` reads as no duplicate at all. dart agrees on both halves,
/// measured 2026-09-29 through its JS API:
///
/// ```text
///   foo($a_b)  foo(1, $a-b: 2)   Argument $a_b was passed both by position and by name.
///   foo($a-b)  foo(1, $a_b: 2)   Argument $a-b was passed both by position and by name.
/// ```
///
/// A user `@function` cannot reach that: its declaration's original spelling is
/// gone by the time any message exists, so `@function f($a_b)` is quoted `$a-b`
/// where dart quotes `$a_b` — wider than this rule (`Missing argument` differs
/// the same way) and recorded separately.
pub(crate) fn argument_passed_twice<'a>(
    declared: impl IntoIterator<Item = &'a str>,
    positional: usize,
    was_named: impl Fn(&str) -> bool,
) -> Option<String> {
    declared
        .into_iter()
        .take(positional)
        .find(|name| was_named(canonical_name(name).as_ref()))
        .map(|name| format!("Argument ${name} was passed both by position and by name."))
}

/// dart's message for names that match no parameter, or `None` when there are
/// none. Plural from two up, joined with a comma and a final `or` and NO comma
/// before it: `No parameters named $x, $y or $z.` — measured 2026-09-28.
///
/// The names are reported in the order they were WRITTEN, not sorted.
fn no_parameter_named(names: &[&str], pos: Pos) -> Option<Error> {
    let (last, init) = names.split_last()?;
    let msg = if init.is_empty() {
        format!("No parameter named ${last}.")
    } else {
        let head = init
            .iter()
            .map(|n| format!("${n}"))
            .collect::<Vec<_>>()
            .join(", ");
        format!("No parameters named {head} or ${last}.")
    };
    Some(Error::at(msg, pos))
}

/// A named argument that matches no parameter of `declared`, as dart's
/// `No parameter named $x.`.
///
/// `declared` matters because a rest parameter usually sits behind named
/// parameters that ARE addressable — `map.get($map, $key, $keys...)` answers
/// `map.get((a: 1), $key: a)` with `1` in both compilers.
fn reject_named(declared: &[&str], named: &[(String, Value)], pos: Pos) -> Result<(), Error> {
    // `declared` matters: a rest parameter usually sits behind named parameters
    // that ARE addressable — `map.get($map, $key, $keys...)` answers
    // `map.get((a: 1), $key: a)` with `1` in both compilers. Rejecting every
    // name here broke that, which a re-measure caught.
    let names: Vec<&str> = named
        .iter()
        .map(|(n, _)| n.as_str())
        .filter(|n| !declared.contains(&canonical_name(n).as_ref()))
        .collect();
    match no_parameter_named(&names, pos) {
        Some(err) => Err(err),
        None => Ok(()),
    }
}

/// The other half of [`verify_args`], for a REST parameter: dart binds the rest,
/// RUNS THE BODY, and only then complains about a named argument the body did
/// not consume.
///
/// The order is observable, which is why this is a post-check and not part of
/// `verify_args` — measured 2026-09-28:
///
/// ```text
///   math.max("a" "b", $x: 1)   ("a" "b") is not a number.       the body
///   list.slash(1, $x: 2)       At least two elements are required.
///   math.max($x: 1)            At least one argument must be passed.
///   math.max(1, 2, $x: 3)      No parameter named $x.           the leftover
/// ```
///
/// A first attempt put the check inside each built-in, before the body's own
/// validation; `a_built_in_rejects_an_unrecognized_named_argument` failed on the
/// first of those and this replaced it.
fn reject_leftover(
    f: &Fun,
    named: &[(String, Value)],
    pos: Pos,
    out: Result<Value, Error>,
) -> Result<Value, Error> {
    // Only for a rest parameter — a fixed-arity member was fully verified up
    // front — and only when the body does not read the keywords itself.
    if f.rest().is_none() || f.reads_keywords || named.is_empty() {
        return out;
    }
    let value = out?;
    reject_named(f.named_params(), named, pos)?;
    Ok(value)
}

/// Verify a module member's arguments for a caller that dispatches the member
/// ITSELF rather than through [`call_module`].
///
/// `sass:meta`'s evaluator-owned members are the case: `try_meta_eval_call`
/// answers thirteen of them from the evaluator's own state and returns before
/// `call_module` is reached, so without this they were the one part of the table
/// nothing checked — `meta.variable-exists("v", $nope: 1)` answered `true`
/// (r4128127579), and that is one of the shapes #62 was filed about.
pub(crate) fn verify_member_args(
    module: &str,
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<(), Error> {
    let canonical = canonical_name(member);
    match member_of(module, canonical.as_ref()) {
        Some(f) => verify_args(f, pos_args, named, pos),
        None => Ok(()),
    }
}

/// The `Fun` row for a module member, for [`verify_args`].
fn member_of(module: &str, member: &str) -> Option<&'static Fun> {
    member_index().members[module_slot(module)?].get(member).copied()
}

/// Every [`Fun`] row, keyed both ways a call can name it, and every global
/// built-in name. Built once per process, because verification runs ahead of
/// EVERY built-in call and a linear walk of all seven tables there was
/// measurable (#260). So was [`is_builtin`]'s walk of every family's names,
/// which the evaluator asks on every global call.
struct MemberIndex {
    /// By [`module_slot`], then by member name.
    members: [FxHashMap<&'static str, &'static Fun>; MODULES.len()],
    globals: FxHashMap<&'static str, &'static Fun>,
    /// The union of [`FAMILY_NAMES`].
    builtins: FxHashSet<&'static str>,
}

/// The modules [`members_of`] describes, in the order [`global_member`] has
/// always searched them: the first to name a global is the one that answers.
const MODULES: [&str; 7] = ["math", "color", "list", "map", "selector", "string", "meta"];

/// `module`'s position in [`MODULES`].
fn module_slot(module: &str) -> Option<usize> {
    MODULES.iter().position(|m| *m == module)
}

fn member_index() -> &'static MemberIndex {
    static INDEX: std::sync::OnceLock<MemberIndex> = std::sync::OnceLock::new();
    INDEX.get_or_init(|| {
        // The index outlives the compile that first asks for it, so it must not
        // be allocated in that compile's arena.
        let _paused = crate::arena::pause();
        let mut index = MemberIndex {
            members: Default::default(),
            globals: FxHashMap::default(),
            builtins: FAMILY_NAMES.iter().flat_map(|f| f.iter().copied()).collect(),
        };
        for (slot, module) in MODULES.iter().enumerate() {
            let Some(m) = members_of(module) else { continue };
            for f in m.functions {
                // First wins in both maps, as the linear `find` this replaces
                // did: a later row never shadows an earlier one.
                index.members[slot].entry(f.name).or_insert(f);
                if let Some(g) = f.global.filter(|g| !CALCULATION_GLOBALS.contains(g)) {
                    index.globals.entry(g).or_insert(f);
                }
            }
        }
        index
    })
}

/// The `Fun` row a GLOBAL name is a view of, or `None` when this build does not
/// know the global's parameters.
///
/// Only the members that name a global alias, which is 81 of the 116. The rest
/// keep their previous behaviour at the global spelling, for two measured
/// reasons: a deprecated colour global (`lighten`) shares its name with a
/// module-only member, and `max`/`min`/`clamp`/`round` are also CSS math
/// functions whose named-argument error is a different sentence entirely
/// (`Keyword arguments can't be used with calculations.`, #215). Matching by
/// member NAME would give those dart's Sass-function message where dart gives
/// the calculation one.
fn global_member(name: &str) -> Option<&'static Fun> {
    member_index().globals.get(name).copied()
}

/// The globals dart treats as CSS CALCULATIONS rather than as Sass functions,
/// so a named argument there is a different sentence entirely:
/// `Keyword arguments can't be used with calculations.` (#215).
///
/// They must stay out of [`global_member`], or the module member's declaration
/// answers for the calculation and reports `No parameter named $x.` — which is
/// what this rewrite did until a review caught it (r4128303276). The MODULE
/// spelling is unaffected and verified as usual: `math.sin(1, $nope: 2)` is
/// `No parameter named $nope.` in both compilers, and only the bare `sin(…)`
/// is a calculation.
///
/// Measured 2026-09-28 by asking dart `<g>(…, $nope: 9)` for every global that
/// names a math function. The split is not "is it a CSS math function" — these
/// answer with the calculation sentence:
///
/// ```text
///   acos asin atan atan2 clamp cos exp hypot log mod pow rem sign sin sqrt tan
/// ```
///
/// …while `abs`, `ceil`, `floor`, `max`, `min`, `percentage`, `round`, `unit`,
/// `unitless`, `random` and `comparable` answer as Sass functions and are
/// verified here. `clamp`, `exp`, `mod`, `rem` and `sign` are in the list for
/// completeness: they name no member with a global alias, so they never reach
/// this lookup anyway.
const CALCULATION_GLOBALS: &[&str] = &[
    "acos", "asin", "atan", "atan2", "clamp", "cos", "exp", "hypot", "log", "mod", "pow", "rem", "sign",
    "sin", "sqrt", "tan",
];

/// dart's arity check (`ArgumentDeclaration.verify`): only POSITIONAL
/// arguments count against a function's parameter count, and the moment any
/// NAMED argument is present the message says so —
/// `lighten(red, 10%, 3, $nope: 1)` is "Only 2 positional arguments allowed,
/// but 3 were passed.", counting the three positional ones, not the four
/// arguments written.
///
/// A named argument that matches no parameter is a separate error, which dart
/// raises after this one — and which sasso does not raise at all yet outside
/// `list.rs`'s `validate_args` (momiji-rs/sasso#62). Nothing downstream checks
/// it: `require` only looks a parameter up BY name, so an unrecognized one is
/// simply never read.
pub(crate) fn check_arity(
    max: usize,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<(), Error> {
    let n = pos_args.len();
    if n <= max {
        return Ok(());
    }
    let noun = if max == 1 { "argument" } else { "arguments" };
    let kind = if named.is_empty() { "" } else { "positional " };
    let verb = if n == 1 { "was" } else { "were" };
    Err(Error::at(
        format!("Only {max} {kind}{noun} allowed, but {n} {verb} passed."),
        pos,
    ))
}

/// Extract an `f64` from a number value (ignoring its unit).
pub(super) fn num(v: &Value, pname: Option<&str>, pos: Pos) -> Result<f64, Error> {
    match v {
        Value::Number(n) => Ok(n.value),
        other => Err(type_error(other, pname, "number", pos)),
    }
}

/// dart's "<value> is not a <type>." with the PARAMETER the value failed to
/// bind to in front of it.
///
/// Both halves were missing here and are one sentence, so they are one
/// function (#139):
///
/// - The prefix names the parameter, not the function — `color.mix(null, red)`
///   is `$color1: …` and `color.mix(red, null)` is `$color2: …`. It is
///   information the CALL SITE has, which is why the two helpers below take a
///   name rather than inventing one. Where dart has no parameter to name — a
///   value that came out of a rest list — it prints no prefix, and
///   `math.max(1, "x")` already matched.
/// - The value is spelled as [`Value::to_inspect_message`], dart's own
///   `toString`, not as CSS: `null` is `null` rather than nothing at all, and
///   an unbracketed list is parenthesized so its separator is not read as the
///   sentence's punctuation.
///
/// The parameter is the one the value was BOUND to, which is not always the one
/// the message goes on to talk about: `rgb(1 2 3 / "x")` binds `$channels` and
/// says so, where `rgb(1, 2, 3, "x")` binds `$alpha`; `color(srgb 1 2 3 / "x")`
/// says `$description`; and `color.hwb(1, 2%, 3%, "x")`, whose channels list
/// sasso synthesizes rather than receives, names nothing at all.
///
/// Measured against dart-sass 1.104.1 on 2026-09-29; the spelling rule was
/// measured for every list shape, including the single-element ones
/// `inspect` already parenthesizes and must not be wrapped twice.
pub(super) fn type_error(v: &Value, pname: Option<&str>, want: &str, pos: Pos) -> Error {
    let msg = match pname {
        Some(p) => format!("${p}: {} is not a {want}.", v.to_inspect_message()),
        // A value that came out of a REST list was not bound to a parameter, so
        // dart names none: `math.max(1, "x")` is `"x" is not a number.` where
        // the fixed-arity `math.abs("x")` is `$number: "x" is not a number.`.
        // An `Option` rather than an empty string, so a caller has to decide.
        None => format!("{} is not a {want}.", v.to_inspect_message()),
    };
    Error::at(msg, pos)
}

/// Extract a color value.
pub(super) fn as_color(v: &Value, pname: Option<&str>, pos: Pos) -> Result<Color, Error> {
    match v {
        Value::Color(c) => Ok(c.clone()),
        other => Err(type_error(other, pname, "color", pos)),
    }
}

/// Reject a non-legacy color passed to a legacy-only modification function
/// (`darken`/`lighten`/`saturate`/`desaturate`/`opacify`/`transparentize`/
/// `adjust-hue`), matching dart-sass's "<fn>() is only supported for legacy
/// colors." error. `fname` is the called name (hyphenated, no `()`).
pub(super) fn require_legacy_color(c: &Color, fname: &str, pos: Pos) -> Result<(), Error> {
    if c.modern.as_ref().is_some_and(|m| !m.space.is_legacy()) {
        return Err(Error::at(
            format!(
                "{fname}() is only supported for legacy colors. Please use color.adjust() \
                 instead with an explicit $space argument."
            ),
            pos,
        ));
    }
    Ok(())
}

/// Extract an RGB channel value (`0..=255`), converting a percentage.
pub(super) fn channel(v: &Value, pos: Pos) -> Result<f64, Error> {
    match v {
        Value::Number(n) => {
            if n.unit() == "%" {
                // `255 * value / 100`, in dart's order: see `modern_channel`.
                Ok((255.0 * n.value / 100.0).clamp(0.0, 255.0))
            } else {
                Ok(n.value.clamp(0.0, 255.0))
            }
        }
        // No `$param:` prefix, because nothing is known to reach this arm:
        // `validate_numeric` runs first and rejects a non-numeric channel with
        // dart's own `Expected <channel> channel to be a number, was …`. 13
        // shapes were tried against dart-sass 1.104.1 (2026-09-29) — a quoted
        // string, a `var()`, a `calc()`, a degenerate `calc(infinity)`, a
        // division — and every one of them was caught earlier, identically on
        // both compilers. The spelling is still dart's, so if a path ever does
        // arrive the sentence is right as far as it goes.
        other => Err(Error::at(
            format!("{} is not a number.", other.to_inspect_message()),
            pos,
        )),
    }
}

/// Clamp a value to `[0, 1]` (e.g. alpha).
pub(super) fn clamp01(v: f64) -> f64 {
    v.clamp(0.0, 1.0)
}

/// Preserve an unknown function call verbatim as an unquoted CSS string.
/// Plain CSS has no keyword arguments, and a value with no CSS
/// representation (an empty unbracketed list, a map) is rejected — while
/// `null` serializes to nothing and a bracketed empty list stays `[]`
/// (dart-sass).
fn plain_css_function(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<Value, Error> {
    if !named.is_empty() {
        return Err(Error::at(
            "Plain CSS functions don't support keyword arguments.",
            pos,
        ));
    }
    let mut parts: Vec<String> = Vec::with_capacity(pos_args.len());
    for v in pos_args {
        match v {
            Value::List(l) if l.items.is_empty() && !l.bracketed => {
                return Err(Error::at("() isn't a valid CSS value.", pos));
            }
            Value::Map(_) => {
                return Err(Error::at(
                    format!("{} isn't a valid CSS value.", v.to_inspect_message()),
                    pos,
                ));
            }
            _ => parts.push(v.to_css(false)),
        }
    }
    Ok(Value::Str(SassStr {
        text: format!("{name}({})", parts.join(", ")).into(),
        quoted: false,
    }))
}

// ---- built-in module system (`@use "sass:<mod>"`) ----------------------

/// The `sass:*` member dart names when a GLOBAL built-in with a module
/// equivalent is called — the `global-builtin` deprecation's `Use … instead.`
/// line. `None` for a global dart keeps: a CSS function it shares a name with
/// (`abs`, `round`, `min`, `sqrt`, …), `if()` (which has its own deprecation),
/// and `ie-hex-str`, which has no module form.
///
/// Every entry was measured against dart-sass 1.103.1 — the mapping is not
/// mechanical: the legacy colour adjusters all point at `color.adjust`,
/// `unitless` at `math.is-unitless`, `comparable` at `math.compatible`, and
/// `list-separator` at `list.separator`.
pub(crate) fn global_builtin_replacement(name: &str) -> Option<&'static str> {
    // Matched EXACTLY apart from the underscore spelling every Sass identifier
    // allows: dart resolves these Sass-only globals case-sensitively, so
    // `MAP-GET(…)` and `FLOOR(…)` are plain CSS to it — no call, and so no
    // deprecation — while `map_get(…)` is the deprecated `map-get(…)`. (The
    // case-insensitive globals are the ones CSS shares, `abs`/`round`/`min`/
    // `sin`/…, none of which are deprecated.)
    let canonical = canonical_name(name);
    Some(match canonical.as_ref() {
        // sass:color — the getters keep their names, every legacy adjuster
        // becomes `color.adjust`.
        "red" => "color.red",
        "green" => "color.green",
        "blue" => "color.blue",
        "hue" => "color.hue",
        "saturation" => "color.saturation",
        "lightness" => "color.lightness",
        "alpha" => "color.alpha",
        "opacity" => "color.opacity",
        "mix" => "color.mix",
        "invert" => "color.invert",
        "grayscale" => "color.grayscale",
        "complement" => "color.complement",
        "change-color" => "color.change",
        "scale-color" => "color.scale",
        "adjust-color" | "adjust-hue" | "lighten" | "darken" | "saturate" | "desaturate" | "opacify"
        | "fade-in" | "transparentize" | "fade-out" => "color.adjust",
        // sass:math — only the members CSS has no function for.
        "percentage" => "math.percentage",
        "floor" => "math.floor",
        "ceil" => "math.ceil",
        "random" => "math.random",
        "unit" => "math.unit",
        "unitless" => "math.is-unitless",
        "comparable" => "math.compatible",
        // sass:list
        "length" => "list.length",
        "nth" => "list.nth",
        "set-nth" => "list.set-nth",
        "join" => "list.join",
        "append" => "list.append",
        "zip" => "list.zip",
        "index" => "list.index",
        "list-separator" => "list.separator",
        "is-bracketed" => "list.is-bracketed",
        // sass:map
        "map-get" => "map.get",
        "map-merge" => "map.merge",
        "map-remove" => "map.remove",
        "map-keys" => "map.keys",
        "map-values" => "map.values",
        "map-has-key" => "map.has-key",
        // sass:string
        "quote" => "string.quote",
        "unquote" => "string.unquote",
        "to-upper-case" => "string.to-upper-case",
        "to-lower-case" => "string.to-lower-case",
        "str-length" => "string.length",
        "str-index" => "string.index",
        "str-insert" => "string.insert",
        "str-slice" => "string.slice",
        "unique-id" => "string.unique-id",
        // sass:meta
        "type-of" => "meta.type-of",
        "inspect" => "meta.inspect",
        "keywords" => "meta.keywords",
        "call" => "meta.call",
        "get-function" => "meta.get-function",
        "function-exists" => "meta.function-exists",
        "feature-exists" => "meta.feature-exists",
        "variable-exists" => "meta.variable-exists",
        "global-variable-exists" => "meta.global-variable-exists",
        "mixin-exists" => "meta.mixin-exists",
        "content-exists" => "meta.content-exists",
        // sass:selector
        "selector-parse" => "selector.parse",
        "selector-append" => "selector.append",
        "selector-nest" => "selector.nest",
        "selector-unify" => "selector.unify",
        "selector-replace" => "selector.replace",
        "selector-extend" => "selector.extend",
        "is-superselector" => "selector.is-superselector",
        "simple-selectors" => "selector.simple-selectors",
        _ => return None,
    })
}

/// Whether `module` names a built-in `sass:*` module this build supports.
pub(crate) fn is_module(module: &str) -> bool {
    module_name(module).is_some()
}

/// The canonical name of the built-in module `module` names, as a `'static`
/// string, or `None` when there is no such module.
///
/// The set is closed and known at compile time, so a namespace bound by
/// `@use "sass:math"` points at the program's own copy of the name instead of
/// owning one: the tables that hold them are cloned into every callable's
/// lexical environment and read back on every `ns.member()` call.
pub(crate) fn module_name(module: &str) -> Option<&'static str> {
    crate::value::BuiltinModule::from_name(module).map(crate::value::BuiltinModule::name)
}

/// One built-in module's members, in DART'S DECLARATION ORDER.
///
/// The order is part of the observable behaviour: `meta.module-functions()`
/// returns a map, Sass maps keep insertion order, and dart returns members as
/// declared rather than sorted — `module-functions("meta")` begins
/// `feature-exists, inspect, type-of, keywords`. Sorting is right for a user
/// module, whose members are discovered, and wrong for a built-in, whose list
/// is dart's source file.
///
/// `global` is the global builtin that implements the member, or `None` when
/// there is no global alias — either because the member is module-only
/// (`math.div`, `map.set`, `string.split`, `list.slash`) and dispatched
/// directly in [`call_module`], or because it needs evaluator state that this
/// value-only layer does not have (`meta.call` and friends), or because it is
/// one of the nine adjusters CSS Color 4 removed, which exist in order to
/// FAIL (see [`color::removed`]).
struct Members {
    functions: &'static [Fun],
    mixins: &'static [&'static str],
    variables: &'static [&'static str],
}

/// One function member: its name, the global that implements it, and dart's
/// parameter declaration.
struct Fun {
    name: &'static str,
    global: Option<&'static str>,
    /// dart's parameters, in order, a rest parameter written with dart's own
    /// `...` suffix (`&["map", "key", "keys..."]`). `None` for the two members
    /// this table does not describe — see [`no_sig`], and
    /// `only_the_overloaded_members_go_unverified`, which pins which two.
    params: Option<&'static [&'static str]>,
    /// How many leading `params` have no default, so omitting one is
    /// `Missing argument $x.`. A rest parameter requires nothing.
    required: usize,
    /// Whether the implementation READS the keywords its rest parameter
    /// collected, so a named argument is part of its interface rather than a
    /// mistake. Only meaningful with a rest parameter; see [`f_kw`].
    reads_keywords: bool,
    /// Whether the last of `params` is a rest parameter, decided once when the
    /// table is built rather than by a suffix test on every call (#260).
    has_rest: bool,
}

impl Fun {
    /// The rest parameter's name, if the last parameter is one.
    fn rest(&self) -> Option<&'static str> {
        if !self.has_rest {
            return None;
        }
        self.params?.last()?.strip_suffix("...")
    }

    /// The named parameters, excluding a rest parameter — a rest parameter is
    /// not addressable by name, which is measured: dart answers
    /// `math.max(1, $numbers: 2)` with `No parameter named $numbers.`.
    fn named_params(&self) -> &'static [&'static str] {
        let all = self.params.unwrap_or(&[]);
        &all[..all.len() - self.has_rest as usize]
    }
}

/// A member with dart's signature, measured from the declaration dart prints
/// under an argument error:
///
/// ```text
///   Error: Missing argument $start-at.
///     ┌──> sass:string
///   1 │ @function slice($string, $start-at, $end-at: -1) {
///     │           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ declaration
/// ```
///
/// Every one of the 116 members was read that way on 2026-09-28 against
/// dart-sass 1.104.1, and the global spelling shares the declaration — a
/// `str-slice()` error prints `@function slice(…)` — so one row serves both.
const fn f(
    name: &'static str,
    global: Option<&'static str>,
    params: &'static [&'static str],
    required: usize,
) -> Fun {
    Fun {
        name,
        global,
        params: Some(params),
        required,
        reads_keywords: false,
        has_rest: ends_in_rest(params),
    }
}

/// A member whose rest parameter's KEYWORDS are its interface, so a named
/// argument that matches no declared parameter is handed to the body instead of
/// being rejected. Six members, measured: `color.adjust`/`change`/`scale` take
/// channel adjustments that way (`color.adjust(red, $lightness: 10%)`),
/// `map.merge` and `map.set` accept `$map2`/`$key`/`$value`, and `meta.call`
/// forwards everything to the function it calls.
///
/// dart decides this at RUNTIME — it checks whether the body actually read the
/// keywords (`ArgumentList.keywordsAccessed`) — which shows in `map.set`:
/// `map.set((a: 1), $key: b, $value: 2)` reads them, `map.set((a: 1), b, 2,
/// $nope: 3)` does not, and dart rejects `$nope` only in the second. A row
/// cannot express that, so these six accept a leftover name where dart's body
/// would have complained about it instead. The gap is one message, not one
/// answer, and it is the same gap #147 records for user callables.
const fn f_kw(
    name: &'static str,
    global: Option<&'static str>,
    params: &'static [&'static str],
    required: usize,
) -> Fun {
    Fun {
        name,
        global,
        params: Some(params),
        required,
        reads_keywords: true,
        has_rest: ends_in_rest(params),
    }
}

/// A member whose parameters this table does NOT describe, so nothing is
/// verified for it and its behaviour is unchanged. Two members, each for a
/// measured reason:
///
/// - `color.hwb` is OVERLOADED by arity — `hwb($channels)` or
///   `hwb($hue, $whiteness, $blackness, $alpha: 1)` — and the two declare
///   DIFFERENT names, so a single row cannot say which applies before counting
///   the arguments. (`map.remove` is overloaded too and does not need this: its
///   overloads declare the same names and differ only in arity, which a rest
///   parameter allows.)
/// - `color.alpha` never prints a declaration at all: dart answers both
///   `alpha(red, blue)` and `alpha(red, $x: 1)` with the self-contradictory
///   `Only 1 argument allowed, but 1 were passed.`, from the legacy
///   `alpha(opacity=20)` IE-filter overload.
const fn no_sig(name: &'static str, global: Option<&'static str>) -> Fun {
    Fun {
        name,
        global,
        params: None,
        required: 0,
        reads_keywords: false,
        has_rest: false,
    }
}

/// Whether the last parameter is written with dart's `...` rest suffix.
const fn ends_in_rest(params: &[&str]) -> bool {
    let Some(last) = params.last() else {
        return false;
    };
    let b = last.as_bytes();
    b.len() >= 3 && b[b.len() - 3] == b'.' && b[b.len() - 2] == b'.' && b[b.len() - 1] == b'.'
}

/// The table every member question is answered from.
///
/// One source of truth, because the alternative was two: a `match` that could
/// say whether `get` is in `sass:map` but not what `sass:map` contains, plus a
/// hand-written list beside it for the things the match could not express. The
/// per-family `NAMES` consts exist to stop exactly that kind of pair drifting,
/// and the module members needed the same treatment (#64).
///
/// Measured against dart-sass 1.104.1 on 2026-09-28, through
/// `map.keys(meta.module-functions(…))` for the names and order and
/// `meta.function-exists($module:)` for membership: across the seven modules,
/// 116 functions (24 math, 37 color, 10 list, 9 map, 8 selector, 10 string, 18
/// meta), 2 mixins and 7 variables. The three members that disagreed are noted
/// where they sit.
///
/// The first spelling of this paragraph said 93, which is not a count of
/// anything here (r4118793518). A number in a comment cannot fail, so the one
/// that can is in [`tests::the_table_holds_no_more_and_no_less`] — this
/// paragraph is a dated measurement record, and that test is the guard.
fn members_of(module: &str) -> Option<&'static Members> {
    Some(match module {
        "math" => &MATH_MEMBERS,
        "color" => &COLOR_MEMBERS,
        "list" => &LIST_MEMBERS,
        "map" => &MAP_MEMBERS,
        "selector" => &SELECTOR_MEMBERS,
        "string" => &STRING_MEMBERS,
        "meta" => &META_MEMBERS,
        _ => return None,
    })
}

/// `sass:math`.
///
/// No `exp` and no `sign`: dart has neither as a Sass function, and
/// `meta.function-exists("exp", $module: "math")` is `false` there. They still
/// COMPUTE in both compilers — `exp(1)` is `2.7182818285` — because they are
/// CSS math functions, which is a different thing from a module member. sasso
/// listing them here made the `$module:`-qualified lookup lie.
static MATH_MEMBERS: Members = Members {
    functions: &[
        f("abs", Some("abs"), &["number"], 1),
        f("acos", Some("acos"), &["number"], 1),
        f("asin", Some("asin"), &["number"], 1),
        f("atan", Some("atan"), &["number"], 1),
        f("atan2", Some("atan2"), &["y", "x"], 2),
        f("ceil", Some("ceil"), &["number"], 1),
        // The numeric forms, dispatched in `call_module`, distinct from the
        // global CSS-calc functions of the same name which preserve unknown
        // arguments.
        f("clamp", None, &["min", "number", "max"], 3),
        f("cos", Some("cos"), &["number"], 1),
        f("compatible", Some("comparable"), &["number1", "number2"], 2),
        f("floor", Some("floor"), &["number"], 1),
        f("hypot", Some("hypot"), &["numbers..."], 0),
        f("is-unitless", Some("unitless"), &["number"], 1),
        f("log", Some("log"), &["number", "base"], 1),
        f("max", None, &["numbers..."], 0),
        f("min", None, &["numbers..."], 0),
        f("percentage", Some("percentage"), &["number"], 1),
        f("pow", Some("pow"), &["base", "exponent"], 2),
        f("random", Some("random"), &["limit"], 0),
        f("round", None, &["number"], 1),
        f("sin", Some("sin"), &["number"], 1),
        f("sqrt", Some("sqrt"), &["number"], 1),
        f("tan", Some("tan"), &["number"], 1),
        f("unit", Some("unit"), &["number"], 1),
        // Last in dart's list, not alphabetical: true division, unit-aware.
        f("div", None, &["number1", "number2"], 2),
    ],
    mixins: &[],
    // Resolved by `module_var`, not callable.
    variables: &[
        "e",
        "pi",
        "epsilon",
        "max-safe-integer",
        "min-safe-integer",
        "max-number",
        "min-number",
    ],
};

/// `sass:color`.
///
/// The nine adjusters CSS Color 4 removed — `adjust-hue`, `lighten`, `darken`,
/// `saturate`, `desaturate`, `opacify`, `fade-in`, `transparentize`,
/// `fade-out` — are members that always FAIL, and being members is the point:
/// they are found by `meta.function-exists`, captured by `meta.get-function`,
/// re-exported by `@forward "sass:color"`, and shadow the global of the same
/// name under `@use "sass:color" as *`, where dart reports the removal instead
/// of running the deprecated global.
static COLOR_MEMBERS: Members = Members {
    functions: &[
        f("red", Some("red"), &["color"], 1),
        f("green", Some("green"), &["color"], 1),
        f("blue", Some("blue"), &["color"], 1),
        f("mix", Some("mix"), &["color1", "color2", "weight", "method"], 2),
        f("invert", Some("invert"), &["color", "weight", "space"], 1),
        f("hue", Some("hue"), &["color"], 1),
        f("saturation", Some("saturation"), &["color"], 1),
        f("lightness", Some("lightness"), &["color"], 1),
        f("adjust-hue", None, &["color", "amount"], 2),
        f("lighten", None, &["color", "amount"], 2),
        f("darken", None, &["color", "amount"], 2),
        // Two parameters, measured: `color.saturate($nope: 1)` is
        // `Missing argument $color.` and `color.saturate(10%)` is
        // `Missing argument $amount.`. The GLOBAL `saturate` is a different
        // declaration — `saturate($amount)`, the CSS filter function, asymmetric
        // with `desaturate($color, $amount)` — which is why this row must keep
        // `global: None`; `the_global_saturate_is_not_this_declaration` pins it.
        f("saturate", None, &["color", "amount"], 2),
        f("desaturate", None, &["color", "amount"], 2),
        f("grayscale", Some("grayscale"), &["color"], 1),
        // Module-only: the comma form has no global alias, and the two
        // deprecated getters live only in the module list.
        no_sig("hwb", None),
        f("whiteness", None, &["color"], 1),
        f("blackness", None, &["color"], 1),
        f("opacify", None, &["color", "amount"], 2),
        f("fade-in", None, &["color", "amount"], 2),
        f("transparentize", None, &["color", "amount"], 2),
        f("fade-out", None, &["color", "amount"], 2),
        no_sig("alpha", Some("alpha")),
        f("opacity", Some("opacity"), &["color"], 1),
        // The CSS Color 4 members, under disambiguated global names.
        f("space", Some("color-space"), &["color"], 1),
        f("to-space", Some("color-to-space"), &["color", "space"], 2),
        f("is-legacy", Some("color-is-legacy"), &["color"], 1),
        f("is-missing", Some("color-is-missing"), &["color", "channel"], 2),
        f("is-in-gamut", Some("color-is-in-gamut"), &["color", "space"], 1),
        f(
            "to-gamut",
            Some("color-to-gamut"),
            &["color", "space", "method"],
            1,
        ),
        f(
            "channel",
            Some("color-channel"),
            &["color", "channel", "space"],
            2,
        ),
        f("same", Some("color-same"), &["color1", "color2"], 2),
        f(
            "is-powerless",
            Some("color-is-powerless"),
            &["color", "channel", "space"],
            2,
        ),
        f("complement", Some("complement"), &["color", "space"], 1),
        f_kw("adjust", Some("adjust-color"), &["color", "kwargs..."], 1),
        f_kw("scale", Some("scale-color"), &["color", "kwargs..."], 1),
        f_kw("change", Some("change-color"), &["color", "kwargs..."], 1),
        f("ie-hex-str", Some("ie-hex-str"), &["color"], 1),
    ],
    mixins: &[],
    variables: &[],
};

/// `sass:list`.
static LIST_MEMBERS: Members = Members {
    functions: &[
        f("length", Some("length"), &["list"], 1),
        f("nth", Some("nth"), &["list", "n"], 2),
        f("set-nth", Some("set-nth"), &["list", "n", "value"], 3),
        f(
            "join",
            Some("join"),
            &["list1", "list2", "separator", "bracketed"],
            2,
        ),
        f("append", Some("append"), &["list", "val", "separator"], 2),
        f("zip", Some("zip"), &["lists..."], 0),
        f("index", Some("index"), &["list", "value"], 2),
        f("is-bracketed", Some("is-bracketed"), &["list"], 1),
        f("separator", Some("list-separator"), &["list"], 1),
        // Module-only, and the one member dart had that sasso did not.
        f("slash", None, &["elements..."], 0),
    ],
    mixins: &[],
    variables: &[],
};

/// `sass:map`.
static MAP_MEMBERS: Members = Members {
    functions: &[
        f("get", Some("map-get"), &["map", "key", "keys..."], 2),
        // Module-only: no global alias in dart.
        f_kw("set", None, &["map", "args..."], 1),
        f_kw("merge", Some("map-merge"), &["map1", "args..."], 1),
        // dart overloads this by arity — `remove($map)` or
        // `remove($map, $key, $keys...)` — and the two collapse into one row
        // because they declare the SAME names and differ only in how many
        // positional arguments they take, which a rest parameter already allows.
        f("remove", Some("map-remove"), &["map", "key", "keys..."], 1),
        f("keys", Some("map-keys"), &["map"], 1),
        f("values", Some("map-values"), &["map"], 1),
        f("has-key", Some("map-has-key"), &["map", "key", "keys..."], 2),
        f("deep-merge", None, &["map1", "map2"], 2),
        f("deep-remove", None, &["map", "key", "keys..."], 2),
    ],
    mixins: &[],
    variables: &[],
};

/// `sass:selector`.
static SELECTOR_MEMBERS: Members = Members {
    functions: &[
        f("is-superselector", Some("is-superselector"), &["super", "sub"], 2),
        f("simple-selectors", Some("simple-selectors"), &["selector"], 1),
        f("parse", Some("selector-parse"), &["selector"], 1),
        f("nest", Some("selector-nest"), &["selectors..."], 0),
        f("append", Some("selector-append"), &["selectors..."], 0),
        f(
            "extend",
            Some("selector-extend"),
            &["selector", "extendee", "extender"],
            3,
        ),
        f(
            "replace",
            Some("selector-replace"),
            &["selector", "original", "replacement"],
            3,
        ),
        f("unify", Some("selector-unify"), &["selector1", "selector2"], 2),
    ],
    mixins: &[],
    variables: &[],
};

/// `sass:string`.
static STRING_MEMBERS: Members = Members {
    functions: &[
        f("unquote", Some("unquote"), &["string"], 1),
        f("quote", Some("quote"), &["string"], 1),
        f("to-upper-case", Some("to-upper-case"), &["string"], 1),
        f("to-lower-case", Some("to-lower-case"), &["string"], 1),
        f("length", Some("str-length"), &["string"], 1),
        f("insert", Some("str-insert"), &["string", "insert", "index"], 3),
        f("index", Some("str-index"), &["string", "substring"], 2),
        f("slice", Some("str-slice"), &["string", "start-at", "end-at"], 2),
        f("unique-id", Some("unique-id"), &[], 0),
        // Module-only.
        f("split", None, &["string", "separator", "limit"], 2),
    ],
    mixins: &[],
    variables: &[],
};

/// `sass:meta`.
///
/// Most of these need the evaluator's scopes, definitions or call state, so
/// they have no entry in this value-only layer's dispatch and carry `None`.
/// They are still members, which is what `meta.module-functions("meta")` and
/// every `$module`-qualified lookup ask.
static META_MEMBERS: Members = Members {
    functions: &[
        f("feature-exists", Some("feature-exists"), &["feature"], 1),
        f("inspect", Some("inspect"), &["value"], 1),
        f("type-of", Some("type-of"), &["value"], 1),
        f("keywords", None, &["args"], 1),
        f("calc-name", Some("calc-name"), &["calc"], 1),
        f("calc-args", Some("calc-args"), &["calc"], 1),
        f("accepts-content", None, &["mixin"], 1),
        f("global-variable-exists", None, &["name", "module"], 1),
        f("variable-exists", None, &["name"], 1),
        f("function-exists", None, &["name", "module"], 1),
        f("mixin-exists", None, &["name", "module"], 1),
        f("content-exists", None, &[], 0),
        f("module-variables", None, &["module"], 1),
        f("module-functions", None, &["module"], 1),
        f("module-mixins", None, &["module"], 1),
        f("get-function", None, &["name", "css", "module"], 1),
        f("get-mixin", None, &["name", "module"], 1),
        f_kw("call", None, &["function", "args..."], 1),
    ],
    mixins: &["load-css", "apply"],
    variables: &[],
};

/// A built-in module's FUNCTION members, in dart's order.
///
/// Built from the one table rather than sitting beside it: the names and the
/// global aliases are the same rows, so a member cannot be in one and missing
/// from the other. The `Vec` is the cost of that — a `&[(&str, Option<&str>)]`
/// cannot be re-borrowed as `&[&str]` — and it is paid only by
/// `meta.module-functions()`, which is not on any hot path.
///
/// Empty for a module this build does not know, which is what dart answers for
/// a namespace that is not a built-in; the caller has resolved the namespace
/// by then.
pub(crate) fn module_function_names(module: &str) -> Vec<&'static str> {
    members_of(module).map_or_else(Vec::new, |m| m.functions.iter().map(|f| f.name).collect())
}

/// A built-in module's MIXIN members, in dart's order.
pub(crate) fn module_mixin_names(module: &str) -> &'static [&'static str] {
    members_of(module).map_or(&[], |m| m.mixins)
}

/// A built-in module's VARIABLE members, in dart's order.
pub(crate) fn module_variable_names(module: &str) -> &'static [&'static str] {
    members_of(module).map_or(&[], |m| m.variables)
}

/// Translate a `(module, member)` pair to the global builtin that implements
/// it, or `None` when the member has no global alias — see [`Members`].
pub(crate) fn module_member_to_global(module: &str, member: &str) -> Option<&'static str> {
    member_of(module, member)?.global
}

/// Whether `module` exposes `member` as a FUNCTION.
///
/// Functions only, and deliberately: every caller asks this for
/// `MemberKind::Function` and the other two kinds have their own answerers
/// (`is_builtin_mixin`, `module_var`). Counting mixins and variables here made
/// `meta.function-exists("load-css", $module: "meta")` and
/// `("pi", $module: "math")` answer `true` where dart answers `false` — a
/// regression this rewrite introduced and its own mutation sweep caught.
///
/// A member with no global alias still counts: `map.set` is dispatched
/// directly in [`call_module`], and the nine removed colour adjusters exist in
/// order to fail.
pub(crate) fn module_has_member(module: &str, member: &str) -> bool {
    let canonical = canonical_name(member);
    let member = canonical.as_ref();
    members_of(module).is_some_and(|m| m.functions.iter().any(|f| f.name == member))
}

/// The `sass:meta` members that are ALSO global functions and are owned by the
/// evaluator rather than by this value-only layer: each resolves against the
/// evaluator's scopes, definitions or call state, so none of them appears in a
/// family `NAMES` table and [`is_builtin`] does not know them. dart exposes
/// them like any other global — callable, referenceable through
/// `get-function`, and deprecated for being global — so the places that need
/// the full global picture consult this list alongside `is_builtin`.
pub(crate) const EVAL_GLOBAL_NAMES: &[&str] = &[
    "call",
    "content-exists",
    "function-exists",
    "get-function",
    "global-variable-exists",
    "keywords",
    "mixin-exists",
    "variable-exists",
];

/// Call a module member `module.member(args)`, dispatching to the reused global
/// implementation. An unknown member is "Undefined function." (dart-sass).
pub(crate) fn call_module(
    module: &str,
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<Value, Error> {
    // Member names are dash/underscore-interchangeable like every Sass
    // identifier (`string.unique_id()` is `string.unique-id()`).
    let normalized;
    let member = if member.contains('_') {
        normalized = member.replace('_', "-");
        normalized.as_str()
    } else {
        member
    };
    // Against dart's declaration first, for the same reason as in [`call`] —
    // and here for every member, not only the ones that name a global.
    if let Some(f) = member_of(module, member) {
        verify_args(f, pos_args, named, pos)?;
        if f.rest().is_some() {
            return reject_leftover(
                f,
                named,
                pos,
                call_module_body(module, member, pos_args, named, pos),
            );
        }
    }
    call_module_body(module, member, pos_args, named, pos)
}

/// [`call_module`]'s dispatch, split out as [`call_body`] is.
fn call_module_body(
    module: &str,
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<Value, Error> {
    // `math.div(a, b)` is true (always-divide) division, unit-aware.
    if module == "math" && member == "div" {
        return math::module_div(pos_args, named, pos);
    }
    // `math.clamp`/`math.min`/`math.max` are the numeric forms, not the
    // CSS-calc functions of the same name.
    if module == "math" {
        match member {
            "clamp" => return math::module_clamp(pos_args, named, pos),
            "min" => return math::module_min_max(pos_args, pos, true),
            "max" => return math::module_min_max(pos_args, pos, false),
            "round" => return math::module_round(pos_args, named, pos),
            _ => {}
        }
    }
    // `sass:map` members without a global alias (`set`, `deep-merge`,
    // `deep-remove`).
    if module == "map" {
        if let Some(r) = map::call_module_member(member, pos_args, named, pos) {
            return r;
        }
    }
    // `sass:string` members without a global alias (`split`).
    if module == "string" {
        if let Some(r) = string::call_module_member(member, pos_args, named, pos) {
            return r;
        }
    }
    // `sass:list` members without a global alias (`slash`).
    if module == "list" {
        if let Some(r) = list::call_module_member(member, pos_args, pos) {
            return r;
        }
    }
    // `sass:color` members without a global alias (the comma-form `hwb`, and
    // the deprecated HWB getters `whiteness`/`blackness`).
    if module == "color" {
        // The removed adjusters go first: they own their names outright on this
        // module (the surviving implementations of those names are GLOBAL only),
        // and their message is the whole point of the member existing.
        if let Some(r) = color::removed::call_module_member(member, pos_args, named, pos) {
            return r;
        }
        if let Some(r) = color::call_module_member(member, pos_args, named, pos) {
            return r;
        }
        if let Some(r) = color_ext::call_module_member(member, pos_args, named, pos) {
            return r;
        }
        // `color.grayscale`/`color.invert`/`color.opacity` keep the global
        // filter overload only for a NUMBER (passed through, and deprecated by
        // the evaluator). Every other plain-CSS-special argument — `var(--c)`,
        // `env(…)`, an unsimplifiable `calc()`, a slash-separated list — is a
        // colour argument here and fails as one, where the global spelling
        // passes it through verbatim. `module_filter_arg` is that rule, and the
        // deprecation asks it too, so the two cannot disagree (#124).
        if let Some((ModuleFilterArg::NotAColor, v)) = module_filter_arg(member, pos_args, named) {
            return Err(Error::at(
                format!("$color: {} is not a color.", v.to_inspect_message()),
                pos,
            ));
        }
    }
    // Straight to the dispatch, not through [`call`]: [`call_module`] already
    // verified these arguments against this member's row, and the global is a
    // view of the same row (`a_module_members_global_is_the_same_row`), so a
    // second lookup and verification would repeat the first (#260).
    match module_member_to_global(module, member) {
        Some(global) => call_body(global, global, pos_args, named, pos),
        None => Err(Error::at("Undefined function.".to_string(), pos)),
    }
}

/// Resolve a built-in module variable (`math.$pi`, etc.). An unknown member is
/// "Undefined variable.".
///
/// The TABLE decides which names exist and the match below decides what they
/// are worth, so the two cannot disagree about membership — which they could
/// when this hard-coded its own list beside [`Members::variables`], and
/// `meta.module-variables()` enumerated from one while `global-variable-exists`
/// answered from the other (r4119082581). `sass:math` is no longer named here
/// either: it is the only module the table gives variables, so the lookup says
/// so instead of a second place repeating it.
pub(crate) fn module_var(module: &str, name: &str, pos: Pos) -> Result<Value, Error> {
    let undefined = || Error::at("Undefined variable.".to_string(), pos);
    let canonical = canonical_name(name);
    let name = canonical.as_ref();
    if !module_variable_names(module).contains(&name) {
        return Err(undefined());
    }
    let number = |value: f64| Ok(Value::Number(Number::unitless(value)));
    match name {
        "pi" => number(std::f64::consts::PI),
        "e" => number(std::f64::consts::E),
        "epsilon" => number(f64::EPSILON),
        "max-safe-integer" => number(9_007_199_254_740_991.0),
        "min-safe-integer" => number(-9_007_199_254_740_991.0),
        "max-number" => number(f64::MAX),
        // The smallest positive (subnormal) double, matching dart-sass's
        // `$min-number` (`5e-324`), not the smallest *normal* value.
        "min-number" => number(f64::from_bits(1)),
        // A name the table lists and this does not answer. Unreachable while
        // they agree, which `every_listed_variable_has_a_value` is what makes
        // true rather than hoped for.
        _ => Err(undefined()),
    }
}

#[cfg(test)]
mod tests {
    use super::{is_builtin, module_function_names, module_has_member, module_member_to_global};

    /// Every member of every module, in DART'S ORDER, written out.
    ///
    /// Literals, not derived from the table they check — deriving them would
    /// make this adapt to a change instead of catching it, which a mutation
    /// sweep caught doing in `link_destination`'s boundary cases. Measured
    /// from dart-sass 1.104.1 on 2026-09-28 with
    /// `map.keys(meta.module-functions(…))`; a map keeps insertion order, so
    /// those keys ARE dart's declaration order.
    const DART_FUNCTIONS: &[(&str, &[&str])] = &[
        (
            "math",
            &[
                "abs",
                "acos",
                "asin",
                "atan",
                "atan2",
                "ceil",
                "clamp",
                "cos",
                "compatible",
                "floor",
                "hypot",
                "is-unitless",
                "log",
                "max",
                "min",
                "percentage",
                "pow",
                "random",
                "round",
                "sin",
                "sqrt",
                "tan",
                "unit",
                "div",
            ],
        ),
        (
            "color",
            &[
                "red",
                "green",
                "blue",
                "mix",
                "invert",
                "hue",
                "saturation",
                "lightness",
                "adjust-hue",
                "lighten",
                "darken",
                "saturate",
                "desaturate",
                "grayscale",
                "hwb",
                "whiteness",
                "blackness",
                "opacify",
                "fade-in",
                "transparentize",
                "fade-out",
                "alpha",
                "opacity",
                "space",
                "to-space",
                "is-legacy",
                "is-missing",
                "is-in-gamut",
                "to-gamut",
                "channel",
                "same",
                "is-powerless",
                "complement",
                "adjust",
                "scale",
                "change",
                "ie-hex-str",
            ],
        ),
        (
            "list",
            &[
                "length",
                "nth",
                "set-nth",
                "join",
                "append",
                "zip",
                "index",
                "is-bracketed",
                "separator",
                "slash",
            ],
        ),
        (
            "map",
            &[
                "get",
                "set",
                "merge",
                "remove",
                "keys",
                "values",
                "has-key",
                "deep-merge",
                "deep-remove",
            ],
        ),
        (
            "selector",
            &[
                "is-superselector",
                "simple-selectors",
                "parse",
                "nest",
                "append",
                "extend",
                "replace",
                "unify",
            ],
        ),
        (
            "string",
            &[
                "unquote",
                "quote",
                "to-upper-case",
                "to-lower-case",
                "length",
                "insert",
                "index",
                "slice",
                "unique-id",
                "split",
            ],
        ),
        (
            "meta",
            &[
                "feature-exists",
                "inspect",
                "type-of",
                "keywords",
                "calc-name",
                "calc-args",
                "accepts-content",
                "global-variable-exists",
                "variable-exists",
                "function-exists",
                "mixin-exists",
                "content-exists",
                "module-variables",
                "module-functions",
                "module-mixins",
                "get-function",
                "get-mixin",
                "call",
            ],
        ),
    ];

    /// dart's four rules, in dart's order, measured.
    ///
    /// Literals, not built from the table: the point is to catch the table and
    /// the verifier moving together. Every line was read from dart-sass 1.104.1
    /// on 2026-09-28 (#62).
    const ARGUMENT_ERRORS: &[(&str, &str, &[&str], &str)] = &[
        // rule 0 (passed twice) outranks every one of them, including a
        // missing argument, an overflow and an unrecognized name in the same
        // call.
        (
            "list",
            "nth",
            &["1 2 3", "1", "$list: 4"],
            "Argument $list was passed both by position and by name.",
        ),
        (
            "list",
            "nth",
            &["1 2 3", "$list: 4"],
            "Argument $list was passed both by position and by name.",
        ),
        (
            "list",
            "nth",
            &["1", "2", "3", "$list: 4"],
            "Argument $list was passed both by position and by name.",
        ),
        (
            "list",
            "nth",
            &["1 2 3", "1", "$list: 4", "$nope: 5"],
            "Argument $list was passed both by position and by name.",
        ),
        // …in DECLARATION order, not the order the names were written, and
        // never in the plural — the unrecognized-name rule would have said
        // `$string, $start-at or $end-at`.
        (
            "string",
            "slice",
            &["\"abc\"", "1", "2", "$end-at: 9", "$string: \"z\""],
            "Argument $string was passed both by position and by name.",
        ),
        (
            "string",
            "slice",
            &[
                "\"abc\"",
                "1",
                "2",
                "$string: \"z\"",
                "$start-at: 9",
                "$end-at: 9",
            ],
            "Argument $string was passed both by position and by name.",
        ),
        // The comparison canonicalizes and the message does NOT: a `$start_at`
        // argument is reported against the declaration's `$start-at`.
        (
            "string",
            "slice",
            &["\"abc\"", "1", "2", "$start_at: 9"],
            "Argument $start-at was passed both by position and by name.",
        ),
        // A name matching a parameter BEFORE a rest parameter is a duplicate.
        // (The rest's own name being no parameter at all is a case for
        // `tests/parity.rs` instead: for a rest signature the leftover check is
        // a POST-check, so `verify_args` alone answers `None` for it by design.)
        (
            "map",
            "get",
            &["(a: 1)", "a", "$map: (b: 2)"],
            "Argument $map was passed both by position and by name.",
        ),
        // rule 1 (missing) outranks rule 3 (unrecognized), which is the
        // ordering `list.rs`'s old copy got backwards.
        ("list", "nth", &["$nope: 1"], "Missing argument $list."),
        ("list", "nth", &["1 2 3", "$nope: 1"], "Missing argument $n."),
        ("string", "slice", &["$nope: 1"], "Missing argument $string."),
        // …and a near-miss on a real parameter's name is still rule 1, because
        // the parameter it was meant for is the one reported.
        (
            "list",
            "nth",
            &["$lst: 1 2 3", "$n: 1"],
            "Missing argument $list.",
        ),
        // rule 2 counts only the POSITIONAL arguments, and says so once a
        // named one is present.
        (
            "math",
            "abs",
            &["1", "2", "$nope: 1"],
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "list",
            "nth",
            &["1 2 3", "1", "2", "$nope: 1"],
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "string",
            "slice",
            &["1", "2", "3", "4"],
            "Only 3 arguments allowed, but 4 were passed.",
        ),
        // rule 3, once nothing above applies.
        (
            "string",
            "to-upper-case",
            &["\"a\"", "$nope: 1"],
            "No parameter named $nope.",
        ),
        ("math", "abs", &["1", "$nope: 1"], "No parameter named $nope."),
        ("color", "red", &["red", "$nope: 1"], "No parameter named $nope."),
        (
            "string",
            "slice",
            &["$string: \"abc\"", "$start-at: 1", "$end: 2"],
            "No parameter named $end.",
        ),
        // …in the plural, joined with a final `or` and no comma before it.
        (
            "list",
            "nth",
            &["1 2 3", "1", "$x: 1", "$y: 2"],
            "No parameters named $x or $y.",
        ),
        (
            "list",
            "nth",
            &["1 2 3", "1", "$x: 1", "$y: 2", "$z: 3"],
            "No parameters named $x, $y or $z.",
        ),
    ];

    /// An OPTIONAL parameter passed by name must still be accepted — the
    /// verifier's job is to reject what dart rejects, and nothing else.
    const ACCEPTED: &[(&str, &str, &[&str])] = &[
        ("string", "slice", &["\"abcd\"", "2", "$end-at: 3"]),
        // Underscores and dashes are the same character, so the spelling of
        // the name cannot decide whether it is recognized.
        ("string", "slice", &["\"abcd\"", "2", "$end_at: 3"]),
        // …and for a REQUIRED parameter too, which is a different branch: rule
        // 1 has to canonicalize the name it looks for, or `$start_at` reads as
        // absent and the call fails with `Missing argument $start-at.` where
        // dart answers `"bcd"`.
        ("string", "slice", &["$string: \"abcd\"", "$start_at: 2"]),
        ("list", "set-nth", &["$list: 1 2", "$n: 1", "$value: 9"]),
        ("map", "has-key", &["$map: (a: 1)", "$key: a"]),
        // The two with no recorded signature are verified for nothing, so
        // arguments that would break any of the three rules still get through.
        // `map.remove` is NOT one of them — its overloads collapse into a rest
        // parameter — so these cases check that it is verified and still accepts
        // every arity and its `$key`.
        ("color", "hwb", &["red"]),
        ("map", "remove", &["(a: 1, b: 2)", "b"]),
        ("map", "remove", &["(a: 1)"]),
        ("map", "remove", &["(a: 1, b: 2)", "$key: b"]),
        ("color", "alpha", &["red"]),
        ("math", "log", &["8", "$base: 2"]),
        ("color", "invert", &["red", "$weight: 100%"]),
        (
            "list",
            "join",
            &["(1)", "(2)", "$separator: comma", "$bracketed: true"],
        ),
        // NOT a duplicate: the positional arguments stopped before this
        // parameter, so naming it is the only way it was passed. `take(n)` in
        // `argument_passed_twice` is what makes this pass, and dropping it
        // rejects every optional argument given by name.
        ("string", "slice", &["\"abcd\"", "$start-at: 2"]),
        ("list", "nth", &["$list: 1 2 3", "$n: 1"]),
        ("color", "mix", &["red", "blue", "$weight: 10%"]),
        // A REST parameter takes any number of positional arguments, so rule 2
        // must not fire for one.
        ("map", "get", &["(a: 1)", "a"]),
        ("math", "max", &["1", "2", "3", "4", "5"]),
    ];

    /// Every case in [`ARGUMENT_ERRORS`] is what the verifier answers, and
    /// every case in [`ACCEPTED`] gets through it.
    #[test]
    fn the_verifier_answers_what_dart_answers() {
        for (module, member, args, want) in ARGUMENT_ERRORS {
            let got = verify_call(module, member, args);
            assert_eq!(
                got.as_deref(),
                Some(*want),
                "{module}.{member}({})",
                args.join(", ")
            );
        }
        for (module, member, args) in ACCEPTED {
            assert_eq!(
                verify_call(module, member, args),
                None,
                "{module}.{member}({}) should pass verification",
                args.join(", ")
            );
        }
    }

    /// Run only the verifier for `module.member(args…)`, returning its message.
    ///
    /// The arguments are written as they would be in a stylesheet — `"$n: 1"`
    /// for a named one — and only their SHAPE matters here, because dart
    /// verifies before the body runs and so never looks at the values.
    fn verify_call(module: &str, member: &str, args: &[&str]) -> Option<String> {
        let mut pos_args = Vec::new();
        let mut named = Vec::new();
        for arg in args {
            match arg.strip_prefix('$').and_then(|a| a.split_once(": ")) {
                Some((name, _)) => named.push((name.to_string(), super::Value::Null)),
                None => pos_args.push(super::Value::Null),
            }
        }
        let f =
            super::member_of(module, member).unwrap_or_else(|| panic!("no member sass:{module}.{member}"));
        super::verify_args(f, &pos_args, &named, super::Pos::NONE)
            .err()
            .map(|e| e.message)
    }

    /// Every parameter in the table is spelled canonically, so the built-in path
    /// never exercises [`argument_passed_twice`]'s canonicalization of the
    /// DECLARED name — only `host_fn`'s signatures do, and this is what says so.
    /// A row written `$start_at` would make the table depend on it silently.
    #[test]
    fn every_declared_parameter_is_already_canonical() {
        for (module, _) in DART_FUNCTIONS {
            for name in module_function_names(module) {
                let f = super::member_of(module, name).unwrap();
                for param in f.params.unwrap_or(&[]) {
                    assert!(
                        !param.contains('_'),
                        "sass:{module}.{name}'s ${param} is not canonical",
                    );
                }
            }
        }
    }

    /// A calculation global is not verified against its module member's
    /// declaration.
    ///
    /// dart answers `sin(1, $nope: 2)` with
    /// `Keyword arguments can't be used with calculations.` and
    /// `math.sin(1, $nope: 2)` with `No parameter named $nope.`. Verifying the
    /// bare `sin(…)` against `math.sin`'s parameters produced the second
    /// sentence for the first call — a wrong message this rewrite introduced
    /// where there had been none, which a review caught (r4128303276). The
    /// right sentence is #215's; keeping these out leaves the previous
    /// behaviour untouched rather than replacing one wrong answer with another.
    #[test]
    fn a_calculation_global_is_not_verified_as_a_member() {
        // Measured: the sixteen dart answers about calculations.
        for name in super::CALCULATION_GLOBALS {
            assert!(
                super::global_member(name).is_none(),
                "the global `{name}` is a calculation, not a Sass function",
            );
        }
        // …and the ones it answers about as Sass functions still are verified,
        // so the exclusion did not take the whole family with it. Eight of the
        // eleven measured SASS names: `max`, `min` and `round` are left out
        // because they name no member with a global alias, so they never reach
        // this lookup either — dart answers those as Sass functions for some
        // argument shapes and as calculations for others, which is #215's and
        // #220's selection problem rather than this exclusion's.
        for name in [
            "abs",
            "ceil",
            "floor",
            "percentage",
            "unit",
            "unitless",
            "random",
            "comparable",
        ] {
            assert!(
                super::global_member(name).is_some(),
                "the global `{name}` is a Sass function and must be verified",
            );
        }
        // The MODULE spelling is unaffected — that is the whole distinction.
        for name in ["sin", "sqrt", "hypot", "log", "pow", "atan2"] {
            assert!(super::member_of("math", name).unwrap().params.is_some());
        }
    }

    /// `saturate` names two DIFFERENT declarations, and only one of them is
    /// this table's.
    ///
    /// `color.saturate($color, $amount)` is the module member; the global
    /// `saturate($amount)` is the CSS filter function, asymmetric with
    /// `desaturate($color, $amount)`. Measured against dart-sass 1.104.1 on
    /// 2026-09-28: `color.saturate($nope: 1)` is `Missing argument $color.`,
    /// `color.saturate(10%)` is `Missing argument $amount.`, and the global
    /// `saturate(1%)` is preserved as CSS.
    ///
    /// So giving this row a global alias would verify the filter function
    /// against the member's parameters and answer `Missing argument $color.`
    /// where dart answers about `$amount` — which is exactly the reading a
    /// review arrived at (r4127788923), so the distinction is pinned rather
    /// than left to the comment beside the row.
    #[test]
    fn the_global_saturate_is_not_this_declaration() {
        let member = super::member_of("color", "saturate").unwrap();
        assert_eq!(member.params, Some(&["color", "amount"][..]));
        assert_eq!(member.required, 2);
        assert_eq!(member.global, None, "the global saturate is a different function");
        assert!(
            super::global_member("saturate").is_none(),
            "the global `saturate` must not be verified against the member's parameters",
        );
    }

    /// The members with no recorded signature are exactly the ones there is a
    /// measured reason for, and nothing has quietly joined them.
    ///
    /// The list, not a count: `no_sig`'s prose says two and nothing can make
    /// that prose fail, which is why the assertion below names them. Four
    /// stale "three"s were left behind when `map.remove` stopped needing
    /// `no_sig` (r4127788954, r4127788989, r4128127606) and a fifth was this
    /// very comment (r4128395163) — the count is the part that drifts.
    #[test]
    fn only_the_overloaded_members_go_unverified() {
        let mut unverified = Vec::new();
        for (module, _) in DART_FUNCTIONS {
            for name in module_function_names(module) {
                let f = super::member_of(module, name).unwrap();
                if f.params.is_none() {
                    unverified.push(format!("{module}.{name}"));
                }
            }
        }
        assert_eq!(unverified, ["color.hwb", "color.alpha"]);
    }

    /// The index answers exactly what a walk of the tables answers, for every
    /// member and every global, including a name that is both. It replaced
    /// that walk for speed alone (#260), and its first-wins rule is what keeps
    /// a later row from shadowing an earlier one.
    #[test]
    fn the_member_index_agrees_with_the_tables() {
        let tables = || {
            super::MODULES
                .iter()
                .filter_map(|m| super::members_of(m).map(|t| (*m, t)))
        };
        for (module, table) in tables() {
            for f in table.functions {
                let walked = table.functions.iter().find(|g| g.name == f.name).unwrap();
                assert!(std::ptr::eq(super::member_of(module, f.name).unwrap(), walked));
            }
        }
        assert!(super::member_of("math", "nope").is_none());
        assert!(super::member_of("nope", "abs").is_none());
        for (_, table) in tables() {
            for g in table.functions.iter().filter_map(|f| f.global) {
                let walked = tables()
                    .flat_map(|(_, t)| t.functions.iter())
                    .find(|f| f.global == Some(g))
                    .filter(|_| !super::CALCULATION_GLOBALS.contains(&g));
                let indexed = super::global_member(g);
                assert_eq!(
                    indexed.map(|f| f as *const _),
                    walked.map(|f| f as *const _),
                    "{g}"
                );
            }
        }
    }

    /// A module member and the global it names share one [`super::Fun`] row
    /// whenever the global is verified at all, which is what lets
    /// `call_module_body` skip [`super::call`]'s second verification. A global
    /// that resolves to a DIFFERENT row would make that skip change an error.
    #[test]
    fn a_module_members_global_is_the_same_row() {
        for module in super::MODULES {
            for f in super::members_of(module).unwrap().functions {
                let Some(g) = f.global else { continue };
                if let Some(row) = super::global_member(g) {
                    let own = super::member_of(module, f.name).unwrap();
                    assert!(std::ptr::eq(row, own), "sass:{module}.{} -> {g}", f.name);
                }
            }
        }
    }

    /// `has_rest` is computed once, in a `const fn`; it must agree with the
    /// suffix test it replaced.
    #[test]
    fn has_rest_matches_the_rest_suffix() {
        for module in super::MODULES {
            for f in super::members_of(module).unwrap().functions {
                let suffixed = f
                    .params
                    .and_then(|p| p.last())
                    .is_some_and(|p| p.ends_with("..."));
                assert_eq!(f.has_rest, suffixed, "sass:{module}.{}", f.name);
            }
        }
    }

    /// A rest parameter is not addressable by its own name, and dart says so:
    /// `math.max(1, $numbers: 2)` is `No parameter named $numbers.`. So the
    /// rest must not appear among the parameters a name can match.
    #[test]
    fn a_rest_parameter_is_not_a_named_parameter() {
        for (module, member, rest) in [
            ("math", "max", "numbers"),
            ("list", "slash", "elements"),
            ("selector", "nest", "selectors"),
            ("map", "get", "keys"),
            ("meta", "call", "args"),
        ] {
            let f = super::member_of(module, member).unwrap();
            assert_eq!(f.rest(), Some(rest), "sass:{module}.{member}");
            // Not `!contains(&rest)`: the element is `"numbers..."`, so that
            // reads false whether or not the rest is excluded, and the mutation
            // that stopped excluding it SURVIVED until this looked for the
            // suffix instead.
            assert!(
                f.named_params().iter().all(|p| !p.ends_with("...")),
                "sass:{module}.{member} exposes its rest parameter as a name: {:?}",
                f.named_params(),
            );
            assert!(
                f.params.unwrap().len() == f.named_params().len() + 1,
                "sass:{module}.{member} should have exactly one rest parameter",
            );
        }
    }

    /// The table holds no more and no less than what was measured.
    ///
    /// For the FUNCTIONS this is subsumed by the list comparison below, which
    /// checks every name; for the mixins and the variables nothing else pins a
    /// total, and for all three it is the only thing that can contradict the
    /// counts the module comment and the CHANGELOG publish. Those said 93 and
    /// 118 against a real 116, neither of which anything could disagree with
    /// (r4118793518, r4118793564).
    #[test]
    fn the_table_holds_no_more_and_no_less() {
        let mut counts = (0, 0, 0);
        for (module, _) in DART_FUNCTIONS {
            counts.0 += module_function_names(module).len();
            counts.1 += super::module_mixin_names(module).len();
            counts.2 += super::module_variable_names(module).len();
        }
        // dart-sass 1.104.1, measured 2026-09-28 by
        // `list.length(map.keys(meta.module-{functions,mixins,variables}($m)))`
        // summed over the seven modules.
        assert_eq!(counts, (116, 2, 7), "(functions, mixins, variables)");
    }

    /// Every variable the table lists resolves to a value.
    ///
    /// `module_var` decides what a variable is worth and the table decides
    /// which exist; this is what stops a row being added to one without the
    /// other. Before it, a listed name `module_var` did not answer reached
    /// `meta.module-variables()` as a `null` value under an `unwrap_or`, which
    /// is drift that looks like data (r4119082581).
    #[test]
    fn every_listed_variable_has_a_value() {
        for (module, _) in DART_FUNCTIONS {
            for name in super::module_variable_names(module) {
                assert!(
                    super::module_var(module, name, super::Pos::NONE).is_ok(),
                    "sass:{module}.${name} is listed but does not resolve",
                );
                // …and the underscore spelling reaches the same value, because
                // the guard canonicalizes before it looks.
                let under = name.replace('-', "_");
                assert!(
                    super::module_var(module, &under, super::Pos::NONE).is_ok(),
                    "sass:{module}.${under} should resolve too",
                );
            }
        }
    }

    /// …and a name the table does not list resolves to nothing, so the table is
    /// what is being consulted rather than the match falling through.
    #[test]
    fn an_unlisted_variable_has_no_value() {
        for (module, name) in [
            ("math", "tau"), // plausible, and not a dart member
            ("math", "abs"), // a FUNCTION of the same module
            ("color", "pi"), // a real variable, wrong module
            ("nope", "pi"),  // no such module
        ] {
            assert!(
                super::module_var(module, name, super::Pos::NONE).is_err(),
                "sass:{module}.${name} should not resolve",
            );
        }
    }

    /// `meta.module-functions()` answers with dart's names, in dart's order.
    ///
    /// Order is observable: the result is a map, and a Sass map keeps
    /// insertion order. Sorting is right for a user module, whose members are
    /// discovered, and wrong for a built-in, whose list is dart's source file.
    #[test]
    fn every_module_lists_darts_members_in_darts_order() {
        for (module, want) in DART_FUNCTIONS {
            assert_eq!(&module_function_names(module), want, "sass:{module}");
        }
    }

    /// A module this build does not know answers with nothing, rather than
    /// panicking or inventing a list.
    #[test]
    fn an_unknown_module_has_no_members() {
        assert!(module_function_names("nope").is_empty());
        assert!(super::module_mixin_names("nope").is_empty());
        assert!(super::module_variable_names("nope").is_empty());
        assert!(!module_has_member("nope", "get"));
    }

    /// Every global a member points at must be a global this build dispatches.
    ///
    /// This was a comment on the old `match` — "Names returned as `Some` must
    /// be real global builtins (so the dispatcher finds them)" — and a comment
    /// cannot fail. A typo there would have made `map.get` undefined at the
    /// point of call, with membership still answering yes.
    #[test]
    fn every_alias_names_a_real_global() {
        for (module, members) in DART_FUNCTIONS {
            for member in *members {
                if let Some(global) = module_member_to_global(module, member) {
                    assert!(
                        is_builtin(global),
                        "sass:{module}.{member} points at `{global}`, which is not a global builtin",
                    );
                }
            }
        }
    }

    /// A member with no global alias is still a member. This is the half a
    /// predicate over the alias table could not express, and the reason the
    /// two answers now come from one table.
    #[test]
    fn a_member_without_a_global_is_still_a_member() {
        for (module, member) in [
            ("map", "set"), // dispatched in `call_module`
            ("map", "deep-merge"),
            ("string", "split"),
            ("list", "slash"),
            ("math", "div"),
            ("color", "hwb"),     // comma form, module-only
            ("color", "lighten"), // removed by CSS Color 4: exists to FAIL
            ("meta", "call"),     // needs evaluator state
        ] {
            assert!(module_has_member(module, member), "sass:{module}.{member}");
            assert!(
                module_member_to_global(module, member).is_none(),
                "sass:{module}.{member} should have no global alias",
            );
        }
    }

    /// `sass:math` has no `exp` and no `sign`.
    ///
    /// They COMPUTE in both compilers — `exp(1)` is `2.7182818285` — because
    /// they are CSS math functions, which is a different thing from a Sass
    /// function. dart answers `meta.function-exists("exp", $module: "math")`
    /// with `false`; sasso answered `true` until this table replaced the
    /// alias-only predicate (#64).
    #[test]
    fn math_has_no_exp_or_sign() {
        for member in ["exp", "sign"] {
            assert!(!module_has_member("math", member), "sass:math.{member}");
        }
    }

    /// A mixin or a variable is NOT a function member.
    ///
    /// `meta.function-exists($module:)` reads this predicate, and dart answers
    /// `false` for `load-css` and for `pi`. Broadening it to "a member of any
    /// kind" made both `true` — measured against dart-sass 1.104.1, and the
    /// mutation that removed this distinction SURVIVED until this case
    /// existed. The other kinds are answered by `is_builtin_mixin` and
    /// `module_var`.
    #[test]
    fn a_mixin_or_a_variable_is_not_a_function() {
        assert!(!module_has_member("meta", "load-css"), "load-css is a mixin");
        assert!(!module_has_member("meta", "apply"), "apply is a mixin");
        for var in super::module_variable_names("math") {
            assert!(!module_has_member("math", var), "math.{var} is a variable");
        }
        // …while the mixin and variable LISTS still carry them, because
        // `module-mixins()` and `module-variables()` enumerate from the same
        // table.
        assert!(super::module_mixin_names("meta").contains(&"load-css"));
        assert!(super::module_variable_names("math").contains(&"pi"));
    }

    /// Underscores and dashes are one character in a Sass identifier, so the
    /// predicate has to canonicalise before it looks.
    #[test]
    fn a_member_can_be_spelled_with_underscores() {
        assert!(module_has_member("string", "unique_id"));
        assert!(module_has_member("list", "is_bracketed"));
        assert!(module_has_member("color", "ie_hex_str"));
    }

    /// Lock the byte-observable `is_builtin` classification: a sample across
    /// every family must report `true` (including the case-insensitive math
    /// name `SiN`, the list-owned `length`, and a function-existence-relevant
    /// name like `function-exists`), and unknown / plain-CSS names must report
    /// `false`. Mis-classification flips CSS output (slash-division collapse,
    /// `function-exists`/`feature-exists`), so this is a real behavior lock.
    #[test]
    fn is_builtin_locks_classification() {
        for name in [
            "lighten",         // color_ext
            "rgb",             // color
            "color-space",     // color (modern)
            "sin",             // math
            "SiN",             // math, case-insensitive
            "map-get",         // map
            "length",          // list (not map)
            "selector-parse",  // selector
            "function-exists", // meta
        ] {
            assert!(is_builtin(name), "expected `{name}` to be a builtin");
        }
        for name in ["totally-unknown-fn", "rotate", "translatex"] {
            assert!(!is_builtin(name), "expected `{name}` not to be a builtin");
        }
    }

    /// Equivalence guard: the new per-family-`NAMES` union must classify
    /// *exactly* the historical hardcoded set (the union of the pre-refactor
    /// `is_builtin` `matches!` arms + `is_math_builtin_name` arms). Locks that
    /// the single-source refactor changed no name's classification, and that no
    /// extra name leaked into the union. Math names are tested case-insensitively
    /// (`SiN`) since the family lowercases before dispatch.
    #[test]
    fn is_builtin_matches_historical_set() {
        // The exact pre-refactor non-math `matches!` arms.
        const OLD_NON_MATH: &[&str] = &[
            // color (legacy + modern)
            "rgb",
            "rgba",
            "hsl",
            "hsla",
            "hwb",
            "lab",
            "lch",
            "oklab",
            "oklch",
            "color",
            "mix",
            "lighten",
            "darken",
            "percentage",
            "red",
            "green",
            "blue",
            "alpha",
            "color-space",
            "color-channel",
            "color-to-space",
            "color-is-legacy",
            "color-is-missing",
            "color-is-in-gamut",
            "color-is-powerless",
            "color-to-gamut",
            "color-same",
            // color_ext
            "adjust-hue",
            "complement",
            "invert",
            "grayscale",
            "saturate",
            "desaturate",
            "opacify",
            "fade-in",
            "transparentize",
            "fade-out",
            "hue",
            "saturation",
            "lightness",
            // `whiteness`/`blackness` were in the historical set but never
            // belonged there: dart-sass has no *global* HWB getters (they exist
            // only as `sass:color` members, lib/src/functions/color.dart:532-541
            // vs. the `global` list at line 31). They were removed from
            // `color_ext::NAMES`, so the historical baseline is corrected here
            // rather than the union being bent back to match it.
            "opacity",
            "ie-hex-str",
            "scale-color",
            "adjust-color",
            "change-color",
            // string
            "quote",
            "unquote",
            "to-upper-case",
            "to-lower-case",
            "str-length",
            "str-index",
            "str-slice",
            "str-insert",
            "unique-id",
            // map
            "map-get",
            "map-keys",
            "map-values",
            "map-has-key",
            "map-merge",
            "map-remove",
            // list (length/nth are list-owned)
            "length",
            "nth",
            "set-nth",
            "join",
            "append",
            "index",
            "list-separator",
            "is-bracketed",
            "zip",
            // meta
            "get-function",
            "type-of",
            "unit",
            "unitless",
            "comparable",
            "inspect",
            "feature-exists",
            "function-exists",
            "calc-name",
            "calc-args",
            // selector
            "selector-nest",
            "selector-append",
            "selector-extend",
            "selector-replace",
            "selector-unify",
            "is-superselector",
            "simple-selectors",
            "selector-parse",
        ];
        // The exact pre-refactor `is_math_builtin_name` arms (lowercase).
        const OLD_MATH: &[&str] = &[
            "abs", "ceil", "floor", "round", "min", "max", "clamp", "sign", "pow", "sqrt", "exp", "log",
            "hypot", "sin", "cos", "tan", "asin", "acos", "atan", "atan2", "rem", "mod", "random",
        ];

        // Direction 1: every name the old set owned is still a builtin.
        for &name in OLD_NON_MATH.iter().chain(OLD_MATH.iter()) {
            assert!(is_builtin(name), "old builtin `{name}` no longer classified");
        }

        // Direction 2: the new union introduces no name the old set lacked.
        let new_union: Vec<&str> = super::color::NAMES
            .iter()
            .chain(super::color::MODERN_NAMES.iter())
            .chain(super::color_ext::NAMES.iter())
            .chain(super::string::NAMES.iter())
            .chain(super::map::NAMES.iter())
            .chain(super::list::NAMES.iter())
            .chain(super::meta::NAMES.iter())
            .chain(super::selector::NAMES.iter())
            .chain(super::math::NAMES.iter())
            .copied()
            .collect();
        let old_set: std::collections::BTreeSet<&str> =
            OLD_NON_MATH.iter().chain(OLD_MATH.iter()).copied().collect();
        for name in &new_union {
            assert!(
                old_set.contains(name),
                "new union introduced unexpected name `{name}`"
            );
        }
        // Cardinality match (no duplicates within the families, exact size).
        let new_set: std::collections::BTreeSet<&str> = new_union.iter().copied().collect();
        assert_eq!(new_set.len(), new_union.len(), "duplicate name in family NAMES");
        assert_eq!(new_set, old_set, "new union != historical builtin set");
    }
}
