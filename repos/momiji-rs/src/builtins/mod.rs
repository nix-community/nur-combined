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
    // The `math` family matches `name.to_ascii_lowercase()`, so it owns these
    // names case-insensitively.
    if is_math_builtin_name(name) {
        return true;
    }
    [
        color::NAMES,
        color::MODERN_NAMES,
        color_ext::NAMES,
        string::NAMES,
        map::NAMES,
        list::NAMES,
        meta::NAMES,
        selector::NAMES,
    ]
    .iter()
    .any(|family| family.contains(&name))
}

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
pub(super) fn num(v: &Value, pos: Pos) -> Result<f64, Error> {
    match v {
        Value::Number(n) => Ok(n.value),
        other => Err(Error::at(
            format!("{} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

/// Extract a color value.
pub(super) fn as_color(v: &Value, pos: Pos) -> Result<Color, Error> {
    match v {
        Value::Color(c) => Ok(c.clone()),
        other => Err(Error::at(format!("{} is not a color.", other.to_css(false)), pos)),
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
        other => Err(Error::at(
            format!("{} is not a number.", other.to_css(false)),
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
                    format!("{} isn't a valid CSS value.", v.to_css(false)),
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

/// Translate a `(module, member)` pair to the global builtin name that
/// implements it, or `None` when the member is not a function this build can
/// dispatch to a global implementation. The global implementations are reused
/// verbatim — module members are just renamed views of them.
pub(crate) fn module_member_to_global(module: &str, member: &str) -> Option<&'static str> {
    // Names returned as `Some` must be real global builtins (so the dispatcher
    // finds them). Members handled specially (e.g. `math.div`) or unsupported
    // (color-space math, first-class functions) are deliberately absent.
    match module {
        "math" => match member {
            "abs" => Some("abs"),
            "ceil" => Some("ceil"),
            "floor" => Some("floor"),
            // `math.min`/`math.max`/`math.clamp`/`math.round` are the numeric
            // forms (dispatched directly in `call_module`), distinct from the
            // global CSS-calc functions which preserve unknown args.
            "sqrt" => Some("sqrt"),
            "pow" => Some("pow"),
            "exp" => Some("exp"),
            "log" => Some("log"),
            "sin" => Some("sin"),
            "cos" => Some("cos"),
            "tan" => Some("tan"),
            "asin" => Some("asin"),
            "acos" => Some("acos"),
            "atan" => Some("atan"),
            "atan2" => Some("atan2"),
            "hypot" => Some("hypot"),
            "sign" => Some("sign"),
            "percentage" => Some("percentage"),
            "unit" => Some("unit"),
            "is-unitless" => Some("unitless"),
            "compatible" => Some("comparable"),
            "random" => Some("random"),
            // `div` is implemented directly in `call_module`; the module
            // variables are resolved by `module_var`.
            _ => None,
        },
        "map" => match member {
            "get" => Some("map-get"),
            "merge" => Some("map-merge"),
            "remove" => Some("map-remove"),
            "keys" => Some("map-keys"),
            "values" => Some("map-values"),
            "has-key" => Some("map-has-key"),
            // `set`/`deep-merge`/`deep-remove` are module-only (no global alias
            // in dart-sass); they are dispatched directly in `call_module`.
            _ => None,
        },
        "string" => match member {
            "length" => Some("str-length"),
            "insert" => Some("str-insert"),
            "index" => Some("str-index"),
            "slice" => Some("str-slice"),
            "quote" => Some("quote"),
            "unquote" => Some("unquote"),
            "to-upper-case" => Some("to-upper-case"),
            "to-lower-case" => Some("to-lower-case"),
            "unique-id" => Some("unique-id"),
            // `split` is module-only (no global alias); dispatched in
            // `call_module`.
            _ => None,
        },
        "list" => match member {
            "length" => Some("length"),
            "nth" => Some("nth"),
            "set-nth" => Some("set-nth"),
            "append" => Some("append"),
            "join" => Some("join"),
            "zip" => Some("zip"),
            "index" => Some("index"),
            "separator" => Some("list-separator"),
            "is-bracketed" => Some("is-bracketed"),
            _ => None,
        },
        "selector" => match member {
            "nest" => Some("selector-nest"),
            "append" => Some("selector-append"),
            "extend" => Some("selector-extend"),
            "replace" => Some("selector-replace"),
            "unify" => Some("selector-unify"),
            "parse" => Some("selector-parse"),
            "is-superselector" => Some("is-superselector"),
            "simple-selectors" => Some("simple-selectors"),
            _ => None,
        },
        "color" => match member {
            // Legacy members map to the global color functions.
            "adjust" => Some("adjust-color"),
            "scale" => Some("scale-color"),
            "change" => Some("change-color"),
            "red" => Some("red"),
            "green" => Some("green"),
            "blue" => Some("blue"),
            "hue" => Some("hue"),
            "saturation" => Some("saturation"),
            "lightness" => Some("lightness"),
            // `whiteness`/`blackness` have no global alias in dart-sass (they
            // live only in the `sass:color` module list) — they are dispatched
            // directly in `call_module` via `color_ext::call_module_member`.
            "alpha" => Some("alpha"),
            "opacity" => Some("opacity"),
            "grayscale" => Some("grayscale"),
            "complement" => Some("complement"),
            "invert" => Some("invert"),
            "mix" => Some("mix"),
            "ie-hex-str" => Some("ie-hex-str"),
            // Modern CSS Color 4 color-space members. These dispatch to the
            // color-space-aware implementations in the color builtin family
            // under disambiguated global names.
            "space" => Some("color-space"),
            "channel" => Some("color-channel"),
            "to-space" => Some("color-to-space"),
            "is-legacy" => Some("color-is-legacy"),
            "is-missing" => Some("color-is-missing"),
            "is-in-gamut" => Some("color-is-in-gamut"),
            "is-powerless" => Some("color-is-powerless"),
            "to-gamut" => Some("color-to-gamut"),
            "same" => Some("color-same"),
            _ => None,
        },
        "meta" => match member {
            "type-of" => Some("type-of"),
            "inspect" => Some("inspect"),
            "feature-exists" => Some("feature-exists"),
            "calc-name" => Some("calc-name"),
            "calc-args" => Some("calc-args"),
            // `keywords`, `call`, `get-function`, the `*-exists`/`get-mixin`/
            // `apply`/`module-*` members need evaluator context or first-class
            // functions not available in this value-only dispatch — left
            // unsupported (Undefined function).
            _ => None,
        },
        _ => None,
    }
}

/// Whether `module` exposes `member` as a callable function (used by the
/// evaluator to resolve unprefixed `@use … as *` members).
/// The `sass:meta` module's function members (dart-sass 1.100), for
/// `meta.module-functions("meta")` and `$module`-qualified lookups.
pub(crate) const META_FUNCTION_NAMES: &[&str] = &[
    "accepts-content",
    "calc-args",
    "calc-name",
    "call",
    "content-exists",
    "feature-exists",
    "function-exists",
    "get-function",
    "get-mixin",
    "global-variable-exists",
    "inspect",
    "keywords",
    "mixin-exists",
    "module-functions",
    "module-mixins",
    "module-variables",
    "type-of",
    "variable-exists",
];

/// The `sass:meta` module's mixin members.
pub(crate) const META_MIXIN_NAMES: &[&str] = &["apply", "load-css"];

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

pub(crate) fn module_has_member(module: &str, member: &str) -> bool {
    let canonical = canonical_name(member);
    let member = canonical.as_ref();
    if module == "meta" && META_FUNCTION_NAMES.contains(&member) {
        return true;
    }
    if module == "math" && matches!(member, "div" | "clamp" | "min" | "max" | "round") {
        return true;
    }
    if module == "map" && matches!(member, "set" | "deep-merge" | "deep-remove") {
        return true;
    }
    if module == "string" && member == "split" {
        return true;
    }
    // `color.hwb` (comma form) and the deprecated `color.whiteness`/
    // `color.blackness` getters are module-only: they have no global alias, so
    // `module_member_to_global` cannot see them.
    if module == "color" && matches!(member, "hwb" | "whiteness" | "blackness") {
        return true;
    }
    // The nine adjusters CSS Color 4 removed are members that always FAIL, and
    // that distinction is what this predicate answers: they are found by
    // `meta.function-exists`, captured by `meta.get-function`, re-exported by
    // `@forward "sass:color"`, and — the visible half — SHADOW the global of the
    // same name under `@use "sass:color" as *`, where dart reports the removal
    // instead of running the deprecated global. See [`color::removed`].
    if module == "color" && color::removed::is_member(member) {
        return true;
    }
    module_member_to_global(module, member).is_some()
}

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
    // `math.div(a, b)` is true (always-divide) division, unit-aware.
    if module == "math" && member == "div" {
        return math::module_div(pos_args, named, pos);
    }
    // `math.clamp`/`math.min`/`math.max` are the numeric forms, not the
    // CSS-calc functions of the same name.
    if module == "math" {
        match member {
            "clamp" => return math::module_clamp(pos_args, named, pos),
            "min" => return math::module_min_max(pos_args, named, pos, true),
            "max" => return math::module_min_max(pos_args, named, pos, false),
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
        if let Some(r) = list::call_module_member(member, pos_args, named, pos) {
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
                format!("$color: {} is not a color.", v.to_css(false)),
                pos,
            ));
        }
    }
    match module_member_to_global(module, member) {
        Some(global) => call(global, pos_args, named, pos),
        None => Err(Error::at("Undefined function.".to_string(), pos)),
    }
}

/// Resolve a built-in module variable (`math.$pi`, etc.). dart-sass exposes
/// these only on `sass:math`; an unknown member is "Undefined variable.".
pub(crate) fn module_var(module: &str, name: &str, pos: Pos) -> Result<Value, Error> {
    let number = |value: f64| Ok(Value::Number(Number::unitless(value)));
    if module == "math" {
        return match name {
            "pi" => number(std::f64::consts::PI),
            "e" => number(std::f64::consts::E),
            "epsilon" => number(f64::EPSILON),
            "max-safe-integer" => number(9_007_199_254_740_991.0),
            "min-safe-integer" => number(-9_007_199_254_740_991.0),
            "max-number" => number(f64::MAX),
            // The smallest positive (subnormal) double, matching dart-sass's
            // `$min-number` (`5e-324`), not the smallest *normal* value.
            "min-number" => number(f64::from_bits(1)),
            _ => Err(Error::at("Undefined variable.".to_string(), pos)),
        };
    }
    Err(Error::at("Undefined variable.".to_string(), pos))
}

#[cfg(test)]
mod tests {
    use super::is_builtin;

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
