//! The parsed syntax tree.
//!
//! Selectors and property names are templates ([`TplPiece`]) because they
//! may contain `#{...}` interpolation that is only resolved at eval time.

use std::rc::Rc;

use crate::scanner::Pos;
use crate::value::{Color, ListSep};

/// A parsed stylesheet: an ordered list of top-level statements.
pub(crate) struct Stylesheet {
    pub stmts: Vec<Stmt>,
}

/// 1-based source-line metadata for the serializer's trailing-comment rule
/// (dart `_isTrailingComment`). `file` is an evaluator-interned source id
/// (0 = unknown, never trailing).
#[derive(Clone, Copy, Default, PartialEq)]
pub(crate) struct SrcLines {
    pub file: u32,
    /// A comment's `/*` line; a block's opening-brace line.
    pub start: u32,
    /// The construct's last line (closing delimiter / end of value).
    pub end: u32,
    /// A comment's 1-based `/*` column (0 elsewhere): two comments with the
    /// same file/lines/column are span-identical CLONES (the same file
    /// imported twice), which dart's span-containment branch rejects as
    /// trailing — distinct same-line comments differ in column and still join.
    pub col: u32,
    /// The 0-based source COLUMN of the mapped token's start (a selector's
    /// first character, a declaration/at-rule keyword, a comment's `/*`), used
    /// ONLY by source-map generation — never by the serializer. Default 0 when
    /// unknown. Distinct from [`Self::col`], which is overloaded for the
    /// trailing-comment / custom-property-reindent heuristics; this field is a
    /// pure additive carrier and changes no CSS output.
    pub start_col: u32,
    /// Source-map-only OVERRIDE for the mapped source file id (0 = fall back to
    /// [`Self::file`]). A bubbled `@media`/`@at-root` wrapper re-uses the
    /// enclosing rule's selector position for its mapping while keeping
    /// `file`/`start`/`end` at 0 so the trailing-comment heuristic stays
    /// disabled (dart maps the duplicated parent selector to the ORIGINAL rule's
    /// span). Like [`Self::start_col`] this changes no CSS output.
    pub map_file: u32,
    /// Source-map-only OVERRIDE for the mapped 1-based source line (0 = fall
    /// back to [`Self::start`]). Set together with [`Self::map_file`] on a
    /// bubbled-selector wrapper; see that field.
    pub map_line: u32,
}

impl SrcLines {
    /// The 1-based source line a mapping for this construct points at:
    /// [`Self::map_line`] when set (a rule maps its selector's first line,
    /// which is not its brace line), else [`Self::start`].
    pub(crate) fn mapped_line(&self) -> u32 {
        if self.map_line != 0 {
            self.map_line
        } else {
            self.start
        }
    }
}

/// A statement, valid at the top level or inside a rule body.
pub(crate) enum Stmt {
    /// `$name: value [!default] [!global];`
    VarDecl(VarDecl),
    /// `selector { ... }`
    Rule(Rule),
    /// `property: value [!important];`
    Decl(Declaration),
    /// A nested property set: `property: [value] { children }`. The optional
    /// value is emitted as `property: value;` first, then each child
    /// declaration is namespaced as `property-<child>` and emitted in source
    /// order (dart-sass property-set / namespaced-declaration form).
    PropertySet(PropertySet),
    /// A custom-property declaration (`--name: value`) whose name *literally*
    /// begins with `--`. Its value is captured verbatim (a template) — only
    /// `#{…}` interpolation is resolved, never SassScript — matching dart-sass
    /// `_interpolatedDeclarationValue`.
    CustomDecl(CustomDecl),
    /// `@import "a", "b";` — each entry is either a Sass path to inline or a
    /// plain CSS import emitted verbatim.
    /// `@import <args>;` — `pos`/`length` span the rule up to its `;`
    /// (`@import "x"`, trailing whitespace included), the caret dart uses when
    /// the rule is misplaced.
    Import {
        args: Vec<ImportArg>,
        pos: Pos,
        length: usize,
    },
    /// `@use "<url>" [as <namespace>|as *] [with (...)];`. Built-in `sass:*`
    /// modules and user stylesheets are both supported: the namespace defaults
    /// to the final URL segment (or the part after `sass:`), `as ns` overrides
    /// it, and `as *` exposes the members unprefixed. `with (...)` overrides the
    /// loaded module's `!default` variables before it is evaluated.
    Use {
        url: String,
        namespace: Option<String>,
        star: bool,
        config: Vec<ConfigEntry>,
        pos: Pos,
        /// Byte length of the rule (`@use "x" as y`, excluding the `;`) — the
        /// span dart reports a load failure or a misplaced rule against.
        length: usize,
    },
    /// `@forward "<url>" [as <prefix>-*] [show ...|hide ...] [with (...)];` —
    /// re-export another module's members from the current module.
    Forward {
        url: String,
        prefix: Option<String>,
        show: Option<Vec<ForwardMember>>,
        hide: Option<Vec<ForwardMember>>,
        config: Vec<ConfigEntry>,
        /// Byte length of the rule, as for [`Stmt::Use`].
        length: usize,
        pos: Pos,
    },
    /// `/* ... */` loud comment (inner text, without the delimiters). The body
    /// is a template so `#{…}` interpolation is resolved at eval time. The
    /// [`SrcLines`] carry the comment's source lines (parser fills start/end,
    /// `file` stays 0 until the evaluator stamps it).
    Comment(Vec<TplPiece>, SrcLines),
    /// `@if`/`@else if`/`@else` — evaluated top to bottom, first match wins.
    If(Vec<IfBranch>),
    /// `@for $i from A through|to B { … }`.
    For {
        var: String,
        from: Expr,
        to: Expr,
        inclusive: bool,
        body: Vec<Stmt>,
        /// 1-based start of `from`'s text. Source-map only: the loop variable's
        /// definition node is `_expressionNode(node.from)` (evaluate.dart:1666).
        from_pos: Pos,
    },
    /// `@each $v[, $k…] in <list> { … }`.
    Each {
        vars: Vec<String>,
        list: Expr,
        body: Vec<Stmt>,
        /// 1-based start of `list`'s text. Source-map only: every `@each`
        /// variable's definition node is `_expressionNode(node.list)`
        /// (evaluate.dart:1441).
        list_pos: Pos,
    },
    /// `@while <cond> { … }`.
    While { cond: Expr, body: Vec<Stmt> },
    /// `@function name(params) { … @return … }`. Shared in an `Rc` so the
    /// definition survives in the environment after its source drops.
    FunctionDef(Rc<Callable>),
    /// `@return <expr>;`
    Return(Expr),
    /// `@mixin name(params) { … }`.
    MixinDef(Rc<Callable>),
    /// `@include name(args) [{ content }];`. `module` is the namespace of a
    /// `@include ns.mixin(...)` reference; `None` for an unqualified include.
    Include {
        name: String,
        args: Vec<CallArg>,
        content: Option<Rc<Vec<Stmt>>>,
        /// The `using (params)` clause's parameters, if any — the content block
        /// declares these and they're bound from the `@content(args)` call.
        content_params: Option<Rc<ParamList>>,
        module: Option<String>,
        /// 1-based position of the `@include` keyword (the `@`), used as the
        /// call-site span for diagnostic stack frames.
        pos: Pos,
        /// Byte length of the CALL (`@include name(args)`, excluding the
        /// trailing `;`, a `using` clause and a content block) — dart's
        /// `spanWithoutContent`, which sizes the caret of an error about the
        /// call itself: a content block the mixin does not take, a missing
        /// argument.
        length: usize,
        /// Byte length of the WHOLE statement, `using` clause and content block
        /// included — dart's `span`, which sizes the caret of an error about
        /// the rule: an undefined mixin, a namespace that is not there.
        full_length: usize,
    },
    /// `@content;` or `@content(args)` — runs the `@include`'s content block,
    /// passing any arguments to its `using (params)`.
    Content { args: Vec<CallArg>, pos: Pos },
    /// A generic at-rule: `@name <prelude> { body }` or `@name <prelude>;`.
    /// `body == None` is the statement (`;`) form. Used for `@font-face`,
    /// `@page`, `@charset`, `@supports`, vendor `@foo`, and unknown
    /// directives alike.
    AtRule {
        name: String,
        prelude: Vec<TplPiece>,
        body: Option<Vec<Stmt>>,
        /// Source lines: `start` = the `{` line (or the rule's own line for the
        /// `;` form), `end` = the `}` line (or the same line).
        lines: SrcLines,
    },
    /// A generic at-rule whose NAME contains interpolation
    /// (`@#{"media"} … {}`): always treated as unknown — no Sass parse-time
    /// behavior — except `@keyframes`, whose frame handling happens at eval
    /// time once the name resolves.
    InterpAtRule {
        name: Vec<TplPiece>,
        prelude: Vec<TplPiece>,
        body: Option<Vec<Stmt>>,
        /// Source lines, as for [`Stmt::AtRule`]: `start` = the `{` line (or
        /// the rule's own line for the `;` form), `end` = the `}` line.
        lines: SrcLines,
    },
    /// A plain-CSS custom `@function`/`@mixin` whose name begins with `--`.
    /// dart-sass does not treat these as Sass definitions: the whole construct
    /// is emitted verbatim as a generic at-rule. `name` is the keyword exactly
    /// as written (`function`/`FUNCTION`/`mixin`). The prelude (`--a(...)
    /// [returns ...]`) and each body declaration value are preserved literally;
    /// only `#{...}` interpolation is resolved.
    CssCustomAtRule {
        name: String,
        prelude: Vec<TplPiece>,
        body: Vec<CssCustomItem>,
    },
    /// `@media <media-query-list> { body }`. The query is parsed into a
    /// structured form so SassScript inside feature values is resolved and the
    /// query is re-serialized (and bubbled/merged) exactly like dart-sass.
    Media {
        query: MediaQueryList,
        body: Vec<Stmt>,
        /// `{`/`}` source lines for the serializer's trailing-comment rule.
        lines: SrcLines,
    },
    /// `@supports <condition> { body }`. The condition is parsed into a
    /// structured form (`SupportsCondition`) so it serializes canonically and
    /// malformed conditions are rejected; the body bubbles like any at-rule.
    Supports {
        condition: SupportsCondition,
        body: Vec<Stmt>,
        /// `{`/`}` source lines (+ the `@` keyword column in `start_col`) for
        /// the serializer's trailing-comment rule and source-map output.
        lines: SrcLines,
    },
    /// `@at-root [query] { body }` — runs the body with the parent selector
    /// reset to the document root.
    AtRoot {
        query: Option<Vec<TplPiece>>,
        body: Vec<Stmt>,
    },
    /// `@keyframes <name> { from {…} 50% {…} … }`. The inner block selectors
    /// are keyframe selectors, not CSS selectors (no `&`/parent resolution),
    /// so the body is run with the parent context reset to root.
    Keyframes {
        name: String,
        prelude: Vec<TplPiece>,
        body: Vec<Stmt>,
        /// Source lines: `start` = the `{` line, `end` = the `}` line.
        lines: SrcLines,
    },
    /// `@extend <selector> [!optional];` — registers an extension of the
    /// enclosing rule onto the target selector. The selector is a template
    /// so `#{...}` interpolation resolves at eval time.
    Extend {
        selector: Vec<TplPiece>,
        optional: bool,
        pos: Pos,
    },
    /// `@warn <expr>;` — writes to stderr, emits no CSS. `pos` is the 1-based
    /// position of the `@warn` keyword (the innermost stack frame).
    Warn { value: Expr, pos: Pos },
    /// `@debug <expr>;` — writes to stderr, emits no CSS. `pos` is the 1-based
    /// position of the `@debug` keyword (only its line is reported).
    Debug { value: Expr, pos: Pos },
    /// `@error <expr>;` — aborts compilation with the message. `pos` is the
    /// 1-based position of the `@error` keyword and `length` the byte length of
    /// the `@error <expr>` span (used as the snippet span only at the document
    /// root; inside a call the innermost call site is used instead).
    Error { value: Expr, pos: Pos, length: usize },
}

/// One `$name: value [!default]` entry in a `@use`/`@forward` `with (...)`
/// configuration clause.
pub(crate) struct ConfigEntry {
    pub name: String,
    pub value: Expr,
    /// `!default` on a `@forward ... with` entry: the override only applies if
    /// the downstream module does not configure the variable itself.
    pub is_default: bool,
}

/// A member name in a `@forward ... show/hide` clause. Variables keep their
/// leading `$`; functions/mixins are bare identifiers.
pub(crate) enum ForwardMember {
    /// A `$variable` name (stored without the `$`).
    Var(String),
    /// A function or mixin name.
    Name(String),
}

/// One entry in an `@import` statement.
pub(crate) enum ImportArg {
    /// A Sass import: the (unquoted) path of a partial to resolve and inline,
    /// plus the 1-based position and byte length of the quoted URL token (for
    /// the `[import]` deprecation snippet).
    Sass { path: String, pos: Pos, length: usize },
    /// A plain CSS `@import`: emitted as `@import <url> <modifiers>;`. The URL
    /// is a template (only `#{…}` interpolation resolves); the modifiers are
    /// parsed structurally so `supports(...)` and media queries re-serialize
    /// canonically (dart-sass `tryImportModifiers`). `pos` is the 1-based
    /// position of the URL token (`url(` or the opening quote): a source map
    /// maps the emitted rule there, as dart's `visitCssImport` does.
    Css {
        url: Vec<TplPiece>,
        modifiers: Vec<ImportModifier>,
        pos: Pos,
    },
}

/// One parsed `@import` modifier (dart-sass `tryImportModifiers`).
pub(crate) enum ImportModifier {
    /// A run of bare identifiers and unknown functions (`b`, `c(d)`), joined
    /// by single spaces; captured as a template (only `#{…}` resolves).
    Raw(Vec<TplPiece>),
    /// `supports(<query>)`. `declaration` is true for a bare `supports(a: b)`
    /// query, whose `Declaration` serialization already carries its own parens
    /// (`supports((a: b))` also unwraps to this); every other condition gets
    /// wrapped in one explicit pair.
    Supports {
        condition: SupportsCondition,
        declaration: bool,
    },
    /// The trailing media query list (always the final modifier).
    /// `comma_before` distinguishes `b, (c: d)` (a list continued after a
    /// bare-identifier query) from `b (c: d)` (a space-joined list start).
    Media {
        list: MediaQueryList,
        comma_before: bool,
    },
}

/// One arm of an `@if` chain. `cond == None` is the trailing `@else`.
pub(crate) struct IfBranch {
    pub cond: Option<Expr>,
    pub body: Vec<Stmt>,
}

/// A `@function` or `@mixin` definition (same shape).
pub(crate) struct Callable {
    pub name: String,
    pub params: ParamList,
    pub body: Vec<Stmt>,
    /// 1-based start of the declaration's `name(params)` text, and its byte
    /// length. dart underlines exactly that as the `declaration` half of an
    /// argument-binding error — `m($x)` for `@mixin m($x)`, and just `m` when
    /// there is no parameter list at all.
    pub decl_pos: Pos,
    pub decl_length: usize,
}

/// A declared parameter list: positional/defaulted params plus an optional
/// trailing rest parameter (`$args...`).
pub(crate) struct ParamList {
    pub params: Vec<Param>,
    pub rest: Option<String>,
}

/// One declared parameter, with an optional default expression.
pub(crate) struct Param {
    pub name: String,
    pub default: Option<Expr>,
    /// 1-based position where `default`'s text starts ([`Pos::NONE`] when there
    /// is no default). Source-map only: a parameter bound from its declared
    /// default takes that default's span as its definition node, exactly like
    /// a `$x: <value>` declaration (dart `_expressionNode(parameter
    /// .defaultValue!)`, evaluate.dart:3588).
    pub default_pos: Pos,
}

pub(crate) struct VarDecl {
    pub name: String,
    pub value: Expr,
    pub is_default: bool,
    pub is_global: bool,
    /// `Some(ns)` for a namespaced assignment `ns.$name: value`, which updates
    /// the variable in the `@use`d module bound to `ns`.
    pub namespace: Option<String>,
    /// 1-based position where `value`'s text starts. Source-map only: this is
    /// the span dart records as the variable's *definition node* so a later
    /// bare `$name` reference in a declaration maps back here (dart
    /// `Environment._variableNodes`, environment.dart:93).
    pub value_pos: Pos,
}

pub(crate) struct Rule {
    pub selector: Vec<TplPiece>,
    pub body: Vec<Stmt>,
    /// 1-based position where the selector text starts, for mapping a
    /// resolved-selector error column back to the source.
    pub selector_pos: crate::scanner::Pos,
    /// Expression spans (line, start col, col of `}`) of the selector's
    /// top-level `#{…}` interpolations, parallel to its `Interp` pieces —
    /// for the dual-span "error in interpolated output" diagnostic.
    pub selector_interp_spans: Vec<(u32, u32, u32)>,
    /// 1-based line of the rule's opening `{` (0 when unavailable), for the
    /// serializer's trailing-comment rule.
    pub brace_line: u32,
    /// 1-based line of the rule's closing `}` (0 when unavailable).
    pub end_line: u32,
}

/// One top-level item in a plain-CSS custom `@function`/`@mixin` body. The
/// value is captured as a template (preserving arbitrary CSS characters
/// verbatim, resolving only `#{...}`) when the property is a plain literal,
/// or as a SassScript expression when the property contains interpolation —
/// matching dart-sass's declaration parsing inside these constructs.
pub(crate) struct CssCustomItem {
    pub property: Vec<TplPiece>,
    /// `Err` holds the verbatim value template; `Ok` holds a SassScript value.
    pub value: CssCustomValue,
}

pub(crate) enum CssCustomValue {
    /// Verbatim value template (literal property): whitespace runs collapse to
    /// single spaces and `#{...}` resolves, otherwise emitted exactly.
    Raw(Vec<TplPiece>),
    /// SassScript value (interpolated property): evaluated normally.
    Script(Expr),
    /// A nested property set on an interpolated property (`#{re}sult: {b: c}`):
    /// each `(suffix, value)` child emits as `property-suffix: value`.
    Set(Vec<(Vec<TplPiece>, Expr)>),
}

pub(crate) struct Declaration {
    pub property: Vec<TplPiece>,
    pub value: Expr,
    pub important: bool,
    pub pos: Pos,
    /// 1-based line where the declaration's value ends (0 when unavailable),
    /// for the serializer's trailing-comment rule.
    pub end_line: u32,
    /// 1-based position where `value`'s text starts. Source-map only: dart
    /// wraps the serialized value in `forSpan(valueSpanForMap)`
    /// (serialize.dart:389), which defaults to the value expression's own span
    /// and becomes the *variable definition's* span when the value is a bare
    /// `$name` (evaluate.dart:1414 -> `_expressionNode`, evaluate.dart:4538).
    pub value_pos: Pos,
}

/// A custom-property declaration (`--name: value`). The name and the value
/// are both templates so `#{…}` interpolation resolves at eval time; the value
/// is otherwise emitted verbatim (no SassScript evaluation).
pub(crate) struct CustomDecl {
    pub property: Vec<TplPiece>,
    pub value: Vec<TplPiece>,
    pub pos: Pos,
    /// 1-based line where the declaration's value ends (0 when unavailable),
    /// for the serializer's trailing-comment rule.
    pub end_line: u32,
    /// 1-based position where the verbatim value text starts. Source-map only:
    /// a custom property is serialized inside `_for(node.value, …)`
    /// (serialize.dart:379), i.e. always the value's OWN span — a custom
    /// property never routes through `_expressionNode`, so `--x: $c` maps to
    /// the `$c` text, not to `$c`'s definition.
    pub value_pos: Pos,
}

/// A nested property set: a declaration whose value (which may be empty) is
/// followed by a `{ … }` block whose children are namespaced with the parent
/// property name joined by `-`.
pub(crate) struct PropertySet {
    pub property: Vec<TplPiece>,
    /// The optional leading value (`b: c { … }` keeps `c`; `b: { … }` is
    /// `None`). When present it is emitted as `<property>: <value>;` first.
    pub value: Option<Expr>,
    pub important: bool,
    pub body: Vec<Stmt>,
    pub pos: Pos,
}

/// One piece of an interpolated template: literal text or an embedded
/// expression (`#{...}`).
pub(crate) enum TplPiece {
    /// Literal text, held as `Rc<str>` because a template that is a single
    /// literal — which is what nearly every property name and unquoted value
    /// keyword is — hands this buffer straight to the string it evaluates to
    /// rather than copying it. The parser builds it once and never edits it.
    Lit(Rc<str>),
    Interp(Expr),
}

/// A value expression.
pub(crate) enum Expr {
    /// Numeric literal: value + unit (`""` for unitless). The unit is spelled
    /// out once, here, and every evaluation of the literal shares it — a
    /// `1px` inside a loop body allocates no unit at all.
    Number(f64, Rc<str>),
    /// Color literal (hex or named), parsed eagerly.
    Color(Color),
    /// Quoted string, possibly with interpolation.
    QuotedString(Vec<TplPiece>),
    /// Unquoted identifier/string, possibly with interpolation
    /// (e.g. `solid`, `sans-serif`, `col-#{$n}`).
    Ident(Vec<TplPiece>),
    /// `true` / `false`.
    Bool(bool),
    /// `null`.
    Null,
    /// `$name` variable reference.
    Var { name: String, pos: Pos },
    /// `ns.$name` — a module variable reference (e.g. `math.$pi`). Resolved by
    /// the evaluator against the used module bound to `module`.
    NsVar {
        module: String,
        name: String,
        /// The `ns` identifier's position, and the byte length of the whole
        /// `ns.$name` reference — the span dart reports against.
        pos: Pos,
        length: usize,
    },
    /// The parent selector `&` used in value position. Resolves to the current
    /// resolved selector as a comma-separated list of space-separated
    /// compound-selector strings, or `null` at the document root.
    Parent,
    /// Binary arithmetic / string concatenation.
    Binary {
        op: BinOp,
        lhs: Box<Expr>,
        rhs: Box<Expr>,
        pos: Pos,
    },
    /// The `a / b` slash operator. When `slash` is true (both operands are
    /// number literals or themselves slash divisions), it produces a
    /// slash-separated value that serializes as `a/b`; otherwise it performs
    /// real division.
    Div {
        lhs: Box<Expr>,
        rhs: Box<Expr>,
        slash: bool,
        pos: Pos,
    },
    /// A `calc()` calculation whose interior is the wrapped expression.
    /// Evaluated with calc simplification rules (numeric subtrees fold,
    /// everything else is preserved verbatim).
    Calc { inner: Box<Expr> },
    /// Unary negation.
    Unary { op: UnOp, operand: Box<Expr> },
    /// Function call. `module` is the namespace of a `ns.fn(...)` call (the
    /// part before the dot); `None` for an ordinary unqualified call.
    Func {
        name: String,
        args: Vec<CallArg>,
        /// 1-based position of the function-name start (the call's primary span
        /// origin for diagnostics — `rgb(…)` points at `rgb`).
        pos: Pos,
        /// Byte length of the whole call `name(args)`, for the diagnostic caret.
        length: usize,
        module: Option<String>,
    },
    /// A function call whose name contains interpolation (`qu#{o}te(arg)`).
    /// dart-sass treats these as *plain CSS* calls: the name resolves at
    /// eval time, the arguments are evaluated, and the call serializes
    /// verbatim — never dispatched to a built-in or user function.
    InterpFunc {
        name: Vec<TplPiece>,
        args: Vec<CallArg>,
        pos: Pos,
    },
    /// A space- or comma-separated list. `bracketed` marks `[a b]`/`[a, b]`
    /// literals, which serialize wrapped in square brackets.
    List {
        items: Vec<Expr>,
        sep: ListSep,
        bracketed: bool,
    },
    /// `( expr )`.
    Paren(Box<Expr>),
    /// A map literal `(k1: v1, k2: v2)`. Disambiguated from a parenthesised
    /// expression / list by the `:` after the first key. An empty map is
    /// written `()` but parses as the empty list; only a non-empty
    /// `(k: v, …)` produces this node.
    Map(Vec<(Expr, Expr)>),
    /// `#{ expr }` used in value position — always yields an unquoted
    /// string.
    Interp(Box<Expr>),
    /// The modern CSS `if()` conditional: a `;`-separated list of clauses,
    /// each `<condition>: <value>` (or `else: <value>`). Conditions mix
    /// `sass(<expr>)` (evaluated) and `css(...)`/other "arbitrary
    /// substitution" pieces (kept verbatim). Distinct from the legacy
    /// `if($cond, $t, $f)` builtin, which routes through [`Expr::Func`].
    ModernIf(Vec<IfClause>),
}

/// One clause of a modern `if()`: an optional condition (absent for the
/// trailing `else` clause) and its value expression.
pub(crate) struct IfClause {
    /// `None` for the `else` clause; otherwise the parsed condition tree.
    pub condition: Option<IfCond>,
    pub value: Expr,
}

/// A modern `if()` condition tree. Atoms are either an evaluated
/// `sass(<expr>)` or a verbatim "raw" CSS sequence (`css(...)`, `var(...)`,
/// nested `if(...)`, interpolation, ...); combined with `not`/`and`/`or`
/// and parentheses.
pub(crate) enum IfCond {
    /// `sass(<expr>)` — evaluated for truthiness.
    Sass(Box<Expr>),
    /// One or more space-separated raw substitution tokens forming a single
    /// non-evaluable CSS condition (each token is a template so embedded
    /// `#{...}` resolves at eval time). `multi` is true when the sequence has
    /// more than one token (an "arbitrary substitution", which may not
    /// coexist with `sass()` in the same condition).
    Raw { pieces: Vec<TplPiece>, multi: bool },
    /// `not <cond>`.
    Not(Box<IfCond>),
    /// `<cond> and <cond>` (one or more, left-associative chain).
    And(Vec<IfCond>),
    /// `<cond> or <cond>` (one or more, left-associative chain).
    Or(Vec<IfCond>),
    /// `( <cond> )`.
    Paren(Box<IfCond>),
}

/// A call argument, optionally named (`$name: value`).
///
/// A `splat` argument (`$list...`) is expanded at call time: a list spreads
/// into positional arguments and a map spreads into keyword arguments. A
/// splat argument never carries a `name`.
pub(crate) struct CallArg {
    pub name: Option<String>,
    pub value: Expr,
    pub splat: bool,
    /// 1-based position where `value`'s text starts. Source-map only: binding a
    /// parameter to this argument records the argument's span as the
    /// parameter's definition node, so `@mixin m($p) { pad: $p }` invoked as
    /// `@include m(4px)` maps the emitted `4px` back to the CALL SITE (dart
    /// `evaluated.positionalNodes` / `namedNodes`, evaluate.dart:3572-3592).
    pub value_pos: Pos,
}

#[derive(Clone, Copy)]
pub(crate) enum BinOp {
    Add,
    Sub,
    Mul,
    Mod,
    Eq,
    Neq,
    Lt,
    Gt,
    Le,
    Ge,
    And,
    Or,
    /// The single-`=` Microsoft-filter operator, valid only inside a function
    /// argument list (`alpha(opacity=80)`). It is the lowest-precedence value
    /// operator: both sides are evaluated and joined with `=` (no spaces) as an
    /// unquoted string.
    SingleEq,
}

#[derive(Clone, Copy)]
pub(crate) enum UnOp {
    Neg,
    /// Unary `+`: numeric identity (`+5` -> `5`); on any other operand an
    /// unquoted string prefixed with `+` (`+foo` -> `+foo`), matching
    /// dart-sass's `unaryPlus`.
    Plus,
    Not,
}

// ---- media queries -----------------------------------------------------

/// A `@media` prelude: a comma-separated list of media queries.
pub(crate) struct MediaQueryList {
    pub queries: Vec<MediaQuery>,
}

/// One media query: either a media-type form (`[not|only]? <type> [and
/// <cond>]*`) or a condition-only form (`<cond> [<and|or> <cond>]*`).
pub(crate) enum MediaQuery {
    /// `[modifier]? <type> [and <cond>]*`. The modifier (`not`/`only`,
    /// already lowercased) and type may contain interpolation.
    Type {
        modifier: Option<Vec<TplPiece>>,
        mtype: Vec<TplPiece>,
        conditions: Vec<MediaInParens>,
    },
    /// `<cond> [<and|or> <cond>]*`.
    Condition {
        conditions: Vec<MediaInParens>,
        conjunction: Conjunction,
    },
}

/// `and` / `or`, the conjunction joining media conditions.
#[derive(Clone, Copy, PartialEq, Eq)]
pub(crate) enum Conjunction {
    And,
    Or,
}

/// A single "media in parens": one operand of a media condition.
pub(crate) enum MediaInParens {
    /// `(<feature>)` — serialized wrapped in parentheses. Boxed because a
    /// [`MediaFeature`] is large relative to the other variants.
    Feature(Box<MediaFeature>),
    /// `not <media-in-parens>` — serialized without wrapping parentheses.
    Not(Box<MediaInParens>),
    /// `(<cond> <and|or> <cond>…)` — a parenthesised sub-condition group,
    /// serialized keeping its parentheses.
    Group {
        conditions: Vec<MediaInParens>,
        conjunction: Conjunction,
    },
    /// Raw interpolation spliced into the query verbatim, e.g.
    /// `(a) and #{"(b) and (c)"}`.
    Interp(Expr),
}

/// The interior of a single `(...)` media feature.
pub(crate) enum MediaFeature {
    /// `(<name>)` or `(<name>: <value>)`.
    Decl { name: Expr, value: Option<Expr> },
    /// A range feature: `<first> <op1> <second> [<op2> <third>]`.
    Range {
        first: Expr,
        op1: String,
        second: Expr,
        rest: Option<(String, Expr)>,
    },
}

// ---- @supports conditions ----------------------------------------------

/// A parsed `@supports` condition (dart-sass `SupportsCondition`). The
/// condition is re-serialized canonically at eval time: `(a: b)` declaration
/// spacing, stripped trivia comments, normalized whitespace.
pub(crate) enum SupportsCondition {
    /// `(<name>: <value>)`. `custom` is true when the name is a literal
    /// unquoted identifier starting with `--`; its value is then captured
    /// verbatim (a template) and serialized with no space after the colon.
    Declaration {
        name: Expr,
        value: Box<SupportsValue>,
        custom: bool,
    },
    /// `not <condition-in-parens>`.
    Negation(Box<SupportsCondition>),
    /// `<left> <and|or> <right>`.
    Operation {
        left: Box<SupportsCondition>,
        right: Box<SupportsCondition>,
        op: Conjunction,
    },
    /// A lone `#{…}` interpolation spliced in verbatim (unquoted).
    Interpolation(Expr),
    /// `<name>(<arguments>)` — a `supports()`-style function call. Both the
    /// name and the arguments are templates captured verbatim.
    Function {
        name: Vec<TplPiece>,
        arguments: Vec<TplPiece>,
    },
    /// `(<anything>)` — an arbitrary parenthesised value captured verbatim
    /// (the declaration grammar didn't match, e.g. `(a b)` or `(a !&$)`).
    Anything(Vec<TplPiece>),
}

/// The right-hand side of a `@supports` declaration condition.
pub(crate) enum SupportsValue {
    /// A normal SassScript expression value (`(a: 1 + 1)` -> `(a: 2)`).
    Expr(Expr),
    /// A custom-property value captured verbatim as a template (only `#{…}`
    /// interpolation resolves); serialized with no space after the colon.
    Raw(Vec<TplPiece>),
}
