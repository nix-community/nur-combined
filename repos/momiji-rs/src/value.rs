//! The Sass value model and its CSS serialization.
//!
//! Numbers carry a unit, colors keep full `f64` channel precision (so
//! computed colors serialize exactly like current dart-sass, e.g.
//! `rgb(25%, 50%, 75%)` — dart re-spells a fractional triple as
//! percentages), and colors remember their authored
//! spelling so untransformed literals round-trip unchanged.

use std::rc::Rc;

/// A fully-evaluated Sass value.
#[derive(Debug, Clone, PartialEq)]
pub(crate) enum Value {
    /// A number with an optional unit.
    Number(Number),
    /// An sRGB color with an alpha channel.
    Color(Color),
    /// A quoted or unquoted string.
    Str(SassStr),
    /// A space- or comma-separated list.
    List(List),
    /// A map of key/value pairs, preserving insertion order. Keys are
    /// compared by Sass `==`. An empty map serializes (and inspects) as `()`.
    Map(Map),
    /// A boolean.
    Bool(bool),
    /// The `null` value.
    Null,
    /// A number produced by the deprecated `a / b` slash division of two
    /// numeric literals. It behaves as `number` numerically (so arithmetic
    /// and functions use `number`), but serializes as the original
    /// `left/right` slash text. The slash is dropped (collapsing to
    /// `number`) when the value crosses a variable, function/mixin, or
    /// arithmetic boundary — matching dart-sass.
    Slash(Number, String),
    /// A `calc()` calculation that could not be reduced to a single number
    /// (e.g. it contains `var()`, an interpolation, or incompatible units).
    /// Stored as its simplified operand tree for canonical serialization.
    Calc(CalcNode),
    /// A first-class function reference (`meta.get-function(...)`), invoked via
    /// `meta.call`. Not a valid CSS value; `inspect` renders it as
    /// `get-function("name")`.
    Function(SassFunction),
    /// A first-class mixin reference (`meta.get-mixin(...)`), invoked via
    /// `@include meta.apply(...)`. Not a valid CSS value; `inspect` renders it
    /// as `get-mixin("name")`.
    // Boxed: a first-class mixin carries an optional captured file context, so
    // the inline struct is larger than Value's 64-byte budget. Mixins are never
    // emitted as CSS, so the indirection is off every hot path.
    Mixin(Box<SassMixin>),
}

/// `Value` is moved/cloned constantly (every scope slot, every `Vec<Value>`
/// element, every `$var` read), so its size is a hot-path constant. `Color` was
/// the sole 128-byte variant (its 72-byte `ModernColor` is now boxed); keep
/// `Value` at one cache line. Bump this only with a deliberate measurement.
const _: () = assert!(std::mem::size_of::<Value>() <= 64);

/// One of the `sass:*` built-in modules, recorded as the provenance of a
/// first-class function reference. A `u8`-sized enum rather than a `String`
/// because it rides inside [`Value`], which is pinned to one cache line.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub(crate) enum BuiltinModule {
    Color,
    List,
    Map,
    Math,
    Meta,
    Selector,
    String,
}

impl BuiltinModule {
    /// The module for a `sass:` namespace name, or `None` for anything that is
    /// not a built-in module.
    pub(crate) fn from_name(name: &str) -> Option<Self> {
        Some(match name {
            "color" => BuiltinModule::Color,
            "list" => BuiltinModule::List,
            "map" => BuiltinModule::Map,
            "math" => BuiltinModule::Math,
            "meta" => BuiltinModule::Meta,
            "selector" => BuiltinModule::Selector,
            "string" => BuiltinModule::String,
            _ => return None,
        })
    }

    /// The module's name, as it is written after `sass:`.
    pub(crate) fn name(self) -> &'static str {
        match self {
            BuiltinModule::Color => "color",
            BuiltinModule::List => "list",
            BuiltinModule::Map => "map",
            BuiltinModule::Math => "math",
            BuiltinModule::Meta => "meta",
            BuiltinModule::Selector => "selector",
            BuiltinModule::String => "string",
        }
    }
}

/// A first-class function reference. Built-in references compare equal by name
/// (and CSS flag, and the module they were taken from); user references compare
/// by identity of the captured definition (so a redefined `@function` yields a
/// distinct reference). The captured user definition is held as a type-erased
/// `Rc` (the concrete `Callable` lives in `ast`, which cannot be referenced
/// from this module without a dependency cycle); the evaluator downcasts it
/// when invoking.
#[derive(Clone)]
pub(crate) struct SassFunction {
    /// The function's name (for `inspect` and error messages).
    pub name: String,
    /// Whether this is a plain-CSS reference (`$css: true`), which is preserved
    /// verbatim instead of dispatched to a Sass builtin.
    pub css: bool,
    /// The built-in module this reference came from, for one taken through a
    /// module (`meta.get-function("get", $module: "map")`, or a bare name a
    /// `@use "sass:map" as *` exposes). A module member is NOT the global alias
    /// of the same function: dart keeps the member's own name, compares the two
    /// references unequal, and deprecates only the global spelling.
    pub module: Option<BuiltinModule>,
    /// The captured user `@function` definition, or `None` for a built-in /
    /// plain-CSS reference. Type-erased to break the `ast` ↔ `value` cycle.
    pub user: Option<std::rc::Rc<dyn std::any::Any>>,
}

impl std::fmt::Debug for SassFunction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SassFunction")
            .field("name", &self.name)
            .field("css", &self.css)
            .field("module", &self.module)
            .field("user", &self.user.is_some())
            .finish()
    }
}

impl PartialEq for SassFunction {
    fn eq(&self, other: &Self) -> bool {
        match (&self.user, &other.user) {
            // User references: identity of the captured definition.
            (Some(a), Some(b)) => std::rc::Rc::ptr_eq(a, b),
            // Built-in / plain-CSS references: same name, CSS flag and module.
            (None, None) => self.name == other.name && self.css == other.css && self.module == other.module,
            _ => false,
        }
    }
}

impl SassFunction {
    /// The `inspect()` / debug form, `get-function("name")` (dart-sass).
    pub(crate) fn inspect(&self) -> String {
        format!("get-function(\"{}\")", self.name)
    }
}

/// A first-class mixin reference, analogous to [`SassFunction`]. Built-in
/// references (e.g. `meta.load-css`) compare equal by name; user references
/// compare by identity of the captured `@mixin` definition (so a redefined
/// `@mixin` yields a distinct reference). The captured user definition is held
/// as a type-erased `Rc` (the concrete `Callable` lives in `ast`, which cannot
/// be referenced from this module without a dependency cycle); the evaluator
/// downcasts it when invoking.
#[derive(Clone)]
pub(crate) struct SassMixin {
    /// The mixin's name (for `inspect` and error messages).
    pub name: String,
    /// The captured user `@mixin` definition, or `None` for a built-in
    /// reference. Type-erased to break the `ast` ↔ `value` cycle.
    pub user: Option<std::rc::Rc<dyn std::any::Any>>,
    /// The module the captured mixin came from, when it was resolved from
    /// another `@use`d module (so its body runs in that module's environment).
    /// `None` for a same-module reference. Type-erased to break the cycle.
    pub module: Option<std::rc::Rc<dyn std::any::Any>>,
}

/// The file a callable was written in, captured with it. Its body runs against
/// this file: diagnostics name it, output maps to it, and a relative
/// `meta.load-css` inside it resolves against its directory — wherever the
/// callable is later called from. Held as plain strings (plus the text itself)
/// to keep `value` free of `eval`/`ast` types.
#[derive(Clone)]
pub(crate) struct MixinOrigin {
    /// The diagnostic display URL of the defining file (e.g. `src/_mod.scss`).
    pub diag_url: String,
    /// The defining file's directory (the legacy `@import` resolution base);
    /// empty when there is none.
    pub file_dir: String,
    /// The defining file's canonical URL (the importer resolution base).
    pub canonical: String,
    /// The defining file's text, for snippets. Carried here rather than looked
    /// up by `diag_url`: display names are not unique across custom importers
    /// (two canonical URLs may share a last segment), the canonical URL is.
    pub source: Rc<str>,
}

impl std::fmt::Debug for SassMixin {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SassMixin")
            .field("name", &self.name)
            .field("user", &self.user.is_some())
            .finish()
    }
}

impl PartialEq for SassMixin {
    fn eq(&self, other: &Self) -> bool {
        match (&self.user, &other.user) {
            // User references: identity of the captured definition.
            (Some(a), Some(b)) => std::rc::Rc::ptr_eq(a, b),
            // Built-in references: same name.
            (None, None) => self.name == other.name,
            _ => false,
        }
    }
}

impl SassMixin {
    /// The `inspect()` / debug form, `get-mixin("name")` (dart-sass).
    pub(crate) fn inspect(&self) -> String {
        format!("get-mixin(\"{}\")", self.name)
    }
}

/// A node in a simplified `calc()` tree. Numeric subtrees are folded during
/// evaluation; everything else (variables, interpolations, percentages with
/// incompatible neighbours) is preserved for canonical serialization.
#[derive(Debug, Clone, PartialEq)]
pub(crate) enum CalcNode {
    /// A resolved number operand.
    Number(Number),
    /// An opaque operand: `var(--x)`, an interpolation result, a nested
    /// unknown function — anything kept verbatim.
    Str(String),
    /// A binary operation `left <op> right`.
    Op {
        op: CalcOp,
        left: Box<CalcNode>,
        right: Box<CalcNode>,
    },
    /// A calculation function call that could not be reduced to a number
    /// (`min`/`max`/`clamp`/`hypot`/…). The `Value::Calc` holding this serializes
    /// as `name(arg, …)` (no `calc()` wrapper).
    Func { name: String, args: Vec<CalcNode> },
}

/// A `calc()` binary operator.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum CalcOp {
    Add,
    Sub,
    Mul,
    Div,
}

impl CalcOp {
    fn symbol(self) -> &'static str {
        match self {
            CalcOp::Add => "+",
            CalcOp::Sub => "-",
            CalcOp::Mul => "*",
            CalcOp::Div => "/",
        }
    }

    /// Precedence: `*`/`/` bind tighter than `+`/`-`.
    fn precedence(self) -> u8 {
        match self {
            CalcOp::Add | CalcOp::Sub => 1,
            CalcOp::Mul | CalcOp::Div => 2,
        }
    }
}

impl CalcNode {
    /// Serialize this node's interior (without the enclosing `calc(`...`)`) into
    /// `out`, adding parentheses only where operator precedence/associativity
    /// requires them, matching dart-sass's canonical form.
    ///
    /// This is the primitive, and it allocates nothing: a calculation is a tree,
    /// so building each node's text as a string of its own meant one allocation
    /// per node plus one per operator gap, all of them immediately concatenated
    /// into the parent's. Writing into the caller's buffer is the same walk
    /// without the intermediate strings. [`CalcNode::to_calc_css`] wraps it for
    /// callers that want a string.
    pub(crate) fn write_calc_css(&self, out: &mut String, compressed: bool) {
        match self {
            CalcNode::Number(n) => write_calc_number(out, n, compressed),
            CalcNode::Str(s) => out.push_str(s),
            CalcNode::Op { op, left, right } => {
                self.write_operand(out, left, *op, false, compressed);
                // A `+ -n` / `- -n` numeric right operand flips the operator,
                // in every output style: dart-sass does this when it builds the
                // operation (`SassCalculation._operateInternal`: `right.value <
                // 0` → negate the operand and swap the operator), so the flip
                // is already baked into the tree it serializes. The test is
                // exactly `< 0`, which excludes `-0` and NaN but INCLUDES
                // `-infinity` (`+ -infinity * 1em` → `- infinity * 1em`).
                //
                // `write_calc_number`, not `write_css`, because a non-finite or
                // complex-unit operand renders as a `*`/`/` chain here rather
                // than a `calc()` constant. It needs no parentheses under an
                // add/sub parent: `write_operand` would only parenthesize a
                // `Mul`-precedence child of a *higher*-precedence parent.
                if matches!(op, CalcOp::Add | CalcOp::Sub) {
                    if let CalcNode::Number(n) = right.as_ref() {
                        if n.value < 0.0 {
                            out.push(' ');
                            out.push_str(if *op == CalcOp::Add { "-" } else { "+" });
                            out.push(' ');
                            write_calc_number(out, &n.copy_units(-n.value), compressed);
                            return;
                        }
                    }
                }
                match (op, compressed) {
                    (CalcOp::Mul | CalcOp::Div, true) => out.push_str(op.symbol()),
                    _ => {
                        out.push(' ');
                        out.push_str(op.symbol());
                        out.push(' ');
                    }
                }
                self.write_operand(out, right, *op, true, compressed);
            }
            CalcNode::Func { name, args } => {
                out.push_str(name);
                out.push('(');
                for (i, arg) in args.iter().enumerate() {
                    if i > 0 {
                        out.push_str(if compressed { "," } else { ", " });
                    }
                    arg.write_calc_css(out, compressed);
                }
                out.push(')');
            }
        }
    }

    /// Serialize this node's interior (without the enclosing `calc(`...`)`),
    /// adding parentheses only where operator precedence/associativity
    /// requires them, matching dart-sass's canonical form.
    pub(crate) fn to_calc_css(&self, compressed: bool) -> String {
        let mut out = String::new();
        self.write_calc_css(&mut out, compressed);
        out
    }

    /// [`CalcNode::to_calc_value_css`] into `out`.
    pub(crate) fn write_calc_value_css(&self, out: &mut String, compressed: bool) {
        match self {
            CalcNode::Func { .. } => self.write_calc_css(out, compressed),
            _ => {
                out.push_str("calc(");
                self.write_calc_css(out, compressed);
                out.push(')');
            }
        }
    }

    /// Serialize as the top-level `Value::Calc` holding this node would: a
    /// calculation-function node renders bare as `name(args)`, while any other
    /// node is wrapped in `calc(...)`.
    pub(crate) fn to_calc_value_css(&self, compressed: bool) -> String {
        let mut out = String::new();
        self.write_calc_value_css(&mut out, compressed);
        out
    }

    /// Write `operand` as a child of a parent `op`, wrapping in parens when
    /// the child binds more loosely (or equally on the right of `-`/`/`).
    fn write_operand(
        &self,
        out: &mut String,
        operand: &CalcNode,
        parent: CalcOp,
        is_right: bool,
        compressed: bool,
    ) {
        // A unit-carrying non-finite number renders as a `*` operation
        // (`infinity * 1px`), so it parenthesizes like a `Mul`-precedence
        // child rather than a bare leaf number.
        let child_op = match operand {
            CalcNode::Op { op, .. } => Some(*op),
            CalcNode::Number(n) if !n.value.is_finite() && !n.is_unitless() => Some(CalcOp::Mul),
            _ => None,
        };
        if let Some(child_op) = child_op {
            let needs_paren = child_op.precedence() < parent.precedence()
                || (child_op.precedence() == parent.precedence()
                    && is_right
                    && matches!(parent, CalcOp::Sub | CalcOp::Div));
            if needs_paren {
                out.push('(');
                operand.write_calc_css(out, compressed);
                out.push(')');
                return;
            }
        }
        operand.write_calc_css(out, compressed);
    }
}

/// Write a number as it appears inside a `calc()` interior. Finite single-unit
/// numbers use their ordinary CSS form. Non-finite numbers use dart-sass's
/// canonical lowercase constants — `infinity` / `-infinity` / `NaN`, with units
/// spelled out as operands (`infinity * 1px`). Multi-unit numbers spell every
/// unit as an operand: a finite value attaches to the first numerator
/// (`1000px * 1rad / 1Hz`), a numerator-less one stays bare (`1 / 1px`).
fn write_calc_number(out: &mut String, n: &Number, compressed: bool) {
    if n.value.is_finite() && !n.has_complex_units() {
        n.write_css(out, compressed);
        return;
    }
    let star = if compressed { "*" } else { " * " };
    let slash = if compressed { "/" } else { " / " };
    let mut numer = n.numer_units().iter();
    if n.value.is_finite() {
        // A finite value rides on the first numerator unit when there is one.
        push_num(out, n.value, compressed);
        if let Some(u) = numer.next() {
            out.push_str(u);
        }
    } else {
        out.push_str(if n.value.is_nan() {
            "NaN"
        } else if n.value > 0.0 {
            "infinity"
        } else {
            "-infinity"
        });
    }
    for u in numer {
        out.push_str(star);
        out.push('1');
        out.push_str(u);
    }
    for u in n.denom_units() {
        out.push_str(slash);
        out.push('1');
        out.push_str(u);
    }
}

/// A number with its units (dart-sass `SassNumber`: a list of numerator units
/// and a list of denominator units). The representation keeps the two
/// overwhelmingly common cases — unitless and a single numerator unit — free of
/// any unit list; multi-unit numbers (`px*px`, `px/s`) box their unit lists.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct Number {
    pub value: f64,
    units: Units,
}

/// A unit name is held as `Rc<str>`, like [`SassStr`]'s text, so that cloning
/// a number — which happens on every `$var` read, every operand copied out of
/// an operation and every value handed to a builtin — is a refcount bump rather
/// than a heap copy of `px`. Units are immutable: a number never edits its own
/// unit name, it builds a new one, so the sharing is invisible.
#[derive(Debug, Clone, PartialEq)]
enum Units {
    None,
    Single(Rc<str>),
    Complex(Box<ComplexUnits>),
}

/// The unit lists of a multi-unit number. Invariant (kept by
/// [`Number::with_units`]): not representable as `None`/`Single` — there is a
/// denominator unit, or more than one numerator unit.
#[derive(Debug, Clone, PartialEq)]
struct ComplexUnits {
    numer: Vec<Rc<str>>,
    denom: Vec<Rc<str>>,
}

impl Number {
    pub(crate) fn unitless(value: f64) -> Number {
        Number {
            value,
            units: Units::None,
        }
    }

    /// A number with zero or one numerator unit (`""` means unitless).
    ///
    /// The unit comes in BORROWED: unitless is the common case and it must not
    /// allocate, and a caller that has to spell the unit out (`"deg"`, a
    /// literal's suffix) should pay for exactly one buffer, not a `String` it
    /// then copies into an `Rc`.
    pub(crate) fn with_unit(value: f64, unit: &str) -> Number {
        Number {
            value,
            units: if unit.is_empty() {
                Units::None
            } else {
                Units::Single(Rc::from(unit))
            },
        }
    }

    /// A number reusing an existing unit name — a numeric literal's, spelled
    /// out once by the parser — so that evaluating the literal again costs a
    /// refcount bump and nothing else.
    pub(crate) fn with_shared_unit(value: f64, unit: &Rc<str>) -> Number {
        Number {
            value,
            units: if unit.is_empty() {
                Units::None
            } else {
                Units::Single(Rc::clone(unit))
            },
        }
    }

    /// A number with full numerator/denominator unit lists, normalized to the
    /// compact representation when possible. No unit cancellation happens
    /// here — callers cancel before constructing (dart-sass keeps whatever
    /// lists arithmetic produces).
    pub(crate) fn with_units(value: f64, mut numer: Vec<Rc<str>>, denom: Vec<Rc<str>>) -> Number {
        let units = if denom.is_empty() && numer.len() <= 1 {
            match numer.pop() {
                None => Units::None,
                Some(u) => Units::Single(u),
            }
        } else {
            Units::Complex(Box::new(ComplexUnits { numer, denom }))
        };
        Number { value, units }
    }

    /// A new number carrying this number's units (the common "derive a result
    /// from an operand" pattern; preserves multi-unit lists).
    pub(crate) fn copy_units(&self, value: f64) -> Number {
        Number {
            value,
            units: self.units.clone(),
        }
    }

    pub(crate) fn is_unitless(&self) -> bool {
        matches!(self.units, Units::None)
    }

    /// The single unit for the common path: `""` when unitless, the unit of a
    /// single-numerator number, or the FIRST numerator unit of a multi-unit
    /// number (callers that can meet multi-unit numbers must check
    /// [`Number::has_complex_units`] first).
    pub(crate) fn unit(&self) -> &str {
        match &self.units {
            Units::None => "",
            Units::Single(u) => u,
            Units::Complex(c) => c.numer.first().map(|u| &**u).unwrap_or(""),
        }
    }

    pub(crate) fn has_complex_units(&self) -> bool {
        matches!(self.units, Units::Complex(_))
    }

    pub(crate) fn numer_units(&self) -> &[Rc<str>] {
        match &self.units {
            Units::None => &[],
            Units::Single(u) => std::slice::from_ref(u),
            Units::Complex(c) => &c.numer,
        }
    }

    pub(crate) fn denom_units(&self) -> &[Rc<str>] {
        match &self.units {
            Units::None | Units::Single(_) => &[],
            Units::Complex(c) => &c.denom,
        }
    }
}

/// A string value; `quoted` controls whether it serializes with quotes.
///
/// The payload is held as `Rc<str>` so cloning a `Value::Str` (e.g. on every
/// read-only `$var` lookup) is an O(1) refcount bump rather than a heap copy of
/// the text. Strings are immutable Sass values, so the sharing is invisible:
/// any "mutating" string builtin builds a fresh `Rc<str>`.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct SassStr {
    pub text: Rc<str>,
    pub quoted: bool,
}

/// A private-use code point per dart-sass `isPrivateUseCharacter`: the BMP
/// private-use area plus the whole of planes 15 and 16 (so `\e000`, `\f0000`,
/// `\10fffd` escape, while a non-character like `\fdd0` or `\f900` stays raw).
pub(crate) fn is_private_use(cp: u32) -> bool {
    (0xE000..=0xF8FF).contains(&cp) || (0xF0000..=0x10FFFF).contains(&cp)
}

/// Serialize a string as a quoted CSS string, matching dart-sass's
/// `_visitQuotedString`. The text holds decoded code points; this re-escapes
/// only what it must: the chosen quote character, backslashes, control
/// characters (everything `0x00..=0x1F` except tab, plus `0x7F`), and
/// private-use characters. Double quotes are preferred; a string that contains
/// `"` but no `'` is wrapped in `'`.
pub(crate) fn serialize_quoted(text: &str) -> String {
    serialize_quoted_styled(text, false)
}

/// [`serialize_quoted`] for CSS OUTPUT, which depends on the style: dart
/// escapes a private-use character in expanded output — they are not rendered
/// consistently, so the escape is the safer spelling — but writes it raw when
/// compressing, where the escape costs more bytes than the character. (The
/// output then holds non-ASCII text, and picks up the `@charset`/BOM that
/// comes with it.) Everything else escapes the same either way.
pub(crate) fn serialize_quoted_styled(text: &str, compressed: bool) -> String {
    let mut out = String::with_capacity(text.len() + 2);
    push_quoted_styled(&mut out, text, compressed);
    out
}

/// [`serialize_quoted_styled`] into the caller's buffer.
pub(crate) fn push_quoted_styled(out: &mut String, text: &str, compressed: bool) {
    let has_double = text.contains('"');
    let has_single = text.contains('\'');
    // Use single quotes only when the text has a `"` and no `'`.
    let quote = if has_double && !has_single { '\'' } else { '"' };
    push_quoted_with_styled(out, text, quote, compressed);
}

/// The same, with the quote character already chosen — for a string whose
/// quote depends on more than this fragment (an interpolated one, whose pieces
/// are escaped separately but must share one quote).
pub(crate) fn serialize_quoted_with(text: &str, quote: char) -> String {
    serialize_quoted_with_styled(text, quote, false)
}

/// [`serialize_quoted_with`] for CSS output — see [`serialize_quoted_styled`]
/// for what the style changes.
pub(crate) fn serialize_quoted_with_styled(text: &str, quote: char, compressed: bool) -> String {
    let mut out = String::with_capacity(text.len() + 2);
    push_quoted_with_styled(&mut out, text, quote, compressed);
    out
}

/// [`serialize_quoted_with_styled`] into the caller's buffer: a quoted string
/// in a list or a declaration value is written where it belongs instead of into
/// a string of its own.
pub(crate) fn push_quoted_with_styled(out: &mut String, text: &str, quote: char, compressed: bool) {
    // A private-use character is escaped only when NOT compressing.
    let escapes_private_use = !compressed;
    // Fast path: when no character needs escaping, the body is `text` verbatim
    // between the quotes — skip the `Vec<char>` and the per-char loop. The
    // predicate mirrors the loop's two escape branches exactly.
    let needs_escape = text.chars().any(|c| {
        let cp = c as u32;
        c == quote
            || c == '\\'
            || (cp <= 0x1F && c != '\t')
            || cp == 0x7F
            || (escapes_private_use && is_private_use(cp))
    });
    if !needs_escape {
        out.reserve(text.len() + 2);
        out.push(quote);
        out.push_str(text);
        out.push(quote);
        return;
    }
    let chars: Vec<char> = text.chars().collect();
    out.reserve(text.len() + 2);
    out.push(quote);
    for (i, &c) in chars.iter().enumerate() {
        let cp = c as u32;
        if c == quote || c == '\\' {
            out.push('\\');
            out.push(c);
        } else if (cp <= 0x1F && c != '\t') || cp == 0x7F || (escapes_private_use && is_private_use(cp)) {
            // A control character, DEL, or a private-use character: `\<hex>`
            // with a trailing space only when the next character would otherwise
            // extend the escape (a hex digit, space, or tab).
            out.push('\\');
            out.push_str(&format!("{cp:x}"));
            let needs_space = chars
                .get(i + 1)
                .is_some_and(|n| n.is_ascii_hexdigit() || *n == ' ' || *n == '\t');
            if needs_space {
                out.push(' ');
            }
        } else {
            out.push(c);
        }
    }
    out.push(quote);
}

/// Serialize an unquoted string for CSS / interpolation output (dart-sass
/// `_visitUnquotedString`): a newline becomes a space, and a space directly
/// after a newline is dropped so `"\a "`-style line breaks collapse to a single
/// space; a private-use character is escaped as `\<hex>` in every style BUT
/// compressed (control characters, unlike in a quoted string, are written
/// verbatim here); every other code point is written verbatim.
pub(crate) fn serialize_unquoted(text: &str, compressed: bool) -> String {
    let mut out = String::new();
    push_unquoted(&mut out, text, compressed);
    out
}

/// [`serialize_unquoted`] into the caller's buffer. Almost every unquoted
/// string is written verbatim — `bold`, `solid`, `inherit`, a url — so this
/// costs nothing beyond the copy the caller was going to make anyway.
pub(crate) fn push_unquoted(out: &mut String, text: &str, compressed: bool) {
    // dart's `_tryPrivateUseCharacter` gives up immediately when compressing:
    // an escape is for a READER, who cannot tell two unrendered glyphs apart,
    // and compressed output has no reader. The character then goes out as its
    // own UTF-8 bytes, which is what makes the file non-ASCII and earns it the
    // BOM `emit` prepends.
    let escapes_private_use = !compressed;
    // Fast path: nothing to rewrite unless a newline or private-use char is
    // present. Scan without allocating; only collect into a `Vec<char>` (needed
    // for the escape look-ahead) on the rare slow path.
    if !text
        .chars()
        .any(|c| c == '\n' || (escapes_private_use && is_private_use(c as u32)))
    {
        out.push_str(text);
        return;
    }
    let chars: Vec<char> = text.chars().collect();
    out.reserve(text.len());
    let mut after_newline = false;
    for (i, &c) in chars.iter().enumerate() {
        let cp = c as u32;
        if escapes_private_use && is_private_use(cp) {
            out.push('\\');
            out.push_str(&format!("{cp:x}"));
            let needs_space = chars
                .get(i + 1)
                .is_some_and(|n| n.is_ascii_hexdigit() || *n == ' ' || *n == '\t');
            if needs_space {
                out.push(' ');
            }
            after_newline = false;
            continue;
        }
        match c {
            '\n' => {
                out.push(' ');
                after_newline = true;
            }
            ' ' => {
                if !after_newline {
                    out.push(' ');
                }
            }
            _ => {
                out.push(c);
                after_newline = false;
            }
        }
    }
}

/// A list value.
///
/// `items` is held as `Rc<[Value]>` so cloning a `Value::List` (e.g. on every
/// read-only `$var` lookup, or passing a list through a function) is an O(1)
/// refcount bump rather than a deep element copy. Lists are immutable Sass
/// values; every "mutating" list builtin (`append`, `join`, `set-nth`, …)
/// builds a fresh `Vec<Value>` and re-wraps it in a new `Rc`, so the sharing is
/// invisible.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct List {
    pub items: Rc<[Value]>,
    pub sep: ListSep,
    /// Whether the list was written with square brackets (`[a b]`); such
    /// lists serialize wrapped in `[`...`]` and report `true` from
    /// `list.is-bracketed`.
    pub bracketed: bool,
    /// `Some` when this list is an *argument list* (`$args...`): it carries the
    /// caller's leftover keyword arguments (name -> value), which `meta.keywords`
    /// reads and a `$args...` splat forwards as named arguments. `None` for an
    /// ordinary list. The positional arguments are the list's `items`.
    pub keywords: Option<Vec<(Value, Value)>>,
}

impl List {
    /// An ordinary (non-argument) list.
    pub(crate) fn new(items: impl Into<Rc<[Value]>>, sep: ListSep, bracketed: bool) -> Self {
        List {
            items: items.into(),
            sep,
            bracketed,
            keywords: None,
        }
    }
}

/// A map value: an ordered list of key/value entries. Insertion order is
/// preserved (dart-sass maps are ordered); duplicate keys are resolved by the
/// constructor so at most one entry exists per Sass-equal key.
///
/// `entries` is held as `Rc<Vec<…>>` so cloning a `Value::Map` (e.g. on every
/// read-only `$var` lookup) is an O(1) refcount bump rather than a deep copy of
/// every entry. Maps are immutable Sass values; `Map::insert` and the mutating
/// map builtins (`map.merge`, `map.set`, `map.remove`, …) use copy-on-write
/// (`Rc::make_mut` on a uniquely-owned `Rc`, or build a fresh `Vec`), so the
/// sharing never lets one binding observe another's mutation.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct Map {
    pub entries: Rc<Vec<(Value, Value)>>,
}

impl Map {
    /// Construct a map from an owned entry vector.
    pub(crate) fn new(entries: Vec<(Value, Value)>) -> Self {
        Map {
            entries: Rc::new(entries),
        }
    }

    /// Look up a value by key (Sass `==`), or `None` when absent.
    pub(crate) fn get(&self, key: &Value) -> Option<&Value> {
        self.entries.iter().find(|(k, _)| k.sass_eq(key)).map(|(_, v)| v)
    }

    /// Insert or overwrite an entry, preserving the position of an existing
    /// key (matching dart-sass map ordering). Copy-on-write: if the entry
    /// vector is shared, `Rc::make_mut` clones it first so no other `Map`
    /// observes the change.
    pub(crate) fn insert(&mut self, key: Value, value: Value) {
        let entries = Rc::make_mut(&mut self.entries);
        if let Some(slot) = entries.iter_mut().find(|(k, _)| k.sass_eq(&key)) {
            slot.1 = value;
        } else {
            entries.push((key, value));
        }
    }

    /// Serialize the map for CSS / error messages: `(k1: v1, k2: v2)`, with
    /// the empty map rendered as `()`.
    pub(crate) fn to_css(&self, compressed: bool) -> String {
        self.to_map_css(compressed)
    }

    /// Serialize the map as dart-sass does: `(k1: v1, k2: v2)`, with the empty
    /// map rendered as `()`. Keys and values use their inspect form so nested
    /// quoted strings keep their quotes.
    fn to_map_css(&self, compressed: bool) -> String {
        if self.entries.is_empty() {
            return "()".to_string();
        }
        let sep = if compressed { "," } else { ", " };
        let pair_sep = if compressed { ":" } else { ": " };
        let inner = self
            .entries
            .iter()
            .map(|(k, v)| format!("{}{pair_sep}{}", map_key_css(k), map_val_css(v)))
            .collect::<Vec<_>>()
            .join(sep);
        format!("({inner})")
    }
}

/// Serialize a map key (dart-sass uses the inspect form for keys/values).
fn map_key_css(v: &Value) -> String {
    match v {
        Value::Str(s) if s.quoted => serialize_quoted(&s.text),
        Value::Map(m) => m.to_map_css(false),
        other => other.to_css(false),
    }
}

/// Serialize a map value entry. A bare comma list inside a map is wrapped in
/// parentheses to disambiguate from the entry separators.
fn map_val_css(v: &Value) -> String {
    match v {
        Value::Str(s) if s.quoted => serialize_quoted(&s.text),
        Value::Map(m) => m.to_map_css(false),
        Value::List(l) if l.sep == ListSep::Comma && !l.bracketed && l.items.len() >= 2 => {
            format!("({})", l.to_css(false))
        }
        other => other.to_css(false),
    }
}

/// List separator.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum ListSep {
    /// Space-separated (`1px 2px`).
    Space,
    /// Comma-separated (`1px, 2px`).
    Comma,
    /// Slash-separated (`1px / 2px`), produced by `list.slash()`.
    Slash,
    /// Not yet decided: an empty or single-element list that has no explicit
    /// separator. It serializes like a space list but defers to the other
    /// operand's separator in `list.join`/`list.append`, and `list.separator`
    /// reports it as `space`. Only ever held by a list with fewer than two
    /// elements (two elements force a real separator).
    Undecided,
}

/// An sRGB color. Channels are `0..=255` and may be fractional; alpha is
/// `0..=1`.
///
/// A color may also carry a *modern* color-space representation in
/// [`Color::modern`]. When present, the color belongs to a non-legacy CSS
/// Color 4 space (or a legacy space stored in canonical units, e.g. `hsl`),
/// and serialization/channel access use that representation. The legacy
/// `r`/`g`/`b`/`a` fields still hold an sRGB-byte approximation so the large
/// body of legacy color builtins keep working unchanged.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct Color {
    pub r: f64,
    pub g: f64,
    pub b: f64,
    pub a: f64,
    /// The authored spelling (`"red"`, `"#336699"`). Used verbatim when
    /// the color is emitted unchanged; `None` for computed colors. SHARED
    /// (`Rc<str>`) because a color literal lives in the AST and is cloned out
    /// of it on every evaluation: the clone bumps a refcount instead of
    /// copying the handful of bytes into a fresh allocation. Nothing ever
    /// mutates a spelling in place — a color that changes gets a new spelling
    /// or none at all — so no holder needs to unshare it. The thin handle is
    /// also 8 bytes narrower than a `String`, which takes `Color` from 64
    /// down to 56 bytes — `Value` itself stays 64 for now, its width set by
    /// `Slash`'s own 56-byte payload.
    pub repr: Option<Rc<str>>,
    /// Modern CSS Color 4 representation. `None` for plain legacy sRGB
    /// colors (the common case); `Some` once the color is space-aware. BOXED so
    /// the 72-byte `ModernColor` doesn't inflate every `Color` (and thus every
    /// `Value`, since `Color` is the widest variant): inline it would DOUBLE
    /// `Value` to 128 bytes, and every scope slot / `Vec<Value>` element /
    /// lookup clone with it.
    pub modern: Option<Box<ModernColor>>,
}

/// A color CHANNEL never holds a negative zero: dart-sass 1.104.0 converts
/// one to `0` "as per the CSS spec", so `rgb(-0, 0, 0)` is `rgb(0, 0, 0)` and
/// `hsl(-0, …)` is `hsl(0, …)`. (A negative zero is otherwise preserved —
/// `math.div(0, -1)` is `-0` — so this is the color model's own rule, not the
/// number serializer's.)
pub(crate) fn without_negative_zero(v: f64) -> f64 {
    if v == 0.0 {
        0.0
    } else {
        v
    }
}

/// A CSS Color 4 color space.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum ColorSpace {
    Rgb,
    Hsl,
    Hwb,
    Srgb,
    SrgbLinear,
    DisplayP3,
    DisplayP3Linear,
    A98Rgb,
    ProphotoRgb,
    Rec2020,
    XyzD65,
    XyzD50,
    Lab,
    Lch,
    Oklab,
    Oklch,
}

impl ColorSpace {
    pub(crate) fn name(self) -> &'static str {
        match self {
            ColorSpace::Rgb => "rgb",
            ColorSpace::Hsl => "hsl",
            ColorSpace::Hwb => "hwb",
            ColorSpace::Srgb => "srgb",
            ColorSpace::SrgbLinear => "srgb-linear",
            ColorSpace::DisplayP3 => "display-p3",
            ColorSpace::DisplayP3Linear => "display-p3-linear",
            ColorSpace::A98Rgb => "a98-rgb",
            ColorSpace::ProphotoRgb => "prophoto-rgb",
            ColorSpace::Rec2020 => "rec2020",
            ColorSpace::XyzD65 => "xyz",
            ColorSpace::XyzD50 => "xyz-d50",
            ColorSpace::Lab => "lab",
            ColorSpace::Lch => "lch",
            ColorSpace::Oklab => "oklab",
            ColorSpace::Oklch => "oklch",
        }
    }

    pub(crate) fn from_name(s: &str) -> Option<ColorSpace> {
        // Color-space names are ASCII case-insensitive (`sRGB`, `Display-P3`,
        // `XYZ` all resolve); callers keep the original spelling for errors and
        // serialization always uses the canonical lower-case `name()`.
        Some(match s.to_ascii_lowercase().as_str() {
            "rgb" => ColorSpace::Rgb,
            "hsl" => ColorSpace::Hsl,
            "hwb" => ColorSpace::Hwb,
            "srgb" => ColorSpace::Srgb,
            "srgb-linear" => ColorSpace::SrgbLinear,
            "display-p3" => ColorSpace::DisplayP3,
            "display-p3-linear" => ColorSpace::DisplayP3Linear,
            "a98-rgb" => ColorSpace::A98Rgb,
            "prophoto-rgb" => ColorSpace::ProphotoRgb,
            "rec2020" => ColorSpace::Rec2020,
            "xyz" | "xyz-d65" => ColorSpace::XyzD65,
            "xyz-d50" => ColorSpace::XyzD50,
            "lab" => ColorSpace::Lab,
            "lch" => ColorSpace::Lch,
            "oklab" => ColorSpace::Oklab,
            "oklch" => ColorSpace::Oklch,
            _ => return None,
        })
    }

    /// Whether this is a legacy space (`rgb`/`hsl`/`hwb`).
    pub(crate) fn is_legacy(self) -> bool {
        matches!(self, ColorSpace::Rgb | ColorSpace::Hsl | ColorSpace::Hwb)
    }

    /// The three channel names for this space (in storage order).
    pub(crate) fn channel_names(self) -> [&'static str; 3] {
        match self {
            ColorSpace::Rgb
            | ColorSpace::Srgb
            | ColorSpace::SrgbLinear
            | ColorSpace::DisplayP3
            | ColorSpace::DisplayP3Linear
            | ColorSpace::A98Rgb
            | ColorSpace::ProphotoRgb
            | ColorSpace::Rec2020 => ["red", "green", "blue"],
            ColorSpace::Hsl => ["hue", "saturation", "lightness"],
            ColorSpace::Hwb => ["hue", "whiteness", "blackness"],
            ColorSpace::XyzD65 | ColorSpace::XyzD50 => ["x", "y", "z"],
            ColorSpace::Lab | ColorSpace::Oklab => ["lightness", "a", "b"],
            ColorSpace::Lch | ColorSpace::Oklch => ["lightness", "chroma", "hue"],
        }
    }
}

/// A color-space-aware color. Channels are stored in CSS Color 4 canonical
/// units (e.g. lab lightness `0..=100`, oklab lightness `0..=1`, hues in
/// degrees, rgb channels `0..=1`). A `None` channel is a missing channel.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct ModernColor {
    pub space: ColorSpace,
    pub channels: [Option<f64>; 3],
    pub alpha: Option<f64>,
}

impl Value {
    /// Serialize as it would appear in a CSS declaration value, into `out`.
    ///
    /// This is the primitive for every caller that already has a buffer — a
    /// declaration's value, a list's elements, an interpolation — because the
    /// string a value serializes to is nearly always about to be copied into
    /// one. Every value a stylesheet can legally emit is written here without
    /// allocating; what falls through to [`Value::to_css`] is a map or a
    /// first-class function/mixin, none of which is a valid CSS value at all
    /// (a declaration rejects them before serializing) — they reach this only
    /// nested inside a list on an error path.
    pub(crate) fn write_css(&self, out: &mut String, compressed: bool) {
        match self {
            Value::Number(n) => n.write_css(out, compressed),
            Value::Color(c) => c.write_css(out, compressed),
            Value::List(l) => l.write_css(out, compressed),
            Value::Str(s) => {
                if s.quoted {
                    push_quoted_styled(out, &s.text, compressed);
                } else {
                    push_unquoted(out, &s.text, compressed);
                }
            }
            Value::Bool(b) => out.push_str(if *b { "true" } else { "false" }),
            // The authored spelling of `12px/1.5`, already a string.
            Value::Slash(_, repr) => out.push_str(repr),
            Value::Calc(node) => node.write_calc_value_css(out, compressed),
            Value::Null => {}
            other => out.push_str(&other.to_css(compressed)),
        }
    }

    /// [`Value::to_interp`] into `out`, on the same terms as
    /// [`Value::write_css`]: interpolating `#{$i}` or `#{$name}` writes the
    /// number or the string's raw text straight into the template's buffer.
    pub(crate) fn write_interp(&self, out: &mut String) {
        match self {
            Value::Str(s) => out.push_str(&s.text),
            Value::Null => {}
            Value::List(l) => l.write_interp(out),
            Value::Number(n) => n.write_css(out, false),
            Value::Color(c) => c.write_css(out, false),
            Value::Bool(b) => out.push_str(if *b { "true" } else { "false" }),
            Value::Slash(_, repr) => out.push_str(repr),
            Value::Calc(node) => node.write_calc_value_css(out, false),
            other => out.push_str(&other.to_interp()),
        }
    }

    /// Serialize as it would appear in a CSS declaration value.
    pub(crate) fn to_css(&self, compressed: bool) -> String {
        match self {
            Value::Number(n) => n.to_css(compressed),
            Value::Color(c) => c.to_css(compressed),
            Value::Str(s) => {
                if s.quoted {
                    serialize_quoted_styled(&s.text, compressed)
                } else {
                    serialize_unquoted(&s.text, compressed)
                }
            }
            Value::List(l) => l.to_css(compressed),
            Value::Map(m) => m.to_map_css(compressed),
            Value::Bool(b) => b.to_string(),
            Value::Null => String::new(),
            Value::Slash(_, repr) => repr.clone(),
            Value::Calc(node) => node.to_calc_value_css(compressed),
            // Not a valid CSS value; rendered for the "isn't a valid CSS value"
            // error and for `inspect`.
            Value::Function(func) => func.inspect(),
            Value::Mixin(m) => m.inspect(),
        }
    }

    /// Serialize as it would appear inside `#{...}` interpolation, where
    /// strings lose their quotes.
    pub(crate) fn to_interp(&self) -> String {
        match self {
            // A directly interpolated string contributes its RAW text (dart
            // `_performInterpolation` takes `result.text` verbatim); only a
            // string nested in a composite value goes through the unquoted
            // serializer (see `List::to_interp`).
            Value::Str(s) => s.text.to_string(),
            Value::Null => String::new(),
            Value::List(l) => l.to_interp(),
            Value::Map(m) => m.to_map_css(false),
            Value::Slash(_, repr) => repr.clone(),
            Value::Calc(node) => node.to_calc_value_css(false),
            other => other.to_css(false),
        }
    }

    /// The message text for `@warn` / `@debug`: a top-level string is shown
    /// **unquoted**, every other value (including strings nested in a list) is
    /// shown with the dart-sass `inspect()` serialization (`"a" "b"`, `a b c`,
    /// `(k: v)`). Matches dart-sass's `value.toString()`.
    pub(crate) fn to_message(&self) -> String {
        match self {
            Value::Str(s) => s.text.to_string(),
            other => crate::builtins::inspect_value(other),
        }
    }

    /// dart-sass's `Value.toString()`: the spelling a value gets when a
    /// DIAGNOSTIC embeds it whole. It is `inspect()` plus one rule — an
    /// unbracketed, non-empty list is parenthesized, so the list's separator is
    /// never read as the sentence's own punctuation (`(1 2) is not a color.`).
    /// A string keeps its quotes. `inspect()` already parenthesizes the
    /// single-element comma and slash forms (`(1,)`, `(1/)`), which must not be
    /// wrapped a second time.
    ///
    /// Every message that embeds a whole value reads it from here, so the
    /// spellings cannot drift apart: `@error`, the legacy colour overloads'
    /// `$color: … is not a color.`, and the `Recommendation:` line of the
    /// removed `sass:color` members. Verified against dart-sass 1.104.1
    /// (2026-09-19), including the shapes where the three used to disagree: a
    /// one-element space list is `(1)`, not `1`.
    pub(crate) fn to_inspect_message(&self) -> String {
        match self {
            Value::List(l) if !l.bracketed && !l.items.is_empty() => {
                if l.items.len() == 1 && matches!(l.sep, ListSep::Comma | ListSep::Slash) {
                    crate::builtins::inspect_value(self)
                } else {
                    format!("({})", crate::builtins::inspect_value(self))
                }
            }
            other => crate::builtins::inspect_value(other),
        }
    }

    pub(crate) fn type_name(&self) -> &'static str {
        match self {
            Value::Number(_) => "number",
            Value::Color(_) => "color",
            Value::Str(_) => "string",
            // An argument list (`$args...`) reports as `arglist`, not `list`.
            Value::List(l) if l.keywords.is_some() => "arglist",
            Value::List(_) => "list",
            Value::Map(_) => "map",
            Value::Bool(_) => "bool",
            Value::Null => "null",
            Value::Slash(_, _) => "number",
            Value::Calc(_) => "calculation",
            Value::Function(_) => "function",
            Value::Mixin(_) => "mixin",
        }
    }

    /// Collapse a top-level slash-division value to its plain `number`,
    /// matching dart-sass's `withoutSlash`. Numbers nested inside lists keep
    /// their slash spelling, so lists are returned unchanged.
    pub(crate) fn without_slash(self) -> Value {
        match self {
            Value::Slash(n, _) => Value::Number(n),
            other => other,
        }
    }

    /// Sass truthiness: everything except `false` and `null` is truthy.
    pub(crate) fn is_truthy(&self) -> bool {
        !matches!(self, Value::Bool(false) | Value::Null)
    }

    /// Sass `==` equality. Numbers compare by value and unit; strings by
    /// text (quotedness is ignored); colors by channel; lists structurally.
    pub(crate) fn sass_eq(&self, other: &Value) -> bool {
        // A slash-division value compares as the plain number it wraps. Unwrap
        // only the slash operand(s) — the non-slash side is compared by
        // reference (no clone of a potentially large list/map).
        if matches!(self, Value::Slash(_, _)) || matches!(other, Value::Slash(_, _)) {
            let unwrap_num;
            let lhs: &Value = match self {
                Value::Slash(n, _) => {
                    unwrap_num = Value::Number(n.clone());
                    &unwrap_num
                }
                other => other,
            };
            let unwrap_num2;
            let rhs: &Value = match other {
                Value::Slash(n, _) => {
                    unwrap_num2 = Value::Number(n.clone());
                    &unwrap_num2
                }
                other => other,
            };
            return lhs.sass_eq(rhs);
        }
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => numbers_eq(a, b),
            (Value::Calc(a), Value::Calc(b)) => a == b,
            (Value::Str(a), Value::Str(b)) => a.text == b.text,
            (Value::Color(a), Value::Color(b)) => color_sass_eq(a, b),
            (Value::Bool(a), Value::Bool(b)) => a == b,
            (Value::Null, Value::Null) => true,
            (Value::List(a), Value::List(b)) => {
                a.sep == b.sep
                    && a.bracketed == b.bracketed
                    && a.items.len() == b.items.len()
                    && a.items.iter().zip(b.items.iter()).all(|(x, y)| x.sass_eq(y))
            }
            // Maps compare by content regardless of entry order.
            (Value::Map(a), Value::Map(b)) => {
                a.entries.len() == b.entries.len()
                    && a.entries
                        .iter()
                        .all(|(k, v)| b.get(k).is_some_and(|bv| bv.sass_eq(v)))
            }
            // An empty map and an empty list are equal in dart-sass.
            (Value::Map(m), Value::List(l)) | (Value::List(l), Value::Map(m)) => {
                m.entries.is_empty() && l.items.is_empty()
            }
            // Function references: built-ins by name, user functions by the
            // identity of their captured definition (see `SassFunction`).
            (Value::Function(a), Value::Function(b)) => a == b,
            // Mixin references: built-ins by name, user mixins by the identity
            // of their captured definition (see `SassMixin`).
            (Value::Mixin(a), Value::Mixin(b)) => a == b,
            _ => false,
        }
    }
}

/// dart-sass's numeric tolerance for `==` comparisons. Two finite numbers are
/// equal when their difference is below this epsilon (so `1in == 96px` and a
/// color channel like `127.99999999999861` equals `128`), mirroring
/// dart-sass's `fuzzyEquals`.
const FUZZY_EPSILON: f64 = 1e-11;

/// `1 / FUZZY_EPSILON`, the scale dart-sass's `fuzzyEquals` rounds at.
const INVERSE_FUZZY_EPSILON: f64 = 1e11;

/// dart-sass `fuzzyEquals`: exact equality (so `Infinity == Infinity`), or a
/// difference within [`FUZZY_EPSILON`] **and** the same value after scaling
/// both sides by 1e11 and rounding. `NaN` is never equal to anything (matching
/// dart-sass and IEEE semantics).
///
/// The second clause is load-bearing, and it is the whole comparison, not an
/// optimization of the first: 19.999999999994987 is within the epsilon of 20
/// yet scaling disagrees (1999999999999 against 2000000000000), so dart calls
/// it unequal. Every classification built on this — is a channel an integer, is
/// a color in gamut, does a triple match a named color — inherits that, and
/// dart's `namesByColor` lookup inherits it through `fuzzyHashCode`, which is
/// the SAME rounding. `[measured]` against dart-sass 1.104.1:
/// `meta.inspect(color.to-space(hsl(210, 50%, 7.8431372549%), rgb))` is
/// `rgba(3.9215686274500006%, 7.843137254899995%, 11.764705882349999%, 0.4)`,
/// not `rgba(10, 20, 30, 0.4)`.
pub(crate) fn fuzzy_eq(a: f64, b: f64) -> bool {
    a == b
        || ((a - b).abs() <= FUZZY_EPSILON
            && (a * INVERSE_FUZZY_EPSILON).round() == (b * INVERSE_FUZZY_EPSILON).round())
}

/// dart-sass `fuzzyIsInt`: whether a value is [`fuzzy_eq`] to its own rounding.
pub(crate) fn fuzzy_is_int(v: f64) -> bool {
    v.is_finite() && fuzzy_eq(v, v.round())
}

/// Sass `==` for two colors (dart-sass). Legacy colors with no missing channel
/// compare by their sRGB bytes, so they're space-agnostic
/// (`rgb(255 0 0) == hsl(0 100% 50%)`). Otherwise — a non-legacy space on either
/// side, or any missing (`none`) channel — they must share a color space and
/// have channel-by-channel equal (and equally-missing) channels and alpha.
fn color_sass_eq(a: &Color, b: &Color) -> bool {
    let space = |c: &Color| c.modern.as_ref().map(|m| m.space).unwrap_or(ColorSpace::Rgb);
    let chan_eq = |x: Option<f64>, y: Option<f64>| match (x, y) {
        (Some(p), Some(q)) => fuzzy_eq(p, q),
        (None, None) => true,
        _ => false,
    };
    // An untagged color is a plain legacy rgb with no missing channel.
    let channels = |c: &Color| -> [Option<f64>; 3] {
        match &c.modern {
            Some(m) => m.channels,
            None => [Some(c.r), Some(c.g), Some(c.b)],
        }
    };
    let alpha = |c: &Color| c.modern.as_ref().map_or(Some(c.a), |m| m.alpha);
    let (sa, sb) = (space(a), space(b));
    if sa != sb {
        // Different spaces are equal only when BOTH are legacy, compared via
        // their sRGB bytes (with `none` resolved); a non-legacy space never
        // equals a different space.
        if sa.is_legacy() && sb.is_legacy() {
            return fuzzy_eq(a.r, b.r) && fuzzy_eq(a.g, b.g) && fuzzy_eq(a.b, b.b) && fuzzy_eq(a.a, b.a);
        }
        return false;
    }
    // Same space: compare channel-by-channel, where a missing (`none`) channel
    // equals only another missing channel.
    let (ca, cb) = (channels(a), channels(b));
    (0..3).all(|i| chan_eq(ca[i], cb[i])) && chan_eq(alpha(a), alpha(b))
}

/// Sass `==` for two numbers. Numbers with the *exact* same unit compare by
/// value; numbers with different but convertible units compare after
/// converting `b` into `a`'s unit (so `1in == 96px`, `100grad == 90deg`).
/// Units are case-sensitive in `==` (dart-sass: `1PX != 1px`), so conversion
/// only applies to canonical lowercase units. Unitless vs unit-bearing, or
/// incompatible units, are never equal. Value comparisons are fuzzy
/// ([`fuzzy_eq`]).
fn numbers_eq(a: &Number, b: &Number) -> bool {
    if a.unit() == b.unit() {
        return fuzzy_eq(a.value, b.value);
    }
    // A unitless number is only equal to another unitless number; a differing
    // unit (handled above) is the only remaining same-emptiness case.
    if a.is_unitless() || b.is_unitless() {
        return false;
    }
    // Conversion is keyed on canonical lowercase units, matching dart-sass's
    // unit table; an authored uppercase unit (`IN`) is treated as unknown and
    // never converts.
    if a.unit().bytes().any(|c| c.is_ascii_uppercase()) || b.unit().bytes().any(|c| c.is_ascii_uppercase()) {
        return false;
    }
    match convert_factor(b.unit(), a.unit()) {
        Some(factor) => fuzzy_eq(a.value, b.value * factor),
        None => false,
    }
}

/// Append a unit with dart's `_writeIdentifier` escaping: a control
/// character (a decoded `1\9` IE hack) re-serializes as a hex escape with
/// its terminating space (`1\9 `); ordinary units append verbatim.
fn push_unit_escaped(out: &mut String, unit: &str) {
    if unit.chars().all(|c| (c as u32) >= 0x20 && (c as u32) != 0x7F) {
        out.push_str(unit);
        return;
    }
    for c in unit.chars() {
        let cu = c as u32;
        if cu < 0x20 || cu == 0x7F {
            out.push('\\');
            out.push_str(&format!("{cu:x}"));
            out.push(' ');
        } else {
            out.push(c);
        }
    }
}

impl Number {
    /// Serialize as it would appear in a CSS declaration value, into `out`.
    /// This is the hottest serialization path in the compiler — every dimension
    /// in every declaration — and it allocates nothing: the digits and the unit
    /// are generated where they belong.
    pub(crate) fn write_css(&self, out: &mut String, compressed: bool) {
        // A non-finite number serializes as a `calc()` constant, matching
        // dart-sass: a unitless `infinity`/`-infinity`/`NaN` prints as
        // `calc(infinity)` etc., and a unit-bearing one as `calc(infinity * 1px)`.
        // A multi-unit number likewise has no plain CSS form and serializes as
        // a calc with its units spelled out (`calc(1px * 1em)`, `calc(1 / 1px)`)
        // — dart-sass uses this form everywhere, including `meta.inspect`,
        // interpolation, and error messages.
        if !self.value.is_finite() || self.has_complex_units() {
            out.push_str("calc(");
            write_calc_number(out, self, compressed);
            out.push(')');
            return;
        }
        push_num(out, self.value, compressed);
        push_unit_escaped(out, self.unit());
    }

    pub(crate) fn to_css(&self, compressed: bool) -> String {
        let mut s = String::new();
        self.write_css(&mut s, compressed);
        s
    }

    /// dart-sass `unitString`: the human-readable unit list — `px`, `px*em`,
    /// `px/em`, `px*em/(rad*s)`, `px^-1`, `(px*em)^-1`, or `""` for unitless.
    /// Used by `math.unit()`.
    pub(crate) fn unit_string(&self) -> String {
        let numer = self.numer_units();
        let denom = self.denom_units();
        match (numer.is_empty(), denom.is_empty()) {
            (_, true) => numer.join("*"),
            (true, false) => {
                if denom.len() == 1 {
                    format!("{}^-1", denom[0])
                } else {
                    format!("({})^-1", denom.join("*"))
                }
            }
            (false, false) => {
                if denom.len() == 1 {
                    format!("{}/{}", numer.join("*"), denom[0])
                } else {
                    format!("{}/({})", numer.join("*"), denom.join("*"))
                }
            }
        }
    }

    /// Multiply by `other` with dart-sass `multiplyUnits` cancellation: each
    /// numerator cancels the first convertible denominator on the other side
    /// (scaling the value by the conversion), leftovers concatenate.
    pub(crate) fn mul(&self, other: &Number) -> Number {
        // Fast path: a unitless operand has nothing to cancel or concatenate,
        // so the result carries the other side's units verbatim — no unit-list
        // materialization (the general path builds four unit vectors).
        if matches!(other.units, Units::None) {
            return self.copy_units(self.value * other.value);
        }
        if matches!(self.units, Units::None) {
            return other.copy_units(self.value * other.value);
        }
        multiply_units(
            self.value * other.value,
            self.numer_units().to_vec(),
            self.denom_units().to_vec(),
            other.numer_units().to_vec(),
            other.denom_units().to_vec(),
        )
    }

    /// Divide by `other` (multiplication with `other`'s units inverted).
    pub(crate) fn div(&self, other: &Number) -> Number {
        // Fast paths mirroring `mul`: a unitless divisor leaves the units
        // untouched, and same-named single units cancel exactly (`px/px`).
        if matches!(other.units, Units::None) {
            return self.copy_units(self.value / other.value);
        }
        if let (Units::Single(a), Units::Single(b)) = (&self.units, &other.units) {
            if a == b {
                return Number::unitless(self.value / other.value);
            }
        }
        multiply_units(
            self.value / other.value,
            self.numer_units().to_vec(),
            self.denom_units().to_vec(),
            other.denom_units().to_vec(),
            other.numer_units().to_vec(),
        )
    }
}

/// The conversion factor used when a numerator unit cancels a denominator
/// unit: identical names (exact strings, like dart) cancel exactly (covering
/// unknown units like `foo/foo`), and units in the same dimension convert.
fn cancel_factor(numerator: &str, denominator: &str) -> Option<f64> {
    if numerator == denominator {
        return Some(1.0);
    }
    convert_factor(numerator, denominator)
}

/// The factor converting a value with `from` unit lists into `to` unit lists,
/// or `None` when they are incompatible. Each `from` numerator must match a
/// distinct convertible `to` numerator (any order), and likewise for the
/// denominators (a denominator's factor divides). Mirrors dart-sass's
/// `coerce`/`convertValue` for multi-unit numbers.
pub(crate) fn unit_lists_factor(from: (&[Rc<str>], &[Rc<str>]), to: (&[Rc<str>], &[Rc<str>])) -> Option<f64> {
    fn match_lists(from: &[Rc<str>], to: &[Rc<str>]) -> Option<f64> {
        if from.len() != to.len() {
            return None;
        }
        let mut factor = 1.0;
        let mut remaining: Vec<&str> = to.iter().map(|u| &**u).collect();
        for f in from {
            let i = remaining.iter().position(|t| cancel_factor(f, t).is_some())?;
            if let Some(fac) = cancel_factor(f, remaining[i]) {
                factor *= fac;
            }
            remaining.remove(i);
        }
        Some(factor)
    }
    let numer = match_lists(from.0, to.0)?;
    let denom = match_lists(from.1, to.1)?;
    Some(numer / denom)
}

/// dart-sass `multiplyUnits`: combine two numbers' unit lists, cancelling
/// each numerator against the first convertible denominator of the OTHER
/// operand (the value picks up the conversion factor — `1s` cancelling a
/// `/ms` denominator scales by 1000), and concatenating what remains.
fn multiply_units(
    mut value: f64,
    numer1: Vec<Rc<str>>,
    denom1: Vec<Rc<str>>,
    numer2: Vec<Rc<str>>,
    denom2: Vec<Rc<str>>,
) -> Number {
    let mut numer = Vec::new();
    let mut denom2 = denom2;
    for n in numer1 {
        match denom2.iter().position(|d| cancel_factor(&n, d).is_some()) {
            Some(i) => {
                if let Some(factor) = cancel_factor(&n, &denom2[i]) {
                    value *= factor;
                }
                denom2.remove(i);
            }
            None => numer.push(n),
        }
    }
    let mut denom1 = denom1;
    for n in numer2 {
        match denom1.iter().position(|d| cancel_factor(&n, d).is_some()) {
            Some(i) => {
                if let Some(factor) = cancel_factor(&n, &denom1[i]) {
                    value *= factor;
                }
                denom1.remove(i);
            }
            None => numer.push(n),
        }
    }
    denom1.extend(denom2);
    Number::with_units(value, numer, denom1)
}

/// A CSS dimension group whose units can be converted into one another.
///
/// Units in the same group are mutually convertible via [`convert_factor`];
/// units in different groups (or unknown units, `%`, etc.) are incompatible.
///
/// Note: dart-sass does NOT treat the frequency units `hz`/`khz` as
/// convertible in arithmetic (`1khz + 500hz` is an error), so frequency is
/// deliberately omitted here to match its behaviour byte-for-byte.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum Dim {
    Length,
    Angle,
    Time,
    Frequency,
    Resolution,
}

/// The CONVERTIBLE dimension group a unit belongs to, or `None` for `%`, an
/// unknown unit, or a unitless number. dart-sass's conversion table matches
/// unit names case-SENSITIVELY (`1in + 1q` converts but `1in + 1Q` errors,
/// `PX` never converts to `px`), even though calc-class *classification* is
/// case-insensitive (see `known_calc_class`).
pub(crate) fn unit_dimension(unit: &str) -> Option<Dim> {
    match unit {
        "px" | "in" | "cm" | "mm" | "q" | "pt" | "pc" => Some(Dim::Length),
        "deg" | "grad" | "rad" | "turn" => Some(Dim::Angle),
        "s" | "ms" => Some(Dim::Time),
        "Hz" | "kHz" => Some(Dim::Frequency),
        "dpi" | "dpcm" | "dppx" => Some(Dim::Resolution),
        _ => None,
    }
}

/// The canonical factor for a unit: a value of `1<unit>` equals
/// `canonical_factor(unit)` canonical units of its group. `None` for any
/// unit not in a convertible dimension group.
///
/// Canonical bases (verified against dart-sass):
/// length → px, angle → deg, time → s, frequency → Hz, resolution → dpi.
/// Lookups are case-sensitive like dart's conversion table.
fn canonical_factor(unit: &str) -> Option<f64> {
    use std::f64::consts::PI;
    Some(match unit {
        // length (canonical: px)
        "px" => 1.0,
        "in" => 96.0,
        "cm" => 96.0 / 2.54,
        "mm" => 96.0 / 25.4,
        "q" => 96.0 / 101.6,
        "pt" => 96.0 / 72.0,
        "pc" => 16.0,
        // angle (canonical: deg)
        "deg" => 1.0,
        "grad" => 9.0 / 10.0,
        "rad" => 180.0 / PI,
        "turn" => 360.0,
        // time (canonical: s)
        "s" => 1.0,
        "ms" => 1.0 / 1000.0,
        // frequency (canonical: Hz)
        "Hz" => 1.0,
        "kHz" => 1000.0,
        // resolution (canonical: dpi)
        "dpi" => 1.0,
        "dpcm" => 2.54,
        "dppx" => 96.0,
        _ => return None,
    })
}

/// The multiplier to convert a value in `from` units to `to` units
/// (`value_in_to = value_in_from * convert_factor(from, to)`). Returns
/// `None` when the two units are not in the same convertible group.
pub(crate) fn convert_factor(from: &str, to: &str) -> Option<f64> {
    if !units_compatible(from, to) {
        return None;
    }
    let f = canonical_factor(from)?;
    let t = canonical_factor(to)?;
    Some(f / t)
}

/// Whether two units can be combined in arithmetic. Identical units (exact
/// strings — dart treats `PX` and `px` as DIFFERENT units) are always
/// compatible; otherwise both must share a convertible dimension group. An
/// empty unit (unitless) is handled by the caller, not here — this is the
/// strict "two real units" test, mirroring dart-sass's `isComparableTo`.
pub(crate) fn units_compatible(a: &str, b: &str) -> bool {
    if a == b {
        return true;
    }
    match (unit_dimension(a), unit_dimension(b)) {
        (Some(da), Some(db)) => da == db,
        _ => false,
    }
}

/// A relative CSS length unit (`em`, `vw`, `ch`, …). dart-sass knows these are
/// *lengths* (so `calc(1ch + 1deg)` is a cross-dimension error) even though
/// they are not convertible to absolute lengths (so `calc(1px + 1vw)` is
/// preserved). The list mirrors dart-sass's font/viewport/container relative
/// length units; `%` and `fr` are NOT lengths (they preserve against
/// everything), and unknown units stay unknown.
fn is_relative_length(unit: &str) -> bool {
    matches!(
        unit.to_ascii_lowercase().as_str(),
        // font-relative
        "em" | "rem"
            | "ex"
            | "rex"
            | "cap"
            | "rcap"
            | "ch"
            | "rch"
            | "ic"
            | "ric"
            | "lh"
            | "rlh"
            // viewport-relative
            | "vw"
            | "svw"
            | "lvw"
            | "dvw"
            | "vh"
            | "svh"
            | "lvh"
            | "dvh"
            | "vi"
            | "svi"
            | "lvi"
            | "dvi"
            | "vb"
            | "svb"
            | "lvb"
            | "dvb"
            | "vmin"
            | "svmin"
            | "lvmin"
            | "dvmin"
            | "vmax"
            | "svmax"
            | "lvmax"
            | "dvmax"
            // container-relative
            | "cqw"
            | "cqh"
            | "cqi"
            | "cqb"
            | "cqmin"
            | "cqmax"
    )
}

/// The broad class a unit belongs to for `calc()` compatibility decisions.
/// Unlike [`Dim`] (the *convertible*, case-sensitive groups), classification
/// is case-INSENSITIVE (`calc(1PX + 1s)` and `calc(1Q + 1s)` error
/// cross-class even though `PX`/`Q` never convert) and includes the relative
/// length units. Returns `None` for `%`, `fr`, and genuinely unknown units,
/// which `calc()` preserves verbatim rather than rejecting.
fn known_calc_class(unit: &str) -> Option<u8> {
    if is_relative_length(unit) {
        return Some(0); // length class (relative, not convertible)
    }
    match unit.to_ascii_lowercase().as_str() {
        "px" | "in" | "cm" | "mm" | "q" | "pt" | "pc" => Some(0),
        "deg" | "grad" | "rad" | "turn" => Some(1),
        "s" | "ms" => Some(2),
        "dpi" | "dpcm" | "dppx" => Some(3),
        "hz" | "khz" => Some(4),
        _ => None,
    }
}

/// Whether two distinct real units make a `calc()` `+`/`-` an error rather
/// than a preserved expression. dart-sass errors only when BOTH units are
/// known absolute units of DIFFERENT classes (`calc(1px + 1s)`,
/// `calc(1px + 1hz)`); when either unit is relative/unknown
/// (`calc(1px + 1vw)`, `calc(100% - 10px)`) or they share a class but are
/// not convertible (`calc(1khz + 1hz)`), the expression is kept verbatim.
pub(crate) fn calc_units_incompatible(a: &str, b: &str) -> bool {
    match (known_calc_class(a), known_calc_class(b)) {
        (Some(ca), Some(cb)) => ca != cb,
        _ => false,
    }
}

/// dart `Value.isBlank`: `null`, an EMPTY unquoted string, or a list whose
/// every element is blank. Blank elements vanish from list serialization
/// (`foo #{""}` emits `foo`, separator included).
fn value_is_blank(v: &Value) -> bool {
    match v {
        Value::Null => true,
        Value::Str(s) => !s.quoted && s.text.is_empty(),
        // A BRACKETED list is never blank (`[[]]` and `foo []` survive).
        Value::List(l) => !l.bracketed && l.items.iter().all(value_is_blank),
        _ => false,
    }
}

impl List {
    /// Serialize into `out`, element by element. A shorthand value such as
    /// `0 auto` used to cost a string per element, a vector of them, a joined
    /// buffer and — bracketed — a fourth for the brackets; it now costs none of
    /// those, because every element writes where it belongs.
    fn write_css(&self, out: &mut String, compressed: bool) {
        let sep = match (self.sep, compressed) {
            // An undecided list has at most one element, so its separator
            // string is never actually used; serialize it like a space list.
            (ListSep::Space | ListSep::Undecided, _) => " ",
            (ListSep::Comma, true) => ",",
            (ListSep::Comma, false) => ", ",
            (ListSep::Slash, true) => "/",
            (ListSep::Slash, false) => " / ",
        };
        if self.bracketed {
            out.push('[');
        }
        for (i, v) in self.items.iter().filter(|v| !value_is_blank(v)).enumerate() {
            if i > 0 {
                out.push_str(sep);
            }
            v.write_css(out, compressed);
        }
        if self.bracketed {
            out.push(']');
        }
    }

    fn to_css(&self, compressed: bool) -> String {
        let mut s = String::new();
        self.write_css(&mut s, compressed);
        s
    }

    fn write_interp(&self, out: &mut String) {
        let sep = match self.sep {
            ListSep::Space | ListSep::Undecided => " ",
            ListSep::Comma => ", ",
            ListSep::Slash => " / ",
        };
        if self.bracketed {
            out.push('[');
        }
        for (i, v) in self.items.iter().filter(|v| !value_is_blank(v)).enumerate() {
            if i > 0 {
                out.push_str(sep);
            }
            match v {
                // A string INSIDE a composite value serializes through dart's
                // quote-less serializer (`_visitUnquotedString`): its newlines
                // collapse to single spaces (issue_1786 `"#{a $str-with-lf}"`),
                // unlike a directly interpolated string's raw text.
                // Interpolation is serialized in the EXPANDED style in
                // dart-sass whatever the output style is (`_serialize` takes
                // the default), so a private-use character still escapes here.
                Value::Str(s) => push_unquoted(out, &s.text, false),
                other => other.write_interp(out),
            }
        }
        if self.bracketed {
            out.push(']');
        }
    }

    fn to_interp(&self) -> String {
        let mut s = String::new();
        self.write_interp(&mut s);
        s
    }
}

/// `#` followed by ASCII hex `digits`, as a shared spelling. Built through a
/// stack buffer rather than `format!` so the `Rc` allocates ONCE: a hex literal
/// is parsed on every compile, and going through a `String` would copy the
/// bytes twice for a spelling that is at most nine of them.
fn hex_repr(digits: &[u8]) -> Rc<str> {
    let mut buf = [b'#'; 9];
    let end = 1 + digits.len();
    if let Some(dst) = buf.get_mut(1..end) {
        dst.copy_from_slice(digits);
        if let Ok(text) = std::str::from_utf8(&buf[..end]) {
            return Rc::from(text);
        }
    }
    // Unreachable for a parsed literal (3/4/6/8 ASCII hex digits) or a
    // canonicalized one (6): a correct fallback in place of a panic.
    Rc::from(format!("#{}", String::from_utf8_lossy(digits)).as_str())
}

impl Color {
    pub(crate) fn rgb(r: f64, g: f64, b: f64, a: f64) -> Self {
        Color {
            r: without_negative_zero(r),
            g: without_negative_zero(g),
            b: without_negative_zero(b),
            a: without_negative_zero(a),
            repr: None,
            modern: None,
        }
    }

    /// Parse the hex digits following a `#` (3/4/6/8 long). Returns `None`
    /// on an invalid length or digit.
    pub(crate) fn from_hex(digits: &str) -> Option<Color> {
        let parse = |s: &str| u8::from_str_radix(s, 16).ok().map(|v| v as f64);
        let (r, g, b, a) = match digits.len() {
            3 => {
                let d: Vec<char> = digits.chars().collect();
                (
                    parse(&format!("{0}{0}", d[0]))?,
                    parse(&format!("{0}{0}", d[1]))?,
                    parse(&format!("{0}{0}", d[2]))?,
                    255.0,
                )
            }
            4 => {
                let d: Vec<char> = digits.chars().collect();
                (
                    parse(&format!("{0}{0}", d[0]))?,
                    parse(&format!("{0}{0}", d[1]))?,
                    parse(&format!("{0}{0}", d[2]))?,
                    parse(&format!("{0}{0}", d[3]))?,
                )
            }
            6 => (
                parse(&digits[0..2])?,
                parse(&digits[2..4])?,
                parse(&digits[4..6])?,
                255.0,
            ),
            8 => (
                parse(&digits[0..2])?,
                parse(&digits[2..4])?,
                parse(&digits[4..6])?,
                parse(&digits[6..8])?,
            ),
            _ => return None,
        };
        let a = a / 255.0;
        let opaque = (a - 1.0).abs() < f64::EPSILON;
        // dart-sass preserves the *authored* spelling of an opaque 3- or
        // 6-digit hex literal verbatim — `#fff` stays `#fff`, `#FFAA00` keeps
        // its uppercase. The alpha-channel forms (4/8 digits) are always
        // canonicalized: opaque ones round-trip as lowercase 6-digit hex
        // (`#abcf` -> `#aabbcc`), while partial-alpha ones fall back to a
        // computed `rgba()`.
        let repr: Option<Rc<str>> = if opaque {
            match digits.len() {
                3 | 6 => Some(hex_repr(digits.as_bytes())),
                _ => {
                    const HEX: &[u8; 16] = b"0123456789abcdef";
                    let mut six = [0u8; 6];
                    for (i, channel) in [r, g, b].into_iter().enumerate() {
                        let byte = channel.round() as u8;
                        six[i * 2] = HEX[usize::from(byte >> 4)];
                        six[i * 2 + 1] = HEX[usize::from(byte & 0xf)];
                    }
                    Some(hex_repr(&six))
                }
            }
        } else {
            None
        };
        Some(Color {
            r,
            g,
            b,
            a,
            repr,
            modern: None,
        })
    }

    /// Convert to HSL: hue in degrees `[0,360)`, saturation/lightness in
    /// `[0,1]`.
    pub(crate) fn to_hsl(&self) -> (f64, f64, f64) {
        let r = self.r / 255.0;
        let g = self.g / 255.0;
        let b = self.b / 255.0;
        let max = r.max(g).max(b);
        let min = r.min(g).min(b);
        let l = (max + min) / 2.0;
        let d = max - min;
        let s = if d == 0.0 {
            0.0
        } else {
            d / (1.0 - (2.0 * l - 1.0).abs())
        };
        let h = if d == 0.0 {
            0.0
        } else if max == r {
            60.0 * (((g - b) / d).rem_euclid(6.0))
        } else if max == g {
            60.0 * ((b - r) / d + 2.0)
        } else {
            60.0 * ((r - g) / d + 4.0)
        };
        (h.rem_euclid(360.0), s, l)
    }

    /// Build a color from HSL (hue degrees, sat/light `[0,1]`) + alpha.
    pub(crate) fn from_hsl(h: f64, s: f64, l: f64, a: f64) -> Color {
        // The conversion below has no answer for a non-finite channel — it
        // would pick the fallback sector and hand back a NaN component — and
        // dart-sass 1.104.0 does not ask it to: a polar HUE converts every
        // non-finite value to 0, and a NaN elsewhere converts too. That is why
        // `adjust-hue(red, NaN)`, which rotates the hue by NaN, is still red.
        let h = if h.is_finite() {
            without_negative_zero(h)
        } else {
            0.0
        };
        let s = if s.is_nan() { 0.0 } else { s };
        let l = if l.is_nan() { 0.0 } else { l };
        let h = h.rem_euclid(360.0);
        let c = (1.0 - (2.0 * l - 1.0).abs()) * s;
        let x = c * (1.0 - (((h / 60.0) % 2.0) - 1.0).abs());
        let m = l - c / 2.0;
        let (r1, g1, b1) = if h < 60.0 {
            (c, x, 0.0)
        } else if h < 120.0 {
            (x, c, 0.0)
        } else if h < 180.0 {
            (0.0, c, x)
        } else if h < 240.0 {
            (0.0, x, c)
        } else if h < 300.0 {
            (x, 0.0, c)
        } else {
            (c, 0.0, x)
        };
        Color::rgb((r1 + m) * 255.0, (g1 + m) * 255.0, (b1 + m) * 255.0, a)
    }

    /// dart `_canUseHex` (serialize.dart:860): every channel a FUZZY integer
    /// inside `[0, 256)`. The bound is part of the rule — an out-of-gamut
    /// channel has no two-digit hex spelling, and clamping one into range would
    /// print a different color — and `meta.inspect`, which does not reroute an
    /// out-of-gamut color through hsl, is where a color can reach here with
    /// one.
    fn can_use_hex(&self) -> bool {
        let ok =
            |v: f64| fuzzy_is_int(v) && (v > 0.0 || fuzzy_eq(v, 0.0)) && v < 256.0 && !fuzzy_eq(v, 256.0);
        ok(self.r) && ok(self.g) && ok(self.b)
    }

    pub(crate) fn to_css(&self, compressed: bool) -> String {
        let mut s = String::new();
        self.write_css(&mut s, compressed);
        s
    }

    /// Serialize into `out`. A color is written where it belongs: the source
    /// spelling a literal keeps, a hex triple, and the `rgb()`/`rgba()` form all
    /// go straight into the caller's buffer, digits included.
    pub(crate) fn write_css(&self, out: &mut String, compressed: bool) {
        self.write_css_mode(out, compressed, false);
    }

    /// [`write_css`] with dart's `_inspect` flag, which changes one rule: a
    /// channel's integrality is tested fuzzily for `meta.inspect` and exactly
    /// for CSS output (see [`push_rgb_channels`]).
    fn write_css_mode(&self, out: &mut String, compressed: bool, inspect: bool) {
        if let Some(m) = &self.modern {
            out.push_str(&m.to_css_mode(compressed, inspect));
            return;
        }
        if !compressed {
            if let Some(repr) = &self.repr {
                out.push_str(repr);
                return;
            }
        }
        let opaque = fuzzy_eq(self.a, 1.0);
        if opaque && self.can_use_hex() {
            let r = self.r.round().clamp(0.0, 255.0) as u8;
            let g = self.g.round().clamp(0.0, 255.0) as u8;
            let b = self.b.round().clamp(0.0, 255.0) as u8;
            if compressed {
                // `#aabbcc` shortens to `#abc` when each channel's nibbles
                // match, so the shortest hex is four characters wide instead of
                // seven — the width a name has to beat, decided without either
                // spelling being built.
                let halvable = |v: u8| v >> 4 == v & 0xf;
                let hex_len = if halvable(r) && halvable(g) && halvable(b) {
                    4
                } else {
                    7
                };
                // dart-sass compressed: emit whichever is shorter, the shortest
                // hex or the color's canonical CSS name (name wins ties — e.g.
                // `aqua` == `#0ff`). `compressed_color_name` is the value-keyed
                // reverse table of exactly the names that are no longer than the
                // hex; absent => hex is shorter.
                if let Some(name) = compressed_color_name(r, g, b) {
                    if name.len() <= hex_len {
                        out.push_str(name);
                        return;
                    }
                }
                if hex_len == 4 {
                    out.push('#');
                    for v in [r, g, b] {
                        out.push(HEX_DIGITS[(v & 0xf) as usize] as char);
                    }
                    return;
                }
            }
            out.push('#');
            for v in [r, g, b] {
                out.push(HEX_DIGITS[(v >> 4) as usize] as char);
                out.push(HEX_DIGITS[(v & 0xf) as usize] as char);
            }
            return;
        }
        let start = out.len();
        let sep = if compressed { "," } else { ", " };
        out.push_str(if opaque { "rgb(" } else { "rgba(" });
        push_rgb_channels(out, self.r, self.g, self.b, compressed, sep, inspect);
        if !opaque {
            out.push_str(sep);
            push_num(out, self.a, compressed);
        }
        out.push(')');
        // dart-sass compressed output emits whichever legacy form is SHORTER:
        // the rgb()/rgba() form or the equivalent hsl()/hsla() form. A computed
        // color such as `darken(#336699, 10%)` -> `rgb(38.25,76.5,114.75)` is
        // therefore written as the shorter `hsl(210,50%,30%)`. Only an in-gamut
        // color has an exact legacy hsl equivalent; an out-of-gamut channel (or
        // any expanded output) keeps the rgb form. The hsl candidate is derived
        // FROM the rgb channels, so float noise can only lengthen it (never
        // shorten the rgb past it), keeping the choice safe.
        if compressed {
            let in_gamut = |v: f64| (v > 0.0 || fuzzy_eq(v, 0.0)) && (v < 255.0 || fuzzy_eq(v, 255.0));
            if in_gamut(self.r) && in_gamut(self.g) && in_gamut(self.b) {
                // The candidate is built rather than written: it only replaces
                // what is already in `out` if it turns out to be shorter, and
                // compressed output is the one style where the comparison —
                // not the copy — is what costs.
                let hsl = crate::builtins::srgb_to_hsl([self.r / 255.0, self.g / 255.0, self.b / 255.0]);
                // dart nulls the hue when saturation is fuzzy-zero (srgb.dart:
                // `fuzzyEquals(saturation, 0) ? null : hue`), and a missing hue
                // serializes as 0 — float dust in a gray triple must not leak
                // a phantom hue. It is `fuzzyEquals` and not a bare epsilon: a
                // saturation of 6e-12 KEEPS its hue, which lengthens the hsl bid
                // past the rgb one. `[measured]`:
                // `color.change(hsl(90, 50%, 50%), $saturation: -0.000000000006%)`
                // compresses to `rgb(50%,50%,50%)`, not `hsl(0,0%,50%)`.
                let hue = if fuzzy_eq(hsl[1], 0.0) { 0.0 } else { hsl[0] };
                let hh = fmt_num(hue, true);
                let ss = fmt_num(hsl[1], true);
                let ll = fmt_num(hsl[2], true);
                let hsl_css = if opaque {
                    format!("hsl({hh},{ss}%,{ll}%)")
                } else {
                    format!("hsla({hh},{ss}%,{ll}%,{})", fmt_num(self.a, true))
                };
                // dart gives HSL a TWO-CHARACTER handicap
                // (serialize.dart:775, `rgbString.length <= hslString.length + 2`)
                // — its comment: "Add two characters for HSL for the %s on
                // saturation and lightness." So rgb wins ties AND wins when it is
                // up to two characters longer.
                if out.len() - start > hsl_css.len() + 2 {
                    out.truncate(start);
                    out.push_str(&hsl_css);
                }
            }
        }
    }

    /// The `inspect: true` serialization of this color.
    ///
    /// dart's `Value.toString()` is `serializeValue(this, inspect: true)`
    /// (lib/src/value.dart:439), so EVERY color interpolated into an error
    /// message (`"Color $color ..."`) renders with inspect semantics, not CSS
    /// output semantics. The two differ for a space-aware color: `hwb(200 20%
    /// 30%)` inspects as itself but writes as `hsl(200, 55.5555555556%, 45%)`.
    /// Delegates to `ModernColor::inspect_css` when the color is space-aware;
    /// a plain legacy sRGB color serializes identically either way.
    pub(crate) fn inspect_css(&self) -> String {
        match &self.modern {
            Some(m) => m.inspect_css(),
            None => {
                let mut out = String::new();
                self.write_css_mode(&mut out, false, true);
                out
            }
        }
    }
}

/// The CSS named-color spelling for an exact, fully-opaque integer RGB
/// triple (dart-sass canonical names). `None` if the triple has no name.
pub(crate) fn rgb_name(r: f64, g: f64, b: f64) -> Option<&'static str> {
    let int = |v: f64| {
        // dart looks the color up in `namesByColor`, a map keyed by SassColor,
        // so a hit needs `fuzzyHashCode` — the same 1e11 rounding [`fuzzy_eq`]
        // does — to agree on every channel. A channel further off than that
        // has no name, however close it looks.
        let r = v.round();
        if fuzzy_eq(v, r) && (0.0..=255.0).contains(&r) {
            Some(r as u16)
        } else {
            None
        }
    };
    let (r, g, b) = (int(r)?, int(g)?, int(b)?);
    match (r, g, b) {
        (0, 0, 0) => Some("black"),
        (0, 0, 128) => Some("navy"),
        (0, 0, 139) => Some("darkblue"),
        (0, 0, 205) => Some("mediumblue"),
        (0, 0, 255) => Some("blue"),
        (0, 100, 0) => Some("darkgreen"),
        (0, 128, 0) => Some("green"),
        (0, 128, 128) => Some("teal"),
        (0, 139, 139) => Some("darkcyan"),
        (0, 191, 255) => Some("deepskyblue"),
        (0, 206, 209) => Some("darkturquoise"),
        (0, 250, 154) => Some("mediumspringgreen"),
        (0, 255, 0) => Some("lime"),
        (0, 255, 127) => Some("springgreen"),
        (0, 255, 255) => Some("aqua"),
        (25, 25, 112) => Some("midnightblue"),
        (30, 144, 255) => Some("dodgerblue"),
        (32, 178, 170) => Some("lightseagreen"),
        (34, 139, 34) => Some("forestgreen"),
        (46, 139, 87) => Some("seagreen"),
        (47, 79, 79) => Some("darkslategray"),
        (50, 205, 50) => Some("limegreen"),
        (60, 179, 113) => Some("mediumseagreen"),
        (64, 224, 208) => Some("turquoise"),
        (65, 105, 225) => Some("royalblue"),
        (70, 130, 180) => Some("steelblue"),
        (72, 61, 139) => Some("darkslateblue"),
        (72, 209, 204) => Some("mediumturquoise"),
        (75, 0, 130) => Some("indigo"),
        (85, 107, 47) => Some("darkolivegreen"),
        (95, 158, 160) => Some("cadetblue"),
        (100, 149, 237) => Some("cornflowerblue"),
        (102, 51, 153) => Some("rebeccapurple"),
        (102, 205, 170) => Some("mediumaquamarine"),
        (105, 105, 105) => Some("dimgray"),
        (106, 90, 205) => Some("slateblue"),
        (107, 142, 35) => Some("olivedrab"),
        (112, 128, 144) => Some("slategray"),
        (119, 136, 153) => Some("lightslategray"),
        (123, 104, 238) => Some("mediumslateblue"),
        (124, 252, 0) => Some("lawngreen"),
        (127, 255, 0) => Some("chartreuse"),
        (127, 255, 212) => Some("aquamarine"),
        (128, 0, 0) => Some("maroon"),
        (128, 0, 128) => Some("purple"),
        (128, 128, 0) => Some("olive"),
        (128, 128, 128) => Some("gray"),
        (135, 206, 235) => Some("skyblue"),
        (135, 206, 250) => Some("lightskyblue"),
        (138, 43, 226) => Some("blueviolet"),
        (139, 0, 0) => Some("darkred"),
        (139, 0, 139) => Some("darkmagenta"),
        (139, 69, 19) => Some("saddlebrown"),
        (143, 188, 143) => Some("darkseagreen"),
        (144, 238, 144) => Some("lightgreen"),
        (147, 112, 219) => Some("mediumpurple"),
        (148, 0, 211) => Some("darkviolet"),
        (152, 251, 152) => Some("palegreen"),
        (153, 50, 204) => Some("darkorchid"),
        (154, 205, 50) => Some("yellowgreen"),
        (160, 82, 45) => Some("sienna"),
        (165, 42, 42) => Some("brown"),
        (169, 169, 169) => Some("darkgray"),
        (173, 216, 230) => Some("lightblue"),
        (173, 255, 47) => Some("greenyellow"),
        (175, 238, 238) => Some("paleturquoise"),
        (176, 196, 222) => Some("lightsteelblue"),
        (176, 224, 230) => Some("powderblue"),
        (178, 34, 34) => Some("firebrick"),
        (184, 134, 11) => Some("darkgoldenrod"),
        (186, 85, 211) => Some("mediumorchid"),
        (188, 143, 143) => Some("rosybrown"),
        (189, 183, 107) => Some("darkkhaki"),
        (192, 192, 192) => Some("silver"),
        (199, 21, 133) => Some("mediumvioletred"),
        (205, 92, 92) => Some("indianred"),
        (205, 133, 63) => Some("peru"),
        (210, 105, 30) => Some("chocolate"),
        (210, 180, 140) => Some("tan"),
        (211, 211, 211) => Some("lightgray"),
        (216, 191, 216) => Some("thistle"),
        (218, 112, 214) => Some("orchid"),
        (218, 165, 32) => Some("goldenrod"),
        (219, 112, 147) => Some("palevioletred"),
        (220, 20, 60) => Some("crimson"),
        (220, 220, 220) => Some("gainsboro"),
        (221, 160, 221) => Some("plum"),
        (222, 184, 135) => Some("burlywood"),
        (224, 255, 255) => Some("lightcyan"),
        (230, 230, 250) => Some("lavender"),
        (233, 150, 122) => Some("darksalmon"),
        (238, 130, 238) => Some("violet"),
        (238, 232, 170) => Some("palegoldenrod"),
        (240, 128, 128) => Some("lightcoral"),
        (240, 230, 140) => Some("khaki"),
        (240, 248, 255) => Some("aliceblue"),
        (240, 255, 240) => Some("honeydew"),
        (240, 255, 255) => Some("azure"),
        (244, 164, 96) => Some("sandybrown"),
        (245, 222, 179) => Some("wheat"),
        (245, 245, 220) => Some("beige"),
        (245, 245, 245) => Some("whitesmoke"),
        (245, 255, 250) => Some("mintcream"),
        (248, 248, 255) => Some("ghostwhite"),
        (250, 128, 114) => Some("salmon"),
        (250, 235, 215) => Some("antiquewhite"),
        (250, 240, 230) => Some("linen"),
        (250, 250, 210) => Some("lightgoldenrodyellow"),
        (253, 245, 230) => Some("oldlace"),
        (255, 0, 0) => Some("red"),
        (255, 0, 255) => Some("fuchsia"),
        (255, 20, 147) => Some("deeppink"),
        (255, 69, 0) => Some("orangered"),
        (255, 99, 71) => Some("tomato"),
        (255, 105, 180) => Some("hotpink"),
        (255, 127, 80) => Some("coral"),
        (255, 140, 0) => Some("darkorange"),
        (255, 160, 122) => Some("lightsalmon"),
        (255, 165, 0) => Some("orange"),
        (255, 182, 193) => Some("lightpink"),
        (255, 192, 203) => Some("pink"),
        (255, 215, 0) => Some("gold"),
        (255, 218, 185) => Some("peachpuff"),
        (255, 222, 173) => Some("navajowhite"),
        (255, 228, 181) => Some("moccasin"),
        (255, 228, 196) => Some("bisque"),
        (255, 228, 225) => Some("mistyrose"),
        (255, 235, 205) => Some("blanchedalmond"),
        (255, 239, 213) => Some("papayawhip"),
        (255, 240, 245) => Some("lavenderblush"),
        (255, 245, 238) => Some("seashell"),
        (255, 248, 220) => Some("cornsilk"),
        (255, 250, 205) => Some("lemonchiffon"),
        (255, 250, 240) => Some("floralwhite"),
        (255, 250, 250) => Some("snow"),
        (255, 255, 0) => Some("yellow"),
        (255, 255, 224) => Some("lightyellow"),
        (255, 255, 240) => Some("ivory"),
        (255, 255, 255) => Some("white"),
        _ => None,
    }
}

/// Lowercase hex digits, for writing a color's channels without `core::fmt`.
const HEX_DIGITS: &[u8; 16] = b"0123456789abcdef";

/// The canonical CSS name for an opaque RGB value, but ONLY for the colors whose
/// name is no longer than their shortest hex — i.e. the exact set dart-sass
/// prefers in compressed output (`red` over `#f00`, `aqua` over `#0ff`). Colors
/// whose hex is shorter (e.g. `magenta` -> `#f0f`) are deliberately absent.
/// Derived from the dart-sass oracle, so duplicate names resolve to dart's
/// canonical pick (cyan -> aqua, grey -> gray).
fn compressed_color_name(r: u8, g: u8, b: u8) -> Option<&'static str> {
    Some(match (r, g, b) {
        (0, 255, 255) => "aqua",
        (240, 255, 255) => "azure",
        (245, 245, 220) => "beige",
        (255, 228, 196) => "bisque",
        (0, 0, 255) => "blue",
        (165, 42, 42) => "brown",
        (255, 127, 80) => "coral",
        (220, 20, 60) => "crimson",
        (139, 0, 0) => "darkred",
        (105, 105, 105) => "dimgray",
        (255, 215, 0) => "gold",
        (128, 128, 128) => "gray",
        (0, 128, 0) => "green",
        (255, 105, 180) => "hotpink",
        (75, 0, 130) => "indigo",
        (255, 255, 240) => "ivory",
        (240, 230, 140) => "khaki",
        (0, 255, 0) => "lime",
        (250, 240, 230) => "linen",
        (128, 0, 0) => "maroon",
        (0, 0, 128) => "navy",
        (253, 245, 230) => "oldlace",
        (128, 128, 0) => "olive",
        (255, 165, 0) => "orange",
        (218, 112, 214) => "orchid",
        (205, 133, 63) => "peru",
        (255, 192, 203) => "pink",
        (221, 160, 221) => "plum",
        (128, 0, 128) => "purple",
        (255, 0, 0) => "red",
        (250, 128, 114) => "salmon",
        (160, 82, 45) => "sienna",
        (192, 192, 192) => "silver",
        (135, 206, 235) => "skyblue",
        (255, 250, 250) => "snow",
        (210, 180, 140) => "tan",
        (0, 128, 128) => "teal",
        (216, 191, 216) => "thistle",
        (255, 99, 71) => "tomato",
        (238, 130, 238) => "violet",
        (245, 222, 179) => "wheat",
        _ => return None,
    })
}

impl ModernColor {
    /// Whether any of the three channels (or alpha) is a missing channel.
    fn has_missing(&self) -> bool {
        self.channels.iter().any(|c| c.is_none()) || self.alpha.is_none()
    }

    fn is_opaque(&self) -> bool {
        matches!(self.alpha, Some(a) if fuzzy_eq(a, 1.0))
    }

    /// Serialize a single channel, rendering a missing channel as `none`. A
    /// non-finite value (from a degenerate `calc()`, e.g. a lab a/b channel)
    /// serializes as a `calc()` constant like dart-sass (`calc(infinity)`).
    fn chan(&self, i: usize, compressed: bool) -> String {
        match self.channels[i] {
            None => "none".to_string(),
            Some(v) if !v.is_finite() => Number::unitless(v).to_css(compressed),
            Some(v) => fmt_num(v, compressed),
        }
    }

    /// Serialize a channel as a percentage of `denom` (e.g. lab lightness over
    /// 100, oklab lightness over 1). Missing → `none`; non-finite → a `%`-unit
    /// `calc()` constant (`calc(infinity * 1%)`).
    ///
    /// Compressed output drops the `%` of a *finite* channel and writes the
    /// channel's own stored value instead, which is the same number for lab/lch
    /// (0–100) but the unscaled one for oklab/oklch (0–1). A non-finite channel
    /// keeps its `%` in either style, because the unit is what makes the
    /// `calc()` constant a percentage. dart-sass writes the unit-less form
    /// unconditionally here rather than picking the shorter of the two:
    /// `[measured]` against dart-sass 1.104.1, `oklab(33.333333% .1 -0.1)`
    /// compresses to `oklab(.33333333 .1 -0.1)` — the same length — and
    /// `oklab(1% 0 0)` to `oklab(.01 0 0)`, which is longer.
    fn chan_pct(&self, i: usize, denom: f64, compressed: bool) -> String {
        match self.channels[i] {
            None => "none".to_string(),
            Some(v) if !v.is_finite() => Number::with_unit(v, "%").to_css(compressed),
            Some(v) if compressed => fmt_num(v, true),
            Some(v) => format!("{}%", fmt_num(v / denom * 100.0, false)),
        }
    }

    /// Serialize a hue channel with the `deg` suffix. Missing → `none`;
    /// non-finite → a `deg`-unit `calc()` constant (`calc(NaN * 1deg)`).
    ///
    /// Compressed output drops the `deg` of a *finite* hue: an unadorned number
    /// means degrees in every function that takes one, so the suffix is three
    /// bytes of nothing. This applies to the modern form of hsl/hwb as well as
    /// to lch/oklch. A non-finite hue keeps its `deg` in either style, since
    /// the unit is part of the `calc()` constant.
    fn chan_hue(&self, i: usize, compressed: bool) -> String {
        match self.channels[i] {
            None => "none".to_string(),
            Some(v) if !v.is_finite() => Number::with_unit(v, "deg").to_css(compressed),
            Some(v) if compressed => fmt_num(v, true),
            Some(v) => format!("{}deg", fmt_num(v, false)),
        }
    }

    /// The trailing `/ alpha` (modern form) or `, alpha` (handled by caller).
    fn alpha_str(&self, compressed: bool) -> String {
        match self.alpha {
            None => "none".to_string(),
            Some(a) => fmt_num(a, compressed),
        }
    }

    /// Serialize with dart's `_inspect` flag, which the legacy writer needs:
    /// inspect output shows an out-of-gamut color in its own space and tests a
    /// channel's integrality fuzzily, CSS output does neither.
    fn to_css_mode(&self, compressed: bool, inspect: bool) -> String {
        use ColorSpace::*;
        let sp = if compressed { "" } else { " " };
        // Legacy spaces with no missing channel use the comma legacy form.
        if self.space.is_legacy() && !self.has_missing() {
            return self.legacy_css(compressed, inspect);
        }
        // A lab/lch/oklab/oklch lightness outside [0, 100%] cannot round-trip
        // through the space's own function syntax (the CSS parser clamps it),
        // so dart-sass serializes the exact value via a `color-mix()` whose
        // first color is the unclamped xyz-d65 conversion. Only when no
        // channel is missing (a missing channel uses a different fallback,
        // relative color syntax, not exercised by the spec suite and left
        // as-is here). NaN lightness also fails the range check.
        if matches!(self.space, Lab | Lch | Oklab | Oklch) {
            if let (Some(l), Some(_), Some(_)) = (self.channels[0], self.channels[1], self.channels[2]) {
                let max = if matches!(self.space, Lab | Lch) {
                    100.0
                } else {
                    1.0
                };
                // dart fuzzy compare (epsilon 1e-11): in range iff above 0 and
                // below max, or fuzzy-EQUAL to a bound. NaN fails everything.
                let fuzzy_eq = |a: f64, b: f64| (a - b).abs() < 1e-11;
                let in_range = (l > 0.0 || fuzzy_eq(l, 0.0)) && (l < max || fuzzy_eq(l, max));
                if !in_range {
                    return self.out_of_range_css(compressed);
                }
            }
        }
        match self.space {
            Rgb | Hsl | Hwb => {
                // Legacy space with a missing channel: modern space-separated
                // form keeping the space's own name. rgb channels are plain;
                // hsl/hwb use hue+deg and percentages for the other two.
                let body = match self.space {
                    Hsl => format!(
                        "{} {} {}",
                        self.chan_hue(0, compressed),
                        self.pct_or_none(1, compressed),
                        self.pct_or_none(2, compressed),
                    ),
                    Hwb => format!(
                        "{} {} {}",
                        self.chan_hue(0, compressed),
                        self.pct_or_none(1, compressed),
                        self.pct_or_none(2, compressed),
                    ),
                    _ => format!(
                        "{} {} {}",
                        self.chan(0, compressed),
                        self.chan(1, compressed),
                        self.chan(2, compressed),
                    ),
                };
                self.wrap_modern(self.space.name(), &body, compressed)
            }
            Lab => {
                let body = format!(
                    "{} {} {}",
                    self.chan_pct(0, 100.0, compressed),
                    self.chan(1, compressed),
                    self.chan(2, compressed),
                );
                self.wrap_modern("lab", &body, compressed)
            }
            Lch => {
                let body = format!(
                    "{} {} {}",
                    self.chan_pct(0, 100.0, compressed),
                    self.chan(1, compressed),
                    self.chan_hue(2, compressed),
                );
                self.wrap_modern("lch", &body, compressed)
            }
            Oklab => {
                let body = format!(
                    "{} {} {}",
                    self.chan_pct(0, 1.0, compressed),
                    self.chan(1, compressed),
                    self.chan(2, compressed),
                );
                self.wrap_modern("oklab", &body, compressed)
            }
            Oklch => {
                let body = format!(
                    "{} {} {}",
                    self.chan_pct(0, 1.0, compressed),
                    self.chan(1, compressed),
                    self.chan_hue(2, compressed),
                );
                self.wrap_modern("oklch", &body, compressed)
            }
            // Predefined color() spaces. The space name and the three channels
            // are separated by MANDATORY whitespace — `color(display-p3 .5 .2
            // .9)` is one identifier followed by three numbers, so dropping
            // those spaces when compressed produced `color(display-p3.5.2.9)`,
            // which is not a color at all. Only the `/` before the alpha may
            // lose its spaces, so `sp` applies there and nowhere else.
            _ => {
                let space = self.space.name();
                let c0 = self.chan(0, compressed);
                let c1 = self.chan(1, compressed);
                let c2 = self.chan(2, compressed);
                if self.is_opaque() {
                    format!("color({space} {c0} {c1} {c2})")
                } else {
                    format!(
                        "color({space} {c0} {c1} {c2}{sp}/{sp}{})",
                        self.alpha_str(compressed)
                    )
                }
            }
        }
    }

    /// The `meta.inspect`/`@debug` serialization (dart `_writeLegacyColor`
    /// with `inspect: true`): an hwb color with no missing channels prints
    /// its own `hwb(H W% B%[ / A])` form (hue without `deg`), and an
    /// out-of-gamut legacy rgb skips the hsl reroute, falling to the
    /// `rgb(...)` comma form (named/hex only apply in-gamut) written with the
    /// same channel rules CSS output uses. Everything else serializes exactly
    /// like CSS output.
    pub(crate) fn inspect_css(&self) -> String {
        // dart writes an hwb color as `hwb()` in inspect output and through
        // its sRGB form in CSS output (`_writeLegacyColor`: the `_inspect &&
        // color.space == .hwb` branch comes before the format and hex rules).
        if matches!(self.space, ColorSpace::Hwb) && !self.has_missing() {
            let a = self.alpha.unwrap_or(0.0);
            let opaque = fuzzy_eq(a, 1.0);
            let h = fmt_num(self.channels[0].unwrap_or(0.0), false);
            let w = fmt_num(self.channels[1].unwrap_or(0.0), false);
            let b = fmt_num(self.channels[2].unwrap_or(0.0), false);
            return if opaque {
                format!("hwb({h} {w}% {b}%)")
            } else {
                format!("hwb({h} {w}% {b}% / {})", fmt_num(a, false))
            };
        }
        // Everything else — including an OUT-OF-GAMUT legacy rgb color, which
        // inspect output shows as `rgb()` rather than rerouting through hsl —
        // goes through the shared writer in inspect mode.
        self.to_css_mode(false, true)
    }

    /// Serialize an out-of-range lab/lch/oklab/oklch color as
    /// `color-mix(in <space>, color(xyz <x> <y> <z>[ / <alpha>]) 100%, black)`
    /// (dart-sass's fallback for a lightness the own-space syntax would clamp).
    /// Compressed form per dart: no space after commas or before `100%`, and
    /// the irrelevant base color is the shorter `red`:
    /// `color-mix(in lab,color(xyz x y z[/a])100%,red)`. A `none` alpha
    /// converts to `0` in this form.
    fn out_of_range_css(&self, compressed: bool) -> String {
        let xyz = crate::builtins::convert_modern(self, ColorSpace::XyzD65);
        let x = xyz.chan(0, compressed);
        let y = xyz.chan(1, compressed);
        let z = xyz.chan(2, compressed);
        let alpha = self.alpha.unwrap_or(0.0);
        let opaque = self.alpha.is_some() && fuzzy_eq(alpha, 1.0);
        let inner = if opaque {
            format!("color(xyz {x} {y} {z})")
        } else if compressed {
            format!("color(xyz {x} {y} {z}/{})", fmt_num(alpha, true))
        } else {
            format!("color(xyz {x} {y} {z} / {})", fmt_num(alpha, false))
        };
        let space = self.space.name();
        if compressed {
            format!("color-mix(in {space},{inner}100%,red)")
        } else {
            format!("color-mix(in {space}, {inner} 100%, black)")
        }
    }

    /// A non-hue percentage channel for the legacy modern form (saturation,
    /// lightness, whiteness, blackness).
    fn pct_or_none(&self, i: usize, compressed: bool) -> String {
        match self.channels[i] {
            None => "none".to_string(),
            Some(v) => format!("{}%", fmt_num(v, compressed)),
        }
    }

    /// Wrap a function-form modern color (`lab(...)`, `hsl(none ...)`) adding a
    /// `/ alpha` when not opaque.
    fn wrap_modern(&self, name: &str, body: &str, compressed: bool) -> String {
        let sp = if compressed { "" } else { " " };
        if self.is_opaque() && self.alpha.is_some() {
            format!("{name}({body})")
        } else {
            format!("{name}({body}{sp}/{sp}{})", self.alpha_str(compressed))
        }
    }

    /// Serialize a legacy color (rgb/hsl/hwb) with no missing channels in the
    /// classic comma form. rgb may collapse to hex; hwb routes through hsl.
    fn legacy_css(&self, compressed: bool, inspect: bool) -> String {
        let a = self.alpha.unwrap_or(1.0);
        // dart `_writeLegacyColor` opens with `fuzzyEquals(color.alpha, 1)`, so
        // an alpha 1e-13 short of 1 is opaque. `[measured]`:
        // `color.change(red, $alpha: 0.9999999999999)` is `red`, not
        // `rgba(255, 0, 0, 1)` — which is what a stricter test writes, alpha
        // and all.
        let opaque = crate::value::fuzzy_eq(a, 1.0);
        // dart `_writeLegacyColor` (serialize.dart:753) opens with this rule:
        // an out-of-gamut color is written as hsl(), the one legacy form a
        // browser does not clamp at parse time. INSPECT output skips the
        // reroute and shows the color in its own space.
        if !inspect && !self.is_in_gamut() {
            let (h, s, l) = self.legacy_hsl_triple();
            return self.hsl_comma_css(h, s, l, a, opaque, compressed);
        }
        match self.space {
            ColorSpace::Rgb => {
                let mut out = String::new();
                Color {
                    r: self.channels[0].unwrap_or(0.0),
                    g: self.channels[1].unwrap_or(0.0),
                    b: self.channels[2].unwrap_or(0.0),
                    a,
                    repr: None,
                    modern: None,
                }
                .write_css_mode(&mut out, compressed, inspect);
                out
            }
            ColorSpace::Hsl => {
                let (h, s, l) = self.legacy_hsl_triple();
                // Compressed output serializes through the rgb representation
                // (dart `_writeLegacyColor`, serialize.dart: `color.toSpace(.rgb)`
                // then hex/named, else the shorter of the rgb form and the hsl
                // form DERIVED from that rgb) — the stored hsl triple doesn't
                // participate, so a powerless authored hue collapses to the
                // round-trip's 0. The conversion is the engine's `hsl_to_srgb`,
                // dart's `HslColorSpace.convert` to the last bit, because the
                // rgb spelling turns on whether a channel is EXACTLY integral
                // and this conversion is where the dust that decides it comes
                // from.
                if compressed {
                    let srgb = crate::builtins::hsl_to_srgb([h, s, l]);
                    return Color::rgb(srgb[0] * 255.0, srgb[1] * 255.0, srgb[2] * 255.0, a).to_css(true);
                }
                self.hsl_comma_css(h, s, l, a, opaque, compressed)
            }
            ColorSpace::Hwb => {
                // hwb serializes through its sRGB representation: a hex-able
                // rgb becomes hex/named; otherwise the classic hsl comma form.
                let (rgb, h, s, l) = self.hwb_rgb_and_hsl();
                let shadow = Color::rgb(rgb[0], rgb[1], rgb[2], a);
                // Compressed hwb serializes through rgb like every legacy space
                // (dart `_writeLegacyColor`): hex/named/rgb()/derived-hsl,
                // whichever is shortest — rgba() included for a non-opaque
                // color.
                if compressed {
                    return shadow.to_css(true);
                }
                // Expanded: only a fully-OPAQUE hex-able hwb collapses to a
                // named color or hex; a non-opaque hwb uses the hsl comma form
                // (dart-sass never emits rgba() for an hwb color in expanded).
                if opaque && shadow.can_use_hex() {
                    if let Some(name) = rgb_name(rgb[0], rgb[1], rgb[2]) {
                        return name.to_string();
                    }
                    let mut out = String::new();
                    shadow.write_css_mode(&mut out, false, inspect);
                    return out;
                }
                self.hsl_comma_css(h, s, l, a, opaque, compressed)
            }
            _ => String::new(),
        }
    }

    /// dart `SassColor.isInGamut` (color.dart:201) for the legacy spaces: every
    /// LINEAR channel inside ITS OWN bounds, fuzzily; a polar hue is always in
    /// gamut.
    ///
    /// The bounds are the space's own, not sRGB's, and that is the whole point:
    /// `color.to-space(oklch(0.5 0.2 200), hsl)` carries a saturation of
    /// 6051.64% over an rgb conversion that is ordinary black, so testing the
    /// conversion calls it in gamut where dart calls it out. `[measured]`
    /// against dart-sass 1.104.1, compressed:
    /// `hsl(221.7487198664,266.6061126985%,0%)`, not `#000`.
    fn is_in_gamut(&self) -> bool {
        // dart `_isChannelInGamut`: `fuzzyGreaterThanOrEquals(v, min) &&
        // fuzzyLessThanOrEquals(v, max)`. A missing channel is in gamut, and
        // NaN fails both comparisons — which is how a color with an infinite
        // (or NaN) lightness keeps its hsl form in either style.
        let inside = |v: Option<f64>, max: f64| match v {
            None => true,
            Some(v) => (v > 0.0 || fuzzy_eq(v, 0.0)) && (v < max || fuzzy_eq(v, max)),
        };
        match self.space {
            ColorSpace::Rgb => {
                inside(self.channels[0], 255.0)
                    && inside(self.channels[1], 255.0)
                    && inside(self.channels[2], 255.0)
            }
            // hue is polar: only saturation/lightness and whiteness/blackness
            // are bounded, each to [0, 100].
            ColorSpace::Hsl | ColorSpace::Hwb => {
                inside(self.channels[1], 100.0) && inside(self.channels[2], 100.0)
            }
            // Only the legacy spaces reach the legacy writer.
            _ => true,
        }
    }

    /// Serialize the classic `hsl(h, s%, l%)` / `hsla(…)` comma form.
    fn hsl_comma_css(&self, h: f64, s: f64, l: f64, a: f64, opaque: bool, compressed: bool) -> String {
        // dart-sass normalizes a negative HSL saturation — which arises when an
        // out-of-range hwb color converts to hsl — by flipping the hue 180° and
        // taking the saturation's magnitude. A non-negative saturation (every
        // normal color) is untouched.
        let (h, s) = if s < 0.0 {
            ((h + 180.0).rem_euclid(360.0), -s)
        } else {
            (h, s)
        };
        // Writing this triple builds an hsl color, so dart-sass 1.104.0's
        // channel conversion applies: a NaN becomes 0. That is how an hwb color
        // with an infinite whiteness — which the hwb -> hsl conversion sends to
        // NaN — serializes as `hsl(0, 0%, 0%)`.
        let nan_zero = |v: f64| if v.is_nan() { 0.0 } else { v };
        let (h, s, l) = (nan_zero(h), nan_zero(s), nan_zero(l));
        // An INFINITE channel survives that conversion and serializes in its
        // calc form: `calc(infinity)` for the hue, `calc(infinity * 1%)` for a
        // percentage.
        let hh = if h.is_finite() {
            fmt_num(h, compressed)
        } else {
            Number::unitless(h).to_css(compressed)
        };
        let pct = |v: f64| {
            if v.is_finite() {
                format!("{}%", fmt_num(v, compressed))
            } else {
                Number::with_unit(v, "%").to_css(compressed)
            }
        };
        let ss = pct(s);
        let ll = pct(l);
        let comma = if compressed { "," } else { ", " };
        if opaque {
            format!("hsl({hh}{comma}{ss}{comma}{ll})")
        } else {
            let aa = fmt_num(a, compressed);
            format!("hsla({hh}{comma}{ss}{comma}{ll}{comma}{aa})")
        }
    }

    /// The sRGB-byte triple and the (hue, sat%, light%) for an hwb color,
    /// via the engine's exact dart conversions. A fuzzy-zero saturation makes
    /// the hue powerless; the legacy fill renders it as 0.
    fn hwb_rgb_and_hsl(&self) -> ([f64; 3], f64, f64, f64) {
        let hwb = [
            self.channels[0].unwrap_or(0.0),
            self.channels[1].unwrap_or(0.0),
            self.channels[2].unwrap_or(0.0),
        ];
        let rgb01 = crate::builtins::hwb_to_srgb(hwb);
        let hsl = crate::builtins::srgb_to_hsl(rgb01);
        let hue = if hsl[1].abs() < 1e-11 { 0.0 } else { hsl[0] };
        (
            [rgb01[0] * 255.0, rgb01[1] * 255.0, rgb01[2] * 255.0],
            hue,
            hsl[1],
            hsl[2],
        )
    }

    /// The (hue, saturation%, lightness%) triple a legacy color writes as
    /// `hsl()`. An hsl color writes its own channels (dart's `toSpace(.hsl)` is
    /// the identity, so a powerless hue survives); rgb and hwb convert through
    /// sRGB.
    fn legacy_hsl_triple(&self) -> (f64, f64, f64) {
        match self.space {
            ColorSpace::Hsl => (
                self.channels[0].unwrap_or(0.0),
                self.channels[1].unwrap_or(0.0),
                self.channels[2].unwrap_or(0.0),
            ),
            ColorSpace::Rgb => {
                let hsl = crate::builtins::srgb_to_hsl([
                    self.channels[0].unwrap_or(0.0) / 255.0,
                    self.channels[1].unwrap_or(0.0) / 255.0,
                    self.channels[2].unwrap_or(0.0) / 255.0,
                ]);
                // dart's srgb -> hsl conversion hands back a MISSING hue when
                // the saturation is fuzzy-zero, and a missing hue writes as 0,
                // so an out-of-gamut gray must not leak a phantom hue.
                // `[measured]` against dart-sass 1.104.1:
                // `color.to-space(color(srgb 2 0 0.5), rgb)` is
                // `hsl(0, 0%, 100%)`, not `hsl(345, 0%, 100%)`.
                let hue = if hsl[1].abs() < 1e-11 { 0.0 } else { hsl[0] };
                (hue, hsl[1], hsl[2])
            }
            ColorSpace::Hwb => {
                // Share the hwb->hsl conversion (and its achromatic-hue
                // canonicalization) with hwb_rgb_and_hsl.
                let (_, h, s, l) = self.hwb_rgb_and_hsl();
                (h, s, l)
            }
            _ => (0.0, 0.0, 0.0),
        }
    }
}

/// Write the three `rgb()` channel spellings dart-sass uses, separated by `sep`.
///
/// dart switches the WHOLE triple to percentages as soon as ANY channel is
/// non-integral: `mix(red, blue)` is `rgb(50%, 0%, 50%)`, not
/// `rgb(127.5, 0, 127.5)`. An all-integer triple keeps plain numbers
/// (`rgb(1, 2, 3)`).
///
/// Integrality is EXACT for CSS output and FUZZY for `meta.inspect` (dart
/// `_asInt`, serialize.dart:1202: `_inspect ? fuzzyAsInt(number) : (rounded ==
/// number ? rounded : null)` — note dart's own doc comment there describes the
/// opposite of what the code does). The same color therefore has two
/// spellings, and the dust an hsl conversion leaves behind is what separates
/// them: `[measured]` against dart-sass 1.104.1,
/// `color.to-space(hsl(180, 60%, 50%, 0.4), rgb)` has channels
/// (50.999999999999986, 203.99999999999997, 204), writes as
/// `rgba(20%, 80%, 80%, 0.4)` and inspects as `rgba(51, 204, 204, 0.4)`.
fn push_rgb_channels(out: &mut String, r: f64, g: f64, b: f64, compressed: bool, sep: &str, inspect: bool) {
    // dart `_tryIntegerRgbChannels` -> `_asInt`: a non-integral channel sends
    // the WHOLE triple to percentages (serialize.dart:869-886). Integrality
    // alone decides it — there is no gamut bound, which only the INSPECT form
    // can observe, since CSS output writes an out-of-gamut legacy rgb through
    // its hsl spelling instead. `[measured]` against dart-sass 1.104.1:
    // `meta.inspect(color.to-space(color(srgb 2 0 0), rgb))` — channels
    // (510, 0, 0) — is `rgb(510, 0, 0)`, while `color(srgb 2 0 0.5)` —
    // (510, 0, 127.5) — is `rgb(200%, 0%, 50%)`. A non-finite channel is never
    // an integer, so it always takes the percentage branch below.
    let as_int = |v: f64| {
        if inspect {
            fuzzy_is_int(v)
        } else {
            v.is_finite() && v == v.round()
        }
    };
    let ints = as_int(r) && as_int(g) && as_int(b);
    for (i, v) in [r, g, b].into_iter().enumerate() {
        if i > 0 {
            out.push_str(sep);
        }
        if ints {
            push_num(out, v, compressed);
        } else if !v.is_finite() {
            // A non-finite channel — which converting an infinite one produces
            // — is written as a `%`-unit `calc()` constant, `calc(NaN * 1%)`,
            // exactly as `ModernColor::chan_pct` writes one. `as_int` already
            // rejected it, so this IS the percentage branch; scaling a
            // non-finite number would change nothing.
            out.push_str(&Number::with_unit(v, "%").to_css(compressed));
        } else {
            // `v * 100 / 255`, in dart's operand order — `v / 255.0 * 100.0`
            // differs in the last bit.
            push_num(out, v * 100.0 / 255.0, compressed);
            out.push('%');
        }
    }
}

/// Write a number the way dart-sass does — round to 10 decimal places, trim
/// trailing zeros, and (when compressed) drop a leading `0` — into `out`.
///
/// This is the primitive; [`fmt_num`] wraps it for callers that want a string
/// of their own. Every spelling a stylesheet actually writes is generated
/// straight into `out`, so serializing a dimension into a declaration's value
/// allocates nothing at all. The rounding and the leading-zero trim work on
/// the tail of `out`: the spelling is the last thing in the buffer, so
/// truncating or inserting only ever moves bytes this call just wrote.
pub(crate) fn push_num(out: &mut String, n: f64, compressed: bool) {
    if n.is_nan() {
        out.push_str("NaN");
        return;
    }
    if n.is_infinite() {
        out.push_str(if n > 0.0 { "Infinity" } else { "-Infinity" });
        return;
    }
    // A NEGATIVE ZERO keeps its sign (dart-sass 1.104.0, "for greater
    // compatibility when using it in CSS calculations"). This is the IEEE sign
    // bit, not the printed text: `0 * -1` and `-0 + -0` are negative zeros and
    // print `-0`, while `0 - 0`, `0 + -0` and `-0 * -1` are POSITIVE zeros and
    // print `0`. A tiny negative that merely ROUNDS to zero is not a zero at
    // all and prints `0` too — that one is handled further down.
    if n == 0.0 {
        out.push_str(if n.is_sign_negative() { "-0" } else { "0" });
        return;
    }
    let start = out.len();
    // Integers print the way the dart VM does: `fuzzyAsInt` converts the
    // double to a NATIVE int64 (saturating, exactly like Rust's `as i64`)
    // and prints its exact decimal expansion — `593644542057412224`, not the
    // shortest-roundtrip `…200`. A magnitude past int64 fails the round-trip
    // check (saturation changes the value) and falls back to the shortest
    // form, which never overflows into exponential notation.
    if n.fract() == 0.0 {
        let i = n as i64;
        if i as f64 == n {
            push_i64(out, i);
        } else {
            // Integer-valued but past i64: Ryū prints the shortest form in
            // plain positional notation, exactly like Display.
            crate::ryu::format64(n, out);
        }
        // An integer's spelling has no fraction to round, cannot be `-0` (a
        // true zero returned above) and cannot start `0.`, so both of the
        // fix-ups below are dead on this path.
        return;
    }
    // dart `_writeNumber`: serialize the SHORTEST round-trip decimal
    // (`double.toString()` + exponent removal), then round it AT THE
    // STRING LEVEL to 10 decimal places, looking only at the 11th digit
    // (half-up). This follows the shortest spelling, not the true value:
    // `2154.15598416745` (true value …44978) still rounds UP to
    // `…1675` because its shortest form ends in a literal `5`.
    push_ecma_shortest(out, n);
    // Which of dart's two writers handles this spelling. `_writeNumber` emits
    // anything shorter than `precision + 2` = 12 characters (sign included)
    // directly, because `0.` plus ten digits cannot overflow the precision;
    // everything longer goes to `_writeRounded`. The two disagree about the
    // leading zero when compressed, so the choice has to be made on the
    // UNROUNDED spelling, before `round_decimal_in_place` shortens it.
    let direct = out.len() - start < 12;
    let rounded = round_decimal_in_place(out, start);
    // A tiny negative ROUNDS to `-0` at the string level; dart prints `0` for
    // it. A true negative zero never reaches here — it returned above.
    if &out[start..] == "-0" {
        out.truncate(start);
        out.push('0');
    }
    // Compressed style drops the leading zero of a fraction, and which
    // fractions lose it depends on the writer — `[measured]` against dart-sass
    // 1.104.1 over `0.1` … `0.1234567891234` and their negations:
    //
    //   * the direct writer tests the rendered string for a literal `0.`
    //     prefix, which a minus sign has already pushed out of the way, so
    //     `0.5` loses its zero and `-0.5` keeps it;
    //   * `_writeRounded` only reaches the digit-by-digit path when it
    //     actually has digits to drop, and there it omits the integer `0` for
    //     either sign: `-0.00123456789` compresses to `-.0012345679`;
    //   * a long spelling that needs no rounding passes through verbatim, so
    //     it keeps the zero even when positive: `0.0123456789` stays as it is,
    //     one character longer than it has to be.
    if compressed {
        if direct {
            if out[start..].starts_with("0.") {
                out.remove(start);
            }
        } else if rounded {
            let zero_at = start + usize::from(out.as_bytes()[start] == b'-');
            if out[zero_at..].starts_with("0.") {
                out.remove(zero_at);
            }
        }
    }
}

/// [`push_num`] into a string of its own, for the callers that want one.
pub(crate) fn fmt_num(n: f64, compressed: bool) -> String {
    let mut s = String::new();
    push_num(&mut s, n, compressed);
    s
}

/// Append an `i64`'s decimal spelling without the `core::fmt` machinery.
/// Numbers are the hottest serialization path (every dimension in every
/// declaration), and `format!("{i}")` spends most of its time in `Formatter`
/// dispatch, not in digit generation. Output is byte-identical to `i64`'s
/// `Display`.
fn push_i64(out: &mut String, v: i64) {
    // Longest spelling: "-9223372036854775808" = 20 bytes.
    let mut buf = [0u8; 20];
    let neg = v < 0;
    let mut u = v.unsigned_abs();
    let mut at = buf.len();
    loop {
        at -= 1;
        buf[at] = b'0' + (u % 10) as u8;
        u /= 10;
        if u == 0 {
            break;
        }
    }
    if neg {
        at -= 1;
        buf[at] = b'-';
    }
    // The buffer holds only ASCII digits and '-'.
    out.push_str(std::str::from_utf8(&buf[at..]).expect("ascii"));
}

/// Append dart `double.toString()` (ECMA-262 Number::toString): the shortest
/// decimal that round-trips, breaking a tie between two equidistant
/// spellings by choosing the EVEN final digit. Rust's `{}` is also shortest
/// but ties differently (`657390374199289.25` prints `…289.3`, dart prints
/// `…289.2`), so re-round to the same significant-digit count through
/// `{:e}`'s half-to-even rounding and expand the exponent form.
fn push_ecma_shortest(out: &mut String, n: f64) {
    let start = out.len();
    // The zero-dep Ryū port: byte-identical to `format!("{n}")` (proven by
    // its differential fuzz) without the core::fmt machinery, writing into
    // the caller's buffer.
    crate::ryu::format64(n, out);
    let rust = &out[start..];
    // Count significant digits (skipping sign, dot, and leading zeros).
    let sig = rust
        .chars()
        .filter(|c| c.is_ascii_digit())
        .skip_while(|&c| c == '0')
        .count();
    if sig == 0 {
        return;
    }
    if !rust.contains('e') && n.abs() >= f64::MIN_POSITIVE {
        // A tie between two equidistant shortest spellings requires the
        // spacing of sig-digit decimals (relative, at least 10^-sig) to fit
        // inside the value's one-ulp round-trip window (relative at most
        // 2^-52 for normal doubles), which forces sig >= 16. At 15 or fewer
        // significant digits the shortest round-trip spelling is unique, so
        // Rust's `{}` already IS ECMA toString — skip the re-round and its
        // two parses. Subnormals (wider relative ulps) and exponent-form
        // spellings take the slow path.
        if sig <= 15 {
            return;
        }
        // A tie can only flip the FINAL digit of the spelling: the two
        // candidates are same-length decimals one apart in the last place,
        // and a carry would end the higher one in `0` — a trailing zero
        // means a shorter spelling round-trips, contradicting shortest-form.
        // The caller rounds at the 10th fractional digit reading only the
        // 11th, so a final digit deeper than the 11th fractional place never
        // reaches the output and the tie-break is moot.
        if let Some(dot) = rust.find('.') {
            if rust.len() - dot - 1 > 11 {
                return;
            }
        }
    }
    // The slow path is the only one that allocates, and it is reached by a
    // spelling of 16 significant digits or more — never by a hand-written
    // dimension, only by arithmetic that lands on one.
    let sci = format!("{:.*e}", sig - 1, n);
    if sci.parse::<f64>() != Ok(n) {
        return;
    }
    let expanded = expand_exponent(&sci);
    if expanded.parse::<f64>() == Ok(n) {
        out.truncate(start);
        out.push_str(&expanded);
    }
}

/// Expand `D.DDDDeK` scientific notation into a plain decimal string (dart
/// `_removeExponent`).
fn expand_exponent(sci: &str) -> String {
    let Some(epos) = sci.find('e') else {
        return sci.to_string();
    };
    let exp: i32 = sci[epos + 1..].parse().unwrap_or(0);
    let mantissa = &sci[..epos];
    let neg = mantissa.starts_with('-');
    let digits: String = mantissa.chars().filter(|c| c.is_ascii_digit()).collect();
    let sign = if neg { "-" } else { "" };
    // One digit sits before the dot in `{:e}` form, so the decimal point in
    // the digit string belongs after position `exp + 1`.
    let point = exp + 1;
    if point <= 0 {
        let zeros = "0".repeat((-point) as usize);
        format!("{sign}0.{zeros}{digits}")
    } else if (point as usize) >= digits.len() {
        let zeros = "0".repeat(point as usize - digits.len());
        format!("{sign}{digits}{zeros}")
    } else {
        format!(
            "{sign}{}.{}",
            &digits[..point as usize],
            &digits[point as usize..]
        )
    }
}

/// dart `_writeRounded`, in place: round the plain decimal spelling that
/// starts at `start` to 10 fractional digits by inspecting ONLY the 11th
/// digit (>= '5' carries up), then trim trailing fractional zeros. Ten or
/// fewer fractional digits pass verbatim.
///
/// Returns whether any digit was actually dropped, which is what decides
/// whether compressed output loses the leading zero of a negative fraction
/// (see [`push_num`]).
fn round_decimal_in_place(out: &mut String, start: usize) -> bool {
    let Some(dot) = out[start..].find('.').map(|i| start + i) else {
        return false;
    };
    let mut dropped = false;
    if out.len() - dot - 1 > 10 {
        let round_up = out.as_bytes()[dot + 11] >= b'5';
        out.truncate(dot + 11);
        if round_up {
            carry_one(out, start);
        }
        dropped = true;
    }
    trim_fraction_in_place(out, start);
    dropped
}

/// Add one to the last digit of the decimal spelling at `start..`, carrying
/// leftwards: `1.29` -> `1.30`, `9.99` -> `10.00`, `-9.9` -> `-10.0`.
fn carry_one(out: &mut String, start: usize) {
    // Walk back over the digits a carry turns into zeros — the trailing `9`s
    // and the decimal point between them — stopping on the byte that absorbs
    // it: a digit below `9`, the sign, or the start of the spelling.
    let mut i = out.len();
    while i > start && matches!(out.as_bytes()[i - 1], b'9' | b'.') {
        i -= 1;
    }
    // Everything from `i` on is `9`s with at most one `.` among them, and it
    // is the tail of the buffer, so the carry is one truncate and one push
    // instead of a byte edited in the middle of a string.
    let width = out.len() - i;
    let dot = out[i..].find('.');
    let (cut, lead) = match (i > start).then(|| out.as_bytes()[i - 1]) {
        Some(d) if d.is_ascii_digit() => (i - 1, (d + 1) as char),
        // Nothing left to absorb the carry — the spelling was all `9`s, or the
        // only thing before them is the sign — so it grows a leading `1`.
        _ => (i, '1'),
    };
    out.truncate(cut);
    out.push(lead);
    for k in 0..width {
        out.push(if dot == Some(k) { '.' } else { '0' });
    }
}

/// Trim trailing fractional zeros (and a then-trailing dot) from the spelling
/// at `start..`; `-0` and all-zero results collapse to `0` at the caller.
fn trim_fraction_in_place(out: &mut String, start: usize) {
    let text = &out[start..];
    if !text.contains('.') {
        return;
    }
    let kept = text.trim_end_matches('0').trim_end_matches('.').len();
    out.truncate(start + kept);
}

/// Look up a CSS named color. Covers the complete set of 148 CSS Color 4
/// named colors plus `transparent`; unknown identifiers stay unquoted strings.
pub(crate) fn named_color(name: &str) -> Option<Color> {
    let (r, g, b, a) = match name.to_ascii_lowercase().as_str() {
        "transparent" => (0, 0, 0, 0.0),
        "aliceblue" => (240, 248, 255, 1.0),
        "antiquewhite" => (250, 235, 215, 1.0),
        "aqua" | "cyan" => (0, 255, 255, 1.0),
        "aquamarine" => (127, 255, 212, 1.0),
        "azure" => (240, 255, 255, 1.0),
        "beige" => (245, 245, 220, 1.0),
        "bisque" => (255, 228, 196, 1.0),
        "black" => (0, 0, 0, 1.0),
        "blanchedalmond" => (255, 235, 205, 1.0),
        "blue" => (0, 0, 255, 1.0),
        "blueviolet" => (138, 43, 226, 1.0),
        "brown" => (165, 42, 42, 1.0),
        "burlywood" => (222, 184, 135, 1.0),
        "cadetblue" => (95, 158, 160, 1.0),
        "chartreuse" => (127, 255, 0, 1.0),
        "chocolate" => (210, 105, 30, 1.0),
        "coral" => (255, 127, 80, 1.0),
        "cornflowerblue" => (100, 149, 237, 1.0),
        "cornsilk" => (255, 248, 220, 1.0),
        "crimson" => (220, 20, 60, 1.0),
        "darkblue" => (0, 0, 139, 1.0),
        "darkcyan" => (0, 139, 139, 1.0),
        "darkgoldenrod" => (184, 134, 11, 1.0),
        "darkgray" | "darkgrey" => (169, 169, 169, 1.0),
        "darkgreen" => (0, 100, 0, 1.0),
        "darkkhaki" => (189, 183, 107, 1.0),
        "darkmagenta" => (139, 0, 139, 1.0),
        "darkolivegreen" => (85, 107, 47, 1.0),
        "darkorange" => (255, 140, 0, 1.0),
        "darkorchid" => (153, 50, 204, 1.0),
        "darkred" => (139, 0, 0, 1.0),
        "darksalmon" => (233, 150, 122, 1.0),
        "darkseagreen" => (143, 188, 143, 1.0),
        "darkslateblue" => (72, 61, 139, 1.0),
        "darkslategray" | "darkslategrey" => (47, 79, 79, 1.0),
        "darkturquoise" => (0, 206, 209, 1.0),
        "darkviolet" => (148, 0, 211, 1.0),
        "deeppink" => (255, 20, 147, 1.0),
        "deepskyblue" => (0, 191, 255, 1.0),
        "dimgray" | "dimgrey" => (105, 105, 105, 1.0),
        "dodgerblue" => (30, 144, 255, 1.0),
        "firebrick" => (178, 34, 34, 1.0),
        "floralwhite" => (255, 250, 240, 1.0),
        "forestgreen" => (34, 139, 34, 1.0),
        "fuchsia" | "magenta" => (255, 0, 255, 1.0),
        "gainsboro" => (220, 220, 220, 1.0),
        "ghostwhite" => (248, 248, 255, 1.0),
        "gold" => (255, 215, 0, 1.0),
        "goldenrod" => (218, 165, 32, 1.0),
        "gray" | "grey" => (128, 128, 128, 1.0),
        "green" => (0, 128, 0, 1.0),
        "greenyellow" => (173, 255, 47, 1.0),
        "honeydew" => (240, 255, 240, 1.0),
        "hotpink" => (255, 105, 180, 1.0),
        "indianred" => (205, 92, 92, 1.0),
        "indigo" => (75, 0, 130, 1.0),
        "ivory" => (255, 255, 240, 1.0),
        "khaki" => (240, 230, 140, 1.0),
        "lavender" => (230, 230, 250, 1.0),
        "lavenderblush" => (255, 240, 245, 1.0),
        "lawngreen" => (124, 252, 0, 1.0),
        "lemonchiffon" => (255, 250, 205, 1.0),
        "lightblue" => (173, 216, 230, 1.0),
        "lightcoral" => (240, 128, 128, 1.0),
        "lightcyan" => (224, 255, 255, 1.0),
        "lightgoldenrodyellow" => (250, 250, 210, 1.0),
        "lightgray" | "lightgrey" => (211, 211, 211, 1.0),
        "lightgreen" => (144, 238, 144, 1.0),
        "lightpink" => (255, 182, 193, 1.0),
        "lightsalmon" => (255, 160, 122, 1.0),
        "lightseagreen" => (32, 178, 170, 1.0),
        "lightskyblue" => (135, 206, 250, 1.0),
        "lightslategray" | "lightslategrey" => (119, 136, 153, 1.0),
        "lightsteelblue" => (176, 196, 222, 1.0),
        "lightyellow" => (255, 255, 224, 1.0),
        "lime" => (0, 255, 0, 1.0),
        "limegreen" => (50, 205, 50, 1.0),
        "linen" => (250, 240, 230, 1.0),
        "maroon" => (128, 0, 0, 1.0),
        "mediumaquamarine" => (102, 205, 170, 1.0),
        "mediumblue" => (0, 0, 205, 1.0),
        "mediumorchid" => (186, 85, 211, 1.0),
        "mediumpurple" => (147, 112, 219, 1.0),
        "mediumseagreen" => (60, 179, 113, 1.0),
        "mediumslateblue" => (123, 104, 238, 1.0),
        "mediumspringgreen" => (0, 250, 154, 1.0),
        "mediumturquoise" => (72, 209, 204, 1.0),
        "mediumvioletred" => (199, 21, 133, 1.0),
        "midnightblue" => (25, 25, 112, 1.0),
        "mintcream" => (245, 255, 250, 1.0),
        "mistyrose" => (255, 228, 225, 1.0),
        "moccasin" => (255, 228, 181, 1.0),
        "navajowhite" => (255, 222, 173, 1.0),
        "navy" => (0, 0, 128, 1.0),
        "oldlace" => (253, 245, 230, 1.0),
        "olive" => (128, 128, 0, 1.0),
        "olivedrab" => (107, 142, 35, 1.0),
        "orange" => (255, 165, 0, 1.0),
        "orangered" => (255, 69, 0, 1.0),
        "orchid" => (218, 112, 214, 1.0),
        "palegoldenrod" => (238, 232, 170, 1.0),
        "palegreen" => (152, 251, 152, 1.0),
        "paleturquoise" => (175, 238, 238, 1.0),
        "palevioletred" => (219, 112, 147, 1.0),
        "papayawhip" => (255, 239, 213, 1.0),
        "peachpuff" => (255, 218, 185, 1.0),
        "peru" => (205, 133, 63, 1.0),
        "pink" => (255, 192, 203, 1.0),
        "plum" => (221, 160, 221, 1.0),
        "powderblue" => (176, 224, 230, 1.0),
        "purple" => (128, 0, 128, 1.0),
        "rebeccapurple" => (102, 51, 153, 1.0),
        "red" => (255, 0, 0, 1.0),
        "rosybrown" => (188, 143, 143, 1.0),
        "royalblue" => (65, 105, 225, 1.0),
        "saddlebrown" => (139, 69, 19, 1.0),
        "salmon" => (250, 128, 114, 1.0),
        "sandybrown" => (244, 164, 96, 1.0),
        "seagreen" => (46, 139, 87, 1.0),
        "seashell" => (255, 245, 238, 1.0),
        "sienna" => (160, 82, 45, 1.0),
        "silver" => (192, 192, 192, 1.0),
        "skyblue" => (135, 206, 235, 1.0),
        "slateblue" => (106, 90, 205, 1.0),
        "slategray" | "slategrey" => (112, 128, 144, 1.0),
        "snow" => (255, 250, 250, 1.0),
        "springgreen" => (0, 255, 127, 1.0),
        "steelblue" => (70, 130, 180, 1.0),
        "tan" => (210, 180, 140, 1.0),
        "teal" => (0, 128, 128, 1.0),
        "thistle" => (216, 191, 216, 1.0),
        "tomato" => (255, 99, 71, 1.0),
        "turquoise" => (64, 224, 208, 1.0),
        "violet" => (238, 130, 238, 1.0),
        "wheat" => (245, 222, 179, 1.0),
        "white" => (255, 255, 255, 1.0),
        "whitesmoke" => (245, 245, 245, 1.0),
        "yellow" => (255, 255, 0, 1.0),
        "yellowgreen" => (154, 205, 50, 1.0),
        _ => return None,
    };
    Some(Color {
        r: r as f64,
        g: g as f64,
        b: b as f64,
        a,
        repr: Some(name.into()),
        modern: None,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fmt_num_trims_and_rounds() {
        assert_eq!(fmt_num(153.0, false), "153");
        assert_eq!(fmt_num(178.5, false), "178.5");
        assert_eq!(fmt_num(0.5, false), "0.5");
        // A NEGATIVE ZERO keeps its sign from dart-sass 1.104.0 on; a tiny
        // negative that merely rounds to zero does not.
        assert_eq!(fmt_num(-0.0, false), "-0");
        assert_eq!(fmt_num(0.0, false), "0");
        assert_eq!(fmt_num(-0.00000000001, false), "0");
        assert_eq!(fmt_num(16.0, false), "16");
    }

    #[test]
    fn fmt_num_large_values_stay_plain_decimals() {
        // Exact integers print in full, never exponential.
        assert_eq!(fmt_num(123456789012345.0, false), "123456789012345");
        assert_eq!(fmt_num(-123456789012345.0, false), "-123456789012345");
        assert_eq!(fmt_num(1e20, false), "100000000000000000000");
        // Within int64, the exact decimal expansion (dart VM int printing).
        assert_eq!(fmt_num(1234567890123456789.0, false), "1234567890123456768");
        assert_eq!(fmt_num(593644542057412224.0, false), "593644542057412224");
        // 2^63 saturates to int64 max and still round-trips (dart VM).
        assert_eq!(fmt_num(9223372036854775808.0, false), "9223372036854775807");
        // Beyond int64 the shortest round-tripping form matches dart-sass.
        assert_eq!(fmt_num(92233720368547758070.0, false), "92233720368547760000");
        assert_eq!(
            fmt_num(99999999999999999999999999999.0, false),
            "100000000000000000000000000000"
        );
    }

    #[test]
    fn fmt_num_rounds_fractions_to_ten_places() {
        assert_eq!(fmt_num(0.1 + 0.2, false), "0.3");
        assert_eq!(fmt_num(1.0 / 3.0, false), "0.3333333333");
        assert_eq!(fmt_num(2.0 / 3.0, false), "0.6666666667");
        assert_eq!(fmt_num(123456.78901234567, false), "123456.7890123457");
        // Below the tenth decimal place rounds away entirely.
        assert_eq!(fmt_num(1e-11, false), "0");
        // Halfway digits round away from zero (dart-sass), not to even.
        assert_eq!(fmt_num(0.00000000015, false), "0.0000000002");
        assert_eq!(fmt_num(0.00000000035, false), "0.0000000004");
        assert_eq!(fmt_num(0.99999999995, false), "1");
        assert_eq!(fmt_num(0.30000000005, false), "0.3000000001");
    }

    #[test]
    fn fmt_num_compressed_drops_leading_zero() {
        assert_eq!(fmt_num(0.5, true), ".5");
        // A NEGATIVE number keeps its zero: dart looks for a literal `0.`
        // prefix, which the minus sign has pushed out of the way (verified
        // against dart-sass 1.103.1, 2026-09-15).
        assert_eq!(fmt_num(-0.25, true), "-0.25");
        assert_eq!(fmt_num(2.0, true), "2");
    }

    #[test]
    fn fmt_num_compressed_leading_zero_follows_the_writer() {
        // Which fractions lose the leading zero depends on which of dart's two
        // number writers renders them, so the rule has three regimes rather
        // than one. Every expectation here was measured against dart-sass
        // 1.104.1 on 2026-09-19, sweeping `0.1` … `0.1234567891234` and their
        // negations.
        //
        // 1. Shorter than `precision + 2` = 12 characters, sign included: the
        //    direct writer, which tests for a literal `0.` prefix.
        assert_eq!(fmt_num(0.123456789, true), ".123456789");
        assert_eq!(fmt_num(-0.123456789, true), "-0.123456789");
        // 2. Long enough for `_writeRounded`, but with nothing to round away:
        //    the spelling passes through verbatim and keeps its zero even when
        //    positive, one character longer than it needs to be.
        assert_eq!(fmt_num(0.1234567891, true), "0.1234567891");
        assert_eq!(fmt_num(-0.1234567891, true), "-0.1234567891");
        assert_eq!(fmt_num(0.0123456789, true), "0.0123456789");
        assert_eq!(fmt_num(0.0000000001, true), "0.0000000001");
        // 3. `_writeRounded` with digits to drop: the integer `0` goes for
        //    EITHER sign.
        assert_eq!(fmt_num(0.12345678912, true), ".1234567891");
        assert_eq!(fmt_num(-0.12345678912, true), "-.1234567891");
        assert_eq!(fmt_num(-0.00123456789, true), "-.0012345679");
        assert_eq!(fmt_num(0.00000000005, true), ".0000000001");
        // A carry out of the fraction removes the leading zero the other way;
        // a tiny negative that rounds to zero is still `0`, never `-.0`.
        assert_eq!(fmt_num(-0.99999999995, true), "-1");
        assert_eq!(fmt_num(-1e-11, true), "0");
        // Expanded output keeps every leading zero in all three regimes.
        assert_eq!(fmt_num(0.123456789, false), "0.123456789");
        assert_eq!(fmt_num(0.12345678912, false), "0.1234567891");
        assert_eq!(fmt_num(-0.12345678912, false), "-0.1234567891");
    }

    #[test]
    fn push_num_writes_at_an_offset() {
        // `push_num` rounds, carries, strips a leading zero and rewrites `-0`
        // by mutating the bytes it just wrote, addressed from `out.len()` at
        // entry. Every one of those fix-ups must therefore be blind to what is
        // already in the buffer: a number appended after a prefix must render
        // exactly as it does into an empty string, and must leave the prefix
        // untouched — including a multibyte one, where a byte-indexed
        // `truncate`/`remove` would panic if the offset arithmetic slipped.
        let cases = [
            153.0,
            178.5,
            -0.0,
            -0.25,
            0.5,
            1.0 / 3.0,
            // Rounding that carries through every digit, with and without a
            // digit to increment on the left of the dot.
            0.99999999995,
            9.99999999995,
            0.30000000005,
            1e-11,
            // Exponent removal, at both ends of the range.
            1e-7,
            1e20,
            1.5e300,
            // A shortest form whose literal last digit drives the rounding.
            2154.15598416745,
        ];
        for prefix in ["", "margin:", "邊界：", "🎨 "] {
            for compressed in [false, true] {
                for n in cases {
                    let mut out = String::from(prefix);
                    push_num(&mut out, n, compressed);
                    assert_eq!(
                        &out[..prefix.len()],
                        prefix,
                        "prefix {prefix:?} clobbered writing {n} (compressed {compressed})"
                    );
                    assert_eq!(
                        &out[prefix.len()..],
                        fmt_num(n, compressed),
                        "{n} rendered differently after {prefix:?} (compressed {compressed})"
                    );
                }
            }
        }
    }

    fn num(value: f64, unit: &str) -> CalcNode {
        CalcNode::Number(Number::with_unit(value, unit))
    }

    #[test]
    fn calc_serialization_drops_redundant_parens() {
        // `1px + 2% * var(--c)`: `*` binds tighter, so no parens are needed.
        let node = CalcNode::Op {
            op: CalcOp::Add,
            left: Box::new(num(1.0, "px")),
            right: Box::new(CalcNode::Op {
                op: CalcOp::Mul,
                left: Box::new(num(2.0, "%")),
                right: Box::new(CalcNode::Str("var(--c)".into())),
            }),
        };
        assert_eq!(Value::Calc(node).to_css(false), "calc(1px + 2% * var(--c))");
    }

    #[test]
    fn calc_serialization_keeps_required_parens_and_flips_sign() {
        // `1px - (2% + var(--c))`: subtracting a sum needs parens.
        let node = CalcNode::Op {
            op: CalcOp::Sub,
            left: Box::new(num(1.0, "px")),
            right: Box::new(CalcNode::Op {
                op: CalcOp::Add,
                left: Box::new(num(2.0, "%")),
                right: Box::new(CalcNode::Str("var(--c)".into())),
            }),
        };
        assert_eq!(Value::Calc(node).to_css(false), "calc(1px - (2% + var(--c)))");
        // `1% + -1px` serializes as `1% - 1px`.
        let flip = CalcNode::Op {
            op: CalcOp::Add,
            left: Box::new(num(1.0, "%")),
            right: Box::new(num(-1.0, "px")),
        };
        assert_eq!(Value::Calc(flip).to_css(false), "calc(1% - 1px)");
    }

    #[test]
    fn hex_parsing_and_serialization() {
        // dart-sass preserves the authored spelling of opaque 3-/6-digit hex.
        let c = Color::from_hex("336699").expect("valid hex");
        assert_eq!(c.to_css(false), "#336699");
        let short = Color::from_hex("369").expect("valid hex");
        assert_eq!(short.to_css(false), "#369");
        // Uppercase and mixed case round-trip verbatim.
        let upper = Color::from_hex("FFAA00").expect("valid hex");
        assert_eq!(upper.to_css(false), "#FFAA00");
        let upper_short = Color::from_hex("ABC").expect("valid hex");
        assert_eq!(upper_short.to_css(false), "#ABC");
        // Compressed mode ignores the authored form and shortens.
        assert_eq!(upper.to_css(true), "#fa0");
        // 4-/8-digit alpha forms are canonicalized, not preserved. An opaque
        // one collapses to lowercase 6-digit hex; partial alpha -> rgba().
        let opaque4 = Color::from_hex("369f").expect("valid hex");
        assert_eq!(opaque4.to_css(false), "#336699");
        let partial = Color::from_hex("33669980").expect("valid hex");
        assert!(partial.to_css(false).starts_with("rgba("));
    }

    #[test]
    fn an_authored_spelling_is_built_once_and_then_shared() {
        // `hex_repr` assembles `#` + digits in a stack buffer instead of a
        // `format!`, addressed from a fixed offset, so every legal literal
        // length has to come out byte-identical to the formatted spelling —
        // including the ones with alpha digits, where a slipped offset would
        // truncate or over-copy.
        for digits in [
            "fff", "FFF", "abc", "0f0", "ffff", "369f", "336699", "FFAA00", "33669980",
        ] {
            assert_eq!(&*hex_repr(digits.as_bytes()), format!("#{digits}"), "{digits}");
        }
        // The 4-/8-digit forms are canonicalized rather than preserved, still
        // lowercase and two digits per channel.
        assert_eq!(
            Color::from_hex("369f").expect("valid hex").repr.as_deref(),
            Some("#336699")
        );
        assert_eq!(
            Color::from_hex("ABCF").expect("valid hex").repr.as_deref(),
            Some("#aabbcc")
        );
        // A partial-alpha literal has no authored spelling to keep.
        assert!(Color::from_hex("33669980").expect("valid hex").repr.is_none());
        // Cloning a literal — what evaluation does on every read of it — must
        // share that one spelling, not copy the bytes into a new allocation.
        let literal = Color::from_hex("336699").expect("valid hex");
        let read = literal.clone();
        assert_eq!(read.to_css(false), "#336699");
        let (a, b) = (literal.repr.expect("kept"), read.repr.expect("kept"));
        assert!(
            Rc::ptr_eq(&a, &b),
            "the clone copied the spelling instead of sharing it"
        );
        // A named literal shares the same way.
        let named = named_color("rebeccapurple").expect("named");
        let copy = named.clone();
        assert!(Rc::ptr_eq(&named.repr.expect("kept"), &copy.repr.expect("kept")));
    }

    #[test]
    fn compressed_uses_shortest_of_name_or_hex() {
        // dart-sass compressed emits whichever is shorter, the canonical name or
        // the shortest hex (name wins ties).
        let name = |hex: &str| Color::from_hex(hex).expect("valid hex").to_css(true);

        // Name strictly shorter than hex -> name.
        assert_eq!(name("ff0000"), "red"); // red(3) < #f00(4)
        assert_eq!(name("ffa500"), "orange"); // orange(6) < #ffa500(7)
                                              // Tie (#rgb-expandable, 4 vs 4) -> name wins.
        assert_eq!(name("00ffff"), "aqua");
        assert_eq!(name("0000ff"), "blue");
        assert_eq!(name("00ff00"), "lime");
        // Hex shorter than name -> hex.
        assert_eq!(name("ff00ff"), "#f0f"); // magenta(7) > #f0f(4)
        assert_eq!(name("ffffff"), "#fff"); // white(5) > #fff(4)
                                            // No name -> hex.
        assert_eq!(name("3366cc"), "#36c");

        // Duplicate names resolve to dart's canonical pick (value, not spelling).
        assert_eq!(named_color("cyan").unwrap().to_css(true), "aqua");
        assert_eq!(named_color("grey").unwrap().to_css(true), "gray");
        // A computed (non-literal) color still names by value.
        assert_eq!(Color::rgb(0.0, 255.0, 255.0, 1.0).to_css(true), "aqua");

        // Expanded is unaffected: authored spelling is preserved.
        assert_eq!(Color::from_hex("ff0000").unwrap().to_css(false), "#ff0000");
        assert_eq!(named_color("red").unwrap().to_css(false), "red");
    }

    #[test]
    fn hsl_roundtrip_is_exact_for_integer_rgb() {
        // #336699 == hsl(210, 50%, 40%)
        let c = Color::from_hex("336699").expect("valid hex");
        let (h, s, l) = c.to_hsl();
        assert!((h - 210.0).abs() < 1e-9);
        assert!((s - 0.5).abs() < 1e-9);
        assert!((l - 0.4).abs() < 1e-9);
        // lighten by 10% -> exactly dart-sass's fractional rgb.
        let lit = Color::from_hsl(h, s, l + 0.1, 1.0);
        assert_eq!(lit.to_css(false), "rgb(25%, 50%, 75%)");
    }

    #[test]
    fn computed_fractional_channels_serialize_as_rgb() {
        let c = Color::rgb(153.0, 178.5, 204.0, 1.0);
        assert_eq!(c.to_css(false), "rgb(60%, 70%, 80%)");
    }

    #[test]
    fn compressed_picks_shortest_of_rgb_and_hsl() {
        // dart-sass 1.101.0 compressed output emits whichever legacy form is
        // shorter, the rgb()/rgba() form or the equivalent hsl()/hsla() form.

        // A `darken(#336699, 10%)` result: a fractional triple, so both forms
        // spell the channels as percentages.
        let darkened = Color::from_hsl(210.0, 0.5, 0.3, 1.0); // rgb(38.25, 76.5, 114.75)
        assert_eq!(darkened.to_css(true), "rgb(15%,30%,45%)");
        assert_eq!(darkened.to_css(false), "rgb(15%, 30%, 45%)");

        // A `saturate(#888, 20%)` result: the hsl form is longer -> stays rgb.
        let saturated = Color::rgb(159.8, 112.2, 112.2, 1.0);
        assert_eq!(saturated.to_css(true), "rgb(62.6666666667%,44%,44%)");

        // Non-opaque: rgba vs hsla; the percentage rgba form wins (alpha keeps `.5`).
        let translucent = Color::from_hsl(210.0, 0.5, 0.3, 0.5);
        assert_eq!(translucent.to_css(true), "rgba(15%,30%,45%,.5)");

        // A computed gray: the fractional rgb triple is far longer than hsl.
        let gray = Color::rgb(127.5, 127.5, 127.5, 1.0);
        assert_eq!(gray.to_css(true), "hsl(0,0%,50%)");

        // An integer in-gamut color still collapses to hex/name (always
        // shorter than hsl); the new hsl candidate must not regress this.
        let integer = Color::from_hsl(210.0, 0.5, 0.4, 1.0); // == #336699
        assert_eq!(integer.to_css(true), "#369");
        assert_eq!(Color::rgb(0.0, 0.0, 0.0, 0.5).to_css(true), "rgba(0,0,0,.5)");
    }

    #[test]
    fn alpha_color_serializes_as_rgba() {
        let c = Color::rgb(0.0, 0.0, 0.0, 0.5);
        assert_eq!(c.to_css(false), "rgba(0, 0, 0, 0.5)");
    }

    #[test]
    fn named_colors_resolve_and_preserve_spelling() {
        let red = named_color("red").expect("named");
        assert_eq!(red.to_css(false), "red");
        assert!(named_color("definitely-not-a-color").is_none());
        // Extended CSS names resolve to their exact sRGB channels.
        let plum = named_color("plum").expect("named");
        assert_eq!((plum.r, plum.g, plum.b, plum.a), (221.0, 160.0, 221.0, 1.0));
        let rebecca = named_color("rebeccapurple").expect("named");
        assert_eq!((rebecca.r, rebecca.g, rebecca.b), (102.0, 51.0, 153.0));
        // Grey/gray aliases share channel values (the repr keeps the spelling).
        let grey = named_color("darkgrey").expect("named");
        let gray = named_color("darkgray").expect("named");
        assert_eq!((grey.r, grey.g, grey.b), (gray.r, gray.g, gray.b));
    }

    #[test]
    fn unit_dimensions_group_known_units() {
        assert_eq!(unit_dimension("px"), Some(Dim::Length));
        assert_eq!(unit_dimension("deg"), Some(Dim::Angle));
        assert_eq!(unit_dimension("ms"), Some(Dim::Time));
        assert_eq!(unit_dimension("kHz"), Some(Dim::Frequency));
        assert_eq!(unit_dimension("dppx"), Some(Dim::Resolution));
        // The conversion table is case-sensitive (dart: `1in + 1Q` errors,
        // `1in + 1q` converts), so `PT`/`khz` have no group; nor do `%`,
        // viewport units, or unitless.
        assert_eq!(unit_dimension("PT"), None);
        assert_eq!(unit_dimension("khz"), None);
        assert_eq!(unit_dimension("%"), None);
        assert_eq!(unit_dimension("vw"), None);
        assert_eq!(unit_dimension(""), None);
    }

    #[test]
    fn units_compatible_within_groups_only() {
        assert!(units_compatible("in", "cm"));
        assert!(units_compatible("deg", "turn"));
        assert!(units_compatible("s", "ms"));
        assert!(units_compatible("Hz", "kHz"));
        assert!(units_compatible("dpi", "dppx"));
        // equal units are always compatible, even `%` and unknown units.
        assert!(units_compatible("%", "%"));
        assert!(units_compatible("PX", "PX"));
        // cross-group, unknown, and case-mismatched units are incompatible
        // (dart: `1px + 1PX` errors).
        assert!(!units_compatible("px", "s"));
        assert!(!units_compatible("px", "vw"));
        assert!(!units_compatible("px", "PX"));
        assert!(!units_compatible("khz", "hz"));
    }

    #[test]
    fn convert_factor_matches_dart_sass() {
        // length: 1in == 96px, 1cm == 96/2.54 px.
        assert_eq!(convert_factor("in", "px"), Some(96.0));
        assert_eq!(convert_factor("px", "px"), Some(1.0));
        let cm_to_in = convert_factor("cm", "in").expect("compatible");
        assert!((cm_to_in - (1.0 / 2.54)).abs() < 1e-12);
        // 1in + 1cm in inches: 1 + 1*(1/2.54) == 1.3937007874...
        assert!((1.0 + cm_to_in - 1.393700787401575).abs() < 1e-12);
        // time: 1ms == 0.001s.
        assert_eq!(convert_factor("ms", "s"), Some(0.001));
        // angle: 1turn == 360deg, 100grad == 90deg.
        assert_eq!(convert_factor("turn", "deg"), Some(360.0));
        assert_eq!(convert_factor("grad", "deg"), Some(0.9));
        // resolution: 1dppx == 96dpi.
        assert_eq!(convert_factor("dppx", "dpi"), Some(96.0));
        // incompatible -> None.
        assert_eq!(convert_factor("px", "s"), None);
        assert_eq!(convert_factor("px", "vw"), None);
    }

    #[test]
    fn fuzzy_is_int_needs_both_clauses_of_fuzzy_equals() {
        // Exactly integral, and the dust an hsl conversion leaves behind: both
        // are integers to dart's `fuzzyIsInt`.
        assert!(fuzzy_is_int(204.0));
        assert!(fuzzy_is_int(203.999_999_999_999_97));
        assert!(fuzzy_is_int(50.999_999_999_999_986));
        assert!(fuzzy_is_int(-0.0));
        // 5e-12 below 20 is INSIDE the epsilon, so the first clause of
        // `fuzzyEquals` passes it -- and the second one, which rounds both
        // sides at 1e11, rejects it (1999999999999 against 2000000000000).
        // dart therefore spells this channel as a percentage even under
        // `meta.inspect`.
        assert!(!fuzzy_is_int(19.999_999_999_994_987));
        // Plainly non-integral, and non-finite.
        assert!(!fuzzy_is_int(127.5));
        assert!(!fuzzy_is_int(f64::INFINITY));
        assert!(!fuzzy_is_int(f64::NAN));
    }

    fn numval(value: f64, unit: &str) -> Value {
        Value::Number(Number::with_unit(value, unit))
    }

    #[test]
    fn sass_eq_numbers_are_unit_aware_and_fuzzy() {
        // Same unit, equal value.
        assert!(numval(2.0, "px").sass_eq(&numval(2.0, "px")));
        // Convertible units compare after conversion.
        assert!(numval(1.0, "in").sass_eq(&numval(96.0, "px")));
        assert!(numval(96.0, "px").sass_eq(&numval(1.0, "in")));
        assert!(numval(1.0, "cm").sass_eq(&numval(10.0, "mm")));
        assert!(numval(100.0, "grad").sass_eq(&numval(90.0, "deg")));
        assert!(numval(1.0, "s").sass_eq(&numval(1000.0, "ms")));
        // Fuzzy: tiny differences within epsilon are equal.
        assert!(numval(1.000_000_000_000_1, "px").sass_eq(&numval(1.0, "px")));
        // Just outside epsilon is not equal.
        assert!(!numval(1.000_000_001, "px").sass_eq(&numval(1.0, "px")));
        // Unitless vs unit-bearing, incompatible units, `%`, and uppercase
        // units (case-sensitive) are never equal.
        assert!(!numval(1.0, "").sass_eq(&numval(1.0, "px")));
        assert!(!numval(1.0, "px").sass_eq(&numval(1.0, "em")));
        assert!(!numval(50.0, "%").sass_eq(&numval(50.0, "")));
        assert!(!numval(1.0, "PX").sass_eq(&numval(1.0, "px")));
        assert!(!numval(1.0, "IN").sass_eq(&numval(96.0, "px")));
    }

    #[test]
    fn sass_eq_colors_compare_channels_fuzzily() {
        // `purple` (128,0,128) equals an HSL color that resolves to channels
        // a tiny epsilon away (127.999999999998607...).
        let purple = Value::Color(Color::rgb(128.0, 0.0, 128.0, 1.0));
        let computed = Value::Color(Color::rgb(127.999_999_999_998_6, 0.0, 127.999_999_999_998_6, 1.0));
        assert!(purple.sass_eq(&computed));
        // Genuinely different channels are not equal.
        assert!(!purple.sass_eq(&Value::Color(Color::rgb(255.0, 0.0, 0.0, 1.0))));
        // A fractional channel is not equal to its rounded neighbour.
        let frac = Value::Color(Color::rgb(0.4, 0.0, 0.0, 1.0));
        assert!(!frac.sass_eq(&Value::Color(Color::rgb(0.0, 0.0, 0.0, 1.0))));
        assert!(frac.sass_eq(&Value::Color(Color::rgb(0.4, 0.0, 0.0, 1.0))));
        // Differing alpha is not equal.
        assert!(!purple.sass_eq(&Value::Color(Color::rgb(128.0, 0.0, 128.0, 0.5))));
    }

    /// A calculation is the one value whose serialization is recursive, so
    /// writing it into the caller's buffer is the one place where a missed
    /// `return`, a stale offset or a dropped parenthesis can lose or duplicate
    /// text that no single-node case would show. Every shape that decides a
    /// byte is listed — precedence parens on both sides, the `+ -n` operator
    /// flip that returns early, a function with several arguments, a
    /// unit-bearing non-finite number, an opaque operand — asserted against the
    /// spelling dart-sass 1.104.1 produces for the same input, and asserted
    /// again written after existing text.
    #[test]
    fn writing_a_calculation_appends_dart_sass_spelling() {
        fn num(v: f64, unit: &str) -> Box<CalcNode> {
            Box::new(CalcNode::Number(if unit.is_empty() {
                Number::unitless(v)
            } else {
                Number::with_unit(v, unit)
            }))
        }
        fn op(op: CalcOp, left: Box<CalcNode>, right: Box<CalcNode>) -> CalcNode {
            CalcNode::Op { op, left, right }
        }
        let var_x = || Box::new(CalcNode::Str("var(--x)".to_string()));

        // (node, expanded, compressed) — `None` where our compressed spelling
        // is a known pre-existing divergence (the `+ -n` flip is skipped when
        // compressed), which this change neither introduces nor fixes.
        let cases: Vec<(CalcNode, &str, Option<&str>)> = vec![
            (
                op(CalcOp::Sub, num(100.0, "%"), num(16.0, "px")),
                "calc(100% - 16px)",
                Some("calc(100% - 16px)"),
            ),
            // The right operand's sign flips the operator, and returns early.
            (
                op(CalcOp::Add, var_x(), num(-16.0, "px")),
                "calc(var(--x) - 16px)",
                None,
            ),
            // A looser child parenthesizes on the left...
            (
                op(
                    CalcOp::Mul,
                    Box::new(op(CalcOp::Add, var_x(), num(2.0, "px"))),
                    num(3.0, ""),
                ),
                "calc((var(--x) + 2px) * 3)",
                Some("calc((var(--x) + 2px)*3)"),
            ),
            // ...and on the right, where equal precedence under `/` also does.
            (
                op(
                    CalcOp::Div,
                    num(1.0, "px"),
                    Box::new(op(CalcOp::Mul, var_x(), num(3.0, ""))),
                ),
                "calc(1px / (var(--x) * 3))",
                Some("calc(1px/(var(--x)*3))"),
            ),
            // A tighter child does not.
            (
                op(
                    CalcOp::Add,
                    num(1.0, "px"),
                    Box::new(op(CalcOp::Mul, num(2.0, "px"), var_x())),
                ),
                "calc(1px + 2px * var(--x))",
                Some("calc(1px + 2px*var(--x))"),
            ),
            (
                CalcNode::Func {
                    name: "min".to_string(),
                    args: vec![
                        CalcNode::Number(Number::with_unit(10.0, "px")),
                        op(CalcOp::Add, var_x(), num(1.0, "px")),
                        CalcNode::Number(Number::with_unit(2.0, "px")),
                    ],
                },
                "min(10px, var(--x) + 1px, 2px)",
                Some("min(10px,var(--x) + 1px,2px)"),
            ),
            // A unit-bearing infinity is itself an operation, so it
            // parenthesizes like one — and it is written, not formatted.
            (
                CalcNode::Number(Number::with_unit(f64::INFINITY, "px")),
                "calc(infinity * 1px)",
                Some("calc(infinity*1px)"),
            ),
            (
                op(
                    CalcOp::Div,
                    var_x(),
                    CalcNode::Number(Number::with_unit(f64::NEG_INFINITY, "px")).into(),
                ),
                "calc(var(--x) / (-infinity * 1px))",
                Some("calc(var(--x)/(-infinity*1px))"),
            ),
            (*var_x(), "calc(var(--x))", Some("calc(var(--x))")),
        ];

        for (node, expanded, compressed) in &cases {
            for (style, expected) in [(false, Some(*expanded)), (true, *compressed)] {
                let Some(expected) = expected else { continue };
                assert_eq!(
                    &node.to_calc_value_css(style),
                    expected,
                    "calc spelling (compressed = {style}) for {node:?}"
                );
                // The same bytes when there is already text in the buffer: the
                // walk must append, never assume it starts at zero.
                let mut buf = String::from("PREFIX:");
                node.write_calc_value_css(&mut buf, style);
                assert_eq!(buf, format!("PREFIX:{expected}"));
            }
        }
    }

    /// [`Value::write_css`] and [`Value::to_css`] are two spellings of one
    /// serialization, and callers pick between them by whether they already hold
    /// a buffer — so a variant spelled out in one and not the other must still
    /// produce the same bytes. Every variant is listed, in both output styles,
    /// because the way this breaks is a new in-place arm that formats slightly
    /// differently from the owned one it was copied from and only shows up in the
    /// two places (declarations, interpolation) that take the buffer path.
    #[test]
    fn writing_a_value_in_place_matches_serializing_it_to_a_string() {
        let values = vec![
            Value::Number(Number::with_unit(12.5, "px")),
            Value::Color(Color::rgb(51.0, 102.0, 153.0, 1.0)),
            Value::Str(SassStr {
                text: "a b".into(),
                quoted: true,
            }),
            Value::Str(SassStr {
                text: "solid".into(),
                quoted: false,
            }),
            Value::List(List::new(
                vec![
                    Value::Number(Number::with_unit(1.0, "px")),
                    Value::Color(Color::rgb(0.0, 0.0, 0.0, 0.5)),
                ],
                ListSep::Space,
                false,
            )),
            Value::Map(Map::new(vec![(
                Value::Str(SassStr {
                    text: "k".into(),
                    quoted: false,
                }),
                Value::Number(Number::unitless(1.0)),
            )])),
            Value::Bool(true),
            Value::Bool(false),
            Value::Null,
            Value::Slash(Number::unitless(0.5), "1/2".to_string()),
            Value::Calc(CalcNode::Op {
                op: CalcOp::Sub,
                left: Box::new(CalcNode::Number(Number::with_unit(100.0, "%"))),
                right: Box::new(CalcNode::Number(Number::with_unit(16.0, "px"))),
            }),
            Value::Function(SassFunction {
                name: "f".to_string(),
                css: false,
                module: None,
                user: None,
            }),
            Value::Mixin(Box::new(SassMixin {
                name: "m".to_string(),
                user: None,
                module: None,
            })),
        ];
        // The list above is the whole enum, so a new variant cannot be added
        // without being written down here.
        let variants: std::collections::HashSet<_> = values.iter().map(std::mem::discriminant).collect();
        assert_eq!(variants.len(), 11, "one case per `Value` variant");

        for compressed in [false, true] {
            for v in &values {
                let mut buf = String::from("PREFIX:");
                v.write_css(&mut buf, compressed);
                assert_eq!(
                    buf,
                    format!("PREFIX:{}", v.to_css(compressed)),
                    "write_css disagrees with to_css (compressed = {compressed}) for {v:?}"
                );
            }
        }
        // The same for the interpolation pair, which shares the fall-through.
        for v in &values {
            let mut buf = String::new();
            v.write_interp(&mut buf);
            assert_eq!(
                buf,
                v.to_interp(),
                "write_interp disagrees with to_interp for {v:?}"
            );
        }
    }
}
