//! The evaluator: walks the AST, resolving variables, nesting (`&` and
//! the parent×child selector product), interpolation and arithmetic, and
//! flattens the result into a list of output rules.
//!
//! Like dart-sass (and unlike grass), a rule's own declarations are
//! gathered into a single block emitted *before* its nested rules bubble
//! out after it.

use std::borrow::Cow;
use std::cell::RefCell;
use std::rc::Rc;

// The compiler's internal maps are all keyed on short identifiers taken from
// the stylesheet being compiled, so they use the fast FxHash hasher rather than
// std's DoS-resistant-but-slow SipHash. Aliased to `HashMap` so the many type
// declarations below read normally; only the construction sites differ
// (`HashMap::default()` rather than `::new()`, since the hasher is non-default).
use crate::fxhash::FxHashMap as HashMap;

use crate::ast::{
    BinOp, CallArg, Callable, Conjunction, CssCustomItem, CssCustomValue, CustomDecl, Declaration, Expr,
    IfClause, IfCond, ImportArg, ImportModifier, MediaFeature, MediaInParens, MediaQuery, MediaQueryList,
    ParamList, PropertySet, Rule, SrcLines, Stmt, Stylesheet, SupportsCondition, SupportsValue, TplPiece,
    UnOp, VarDecl,
};
use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{CalcNode, CalcOp, List, ListSep, Map, Number, SassFunction, SassMixin, SassStr, Value};
use crate::{CanonicalUrl, CanonicalizeContext, Importer, OutputStyle, Syntax};

mod at_rules;
mod binop;
mod calc;
mod control_flow;
mod expr;
mod meta;
mod modules;
mod plain_css;
mod scope;

use binop::*;
use expr::InterpBounds;
// `eval_div` is part of the crate-internal surface (`crate::eval::eval_div`,
// called from `builtins::math`); re-export it so that path still resolves.
pub(crate) use binop::eval_div;

/// One cached `@import` resolution: (resolved canonical key, syntax, parsed
/// sheet, source text, the importer's `source_map_url`), shared across
/// repeated imports within a single compile. The source rides along so
/// re-executions can swap it in as the current diagnostics/stamp context.
type CachedImport = std::rc::Rc<(
    String,
    Syntax,
    crate::ast::Stylesheet,
    std::rc::Rc<str>,
    Option<String>,
)>;

/// Parse imported/`@use`d source with the front-end matching its file syntax.
fn parse_with_syntax(src: &str, syntax: Syntax) -> Result<crate::ast::Stylesheet, Error> {
    match syntax {
        Syntax::Scss => crate::parser::parse(src),
        Syntax::Css => crate::parser::parse_plain_css(src),
        Syntax::Sass => crate::sass_parser::parse(src),
    }
}

/// A call's evaluated arguments, split into positional values and named
/// `(name, value)` keyword pairs (after splat expansion), plus the rest-
/// argument list separator (a splatted list's separator survives into the
/// callee's arglist; comma otherwise).
type EvaledArgs = (Vec<Value>, Vec<(String, Value)>, ListSep);

/// Definition spans for the values in an [`EvaledArgs`], parallel to its
/// positional and keyword vectors (dart `ArgumentResults.positionalNodes` /
/// `namedNodes`). Binding a parameter to an argument copies the matching span
/// so `@mixin m($p) { pad: $p }` + `@include m(4px)` maps the emitted `4px`
/// back to the CALL SITE. Source-map only.
#[derive(Default)]
pub(crate) struct ArgSpans {
    positional: Vec<VarSpan>,
    named: Vec<(String, VarSpan)>,
}

impl ArgSpans {
    /// The span recorded for positional argument `i`, if any.
    fn positional(&self, i: usize) -> VarSpan {
        self.positional.get(i).copied().unwrap_or_default()
    }

    /// The span recorded for the keyword argument spelled `name` (compared
    /// hyphen/underscore-insensitively, like the value lookup).
    fn named(&self, name: &str) -> VarSpan {
        let key = normalize_arg_name(name);
        self.named
            .iter()
            .find(|(n, _)| normalize_arg_name(n) == key)
            .map(|(_, sp)| *sp)
            .unwrap_or_default()
    }
}

/// One variable scope. Lexical scoping shares frames between the active
/// chain and callable closures (dart's Environment maps), so a scope is a
/// shared, interior-mutable map.
pub(crate) type Scope = std::rc::Rc<std::cell::RefCell<HashMap<String, Value>>>;

fn new_scope() -> Scope {
    std::rc::Rc::new(std::cell::RefCell::new(HashMap::default()))
}

/// How many popped scope tables to keep for reuse. Blocks nest, so the pool
/// only has to cover a sheet's nesting depth plus the churn of its siblings;
/// past that, freeing a table is cheaper than holding its buckets.
const SCOPE_POOL_MAX: usize = 32;

/// A table wider than this came from a block with an unusual number of
/// bindings. Parking it would keep those buckets alive for the whole compile,
/// which is the one thing the pool must not trade for its allocations.
const SCOPE_POOL_MAX_CAPACITY: usize = 64;

/// Park a popped scope table for reuse, or let it go.
///
/// The table returns to the pool only when this is the LAST reference to it: a
/// closure that captured the chain — a `@function` or `@mixin` body, a
/// `@content` block — holds an `Rc` of its own, and the bindings it can still
/// read must stay exactly where they are. `Rc::strong_count` answers precisely
/// that question, and a `Weak` (none exist today) would be one more holder, so
/// it is checked too.
fn recycle_scope<T>(
    pool: &mut Vec<Rc<std::cell::RefCell<HashMap<String, T>>>>,
    scope: Rc<std::cell::RefCell<HashMap<String, T>>>,
) {
    if pool.len() >= SCOPE_POOL_MAX || Rc::strong_count(&scope) != 1 || Rc::weak_count(&scope) != 0 {
        return;
    }
    {
        let mut vars = scope.borrow_mut();
        if vars.capacity() > SCOPE_POOL_MAX_CAPACITY {
            return;
        }
        // `clear` keeps the buckets: the next block to take this table finds an
        // empty map that no longer has to build its own.
        vars.clear();
    }
    pool.push(scope);
}

/// Where a variable was DEFINED: the interned source file id plus the 0-based
/// line/column of the defining expression's first character.
///
/// This is sasso's equivalent of the `AstNode` dart stores in
/// `Environment._variableNodes` (environment.dart:93) — a map kept in lockstep
/// with `_variables`, holding, for each binding, the node whose span should be
/// blamed for the value. It exists purely for source maps and diagnostics
/// alignment: no CSS byte depends on it.
///
/// `file == 0` means "unknown" (a synthesized binding with no source text, e.g.
/// a built-in module variable or a host-function argument); the source map
/// drops such entries.
#[derive(Clone, Copy, PartialEq, Eq, Default)]
pub(crate) struct VarSpan {
    pub file: u32,
    /// 0-based source line.
    pub line: u32,
    /// 0-based source column.
    pub col: u32,
}

/// One frame of the variable-definition-span chain, parallel to [`Scope`]
/// (dart's `Environment._variableNodes` is a `List<Map<String, AstNode>>`
/// pushed and popped in lockstep with `_variables`). Shared by `Rc` so a
/// callable's captured closure sees later writes to the frames it closed over,
/// exactly like the value chain.
pub(crate) type SpanScope = std::rc::Rc<std::cell::RefCell<HashMap<String, VarSpan>>>;

fn new_span_scope() -> SpanScope {
    std::rc::Rc::new(std::cell::RefCell::new(HashMap::default()))
}

/// One function/mixin scope frame, parallel to the variable chain (dart's
/// `Environment._functions`/`_mixins` are lists of maps pushed and popped in
/// lockstep with `_variables`).
pub(crate) type FnScope = std::rc::Rc<std::cell::RefCell<HashMap<String, Rc<UserCallable>>>>;

fn new_fn_scope() -> FnScope {
    std::rc::Rc::new(std::cell::RefCell::new(HashMap::default()))
}

/// One frame of the function or mixin chain, EMPTY until something is defined
/// in it. Nearly every block is empty: a `@function` or `@mixin` is written at
/// the top level of a file or a mixin body, while the blocks that push a frame
/// are style rules and control flow, which almost never declare one. `None`
/// says "no definitions here" without paying for a table to hold them.
///
/// The frame is materialized on the two events that can make it observable
/// beyond the current block — a definition landing in it
/// ([`Evaluator::define_function`]) and the chain being closed over by a
/// callable or a `@content` block — so a materialized frame is always the
/// SHARED `Rc` the chain and every closure over it see, exactly as an eagerly
/// allocated one was (see [`materialize_fn_frames`]).
pub(crate) type FnFrame = Option<FnScope>;

/// Give every frame of a function or mixin chain a table, so the chain can be
/// cloned into a lexical closure.
///
/// A closure over the chain (a callable's capture, a `@content` block's call-site
/// snapshot) does not copy the frames — it shares them, so a definition written
/// into a frame afterwards is visible through both. A cloned `None` would share
/// nothing: each side would materialize its own table on its next definition and
/// the other would never see it. Materializing first keeps the sharing that an
/// eagerly allocated frame had, and costs an allocation only for frames that
/// went unused up to this point.
fn materialize_fn_frames(chain: &mut [FnFrame]) {
    for frame in chain {
        frame.get_or_insert_with(new_fn_scope);
    }
}

/// The `@use` namespace tables visible at a callable's definition site.
/// dart's `Environment.closure()` carries them with the rest of the lexical
/// environment: a callable inlined by `@import` must resolve `list.length()`
/// against ITS file's `@use "sass:list"`, not whatever the caller has bound
/// (uswds `units()`, quasar `str-fe()`).
#[derive(Clone)]
pub(crate) struct EnvModules {
    pub(self) used_modules: HashMap<String, &'static str>,
    pub(self) star_modules: Vec<&'static str>,
    pub(self) used_user_modules: HashMap<String, Rc<Module>>,
    pub(self) star_user_modules: Vec<Rc<Module>>,
}

/// A user `@function`/`@mixin` with its LEXICAL environment: the variable and
/// function/mixin scope chains captured at the definition site (shared
/// frames, dart's `Environment.closure()`). The body runs against these
/// chains, not the caller's stack.
/// What an argument-binding failure points back at: the callable's name for
/// the message, and the `name(params)` span in the file it was DECLARED in,
/// which dart draws as the error's second span.
pub(super) struct Declared<'a> {
    pub pos: Pos,
    pub length: usize,
    /// The file the declaration is in. `None` means the current one.
    pub origin: Option<&'a crate::value::MixinOrigin>,
}

pub(crate) struct UserCallable {
    pub def: Rc<Callable>,
    /// The file that defined the callable. Its body runs against that file
    /// (dart evaluates a mixin or function where it was written): output maps
    /// to it, and diagnostics show its name and source — whether it was
    /// reached through `@use`, a textual `@import`, or a first-class
    /// reference. Always present: `capture_callable` is the only way a
    /// callable is built, and it records the file every time, so there is no
    /// "ask the module it came from" fallback to get wrong.
    pub origin: crate::value::MixinOrigin,
    pub env: Vec<Scope>,
    /// The variable-definition-span chain captured alongside `env`, frame for
    /// frame (dart closes over `_variableNodes` with the rest of the
    /// environment).
    pub env_spans: Vec<SpanScope>,
    pub env_semi: Vec<bool>,
    pub env_fns: Vec<FnFrame>,
    pub env_mixins: Vec<FnFrame>,
    pub env_modules: EnvModules,
}

/// A style rule's selector list, carried through the output tree either as the
/// raw resolved strings (the common case — no `@extend` rewrote it, so it is
/// never parsed) or as the typed `Complex` list the `@extend` engine produced
/// (Phase 1d: the engine works on the typed model directly — no `join(", ")` +
/// `parse_list` round trip — and emit renders it via `Complex::render()`, which
/// is byte-identical to the strings the engine used to materialize).
#[derive(Clone)]
pub(crate) enum RuleSelectors {
    /// The already-resolved selector strings (`&`/interpolation substituted).
    /// Untouched by the extend pass — emit writes them verbatim. This is the
    /// zero-parse fast path: an extend-free stylesheet never leaves this form.
    ///
    /// Shared: a style rule resolves its list once, and the same list reaches
    /// `current_selector`, every nested rule's `parents` and every block this
    /// rule flushes. Nothing mutates it in place.
    Raw(Rc<Vec<String>>),
    /// The typed selector list a rewrite produced. Rendered only at emit, via
    /// the same `Complex::render()` the engine used to materialize its strings.
    Parsed(Rc<[crate::selector::Complex]>),
}

impl RuleSelectors {
    /// The selector list as rendered strings: the `Raw` slice borrowed
    /// directly, or each `Parsed` `Complex` rendered (byte-identical to the
    /// strings the extend engine used to produce). Used by emit and by the
    /// pre-extend passes (reparent, plain-CSS at-body lowering) and the
    /// cross-media probe.
    pub(crate) fn to_strings(&self) -> std::borrow::Cow<'_, [String]> {
        match self {
            RuleSelectors::Raw(v) => std::borrow::Cow::Borrowed(v),
            RuleSelectors::Parsed(v) => std::borrow::Cow::Owned(v.iter().map(|c| c.render()).collect()),
        }
    }

    /// Consume into rendered strings (owned), for the pre-extend lowering paths
    /// that move a rule's selectors into an `OutItem`/joined parent shell.
    fn into_strings(self) -> Vec<String> {
        match self {
            // The one owner is the common case (a rule flushes a single
            // block); a shared list is copied here rather than at every flush.
            RuleSelectors::Raw(v) => Rc::try_unwrap(v).unwrap_or_else(|rc| (*rc).clone()),
            RuleSelectors::Parsed(v) => v.iter().map(|c| c.render()).collect(),
        }
    }
}

/// Which dart-sass node class an at-rule came from — a fact its NAME cannot
/// answer, because the PARSER decides the class and the evaluator is only where
/// an interpolated name finally reads `media`. `@#{"media"} (a: 1) {…}` is a
/// generic at-rule in dart, spelled `@media (a: 1)`; only a parsed `@media` is a
/// conditional group rule.
///
/// The difference is observable twice, both times making a conditional rule LESS
/// visible than a generic one: it is the only kind that omits the compressed
/// space before a `(` prelude (`visitCssMediaRule`/`visitCssSupportsRule`), and
/// the only kind that goes away when its block writes nothing (`_isInvisible`
/// short-circuits on `CssAtRule` — "an unknown at-rule is never invisible …
/// we can't guarantee that (for example) `@foo {}` isn't meaningful").
#[derive(Clone, Copy, PartialEq, Eq)]
pub(crate) enum AtRuleKind {
    /// dart `CssMediaRule` or `CssSupportsRule`.
    Conditional,
    /// dart `CssAtRule`: an unknown at-rule, `@font-face`, `@page`,
    /// `@keyframes`, a plain-CSS custom `@function`/`@mixin` — and any at-rule
    /// whose name arrived through interpolation, whatever that name spells.
    Generic,
}

impl AtRuleKind {
    /// Whether this is one of the two conditional group rules.
    pub(crate) fn is_conditional(self) -> bool {
        matches!(self, AtRuleKind::Conditional)
    }
}

/// A flattened output node.
#[derive(Clone)]
pub(crate) enum OutNode {
    Rule {
        selectors: RuleSelectors,
        /// Per-complex "line break before" flags from the source selector list
        /// (`a,\nb` keeps the newline). Empty means none (all comma-joined with
        /// a space); otherwise parallel to `selectors`.
        linebreaks: Vec<bool>,
        items: Vec<OutItem>,
        /// Source lines (`start` = the `{` line, `end` = the `}` line) for the
        /// serializer's trailing-comment rule; default = disabled.
        lines: SrcLines,
        /// The number of `@extend`s already registered when this rule's selector
        /// was established (dart-sass `addSelector` timing). When the rule was
        /// registered AFTER every applicable `@extend` (`extend_base >=`
        /// visible-extension count), dart extends the fresh selector by the whole
        /// store at ONCE — `_extendComplex`'s `paths` unification order (last
        /// choice slowest) — rather than re-extending it incrementally
        /// (registration-order fold). `usize::MAX` marks a non-evaluated rule
        /// (plain-CSS import, `@at-root` graft, reparent shell) for which the
        /// sequential default always applies.
        extend_base: usize,
    },
    Comment(String, SrcLines),
    /// A verbatim line (e.g. a passed-through CSS `@import`). The `SrcLines`
    /// carry a source-map position in the map-override fields only — a
    /// passed-through `@import` maps to its URL token, as in dart's
    /// `visitCssImport` — and take no part in the trailing-comment rule.
    Raw(String, SrcLines),
    /// A blank-line separator between top-level groups (expanded only).
    Blank,
    /// An at-rule: `@name prelude { body }` (when `has_block`) or
    /// `@name prelude;` (when not). The body holds the bubbled-out child
    /// nodes; bare declarations appear as [`OutNode::AtDecl`].
    AtRule {
        name: String,
        prelude: String,
        body: Vec<OutNode>,
        has_block: bool,
        /// Which dart node class this is (see [`AtRuleKind`]), which `name`
        /// cannot be asked: an interpolated `@#{"media"}` arrives here spelling
        /// `media` and is generic.
        kind: AtRuleKind,
        /// Source lines (`start` = the `{` line or the statement's own line
        /// for the `;` form, `end` = the `}` line or the same) for the
        /// serializer's trailing-comment rule; default = disabled.
        lines: SrcLines,
    },
    /// A module's spliced CSS, tagged with its canonical key so the extend
    /// pass can scope extensions (dart-sass: an `@extend` affects the module's
    /// own CSS and its transitive upstreams, never siblings or downstream).
    /// Emits transparently as its contents.
    ModuleScope {
        key: String,
        nodes: Vec<OutNode>,
    },
    /// A bare declaration emitted directly inside an at-rule body (e.g.
    /// `@font-face { font-family: x; }`).
    AtDecl {
        /// Shared, like [`OutItem::Decl`]'s — this node is repacked from one.
        prop: Rc<str>,
        value: String,
        important: bool,
        /// A custom property (`--x`) whose value is emitted verbatim after the
        /// colon (no inserted space); its leading whitespace is part of `value`.
        custom: bool,
        /// Source lines (only `file` and `end` are meaningful) for the
        /// serializer's trailing-comment rule; default = disabled.
        lines: SrcLines,
        /// Where the emitted VALUE maps back to (dart `valueSpanForMap`,
        /// serialize.dart:390). Source-map only.
        value_span: VarSpan,
    },
    /// Control-only marker (never serialized): the end of a completed top-level
    /// style rule's output group (dart-sass `isGroupEnd`). The next group gets a
    /// blank line even when the group ended in a bubbled at-rule. Consumed by the
    /// next `push_group`; any survivor is skipped by the emitters.
    GroupEnd,
    /// Control-only marker (never serialized): left in an enclosing `@media` body
    /// where a merged nested media rule bubbled out; the outer rule splits its own
    /// children around it.
    MediaHoist,
    /// Control-only marker (never serialized): left where an `@at-root` hoisted a
    /// batch out of one or more enclosing at-rules. `target` is the batch's graft
    /// target (the index of the topmost EXCLUDED at-rule layer — dart
    /// `_trimIncluded`). Each enclosing layer below the target splits around the
    /// marker and passes it outward; the layer whose body sits at the target depth
    /// consumes it — target 0 means the batch re-enters at the document root,
    /// between the outermost layer's segments, while a deeper target grafts INTO
    /// that layer's own body.
    AtRootHoist {
        target: usize,
    },
    /// Control-only marker (never serialized): trailing sentinel after a placed
    /// at-root batch — the next top-level group packs tight against it (no blank
    /// line), and the emitters skip it.
    AtRootPackTight,
}

impl OutNode {
    /// A control-only marker that never serializes: `GroupEnd`, `MediaHoist`,
    /// `AtRootHoist` and `AtRootPackTight`. Such markers may sit between two
    /// nodes without separating them for blank-line purposes.
    pub(crate) fn is_inert_marker(&self) -> bool {
        matches!(
            self,
            OutNode::GroupEnd | OutNode::MediaHoist | OutNode::AtRootHoist { .. } | OutNode::AtRootPackTight
        )
    }

    /// A non-evaluated style rule — a plain-CSS passthrough, an `@at-root`
    /// graft, a reparent shell, etc. It carries no per-complex line breaks and
    /// `extend_base` `usize::MAX`, so the `@extend` pass always applies the
    /// sequential default. Only `selectors`, `items` and `lines` vary across
    /// the call sites; the rest is shared boilerplate.
    pub(crate) fn plain_rule(selectors: Vec<String>, items: Vec<OutItem>, lines: SrcLines) -> OutNode {
        OutNode::Rule {
            selectors: RuleSelectors::Raw(Rc::new(selectors)),
            linebreaks: Vec::new(),
            items,
            lines,
            extend_base: usize::MAX,
        }
    }

    /// A childless at-rule (`@name prelude;`) — no body, no block.
    pub(crate) fn childless_at_rule(name: String, prelude: String, lines: SrcLines) -> OutNode {
        OutNode::AtRule {
            name,
            prelude,
            body: Vec::new(),
            has_block: false,
            // A conditional group rule always has a block, so a childless
            // at-rule is generic whatever it is called: `@#{"media"} (a: 1);`
            // keeps the compressed space a real `@media` would drop.
            kind: AtRuleKind::Generic,
            lines,
        }
    }
}

/// A media query resolved to its final string components, ready to serialize
/// and to merge with nested queries (dart-sass `CssMediaQuery`).
#[derive(Clone, PartialEq, Eq)]
struct ResolvedQuery {
    /// `not`/`only`, already lowercased; `None` for a condition-only query.
    modifier: Option<String>,
    /// The media type (e.g. `screen`); `None` for a condition-only query.
    mtype: Option<String>,
    /// Serialized condition strings (e.g. `(a)`, `not (b)`, `((a) or (b))`).
    conditions: Vec<String>,
    /// Whether the conditions are joined by `and` (true) or `or` (false).
    conjunction_and: bool,
}

/// The result of merging two media queries (dart-sass `MediaQueryMergeResult`).
enum MergeResult {
    /// Mutually exclusive — the merged query selects nothing.
    Empty,
    /// The merge can't be represented as a single query; keep them nested.
    Unrepresentable,
    /// A single merged query.
    Query(ResolvedQuery),
}

/// An item inside a rule block.
#[derive(Clone)]
pub(crate) enum OutItem {
    Decl {
        /// The property name. Shared rather than owned, because a plain
        /// property name (which is nearly all of them) is a single literal in
        /// the AST and this is that literal.
        prop: Rc<str>,
        value: String,
        important: bool,
        /// A custom property (`--x`) whose value is emitted verbatim after the
        /// colon (no inserted space); its leading whitespace is part of `value`.
        custom: bool,
        /// Source lines (only `file` and `end` are meaningful) for the
        /// serializer's trailing-comment rule; default = disabled.
        lines: SrcLines,
        /// Where the emitted VALUE maps back to. dart wraps the serialized
        /// value in `_buffer.forSpan(node.valueSpanForMap, …)`
        /// (serialize.dart:389): normally the value expression's own start, but
        /// the variable's DEFINITION when the value is a bare `$name`
        /// (evaluate.dart:1414 -> `_expressionNode`). Source-map only — this
        /// field can never change a CSS byte.
        value_span: VarSpan,
    },
    Comment(String, SrcLines),
    /// A childless at-rule (`@e f;`) that appears directly inside a style rule:
    /// dart-sass keeps it in the parent block (interleaved with declarations),
    /// unlike a block at-rule which bubbles out to the document root.
    ChildlessAtRule {
        name: String,
        prelude: String,
        /// Whether this is a plain-CSS `@import` written as one — dart's
        /// `CssImport`, which compressed output spells `@import"x.css"` with no
        /// gap. An at-rule that merely RESOLVES to that name (`@#{"import"}`)
        /// is generic in dart and keeps its gap, so this cannot be recovered
        /// from `name`.
        css_import: bool,
        /// Source lines (only `file` and `end` are meaningful) for the
        /// serializer's trailing-comment rule; default = disabled.
        lines: SrcLines,
    },
    /// A style rule nested directly inside another, kept verbatim instead of
    /// flattened. Only produced in plain-CSS mode (a loaded `.css` file).
    NestedRule {
        selectors: Vec<String>,
        /// Per selector, whether it started on its own line in the source:
        /// dart keeps a nested plain-CSS rule's selector list as written
        /// (`e,\n  f {`), like a top-level rule's (`OutNode::Rule`).
        linebreaks: Vec<bool>,
        items: Vec<OutItem>,
        /// Source-map position of the selector's first character (dart maps
        /// `node.selector.span.start`), in the map-override fields only.
        lines: SrcLines,
    },
    /// A block at-rule (`@media`, `@supports`, unknown) nested inside an
    /// already-nested plain-CSS rule, kept in place instead of bubbled —
    /// dart-sass `_hasCssNesting`: once the user opts into native CSS nesting,
    /// at-rules stay where they are. Produced in plain-CSS mode, and for a
    /// `@media` inside a keyframe block, which nests verbatim because a frame is
    /// not a style rule.
    NestedAtRule {
        name: String,
        prelude: String,
        items: Vec<OutItem>,
        /// Which dart node class this is, as for [`OutNode::AtRule`].
        kind: AtRuleKind,
        /// Source lines of the at-rule, as for [`OutNode::AtRule`]: its `@`
        /// keyword's line and column drive the source-map entry.
        lines: SrcLines,
    },
}

/// Which kind of module member an existence predicate (`function-exists`,
/// `mixin-exists`, `global-variable-exists` with a `$module`) queries.
#[derive(Clone, Copy)]
enum MemberKind {
    Function,
    Mixin,
    Variable,
}

/// Where evaluated statements deposit their output. At the top level each
/// statement forms its own blank-separated group; inside a style rule,
/// declarations join the rule's block and nested rules bubble out after it.
/// This is the seam that lets one block executor serve the top level, rule
/// bodies, and every nested-block construct (conditionals, loops, mixins).
/// The enclosing rule's selector list as a sink sees it. A style rule owns a
/// shared handle it can hand to every block it flushes for the price of a
/// refcount; a sink that only has the enclosing selectors as a slice copies
/// them once per block instead.
enum SinkSelectors<'a> {
    Shared(&'a Rc<Vec<String>>),
    Borrowed(&'a [String]),
}

impl<'a> SinkSelectors<'a> {
    fn as_slice(&self) -> &'a [String] {
        match self {
            SinkSelectors::Shared(v) => v.as_slice(),
            SinkSelectors::Borrowed(v) => v,
        }
    }

    fn is_empty(&self) -> bool {
        self.as_slice().is_empty()
    }

    /// A handle to hand to an output node: free for a shared list, one copy for
    /// a borrowed one.
    fn to_shared(&self) -> Rc<Vec<String>> {
        match self {
            SinkSelectors::Shared(v) => Rc::clone(v),
            SinkSelectors::Borrowed(v) => Rc::new(v.to_vec()),
        }
    }
}

enum Sink<'a> {
    Top(&'a mut Vec<OutNode>),
    /// Root-hoisted buffer. `group_ends` is set only for a true `@at-root`
    /// body deposit — a completed style rule then leaves a group-end
    /// sentinel (dart marks isGroupEnd when `_styleRule == null`); generic
    /// at-rule bodies (@media/@supports) keep their own separator logic.
    Rule {
        /// The enclosing rule's resolved selector list, used to build a block
        /// node when the accumulated `items` must be flushed (i.e. when a nested
        /// rule or at-rule interrupts the parent's own declarations).
        selectors: SinkSelectors<'a>,
        /// Per-complex source line-break flags (parallel to `selectors`).
        linebreaks: &'a [bool],
        /// The source rule's brace/end lines, stamped onto every flushed block
        /// fragment (dart keeps the original rule's span on each copy).
        lines: SrcLines,
        items: &'a mut Vec<OutItem>,
        nested: &'a mut Vec<OutNode>,
        /// The at-rule nesting depth of this rule's body (`at_rule_ctx.len()`
        /// at construction): an `@at-root` hoist marker whose batch escapes
        /// this body (target < depth) is transparent to block anchoring, while
        /// one grafting INTO this body (target == depth) is a solid sibling.
        at_depth: usize,
        /// Index in `nested` of the most recently flushed block fragment, so a
        /// later fragment can JOIN it when only escaping hoist markers landed
        /// in between (dart adds both declaration runs to the same style-rule
        /// copy because the escaped batches aren't siblings inside this node).
        flushed: &'a mut Option<usize>,
        /// The `@extend` registration count when this rule's selector was
        /// established (dart `addSelector` timing), carried onto each flushed
        /// [`OutNode::Rule`]. See [`OutNode::Rule::extend_base`].
        extend_base: usize,
    },
    /// The body of a top-level at-rule (no enclosing selector): bare
    /// declarations land here directly as [`OutNode::AtDecl`], interleaved
    /// in source order with bubbled child rules and nested at-rules.
    AtRoot {
        body: &'a mut Vec<OutNode>,
        group_ends: bool,
    },
}

impl Sink<'_> {
    fn is_top(&self) -> bool {
        matches!(self, Sink::Top(_))
    }

    fn is_rule(&self) -> bool {
        matches!(self, Sink::Rule { .. })
    }

    /// Deposit a childless at-rule (`@e f;`). Inside a style rule it joins the
    /// parent's block (interleaved with declarations, in source order); at the
    /// top level or inside an at-rule body it is a bubbled-out `OutNode`.
    fn push_childless_at_rule(&mut self, name: String, prelude: String, lines: SrcLines) {
        match self {
            Sink::Rule { items, .. } => items.push(OutItem::ChildlessAtRule {
                name,
                prelude,
                css_import: false,
                lines,
            }),
            _ => self.push_at_rule(OutNode::childless_at_rule(name, prelude, lines)),
        }
    }

    fn push_comment(&mut self, text: String, lines: SrcLines) {
        // dart-sass strips a `/*# sourceMappingURL=… */` / `/*# sourceURL=… */`
        // loud comment (it generates its own); the `# ` space is required, so
        // `/*#sourceMappingURL…*/`, `/*! … */`, and other names are kept.
        if text.starts_with("# sourceMappingURL=") || text.starts_with("# sourceURL=") {
            // The comment emits nothing, but the statement it occupied still
            // ends a top-level group (dart's serializer writes a blank line
            // before the following node — and, when the stripped comment leads
            // the document, a leading blank). Leave a group-end sentinel so the
            // next top-level group blank-separates; inside a block (or at-root
            // body) the comment vanishes with no separator, as dart does.
            if let Sink::Top(out) = self {
                out.push(OutNode::GroupEnd);
            }
            return;
        }
        match self {
            Sink::Top(out) => {
                let out = &mut **out;
                push_group(out, vec![OutNode::Comment(text, lines)]);
            }
            Sink::Rule { items, .. } => items.push(OutItem::Comment(text, lines)),
            Sink::AtRoot { body, .. } => body.push(OutNode::Comment(text, lines)),
        }
    }

    fn push_item(&mut self, item: OutItem) {
        match self {
            Sink::Rule { items, .. } => items.push(item),
            Sink::AtRoot { body, .. } => match item {
                OutItem::Decl {
                    prop,
                    value,
                    important,
                    custom,
                    lines,
                    value_span,
                } => body.push(OutNode::AtDecl {
                    prop,
                    value,
                    important,
                    custom,
                    lines,
                    value_span,
                }),
                OutItem::Comment(text, lines) => body.push(OutNode::Comment(text, lines)),
                OutItem::ChildlessAtRule {
                    name, prelude, lines, ..
                } => body.push(OutNode::childless_at_rule(name, prelude, lines)),
                // A plain-CSS nested rule reaching an at-root sink becomes a
                // top-level rule carrying its items.
                OutItem::NestedRule {
                    selectors,
                    linebreaks,
                    items,
                    lines,
                } => body.push(OutNode::Rule {
                    selectors: RuleSelectors::Raw(Rc::new(selectors)),
                    linebreaks,
                    items,
                    lines,
                    extend_base: usize::MAX,
                }),
                // Likewise a plain-CSS nested at-rule becomes a top-level one,
                // its items wrapped as bare at-rule children.
                OutItem::NestedAtRule {
                    name,
                    prelude,
                    items,
                    kind,
                    lines,
                } => body.push(OutNode::AtRule {
                    name,
                    prelude,
                    body: items
                        .into_iter()
                        .map(|it| match it {
                            OutItem::Decl {
                                prop,
                                value,
                                important,
                                custom,
                                lines,
                                value_span,
                            } => OutNode::AtDecl {
                                prop,
                                value,
                                important,
                                custom,
                                lines,
                                value_span,
                            },
                            OutItem::Comment(text, lines) => OutNode::Comment(text, lines),
                            OutItem::NestedRule {
                                selectors,
                                linebreaks,
                                items,
                                lines,
                            } => OutNode::Rule {
                                selectors: RuleSelectors::Raw(Rc::new(selectors)),
                                linebreaks,
                                items,
                                lines,
                                extend_base: usize::MAX,
                            },
                            OutItem::ChildlessAtRule {
                                name, prelude, lines, ..
                            } => OutNode::childless_at_rule(name, prelude, lines),
                            OutItem::NestedAtRule {
                                name,
                                prelude,
                                items,
                                kind,
                                lines,
                            } => OutNode::AtRule {
                                name,
                                prelude,
                                body: vec![OutNode::plain_rule(Vec::new(), items, SrcLines::default())],
                                has_block: true,
                                kind,
                                lines,
                            },
                        })
                        .collect(),
                    has_block: true,
                    kind,
                    lines,
                }),
            },
            Sink::Top(_) => {}
        }
    }

    /// Flush the parent rule's accumulated declarations/loud-comments into a
    /// block node, in source order, before a nested rule or at-rule is emitted.
    /// dart-sass splits the parent block around each bubbled child so that a
    /// declaration (or loud comment) following a nested rule appears AFTER that
    /// rule in the output. No-op for non-`Rule` sinks (which never accumulate a
    /// block) and when there are no pending items.
    fn flush_rule_block(&mut self) -> bool {
        if let Sink::Rule {
            selectors,
            linebreaks,
            lines,
            items,
            nested,
            at_depth,
            flushed,
            extend_base,
        } = self
        {
            if !items.is_empty() {
                // A rule whose every complex selector was a dropped bogus
                // combinator has no selectors left, so it emits no block.
                if selectors.is_empty() {
                    items.clear();
                } else {
                    // The rule's block precedes any hoist markers that
                    // accumulated while it was open (the bubbled rules leave
                    // the style rule entirely and follow it in the output);
                    // an `@at-root` graft INTO this body (target == depth) is
                    // a real sibling, so the block stays after it.
                    let insert_at = nested
                        .iter()
                        .position(|n| is_escaping_marker(n, *at_depth))
                        .unwrap_or(nested.len());
                    // Both declaration runs target the same style-rule copy
                    // when only escaped batches landed between them (dart's
                    // entry copy has no following sibling inside this node).
                    if insert_at > 0 && **flushed == Some(insert_at - 1) {
                        if let Some(OutNode::Rule { items: prev, .. }) = nested.get_mut(insert_at - 1) {
                            prev.append(*items);
                            return true;
                        }
                        // (a non-Rule at that index can't happen: `flushed`
                        // only ever records a flushed block fragment)
                    }
                    let rule = OutNode::Rule {
                        selectors: RuleSelectors::Raw(selectors.to_shared()),
                        linebreaks: linebreaks.to_vec(),
                        items: std::mem::take(*items),
                        lines: *lines,
                        extend_base: *extend_base,
                    };
                    nested.insert(insert_at, rule);
                    **flushed = Some(insert_at);
                    return true;
                }
            }
        }
        false
    }

    /// Emit a produced style rule's fully interleaved output (its own block
    /// fragments plus the rules that bubbled out of it, in source order).
    fn emit_style_rule(&mut self, output: Vec<OutNode>, allow_group_end: bool) {
        match self {
            Sink::Top(out) => {
                let out = &mut **out;
                // An `@at-root` chunk hoisted in-place leaves an INTERIOR
                // group-end marker before the resumed parent rule; materialize it
                // into the one blank line dart emits there. A TRAILING marker
                // (nothing resumes) is left untouched — it's the rule's own
                // isGroupEnd, consumed by the next group's `push_group`.
                let output = materialize_interior_group_ends(output);
                // dart-sass isGroupEnd is set only by visitStyleRule, and an
                // INVISIBLE rule (e.g. `@extend`-only, no declarations) never
                // becomes `previous` in _visitChildren — it must not leave a
                // group-end behind, or the next sibling gains a phantom blank
                // line (bootstrap: two @media from consecutive @each rounds).
                let produced = output
                    .iter()
                    .any(|n| !matches!(n, OutNode::Blank | OutNode::AtRootPackTight | OutNode::GroupEnd));
                push_group(out, output);
                // A completed top-level style rule marks its LAST produced
                // node (which may be a bubbled at-rule) as a group end: the
                // next group gets a blank line even after an at-rule —
                // UNLESS the rule's own last child was an invisible empty
                // rule, which owns the group end in dart and never renders;
                // then the next group packs TIGHT (the pack-tight sentinel
                // also suppresses push_group's default blank-after-rule).
                if produced && !out.is_empty() {
                    out.push(if allow_group_end {
                        OutNode::GroupEnd
                    } else {
                        OutNode::AtRootPackTight
                    });
                }
            }
            Sink::Rule { .. } => {
                // Split the enclosing rule's own block around this nested rule.
                self.flush_rule_block();
                if let Sink::Rule { nested, .. } = self {
                    nested.extend(output);
                }
            }
            Sink::AtRoot { body, group_ends } => {
                // For a true `@at-root` body: a completed style rule at the
                // body's own level marks a group end (dart sets isGroupEnd
                // only when `_styleRule == null` — rules flattened out of a
                // wrapper rule arrive inside ONE batch and pack tight); an
                // invisible trailing child packs the next group tight.
                let produced = *group_ends
                    && output
                        .iter()
                        .any(|n| !matches!(n, OutNode::Blank | OutNode::AtRootPackTight | OutNode::GroupEnd));
                body.extend(output);
                if produced {
                    body.push(if allow_group_end {
                        OutNode::GroupEnd
                    } else {
                        OutNode::AtRootPackTight
                    });
                }
            }
        }
    }

    /// Deposit a produced at-rule (or `@at-root` output). At the top level it
    /// forms its own group; inside a style rule it joins the rules that bubble
    /// out to the document root (splitting the parent's own block around it);
    /// inside another at-rule's body it nests.
    fn push_at_rule(&mut self, node: OutNode) {
        match self {
            Sink::Top(out) => {
                let out = &mut **out;
                push_group(out, vec![node]);
            }
            Sink::Rule { .. } => {
                // A hoist marker whose batch ESCAPES this body only matters to
                // an OUTER at-rule's segmenting: the batch leaves this style
                // rule entirely, so its own block is NOT split around it. An
                // `@at-root` graft INTO this body is a real sibling and splits
                // the block like any other bubbled child.
                let depth = match self {
                    Sink::Rule { at_depth, .. } => *at_depth,
                    _ => 0,
                };
                if !is_escaping_marker(&node, depth) {
                    self.flush_rule_block();
                }
                if let Sink::Rule { nested, .. } = self {
                    nested.push(node);
                }
            }
            Sink::AtRoot { body, .. } => body.push(node),
        }
    }
}

/// Options visible to the evaluator (subset of the public `Options`).
pub(crate) struct EvalOptions<'a> {
    pub style: OutputStyle,
    pub importer: Option<&'a dyn Importer>,
    /// Host-defined custom functions (dart-sass `functions`), matched by name.
    pub functions: &'a [crate::host_fn::HostFn],
    /// The entrypoint's source text, for rendering byte-exact diagnostic
    /// snippets. Empty when the embedder does not supply it (diagnostics then
    /// fall back to the legacy one-liner).
    pub source: &'a str,
    /// The entrypoint's file path/URL as it should appear in diagnostics
    /// (e.g. `input.scss`).
    pub url: &'a str,
    /// The directory diagnostic paths are relative to, or `None` to ask the
    /// operating system (see [`crate::Options::cwd`]).
    pub cwd: Option<&'a str>,
    /// The glyph set for snippet/gutter decoration (ASCII under `--no-unicode`).
    pub glyphs: crate::diag::GlyphSet,
    /// Diagnostic handler (dart-sass `logger`). When set, `@warn`/`@debug`/
    /// deprecation warnings are delivered here instead of printed to stderr.
    pub warn: Option<&'a crate::WarnHandler>,
    /// Deprecation ids to drop (dart-sass `silenceDeprecations`), applied
    /// beside `quiet_deps` so they never reach the per-id cap.
    pub silenced_deprecations: &'a [String],
    /// dart-sass `quietDeps`: deprecations raised inside a file this set marks
    /// as a dependency are dropped before they are counted or delivered.
    pub quiet_deps: Option<&'a crate::DependencySet>,
    /// The entry was parsed as plain CSS (`Syntax::Css`): it is emitted as
    /// plain CSS — nesting preserved, `@import "theme"` passed through, no
    /// Sass evaluation — like a `.css` file reached through `@use`.
    pub plain_css: bool,
    /// Whether this compile produces a source map. Gates the variable
    /// definition-span bookkeeping (`var_spans` et al.), which only source-map
    /// emission reads: when false the span chain stays empty and every
    /// span lookup short-circuits to "unknown", so the plain [`crate::compile`]
    /// path pays nothing for it.
    pub source_map: bool,
}

pub(crate) struct Evaluator<'a> {
    scopes: Vec<Scope>,
    /// Definition spans for the bindings in `scopes`, one frame per scope
    /// (dart `Environment._variableNodes`). Pushed/popped in lockstep. Purely
    /// additive: nothing here can change a CSS byte.
    var_spans: Vec<SpanScope>,
    /// Whether each scope in `scopes` is "semi-global" (dart-sass): a control
    /// flow scope (`@for`/`@each`/`@while`/`@if`) that lets a fresh assignment
    /// reach the global scope, but only when every enclosing scope up to the
    /// root is itself semi-global. Rule/mixin/function scopes are not.
    scope_semi_global: Vec<bool>,
    /// Popped scope tables, kept for the next block to use. A block's scope
    /// lives exactly as long as the block unless a closure captured the chain,
    /// so [`pop_scope`](Evaluator::pop_scope) usually holds the only reference
    /// to a table it is about to free — and entering the next block would
    /// immediately allocate another. Bounded by [`SCOPE_POOL_MAX`].
    scope_pool: Vec<Scope>,
    /// The same for the definition-span frames, which are pushed in lockstep
    /// with `scopes` when a source map is being built.
    span_pool: Vec<SpanScope>,
    /// Scratch buffer for serializing one declaration value. Serializing into
    /// a fresh `String` starts at the allocator's minimum block and regrows
    /// once or twice for a value as ordinary as `0 1px 2px rgba(0, 0, 0, .2)`;
    /// this buffer keeps whatever capacity the widest value so far needed, so
    /// the out item's own exactly-sized copy is the only allocation left. One
    /// buffer suffices because serializing a value never re-enters the
    /// evaluator; the values it does NOT serve are the ones that build an owned
    /// string anyway — see [`Evaluator::declared_css`].
    css_buf: String,
    options: EvalOptions<'a>,
    /// Import paths currently being loaded, deepest last. Re-entering one is a
    /// load cycle (dart-sass "This file is already being loaded."); a path that
    /// has finished loading may be imported again (`@import` re-evaluates).
    loading: Vec<String>,
    /// Per-compile `@import` cache (dart-sass ImportCache analogue): keyed by
    /// (url, importing dir), holding (resolved key, syntax, parsed sheet).
    import_cache: HashMap<(String, Option<String>), CachedImport>,
    /// The current file's interned diagnostic id for [`Self::stamp`], or 0
    /// when not yet interned. Every `current_url` assignment resets it.
    current_url_stamp: u32,
    /// User function/mixin scope chains, parallel to `scopes` (dart's
    /// `Environment._functions`/`_mixins`): a definition always lands in the
    /// innermost frame, so a nested `@function`/`@mixin` shadows an outer one
    /// only within its block. A frame holds no table until it has something to
    /// put in it ([`FnFrame`]).
    functions: Vec<FnFrame>,
    mixins: Vec<FnFrame>,
    /// Stack of `@content` blocks, one per active `@include`.
    content_stack: Vec<Option<ContentBlock>>,
    /// Whether we are *directly* executing a mixin body (dart-sass `_inMixin`).
    /// `true` is pushed while a mixin body runs; running a `@content` block or a
    /// function body pushes `false` (those execute in the caller's context), so
    /// `meta.content-exists()` errors there. Empty at the document root.
    in_mixin: Vec<bool>,
    /// The resolved query list of the enclosing `@media` context (empty at the
    /// document root). Used to merge nested `@media` queries.
    media_queries: Vec<ResolvedQuery>,
    /// The resolved selector list of the enclosing style rule, used to resolve
    /// `&` in value position. `None` at the document root (where `&` is `null`).
    /// Each element is one resolved complex selector (space-joined).
    ///
    /// Shared rather than owned: the same list is also the `parents` of every
    /// nested rule and the extender list of every `@extend` in the body, and a
    /// rule resolves its selectors once. Handing out an `Rc` keeps that one list
    /// instead of deep-copying it per reader.
    current_selector: Option<Rc<Vec<String>>>,
    /// Source line-break flags parallel to `current_selector` (whether each
    /// resolved complex selector started on a fresh source line). A nested
    /// rule's complex inherits its parent's flag OR its own part's flag.
    current_linebreaks: Vec<bool>,
    /// Collected `@extend` directives, applied in a post-eval extension pass.
    extends: Vec<PendingExtend>,
    /// The current nested-property-set name prefix (e.g. `font` then `font-x`).
    /// Empty at the document root and inside ordinary rules; a child declaration
    /// emitted while this is non-empty is namespaced as `<prefix>-<name>`.
    decl_prefix: Option<Rc<str>>,
    /// Whether we are evaluating the value of a `@supports` declaration. When
    /// set, `calc()` interiors are NOT simplified (dart-sass keeps
    /// `calc(1 + 2)` literal in `@supports (a: calc(1 + 2))`), matching
    /// dart-sass `_inSupportsDeclaration`.
    in_supports_declaration: bool,
    /// True while evaluating a plain-CSS (`.css`) module's statements: no
    /// function — user-defined or built-in — is invoked there (dart-sass
    /// `plainCss`); calls re-serialize verbatim. CSS calculations still
    /// simplify.
    in_plain_css: bool,
    /// True while the pending configuration is the *implicit* one built from
    /// an `@import`'s visible variables (dart `Configuration.implicit`): an
    /// already-loaded module is then reused silently instead of erroring with
    /// "can't be configured using with".
    config_is_implicit: bool,
    /// The canonical key of the module currently being evaluated (empty for
    /// the root stylesheet) — stamped onto each registered `@extend`.
    current_module: String,
    /// Module dependency edges: user key -> the canonical keys it loads
    /// (via `@use`/`@forward`/`meta.load-css`). An extension whose origin can
    /// reach a module along these edges may rewrite that module's CSS.
    module_deps: RefCell<HashMap<String, std::collections::HashSet<String>>>,
    /// The same load edges in *load order* (for `meta.load-css` subtree
    /// re-emission, which walks dependencies upstream-first).
    module_dep_order: RefCell<HashMap<String, Vec<String>>>,
    /// `meta.load-css` copy scopes: (copy key, base module key). An origin
    /// inside the base's subtree also sees the copy (its extensions apply to
    /// the clone), in addition to the caller-edge reachability.
    load_css_copies: RefCell<Vec<(String, String)>>,
    /// Monotonic counter for unique load-css copy keys.
    copy_counter: std::cell::Cell<usize>,
    /// Queue of merged nested `@media` nodes bubbling out of an enclosing
    /// media rule, taken in order at the [`OutNode::MediaHoist`] markers the
    /// inner rule leaves in the outer body.
    media_hoist: Vec<Vec<OutNode>>,
    /// Batches hoisted by `@at-root` queries, taken in order at the
    /// [`OutNode::AtRootHoist`] markers; each batch is already re-wrapped in the
    /// kept at-rule layers BELOW its graft target and travels outward to it.
    at_root_hoist: std::collections::VecDeque<AtRootBatch>,
    /// The enclosing at-rule layers (outermost first), so `@at-root` queries
    /// can re-wrap their body in the layers the query keeps.
    at_rule_ctx: Vec<AtCtx>,
    /// Source-map position of the innermost enclosing style rule's selector
    /// (its `rule_lines`). A bubbled `@media`/`@at-root` wrapper re-uses this so
    /// the duplicated parent selector maps to the ORIGINAL rule's span (dart
    /// parity); `SrcLines::default()` when not inside a style rule. Used ONLY
    /// for source maps — never affects CSS bytes.
    cur_rule_lines: SrcLines,
    /// The enclosing style rule's `extend_base` (how many `@extend`s were
    /// registered when it was created), inherited by the wrap that re-emits
    /// its selectors inside a nested at-rule — the @media copy of a rule is
    /// created "at the same time" as the rule for dart's addSelector timing.
    cur_rule_extend_base: usize,
    /// Bogus-combinator selectors omitted from the CSS (`.a > + x`): they
    /// still satisfy `@extend` target matching like dart's extend graph.
    bogus_selectors: Vec<String>,
    /// Placeholder-rule selectors seen during eval (module key, selector).
    /// An empty placeholder rule is pruned from the output tree but still
    /// counts as an `@extend` target within the modules the extension sees.
    placeholder_rules: Vec<(String, String)>,
    /// Set while module loads run inside a module-loading `@import`: dart
    /// clones the whole import subtree's CSS at the import site (the same
    /// `_combineCss(clone: true)` as meta.load-css). All loads in the chain
    /// share ONE copy scope key and ONE visited set (a diamond emits its
    /// shared upstream once per import, not once per use edge), and record no
    /// main-tree edge.
    import_clone: Option<(String, std::collections::HashSet<String>)>,
    /// The directory of the file currently being evaluated, used to resolve
    /// relative `@use`/`@forward`/`@import` URLs against the containing file
    /// first (dart-sass resolution order).
    current_file_dir: Option<String>,
    /// The canonical URL of the file currently being evaluated, passed to the
    /// importer as `CanonicalizeContext::containing_url`.
    ///
    /// INVARIANT: tracked in **lockstep** with [`Self::current_file_dir`] — every
    /// site that swaps `current_file_dir` must swap this too, or a relative
    /// `@use`/`@import`/`meta.load-css` resolves against the wrong file. The four
    /// sites: entry init (`Evaluator::new`), `eval_module`, the `@import` enter,
    /// and `enter_origin_file`. (The two are kept separate rather than derived
    /// because `current_file_dir` is also the `@import` cache key.)
    current_canonical: Option<CanonicalUrl>,
    /// The current directory diagnostics are spelled against, resolved at
    /// most once per compile. Only the frame-naming rule in `modules.rs`
    /// reads it, and only to build a display string, but `getcwd` is a real
    /// syscall -- ~10-19 us on macOS against ~0.5 us on Linux -- and it was
    /// being made once per module loaded. `None` means nobody knows one:
    /// either the call failed, or this is a target without `getcwd` and the
    /// host passed nothing.
    cwd_cache: std::cell::OnceCell<Option<std::path::PathBuf>>,
    /// Whether evaluation is inside a `@keyframes` body: frame blocks are not
    /// style rules in dart-sass, so nested at-rules do not bubble out of them
    /// and frame selectors get keyframe normalization (`E` -> `e`).
    in_keyframes: bool,
    /// dart `_inUnknownAtRule`: inside the body of a generic/unknown at-rule
    /// (`@utility`, `@layer`, `@font-face`, vendor `@foo`, …). Bare
    /// declarations are legal there even without an enclosing style rule —
    /// including directly inside a nested `@media` (Tailwind v4's
    /// `@utility x { @media (…) { max-width: …; } }`).
    in_unknown_at_rule: bool,
    /// Whether the most recent CSS-NODE-CREATING statement in the current
    /// body was an EMPTY style rule (extend-only / no declarations). dart
    /// creates a CssStyleRule node even then; being invisible it still OWNS
    /// its group end, which the serializer never sees — so a rule whose LAST
    /// child was such a statement emits no blank-line separator
    /// (`.brand` stays tight after `.nav { %p {…} > .c { @extend %p; } }`).
    /// Statements that create no node (variables, @extend, loads, control
    /// flow shells) leave it untouched.
    last_child_invisible: bool,
    /// dart `_atRootExcludingStyleRule`: inside `@at-root` (before the first
    /// nested style rule) the implicit parent join is disabled — `&` still
    /// resolves against the enclosing rule, but a plain selector stays at the
    /// root instead of nesting under it.
    at_root_excluding_style_rule: bool,
    /// Global variables that were written by an `@import`ed `@forward` merge,
    /// with the source module each came from (by pointer). In dart-sass such
    /// a variable stays bound to its module: re-importing the SAME forwards
    /// must not clobber an intervening assignment (`@import "f"; $a: changed;
    /// @import "f"` keeps `changed`), while a user-defined global IS
    /// overwritten by the first merge — and a forward of the same name from a
    /// DIFFERENT module overrides the previous binding (sass/dart-sass#888).
    forwarded_globals: HashMap<String, usize>,
    /// Built-in modules made available via `@use "sass:<mod>"`, keyed by the
    /// in-scope namespace (default = the part after `sass:`, or the `as ns`
    /// override). The value is the canonical built-in module name (e.g.
    /// `math`) — one of a closed set, so it is borrowed, not owned.
    used_modules: HashMap<String, &'static str>,
    /// Built-in modules brought into scope unprefixed via `@use "sass:<mod>"
    /// as *`. Their members resolve as bare calls/variables.
    star_modules: Vec<&'static str>,
    /// User stylesheet modules brought into scope via `@use "<file>" [as ns]`,
    /// keyed by the in-scope namespace.
    used_user_modules: HashMap<String, Rc<Module>>,
    /// User modules brought into scope unprefixed via `@use "<file>" as *`.
    star_user_modules: Vec<Rc<Module>>,
    /// All user modules loaded so far, keyed by the importer's canonical key so
    /// each file is evaluated once and shared between every `@use`/`@forward`.
    /// Shared so a module's own forwarded sub-modules see the same cache.
    module_cache: Rc<RefCell<HashMap<String, Rc<Module>>>>,
    /// Members re-exported from the module currently being evaluated, collected
    /// from its `@forward` rules. Empty when not evaluating a module.
    forwarded: Forwarded,
    /// Configuration (`@use/@forward ... with`) supplied for the module
    /// currently being evaluated, consumed by its `!default` declarations.
    /// Maps variable name -> (value, is_default_override).
    pending_config: HashMap<String, (Value, bool)>,
    /// The opaque identity of the ORIGINAL explicit configuration the pending
    /// config derives from (0 = none/implicit). dart-sass allows re-loading
    /// an already-loaded module with a configuration that shares the same
    /// original (a `with (...)` distributed through several forwards).
    pending_config_id: usize,
    /// Counter for fresh explicit-configuration identities.
    config_id_counter: std::cell::Cell<usize>,
    /// Config keys actually consumed by a `!default` declaration in the module
    /// currently being evaluated (used to reject unused configuration).
    consumed_config: Vec<String>,
    /// The name of the member whose body is currently executing, as it appears
    /// in a diagnostic stack frame: `root stylesheet` at the entrypoint, or
    /// `<name>()` inside a user mixin/function. dart-sass `_member`.
    member: String,
    /// The diagnostic call stack: one entry per active user callable/import,
    /// recording the call site and the *caller's* member name. dart-sass
    /// `_stack`. Used to render byte-exact stack traces under errors/warnings.
    call_stack: Vec<DiagFrame>,
    /// The file path/URL the statements currently being evaluated came from
    /// (the entrypoint URL, or an imported/used partial's path).
    current_url: String,
    /// The source text of [`Self::current_url`], for rendering snippets that
    /// point into the currently-executing file.
    current_source: Rc<str>,
    /// Per-id count of deprecation warnings already *printed* (capped at 5 each,
    /// dart-sass). Keyed by the deprecation `[id]`.
    deprecations_shown: HashMap<&'static str, u32>,
    /// Total deprecation warnings *omitted* by the per-id cap, summed across
    /// ids; rendered into the aggregate footer at the end of the compile.
    deprecations_omitted: u32,
    /// Per-location dedup: a `(id, url, line, col)` already warned about is not
    /// warned about again (dart-sass collapses identical repeated warnings).
    /// Keyed `(id, message, url, line, col)`. The MESSAGE is part of the
    /// identity because one span can carry two different warnings of the same
    /// id: `call(get-function("percentage"))` is `[global-builtin]` twice, once
    /// naming `meta.call` and once `math.percentage`, and dart prints both.
    deprecations_seen: crate::fxhash::FxHashSet<(&'static str, String, String, usize, usize)>,
    /// Memo over deprecation PROBES: the material a call site would build a
    /// `Deprecation` from, so a repeat can skip the whole path. Sound only
    /// because the dedup insert at [`Self::emit_deprecation`] precedes the
    /// per-id cap: a repeat of an already-seen key is a TOTAL no-op there (it
    /// does not even increment `deprecations_omitted`), so skipping it early
    /// cannot change stderr. Keyed by a fingerprint; the stored material is
    /// compared with `==` on a hit, so a 64-bit collision only costs the slow
    /// path.
    ///
    /// Bounded in BOTH directions, because it retains what it was asked about:
    /// [`Self::DEP_MEMO_MAX`] caps how many entries there can be, and
    /// [`Self::probe_arg_memoizable`] caps what one entry can hold. No `Value`
    /// graph ever enters it.
    dep_memo: HashMap<(u32, u32, u32, u64), DepProbe>,
    /// Small interned ids for source files, stamped into [`SrcLines`] so the
    /// serializer's trailing-comment rule can require same-file adjacency and
    /// the source map can name the file. Keyed by the file's CANONICAL URL —
    /// the resolved path for the filesystem importer, the entry's `url` as
    /// given — not its display URL, so two partials that share a basename stay
    /// two sources (dart's `sources` are canonical URLs too).
    file_ids: HashMap<String, u32>,
    /// Source text per canonical URL, for the map's `sourcesContent`.
    file_texts: HashMap<String, Rc<str>>,
    /// Source-map URL OVERRIDES: a loaded file's canonical URL -> the URL an
    /// importer asked the source map to record for it (`ImporterResult
    /// .source_map_url`). Empty for the filesystem importer / entry file, so the
    /// generated source map is byte-identical unless a custom importer sets it.
    file_map_urls: HashMap<String, String>,
}

/// One frame of the diagnostic call stack: the call site (file + 1-based
/// position) and the name of the member that contained that call.
#[derive(Clone)]
struct DiagFrame {
    url: String,
    pos: Pos,
    /// The member name to print for this frame (`root stylesheet` or `name()`).
    member: String,
    /// Byte length of the call-site span, to size the snippet caret when this
    /// frame is the primary (innermost) one — used by `@error`.
    length: usize,
    /// True for a `@content;` invocation: it appears in the trace, but a
    /// spanless `@error` never attaches to it — dart attaches at the nearest
    /// mixin or function call boundary, through any number of forwarded
    /// content blocks.
    content: bool,
    /// The text of the file the call site is in, for the snippet when this
    /// frame is an `@error`'s boundary. Carried rather than looked up by
    /// `url`: display names are not unique across custom importers.
    source: Rc<str>,
}

/// An evaluated user module: its public members plus the bindings it itself
/// `@use`d (so a `ns.member` lookup can recurse through forwards).
struct Module {
    /// Top-level variables (the module's global scope). Shared and mutable so an
    /// outside `ns.$var: value` assignment updates the module and its own
    /// functions/mixins observe the new value on their next call.
    vars: Scope,
    /// Definition spans for `vars`, in lockstep (dart's module `Environment`
    /// carries its `_variableNodes` the same way). Source-map only.
    var_spans: SpanScope,
    /// Top-level functions/mixins (the module's global frame). Shared by Rc
    /// with the chains the module's own callables captured, so they resolve
    /// each other (and forwarded members merged after evaluation).
    functions: FnScope,
    mixins: FnScope,
    /// Namespaced user modules this module `@use`d (for transitive `ns.fn()`
    /// calls evaluated inside this module's own functions/mixins).
    used_user_modules: HashMap<String, Rc<Module>>,
    star_user_modules: Vec<Rc<Module>>,
    /// Built-in modules this module `@use`d, by namespace, and unprefixed.
    used_builtin_modules: HashMap<String, &'static str>,
    star_builtin_modules: Vec<&'static str>,
    /// Built-in `sass:*` modules re-exported via `@forward`. A `ns.member` that
    /// misses every captured member is retried against these.
    forwarded_builtins: Vec<ForwardedBuiltin>,
    /// For members re-exported via `@forward`, the module they actually live
    /// in (the variable entry also carries the ORIGINAL name): reads, writes
    /// and calls route there so the defining module's environment is live.
    var_origins: HashMap<String, (Rc<Module>, String)>,
    /// Like `var_origins`, but kept even when the module's own same-named
    /// variable SHADOWS the forwarded one: dart reads the own variable but a
    /// namespaced *assignment* still writes through to the forwarded module.
    var_write_origins: HashMap<String, (Rc<Module>, String)>,
    fn_origins: HashMap<String, Rc<Module>>,
    mixin_origins: HashMap<String, Rc<Module>>,
    /// The identity of the original explicit configuration this module was
    /// first evaluated with (0 = none/implicit).
    config_origin: std::cell::Cell<usize>,
    /// Whether this module's CSS has been emitted into the MAIN tree (an
    /// ordinary `@use`/`@forward` load). A module first loaded inside an
    /// `@import`/load-css clone has not — the next plain load emits it.
    emitted_main: std::cell::Cell<bool>,
    /// The module's emitted CSS, captured at first evaluation so an
    /// `@import`-reached module can re-emit it at each import site (dart
    /// clones the module's CSS tree per import).
    css: Vec<OutNode>,
}

impl Module {
    /// Look up a public variable. Names are dash/underscore-insensitive, so an
    /// exact miss falls back to comparing the canonical (dashed) form against
    /// every key. Private members (leading `-`/`_`) are the caller's
    /// responsibility to exclude.
    fn var(&self, name: &str) -> Option<Value> {
        // A forwarded member reads live from its defining module.
        if let Some((m, oname)) = self.var_origin(name) {
            return m.var(&oname);
        }
        let vars = self.vars.borrow();
        if let Some(v) = vars.get(name) {
            return Some(v.clone());
        }
        let norm = normalize_var_name(name);
        vars.iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, v)| v.clone())
    }
    /// The defining module (and original variable name) of a forwarded
    /// variable, dash/underscore-insensitively.
    fn var_origin(&self, name: &str) -> Option<(Rc<Module>, String)> {
        if let Some((m, o)) = self.var_origins.get(name) {
            return Some((Rc::clone(m), o.clone()));
        }
        let norm = normalize_var_name(name);
        self.var_origins
            .iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, (m, o))| (Rc::clone(m), o.clone()))
    }
    /// The write-through target of a forwarded variable (kept even when
    /// shadowed by the module's own same-named variable).
    fn var_write_origin(&self, name: &str) -> Option<(Rc<Module>, String)> {
        if let Some((m, o)) = self.var_write_origins.get(name) {
            return Some((Rc::clone(m), o.clone()));
        }
        let norm = normalize_var_name(name);
        self.var_write_origins
            .iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, (m, o))| (Rc::clone(m), o.clone()))
    }
    /// The defining module of a forwarded function/mixin.
    fn fn_origin(&self, name: &str) -> Option<Rc<Module>> {
        if let Some(m) = self.fn_origins.get(name) {
            return Some(Rc::clone(m));
        }
        let norm = normalize_var_name(name);
        self.fn_origins
            .iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, m)| Rc::clone(m))
    }
    fn mixin_origin(&self, name: &str) -> Option<Rc<Module>> {
        if let Some(m) = self.mixin_origins.get(name) {
            return Some(Rc::clone(m));
        }
        let norm = normalize_var_name(name);
        self.mixin_origins
            .iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, m)| Rc::clone(m))
    }
    fn function(&self, name: &str) -> Option<Rc<UserCallable>> {
        let fns = self.functions.borrow();
        if let Some(f) = fns.get(name) {
            return Some(Rc::clone(f));
        }
        let norm = normalize_var_name(name);
        fns.iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, f)| Rc::clone(f))
    }
    fn mixin(&self, name: &str) -> Option<Rc<UserCallable>> {
        let mixins = self.mixins.borrow();
        if let Some(m) = mixins.get(name) {
            return Some(Rc::clone(m));
        }
        let norm = normalize_var_name(name);
        mixins
            .iter()
            .find(|(k, _)| normalize_var_name(k) == norm)
            .map(|(_, m)| Rc::clone(m))
    }
}

/// A `@content` block plus, when the enclosing `@include` targets a mixin from
/// another module, a snapshot of the call-site environment in which the content
/// must run (dart-sass: a content block closes over its definition site).
struct ContentBlock {
    stmts: Rc<Vec<Stmt>>,
    /// The `using (params)` clause's parameters; `@content(args)` binds its
    /// arguments to these before the block runs.
    params: Option<Rc<ParamList>>,
    /// `Some` only for a cross-module include: the environment to install while
    /// the block runs, so the content resolves against the call site, not the
    /// mixin's module.
    caller_env: Option<Box<SavedModuleEnv>>,
    /// The file the block was written in (the `@include` site's file). The
    /// block runs against it — dart's `@content` frame names the includer's
    /// file, and the block's output maps there — not against the mixin's.
    origin: Option<crate::value::MixinOrigin>,
}

/// The caller-side environment saved while a cross-module member call runs in
/// the callee module's environment.
#[derive(Clone)]
struct SavedModuleEnv {
    scopes: Vec<Scope>,
    /// Definition spans parallel to `scopes` (source-map only).
    var_spans: Vec<SpanScope>,
    scope_semi_global: Vec<bool>,
    functions: Vec<FnFrame>,
    mixins: Vec<FnFrame>,
    used_modules: HashMap<String, &'static str>,
    star_modules: Vec<&'static str>,
    used_user_modules: HashMap<String, Rc<Module>>,
    star_user_modules: Vec<Rc<Module>>,
    /// When set (a cross-module call), the module whose global scope was
    /// installed: `leave_module` writes the (possibly mutated) global scope back
    /// so a `!global` assignment inside the module persists.
    write_back: Option<Rc<Module>>,
}

/// Members a module re-exports via `@forward`, accumulated while it evaluates.
#[derive(Default)]
struct Forwarded {
    vars: HashMap<String, Value>,
    /// Definition spans for `vars`, keyed identically (source-map only): a
    /// forwarded variable keeps pointing at the `$x: <value>` that defined it
    /// in its home module.
    var_spans: HashMap<String, VarSpan>,
    functions: HashMap<String, Rc<UserCallable>>,
    mixins: HashMap<String, Rc<UserCallable>>,
    /// The module each re-exported member actually lives in (with the
    /// member's ORIGINAL name for variables), so calls/assignments through
    /// the forward run against the defining module's environment.
    var_origins: HashMap<String, (Rc<Module>, String)>,
    fn_origins: HashMap<String, Rc<Module>>,
    mixin_origins: HashMap<String, Rc<Module>>,
    /// Built-in `sass:*` modules re-exported via `@forward "sass:x"`.
    builtins: Vec<ForwardedBuiltin>,
    /// For each re-exported member name, the source module it came from (by
    /// pointer). Re-forwarding the SAME module is idempotent (no conflict);
    /// forwarding a same-named member from a DIFFERENT module is a conflict.
    var_src: HashMap<String, *const Module>,
    fn_src: HashMap<String, *const Module>,
    mixin_src: HashMap<String, *const Module>,
}

/// A built-in module re-exported via `@forward "sass:x" [as p-*] [show|hide ...]`,
/// possibly through further `@forward`s of the module that wrote that rule.
#[derive(Clone)]
struct ForwardedBuiltin {
    module: String,
    /// One entry per `@forward` the member passed through, innermost first.
    filters: Vec<ForwardFilter>,
}

/// The `show`/`hide` clause of one `@forward` in a chain, together with the
/// prefix the member is exported under at that point. dart matches `show`/`hide`
/// against the member's name AS THAT RULE EXPORTS IT — `@forward "sass:map" as
/// p-* hide p-get` hides `p-get`, not `get` — which is what the prefix is for.
#[derive(Clone)]
struct ForwardFilter {
    /// The accumulated prefix at this level, canonical and possibly empty.
    prefix: String,
    /// Whether the rule had a `show` clause at all: one that names only
    /// variables still hides every function and mixin.
    has_show: bool,
    /// `show`/`hide` lists of exported function and mixin names.
    show: Option<std::collections::HashSet<String>>,
    hide: Option<std::collections::HashSet<String>>,
    /// The same, for the `$variable` entries of those clauses.
    show_vars: Option<std::collections::HashSet<String>>,
    hide_vars: Option<std::collections::HashSet<String>>,
}

/// Which kind of member a forwarded-built-in lookup is for: `show`/`hide`
/// name variables separately from functions and mixins.
#[derive(Clone, Copy, PartialEq, Eq)]
pub(super) enum ForwardKind {
    Name,
    Var,
}

impl ForwardedBuiltin {
    /// The full prefix the member is exported under.
    fn prefix(&self) -> &str {
        self.filters.last().map_or("", |f| f.prefix.as_str())
    }

    /// Whether a re-exported built-in member (given by its bare, un-prefixed
    /// name) survives every `@forward` it passed through.
    fn visible(&self, bare: &str, kind: ForwardKind) -> bool {
        self.filters.iter().all(|f| {
            let exported = format!("{}{bare}", f.prefix);
            let (show, hide) = match kind {
                ForwardKind::Name => (&f.show, &f.hide),
                ForwardKind::Var => (&f.show_vars, &f.hide_vars),
            };
            if f.has_show {
                show.as_ref().is_some_and(|s| s.contains(&exported))
            } else {
                !hide.as_ref().is_some_and(|h| h.contains(&exported))
            }
        })
    }
}

/// A pending `@extend`, captured during eval and applied after flattening.
struct PendingExtend {
    /// The resolved target simple selector (e.g. `.foo`, `%bar`).
    target: crate::selector::Simple,
    /// The resolved target selector string, for error messages.
    target_str: String,
    /// The enclosing rule's resolved selector list (the extenders), shared with
    /// the rule that registered this `@extend` — see
    /// [`Evaluator::current_selector`].
    extenders: Rc<Vec<String>>,
    /// Source line-break flags parallel to `extenders` (an extend product
    /// inherits its extender's flag, dart's ComplexSelector.lineBreak).
    extender_breaks: Vec<bool>,
    optional: bool,
    /// Whether this `@extend` was registered inside a `@media` context.
    in_media: bool,
    /// The canonical key of the module this `@extend` was written in
    /// (empty for the root stylesheet).
    origin: String,
    pos: Pos,
}

impl<'a> Evaluator<'a> {
    pub(crate) fn new(options: EvalOptions<'a>) -> Self {
        let url = options.url.to_string();
        let entry_canonical = CanonicalUrl::new(options.url);
        let entry_dir = dirname_of(options.url).unwrap_or_default();
        let source: Rc<str> = Rc::from(options.source);
        let file_texts: HashMap<String, Rc<str>> = [(url.clone(), Rc::clone(&source))].into_iter().collect();
        Evaluator {
            member: "root stylesheet".to_string(),
            call_stack: Vec::new(),
            current_url: url,
            current_source: source,
            deprecations_shown: HashMap::default(),
            deprecations_omitted: 0,
            deprecations_seen: crate::fxhash::FxHashSet::default(),
            dep_memo: HashMap::default(),
            file_ids: HashMap::default(),
            file_texts,
            file_map_urls: HashMap::default(),
            scopes: vec![new_scope()],
            // Empty (not one empty frame) when spans aren't tracked: every
            // push/insert/lookup site is guarded, so an empty chain makes the
            // whole bookkeeping a no-op. See `EvalOptions::source_map`.
            var_spans: if options.source_map {
                vec![new_span_scope()]
            } else {
                Vec::new()
            },
            // The global scope is treated as semi-global so a top-level control
            // flow scope (its child) becomes semi-global too.
            scope_semi_global: vec![true],
            scope_pool: Vec::new(),
            span_pool: Vec::new(),
            css_buf: String::new(),
            options,
            loading: Vec::new(),
            import_cache: HashMap::default(),
            current_url_stamp: 0,
            functions: vec![None],
            mixins: vec![None],
            content_stack: Vec::new(),
            in_mixin: Vec::new(),
            media_queries: Vec::new(),
            current_selector: None,
            current_linebreaks: Vec::new(),
            extends: Vec::new(),
            decl_prefix: None,
            in_supports_declaration: false,
            in_plain_css: false,
            config_is_implicit: false,
            forwarded_globals: HashMap::default(),
            current_module: String::new(),
            module_deps: RefCell::new(HashMap::default()),
            module_dep_order: RefCell::new(HashMap::default()),
            load_css_copies: RefCell::new(Vec::new()),
            copy_counter: std::cell::Cell::new(0),
            in_keyframes: false,
            in_unknown_at_rule: false,
            last_child_invisible: false,
            at_root_excluding_style_rule: false,
            import_clone: None,
            // The entry file's containing directory (possibly "" = the
            // CWD-relative root): relative imports resolve against it first,
            // like dart — NOT via an implicit load path.
            current_file_dir: Some(entry_dir),
            // The entry file's canonical URL = its display URL; the FsImporter
            // derives the same search base from its dirname (a bare name like
            // `input.scss` -> "" = CWD, matching `entry_dir`).
            current_canonical: Some(entry_canonical),
            cwd_cache: std::cell::OnceCell::new(),
            media_hoist: Vec::new(),
            at_root_hoist: std::collections::VecDeque::new(),
            at_rule_ctx: Vec::new(),
            cur_rule_lines: SrcLines::default(),
            cur_rule_extend_base: usize::MAX,
            bogus_selectors: Vec::new(),
            placeholder_rules: Vec::new(),
            used_modules: HashMap::default(),
            star_modules: Vec::new(),
            used_user_modules: HashMap::default(),
            star_user_modules: Vec::new(),
            module_cache: Rc::new(RefCell::new(HashMap::default())),
            forwarded: Forwarded::default(),
            pending_config: HashMap::default(),
            pending_config_id: 0,
            config_id_counter: std::cell::Cell::new(0),
            consumed_config: Vec::new(),
        }
    }

    /// Intern the current file's diagnostics URL as a small id for SrcLines.
    /// Parser-produced lines (`file == 0`) become "this file"; a default
    /// (all-zero) value stays disabled.
    fn stamp(&mut self, mut lines: SrcLines) -> SrcLines {
        if lines == SrcLines::default() {
            return lines;
        }
        lines.file = self.intern_current_file();
        lines
    }

    /// Source-map-only position for a construct that takes no part in the
    /// trailing-comment rule: `file`/`start`/`end` stay 0 and only the map
    /// override fields are set. A passed-through plain-CSS `@import` maps to
    /// its URL token (dart `visitCssImport` spans `node.url`); a nested
    /// plain-CSS rule maps to its selector's first character.
    fn map_only_lines(&mut self, pos: Pos) -> SrcLines {
        SrcLines {
            map_file: self.intern_current_file(),
            map_line: pos.line as u32,
            start_col: (pos.col as u32).saturating_sub(1),
            ..SrcLines::default()
        }
    }

    /// The interned diagnostic/source-map file id of the file being evaluated,
    /// assigning one on first use. Interned once per file entry (every
    /// `current_url` assignment resets `current_url_stamp`), so the steady-state
    /// cost is a `u32` check.
    pub(crate) fn intern_current_file(&mut self) -> u32 {
        if self.current_url_stamp != 0 {
            return self.current_url_stamp;
        }
        let next = self.file_ids.len() as u32 + 1;
        let key = self.current_path().to_string();
        let id = *self.file_ids.entry(key).or_insert(next);
        self.current_url_stamp = id;
        id
    }

    /// Emit the `[import]` deprecation for every Sass `@import` rule in a
    /// just-parsed stylesheet, in source order — dart-sass warns while PARSING
    /// a file, so a file's import deprecations all precede anything its body
    /// prints, and a file parsed once (the import cache) warns once however
    /// often it is imported. Plain-CSS imports (`.css`, `url(...)`, media
    /// queries) are not deprecated. Called with the file's context current
    /// (its url, source, and loader frames), before its statements run.
    pub(crate) fn warn_import_rules(&mut self, stmts: &[Stmt]) {
        if !self.diag_enabled() {
            return;
        }
        for d in crate::ast_writer::collect_parse_time_deprecations(stmts) {
            let (dep, pos, length) = match &d {
                crate::ast_writer::ParseTimeDeprecation::Import { pos, length } => {
                    (crate::deprecation::Deprecation::import(), *pos, *length)
                }
                crate::ast_writer::ParseTimeDeprecation::LegacyIf {
                    pos,
                    length,
                    suggestion,
                } => (
                    crate::deprecation::Deprecation::if_function(suggestion.as_deref()),
                    *pos,
                    *length,
                ),
            };
            self.emit_deprecation(&dep, pos, length);
        }
    }

    pub(crate) fn eval_sheet(&mut self, sheet: &Stylesheet, out: &mut Vec<OutNode>) -> Result<(), Error> {
        let plain_css = self.options.plain_css;
        if !plain_css {
            self.warn_import_rules(&sheet.stmts);
        }
        {
            let mut sink = Sink::Top(out);
            // A plain-CSS entry (`.css`) is emitted as plain CSS, like a `.css`
            // module: its `@import "theme";` is a CSS import to pass through,
            // not a Sass file to load (dart-sass evaluates it the same way).
            let r = if plain_css {
                self.exec_css(&sheet.stmts, &[], &mut sink)
            } else {
                self.exec(&sheet.stmts, &[], &mut sink)
            };
            // At the outermost boundary, finalize any error into a rendered
            // diagnostic block (header + snippet + frames) if we have a span.
            if let Err(e) = r {
                let e = self.finalize_error(e);
                self.emit_deprecation_footer();
                return Err(e);
            }
        }
        self.apply_extends(out)?;
        hoist_css_imports(out);
        self.emit_deprecation_footer();
        Ok(())
    }

    /// The source-map `sources` table for the file ids in `order` — the ids the
    /// mappings reference, in order of first appearance (`Mappings::source_ids`).
    /// Only files that produced a mapping appear; a stylesheet with no output
    /// has an empty `sources`, as in dart-sass. Each entry is the file's
    /// canonical URL (an importer's `source_map_url` override wins). When
    /// `include_sources` is set, the parallel `sourcesContent` is built from
    /// the recorded file texts.
    pub(crate) fn source_table(
        &self,
        order: &[u32],
        include_sources: bool,
    ) -> (Vec<String>, Option<Vec<String>>) {
        // Invert the id table once (ids are dense, assigned 1,2,3,…), then
        // index it per source.
        let mut key_of_id: Vec<&str> = vec![""; self.file_ids.len() + 1];
        for (key, &id) in &self.file_ids {
            if let Some(slot) = key_of_id.get_mut(id as usize) {
                *slot = key.as_str();
            }
        }
        let keys: Vec<&str> = order
            .iter()
            .map(|&id| key_of_id.get(id as usize).copied().unwrap_or(""))
            .collect();
        let sources: Vec<String> = keys
            .iter()
            .map(|&key| {
                self.file_map_urls
                    .get(key)
                    .cloned()
                    .unwrap_or_else(|| key.to_string())
            })
            .collect();
        let content = if include_sources {
            Some(
                keys.iter()
                    .map(|&key| {
                        self.file_texts
                            .get(key)
                            .map(|s| s.to_string())
                            .unwrap_or_default()
                    })
                    .collect(),
            )
        } else {
            None
        };
        (sources, content)
    }

    // ---- diagnostic rendering -------------------------------------------

    /// Whether the entrypoint supplied source text (so snippets can render).
    fn diag_enabled(&self) -> bool {
        !self.options.source.is_empty()
    }

    /// Build the diagnostic stack-frame list (innermost first) for a primary
    /// span located at `pos` in `self.current_url`, executed by `self.member`.
    /// This is `[(current file, pos, member)]` followed by the recorded call
    /// stack, outermost last — exactly dart-sass's `_stackTrace`.
    fn frames_for(&self, pos: Pos) -> Vec<DiagFrame> {
        let mut frames = Vec::with_capacity(self.call_stack.len() + 1);
        frames.push(DiagFrame {
            url: self.current_url.clone(),
            pos,
            member: self.member.clone(),
            length: 0,
            content: false,
            source: Rc::clone(&self.current_source),
        });
        frames.extend(self.call_stack.iter().rev().cloned());
        frames
    }

    /// Render the stack-frame list into the column-aligned block dart-sass
    /// appends under a snippet/warning. `indent` is 2 (errors) or 4
    /// (warnings/deprecations).
    fn render_frame_block(&self, frames: &[DiagFrame], indent: usize) -> String {
        // Column-align: pad each `<url> <line>:<col>` field to the longest.
        // The name goes through the frame-naming rule HERE, at the one place
        // a frame becomes text, rather than at each of the places a frame is
        // built: the entry's is whatever the host passed as `Options::url`,
        // which is a path from the binary and a `file://` URL from the JS
        // API, and both have to read as the path dart prints.
        let fields: Vec<String> = frames
            .iter()
            .map(|f| format!("{} {}:{}", self.frame_name(&f.url), f.pos.line, f.pos.col))
            .collect();
        let width = fields.iter().map(String::len).max().unwrap_or(0);
        let pad: String = " ".repeat(indent);
        let mut out = String::new();
        for (i, (field, frame)) in fields.iter().zip(frames).enumerate() {
            if i > 0 {
                out.push('\n');
            }
            out.push_str(&pad);
            out.push_str(field);
            for _ in 0..width.saturating_sub(field.len()) {
                out.push(' ');
            }
            out.push_str("  ");
            out.push_str(&frame.member);
        }
        out
    }

    /// Convert an `Error` into a fully-rendered diagnostic block (header +
    /// snippet + 2-space frame trace), if diagnostics are enabled and the error
    /// carries a position. Idempotent: an already-rendered error is returned
    /// unchanged.
    fn finalize_error(&self, mut e: Error) -> Error {
        if e.rendered.is_some() || !self.diag_enabled() || !e.has_position() {
            return e;
        }
        // An empty span sitting in the file's trailing whitespace belongs at the
        // end of the last line with content, where dart reports it.
        let trimmed = crate::diag::trim_empty_span_to_content(
            &self.current_source,
            crate::diag::Span {
                line: e.line,
                col: e.col,
                length: e.length,
            },
        );
        e.line = trimmed.line;
        e.col = trimmed.col;
        let frames = self.frames_for(Pos {
            line: e.line,
            col: e.col,
        });
        e.rendered = Some(self.render_error_with_frames(&e, &frames));
        e
    }

    /// Build the "expected selector." error for a `@` in a resolved selector:
    /// when the offending column falls inside an interpolation's output the
    /// error renders dart's dual-span "error in interpolated output" block;
    /// when it maps to literal selector text the source column is recovered
    /// by shifting across the interpolations before it.
    fn interp_selector_error(
        &self,
        rule: &Rule,
        sel_str: &str,
        interp_bounds: &InterpBounds,
        at_idx: usize,
    ) -> Error {
        const MSG: &str = "expected selector.";
        let spans = &rule.selector_interp_spans;
        let single_line = !sel_str.contains('\n');
        // Inside an interpolation's output -> dual-span rendering, positioned
        // at the interpolation expression's start.
        let interp_bounds = interp_bounds.as_slice();
        if spans.len() == interp_bounds.len() {
            for (k, &(start, len)) in interp_bounds.iter().enumerate() {
                if at_idx >= start && at_idx < start + len {
                    let (line, col_start, col_end) = spans[k];
                    let pos = Pos {
                        line: line as usize,
                        col: col_start as usize,
                    };
                    let mut e = Error::at(MSG, pos);
                    if self.diag_enabled() {
                        let source = Rc::clone(&self.current_source);
                        let frames = self.frames_for(pos);
                        let mut rendered = format!("Error: {MSG}\n");
                        rendered.push_str(&crate::diag::render_interp_error_snippet(
                            &source,
                            line as usize,
                            col_start as usize,
                            col_end as usize,
                            sel_str,
                            at_idx + 1,
                            // This snippet prints the file in its own header,
                            // so it is a second place a frame becomes text and
                            // needs the same rule. Left out, one message
                            // contradicted itself: a `file://` URL in the
                            // header above the path in the trace below.
                            &self.frame_name(&frames[0].url),
                            self.options.glyphs,
                        ));
                        rendered.push('\n');
                        rendered.push_str(&self.render_frame_block(&frames, 2));
                        e.rendered = Some(rendered);
                    }
                    return e;
                }
            }
        }
        // Literal text: recover the source column by shifting across the
        // interpolations that precede the offending index.
        if single_line
            && spans.len() == interp_bounds.len()
            && spans
                .iter()
                .all(|&(l, _, _)| l as usize == rule.selector_pos.line)
        {
            let mut shift: i64 = 0;
            for (k, &(start, len)) in interp_bounds.iter().enumerate() {
                if at_idx >= start + len {
                    let (_, col_start, col_end) = spans[k];
                    // The source text `#{ ... }` spans from 2 before the
                    // expression start through the closing brace.
                    let src_total = (col_end as i64 + 1) - (col_start as i64 - 2);
                    shift += src_total - len as i64;
                }
            }
            let col = (rule.selector_pos.col as i64 + at_idx as i64 + shift).max(1) as usize;
            return Error::at(
                MSG,
                Pos {
                    line: rule.selector_pos.line,
                    col,
                },
            );
        }
        Error::at(MSG, rule.selector_pos)
    }

    /// How a frame names its file: a path relative to the working directory,
    /// whether the host handed over a path or a `file://` URL. Anything that
    /// does not name a file — a `data:` URL, a custom importer's key — keeps
    /// the display string it already has.
    fn frame_name(&self, url: &str) -> String {
        self.pretty_name(url).unwrap_or_else(|| url.to_string())
    }

    /// Render `Error: <msg>` + the snippet pointing at the innermost frame +
    /// the 2-space-indented frame trace.
    fn render_error_with_frames(&self, e: &Error, frames: &[DiagFrame]) -> String {
        self.render_error_at(e, &frames[0], frames)
    }

    /// Like [`Self::render_error_with_frames`], with the snippet drawn at
    /// `primary` rather than the innermost frame (an error in a content block
    /// points at the `@include` that supplied it, one frame out).
    fn render_error_at(&self, e: &Error, primary: &DiagFrame, frames: &[DiagFrame]) -> String {
        // The frame's own text, not a display-url lookup: two custom-importer
        // files may both display as `foo`.
        let source = Rc::clone(&primary.source);
        // Prefer the primary frame's own span length (set for `@error`'s call
        // site); otherwise the error's recorded length.
        let length = if primary.length > 0 {
            primary.length
        } else {
            e.length
        };
        let span = crate::diag::Span {
            line: primary.pos.line,
            col: primary.pos.col,
            length,
        };
        let mut out = format!("Error: {}\n", e.message);
        out.push_str(&crate::diag::render_snippet(
            &source,
            span,
            &[],
            self.options.glyphs,
        ));
        out.push('\n');
        out.push_str(&self.render_frame_block(frames, 2));
        out
    }

    /// dart's `quietDeps`: the second of the two side-effect-free rejections at
    /// the top of [`Self::emit_deprecation`], hoisted verbatim so a caller can
    /// skip building anything at all. Must stay byte-for-byte that check, and
    /// side-effect-free.
    ///
    /// The FIRST of the two, `diag_enabled`, is a field test and belongs at the
    /// top of a caller's gates. This one does not: with `quiet_deps` set it
    /// pauses the arena and takes a mutex (see
    /// [`crate::DependencySet::is_dependency`]), so it goes last among the
    /// cheap gates — after the name lookups that reject nearly every call — and
    /// a caller that asks it on every function call has made a compile with
    /// `--quiet-deps` measurably slower than one without.
    ///
    /// It must still be asked ABOVE [`Self::dep_memo`], not below it. `quietDeps`
    /// keys on the CANONICAL path, and the memo's key carries only the display
    /// URL, which two canonical files may share: a probe quieted in a dependency
    /// could otherwise answer for the same span in a file that is not one, and
    /// drop its warning.
    fn deprecation_quieted(&self) -> bool {
        match self.options.quiet_deps {
            Some(deps) => deps.is_dependency(self.current_path()),
            None => false,
        }
    }

    /// Ceiling on [`Self::dep_memo`]. A sheet can probe one span with
    /// unboundedly many distinct VALUES, and such probes do not all leave a
    /// matching entry in `deprecations_seen` to bound them against: `@each $c
    /// in <n colours> { whiteness($c) }` records one probe per colour and emits
    /// nothing, because the bare spelling is rejected *below* the memo. Past
    /// the ceiling the memo simply stops learning — every further probe takes
    /// the same path it took before this memo existed, which is slower and
    /// byte-identical. The largest sheet in `bench/corpus` peaks at 70 entries
    /// (measured 2026-09-16), so this is ~58x observed usage.
    ///
    /// The count is only half a bound; [`Self::probe_arg_memoizable`] is the
    /// other half, and without it this number would mean nothing. With both, a
    /// full memo costs about 645 bytes an entry — measured 2026-09-16 on a
    /// generated sheet with 4000 distinct probe sites, +2.46 MB of peak RSS
    /// under the CLI's bump arena, which never reuses a freed block — so ~2.6
    /// MB at the ceiling, against a ~25 MB peak for the largest bench sheet.
    const DEP_MEMO_MAX: usize = 4096;

    /// Whether this exact deprecation probe has already run to completion at
    /// this exact place, making a second run a no-op (see [`Self::dep_memo`]).
    /// A miss records the material and returns `false`; a fingerprint collision
    /// whose stored material differs also returns `false`, so the exact path
    /// still runs.
    ///
    /// The `==` verify is UNCONDITIONAL, not a `debug_assert`: a hash collision
    /// would otherwise drop a warning, and a dropped warning is a parity break
    /// that no release build should be able to reach. The cost of being wrong
    /// is therefore only speed — a colliding probe takes the slow path, and is
    /// not re-memoised either, so it keeps taking it. The behaviour this
    /// protects is locked from the outside as well: one span reached with two
    /// different colours must warn twice, with a different suggestion each time
    /// (`tests/diagnostics.rs`, `a_legacy_color_function_suggests_its_replacement`).
    fn probe_already_done(
        &mut self,
        probe: DepProbePath,
        name: &str,
        module: Option<&str>,
        pos: Pos,
        pos_args: &[Value],
        named: &[(String, Value)],
    ) -> bool {
        // A shape this memo must not retain is not memoised at all: no entry,
        // no fingerprint, straight down the path it took before the memo
        // existed. See [`Self::probe_arg_memoizable`].
        if !pos_args.iter().all(Self::probe_arg_memoizable)
            || !named.iter().all(|(_, v)| Self::probe_arg_memoizable(v))
        {
            return false;
        }
        use std::hash::Hasher;
        let mut h = crate::fxhash::FxHasher::default();
        // The URL's CONTENTS, not merely its length. A key whose stored material
        // turns out to differ is answered `false` and NOT overwritten, so two
        // files whose display URLs are the same length — `src/_a.scss` and
        // `src/_b.scss` — would otherwise fight over one key at the same span,
        // and every repeat in whichever lost would pay the slow path for the
        // rest of the compile.
        h.write(self.current_url.as_bytes());
        h.write_u8(0xff);
        h.write(name.as_bytes());
        match module {
            Some(m) => {
                h.write_u8(1);
                h.write(m.as_bytes());
            }
            None => h.write_u8(0),
        }
        h.write_u8(0xfe);
        for v in pos_args {
            Self::fingerprint_value(&mut h, v);
        }
        h.write_u8(0xfd);
        for (n, v) in named {
            h.write(n.as_bytes());
            Self::fingerprint_value(&mut h, v);
        }
        let key = (probe as u32, pos.line as u32, pos.col as u32, h.finish());
        if let Some(prev) = self.dep_memo.get(&key) {
            return prev.url == self.current_url
                && prev.name == name
                && prev.module.as_deref() == module
                && prev.pos_args == *pos_args
                && prev.named == *named;
        }
        if self.dep_memo.len() < Self::DEP_MEMO_MAX {
            self.dep_memo.insert(
                key,
                DepProbe {
                    url: self.current_url.clone(),
                    name: name.to_string(),
                    module: module.map(str::to_string),
                    pos_args: pos_args.to_vec(),
                    named: named.to_vec(),
                },
            );
        }
        false
    }

    /// Whether an argument of this shape may enter [`Self::dep_memo`] at all.
    ///
    /// The memo RETAINS its arguments, because that is what makes the `==`
    /// verify possible — so an entry count is only a bound if one entry is
    /// bounded too. `Calc`, `Slash`, `Function` and `Mixin` clone their whole
    /// tree, a `List` clones the keyword map of an argument list, and a `Number`
    /// clones its unit lists when they are complex. One large value reached from
    /// many call sites would then be retained once per site: measured
    /// 2026-09-16, a sheet with 4000 `saturate($c)` sites where `$c` is a
    /// 4000-term `calc()` cost the memo **1.19 GB** on top of the 1.80 GB that
    /// sheet already costs without it. `Str` and `Map` clone an `Rc` and so
    /// amplify nothing, but they are refused with the rest: admitting them buys
    /// no speed, and the rule is easier to keep true when it is "only what the
    /// suggestion tables read".
    ///
    /// Which is the reason refusing costs nothing. Every probe reaches here only
    /// after the call itself SUCCEEDED, and
    /// [`crate::builtins::color_function_suggestions`] reads exactly a `Color`
    /// and a `Number`: a channel getter (`red`, `whiteness`, …) has no plain-CSS
    /// overload, so a non-`Color` argument fails the call before this point, and
    /// a legacy adjuster (`saturate($c)`) that does pass through as CSS yields
    /// no suggestion. A refused probe is therefore one that had no warning to
    /// skip. The `[global-builtin]` probes, which are the bulk of the win, pass
    /// no arguments at all and are unaffected.
    ///
    /// The match is exhaustive ON PURPOSE: a new [`Value`] variant must not
    /// default into a memo that retains it, so adding one has to fail the build
    /// here.
    fn probe_arg_memoizable(v: &Value) -> bool {
        match v {
            // A simple unit is a shared `Rc<str>`, cloned by refcount.
            Value::Number(n) => !n.has_complex_units(),
            Value::Color(_) => true,
            Value::Str(_)
            | Value::List(_)
            | Value::Map(_)
            | Value::Bool(_)
            | Value::Null
            | Value::Slash(_, _)
            | Value::Calc(_)
            | Value::Function(_)
            | Value::Mixin(_) => false,
        }
    }

    /// Fold a value into a probe fingerprint. Deliberately COARSE for the
    /// composite variants: the `==` verify in [`Self::probe_already_done`] is
    /// what makes the memo exact, and a coarse fingerprint only ever costs a
    /// trip down the slow path. Numbers are hashed by `to_bits()` (not `==` on
    /// the float) WITH their unit, because `red(1px)`, `red(1)` and
    /// `red(1.0000000000000002)` render three different `Recommendation:` lines.
    ///
    /// Only `Number` and `Color` can reach it, since
    /// [`Self::probe_arg_memoizable`] refuses the rest before any hashing. The
    /// other arms stay because coarse-but-verified is the safe default: widening
    /// that gate would cost hash quality here, never correctness.
    fn fingerprint_value(h: &mut crate::fxhash::FxHasher, v: &Value) {
        use std::hash::{Hash, Hasher};
        std::mem::discriminant(v).hash(h);
        match v {
            Value::Number(n) => {
                h.write_u64(n.value.to_bits());
                h.write(n.unit().as_bytes());
            }
            Value::Color(c) => {
                h.write_u64(c.r.to_bits());
                h.write_u64(c.g.to_bits());
                h.write_u64(c.b.to_bits());
                h.write_u64(c.a.to_bits());
                match &c.modern {
                    None => h.write_u8(0),
                    Some(m) => {
                        h.write_u8(1);
                        std::mem::discriminant(&m.space).hash(h);
                        for ch in m.channels.iter().chain(std::iter::once(&m.alpha)) {
                            match ch {
                                Some(x) => h.write_u64(x.to_bits()),
                                None => h.write_u8(0),
                            }
                        }
                    }
                }
            }
            Value::Str(s) => {
                h.write(s.text.as_bytes());
                h.write_u8(s.quoted as u8);
            }
            Value::Bool(b) => h.write_u8(*b as u8),
            Value::Null => {}
            _ => {}
        }
    }

    /// Emit a deprecation warning at `pos` (caret length `len`): the header
    /// block + a snippet pointing at the deprecated construct + a 4-space stack
    /// trace + a trailing blank line. Honours dart-sass's per-location dedup and
    /// per-id cap of 5 (further occurrences are counted into the aggregate
    /// footer rendered by [`Self::emit_deprecation_footer`]). No-op when
    /// diagnostics are disabled.
    /// Emit whatever deprecations a call to `name` carries. `module` is the
    /// namespace it was written with, if any: a GLOBAL built-in with a `sass:*`
    /// equivalent is deprecated for being global, while `feature-exists` is
    /// deprecated whichever way it is spelled.
    pub(super) fn emit_call_deprecations(&mut self, name: &str, module: Option<&str>, pos: Pos, len: usize) {
        // Both registries are keyed by the canonical spelling: `_` and `-` are
        // one character in a Sass identifier, and dart deprecates `map_get(…)`
        // exactly as it deprecates `map-get(…)`.
        let canonical = if name.contains('_') {
            Cow::Owned(name.replace('_', "-"))
        } else {
            Cow::Borrowed(name)
        };
        let name = canonical.as_ref();
        // Cheapest gate first: this runs on EVERY call, and all but a handful of
        // them deprecate nothing. `global_builtin_replacement` is still asked
        // about the already-canonicalised name, exactly as before (it
        // canonicalises internally too), and the emission ORDER below is
        // unchanged: global-builtin, then feature-exists.
        if !self.diag_enabled() {
            return;
        }
        let replacement = if module.is_none() {
            crate::builtins::global_builtin_replacement(name)
        } else {
            None
        };
        let feature_exists = name == "feature-exists" && module.map_or(true, |m| m == "meta");
        if replacement.is_none() && !feature_exists {
            return;
        }
        // Only now the gate that can take a lock: a name nothing deprecates has
        // already gone home, so `--quiet-deps` costs a mutex per WARNING, as it
        // did before this hoist, not one per call.
        if self.deprecation_quieted() {
            return;
        }
        if self.probe_already_done(DepProbePath::Call, name, module, pos, &[], &[]) {
            return;
        }
        if let Some(replacement) = replacement {
            let dep = crate::deprecation::Deprecation::global_builtin(replacement);
            self.emit_deprecation(&dep, pos, len);
        }
        if feature_exists {
            self.emit_deprecation(&crate::deprecation::Deprecation::feature_exists(), pos, len);
        }
    }

    /// Emit the `[color-functions]` deprecation for a call that has just
    /// SUCCEEDED. dart raises it from inside the function, after its arguments
    /// are validated and from their VALUES, so it belongs after the dispatch:
    /// `lighten(3, 10%)` errors and warns about nothing, and one `lighten($c,
    /// 10%)` in a mixin included with two colours warns twice, with a different
    /// suggestion each time.
    pub(super) fn emit_color_function_deprecation(
        &mut self,
        name: &str,
        module: Option<&str>,
        pos: Pos,
        len: usize,
        pos_args: &[Value],
        named: &[(String, Value)],
    ) {
        // Only `sass:color` has these members; every other module's call is
        // someone else's business.
        if module.is_some_and(|m| m != "color") {
            return;
        }
        // Cheap gates before any colour maths, cheapest first: nothing
        // downstream of here has a side effect, so a field test and two name
        // lookups can run ahead of it, and a probe already made at this span
        // with these VALUES is a no-op (see `dep_memo`). `deprecation_quieted`
        // sits after the name gate because it can take a lock, and above the
        // memo because it reads the canonical path the memo's key omits.
        if !self.diag_enabled() {
            return;
        }
        // `[color-module-compat]` shares this entry point because it shares the
        // precondition — a `sass:color` call that SUCCEEDED, judged by its
        // argument values — and because every dispatch site that can reach a
        // module member already calls here. The two ids never both fire: their
        // name sets are disjoint (`grayscale`/`invert`/`opacity`/`alpha` against
        // the channel getters and legacy adjusters).
        if let Some(module) = module {
            self.emit_color_module_compat(name, module, pos, len, pos_args, named);
        }
        if !crate::builtins::color_function_deprecates(name) {
            return;
        }
        if self.deprecation_quieted() {
            return;
        }
        if self.probe_already_done(DepProbePath::ColorFunction, name, module, pos, pos_args, named) {
            return;
        }
        // And a bare name that is no global built-in dispatched as a plain CSS
        // function, not as the member it shares a name with: `whiteness` and
        // `blackness` live ONLY on `sass:color`, so `whiteness(#abc)` is
        // nobody's call and deprecates nothing.
        if module.is_none() && !crate::builtins::is_builtin(name) {
            return;
        }
        let Some(suggestions) = crate::builtins::color_function_suggestions(name, pos_args, named) else {
            return;
        };
        // dart names the function the way the call REACHED it: `color.red()`
        // through the module (under any namespace, star or forward), `red()`
        // as the global.
        let qualified = if module.is_some() {
            format!("color.{name}")
        } else {
            name.to_string()
        };
        let dep = crate::deprecation::Deprecation::color_functions(&qualified, &suggestions);
        self.emit_deprecation(&dep, pos, len);
    }

    /// Emit `[color-module-compat]` for a `sass:color` MEMBER call that has just
    /// succeeded by taking a plain-CSS filter path: `color.grayscale(1)` is
    /// `filter: grayscale(1)` written the long way, and dart is removing that
    /// spelling from the module. The global `grayscale(1)` is not deprecated at
    /// all — there the CSS filter is the whole meaning of the call (#122) — so
    /// the caller passes the module it was reached through, and `@use
    /// "sass:color" as *` counts: the member shadows the global, so the warning
    /// follows the member, not the syntax.
    ///
    /// Which calls took that path is not re-decided here: `module_filter_arg`
    /// and `ms_filter_args` are the dispatcher's own predicates. Keying on the
    /// RESULT would have been wrong in a way that is easy to miss —
    /// `color.ie-hex-str()` also returns an unquoted string and deprecates
    /// nothing.
    fn emit_color_module_compat(
        &mut self,
        name: &str,
        module: &str,
        pos: Pos,
        len: usize,
        pos_args: &[Value],
        named: &[(String, Value)],
    ) {
        if module != "color" || !matches!(name, "grayscale" | "invert" | "opacity" | "alpha") {
            return;
        }
        // The gates that can take a lock or hash the arguments, above the two
        // allocations a message costs and in the same order as the sibling's. A
        // call of one of these four names that turns out not to be a filter call
        // is memoised too, and says nothing either way.
        if self.deprecation_quieted() {
            return;
        }
        if self.probe_already_done(
            DepProbePath::ColorModuleCompat,
            name,
            Some(module),
            pos,
            pos_args,
            named,
        ) {
            return;
        }
        let dep = if name == "alpha" {
            let Some(args) = crate::builtins::ms_filter_args(pos_args, named) else {
                return;
            };
            crate::deprecation::Deprecation::color_module_compat_ms_filter(&crate::builtins::ms_filter_text(
                &args,
            ))
        } else {
            let Some((crate::builtins::ModuleFilterArg::Filter, arg)) =
                crate::builtins::module_filter_arg(name, pos_args, named)
            else {
                return;
            };
            crate::deprecation::Deprecation::color_module_compat_number(
                name,
                &arg.to_css(false),
                &crate::builtins::plain_filter_text(name, arg),
            )
        };
        self.emit_deprecation(&dep, pos, len);
    }

    pub(super) fn emit_deprecation(&mut self, dep: &crate::deprecation::Deprecation, pos: Pos, len: usize) {
        if !self.diag_enabled() {
            return;
        }
        // dart's `quietDeps`: a deprecation raised inside a dependency is
        // dropped HERE, before the per-id cap, so silenced warnings neither
        // consume the five visible slots nor count towards the "N repetitive
        // deprecation warnings omitted" footer.
        if let Some(deps) = self.options.quiet_deps {
            if deps.is_dependency(self.current_path()) {
                return;
            }
        }
        // `silenceDeprecations` drops by id, in the same place and for the
        // same reason: filtering further out silences the warnings but still
        // tallies them, so the footer reports omissions the caller asked not
        // to hear about. dart prints nothing at all.
        if self.options.silenced_deprecations.iter().any(|id| id == dep.id) {
            return;
        }
        // Per-location dedup: the SAME warning at the same place fires once.
        // What makes it the same one is everything it SAYS, not just its id:
        // `call(get-function("percentage"))` is two different
        // `[global-builtin]` warnings at one span (one naming `meta.call`, one
        // `math.percentage`), and `[call-string]` has a static message whose
        // `Recommendation:` line carries the name — so one `call($n)` invoked
        // with two names is two warnings. dart prints both, in both cases.
        let key = (
            dep.id,
            dep.render_header(),
            self.current_url.clone(),
            pos.line,
            pos.col,
        );
        if !self.deprecations_seen.insert(key) {
            return;
        }
        let count = self.deprecations_shown.entry(dep.id).or_insert(0);
        if *count >= 5 {
            self.deprecations_omitted += 1;
            return;
        }
        *count += 1;

        let frames = self.frames_for(pos);
        let span = crate::diag::Span {
            line: pos.line,
            col: pos.col,
            length: len,
        };
        let source = Rc::clone(&self.current_source);
        let mut block = dep.render_header();
        block.push_str(&crate::diag::render_snippet(
            &source,
            span,
            &[],
            self.options.glyphs,
        ));
        block.push('\n');
        block.push_str(&self.render_frame_block(&frames, 4));
        let formatted = format!("{block}\n");
        self.emit_diag(crate::WarnEvent {
            kind: crate::WarnKind::Warn,
            deprecation: true,
            deprecation_id: dep.id,
            message: &dep.message,
            formatted: &formatted,
            url: &self.current_url,
            line: pos.line,
            path: self.current_path(),
        });
    }

    /// Emit the aggregate "N repetitive deprecation warnings omitted" footer at
    /// the end of the compile, if the per-id cap dropped any warnings.
    fn emit_deprecation_footer(&self) {
        if self.deprecations_omitted == 0 {
            return;
        }
        let msg = format!(
            "{} repetitive deprecation warnings omitted.",
            self.deprecations_omitted
        );
        // The second line is dart's, copied verbatim, and it advertises a flag
        // sasso does not have. That is deliberate rather than an oversight: the
        // footer is part of the stderr parity contract (locked by
        // `tests/fixtures/diagnostics/deprecation-cap-{omitted,per-id}.stderr`),
        // so it says what dart says. In dart `--verbose` lifts the per-id cap
        // of 5 that produced this count, and drops this footer along with it --
        // on `deprecation-cap-omitted.scss`, dart-sass 1.103.1 prints 5
        // warnings plus this line without the flag and 8 warnings with no
        // footer under it (verified 2026-09-16). sasso implements only the
        // capped half, so the advice here is unreachable, not wrong. Adding the
        // flag is a CLI feature with fixtures of its own, not a fix to this
        // line.
        let formatted = format!("WARNING: {msg}\nRun in verbose mode to see all warnings.\n");
        self.emit_diag(crate::WarnEvent {
            kind: crate::WarnKind::Warn,
            deprecation: true,
            deprecation_id: "",
            message: &msg,
            formatted: &formatted,
            url: "",
            line: 0,
            // An aggregate over several files: no single origin (like `url`).
            path: "",
        });
    }

    /// Enter a user callable (mixin/function) for diagnostics: record a stack
    /// frame at `call_pos` (caret length `call_len`) attributed to the *current*
    /// member, then make `new_member` the current member. Returns the previous
    /// member name, to be restored by [`Self::leave_call`].
    /// An error against the innermost CALL SITE — the frame a caller pushed
    /// before it bound arguments or ran a body. Unpositioned when there is no
    /// call in progress (a top-level statement raised it).
    ///
    /// The call site is in the CALLER's file, which by now may not be the
    /// current one (a cross-file call has already switched context), so the
    /// block is rendered here, against that frame's own text.
    /// An error about a construct that has a `declaration` to point back at,
    /// reported at `pos` with the frames as they stand — for a failure that
    /// happens BEFORE the callable is entered, so its own frame is not on the
    /// stack (dart shows only the caller's).
    pub(super) fn error_with_declaration_at(
        &self,
        message: impl Into<String>,
        pos: Pos,
        length: usize,
        decl: &Declared<'_>,
    ) -> Error {
        let message = message.into();
        // The stack AS IT STANDS, without the synthetic frame naming the
        // member being entered: this error happens before the callable runs,
        // so dart's trace starts at the caller.
        let frames: Vec<DiagFrame> = self.call_stack.iter().rev().cloned().collect();
        let frames = if frames.is_empty() {
            self.frames_for(pos)
        } else {
            frames
        };
        let rendered = match self.declaration_block(&message, pos, length, decl, &frames) {
            Some(rendered) => Some(rendered),
            // The two spans cannot share a block. Draw the primary one HERE,
            // against the frames as they stand: leaving the error unrendered
            // would defer that until the `@include` arm has popped this call,
            // and the trace would be built from whatever is current then.
            None if self.diag_enabled() && !frames.is_empty() => {
                let mut block = format!("Error: {message}\n");
                block.push_str(&crate::diag::render_snippet(
                    &frames[0].source,
                    crate::diag::Span {
                        line: pos.line,
                        col: pos.col,
                        length,
                    },
                    &[],
                    self.options.glyphs,
                ));
                block.push('\n');
                block.push_str(&self.render_frame_block(&frames, 2));
                Some(block)
            }
            None => None,
        };
        let mut e = Error::at(message, pos).with_length(length);
        e.rendered = rendered;
        e
    }

    /// The rendered two-span block, or `None` when this diagnostic cannot have
    /// one: diagnostics off, no declaration position, or two spans the renderer
    /// cannot keep apart (see [`Self::spans_share_a_block`]).
    fn declaration_block(
        &self,
        message: &str,
        pos: Pos,
        length: usize,
        decl: &Declared<'_>,
        frames: &[DiagFrame],
    ) -> Option<String> {
        if !self.diag_enabled() || !decl.pos.is_known() || frames.is_empty() {
            return None;
        }
        let (decl_url, decl_source) = match decl.origin {
            Some(o) => (o.diag_url.clone(), Rc::clone(&o.source)),
            None => (frames[0].url.clone(), Rc::clone(&frames[0].source)),
        };
        let decl_span = crate::diag::Span {
            line: decl.pos.line,
            col: decl.pos.col,
            length: decl.length,
        };
        let call_span = crate::diag::Span {
            line: pos.line,
            col: pos.col,
            length,
        };
        if !Self::spans_share_a_block(
            (&frames[0].url, &frames[0].source, call_span),
            (&decl_url, &decl_source, decl_span),
        ) {
            return None;
        }
        let mut rendered = format!("Error: {message}\n");
        // A third and fourth place a frame becomes text: this snippet prints
        // a header per file group. The SOURCE stays part of the grouping key
        // (see `render_labelled_snippet`), so naming the groups for display
        // cannot draw one file's span against another's lines.
        let call_name = self.frame_name(&frames[0].url);
        let decl_name = self.frame_name(&decl_url);
        rendered.push_str(&crate::diag::render_labelled_snippet(
            &call_name,
            &frames[0].source,
            call_span,
            "invocation",
            &[crate::diag::Secondary {
                url: &decl_name,
                source: &decl_source,
                span: decl_span,
                label: "declaration",
            }],
            &[],
            self.options.glyphs,
        ));
        rendered.push('\n');
        rendered.push_str(&self.render_frame_block(frames, 2));
        Some(rendered)
    }

    /// [`Self::error_at_call`] with dart's SECOND span: the `declaration` the
    /// failure is measured against, in the file it was written in.
    ///
    /// Falls back to the plain single-span block for the one pair of spans the
    /// renderer cannot keep apart (see [`Self::spans_share_a_block`]).
    pub(super) fn error_at_call_with_declaration(
        &self,
        message: impl Into<String>,
        decl: &Declared<'_>,
    ) -> Error {
        let message = message.into();
        let Some(frame) = self.call_stack.last() else {
            return Error::unpositioned(message);
        };
        if !self.diag_enabled() || !decl.pos.is_known() {
            return self.error_at_call(message);
        }
        let (decl_url, decl_source) = match decl.origin {
            Some(o) => (o.diag_url.clone(), Rc::clone(&o.source)),
            None => (frame.url.clone(), Rc::clone(&frame.source)),
        };
        let decl_span = crate::diag::Span {
            line: decl.pos.line,
            col: decl.pos.col,
            length: decl.length,
        };
        let call_span = crate::diag::Span {
            line: frame.pos.line,
            col: frame.pos.col,
            length: frame.length,
        };
        if !Self::spans_share_a_block(
            (&frame.url, &frame.source, call_span),
            (&decl_url, &decl_source, decl_span),
        ) {
            return self.error_at_call(message);
        }
        let mut e = Error::at(message.clone(), frame.pos).with_length(frame.length);
        let mut frames = Vec::with_capacity(self.call_stack.len() + 1);
        frames.push(DiagFrame {
            url: frame.url.clone(),
            pos: frame.pos,
            member: self.member.clone(),
            length: frame.length,
            content: false,
            source: Rc::clone(&frame.source),
        });
        frames.extend(self.call_stack.iter().rev().cloned());
        let mut rendered = format!("Error: {message}\n");
        let call_name = self.frame_name(&frame.url);
        let decl_name = self.frame_name(&decl_url);
        rendered.push_str(&crate::diag::render_labelled_snippet(
            &call_name,
            &frame.source,
            call_span,
            "invocation",
            &[crate::diag::Secondary {
                url: &decl_name,
                source: &decl_source,
                span: decl_span,
                label: "declaration",
            }],
            &[],
            self.options.glyphs,
        ));
        rendered.push('\n');
        rendered.push_str(&self.render_frame_block(&frames, 2));
        e.rendered = Some(rendered);
        e
    }

    /// Whether the call and the declaration can be drawn in one rendered
    /// block. They can, unless they sit in the SAME file with OVERLAPPING
    /// lines AND both draw an ARM: dart nests a second arm column and crosses
    /// the two for that shape, which the renderer cannot do. Anything less
    /// overlapping is drawable — two spans on one line stack their underline
    /// rows, and a span that stays within its line sits inside an arm's range
    /// with the arm running down the column beside it. A file is identified by
    /// its text as well as its display url: two custom-importer files can
    /// share a display name.
    fn spans_share_a_block(
        call: (&str, &str, crate::diag::Span),
        decl: (&str, &str, crate::diag::Span),
    ) -> bool {
        let ((call_url, call_source, call_span), (decl_url, decl_source, decl_span)) = (call, decl);
        if call_url != decl_url || call_source != decl_source {
            return true;
        }
        let (call_first, call_last) = crate::diag::span_line_range(call_source, call_span);
        let (decl_first, decl_last) = crate::diag::span_line_range(decl_source, decl_span);
        let overlapping = call_first <= decl_last && decl_first <= call_last;
        let both_arms = call_first != call_last && decl_first != decl_last;
        !(overlapping && both_arms)
    }

    pub(super) fn error_at_call(&self, message: impl Into<String>) -> Error {
        let Some(frame) = self.call_stack.last() else {
            return Error::unpositioned(message);
        };
        let mut e = Error::at(message, frame.pos).with_length(frame.length);
        if self.diag_enabled() {
            // The innermost trace line names the CALLEE at the call's position
            // (dart: `file 2:9  f()`), and reads its snippet from the caller's
            // file; the frames under it are the stack as it stands.
            let mut frames = Vec::with_capacity(self.call_stack.len() + 1);
            frames.push(DiagFrame {
                url: frame.url.clone(),
                pos: frame.pos,
                member: self.member.clone(),
                length: frame.length,
                content: false,
                source: Rc::clone(&frame.source),
            });
            frames.extend(self.call_stack.iter().rev().cloned());
            e.rendered = Some(self.render_error_at(&e, &frames[0], &frames));
        }
        e
    }

    fn enter_call(&mut self, call_pos: Pos, call_len: usize, new_member: &str) -> String {
        self.push_frame(call_pos, call_len, new_member, false)
    }

    /// [`Self::enter_call`] for a `@content;` invocation: the frame shows in
    /// the trace under the `@content` member but is never an `@error`
    /// boundary (see [`DiagFrame::content`]).
    pub(super) fn enter_content_call(&mut self, call_pos: Pos) -> String {
        self.push_frame(call_pos, "@content".len(), "@content", true)
    }

    fn push_frame(&mut self, call_pos: Pos, call_len: usize, new_member: &str, content: bool) -> String {
        self.call_stack.push(DiagFrame {
            url: self.current_url.clone(),
            pos: call_pos,
            member: self.member.clone(),
            length: call_len,
            content,
            source: Rc::clone(&self.current_source),
        });
        std::mem::replace(&mut self.member, new_member.to_string())
    }

    /// Leave a user callable: pop its diagnostic frame and restore `member`.
    fn leave_call(&mut self, saved_member: String) {
        self.call_stack.pop();
        self.member = saved_member;
    }

    /// The canonical URL of the stylesheet being evaluated (the resolved path
    /// for a filesystem file), for [`crate::WarnEvent::path`]; `""` if unknown.
    fn current_path(&self) -> &str {
        self.current_canonical.as_ref().map(|c| c.as_str()).unwrap_or("")
    }

    /// Deliver a diagnostic to the embedder's handler (dart-sass `logger`), or —
    /// when none is set — print its `formatted` block to stderr (preserving the
    /// exact native output, since the handler-less path mirrors the old
    /// `eprintln!`s byte-for-byte).
    fn emit_diag(&self, ev: crate::WarnEvent<'_>) {
        match self.options.warn {
            Some(handler) => {
                // Run the embedder's handler outside the arena scope, so
                // whatever it retains from the event (a buffered log, a list
                // of warnings) is allocated by the system allocator and
                // outlives this compile's arena reset — the same reason
                // importer calls are paused. Inside the scope a `String` the
                // handler grows would land in the arena and dangle afterwards.
                let _paused = crate::arena::pause();
                handler(&ev);
            }
            None => eprintln!("{}", ev.formatted),
        }
    }

    /// Execute a `@warn`: emit `WARNING: <message>` + the 4-space-indented stack
    /// trace + a trailing blank line to stderr. The message is the string value
    /// unquoted; exit code is unaffected.
    fn emit_warn(&mut self, value: &Expr, pos: Pos) -> Result<(), Error> {
        let v = self.eval_expr(value)?;
        let msg = v.to_message();
        let formatted = if self.diag_enabled() {
            let frames = self.frames_for(pos);
            format!("WARNING: {}\n{}\n", msg, self.render_frame_block(&frames, 4))
        } else {
            format!("WARNING: {msg}")
        };
        self.emit_diag(crate::WarnEvent {
            kind: crate::WarnKind::Warn,
            deprecation: false,
            deprecation_id: "",
            message: &msg,
            formatted: &formatted,
            url: &self.current_url,
            line: pos.line,
            path: self.current_path(),
        });
        Ok(())
    }

    /// Execute a `@debug`: emit `<path>:<line> DEBUG: <value>` to stderr (the
    /// value serialized as in CSS, a string unquoted). No snippet, no frames.
    fn emit_debug(&mut self, value: &Expr, pos: Pos) -> Result<(), Error> {
        let v = self.eval_expr(value)?;
        let msg = v.to_message();
        let url = self.current_url.clone();
        let formatted = if self.diag_enabled() {
            format!("{url}:{} DEBUG: {msg}", pos.line)
        } else {
            format!("DEBUG: {msg}")
        };
        self.emit_diag(crate::WarnEvent {
            kind: crate::WarnKind::Debug,
            deprecation: false,
            deprecation_id: "",
            message: &msg,
            formatted: &formatted,
            url: &url,
            line: pos.line,
            path: self.current_path(),
        });
        Ok(())
    }

    /// Build the error for an `@error`: its message is the serialized argument
    /// (a string keeps its quotes). The snippet points at the innermost active
    /// call site (so an `@error` inside a mixin highlights the `@include`), or
    /// at the `@error` statement itself when there is no enclosing call. dart's
    /// "unspanned exception attaches at the boundary" rule.
    fn build_error(&mut self, value: &Expr, pos: Pos, length: usize) -> Error {
        let msg = match self.eval_expr(value) {
            Ok(v) => v.to_inspect_message(),
            Err(e) => return e,
        };
        if !self.diag_enabled() {
            return Error::unpositioned(msg);
        }
        // The @error throws unspanned; the nearest enclosing call boundary
        // attaches its span. With an active call stack, the snippet points at
        // the innermost call site and the trace is the callers only (the
        // @error's own frame is dropped). At the root, the @error span is used.
        let frames: Vec<DiagFrame> = if self.call_stack.is_empty() {
            vec![DiagFrame {
                url: self.current_url.clone(),
                pos,
                member: self.member.clone(),
                length,
                content: false,
                source: Rc::clone(&self.current_source),
            }]
        } else {
            self.call_stack.iter().rev().cloned().collect()
        };
        // dart attaches a spanless `@error` at the nearest mixin or function
        // call boundary: a `@content;` invocation is not one, so an error in a
        // content block — however many forwarding blocks deep — carets the
        // `@include` whose mixin is running, while the `@content` frames stay
        // in the trace.
        let boundary = frames.iter().find(|f| !f.content).unwrap_or(&frames[0]);
        let mut e = Error::at(msg, boundary.pos);
        e.length = boundary.length;
        e.rendered = Some(self.render_error_at(&e, boundary, &frames));
        e
    }

    fn compressed(&self) -> bool {
        matches!(self.options.style, OutputStyle::Compressed)
    }

    // ---- callables ---------------------------------------------------

    // ---- statements --------------------------------------------------

    /// Execute a block of statements, routing each into `sink`. One executor
    /// serves the top level (each statement is its own group), rule bodies
    /// (declarations join the block, nested rules bubble out), and every
    /// nested-block construct that reuses it.
    fn exec(&mut self, stmts: &[Stmt], parents: &[String], sink: &mut Sink<'_>) -> Result<(), Error> {
        for stmt in stmts {
            match stmt {
                Stmt::VarDecl(v) => self.apply_var(v)?,
                Stmt::Comment(c, lines) => {
                    let text = self.eval_template(c)?;
                    let lines = self.stamp(*lines);
                    sink.push_comment(text, lines);
                    self.last_child_invisible = false;
                }
                Stmt::Decl(d) => {
                    if sink.is_top() {
                        return Err(Error::at("top-level declarations aren't allowed", d.pos));
                    }
                    if let Some(oi) = self.eval_decl(d)? {
                        sink.push_item(oi);
                        self.last_child_invisible = false;
                    }
                }
                Stmt::PropertySet(ps) => {
                    if sink.is_top() {
                        return Err(Error::at("top-level declarations aren't allowed", ps.pos));
                    }
                    self.eval_property_set(ps, parents, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::CustomDecl(d) => {
                    if sink.is_top() {
                        return Err(Error::at("top-level declarations aren't allowed", d.pos));
                    }
                    // A literal `--` name may never be nested inside a property
                    // set (dart-sass parse-time error).
                    if self.decl_prefix.is_some() {
                        return Err(Error::at(
                            "Declarations whose names begin with \"--\" may not be nested.",
                            d.pos,
                        ));
                    }
                    if let Some(oi) = self.eval_custom_decl(d)? {
                        sink.push_item(oi);
                        self.last_child_invisible = false;
                    }
                }
                Stmt::Rule(r) => self.eval_style_rule(r, parents, sink)?,
                Stmt::If(branches) => {
                    // Evaluate conditions top to bottom; run the first match's
                    // body in a fresh semi-global scope so an assignment to an
                    // existing outer variable updates it (and can reach the
                    // global scope when every enclosing scope is semi-global),
                    // while a freshly declared variable stays local to the
                    // branch (dart-sass `visitIf`).
                    for branch in branches {
                        let take = match &branch.cond {
                            None => true,
                            Some(c) => self.eval_expr(c)?.is_truthy(),
                        };
                        if take {
                            self.push_scope(true);
                            let result = self.exec(&branch.body, parents, sink);
                            self.pop_scope();
                            result?;
                            break;
                        }
                    }
                }
                Stmt::For {
                    var,
                    from,
                    to,
                    inclusive,
                    body,
                    from_pos,
                } => {
                    let (start_i, end_i, unit) = self.for_bounds(from, to)?;
                    // The loop body runs in its own semi-global scope: the loop
                    // variable and any fresh assignments live there and vanish
                    // when the loop ends (dart-sass `visitForRule`).
                    self.push_scope(true);
                    // Source-map: the loop variable is defined by `from`
                    // (evaluate.dart:1666); resolved inside the scope like dart.
                    let span = self.expression_node(from, *from_pos);
                    let mut result = Ok(());
                    for i in for_indices(start_i, end_i, *inclusive) {
                        self.set_local(var, Value::Number(Number::with_unit(i as f64, &unit)), span);
                        result = self.exec(body, parents, sink);
                        if result.is_err() {
                            break;
                        }
                    }
                    self.pop_scope();
                    result?;
                }
                Stmt::Each {
                    vars,
                    list,
                    body,
                    list_pos,
                } => {
                    let items = self.eval_each_items(list)?;
                    // Source-map: every bound variable is defined by the list
                    // expression, resolved before the scope is pushed
                    // (evaluate.dart:1441).
                    let span = self.expression_node(list, *list_pos);
                    self.push_scope(true);
                    let mut result = Ok(());
                    for i in 0..items.len() {
                        self.bind_each(vars, items.get(i), span);
                        result = self.exec(body, parents, sink);
                        if result.is_err() {
                            break;
                        }
                    }
                    self.pop_scope();
                    result?;
                }
                Stmt::While { cond, body } => {
                    self.push_scope(true);
                    let mut result = Ok(());
                    let mut guard = 0u32;
                    loop {
                        match self.eval_expr(cond) {
                            Ok(v) if v.is_truthy() => {}
                            Ok(_) => break,
                            Err(e) => {
                                result = Err(e);
                                break;
                            }
                        }
                        result = self.exec(body, parents, sink);
                        if result.is_err() {
                            break;
                        }
                        guard += 1;
                        if guard >= 100_000 {
                            result = Err(Error::unpositioned("@while exceeded 100000 iterations"));
                            break;
                        }
                    }
                    self.pop_scope();
                    result?;
                }
                Stmt::FunctionDef(callable) => {
                    let captured = self.capture_callable(callable);
                    self.define_function(&callable.name, captured);
                }
                Stmt::MixinDef(callable) => {
                    let captured = self.capture_callable(callable);
                    self.define_mixin(&callable.name, captured);
                }
                Stmt::Return(_) => {
                    return Err(Error::unpositioned("@return is only allowed inside a function."));
                }
                Stmt::Include {
                    name,
                    args,
                    content,
                    content_params,
                    module,
                    pos,
                    length,
                    full_length,
                } => {
                    // Push a diagnostic call frame so an error/warning raised in
                    // the mixin body unwinds through this `@include` call site.
                    let saved = self.enter_call(*pos, *length, &mixin_frame_name(name, module));
                    let r = self.exec_include(
                        name,
                        args,
                        content.clone(),
                        content_params.clone(),
                        module.as_deref(),
                        *pos,
                        *length,
                        *full_length,
                        parents,
                        sink,
                    );
                    self.leave_call(saved);
                    // An error the include itself reported AT this position —
                    // a content block the mixin does not take, a
                    // `meta.load-css` that found nothing — takes the call's
                    // span. An error from the mixin BODY keeps its own context
                    // (dart reports it against the failing construct), and an
                    // argument error is already anchored to this call by
                    // `error_at_call`.
                    r.map_err(|e| e.with_length_at(*pos, *length))?;
                }
                Stmt::Use {
                    url,
                    namespace,
                    star,
                    config,
                    pos,
                    length,
                } => self
                    .exec_use(url, namespace.as_deref(), *star, config, *pos, parents, sink)
                    .map_err(|e| e.with_length_at(*pos, *length))?,
                Stmt::Forward {
                    url,
                    prefix,
                    show,
                    hide,
                    config,
                    pos,
                    length,
                } => self
                    .exec_forward(url, prefix.as_deref(), show, hide, config, *pos, parents, sink)
                    .map_err(|e| e.with_length_at(*pos, *length))?,
                Stmt::Content {
                    args: content_args,
                    pos: content_pos,
                } => {
                    // The content block runs in the caller's context, so it is no
                    // longer "directly in a mixin" (dart-sass): a
                    // `meta.content-exists()` inside it is an error.
                    self.in_mixin.push(false);
                    let result = self.exec_content(content_args, *content_pos, parents, sink);
                    self.in_mixin.pop();
                    result?;
                }
                Stmt::Import { args, .. } => self.eval_imports(args, parents, sink)?,
                Stmt::AtRule {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    let lines = self.stamp(*lines);
                    self.eval_at_rule(name, prelude, body.as_deref(), lines, parents, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::InterpAtRule {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    // The name resolves at eval time; `@keyframes` is the one
                    // rule whose special handling happens here (frame stops).
                    let resolved = self.eval_template(name)?;
                    // An interpolated name changes nothing about the RULE: it
                    // carries its own span, so it maps like any other at-rule
                    // and joins a trailing comment the same way (dart parity).
                    let stamped = self.stamp(*lines);
                    if is_keyframes_name(&resolved) && body.is_some() {
                        if let Some(b) = body {
                            self.eval_keyframes(&resolved, prelude, b, stamped, sink)?;
                        }
                    } else {
                        self.eval_at_rule(&resolved, prelude, body.as_deref(), stamped, parents, sink)?;
                    }
                    self.last_child_invisible = false;
                }
                Stmt::CssCustomAtRule { name, prelude, body } => {
                    self.eval_css_custom_at_rule(name, prelude, body, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::Media { query, body, lines } => {
                    let stamped = self.stamp(*lines);
                    self.eval_media(query, body, stamped, parents, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::Supports {
                    condition,
                    body,
                    lines,
                } => {
                    let stamped = self.stamp(*lines);
                    self.eval_supports(condition, body, stamped, parents, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::AtRoot { query, body } => {
                    self.eval_at_root(query.as_deref(), body, parents, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::Keyframes {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    let lines = self.stamp(*lines);
                    self.eval_keyframes(name, prelude, body, lines, sink)?;
                    self.last_child_invisible = false;
                }
                Stmt::Extend {
                    selector,
                    optional,
                    pos,
                } => self.register_extend(selector, *optional, *pos, parents)?,
                Stmt::Warn { value, pos } => self.emit_warn(value, *pos)?,
                Stmt::Debug { value, pos } => self.emit_debug(value, *pos)?,
                Stmt::Error { value, pos, length } => {
                    return Err(self.build_error(value, *pos, *length));
                }
            }
        }
        Ok(())
    }

    /// Evaluate a style rule: resolve its selector against `parents`, run its
    /// body into a fresh rule sink, then hand the produced block and the
    /// rules that bubbled out of it to the enclosing `sink`.
    /// A placeholder rule stays an `@extend` target even when its body produces
    /// nothing (`%bam { bam: null }` is "found", dart keeps every rule in the
    /// extend graph; we prune empty rules from the output tree, so the selector
    /// is recorded with its module scope).
    fn note_placeholder_rule(&mut self, s: &str) {
        if s.contains('%') {
            self.placeholder_rules
                .push((self.current_module.clone(), s.to_string()));
        }
    }

    fn eval_style_rule(&mut self, rule: &Rule, parents: &[String], sink: &mut Sink<'_>) -> Result<(), Error> {
        let (sel_str, interp_bounds) = self.eval_template_bounds(&rule.selector)?;
        // A selector that resolves to nothing (e.g. `#{&}` at the document root,
        // where `&` is null) is rejected by dart-sass with "expected selector".
        if sel_str.trim().is_empty() {
            return Err(Error::unpositioned("expected selector."));
        }
        validate_selector(&sel_str, !parents.is_empty())?;
        // A `@` has no legal position in a CSS selector: dart's selector
        // parser fails with "expected selector." — pointed at the source when
        // the offending character maps to literal text, or rendered as the
        // dual-span "error in interpolated output" diagnostic when it came
        // from an interpolation (todo_single_escape).
        if !self.in_keyframes {
            if let Some(at_idx) = find_unquoted_at(&sel_str) {
                return Err(self.interp_selector_error(rule, &sel_str, &interp_bounds, at_idx));
            }
        }
        // A selector starting with a digit is dart's "expected selector."
        // (`1a {}`, issue_2023) — except keyframe stops (`50%`, `13E2%`).
        if !self.in_keyframes {
            for part in split_commas(&sel_str).iter() {
                if part.trim_start().starts_with(|c: char| c.is_ascii_digit()) {
                    return Err(Error::unpositioned("expected selector."));
                }
            }
        }
        // A keyframe selector list is stops (`from`, `to`, `13E+1%`), not CSS
        // selectors: no combinator normalization or parent resolution.
        // Fast path for the line-break flags: no newline anywhere in the source
        // list and no inherited parent breaks means every flag is false — an
        // EMPTY vec, which all consumers read as all-false. Keyframe selector
        // lists always take it (dart re-serializes stops joined with ", ").
        let lbs_fast = self.in_keyframes || (self.current_linebreaks.is_empty() && !sel_str.contains('\n'));
        let part_lbs: Vec<bool> = if lbs_fast {
            Vec::new()
        } else {
            comma_linebreaks(&sel_str, false)
        };
        let parent_lbs: &[bool] = if self.current_linebreaks.len() == parents.len() {
            &self.current_linebreaks
        } else {
            &[]
        };
        // Per-complex source line-breaks (`a,\nb`), on the same fast path as
        // `part_lbs`: when every flag would be false the resolver is told not to
        // derive them, and hands back the empty vec all consumers read as
        // all-false. Keyframe selector lists always take it (dart re-serializes
        // the stops joined with ", ", dropping author line breaks that
        // style-rule selectors preserve).
        // `maybe_bogus` / `any_percent` are the resolver's aggregate answers to
        // the two questions the block below would otherwise ask per selector, one
        // full byte scan each. A keyframe list is resolved here rather than by
        // `resolve_selectors_opt`, so it gets the conservative answer — and a
        // keyframe stop really does carry a `%`.
        let (current, full_lbs, maybe_bogus, any_percent): (Vec<String>, Vec<bool>, bool, bool) =
            if self.in_keyframes {
                (
                    split_commas(&sel_str)
                        .iter()
                        .map(|p| p.trim().to_string())
                        .filter(|p| !p.is_empty())
                        .collect(),
                    Vec::new(),
                    true,
                    true,
                )
            } else {
                let resolved = resolve_selectors_opt(
                    &sel_str,
                    parents,
                    !self.at_root_excluding_style_rule,
                    &part_lbs,
                    parent_lbs,
                    !lbs_fast,
                )?;
                let (maybe_bogus, any_percent) = (resolved.maybe_bogus, resolved.any_percent);
                (resolved.sels, resolved.lbs, maybe_bogus, any_percent)
            };
        // Drop "bogus combinator" complex selectors from the emitted block;
        // dart-sass omits them from the generated CSS. A top-level TRAILING
        // combinator (`a >`) is bogus as a leaf (its own declaration block is
        // dropped) but valid for NESTING, so the full `current` list — including
        // such selectors — is still used for `&` resolution and as the `parents`
        // for nested rules (`a >` + `b` -> `a > b`). A nested rule that inherits
        // a genuinely bogus combinator (double, or leading/trailing in a pseudo)
        // is dropped in turn.
        // `current` is `parents × parts` (or just `parts` at the root), so
        // complex `i` came from part `i % parts.len()`; `full_lbs` carries that
        // part's "newline before" flag, and is filtered below in step with the
        // dropped bogus selectors.
        let current = Rc::new(current);
        // Nothing bogus to drop, no keyframe stop to normalize and no per-complex
        // line-break flags to filter in step: the emitted list is `current`
        // itself, and copying every string to say so is pure waste on the shape
        // almost every rule has. The placeholder bookkeeping below still runs.
        // `complex_selector_block_is_bogus` opens by looking for `> + ~ (`, so on
        // the no-trigger shape it is one full byte scan per selector with no early
        // exit. `!maybe_bogus` already proves no selector holds one of those
        // bytes, so the whole probe is skipped rather than run to a foregone
        // conclusion; when the proof is unavailable it runs exactly as before.
        let share_current = !self.in_keyframes
            && full_lbs.is_empty()
            && (!maybe_bogus || !current.iter().any(|s| complex_selector_block_is_bogus(s)));
        let mut emit_selectors: Vec<String> = Vec::new();
        let mut emit_linebreaks: Vec<bool> = Vec::new();
        // Bogus-combinator warnings are raised AFTER this rule's body, because
        // that is dart's order: on lila's `.#{$name} > + lines { & interrupt
        // {…} }` dart reports the nested `… interrupt` first and the rule that
        // contains it second. Emitting where the selector is dropped gets the
        // set right and the order backwards.
        let mut pending_bogus: Vec<(Pos, usize, String)> = Vec::new();
        // Both of these are read ONLY inside the bogus branch below, which
        // almost no rule takes, and `eval_style_rule` is the hottest function
        // in the compiler. Taking the `Rc` unconditionally put a clone+drop on
        // every style rule in every stylesheet to serve a branch that fires on
        // a handful; it is taken on first need instead.
        let mut src_text: Option<Rc<str>> = None;
        if share_current {
            // Only a `%`-bearing selector can be a placeholder rule, and the
            // resolver's scan already answered that for the whole list.
            if any_percent {
                for s in current.iter() {
                    self.note_placeholder_rule(s);
                }
            }
        } else {
            emit_selectors.reserve(current.len());
            emit_linebreaks.reserve(current.len());
            let mut own_parts: Option<usize> = None;
            for (i, s) in current.iter().enumerate() {
                if complex_selector_block_is_bogus(s) {
                    // dart WARNS as it drops this rule, and the warning is the
                    // only sign the CSS lost it (#119). Only the "invalid CSS"
                    // shape is reported: a bare TRAILING combinator is dart's
                    // other message, which carries a second span labelling the
                    // offending child that this renderer cannot draw yet.
                    //
                    // `current` is `parents x parts`, so complex `i` was
                    // produced by part `i % own_parts` — the entry dart points
                    // at, while the message names the RESOLVED selector.
                    if complex_selector_is_bogus(s, false, false) {
                        let parts = *own_parts.get_or_insert_with(|| split_commas(&sel_str).len().max(1));
                        let src = src_text.get_or_insert_with(|| Rc::clone(&self.current_source));
                        let (pos, len) = selector_part_span(src, rule, &sel_str, &interp_bounds, i % parts);
                        pending_bogus.push((pos, len, s.clone()));
                    }
                    // The omitted selector still participates in @extend target
                    // matching (dart keeps the rule in the extend graph and only
                    // omits it from the emitted CSS).
                    self.bogus_selectors.push(s.clone());
                    continue;
                }
                self.note_placeholder_rule(s);
                // A keyframe stop is re-serialized: `FROM` -> `from`, and a
                // percentage's exponent marker `130E-1%` -> `130e-1%`.
                let s = if self.in_keyframes {
                    normalize_keyframe_selector(s)
                } else {
                    s.clone()
                };
                emit_selectors.push(s);
                if !full_lbs.is_empty() {
                    emit_linebreaks.push(full_lbs.get(i).copied().unwrap_or(false));
                }
            }
        }
        // One handle for the whole rule: shared with `current_selector` on the
        // common shape, and cloned into every block this rule flushes.
        let emitted: Rc<Vec<String>> = if share_current {
            Rc::clone(&current)
        } else {
            Rc::new(emit_selectors)
        };
        self.push_scope(false);
        let prev_selector = self.current_selector.replace(Rc::clone(&current));
        let prev_linebreaks = std::mem::replace(&mut self.current_linebreaks, full_lbs);
        // Entering a style rule re-enables the implicit parent join for
        // anything nested below it (dart resets _atRootExcludingStyleRule).
        let prev_at_root = std::mem::replace(&mut self.at_root_excluding_style_rule, false);
        let rule_lines = self.stamp(SrcLines {
            file: 0,
            start: rule.brace_line,
            end: rule.end_line,
            col: 0,
            // Source-map: the selector's first character — its own line and
            // 0-based column, which differ from the brace line when the
            // selector list spans several lines (dart maps
            // `node.selector.span.start`).
            start_col: (rule.selector_pos.col as u32).saturating_sub(1),
            map_file: 0,
            map_line: rule.selector_pos.line as u32,
        });
        // A `@media`/`@at-root` nested in this rule's body bubbles a copy of the
        // selector out; that copy maps back to THIS selector's source position
        // (dart parity). Source-map only — never touches CSS.
        let prev_rule_lines = std::mem::replace(&mut self.cur_rule_lines, rule_lines);
        let prev_rule_extend_base = std::mem::replace(&mut self.cur_rule_extend_base, self.extends.len());
        let mut items: Vec<OutItem> = Vec::new();
        let mut nested: Vec<OutNode> = Vec::new();
        let mut flushed: Option<usize> = None;
        let at_depth = self.at_rule_ctx.len();
        // dart `addSelector` timing: how many `@extend`s were already registered
        // when this rule's selector was established (before its body runs and
        // registers any of its own). A rule registered AFTER all its applicable
        // `@extend`s is extended one-shot in dart's `paths` order; otherwise the
        // registration-order fold.
        let extend_base = self.extends.len();
        // Fresh trailing-invisible tracking for THIS body (the exit below
        // overwrites the flag with this rule's own contribution, so the
        // parent needs no save).
        self.last_child_invisible = false;
        let result = {
            let mut child = Sink::Rule {
                selectors: SinkSelectors::Shared(&emitted),
                linebreaks: &emit_linebreaks,
                lines: rule_lines,
                items: &mut items,
                nested: &mut nested,
                at_depth,
                flushed: &mut flushed,
                extend_base,
            };
            let r = self.exec(&rule.body, current.as_slice(), &mut child);
            // Flush any declarations/loud comments that follow the last nested
            // rule, so they emit (in their own block) after the bubbled rules.
            if r.is_ok() && child.flush_rule_block() {
                // The flushed block is the subtree's last node — visible.
                self.last_child_invisible = false;
            }
            r
        };
        // After the body, so a nested rule's own bogus selector is reported
        // before its parent's — and only if the body COMPLETED. dart drops the
        // warning when the rule it belongs to failed: an error inside
        // `.a > + .b { color: $nope; }` gets the error alone, while an error in
        // a LATER rule still leaves this one warning. Measured on 1.104.1;
        // flushing unconditionally reported a deprecation for a rule that never
        // finished.
        if result.is_ok() {
            for (pos, len, sel) in pending_bogus {
                let dep = crate::deprecation::Deprecation::bogus_combinators(&sel);
                self.emit_deprecation(&dep, pos, len);
            }
        }
        self.current_selector = prev_selector;
        self.current_linebreaks = prev_linebreaks;
        self.at_root_excluding_style_rule = prev_at_root;
        self.cur_rule_lines = prev_rule_lines;
        self.cur_rule_extend_base = prev_rule_extend_base;
        self.pop_scope();
        result?;
        // The body's own trailing-invisible state gates THIS rule's group
        // end; then report this rule's contribution to the PARENT body
        // (empty output = dart's invisible node).
        let body_last_invisible = std::mem::replace(&mut self.last_child_invisible, false);
        let this_rule_invisible = nested.is_empty() && !self.in_keyframes;
        sink.emit_style_rule(nested, !body_last_invisible);
        // dart's group separator rides the subtree's LAST flattened node: a
        // trailing invisible chain ANY levels down (`#al { a { &:hover {
        // @extend } } }`) owns the enclosing group's end and never renders,
        // so the next group packs tight (chirpy panel -> footer seam).
        self.last_child_invisible = this_rule_invisible || body_last_invisible;
        Ok(())
    }

    /// The CSS text of a declaration's value, serialized through the reusable
    /// `css_buf` and then handed over as an exactly-sized `String`.
    ///
    /// The copy at the end is deliberate: the out item outlives the buffer, and
    /// a value's serialized length is not known before it is written, so the
    /// choice is between one regrown allocation per declaration or one buffer
    /// reused for all of them plus a copy that is already right-sized. Taking
    /// the buffer out of `self` is what lets `write_css` borrow it while the
    /// evaluator is borrowed mutably; the borrow is returned before this
    /// returns, and serialization cannot re-enter the evaluator (a `Value` is
    /// fully evaluated by the time it gets here), so the buffer is never
    /// observed missing. Every value that can legally reach this point writes
    /// itself into the buffer without allocating — the ones that cannot are
    /// rejected as invalid CSS values above — so the copy is the only cost the
    /// buffer adds.
    fn declared_css(&mut self, value: &Value) -> String {
        let compressed = self.compressed();
        let mut buf = std::mem::take(&mut self.css_buf);
        buf.clear();
        value.write_css(&mut buf, compressed);
        let text = String::from(buf.as_str());
        self.css_buf = buf;
        text
    }

    fn eval_decl(&mut self, d: &Declaration) -> Result<Option<OutItem>, Error> {
        let name = trim_shared(self.eval_template_shared(&d.property)?);
        let prop = match &self.decl_prefix {
            Some(prefix) => Rc::from(format!("{prefix}-{name}")),
            None => name,
        };
        let value = self.eval_expr(&d.value)?;
        if matches!(value, Value::Null) {
            return Ok(None);
        }
        // A map is not a valid CSS value (even when nested inside a list).
        if let Some(m) = find_map(&value) {
            return Err(Error::at(
                format!("{} isn't a valid CSS value.", m.to_css(false)),
                d.pos,
            ));
        }
        // A first-class function reference is likewise not a valid CSS value.
        if let Value::Function(f) = &value {
            return Err(Error::at(
                format!("{} isn't a valid CSS value.", f.inspect()),
                d.pos,
            ));
        }
        // A first-class mixin reference is likewise not a valid CSS value.
        if let Value::Mixin(m) = &value {
            return Err(Error::at(
                format!("{} isn't a valid CSS value.", m.inspect()),
                d.pos,
            ));
        }
        // An empty unbracketed list (`()`, or e.g. `list.join((), ())`) cannot
        // serialize as a CSS value; a bracketed `[]` is fine, as is any list
        // with at least one element.
        if let Value::List(l) = &value {
            if l.items.is_empty() && !l.bracketed {
                return Err(Error::at("() isn't a valid CSS value.", d.pos));
            }
        }
        let vstr = self.declared_css(&value);
        // A value that serializes to nothing (an empty unquoted string, an
        // all-`null` list) drops the whole declaration, like a `null` value.
        if vstr.is_empty() {
            return Ok(None);
        }
        // dart computes `valueSpanForMap` as `_expressionNode(node.value).span`
        // (evaluate.dart:1414): a BARE `$name` value resolves to wherever that
        // variable was declared; any other expression shape keeps its own span.
        let value_span = self.expression_node(&d.value, d.value_pos);
        Ok(Some(OutItem::Decl {
            prop,
            value: vstr,
            important: d.important,
            custom: false,
            lines: self.stamp(SrcLines {
                file: 0,
                start: d.pos.line as u32,
                end: d.end_line,
                col: 0,
                // Source-map: the property name's 0-based start column.
                start_col: (d.pos.col as u32).saturating_sub(1),
                map_file: 0,
                map_line: 0,
            }),
            value_span,
        }))
    }

    /// Evaluate a custom-property declaration: the name and verbatim value are
    /// templates whose `#{…}` interpolation resolves; the value is otherwise
    /// emitted exactly as written (no SassScript evaluation). An empty value
    /// (`--x: ;`) still emits.
    fn eval_custom_decl(&mut self, d: &CustomDecl) -> Result<Option<OutItem>, Error> {
        let prop = trim_shared(self.eval_template_shared(&d.property)?);
        let value = self.eval_template(&d.value)?;
        // A custom property is serialized inside `_for(node.value, …)`
        // (serialize.dart:379) — the value's OWN span, never resolved through
        // `_expressionNode`. So `--x: $c` maps to the literal `$c` text.
        let value_span = self.span_at(d.value_pos);
        Ok(Some(OutItem::Decl {
            prop,
            value,
            important: false,
            custom: true,
            lines: self.stamp(SrcLines {
                file: 0,
                start: d.pos.line as u32,
                end: d.end_line,
                // The name's 0-based source column caps the re-indentation
                // strip for a multi-line value (dart _writeReindentedValue).
                col: d.pos.col.saturating_sub(1) as u32,
                // Source-map: the property name's 0-based start column.
                start_col: (d.pos.col as u32).saturating_sub(1),
                map_file: 0,
                map_line: 0,
            }),
            value_span,
        }))
    }

    /// Evaluate a nested property set: resolve its (already prefixed) name,
    /// emit the optional leading value as a declaration, then run the body with
    /// that name installed as the child prefix so each child declaration is
    /// namespaced `<name>-<child>` and emitted in source order.
    fn eval_property_set(
        &mut self,
        ps: &PropertySet,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // A nested property set whose own literal name begins with `--` is
        // rejected just like a plain `--` declaration would be when nested.
        if self.decl_prefix.is_some() && literal_name_is_custom_property(&ps.property) {
            return Err(Error::at(
                "Declarations whose names begin with \"--\" may not be nested.",
                ps.pos,
            ));
        }
        let name = trim_shared(self.eval_template_shared(&ps.property)?);
        let full = match &self.decl_prefix {
            Some(prefix) => Rc::from(format!("{prefix}-{name}")),
            None => name,
        };
        // The leading value (`b: c { … }`) emits `<full>: c;` before children.
        if let Some(value_expr) = &ps.value {
            let value = self.eval_expr(value_expr)?;
            if !matches!(value, Value::Null) {
                if let Some(m) = find_map(&value) {
                    return Err(Error::at(
                        format!("{} isn't a valid CSS value.", m.to_css(false)),
                        ps.pos,
                    ));
                }
                let vstr = self.declared_css(&value);
                sink.push_item(OutItem::Decl {
                    prop: full.clone(),
                    value: vstr,
                    important: ps.important,
                    custom: false,
                    // No usable end line of its own (the value precedes the
                    // `{…}` block); the trailing-comment rule stays disabled.
                    lines: SrcLines::default(),
                    // A property set's leading value carries no mapping today
                    // (its `lines` are already blank), so neither does its
                    // value — leaving both unmapped stays self-consistent.
                    value_span: VarSpan::default(),
                });
            }
        }
        let saved = self.decl_prefix.replace(full);
        let result = self.exec(&ps.body, parents, sink);
        self.decl_prefix = saved;
        result
    }

    /// Evaluate an `@import` statement into `sink`. Sass arguments are parsed
    /// and inlined under the current `parents` (so a nested `@import` bubbles
    /// like an inline block); plain CSS arguments are emitted verbatim as
    /// `@import …;` in source order.
    fn eval_imports(
        &mut self,
        args: &[ImportArg],
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        let importer = self.options.importer;
        for arg in args {
            match arg {
                ImportArg::Css { url, modifiers, pos } => {
                    let text = self.serialize_css_import(url, modifiers)?;
                    // Source-map: the rule maps to its URL token.
                    let lines = self.map_only_lines(*pos);
                    // Inside a style rule the plain-CSS @import stays in the
                    // rule's block (dart keeps it nested:
                    // `foo { @import url(...); }`); at the top level it is a
                    // Raw node subject to import hoisting.
                    if matches!(sink, Sink::Rule { .. }) {
                        sink.push_item(OutItem::ChildlessAtRule {
                            name: "import".to_string(),
                            prelude: text,
                            css_import: true,
                            lines,
                        });
                    } else {
                        sink.push_at_rule(OutNode::Raw(
                            format!("@import{}{text};", self.at_rule_gap()),
                            lines,
                        ));
                    }
                }
                ImportArg::Sass { path, pos, length } => {
                    if is_css_import(path) {
                        let lines = self.map_only_lines(*pos);
                        sink.push_at_rule(OutNode::Raw(
                            format!("@import{}\"{path}\";", self.at_rule_gap()),
                            lines,
                        ));
                        continue;
                    }
                    // (The `[import]` deprecation for this rule was emitted
                    // when its file was parsed: `warn_import_rules`.)
                    let base = self.current_file_dir.clone();
                    // Per-compile import cache (dart-sass ImportCache): the
                    // same URL imported from the same base directory shares
                    // one resolution + parse; the body still EXECUTES per
                    // import (Sass semantics). Misses and parse errors are
                    // not cached — they re-error identically.
                    let cache_key = (path.clone(), base.clone());
                    let entry = match self.import_cache.get(&cache_key) {
                        Some(e) => {
                            if self.loading.iter().any(|p| p == path) {
                                return Err(Error::unpositioned("This file is already being loaded."));
                            }
                            // A cache hit skips the importer, which is where
                            // dependency provenance is recorded: keep the rule
                            // "what a dependency loads is a dependency" here too.
                            // (Outside the arena scope, like the importer.)
                            if let Some(deps) = self.options.quiet_deps {
                                if deps.is_dependency(self.current_path()) {
                                    let _paused = crate::arena::pause();
                                    deps.mark(&e.0);
                                }
                            }
                            Some(e.clone())
                        }
                        None => {
                            // Run the caller's importer outside the arena scope
                            // so any state it caches (paths, sources) outlives
                            // this compile's arena reset; see the matching note
                            // in `load_module`.
                            let paused = crate::arena::pause();
                            // Two-phase resolution (canonicalize, then load),
                            // both inside ONE arena pause so the importer's owned
                            // allocations survive this compile's arena reset.
                            let resolved = match importer {
                                Some(imp) => {
                                    let ctx = CanonicalizeContext {
                                        from_import: true,
                                        containing_url: self.current_canonical.as_ref(),
                                    };
                                    match imp.canonicalize(path, &ctx) {
                                        Err(e) => return Err(Error::unpositioned(e.message)),
                                        Ok(None) => None,
                                        Ok(Some(canon)) => match imp.load(&canon) {
                                            Err(e) => return Err(Error::unpositioned(e.message)),
                                            Ok(None) => None,
                                            Ok(Some(res)) => Some((
                                                canon.as_str().to_string(),
                                                res.contents,
                                                res.syntax,
                                                res.source_map_url,
                                            )),
                                        },
                                    }
                                }
                                None => None,
                            };
                            drop(paused);
                            match resolved {
                                Some((resolved_key, src, syntax, source_map_url)) => {
                                    if self.loading.iter().any(|p| p == path) {
                                        return Err(Error::unpositioned(
                                            "This file is already being loaded.",
                                        ));
                                    }
                                    // A loaded sheet is validated like the
                                    // entry (a misplaced `@import` in a mixin
                                    // body is dart's "This at-rule is not
                                    // allowed here."); plain CSS has nothing
                                    // to validate.
                                    let parsed = parse_with_syntax(&src, syntax).and_then(|sheet| {
                                        if !matches!(syntax, Syntax::Css) {
                                            validate_declarations(&sheet)?;
                                        }
                                        Ok(sheet)
                                    });
                                    let sheet = match parsed {
                                        Ok(sheet) => sheet,
                                        Err(err) => {
                                            // A parse or validation error names
                                            // the IMPORTED file: render eagerly
                                            // under its url/source with an
                                            // `@import` frame at the URL token
                                            // (dart: `_mod.scss 3:19  @import`).
                                            let diag = self.module_diag_url(path, &resolved_key);
                                            let saved_member = self.enter_call(*pos, *length, "@import");
                                            let saved_url = std::mem::replace(&mut self.current_url, diag);
                                            let saved_source = std::mem::replace(
                                                &mut self.current_source,
                                                Rc::from(src.as_str()),
                                            );
                                            let err = self.finalize_error(err);
                                            self.current_url = saved_url;
                                            self.current_source = saved_source;
                                            self.leave_call(saved_member);
                                            return Err(err);
                                        }
                                    };
                                    let e = std::rc::Rc::new((
                                        resolved_key,
                                        syntax,
                                        sheet,
                                        std::rc::Rc::<str>::from(src.as_str()),
                                        source_map_url,
                                    ));
                                    self.import_cache.insert(cache_key, e.clone());
                                    Some(e)
                                }
                                None => None,
                            }
                        }
                    };
                    match entry {
                        Some(entry) => {
                            let (resolved_key, syntax, sheet) = (&entry.0, entry.1, &entry.2);
                            // The diagnostic `@import` frame records the
                            // IMPORTING file at the URL token — push it before
                            // the context swap below rebinds current_url.
                            let saved_member = self.enter_call(*pos, *length, "@import");
                            // The imported file becomes the diagnostics/stamp
                            // context while its body runs (dart shows ITS name
                            // in error frames, and the trailing-comment check
                            // compares file identity): swap in its display URL
                            // and source, and re-intern the SrcLines file id.
                            let import_diag = if resolved_key.is_empty() {
                                self.current_url.clone()
                            } else {
                                self.module_diag_url(path, resolved_key)
                            };
                            if self.options.source_map && !resolved_key.is_empty() {
                                self.file_texts
                                    .entry(resolved_key.to_string())
                                    .or_insert_with(|| Rc::clone(&entry.3));
                                // The importer's `source_map_url` names this
                                // file in `sources[]` (dart's
                                // `ImporterResult.sourceMapUrl`), for `@import`
                                // as for `@use`.
                                if let Some(smu) = &entry.4 {
                                    self.file_map_urls
                                        .entry(resolved_key.to_string())
                                        .or_insert_with(|| smu.clone());
                                }
                            }
                            let saved_import_url = std::mem::replace(&mut self.current_url, import_diag);
                            let saved_import_source =
                                std::mem::replace(&mut self.current_source, Rc::clone(&entry.3));
                            self.current_url_stamp = 0;
                            // Relative URLs inside the imported sheet resolve
                            // against ITS directory, and its canonical URL is
                            // tracked in lockstep (so a nested relative
                            // `@use`/`@import` resolves against ITS directory,
                            // and its mappings — the file table is keyed by
                            // the canonical URL — land on ITS `sources` entry).
                            let saved_dir = if resolved_key.is_empty() {
                                self.current_file_dir.clone()
                            } else {
                                std::mem::replace(&mut self.current_file_dir, dirname_of(resolved_key))
                            };
                            let saved_canonical = if resolved_key.is_empty() {
                                self.current_canonical.clone()
                            } else {
                                self.current_canonical
                                    .replace(CanonicalUrl::new(resolved_key.clone()))
                            };
                            // A plain-CSS file imports as plain CSS: nesting
                            // preserved, no Sass evaluation (same as `@use`).
                            if matches!(syntax, Syntax::Css) {
                                self.loading.push(path.clone());
                                let result = self
                                    .exec_css(&sheet.stmts, parents, sink)
                                    .map_err(|e| self.finalize_error(e));
                                self.loading.pop();
                                self.current_file_dir = saved_dir;
                                self.current_canonical = saved_canonical;
                                self.current_url = saved_import_url;
                                self.current_source = saved_import_source;
                                self.current_url_stamp = 0;
                                self.leave_call(saved_member);
                                result?;
                                continue;
                            }
                            self.loading.push(path.clone());
                            // `@import` inlines the file's variables/functions/
                            // mixins into the current scope, but its module
                            // bindings (`@use`/`@forward`) stay local to the
                            // imported file and must not leak to the importer.
                            let saved_used = std::mem::take(&mut self.used_modules);
                            let saved_star = std::mem::take(&mut self.star_modules);
                            let saved_used_user = std::mem::take(&mut self.used_user_modules);
                            let saved_star_user = std::mem::take(&mut self.star_user_modules);
                            // Nested `$var: ... !global` declarations in the
                            // imported sheet register null slots in the
                            // importing module too (dart-sass: members are
                            // statically visible).
                            {
                                let mut slots: Vec<String> = Vec::new();
                                collect_global_var_decls(&sheet.stmts, &mut slots);
                                if let Some(g) = self.scopes.first() {
                                    let mut g = g.borrow_mut();
                                    for name in slots {
                                        g.entry(name).or_insert(Value::Null);
                                    }
                                }
                            }
                            // The imported file's own `@forward`s expose members
                            // as if defined in the importer; collect them
                            // separately, then merge into the current scope.
                            let saved_fwd = std::mem::take(&mut self.forwarded);
                            // dart-sass: when the imported file loads
                            // user-defined modules (it has top-level
                            // `@use`/`@forward`), its `@forward`s see every
                            // variable visible at the import — all scope
                            // levels, inner shadowing outer — as an implicit
                            // configuration (`toImplicitConfiguration`); a
                            // file without module loads keeps the current
                            // configuration (an enclosing `with (...)` still
                            // flows into its `!default`s). Unconsumed implicit
                            // entries are never an error.
                            let loads_modules = sheet
                                .stmts
                                .iter()
                                .any(|s| matches!(s, Stmt::Use { .. } | Stmt::Forward { .. }));
                            let saved_pending_consumed = if loads_modules {
                                let mut implicit_config: HashMap<String, (Value, bool)> = HashMap::default();
                                for scope in &self.scopes {
                                    for (k, v) in scope.borrow().iter() {
                                        implicit_config
                                            .insert(normalize_var_name(k).into_owned(), (v.clone(), false));
                                    }
                                }
                                Some((
                                    std::mem::replace(&mut self.pending_config, implicit_config),
                                    std::mem::take(&mut self.consumed_config),
                                    std::mem::replace(&mut self.config_is_implicit, true),
                                    std::mem::replace(&mut self.pending_config_id, 0),
                                ))
                            } else {
                                None
                            };
                            let saved_clone = if loads_modules {
                                let n = self.copy_counter.get() + 1;
                                self.copy_counter.set(n);
                                self.import_clone
                                    .replace((format!("#import{n}"), std::collections::HashSet::new()))
                            } else {
                                self.import_clone.take()
                            };
                            // dart parses an imported file as a TOP-LEVEL
                            // stylesheet: a bare declaration there — even
                            // inside top-level control flow — is its parse
                            // error `expected "{".`, regardless of the
                            // @import sitting inside a rule (issue_2295).
                            fn has_top_decl(stmts: &[Stmt]) -> bool {
                                stmts.iter().any(|s| match s {
                                    Stmt::Decl(_) | Stmt::PropertySet(_) | Stmt::CustomDecl(_) => true,
                                    Stmt::If(branches) => branches.iter().any(|b| has_top_decl(&b.body)),
                                    Stmt::For { body, .. }
                                    | Stmt::Each { body, .. }
                                    | Stmt::While { body, .. } => has_top_decl(body),
                                    _ => false,
                                })
                            }
                            if has_top_decl(&sheet.stmts) {
                                return Err(Error::unpositioned("expected \"{\"."));
                            }
                            // The imported file's own `@import` deprecations
                            // fire now, as if at its parse (the per-location
                            // dedup makes a re-import of a cached file quiet,
                            // like dart's once-parsed stylesheet).
                            self.warn_import_rules(&sheet.stmts);
                            // Render any error before the context restores
                            // below strip its attribution (the `@import`
                            // frame from above is still on the stack).
                            let result = self
                                .exec(&sheet.stmts, parents, sink)
                                .map_err(|e| self.finalize_error(e));
                            self.leave_call(saved_member);
                            self.current_url = saved_import_url;
                            self.current_source = saved_import_source;
                            self.current_url_stamp = 0;
                            self.current_file_dir = saved_dir;
                            self.current_canonical = saved_canonical;
                            self.import_clone = saved_clone;
                            if let Some((p, c, i, id)) = saved_pending_consumed {
                                self.pending_config = p;
                                self.consumed_config = c;
                                self.config_is_implicit = i;
                                self.pending_config_id = id;
                            }
                            let imported_fwd = std::mem::replace(&mut self.forwarded, saved_fwd);
                            self.used_modules = saved_used;
                            self.star_modules = saved_star;
                            self.used_user_modules = saved_used_user;
                            self.star_user_modules = saved_star_user;
                            self.loading.pop();
                            result?;
                            // A `@forward`ed member from the imported file becomes
                            // an ordinary member of the importing scope: dart's
                            // @import is textual inclusion, so each forwarded
                            // callable rebinds to the IMPORT SITE's environment
                            // and lands in the innermost frame (a nested
                            // import's members stay scoped to the enclosing
                            // rule and pop with it).
                            if self.scopes.len() == 1 {
                                for (k, f) in imported_fwd.functions {
                                    let rebound = self.recapture_callable(&f);
                                    self.define_function(&k, rebound);
                                }
                                for (k, m) in imported_fwd.mixins {
                                    let rebound = self.recapture_callable(&m);
                                    self.define_mixin(&k, rebound);
                                }
                                if let Some(g) = self.scopes.first() {
                                    let mut g = g.borrow_mut();
                                    for (k, val) in imported_fwd.vars {
                                        // The forwarded module's assignments
                                        // behave as if written at the import:
                                        // they overwrite an existing
                                        // user-defined global (`$a: shadowed;
                                        // @import "fwd"` sees the forwarded
                                        // value afterwards) — but a global a
                                        // previous forward-merge created stays
                                        // bound to its module, so re-importing
                                        // the SAME module must not clobber an
                                        // intervening assignment, while a
                                        // forward from a DIFFERENT module
                                        // overrides it (sass/dart-sass#888).
                                        let src_ptr =
                                            imported_fwd.var_src.get(&k).map(|p| *p as usize).unwrap_or(0);
                                        match self.forwarded_globals.get(&k) {
                                            Some(prev) if *prev == src_ptr => {
                                                g.entry(k).or_insert(val);
                                            }
                                            _ => {
                                                self.forwarded_globals.insert(k.clone(), src_ptr);
                                                g.insert(k, val);
                                            }
                                        }
                                    }
                                }
                            } else {
                                // A nested `@import`'s forwarded variables join
                                // the enclosing rule's scope (so a following
                                // nested import's implicit configuration sees
                                // them, and a local assignment updates them);
                                // its forwarded functions/mixins land in the
                                // innermost frame, scoped to the enclosing
                                // rule (they pop with it, like dart).
                                if let Some(s) = self.scopes.last() {
                                    let mut s = s.borrow_mut();
                                    for (k, val) in imported_fwd.vars {
                                        s.insert(k, val);
                                    }
                                }
                                for (k, f) in imported_fwd.functions {
                                    let rebound = self.recapture_callable(&f);
                                    self.define_function(&k, rebound);
                                }
                                for (k, m) in imported_fwd.mixins {
                                    let rebound = self.recapture_callable(&m);
                                    self.define_mixin(&k, rebound);
                                }
                            }
                        }
                        None => {
                            // dart names no url — the span points at it, all of
                            // it (`@import foo screen` carets ten characters).
                            return Err(
                                Error::at("Can't find stylesheet to import.", *pos).with_length(*length)
                            );
                        }
                    }
                }
            }
        }
        Ok(())
    }
}

/// Whether a calc space-list item is a substitution that makes the unparsed
/// run legal: a `#{…}` interpolation, or a `var()`/`env()` reference (which
/// the parser lowers to an [`Expr::Ident`] whose text begins with `var(`/
/// `env(`, possibly after a vendor prefix). A plain ident, number, nested
/// calc, or variable is NOT a substitution.
/// Whether a property-name template begins, *literally*, with `--` (a custom
/// property). A name whose first piece is `#{…}` interpolation is not literal,
/// so `#{--b}` is allowed to namespace inside a property set while a written
/// `--b` is not.
fn literal_name_is_custom_property(property: &[TplPiece]) -> bool {
    match property.first() {
        Some(TplPiece::Lit(s)) => s.trim_start().starts_with("--"),
        _ => false,
    }
}

fn expr_has_substitution(e: &Expr) -> bool {
    match e {
        Expr::Interp(_) => true,
        // `var()`/`env()` are parsed as plain function calls; inside a calc
        // space-list they are legal substitutions (`calc(var(--c) 1)`).
        Expr::Func { name, .. } => name.eq_ignore_ascii_case("var") || name.eq_ignore_ascii_case("env"),
        Expr::Ident(pieces) => pieces.iter().any(|p| match p {
            TplPiece::Interp(_) => true,
            TplPiece::Lit(s) => {
                let lower = s.trim_start().to_ascii_lowercase();
                lower.starts_with("var(") || lower.starts_with("env(")
            }
        }),
        _ => false,
    }
}

/// Whether an expression tree contains a calculation substitution — a
/// `var()`/`env()` reference or an interpolation — anywhere within it
/// (recursing through operations, parentheses, nested calculations, and
/// lists). Used to decide whether a legacy global math function such as `abs()`
/// is being used as a CSS calculation (so its argument is preserved) rather
/// than as the deprecated Sass global.
fn expr_contains_calc_substitution(e: &Expr) -> bool {
    if expr_has_substitution(e) {
        return true;
    }
    match e {
        Expr::Binary { lhs, rhs, .. } => {
            expr_contains_calc_substitution(lhs) || expr_contains_calc_substitution(rhs)
        }
        Expr::Div { lhs, rhs, .. } => {
            expr_contains_calc_substitution(lhs) || expr_contains_calc_substitution(rhs)
        }
        Expr::Unary { operand, .. } => expr_contains_calc_substitution(operand),
        Expr::Paren(inner) => expr_contains_calc_substitution(inner),
        Expr::Calc { inner } => expr_contains_calc_substitution(inner),
        Expr::List { items, .. } => items.iter().any(expr_contains_calc_substitution),
        _ => false,
    }
}

/// Collect the names of every `$var: ... !global` declaration nested inside
/// block statements (rules, conditionals, loops, mixins are NOT entered —
/// dart-sass registers slots for statically visible nested globals in rules
/// and control flow). Top-level declarations register themselves on
/// evaluation.
fn collect_global_var_decls(stmts: &[Stmt], out: &mut Vec<String>) {
    for stmt in stmts {
        match stmt {
            Stmt::VarDecl(v) if v.is_global && v.namespace.is_none() => out.push(v.name.clone()),
            Stmt::Rule(r) => collect_global_var_decls(&r.body, out),
            Stmt::If(branches) => {
                for b in branches {
                    collect_global_var_decls(&b.body, out);
                }
            }
            Stmt::For { body, .. }
            | Stmt::Each { body, .. }
            | Stmt::While { body, .. }
            | Stmt::Media { body, .. }
            | Stmt::Supports { body, .. }
            | Stmt::AtRoot { body, .. }
            | Stmt::Keyframes { body, .. } => collect_global_var_decls(body, out),
            Stmt::AtRule { body: Some(b), .. } => collect_global_var_decls(b, out),
            _ => {}
        }
    }
}

/// Nest module CSS under the style rule enclosing an `@import` (descendant
/// join on every top-level rule, recursing into at-rule bodies). dart-sass
/// clones the module's CSS into the current parent; a top-level import
/// (`parents` empty) passes through unchanged.
fn reparent_nodes(nodes: Vec<OutNode>, parents: &[String]) -> Vec<OutNode> {
    if parents.is_empty() {
        return nodes;
    }
    // A rule whose selector contains a parent reference `&` keeps native
    // CSS-nesting semantics: it nests VERBATIM inside one leading
    // parent-selector shell instead of the descendant join (dart `nestWithin`
    // with `preserveParentSelectors` — through_load_css:top_level_parent).
    let mut preserved: Vec<OutItem> = Vec::new();
    let mut rest: Vec<OutNode> = Vec::new();
    for n in nodes {
        match n {
            OutNode::Rule {
                selectors,
                linebreaks,
                items,
                lines,
                extend_base,
            } => {
                let selectors = selectors.into_strings();
                if selectors.iter().any(|s| part_has_parent_ref(s)) {
                    preserved.push(OutItem::NestedRule {
                        selectors,
                        linebreaks,
                        items,
                        lines,
                    });
                } else {
                    rest.push(OutNode::Rule {
                        selectors: RuleSelectors::Raw(Rc::new(
                            parents
                                .iter()
                                .flat_map(|p| selectors.iter().map(move |s| format!("{p} {s}")))
                                .collect(),
                        )),
                        linebreaks: Vec::new(),
                        items,
                        lines,
                        extend_base,
                    });
                }
            }
            OutNode::AtRule {
                name,
                prelude,
                body,
                has_block,
                kind,
                lines,
            } => rest.push(OutNode::AtRule {
                name,
                prelude,
                body: reparent_nodes(body, parents),
                has_block,
                kind,
                lines,
            }),
            other => rest.push(other),
        }
    }
    let mut out = Vec::new();
    if !preserved.is_empty() {
        out.push(OutNode::plain_rule(
            parents.to_vec(),
            preserved,
            SrcLines::default(),
        ));
    }
    out.extend(rest);
    out
}

/// Whether an expression contains a SassScript-only operator (`%`, a
/// comparison, boolean logic) that can never appear in a CSS calculation.
/// dart-sass's parser then treats the whole call as a plain function rather
/// than a calculation (`round(7 % 3, 1)` is the legacy one-argument
/// `math.round` — an arity error).
fn expr_has_non_calc_op(e: &Expr) -> bool {
    match e {
        Expr::Binary { op, lhs, rhs, .. } => {
            matches!(
                op,
                BinOp::Mod
                    | BinOp::Eq
                    | BinOp::Neq
                    | BinOp::Lt
                    | BinOp::Gt
                    | BinOp::Le
                    | BinOp::Ge
                    | BinOp::And
                    | BinOp::Or
                    | BinOp::SingleEq
            ) || expr_has_non_calc_op(lhs)
                || expr_has_non_calc_op(rhs)
        }
        Expr::Div { lhs, rhs, .. } => expr_has_non_calc_op(lhs) || expr_has_non_calc_op(rhs),
        Expr::Unary { operand, .. } => expr_has_non_calc_op(operand),
        Expr::Paren(inner) => expr_has_non_calc_op(inner),
        Expr::List { items, .. } => items.iter().any(expr_has_non_calc_op),
        _ => false,
    }
}

/// The inspect-style spelling of a value rejected from a calculation, for
/// dart-sass's "Value … can't be used in a calculation." error. `null`
/// spells out as `null`, a list is parenthesized (`(1 2 3)`, `(1, 2)`); every
/// other type matches its plain CSS form (`true`, `blue`, `"foo"`, `(b: c)`).
fn calc_value_repr(v: &Value) -> String {
    match v {
        Value::Null => "null".to_string(),
        Value::List(_) => format!("({})", v.to_css(false)),
        other => other.to_css(false),
    }
}

/// Resolve a calc() numeric constant from its (unquoted) ident spelling,
/// case-insensitively: `pi`, `e`, `infinity`/`-infinity`, and `nan`. Returns
/// `None` for any other identifier, which is then kept verbatim.
fn calc_constant(text: &str) -> Option<f64> {
    match text.to_ascii_lowercase().as_str() {
        "pi" => Some(std::f64::consts::PI),
        "e" => Some(std::f64::consts::E),
        "infinity" => Some(f64::INFINITY),
        "-infinity" => Some(f64::NEG_INFINITY),
        "nan" => Some(f64::NAN),
        _ => None,
    }
}

/// Whether `s` is exactly one complete CSS-calculation function call —
/// `name(...)` for a recognized calculation function, with the closing paren
/// at the very end (balanced, nothing trailing). Used so that a `calc()`
/// wrapping a single already-complete calculation (`calc(min(1%, 2px))`)
/// drops its redundant outer `calc()`, matching dart-sass. A non-calculation
/// leaf (`var(--x)`, an unknown function) keeps its wrapper.
/// Whether a single-string operand produced by a *nested* `calc()` must be
/// wrapped in parentheses when spliced into the surrounding calculation.
///
/// dart-sass keeps a nested calc's unresolved interpolation/`var()` operand
/// grouped (`calc(calc(#{"c*"}))` -> `calc((c*))`, `calc(1 + calc(var(--c)))`
/// -> `calc(1 + (var(--c)))`), but a clean single token flattens bare
/// (`calc(calc(c))` -> `calc(c)`, `calc(calc(c-d))` -> `calc(c-d)`). The
/// operand needs grouping when it is not already a complete sub-calculation
/// (`min(…)`, `clamp(…)`, …) and either contains a character that would be
/// ambiguous unparenthesized — whitespace, `*`, `/`, or `\` — or is a `var()`
/// substitution (which dart-sass always treats as an opaque group).
fn nested_calc_needs_parens(s: &str) -> bool {
    if is_complete_calculation(s) {
        return false;
    }
    let trimmed = s.trim_start();
    let is_var = trimmed.len() >= 4 && trimmed[..4].eq_ignore_ascii_case("var(");
    is_var
        || s.chars()
            .any(|c| c.is_whitespace() || matches!(c, '*' | '/' | '\\'))
}

fn is_complete_calculation(s: &str) -> bool {
    let s = s.trim();
    let Some(open) = s.find('(') else { return false };
    if !s.ends_with(')') {
        return false;
    }
    let name = s[..open].trim().to_ascii_lowercase();
    let is_calc_name = matches!(
        name.as_str(),
        "calc"
            | "min"
            | "max"
            | "clamp"
            | "round"
            | "mod"
            | "rem"
            | "sin"
            | "cos"
            | "tan"
            | "asin"
            | "acos"
            | "atan"
            | "atan2"
            | "pow"
            | "sqrt"
            | "exp"
            | "log"
            | "hypot"
            | "abs"
            | "sign"
            | "calc-size"
    );
    if !is_calc_name {
        return false;
    }
    // The opening paren must match the final paren (one balanced call that
    // spans the whole string), so `min(1%, 2px)` qualifies but
    // `min(1%, 2px) + min(…)` (extra trailing content) does not.
    let mut depth = 0u32;
    for (i, c) in s.char_indices() {
        match c {
            '(' => depth += 1,
            ')' => {
                depth -= 1;
                if depth == 0 {
                    return i == s.len() - 1;
                }
            }
            _ => {}
        }
    }
    false
}

/// Convert an evaluated value into a calc operand node. Numbers stay numeric
/// (and can fold); everything else becomes an opaque string token preserved
/// verbatim.
fn value_to_calc_node(v: Value) -> CalcNode {
    match v.without_slash() {
        Value::Number(n) => CalcNode::Number(n),
        Value::Calc(node) => node,
        other => CalcNode::Str(other.to_css(false)),
    }
}

/// Fold a calc operation: combine two compatible numbers into one; raise
/// dart-sass's incompatible-units error for two known-but-cross-dimension
/// operands of `+`/`-`; otherwise keep the operation for canonical
/// serialization. Only the immediate numeric operands are considered, like
/// dart-sass's limited simplification.
fn fold_calc(op: CalcOp, left: CalcNode, right: CalcNode, pos: Pos) -> Result<CalcNode, Error> {
    if let (CalcNode::Number(a), CalcNode::Number(b)) = (&left, &right) {
        if let Some(n) = fold_numbers(op, a, b, pos)? {
            return Ok(CalcNode::Number(n));
        }
    }
    // An addition/subtraction operand that is a purely-numeric multiplication of
    // two unit operands (a compound unit like `1px * 1px`) or a division by a
    // unit operand (an inverse unit like `1 / 1px`) is a number with complex
    // units, which CSS calculations cannot mix into a sum. dart-sass rejects it
    // ("Number calc(1px * 1px) isn't compatible with CSS calculations."). A
    // standalone `calc(1px * 1px)` is fine — only the `+`/`-` context checks.
    if matches!(op, CalcOp::Add | CalcOp::Sub) {
        for operand in [&left, &right] {
            if let Some(node) = calc_complex_unit_operand(operand) {
                return Err(Error::at(
                    format!(
                        "Number calc({}) isn't compatible with CSS calculations.",
                        node.to_calc_css(false)
                    ),
                    pos,
                ));
            }
        }
    }
    Ok(CalcNode::Op {
        op,
        left: Box::new(left),
        right: Box::new(right),
    })
}

/// If `node` is a purely-numeric calc operation that produces a number with
/// complex units — a multiplication of two unit-bearing numeric operands
/// (`1px * 1px`), or a division whose denominator carries a unit (`1 / 1px`) —
/// return the offending node. An operation involving a `var()`/interpolation
/// (opaque) operand is not a resolved number and is left preserved, so it never
/// triggers this check.
fn calc_complex_unit_operand(node: &CalcNode) -> Option<&CalcNode> {
    match node {
        CalcNode::Op {
            op: CalcOp::Mul,
            left,
            right,
        } if calc_node_carries_unit(left) && calc_node_carries_unit(right) => Some(node),
        CalcNode::Op {
            op: CalcOp::Div,
            right,
            ..
        } if calc_node_carries_unit(right) => Some(node),
        _ => None,
    }
}

/// Whether a resolved (no opaque operand) calc node carries a real unit: a
/// unit-bearing number, or a `*`/`/` chain of such numbers. A node containing a
/// `var()`/interpolation is opaque (unknown unit) and reported as not carrying
/// a unit, so it does not count toward a compound/inverse unit.
fn calc_node_carries_unit(node: &CalcNode) -> bool {
    match node {
        CalcNode::Number(n) => !n.is_unitless(),
        CalcNode::Str(_) => false,
        CalcNode::Op {
            op: CalcOp::Mul | CalcOp::Div,
            left,
            right,
        } => calc_node_carries_unit(left) || calc_node_carries_unit(right),
        CalcNode::Op { .. } => false,
        // A nested calculation function has no single determinable unit here.
        CalcNode::Func { .. } => false,
    }
}

/// Try to combine two numbers under a calc operator.
///
/// `Ok(Some(n))` folds them; `Ok(None)` preserves the operation verbatim;
/// `Err` is dart-sass's "<a> and <b> are incompatible." rejection.
///
/// For `+`/`-` dart-sass folds equal units and convertible units (converting
/// the right into the left), but — unlike Sass arithmetic — treats a unitless
/// operand mixed with any real unit as an error, and rejects two known
/// absolute units of different dimensions (`1px + 1s`). Two distinct units
/// where at least one is relative/unknown (`1px + 1vw`, `100% - 10px`) or
/// that share a class but are not convertible (`1khz + 1hz`) are preserved.
///
/// `*`/`/` always fold, with dart-sass unit cancellation: a compound result
/// (`6px * 1s` -> `6px*s`) is a single multi-unit number whose calc
/// serialization spells the units back out as operands.
fn fold_numbers(op: CalcOp, a: &Number, b: &Number, pos: Pos) -> Result<Option<Number>, Error> {
    match op {
        CalcOp::Add | CalcOp::Sub => {
            let apply = |x: f64, y: f64| if op == CalcOp::Add { x + y } else { x - y };
            // A multi-unit operand folds against convertible unit lists;
            // anything else is dart-sass's "isn't compatible with CSS
            // calculations." rejection (quoting the first complex operand).
            if a.has_complex_units() || b.has_complex_units() {
                if let Some(factor) = crate::value::unit_lists_factor(
                    (b.numer_units(), b.denom_units()),
                    (a.numer_units(), a.denom_units()),
                ) {
                    return Ok(Some(a.copy_units(apply(a.value, b.value * factor))));
                }
                let complex = if a.has_complex_units() { a } else { b };
                return Err(Error::at(
                    format!(
                        "Number {} isn't compatible with CSS calculations.",
                        complex.to_css(false)
                    ),
                    pos,
                ));
            }
            // Identical units (incl. `%`, relative units, both unitless)
            // fold; dart compares unit names exactly (`PX` != `px`).
            if a.unit() == b.unit() {
                return Ok(Some(a.copy_units(apply(a.value, b.value))));
            }
            // A unitless operand mixed with a real unit is an error in calc.
            if a.is_unitless() || b.is_unitless() {
                return Err(calc_incompatible(a, b, pos));
            }
            // Two distinct real units: convert when in the same convertible
            // group; error when both are known but cross-dimension; otherwise
            // preserve (a relative/unknown unit is involved).
            if let Some(factor) = crate::value::convert_factor(b.unit(), a.unit()) {
                Ok(Some(a.copy_units(apply(a.value, b.value * factor))))
            } else if crate::value::calc_units_incompatible(a.unit(), b.unit()) {
                Err(calc_incompatible(a, b, pos))
            } else {
                Ok(None)
            }
        }
        CalcOp::Mul => Ok(Some(a.mul(b))),
        CalcOp::Div => Ok(Some(a.div(b))),
    }
}

/// dart-sass's `calc()` incompatible-units error (note: "are incompatible.",
/// distinct from the arithmetic "have incompatible units." wording).
fn calc_incompatible(a: &Number, b: &Number, pos: Pos) -> Error {
    Error::at(
        format!("{} and {} are incompatible.", a.to_css(false), b.to_css(false)),
        pos,
    )
}

/// The declaration scope a statement is nested in, for validating that
/// `@function`/`@mixin` declarations appear only where dart-sass allows them.
#[derive(Clone, Copy, PartialEq)]
enum DeclScope {
    /// Top level, a style rule, or a plain at-rule (`@media`): declarations OK.
    Allowed,
    /// Inside `@if`/`@each`/`@for`/`@while` (propagates through style rules).
    Control,
    /// Inside a `@function` body.
    Function,
    /// Inside a `@mixin` body.
    Mixin,
}

/// The lexical context a statement is nested in, used to statically reject
/// misplaced statements exactly like dart-sass — *before* evaluation, so even
/// an unexecuted `@if false { … }` branch is validated.
#[derive(Clone, Copy)]
struct ScopeCtx {
    /// `@function`/`@mixin`/control declaration scope (see [`DeclScope`]).
    decl: DeclScope,
    /// Lexically inside a style rule (dart-sass's parser `_inStyleRule`). Set by
    /// [`Stmt::Rule`]; preserved through `@media`/`@supports`/`@keyframes`/
    /// generic at-rules and control directives. Governs where `@extend` may
    /// appear lexically.
    in_style_rule: bool,
    /// Inside an `@at-root` body or an `@include` content block: the lexical
    /// `@extend` placement check is deferred to the evaluator, which checks the
    /// *runtime* style-rule context (the `@at-root` query and the include site
    /// determine whether a style rule survives — neither is knowable statically).
    /// All other validations still apply.
    defer_extend: bool,
}

impl ScopeCtx {
    fn root() -> Self {
        ScopeCtx {
            decl: DeclScope::Allowed,
            in_style_rule: false,
            defer_extend: false,
        }
    }
    fn with(self, decl: DeclScope) -> Self {
        ScopeCtx { decl, ..self }
    }
}

/// Reject statements nested where dart-sass forbids them. Runs once after
/// parsing, so an unexecuted `@while (false) { @function … }` still errors (it
/// is a compile-time, not run-time, restriction). Covers:
/// - `@function`/`@mixin` declarations in control/function/mixin bodies;
/// - the full set of statements illegal inside a `@function` body (style rules,
///   declarations, and everything that isn't a var assignment / control flow /
///   `@return` / `@warn` / `@debug` / `@error`);
/// - `@content` outside a `@mixin` declaration;
/// - `@extend` outside a style rule or mixin.
pub(crate) fn validate_declarations(sheet: &Stylesheet) -> Result<(), Error> {
    validate_decl_scope(&sheet.stmts, ScopeCtx::root())
}

fn validate_decl_scope(stmts: &[Stmt], ctx: ScopeCtx) -> Result<(), Error> {
    let scope = ctx.decl;
    for stmt in stmts {
        // Inside a `@function` body dart-sass only permits variable
        // assignments, control flow, `@return`, `@warn`/`@debug`/`@error`, and
        // comments. Reject the rest here (with dart's precedence ordering)
        // before the generic per-statement handling below.
        if scope == DeclScope::Function {
            match stmt {
                // The indented-syntax parser can attach a function header's
                // parameter list on a continuation line (`@function a\n  ()`) as
                // a spurious empty-`()` "style rule" in the body. dart-sass reads
                // it as the (empty) parameter list, not a rule — and `()` is not
                // a valid selector dart would ever produce — so this artifact is
                // not a real style rule. Skip it; a genuine rule is rejected.
                Stmt::Rule(r) if is_empty_parens_selector(&r.selector) => {}
                Stmt::Rule(_) => {
                    return Err(Error::unpositioned(
                        "@function rules may not contain style rules.".to_string(),
                    ));
                }
                Stmt::Decl(_) | Stmt::CustomDecl(_) | Stmt::PropertySet(_) => {
                    return Err(Error::unpositioned(
                        "@function rules may not contain declarations.".to_string(),
                    ));
                }
                // Allowed in a function body: keep walking (control flow) or
                // accept verbatim (assignments / `@return` / diagnostics /
                // comments). Function/mixin definitions fall through to the
                // declaration check below, which already yields dart's
                // "This at-rule is not allowed here." for a nested function.
                Stmt::VarDecl(_)
                | Stmt::Return(_)
                | Stmt::Warn { .. }
                | Stmt::Debug { .. }
                | Stmt::Error { .. }
                | Stmt::Comment(..)
                | Stmt::If(_)
                | Stmt::For { .. }
                | Stmt::Each { .. }
                | Stmt::While { .. }
                | Stmt::FunctionDef(_)
                | Stmt::MixinDef(_) => {}
                // An `@import` is rejected with its span (dart underlines the
                // rule); the generic arm below would lose it.
                Stmt::Import { pos, length, .. } => {
                    let mut e = Error::at("This at-rule is not allowed here.", *pos);
                    e.length = *length;
                    return Err(e);
                }
                // Anything else (@extend, @content, @include, @media, @at-root,
                // @use, @charset, generic at-rules, …) is rejected.
                _ => {
                    return Err(Error::unpositioned(
                        "This at-rule is not allowed here.".to_string(),
                    ));
                }
            }
        }
        match stmt {
            Stmt::FunctionDef(c) => {
                if let Some(msg) = decl_error(scope, "function") {
                    return Err(Error::unpositioned(msg));
                }
                validate_decl_scope(&c.body, ctx.with(DeclScope::Function))?;
            }
            Stmt::MixinDef(c) => {
                if let Some(msg) = decl_error(scope, "mixin") {
                    return Err(Error::unpositioned(msg));
                }
                validate_decl_scope(&c.body, ctx.with(DeclScope::Mixin))?;
            }
            // `@content` is only legal lexically within a `@mixin` declaration
            // (directly or nested through style rules / control / at-rules). The
            // `decl` scope is `Mixin` throughout a mixin body, so testing it
            // captures every nesting. (Inside a `@function` the earlier guard
            // already emitted "This at-rule is not allowed here.".)
            Stmt::Content { .. } if scope != DeclScope::Mixin => {
                return Err(Error::unpositioned(
                    "@content is only allowed within mixin declarations.".to_string(),
                ));
            }
            // `@extend` applies at the include site, so lexically it is legal
            // only within a style rule or a mixin. Elsewhere — top level, or a
            // control directive not inside a style rule — dart-sass errors at
            // parse time. (Inside a `@function` the earlier guard wins; inside
            // an `@at-root` body or an `@include` content block the check is
            // deferred to the evaluator — see `defer_extend`.)
            Stmt::Extend { .. } if !ctx.defer_extend && !ctx.in_style_rule && scope != DeclScope::Mixin => {
                return Err(Error::unpositioned(
                    "@extend may only be used within style rules.".to_string(),
                ));
            }
            // Control directives establish (or keep) the control/function/mixin
            // scope; a `@function`/`@mixin` body's scope sticks through them.
            // They preserve the enclosing `in_style_rule` flag.
            Stmt::If(branches) => {
                let inner = ctx.with(enter_control(scope));
                for b in branches {
                    validate_decl_scope(&b.body, inner)?;
                }
            }
            Stmt::For { body, .. } | Stmt::Each { body, .. } | Stmt::While { body, .. } => {
                validate_decl_scope(body, ctx.with(enter_control(scope)))?;
            }
            // A style rule establishes the style-rule context for `@extend`.
            Stmt::Rule(r) => {
                validate_decl_scope(
                    &r.body,
                    ScopeCtx {
                        in_style_rule: true,
                        ..ctx
                    },
                )?;
            }
            // `@at-root` runs its body at the document root: whether a style
            // rule survives depends on the (runtime-evaluated) `with`/`without`
            // query, so defer the `@extend` placement check to the evaluator.
            // A nested style rule inside the body re-establishes `in_style_rule`
            // for its own descendants (handled by the `Stmt::Rule` arm).
            Stmt::AtRoot { body, .. } => {
                validate_decl_scope(
                    body,
                    ScopeCtx {
                        defer_extend: true,
                        ..ctx
                    },
                )?;
            }
            // Plain at-rules / `@media` / `@supports` / `@keyframes` preserve
            // both the declaration scope and the style-rule context.
            Stmt::AtRule { body: Some(body), .. }
            | Stmt::InterpAtRule { body: Some(body), .. }
            | Stmt::Media { body, .. }
            | Stmt::Supports { body, .. }
            | Stmt::Keyframes { body, .. } => validate_decl_scope(body, ctx)?,
            // An `@include`'s content block resolves at the include site, so its
            // `@extend` placement is only knowable at runtime — defer it. The
            // block is still mixin-body-like for declaration validation, so the
            // other checks keep running with the surrounding scope.
            Stmt::Include {
                content: Some(content),
                ..
            } => validate_decl_scope(
                content,
                ScopeCtx {
                    defer_extend: true,
                    ..ctx
                },
            )?,
            // A Sass `@import` (one that inlines a partial) is forbidden inside
            // a control directive or a function/mixin body; a plain-CSS
            // `@import` is always allowed (passed through verbatim).
            Stmt::Import { args, pos, length }
                if scope != DeclScope::Allowed
                    && args.iter().any(|a| matches!(a, ImportArg::Sass { .. })) =>
            {
                // Positioned at the rule, so the error renders dart's snippet
                // (`@import "x"` underlined) and its frames — for a loaded file,
                // the loader chain.
                let mut e = Error::at("This at-rule is not allowed here.", *pos);
                e.length = *length;
                return Err(e);
            }
            // A property set's body is a declaration block: dart parses its
            // children as declarations and a short list of at-rules that
            // excludes `@import` of ANY kind (plain-CSS ones included, unlike
            // a control directive's body) and `@function`/`@mixin`.
            Stmt::PropertySet(ps) => {
                if let Some((pos, length)) = first_import_rule(&ps.body) {
                    let mut e = Error::at("This at-rule is not allowed here.", pos);
                    e.length = length;
                    return Err(e);
                }
                validate_decl_scope(&ps.body, ctx.with(enter_control(scope)))?;
            }
            _ => {}
        }
    }
    Ok(())
}

/// True when a rule selector is the empty-`()` artifact the indented-syntax
/// parser emits for a `@function` header whose parameter list spills onto a
/// continuation line. dart-sass treats `()` there as the parameter list, never
/// a selector, so it must not count as a style rule inside a `@function` body.
fn is_empty_parens_selector(selector: &[TplPiece]) -> bool {
    match selector {
        [TplPiece::Lit(s)] => s.trim() == "()",
        _ => false,
    }
}

/// Entering a control directive: a `@function`/`@mixin` body keeps its own
/// scope (declarations inside still get the function/mixin message); otherwise
/// control flow establishes the `Control` scope.
/// The first `@import` rule (of any kind) in a property set's body, looking
/// through control directives and nested property sets.
fn first_import_rule(stmts: &[Stmt]) -> Option<(Pos, usize)> {
    for stmt in stmts {
        let found = match stmt {
            Stmt::Import { pos, length, .. } => Some((*pos, *length)),
            Stmt::If(branches) => branches.iter().find_map(|b| first_import_rule(&b.body)),
            Stmt::For { body, .. } | Stmt::Each { body, .. } | Stmt::While { body, .. } => {
                first_import_rule(body)
            }
            Stmt::PropertySet(ps) => first_import_rule(&ps.body),
            _ => None,
        };
        if found.is_some() {
            return found;
        }
    }
    None
}

fn enter_control(scope: DeclScope) -> DeclScope {
    match scope {
        DeclScope::Function | DeclScope::Mixin => scope,
        _ => DeclScope::Control,
    }
}

fn decl_error(scope: DeclScope, kind: &str) -> Option<String> {
    match scope {
        DeclScope::Allowed => None,
        DeclScope::Control => Some(format!(
            "{} may not be declared in control directives.",
            if kind == "function" { "Functions" } else { "Mixins" }
        )),
        DeclScope::Function => Some("This at-rule is not allowed here.".to_string()),
        DeclScope::Mixin => Some(format!("Mixins may not contain {kind} declarations.")),
    }
}

pub(crate) fn is_css_import(arg: &str) -> bool {
    arg.ends_with(".css")
        || arg.starts_with("http://")
        || arg.starts_with("https://")
        || arg.starts_with("//")
}

/// Append a top-level group's output, prefixing a blank-line separator
/// when there is already prior output (and the group is non-empty).
/// dart-sass omits the blank line after an at-rule, so two adjacent at-rules
/// (or an at-rule followed by a style rule) pack together with no gap.
/// Move every top-level plain-CSS `@import` (a `Raw` node) to the front of the
/// document, preserving their relative order — dart-sass requires CSS `@import`
/// rules to precede all style rules. Imports nested in `@media`/rules are not
/// `Raw` top-level nodes and are unaffected. A no-op when there is at most one
/// import or no rules precede any import.
fn hoist_css_imports(out: &mut Vec<OutNode>) {
    fn is_import(n: &OutNode) -> bool {
        matches!(n, OutNode::Raw(s, _) if s.starts_with("@import"))
    }
    // Hoisting only kicks in when a CSS `@import` follows a *style-producing*
    // node (a rule/at-rule/declaration). Imports interleaved only with comments
    // and blanks keep their source order (dart-sass preserves comment context).
    // ModuleScope wrappers are transparent for both detection and extraction.
    fn scan(nodes: &[OutNode], seen_css: &mut bool) -> bool {
        for n in nodes {
            match n {
                OutNode::ModuleScope { nodes, .. } => {
                    if scan(nodes, seen_css) {
                        return true;
                    }
                }
                n if is_import(n) => {
                    if *seen_css {
                        return true;
                    }
                }
                OutNode::Blank | OutNode::Comment(..) => {}
                _ => *seen_css = true,
            }
        }
        false
    }
    let mut seen_css = false;
    if !scan(out, &mut seen_css) {
        return;
    }
    // Stage 1 — dart's per-module `_endOfImports`/`_outOfOrderImports`: a
    // root-level plain-CSS import that appears AFTER other css re-inserts at
    // the end of the module's leading import run (comments before any css
    // extend the run; a ModuleScope is transparent but keeps its position).
    // A load-css / import-clone copy scope is dart's `clone: true` splice:
    // the cloned CSS joins the SURROUNDING module's own statements with no
    // module boundary, so its imports take part in the surrounding module's
    // out-of-order handling and leading-run split.
    fn is_clone_scope(key: &str) -> bool {
        key.contains("#copy") || key.contains("#import")
    }
    fn normalize_out_of_order(nodes: Vec<OutNode>) -> Vec<OutNode> {
        let mut queue: std::collections::VecDeque<OutNode> = nodes.into();
        let mut result: Vec<OutNode> = Vec::new();
        let mut out_of_order: Vec<OutNode> = Vec::new();
        let mut frozen = false;
        let mut insert_at = 0usize;
        while let Some(n) = queue.pop_front() {
            match n {
                OutNode::ModuleScope { key, nodes: inner } if is_clone_scope(&key) => {
                    for x in inner.into_iter().rev() {
                        queue.push_front(x);
                    }
                }
                OutNode::ModuleScope { key, nodes: inner } => {
                    result.push(OutNode::ModuleScope {
                        key,
                        nodes: normalize_out_of_order(inner),
                    });
                    if !frozen {
                        insert_at = result.len();
                    }
                }
                n if is_import(&n) => {
                    if frozen {
                        out_of_order.push(n);
                    } else {
                        result.push(n);
                        insert_at = result.len();
                    }
                }
                OutNode::Comment(..) | OutNode::Blank => {
                    result.push(n);
                    if !frozen {
                        insert_at = result.len();
                    }
                }
                other => {
                    frozen = true;
                    result.push(other);
                }
            }
        }
        if !out_of_order.is_empty() {
            result.splice(insert_at..insert_at, out_of_order);
        }
        result
    }
    // Stage 2 — dart `_combineCss`'s visitModule: two buckets. Each module
    // contributes its leading run (comments + plain-CSS @imports up to the
    // LAST import — `_indexAfterImports`) to the `imports` bucket and
    // everything after to the `css` flow. Comments written before a `@use`
    // (sitting before a ModuleScope here) are that module's
    // preModuleComments: they go to the imports bucket while the css flow is
    // still empty, and stay in place afterwards. The css flow keeps its
    // ModuleScope structure.
    fn visit(nodes: Vec<OutNode>, imports: &mut Vec<OutNode>, css_seen: &mut bool) -> Vec<OutNode> {
        let mut rest: Vec<OutNode> = Vec::new();
        let mut iter = nodes.into_iter().peekable();
        // Phase 1: pre-module comment runs and embedded upstream modules.
        let mut pending: Vec<OutNode> = Vec::new();
        loop {
            match iter.peek() {
                Some(OutNode::Comment(..)) | Some(OutNode::Blank) => {
                    pending.push(iter.next().unwrap());
                }
                Some(OutNode::ModuleScope { .. }) => {
                    let Some(OutNode::ModuleScope { key, nodes: inner }) = iter.next() else {
                        unreachable!()
                    };
                    // preModuleComments: into the imports bucket only while
                    // no css flowed yet (dart `css.isEmpty ? imports : css`).
                    if !*css_seen {
                        imports.extend(pending.drain(..).filter(|n| !matches!(n, OutNode::Blank)));
                    } else {
                        rest.append(&mut pending);
                    }
                    let inner_rest = visit(inner, imports, css_seen);
                    if !inner_rest.is_empty() {
                        *css_seen = true;
                        rest.push(OutNode::ModuleScope {
                            key,
                            nodes: inner_rest,
                        });
                    }
                }
                _ => break,
            }
        }
        // Phase 2: the module's own statements — `_indexAfterImports` over
        // the remaining sequence (pending comments are its leading run).
        let mut own: Vec<OutNode> = pending;
        own.extend(iter);
        let mut last_import: Option<usize> = None;
        for (i, n) in own.iter().enumerate() {
            if is_import(n) {
                last_import = Some(i);
            } else if !matches!(n, OutNode::Comment(..) | OutNode::Blank) {
                break;
            }
        }
        if let Some(li) = last_import {
            let mut tail = own.split_off(li + 1);
            imports.extend(own.into_iter().filter(|n| !matches!(n, OutNode::Blank)));
            // Pulling the run leaves a NEW seam between the preceding css and
            // the remainder: its eval-time separator left with the run, so
            // re-derive it exactly like the eval-time `push_group` (dart's
            // group-end rule). Everything after the seam keeps its eval-time
            // grouping verbatim (a parent rule packs tight against its own
            // flattened nested children).
            while matches!(tail.first(), Some(OutNode::Blank)) {
                tail.remove(0);
            }
            if tail.iter().any(|n| !matches!(n, OutNode::Blank)) {
                *css_seen = true;
            }
            push_group(&mut rest, tail);
            return rest;
        }
        if own.iter().any(|n| !matches!(n, OutNode::Blank)) {
            *css_seen = true;
        }
        rest.extend(own);
        rest
    }
    let original = normalize_out_of_order(std::mem::take(out));
    let mut imports = Vec::new();
    let mut css_seen = false;
    let rest = visit(original, &mut imports, &mut css_seen);
    out.extend(imports);
    // The css flow keeps its eval-time grouping and packs tight against the
    // imports bucket (dart writes the flow right after the imports).
    let mut rest = rest;
    while matches!(rest.first(), Some(OutNode::Blank)) {
        rest.remove(0);
    }
    out.extend(rest);
    while matches!(out.last(), Some(OutNode::Blank)) {
        out.pop();
    }
}

/// Splice an already-grouped node sequence (a module's captured CSS) into a
/// sink. Into a top-level sink the whole sequence is ONE group — its internal
/// `Blank` separators are preserved and exactly one separator is added before
/// it — instead of per-node `push_group` calls that would double the blanks.
fn splice_nodes(sink: &mut Sink<'_>, nodes: Vec<OutNode>) {
    match sink {
        Sink::Top(out) => push_group(out, nodes),
        _ => {
            for n in nodes {
                if !matches!(n, OutNode::Blank) {
                    sink.push_at_rule(n);
                }
            }
        }
    }
}

/// Drop leading blank separators (an unwrapped module-scope boundary can
/// leave one at the head of a cloned subtree).
fn trim_leading_blanks(nodes: &mut Vec<OutNode>) {
    while matches!(nodes.first(), Some(OutNode::Blank)) {
        nodes.remove(0);
    }
}

/// Turn an INTERIOR `GroupEnd` marker (one that is immediately followed by an
/// output-producing node) into a single `Blank`, leaving a trailing marker
/// untouched. An in-place `@at-root` hoist that resumes its enclosing style rule
/// leaves such a marker between the hoisted style rule and the resumed parent;
/// dart separates them with one blank line. Today the only `GroupEnd` reaching a
/// style rule's `nested` is that one (top-level post-rule markers stay trailing,
/// consumed by the next `push_group`), so this is a no-op for every other shape.
pub(super) fn materialize_interior_group_ends(nodes: Vec<OutNode>) -> Vec<OutNode> {
    let is_content = |n: &OutNode| {
        !matches!(
            n,
            OutNode::Blank
                | OutNode::GroupEnd
                | OutNode::MediaHoist
                | OutNode::AtRootHoist { .. }
                | OutNode::AtRootPackTight
        )
    };
    let mut result: Vec<OutNode> = Vec::with_capacity(nodes.len());
    let mut iter = nodes.into_iter().peekable();
    while let Some(node) = iter.next() {
        if matches!(node, OutNode::GroupEnd) && iter.peek().is_some_and(is_content) {
            result.push(OutNode::Blank);
        } else {
            result.push(node);
        }
    }
    result
}

fn push_group(out: &mut Vec<OutNode>, mut group: Vec<OutNode>) {
    if group.is_empty() {
        return;
    }
    // A pack-tight or group-end sentinel attaches to the previous group
    // verbatim — no separator logic now; the NEXT group packs tight against
    // a pack-tight sentinel and blank-separates after a group-end one.
    if group.len() == 1 && matches!(&group[0], OutNode::AtRootPackTight | OutNode::GroupEnd) {
        out.append(&mut group);
        return;
    }
    // The last EFFECTIVE node before this group: module-scope wrappers are
    // judged by their last non-blank child (a module's captured CSS may end
    // in a style-group-end sentinel from its own evaluation). An EMPTY
    // module scope (e.g. a settings module of pure variables) is invisible
    // and must not act as the separator anchor — skip it and keep drilling
    // (uswds/bulma function modules ending in `@use "settings"`).
    fn invisible_wrapper(n: &OutNode) -> bool {
        match n {
            OutNode::Blank => true,
            OutNode::ModuleScope { nodes, .. } => nodes.iter().all(invisible_wrapper),
            _ => false,
        }
    }
    fn last_effective(n: &OutNode) -> &OutNode {
        if let OutNode::ModuleScope { nodes, .. } = n {
            if let Some(l) = nodes.iter().rev().find(|x| !invisible_wrapper(x)) {
                return last_effective(l);
            }
        }
        n
    }
    // A completed style rule always separates from the next group (dart
    // isGroupEnd); a top-level sentinel is consumed here, one inside a
    // wrapper just informs the decision (the emitters skip it).
    let top_marker = matches!(out.last(), Some(OutNode::GroupEnd));
    if top_marker {
        out.pop();
    }
    let last_eff = out.last().map(last_effective);
    let prev_group_end = top_marker || matches!(last_eff, Some(OutNode::GroupEnd));
    // dart-sass never prefixes a blank line after an at-rule, a passed-through
    // CSS `@import` (a `Raw` at-rule), or a loud comment: the next group packs
    // tight against them. A blank line is only inserted after a style rule (or
    // top-level declaration) that already emitted CSS.
    let prev_packs_tight = match last_eff {
        Some(OutNode::AtRule { .. } | OutNode::Comment(..)) => true,
        // A passed-through CSS `@import` and the remaining hoist markers (which a
        // module wrapper's last child can be) pack tight; only a group-end marker
        // forces the separator.
        Some(
            OutNode::Raw(..) | OutNode::MediaHoist | OutNode::AtRootHoist { .. } | OutNode::AtRootPackTight,
        ) => true,
        _ => false,
    };
    // A consumed group-end sentinel forces the separator even when popping it
    // emptied `out` (a stripped sourceMappingURL comment leading the document:
    // dart still writes a leading blank before the first emitted node).
    if (top_marker || !out.is_empty()) && (prev_group_end || !prev_packs_tight) {
        out.push(OutNode::Blank);
    }
    out.append(&mut group);
}

/// The integer indices a `@for` iterates: ascending or descending, with the
/// end included (`through`) or excluded (`to`).
/// Normalize a Sass argument/parameter name: hyphens and underscores are
/// interchangeable, so `$b-c` and `$b_c` refer to the same parameter. A name
/// containing CSS escapes is decoded first, so the raw definition spelling
/// `foo\func` and a call site's canonical `foo\f unc` agree (issue_553) —
/// dart decodes escapes into the identifier text at parse time.
fn normalize_arg_name(name: &str) -> Cow<'_, str> {
    if name.contains('\\') {
        return Cow::Owned(decode_ident_escapes(name).replace('_', "-"));
    }
    // The common case is a name with no underscore: borrow it untouched
    // (this runs 4-6x per function call, so the no-alloc path matters).
    if name.contains('_') {
        Cow::Owned(name.replace('_', "-"))
    } else {
        Cow::Borrowed(name)
    }
}

/// Decode CSS escapes (`\66 ` / `\func` / `\\`) to their code points: up to
/// six hex digits terminated by one optional whitespace, or a literal next
/// character. NUL decodes to U+FFFD like CSS.
fn decode_ident_escapes(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut it = s.chars().peekable();
    while let Some(c) = it.next() {
        if c != '\\' {
            out.push(c);
            continue;
        }
        let mut hex = String::new();
        while hex.len() < 6 && it.peek().is_some_and(|h| h.is_ascii_hexdigit()) {
            hex.push(it.next().unwrap());
        }
        if hex.is_empty() {
            match it.next() {
                Some(l) => out.push(l),
                None => out.push('\\'),
            }
        } else {
            let cp = u32::from_str_radix(&hex, 16).unwrap_or(0xFFFD);
            out.push(match char::from_u32(cp) {
                Some('\0') | None => '\u{FFFD}',
                Some(ch) => ch,
            });
            if matches!(it.peek(), Some(' ' | '\t' | '\n')) {
                it.next();
            }
        }
    }
    out
}

/// Whether `name` is a global CSS-calculation function that dart-sass parses
/// as a calculation expression, and so cannot accept a `...` rest argument
/// (`clamp`, `hypot`, the exponent/trig functions). `min`/`max` are excluded:
/// they are variadic Sass functions that also accept a splat.
fn is_calc_function(name: &str) -> bool {
    matches!(name, "clamp" | "hypot" | "atan2" | "log" | "pow")
}

/// Whether `name` is a fixed-arity math calculation (`sin`, `cos`, `sqrt`,
/// `pow`, `log`, `hypot`, …) that dart-sass parses as a calculation rather than
/// an ordinary SassScript function. Matched case-insensitively. The legacy
/// global functions `abs`/`round`/`min`/`max`/`ceil`/`floor` are deliberately
/// excluded: they fall back to the Sass math builtin (with a deprecation
/// warning) instead of rejecting non-calculation operands, and `clamp`/`min`/
/// `max` keep their dedicated builtin preservation.
fn is_pure_calc_math_function(name: &str) -> bool {
    // Compared case-insensitively in place. Folding `name` into an owned
    // lowercase copy first would allocate on every call, and this predicate is
    // reached for every function call in every expression.
    const NAMES: [&str; 15] = [
        "sin", "cos", "tan", "asin", "acos", "atan", "atan2", "exp", "log", "pow", "hypot", "sqrt", "sign",
        "mod", "rem",
    ];
    NAMES.iter().any(|n| name.eq_ignore_ascii_case(n))
}

/// Whether a calc node carries an opaque operand — a `var()`, interpolation, or
/// unknown identifier preserved verbatim — anywhere in its tree. Such a node
/// cannot reduce to a single number, so a math calculation containing it stays
/// preserved (`sin(2px + var(--c))`).
fn calc_node_has_opaque(node: &CalcNode) -> bool {
    match node {
        CalcNode::Number(_) => false,
        CalcNode::Str(_) => true,
        CalcNode::Op { left, right, .. } => calc_node_has_opaque(left) || calc_node_has_opaque(right),
        // A nested calculation function is already preserved, so a calc holding
        // it cannot reduce to a single number.
        CalcNode::Func { .. } => true,
    }
}

/// Serialize an unquoted string as dart-sass `_visitUnquotedString` does: each
/// newline becomes a single space, and any whitespace immediately following a
/// newline is dropped. Used for `@supports` custom-property values.
fn unquoted_string_css(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut after_newline = false;
    for ch in s.chars() {
        match ch {
            '\n' => {
                out.push(' ');
                after_newline = true;
            }
            ' ' => {
                if !after_newline {
                    out.push(' ');
                }
            }
            other => {
                after_newline = false;
                out.push(other);
            }
        }
    }
    out
}

/// Whether `name` is a CSS math function that dart-sass parses as a calculation
/// (and so keeps unsimplified inside a `@supports` declaration). Matched
/// case-insensitively, mirroring dart-sass's calculation-function set.
fn is_supports_calc_function(name: &str) -> bool {
    let lower = name.to_ascii_lowercase();
    matches!(
        lower.as_str(),
        "min"
            | "max"
            | "clamp"
            | "round"
            | "mod"
            | "rem"
            | "abs"
            | "sign"
            | "sin"
            | "cos"
            | "tan"
            | "asin"
            | "acos"
            | "atan"
            | "atan2"
            | "exp"
            | "sqrt"
            | "pow"
            | "log"
            | "hypot"
            | "calc-size"
    )
}

/// Find a map anywhere in a value (including nested in a list), returning a
/// reference to the first one. Used to reject maps in CSS output positions,
/// where dart-sass errors with "(…) isn't a valid CSS value.".
fn find_map(v: &Value) -> Option<&Map> {
    match v {
        Value::Map(m) => Some(m),
        Value::List(l) => l.items.iter().find_map(find_map),
        _ => None,
    }
}

/// The dart-sass "isn't a valid CSS value." error message for a value that
/// cannot be serialized to CSS, or `None` if it can. Mirrors the
/// declaration-emit guard exactly: a MAP found anywhere (including nested in a
/// list) is rejected with its own serialization, and a TOP-LEVEL empty
/// unbracketed list (`()`) is rejected as `()`. A bracketed `[]`, and an empty
/// list merely nested inside a non-empty list, both serialize fine. Reused at
/// every other CSS-serialization site (unary `-`/`+`, the `+`/`-`/`/` string
/// joins, and `#{…}` interpolation) so they reject the same shapes dart does
/// instead of silently emitting bogus output.
pub(super) fn css_value_error_msg(v: &Value) -> Option<String> {
    if let Some(m) = find_map(v) {
        return Some(format!("{} isn't a valid CSS value.", m.to_css(false)));
    }
    if let Value::List(l) = v {
        if l.items.is_empty() && !l.bracketed {
            return Some("() isn't a valid CSS value.".to_string());
        }
    }
    None
}

/// Serialize a value for interpolation, erroring (like dart-sass) if it is a
/// map or empty list that cannot become CSS. Shared by every interpolation
/// context that turns a value into text (`@media`/`@supports` queries and
/// feature decls). The error carries no span — these template sites have no
/// per-piece source position — but matches dart's message and non-zero exit.
pub(super) fn interp_checked(v: &Value) -> Result<String, Error> {
    let mut s = String::new();
    interp_checked_into(&mut s, v)?;
    Ok(s)
}

/// [`interp_checked`] into the caller's buffer, for the template evaluators
/// that are already building one: `#{$i}` writes its digits into the template's
/// string rather than into one of its own.
pub(super) fn interp_checked_into(out: &mut String, v: &Value) -> Result<(), Error> {
    if let Some(msg) = css_value_error_msg(v) {
        return Err(Error::unpositioned(msg));
    }
    v.write_interp(out);
    Ok(())
}

fn for_indices(start: i64, end: i64, inclusive: bool) -> Vec<i64> {
    let mut out = Vec::new();
    if start <= end {
        let last = if inclusive { end } else { end - 1 };
        let mut i = start;
        while i <= last {
            out.push(i);
            i += 1;
        }
    } else {
        let last = if inclusive { end } else { end + 1 };
        let mut i = start;
        while i >= last {
            out.push(i);
            i -= 1;
        }
    }
    out
}

/// The diagnostic stack-frame name for an `@include`: dart-sass prints the bare
/// mixin name with empty parens (`name()`), without the `ns.` namespace.
fn mixin_frame_name(name: &str, _module: &Option<String>) -> String {
    format!("{name}()")
}

/// Whether a mixin body contains a reachable `@content`. dart-sass scans the
/// whole body tree — control flow, at-rules, nested style rules, and nested
/// `@include` content blocks all count (nested mixin/function definitions are
/// disallowed by the grammar, so there is no separate scope to exclude).
fn body_uses_content(body: &[Stmt]) -> bool {
    body.iter().any(stmt_uses_content)
}

fn stmt_uses_content(stmt: &Stmt) -> bool {
    match stmt {
        Stmt::Content { .. } => true,
        Stmt::Rule(r) => body_uses_content(&r.body),
        Stmt::If(branches) => branches.iter().any(|b| body_uses_content(&b.body)),
        Stmt::For { body, .. }
        | Stmt::Each { body, .. }
        | Stmt::While { body, .. }
        | Stmt::Media { body, .. }
        | Stmt::Supports { body, .. }
        | Stmt::AtRoot { body, .. }
        | Stmt::Keyframes { body, .. } => body_uses_content(body),
        Stmt::AtRule { body: Some(body), .. } => body_uses_content(body),
        Stmt::Include {
            content: Some(content),
            ..
        } => body_uses_content(content),
        _ => false,
    }
}

/// Validate a (post-interpolation) selector string against the subset of
/// dart-sass's parser rules this build can safely enforce:
///   * `&` may appear only at the beginning of a compound selector (so `b&`,
///     `[x]&`, `.y&` are all errors). A `&` followed directly by an
///     identifier-name character (`a`, `-`, `_`, digit, `\`) is a "suffix":
///     at the document root (no parent) that is an error, but inside a style
///     rule it concatenates onto the parent.
///   * A `%` placeholder must be followed directly by an identifier name-start
///     character; a bare `%` (or `%` before `.`, a digit, whitespace, …) is
///     "Expected identifier.". A `%` right after a digit is a percentage
///     keyframe selector (`10%`), not a placeholder.
///   * An `[…]` attribute selector's modifier must be a single ASCII letter
///     immediately before the closing `]`.
///
/// Quoted strings (with `\` escapes) and the contents of nested `[…]`/`(…)`
/// groups are skipped so combinators/`&`/`%` inside them are not misread.
/// Reject the selector forms plain CSS forbids in one comma-part: a placeholder
/// (`%x`), a parent reference with a suffix (`&x`), a top-level leading
/// combinator (`> a`), and a trailing combinator (`a >`). The text is the
/// already-resolved selector (no interpolation left).
/// The parent directory of a resolved file key, for relative URL resolution
/// (`None` when the key has no directory component or is not a path).
fn dirname_of(key: &str) -> Option<String> {
    let p = std::path::Path::new(key);
    p.parent()
        .filter(|d| !d.as_os_str().is_empty())
        .map(|d| d.to_string_lossy().into_owned())
}

/// An `@at-root` batch awaiting its graft point (paired with a hoist marker).
struct AtRootBatch {
    /// Index of the topmost excluded at-rule layer = the depth the batch
    /// re-enters the tree at (0 = document root).
    target: usize,
    /// Whether the `@at-root` ran with no enclosing style rule: dart then
    /// marks the batch's last node as a group end (the next root-level node
    /// gets a blank line) instead of packing tight.
    group_end: bool,
    nodes: Vec<OutNode>,
}

/// Whether `n` is a hoist marker whose batch escapes a body at `depth`:
/// media hoists always escape; an at-root batch escapes when its graft
/// target lies outside this body. Escaping markers are transparent to
/// block anchoring (the batch is not a sibling inside this node).
fn is_escaping_marker(n: &OutNode, depth: usize) -> bool {
    match n {
        OutNode::MediaHoist => true,
        OutNode::AtRootHoist { target } => *target < depth,
        _ => false,
    }
}

/// One enclosing at-rule layer recorded for `@at-root` queries: the data
/// needed to re-wrap a hoisted body in that layer (dart's "included" copies).
#[derive(Clone)]
enum AtCtx {
    Media { prelude: String },
    Supports { prelude: String },
    Keyframes { name: String, prelude: String },
}

impl AtCtx {
    /// The query name this layer matches (dart `AtRootQuery.excludes`).
    fn query_name(&self) -> &'static str {
        match self {
            AtCtx::Media { .. } => "media",
            AtCtx::Supports { .. } => "supports",
            AtCtx::Keyframes { .. } => "keyframes",
        }
    }

    /// Wrap `body` in this layer's at-rule node.
    fn wrap(&self, body: Vec<OutNode>) -> OutNode {
        match self {
            AtCtx::Media { prelude } => OutNode::AtRule {
                name: "media".to_string(),
                prelude: prelude.clone(),
                body,
                has_block: true,
                kind: AtRuleKind::Conditional,
                lines: SrcLines::default(),
            },
            AtCtx::Supports { prelude } => OutNode::AtRule {
                name: "supports".to_string(),
                prelude: prelude.clone(),
                body,
                has_block: true,
                kind: AtRuleKind::Conditional,
                lines: SrcLines::default(),
            },
            AtCtx::Keyframes { name, prelude } => OutNode::AtRule {
                name: name.clone(),
                prelude: prelude.clone(),
                body,
                has_block: true,
                kind: AtRuleKind::Generic,
                lines: SrcLines::default(),
            },
        }
    }
}

/// A parsed `@at-root` query (dart `AtRootQuery`): `(with: …)` keeps only
/// the named layers, `(without: …)` drops them, `all` matches every layer,
/// and the default (no query) is `(without: rule)`.
struct AtRootQuery {
    include: bool,
    names: Vec<String>,
    all: bool,
    rule: bool,
}

impl AtRootQuery {
    fn parse(text: Option<&str>) -> AtRootQuery {
        let Some(text) = text else {
            return AtRootQuery {
                include: false,
                names: vec!["rule".to_string()],
                all: false,
                rule: true,
            };
        };
        let inner = text.trim().trim_start_matches('(').trim_end_matches(')');
        let (include, list) = match inner.split_once(':') {
            Some((k, v)) if k.trim().eq_ignore_ascii_case("with") => (true, v),
            Some((_, v)) => (false, v),
            None => (false, inner),
        };
        let names: Vec<String> = list
            .split_whitespace()
            .map(|s| s.trim_matches('"').trim_matches('\'').to_ascii_lowercase())
            .collect();
        let all = names.iter().any(|n| n == "all");
        let rule = names.iter().any(|n| n == "rule");
        AtRootQuery {
            include,
            names,
            all,
            rule,
        }
    }

    /// Whether the query excludes style rules (dart `excludesStyleRules`).
    fn excludes_style_rules(&self) -> bool {
        (self.all || self.rule) != self.include
    }

    /// Whether the query excludes the layer named `name`.
    fn excludes_name(&self, name: &str) -> bool {
        if self.all {
            return !self.include;
        }
        self.names.iter().any(|n| n == name) != self.include
    }
}

/// Normalize a keyframe selector the way dart re-serializes a stop: the
/// `from`/`to` keywords are lowercased (`FROM` -> `from`), and so is a
/// percentage stop's scientific-notation marker (`130E-1%` -> `130e-1%`);
/// the digits are left verbatim.
pub(super) fn normalize_keyframe_selector(s: &str) -> String {
    let t = s.trim();
    if t.eq_ignore_ascii_case("from") || t.eq_ignore_ascii_case("to") {
        return t.to_ascii_lowercase();
    }
    if !s.contains('E') {
        return s.to_string();
    }
    let is_pct = t.ends_with('%')
        && t[..t.len() - 1]
            .chars()
            .all(|c| c.is_ascii_digit() || matches!(c, '.' | '+' | '-' | 'e' | 'E'));
    if is_pct {
        s.replace('E', "e")
    } else {
        s.to_string()
    }
}

/// Convert an at-rule-body node list (as produced by `eval_at_body` with no
/// parents) into rule items, for at-rules nested verbatim inside keyframe
/// blocks.
fn at_body_to_items(nodes: Vec<OutNode>) -> Vec<OutItem> {
    let mut items = Vec::new();
    for n in nodes {
        match n {
            OutNode::AtDecl {
                prop,
                value,
                important,
                custom,
                lines,
                value_span,
            } => items.push(OutItem::Decl {
                prop,
                value,
                important,
                custom,
                lines,
                value_span,
            }),
            OutNode::Comment(t, lines) => items.push(OutItem::Comment(t, lines)),
            OutNode::Rule {
                selectors,
                linebreaks,
                items: ri,
                lines,
                ..
            } => items.push(OutItem::NestedRule {
                selectors: selectors.into_strings(),
                linebreaks,
                items: ri,
                lines,
            }),
            OutNode::AtRule {
                name,
                prelude,
                body,
                has_block,
                kind,
                lines,
            } => {
                if has_block {
                    items.push(OutItem::NestedAtRule {
                        name,
                        prelude,
                        items: at_body_to_items(body),
                        kind,
                        lines,
                    });
                } else {
                    items.push(OutItem::ChildlessAtRule {
                        name,
                        prelude,
                        css_import: false,
                        lines,
                    });
                }
            }
            OutNode::ModuleScope { nodes, .. } => items.extend(at_body_to_items(nodes)),
            // Raw passthroughs, blanks, and the control-only hoist markers carry
            // no rule-block item.
            OutNode::Raw(..)
            | OutNode::Blank
            | OutNode::GroupEnd
            | OutNode::MediaHoist
            | OutNode::AtRootHoist { .. }
            | OutNode::AtRootPackTight => {}
        }
    }
    items
}

fn validate_plain_css_selector(part: &str, top_level: bool) -> Result<(), Error> {
    let trimmed = part.trim();
    let chars_buf = CharBuf::of(trimmed);
    let chars: &[char] = &chars_buf;
    // A leading combinator is allowed when *nested* (it joins onto the parent),
    // but not at the top level.
    if top_level && matches!(chars.first(), Some('>' | '+' | '~')) {
        return Err(Error::unpositioned(
            "Top-level leading combinators aren't allowed in plain CSS.",
        ));
    }
    // A trailing combinator never has a selector to bind to.
    if matches!(chars.last(), Some('>' | '+' | '~')) {
        return Err(Error::unpositioned("expected selector."));
    }
    let mut i = 0;
    // True at the start of each compound (start, or after a combinator/space).
    let mut at_compound_start = true;
    let mut depth = 0i32; // inside `[...]`/`(...)`
    while i < chars.len() {
        let c = chars[i];
        match c {
            '\\' => {
                i += 2;
                at_compound_start = false;
                continue;
            }
            '[' | '(' => depth += 1,
            ']' | ')' => depth -= 1,
            _ if depth > 0 => {}
            ' ' | '\t' | '\n' | '\r' | '>' | '+' | '~' => at_compound_start = true,
            '%' if at_compound_start => {
                return Err(Error::unpositioned(
                    "Placeholder selectors aren't allowed in plain CSS.",
                ));
            }
            '&' => {
                let next = chars.get(i + 1).copied();
                if matches!(next, Some(n) if n.is_ascii_alphanumeric() || n == '-' || n == '_' || n == '\\') {
                    return Err(Error::unpositioned(
                        "Parent selectors can't have suffixes in plain CSS.",
                    ));
                }
                at_compound_start = false;
            }
            _ => at_compound_start = false,
        }
        i += 1;
    }
    Ok(())
}

/// Whether the `(` at `chars[open]` directly follows a pseudo-class/element
/// name: a non-empty run of identifier characters whose preceding character is
/// a `:` (`:not(`, `::-webkit-any(`).
fn paren_follows_pseudo(chars: &[char], open: usize) -> bool {
    let mut j = open;
    while j > 0 {
        let p = chars[j - 1];
        if p.is_ascii_alphanumeric() || p == '-' || p == '_' || (p as u32) >= 0x80 {
            j -= 1;
        } else {
            break;
        }
    }
    j < open && j > 0 && chars[j - 1] == ':'
}

fn validate_selector(sel: &str, has_parent: bool) -> Result<(), Error> {
    // A selector list whose FIRST comma part is empty is dart-sass's
    // "expected selector." (`,b`); later empty parts (`a,,b`, trailing `a,`)
    // are tolerated and skipped.
    if sel.trim_start().starts_with(',') {
        return Err(Error::unpositioned("expected selector."));
    }
    // Parens and brackets must nest properly: `a:b([c)]` is dart's
    // `expected "]".` (a `)` closing while a `[` is still open). A selector
    // without any bracket/quote/escape byte cannot mis-nest — skip the scan.
    if sel
        .bytes()
        .any(|c| matches!(c, b'(' | b'[' | b')' | b']' | b'"' | b'\'' | b'\\'))
    {
        let mut stack: Vec<char> = Vec::new();
        let mut quote: Option<char> = None;
        let mut prev_escape = false;
        for c in sel.chars() {
            if prev_escape {
                prev_escape = false;
                continue;
            }
            match c {
                '\\' => prev_escape = true,
                q @ ('"' | '\'') => match quote {
                    Some(open) if open == q => quote = None,
                    Some(_) => {}
                    None => quote = Some(q),
                },
                _ if quote.is_some() => {}
                '(' | '[' => stack.push(c),
                ')' | ']' => {
                    let open = stack.pop();
                    if c == ')' && open == Some('[') {
                        return Err(Error::unpositioned("expected \"]\"."));
                    }
                    if c == ']' && open == Some('(') {
                        return Err(Error::unpositioned("expected \")\"."));
                    }
                }
                _ => {}
            }
        }
    }
    // Any pseudo-class/element must name an identifier: a bare or repeated colon
    // with no ident-start after it (`a::`, `a:::before`, `::before::`, `a:`) is
    // dart's `Expected identifier.`. Gated on a `:` being present.
    if sel.as_bytes().contains(&b':') {
        validate_pseudo_names(sel)?;
    }
    // Grammar-typed pseudo arguments — the An+B microsyntax of
    // `:nth-child`/`:nth-last-child` and the non-empty selector list of
    // `:not`/`:is`/`:where`/`:has`/… — are validated against dart's parser.
    // Gated on a parenthesized pseudo (a `:` somewhere before a `(`).
    if sel.as_bytes().contains(&b'(') && sel.as_bytes().contains(&b':') {
        crate::selector::validate_pseudo_args(sel).map_err(Error::unpositioned)?;
    }
    // One byte pre-scan classifies the rest of the validation: most resolved
    // selectors are plain (idents/classes/combinators/spaces) and need at
    // most the sigil ident-start check — no char-vector materialization, no
    // comma split. Every rejection or recursion in the full walk below is
    // triggered by one of the "slow" bytes, except the `#`/`.` ident-start
    // rule, which the byte-only light path reproduces exactly (UTF-8
    // continuation bytes are >= 0x80, so byte lookarounds match char ones).
    let mut needs_slow = false;
    let mut has_sigil = false;
    for &b in sel.as_bytes() {
        match b {
            b'\\' | b'"' | b'\'' | b'[' | b'(' | b')' | b']' | b'&' | b'%' | b'/' => needs_slow = true,
            b'#' | b'.' => has_sigil = true,
            _ => {}
        }
    }
    // Equivalence of the light/skip paths against the full walk was proven
    // by a check build asserting identical Results on every call across the
    // full sass-spec suite.
    if needs_slow {
        validate_selector_tail(sel, has_parent)
    } else if has_sigil {
        validate_plain_sigils(sel)
    } else {
        Ok(())
    }
}

/// Every pseudo-class/element must name an identifier: after its leading `:`
/// (or `::`), an identifier-start character is required. A bare or repeated
/// colon (`a::`, `a:::before`, `a:`, `::before::`) — including one nested in a
/// selector-argument pseudo (`:not(::)`) — is dart's `Expected identifier.`.
/// Colons inside `[...]` attribute selectors and string literals are exempt.
fn validate_pseudo_names(sel: &str) -> Result<(), Error> {
    let chars_buf = CharBuf::of(sel);
    let chars: &[char] = &chars_buf;
    let mut i = 0usize;
    while i < chars.len() {
        match chars[i] {
            '\\' => {
                i += 2;
            }
            '"' | '\'' => i = skip_string(chars, i),
            '[' => i = matching_bracket(chars, i) + 1,
            ':' => {
                i += 1;
                // A second colon makes a pseudo-element (`::before`).
                if chars.get(i) == Some(&':') {
                    i += 1;
                }
                // The name must begin with a CSS identifier-start character.
                if !pseudo_name_starts_at(chars, i) {
                    return Err(Error::unpositioned("Expected identifier."));
                }
            }
            _ => i += 1,
        }
    }
    Ok(())
}

/// Whether `chars[i..]` begins a CSS identifier (the pseudo name after a colon):
/// a letter, `_`, escape, or non-ASCII char; or a `-` provided the NEXT
/// character is itself an identifier-start (`-foo`, `--foo`) — a lone `-`, a
/// `-` then a digit (`-9`), and a leading digit (`0`, `9x`) are not.
fn pseudo_name_starts_at(chars: &[char], i: usize) -> bool {
    let is_start = |c: char| c.is_ascii_alphabetic() || c == '_' || c == '\\' || (c as u32) >= 0x80;
    match chars.get(i).copied() {
        Some(c) if is_start(c) => true,
        Some('-') => matches!(chars.get(i + 1).copied(), Some(n) if is_start(n) || n == '-'),
        _ => false,
    }
}

/// The `#`/`.` ident-start rule on a selector with no escape, quote,
/// bracket, paren, `&`, `%`, or `/` byte: every sigil is top-level, and its
/// next character must start an identifier (a `.` right after a digit is a
/// keyframe decimal point and is skipped; `#` gets no such exemption).
fn validate_plain_sigils(sel: &str) -> Result<(), Error> {
    let b = sel.as_bytes();
    for i in 0..b.len() {
        let c = b[i];
        if c != b'#' && c != b'.' {
            continue;
        }
        if c == b'.' && i > 0 && b[i - 1].is_ascii_digit() {
            continue;
        }
        let starts_ident = match b.get(i + 1) {
            Some(&n) => n.is_ascii_alphabetic() || n == b'-' || n == b'_' || n >= 0x80,
            None => false,
        };
        if !starts_ident {
            return Err(Error::unpositioned("Expected identifier."));
        }
    }
    Ok(())
}

/// The full per-part validation walk (slow path).
fn validate_selector_tail(sel: &str, has_parent: bool) -> Result<(), Error> {
    for part in split_commas(sel).iter() {
        let chars_buf = CharBuf::of(part);
        let chars: &[char] = &chars_buf;
        let mut i = 0;
        // True at the start of each compound selector (start of the part and
        // immediately after any combinator or whitespace).
        let mut at_compound_start = true;
        let mut depth = 0i32; // inside `[...]` or `(...)`
        while i < chars.len() {
            let c = chars[i];
            match c {
                '\\' => {
                    // An escape consumes the following character verbatim.
                    i += 2;
                    at_compound_start = false;
                    continue;
                }
                '"' | '\'' => {
                    i = skip_string(chars, i);
                    at_compound_start = false;
                    continue;
                }
                '[' if depth == 0 => {
                    let end = matching_bracket(chars, i);
                    validate_attribute(&chars[i + 1..end])?;
                    i = end + 1;
                    at_compound_start = false;
                    continue;
                }
                // A top-level `(` is only valid as a pseudo-class/element
                // argument list (`:not(…)`, `::part(…)`): the run of identifier
                // characters directly before it must follow a `:`. Anywhere
                // else — compound start, after a plain identifier, after `]` —
                // dart-sass reports "expected selector." (`a(b)`, `a (b)`).
                '(' if depth == 0 => {
                    if !paren_follows_pseudo(chars, i) {
                        return Err(Error::unpositioned("expected selector."));
                    }
                    depth += 1;
                    at_compound_start = false;
                }
                // A stray top-level closer never matches an open bracket.
                ')' if depth == 0 => {
                    return Err(Error::unpositioned("Unexpected \")\"."));
                }
                '[' | '(' => {
                    depth += 1;
                    at_compound_start = false;
                }
                ']' | ')' => {
                    depth -= 1;
                    at_compound_start = false;
                }
                _ if depth > 0 => {}
                ' ' | '\t' | '\n' | '\r' => at_compound_start = true,
                '>' | '+' | '~' => at_compound_start = true,
                '&' => {
                    if !at_compound_start {
                        return Err(Error::unpositioned(
                            "\"&\" may only used at the beginning of a compound selector.",
                        ));
                    }
                    let next = chars.get(i + 1).copied();
                    let is_suffix = matches!(next, Some(n) if n.is_ascii_alphanumeric() || n == '-' || n == '_' || n == '\\');
                    if is_suffix && !has_parent {
                        return Err(Error::unpositioned(
                            "A top-level selector may not contain a parent selector with a suffix.",
                        ));
                    }
                    at_compound_start = false;
                }
                '%' => {
                    let prev_is_digit = i > 0 && chars[i - 1].is_ascii_digit();
                    if !prev_is_digit {
                        let next = chars.get(i + 1).copied();
                        let starts_ident = matches!(next, Some(n) if n.is_ascii_alphabetic() || n == '-' || n == '_' || n == '\\');
                        if !starts_ident {
                            return Err(Error::unpositioned("Expected identifier."));
                        }
                    }
                    at_compound_start = false;
                }
                // A `#`/`.` (id/class) must be followed by an identifier name
                // start; `#2b` / `.3c` are "Expected identifier." (a `-`, `_`,
                // letter, escape, or non-ASCII char is fine). A `.` right after a
                // digit is a decimal point (a keyframe stop like `50.5%`), not a
                // class, so it is skipped. A bare digit *type* selector (`1a`) is
                // also left alone: `50%` keyframe stops reach this same validator.
                '#' | '.' if !(c == '.' && i > 0 && chars[i - 1].is_ascii_digit()) => {
                    let next = chars.get(i + 1).copied();
                    let starts_ident = matches!(next, Some(n) if n.is_ascii_alphabetic() || n == '-' || n == '_' || n == '\\' || (n as u32) >= 0x80);
                    if !starts_ident {
                        return Err(Error::unpositioned("Expected identifier."));
                    }
                    at_compound_start = false;
                }
                // A reference combinator (`/foo/`) used to be valid CSS but is
                // no longer supported; dart-sass now rejects any top-level `/`
                // in a selector with "expected selector.". (A `/` inside an
                // attribute value or a pseudo argument is at depth > 0 and is
                // handled above.)
                '/' => {
                    return Err(Error::unpositioned("expected selector."));
                }
                _ => at_compound_start = false,
            }
            i += 1;
        }
    }
    Ok(())
}

/// Inline capacity of a [`CharBuf`], in characters. Selector parts measure
/// around 16 characters on the benchmark corpora and whole selectors around
/// 40, so 64 keeps effectively all of them off the heap, and initializing that
/// much stack costs far less than the allocate-and-grow it replaces. Longer
/// input takes the heap arm, which builds no array at all.
const CHAR_BUF_INLINE: usize = 64;

/// A selector's characters, materialized for index-based scanning.
///
/// The scanners here want `[char]` rather than bytes: an escape advances by one
/// CHARACTER, and several of the predicates are Unicode-aware, so a byte cursor
/// would have to decode as it walks. Collecting a `Vec<char>` is what that used
/// to cost — and more than one allocation per call, because `str::chars()` only
/// promises `len / 4` characters, so the `Vec` started at a quarter of the size
/// it needed and doubled its way up. Selectors are short, so the characters go
/// into an inline array instead and a scan touches the allocator not at all.
///
/// Never pooled across calls: inside a compile scope the heap arm's allocation
/// comes from the arena, and the arena is reset wholesale when the scope ends
/// (see [`crate::arena`]), so a buffer kept past that point would hand out
/// memory the next compile is also using.
///
/// Bind a `&[char]` from it once (`let chars: &[char] = &buf;`) instead of
/// indexing the buffer: a scan loop then walks a plain slice, exactly as it did
/// the `Vec` this replaces, with no per-index arm to pick.
// The big inline arm is the point of the type, and every `CharBuf` is a
// stack local that never enters a collection, so the arms' size difference
// costs nothing.
#[allow(clippy::large_enum_variant)]
enum CharBuf {
    /// The characters are `chars[..len]` — no allocation.
    Inline {
        chars: [char; CHAR_BUF_INLINE],
        len: usize,
    },
    /// Input too long for the array.
    Heap(Vec<char>),
}

impl CharBuf {
    /// The characters of `s`, in order.
    fn of(s: &str) -> CharBuf {
        // A character is at least one byte, so a string of at most
        // `CHAR_BUF_INLINE` bytes holds at most that many characters.
        if s.len() > CHAR_BUF_INLINE {
            // Deliberately a plain `collect`. Sizing the `Vec` from the byte
            // length first (`with_capacity(s.len())` — one allocation instead
            // of the grow chain) measured SLOWER on every corpus: a `char` is
            // four bytes, so that asks the arena for four times what the text
            // needs, while growing into the arena's tail is nearly free.
            return CharBuf::Heap(s.chars().collect());
        }
        let mut chars = ['\0'; CHAR_BUF_INLINE];
        let mut len = 0;
        for (slot, c) in chars.iter_mut().zip(s.chars()) {
            *slot = c;
            len += 1;
        }
        CharBuf::Inline { chars, len }
    }
}

impl std::ops::Deref for CharBuf {
    type Target = [char];

    fn deref(&self) -> &[char] {
        match self {
            CharBuf::Inline { chars, len } => &chars[..*len],
            CharBuf::Heap(chars) => chars,
        }
    }
}

/// Index just past a quoted string starting at `start` (a `"` or `'`),
/// honouring `\` escapes. Returns `chars.len()` for an unterminated string.
fn skip_string(chars: &[char], start: usize) -> usize {
    let quote = chars[start];
    let mut i = start + 1;
    while i < chars.len() {
        match chars[i] {
            '\\' => i += 2,
            c if c == quote => return i + 1,
            _ => i += 1,
        }
    }
    chars.len()
}

/// Index of the `]` matching the `[` at `open`, skipping quoted strings and
/// escapes. Returns `chars.len()` when unmatched.
fn matching_bracket(chars: &[char], open: usize) -> usize {
    let mut i = open + 1;
    while i < chars.len() {
        match chars[i] {
            '\\' => i += 2,
            '"' | '\'' => i = skip_string(chars, i),
            ']' => return i,
            _ => i += 1,
        }
    }
    chars.len()
}

/// Validate the inner content of an `[…]` attribute selector. dart-sass allows
/// at most a single trailing ASCII-letter modifier, directly before the close
/// bracket: `[a]`, `[a=b]`, `[a=b ]`, `[a="b"i]`, and `[a=b i]` are valid, but
/// `[a b]` (no operator), `[a=b cd]` (too long), `[a=b 1]`/`[a=b _]`/`[a=b ï]`
/// (non-letter), and `[a=b i ]` (trailing space after the modifier) are not.
fn validate_attribute(inner: &[char]) -> Result<(), Error> {
    let err = || Error::unpositioned("expected \"]\".");
    let mut i = 0;
    let skip_ws = |i: &mut usize| {
        while *i < inner.len() && inner[*i].is_whitespace() {
            *i += 1;
        }
    };
    // Namespace + attribute name (identifiers, escapes, and a `|` namespace
    // separator); interpolation has already been resolved to literal text.
    skip_ws(&mut i);
    while i < inner.len() {
        let c = inner[i];
        if c == '\\' {
            i += 2;
        } else if is_name_char(c) || c == '|' || c == '*' {
            i += 1;
        } else {
            break;
        }
    }
    skip_ws(&mut i);
    if i >= inner.len() {
        return Ok(()); // bare `[name]`
    }
    // An operator must follow the name; anything else (e.g. a second
    // identifier in `[a b]`) is invalid.
    let op_ok = match inner[i] {
        '=' => true,
        '~' | '|' | '^' | '$' | '*' => inner.get(i + 1) == Some(&'='),
        _ => false,
    };
    if !op_ok {
        return Err(err());
    }
    i += if inner[i] == '=' { 1 } else { 2 };
    skip_ws(&mut i);
    // The value: a quoted string or an unquoted identifier (with escapes).
    match inner.get(i) {
        Some('"') | Some('\'') => i = skip_string(inner, i),
        Some(_) => {
            while i < inner.len() {
                let c = inner[i];
                if c == '\\' {
                    i += 2;
                } else if c.is_whitespace() {
                    break;
                } else {
                    i += 1;
                }
            }
        }
        None => return Err(err()),
    }
    skip_ws(&mut i);
    if i >= inner.len() {
        return Ok(()); // value, no modifier
    }
    // A modifier: exactly one ASCII letter, immediately before the close.
    if inner[i].is_ascii_alphabetic() && i + 1 == inner.len() {
        return Ok(());
    }
    Err(err())
}

fn is_name_char(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '-' || c == '_' || !c.is_ascii()
}

fn is_name_start(c: char) -> bool {
    c.is_ascii_alphabetic() || c == '_' || !c.is_ascii()
}

/// Whether `s` is a plain CSS identifier that needs no escaping — so a quoted
/// attribute value `"<s>"` can be emitted unquoted as `<s>` by simply dropping
/// the quotes. Matches dart-sass's `_isIdentifier` for the escape-free case:
/// a leading `-` must be followed by a name-start char (`--x`, `-1`, `-` alone
/// are not identifiers), the first significant char is a name-start, and the
/// rest are name chars. Strings containing escapes or non-name characters are
/// conservatively treated as non-identifiers (kept quoted) so nothing
/// regresses.
fn is_plain_css_identifier(s: &str) -> bool {
    let chars_buf = CharBuf::of(s);
    let chars: &[char] = &chars_buf;
    if chars.is_empty() {
        return false;
    }
    let mut i = 0;
    if chars[0] == '-' {
        i = 1;
    }
    match chars.get(i) {
        Some(&c) if is_name_start(c) => i += 1,
        _ => return false,
    }
    chars[i..].iter().all(|&c| is_name_char(c))
}

/// Canonicalize the interior of an `[…]` attribute selector for emit, matching
/// dart-sass's `[name op value modifier]` form: whitespace around the operator
/// and at the edges is removed, and a trailing single-letter modifier is
/// preceded by exactly one space. The value text is preserved verbatim (no
/// unquoting). On any parse uncertainty the original (trimmed) text is kept so
/// no currently-passing selector regresses.
fn normalize_attribute_text(inner: &str) -> String {
    let chars_buf = CharBuf::of(inner);
    let chars: &[char] = &chars_buf;
    let fallback = || inner.trim().to_string();
    let mut i = 0;
    let skip_ws = |i: &mut usize| {
        while *i < chars.len() && chars[*i].is_whitespace() {
            *i += 1;
        }
    };
    skip_ws(&mut i);
    // Namespace + name.
    let name_start = i;
    while i < chars.len() {
        let c = chars[i];
        if c == '\\' {
            i += 2;
        } else if is_name_char(c) || c == '|' || c == '*' {
            i += 1;
        } else {
            break;
        }
    }
    if i == name_start {
        return fallback();
    }
    let name: String = chars[name_start..i.min(chars.len())].iter().collect();
    skip_ws(&mut i);
    if i >= chars.len() {
        return name; // `[name]`
    }
    // Operator.
    let op: String = match chars[i] {
        '=' => {
            i += 1;
            "=".to_string()
        }
        c @ ('~' | '|' | '^' | '$' | '*') if chars.get(i + 1) == Some(&'=') => {
            i += 2;
            format!("{c}=")
        }
        _ => return fallback(),
    };
    skip_ws(&mut i);
    // Value (quoted string or unquoted run), preserved verbatim.
    let value_start = i;
    match chars.get(i) {
        Some('"') | Some('\'') => i = skip_string(chars, i),
        Some(_) => {
            while i < chars.len() {
                let c = chars[i];
                if c == '\\' {
                    i += 2;
                } else if c.is_whitespace() {
                    break;
                } else {
                    i += 1;
                }
            }
        }
        None => return fallback(),
    }
    let raw_value: String = chars[value_start..i.min(chars.len())].iter().collect();
    // dart-sass emits a quoted value unquoted when its content is a plain CSS
    // identifier (`[a="b"]` -> `[a=b]`). Only the escape-free, plain case is
    // unquoted here; anything needing re-escaping is kept verbatim.
    let value = unquote_plain_attribute_value(&raw_value);
    skip_ws(&mut i);
    if i >= chars.len() {
        return format!("{name}{op}{value}");
    }
    // A single-letter modifier (case-insensitive) before the close.
    if chars[i].is_ascii_alphabetic() && i + 1 == chars.len() {
        return format!("{name}{op}{value} {}", chars[i]);
    }
    fallback()
}

/// Drop the quotes from an attribute value when its content is a plain CSS
/// identifier; otherwise return it unchanged.
fn unquote_plain_attribute_value(raw: &str) -> String {
    let bytes_buf = CharBuf::of(raw);
    let bytes: &[char] = &bytes_buf;
    if bytes.len() >= 2 {
        let q = bytes[0];
        if (q == '"' || q == '\'') && bytes[bytes.len() - 1] == q {
            let content: String = bytes[1..bytes.len() - 1].iter().collect();
            if is_plain_css_identifier(&content) {
                return content;
            }
        }
    }
    raw.to_string()
}

/// Whether any TOP-LEVEL style rule (not nested inside an at-rule such as
/// `@media`) contains the extend `target` simple selector. Used to detect an
/// `@extend` that crosses a media-query boundary.
fn root_rule_contains_target(nodes: &[OutNode], target: &crate::selector::Simple) -> bool {
    nodes.iter().any(|node| match node {
        OutNode::Rule { selectors, .. } => selectors.to_strings().iter().any(|s| {
            crate::selector::parse_list(s)
                .map(|cs| crate::selector::list_contains_simple(&cs, target))
                .unwrap_or(false)
        }),
        _ => false,
    })
}

/// Walk the flattened output tree, rewriting each style-rule selector list per
/// the collected extensions and dropping rules whose every complex selector
/// still contains a placeholder. Recurses into at-rule bodies (e.g. `@media`),
/// but NOT into `@keyframes` (whose "selectors" are keyframe stops like `50%`).
/// Scoped extend pass: rewrite `nodes` belonging to module `scope` with the
/// extensions visible there (the module's own plus those of every module that
/// (transitively) loads it — dart-sass per-module ExtensionStores), recursing
/// into [`OutNode::ModuleScope`] wrappers with their own scope.
fn rewrite_nodes_scoped(
    nodes: &mut Vec<OutNode>,
    scope: &str,
    all: &[crate::selector::Extension],
    origins: &[String],
    closures: &HashMap<String, std::collections::HashSet<String>>,
    order: &ExtendOrderCtx,
) {
    // The extensions whose origin can reach `scope` along load edges. A
    // private placeholder target (`%-name`/`%_name`) is module-private:
    // only extensions written in the same module may match it.
    let visible: Vec<crate::selector::Extension> = all
        .iter()
        .zip(origins.iter())
        .filter(|(e, o)| {
            let reachable =
                o.as_str() == scope || closures.get(o.as_str()).is_some_and(|c| c.contains(scope));
            let private_ok = match &e.target {
                Some(crate::selector::Simple::Placeholder(n)) if n.starts_with('-') || n.starts_with('_') => {
                    o.as_str() == scope
                }
                _ => true,
            };
            reachable && private_ok
        })
        .map(|(e, _)| e.clone())
        .collect();
    // dart builds ONE `ExtensionStore` per module scope, then extends each rule
    // against it incrementally. Build the scope-fixed extend plan ONCE here and
    // reuse it for every rule in this scope, rather than re-deriving the whole
    // transitive closure per rule (the old O(rules × extensions) blow-up).
    let plan = crate::selector::build_extend_plan(
        &visible,
        scope,
        if order.has_import_clones {
            std::collections::HashMap::new()
        } else {
            order.rank_for(scope)
        },
        order.has_import_clones,
    );
    rewrite_with_scopes(nodes, &plan, scope, all, origins, closures, order);
}

/// The walk shared by [`rewrite_nodes_scoped`]: rules use the current scope's
/// `plan` (the prebuilt extend closure); a nested [`OutNode::ModuleScope`]
/// re-enters with its own scope and its own plan.
/// The module-graph context for dart's store-merge ORDER: reverse load
/// edges (who loads whom) plus each origin's first registration index.
pub(crate) struct ExtendOrderCtx {
    /// loaded module -> loaders (direct downstream modules).
    pub rev_deps: HashMap<String, Vec<String>>,
    /// origin -> smallest extension registration index (first-load rank).
    pub first_reg: HashMap<String, usize>,
    /// Module-loading `@import`s (clone scopes) are in play: dart merges the
    /// cloned subtree's extension stores into the IMPORTING module's own,
    /// which the pure-`@use` store-merge order below cannot express — fall
    /// back to the legacy fold order for the whole compile.
    pub has_import_clones: bool,
}

impl ExtendOrderCtx {
    /// The per-origin rank in `scope`'s downstream store-merge flatten:
    /// DFS from `scope` over reverse edges, visiting each level's direct
    /// downstream modules in DESCENDING first-load order (a later-loaded
    /// sibling's store registers earlier into the upstream's list), own
    /// store before its absorbed downstreams (pre-order).
    fn rank_for(&self, scope: &str) -> std::collections::HashMap<String, usize> {
        let mut rank = std::collections::HashMap::new();
        let mut next = 0usize;
        let mut stack: Vec<String> = Vec::new();
        let push_children =
            |of: &str, stack: &mut Vec<String>, rank: &std::collections::HashMap<String, usize>| {
                let mut kids: Vec<&String> = self
                    .rev_deps
                    .get(of)
                    .map(|v| {
                        v.iter()
                            .filter(|k| !rank.contains_key(*k) && k.as_str() != scope)
                            .collect()
                    })
                    .unwrap_or_default();
                // Descending first-load; push reversed so the largest pops first.
                kids.sort_by_key(|k| self.first_reg.get(*k).copied().unwrap_or(usize::MAX));
                for k in kids {
                    stack.push(k.clone());
                }
            };
        push_children(scope, &mut stack, &rank);
        while let Some(m) = stack.pop() {
            if rank.contains_key(&m) {
                continue;
            }
            rank.insert(m.clone(), next);
            next += 1;
            push_children(&m, &mut stack, &rank);
        }
        rank
    }
}

fn rewrite_with_scopes(
    nodes: &mut Vec<OutNode>,
    plan: &crate::selector::ExtendPlan,
    scope: &str,
    all: &[crate::selector::Extension],
    origins: &[String],
    closures: &HashMap<String, std::collections::HashSet<String>>,
    order: &ExtendOrderCtx,
) {
    for node in nodes.iter_mut() {
        match node {
            OutNode::ModuleScope { key, nodes } => {
                let key = key.clone();
                rewrite_nodes_scoped(nodes, &key, all, origins, closures, order);
            }
            OutNode::AtRule { name, body, .. } if !is_keyframes_name(name) => {
                rewrite_with_scopes(body, plan, scope, all, origins, closures, order);
            }
            _ => {}
        }
    }
    rewrite_nodes(nodes, plan, scope);
}

fn rewrite_nodes(nodes: &mut Vec<OutNode>, plan: &crate::selector::ExtendPlan, scope: &str) {
    let mut i = 0;
    while i < nodes.len() {
        let drop = match &mut nodes[i] {
            // Already rewritten (with its own scope) by rewrite_with_scopes;
            // drop the wrapper when nothing visible remains inside (so its
            // group separator doesn't leave a stray blank line). Post-eval,
            // group-end/pack-tight sentinels are inert (their eval-time
            // consumers have run), so a wrapper holding only markers — e.g. a
            // placeholder-only module whose rules were all dropped — counts
            // as empty too.
            OutNode::ModuleScope { nodes, .. } => {
                fn invisible(nodes: &[OutNode]) -> bool {
                    nodes.iter().all(|n| match n {
                        OutNode::Blank | OutNode::GroupEnd | OutNode::AtRootPackTight => true,
                        OutNode::ModuleScope { nodes, .. } => invisible(nodes),
                        _ => false,
                    })
                }
                invisible(nodes)
            }
            OutNode::Rule {
                selectors,
                linebreaks,
                extend_base,
                ..
            } => {
                {
                    match extend_selector_list(selectors, linebreaks, plan, scope, *extend_base) {
                        // No change → skip the clone + write-back entirely.
                        SelectorRewrite::Unchanged => false,
                        SelectorRewrite::Changed(s, b) => {
                            // Line-break flags travel with their selectors (dart's
                            // ComplexSelector.lineBreak): an original keeps its
                            // flag, an extend product takes its extender's.
                            *linebreaks = b;
                            *selectors = s;
                            false
                        }
                        // Entirely placeholders → drop the rule.
                        SelectorRewrite::Drop => true,
                    }
                }
            }
            OutNode::AtRule {
                body,
                has_block,
                kind,
                ..
            } => {
                // Body rules were already rewritten by rewrite_with_scopes
                // (which knows the per-module scopes); only the empty-group
                // drop remains here. A conditional group rule
                // (`@media`/`@supports`) whose body is emptied by placeholder
                // removal produces no CSS, so drop it. A GENERIC at-rule
                // survives an empty body, whatever its name spells
                // (`@#{"media"} screen {}` is `@media screen {}` in dart).
                *has_block && body.is_empty() && kind.is_conditional()
            }
            _ => false,
        };
        if drop {
            nodes.remove(i);
            // A dropped rule takes its OWN group separator with it — the Blank
            // that follows it (pushed when the next group arrived because this
            // rule had ended a group) — never the Blank before it, which
            // belongs to the previous group and still separates that group
            // from whatever visible node comes next (dart: `previous` is the
            // last VISIBLE node, and its `isGroupEnd` decides the blank line).
            // Two dropped rules from one statement (`%p { a: 1; > * {} }`)
            // used to eat both blanks, one each. Only at the very end, with
            // nothing following, is the preceding Blank the dangling one.
            // Inert eval-time markers may trail the dropped rule; look past
            // them for what actually follows.
            match nodes[i..].iter().position(|n| !n.is_inert_marker()) {
                Some(k) if matches!(nodes[i + k], OutNode::Blank) => {
                    nodes.remove(i + k);
                }
                Some(_) => {}
                None => {
                    // The preceding node may be an earlier dropped rule's
                    // `GroupEnd`; look back past inert markers too.
                    if let Some(j) = nodes[..i].iter().rposition(|n| !n.is_inert_marker()) {
                        if matches!(nodes[j], OutNode::Blank) {
                            // Removing a PRECEDING node shifts `i` back with it.
                            nodes.remove(j);
                            i -= 1;
                        }
                    }
                }
            }
        } else {
            i += 1;
        }
    }
}

/// True for `@keyframes` and its vendor-prefixed spellings, whose block
/// selectors are keyframe stops, not real selectors.
fn is_keyframes_name(name: &str) -> bool {
    let lower = name.to_ascii_lowercase();
    lower == "keyframes" || lower.ends_with("-keyframes")
}

/// Derive the default namespace for `@use "<url>"`: the final path component,
/// with any leading `_` removed and everything from the first `.` (i.e. all
/// extensions) discarded. dart-sass rejects a result that is not a valid Sass
/// identifier.
fn default_namespace(url: &str, pos: Pos) -> Result<String, Error> {
    let last = url.rsplit('/').next().unwrap_or(url);
    let last = last.strip_prefix('_').unwrap_or(last);
    // Strip every extension: the namespace is the basename up to its first dot.
    let stem = match last.split_once('.') {
        Some((before, _)) => before,
        None => last,
    };
    if !is_valid_namespace(stem) {
        return Err(Error::at(
            format!("The default namespace \"{stem}\" is not a valid Sass identifier."),
            pos,
        ));
    }
    Ok(stem.to_string())
}

/// Build a predicate deciding whether an upstream `$variable` (by bare name) is
/// re-exported through a `@forward`'s `show`/`hide` clause.
fn forward_var_visibility(
    show: &Option<Vec<crate::ast::ForwardMember>>,
    hide: &Option<Vec<crate::ast::ForwardMember>>,
) -> impl Fn(&str) -> bool {
    let show = member_set(show, true);
    let hide = member_set(hide, true);
    move |name: &str| -> bool {
        let n = normalize_var_name(name);
        if let Some(s) = &show {
            return s.contains(n.as_ref());
        }
        if let Some(h) = &hide {
            return !h.contains(n.as_ref());
        }
        true
    }
}

/// Canonicalize a Sass variable name: `-` and `_` are interchangeable, so the
/// canonical form replaces every `_` with `-` (dart-sass dash-insensitivity).
fn normalize_var_name(name: &str) -> Cow<'_, str> {
    // `-`/`_` are interchangeable; borrow when there is nothing to replace
    // (the overwhelmingly common case).
    if name.contains('_') {
        Cow::Owned(name.replace('_', "-"))
    } else {
        Cow::Borrowed(name)
    }
}

/// Whether a member name is private (dart-sass: a leading `-` or `_`), so it is
/// not accessible across module boundaries.
fn is_private_member(name: &str) -> bool {
    name.starts_with('-') || name.starts_with('_')
}

/// Whether `module` exposes `name` as a built-in mixin. dart-sass's `sass:meta`
/// module defines the `load-css` and `apply` mixins; no other built-in module
/// exposes a mixin. Matched dash/underscore-insensitively.
fn is_builtin_mixin(module: &str, name: &str) -> bool {
    if module != "meta" {
        return false;
    }
    matches!(normalize_arg_name(name).as_ref(), "load-css" | "apply")
}

/// Collect the names from a `@forward` `show`/`hide` member list, selecting
/// either the `$variable` entries (`vars == true`) or the function/mixin names.
/// Names are stored in canonical (dashed) form for dash-insensitive matching.
fn member_set(
    members: &Option<Vec<crate::ast::ForwardMember>>,
    vars: bool,
) -> Option<std::collections::HashSet<String>> {
    members.as_ref().map(|list| {
        list.iter()
            .filter_map(|m| match (m, vars) {
                (crate::ast::ForwardMember::Var(n), true) => Some(normalize_var_name(n).into_owned()),
                (crate::ast::ForwardMember::Name(n), false) => Some(normalize_var_name(n).into_owned()),
                _ => None,
            })
            .collect()
    })
}

/// Whether `s` is a valid Sass identifier usable as a module namespace.
fn is_valid_namespace(s: &str) -> bool {
    let mut chars = s.chars();
    match chars.next() {
        Some(c) if c == '_' || c == '-' || c.is_ascii_alphabetic() || !c.is_ascii() => {}
        _ => return false,
    }
    chars.all(|c| c == '_' || c == '-' || c.is_ascii_alphanumeric() || !c.is_ascii())
}

/// The outcome of extending one rule's selector list.
enum SelectorRewrite {
    /// The selector needs no change — leave the rule's selectors in place
    /// (no clone, no write-back). The common case on extend-free stylesheets.
    Unchanged,
    /// The selector was extended/placeholder-stripped — replace it.
    Changed(RuleSelectors, Vec<bool>),
    /// Every complex selector is still a placeholder after extension, so the
    /// rule emits no CSS — drop it.
    Drop,
}

/// Compute the extended selector list for a rule. [`SelectorRewrite::Drop`]
/// when, after extension, every complex selector still contains a placeholder
/// (the rule emits no CSS); [`SelectorRewrite::Unchanged`] when the selector
/// needs no change (so the caller skips the clone + write-back entirely).
///
/// Phase 1d: the engine works on the typed [`crate::selector::Complex`] model
/// and the result is carried as [`RuleSelectors::Parsed`] — emit renders it
/// directly, so there is no `join(", ")` + `parse_list` round trip back to
/// strings. The fast path (no `@extend` and no placeholder) and the
/// unparseable fallback keep the rule's original [`RuleSelectors::Raw`] strings
/// untouched, byte-for-byte.
fn extend_selector_list(
    selectors: &RuleSelectors,
    breaks: &[bool],
    plan: &crate::selector::ExtendPlan,
    scope: &str,
    extend_base: usize,
) -> SelectorRewrite {
    // Fast path: no extensions and no placeholder → the selector is untouched.
    // Crucially this leaves selectors we don't model (keyframe stops are handled
    // separately, but also unusual selectors) byte-for-byte intact.
    //
    // The placeholder probe is a full `%` scan of every selector of the rule, and
    // it is only ever read here — so it runs only when `plan.is_empty()` has
    // already said the answer can matter. With extensions in scope this pass has
    // to parse and extend regardless, and the scan was pure waste.
    let has_placeholder = || match selectors {
        RuleSelectors::Raw(v) => v.iter().any(|s| s.contains('%')),
        RuleSelectors::Parsed(v) => v.iter().any(crate::selector::complex_has_placeholder),
    };
    if plan.is_empty() && !has_placeholder() {
        return SelectorRewrite::Unchanged;
    }
    // Parse the rule's selectors into the typed model exactly once. A `Raw`
    // rule (the only shape an evaluated rule arrives in) is joined and parsed
    // here; a `Parsed` rule (a re-entered already-rewritten list, not produced
    // today) is borrowed directly.
    let parsed_owned;
    let parsed: &[crate::selector::Complex] = match selectors {
        RuleSelectors::Raw(v) => {
            let joined = v.join(", ");
            match crate::selector::parse_list(&joined) {
                Some(p) => {
                    parsed_owned = p;
                    &parsed_owned
                }
                // Unparseable selector: never lose it; leave untouched.
                None => return SelectorRewrite::Unchanged,
            }
        }
        RuleSelectors::Parsed(v) => v,
    };
    let result = crate::selector::extend_selectors(parsed, breaks, plan, scope, extend_base);
    if result.all_placeholders {
        return SelectorRewrite::Drop;
    }
    SelectorRewrite::Changed(RuleSelectors::Parsed(result.selectors.into()), result.breaks)
}

/// For each non-empty top-level comma part of a selector list, whether the
/// emitted complex selector should begin on its own line — parallel to the
/// parts `resolve_selectors` keeps.
///
/// dart-sass carries a per-complex `lineBreak` flag set when a newline precedes
/// the part in source (`a,\nb`). During parent resolution that flag survives for
/// an *implicit*-parent part (`parent.lineBreak || child.lineBreak`), but a part
/// that *references* the parent with `&` takes the parent complex's flag instead
/// and drops its own. We don't track parent line-breaks, so for a `&`-part in a
/// nested rule we conservatively report `false` (correct whenever the governing
/// parent is the first/unbroken one, and never emits a break dart-sass wouldn't).
fn comma_linebreaks(sel: &str, nested: bool) -> Vec<bool> {
    // An EMPTY comma part (a stray trailing/doubled comma) is dropped, but a
    // newline inside it still belongs to the next real part:
    // `#foo #bar,,\n,#baz #boom,` keeps `#baz #boom` on its own line.
    let mut out = Vec::new();
    let mut pending_nl = false;
    let segs = split_commas(sel);
    for (i, seg) in segs.iter().enumerate() {
        if seg.trim().is_empty() {
            pending_nl = pending_nl || (i > 0 && seg.contains('\n'));
            continue;
        }
        // dart marks a complex as line-broken when ANY newline sits between
        // it and the previous one — including BEFORE the comma (`a\n, b`).
        let leading_nl = seg.chars().take_while(|c| c.is_whitespace()).any(|c| c == '\n');
        let prev_trailing_nl = i > 0
            && segs[i - 1]
                .chars()
                .rev()
                .take_while(|c| c.is_whitespace())
                .any(|c| c == '\n');
        let newline_before = i > 0 && (leading_nl || prev_trailing_nl);
        out.push((newline_before || pending_nl) && !(nested && part_has_parent_ref(seg)));
        pending_nl = false;
    }
    out
}

/// Whether a selector comma-part contains a top-level parent reference `&`
/// (not inside `[…]` or a quoted string). Interpolation has already been
/// resolved into `sel` by the time this runs, so a `&` here is a real parent
/// reference.
fn part_has_parent_ref(part: &str) -> bool {
    let mut bracket = 0i32;
    let mut quote: Option<char> = None;
    let mut chars = part.chars();
    while let Some(c) = chars.next() {
        match quote {
            Some(q) => {
                if c == '\\' {
                    chars.next();
                } else if c == q {
                    quote = None;
                }
            }
            None => match c {
                // `\&` is an ampersand in an identifier, not a parent
                // reference.
                '\\' => {
                    chars.next();
                }
                '"' | '\'' => quote = Some(c),
                '[' => bracket += 1,
                ']' => bracket = (bracket - 1).max(0),
                '&' if bracket == 0 => return true,
                _ => {}
            },
        }
    }
    false
}

/// The char index of the first `@` outside quoted strings in a resolved
/// selector, if any — `@` has no legal position in a CSS selector.
fn find_unquoted_at(sel: &str) -> Option<usize> {
    // `@` is ASCII: no `@` byte means no occurrence at all — skip the
    // quote-tracking walk that otherwise runs for every resolved selector.
    if !sel.as_bytes().contains(&b'@') {
        return None;
    }
    let mut quote: Option<char> = None;
    let mut iter = sel.chars().enumerate();
    while let Some((i, c)) = iter.next() {
        match quote {
            Some(q) => {
                if c == '\\' {
                    iter.next();
                } else if c == q {
                    quote = None;
                }
            }
            None => match c {
                '"' | '\'' => quote = Some(c),
                '\\' => {
                    iter.next();
                }
                '@' => return Some(i),
                _ => {}
            },
        }
    }
    None
}

/// Replace top-level `&` parent references with `parent`. A `&` inside `[…]`
/// or a quoted string is literal text (issue_2291 `[str="&"]` keeps its
/// ampersand); one inside pseudo parentheses is still a real reference.
fn replace_parent_refs(part: &str, parent: &str) -> String {
    let mut out = String::with_capacity(part.len() + parent.len());
    let mut bracket = 0i32;
    let mut quote: Option<char> = None;
    let mut chars = part.chars();
    while let Some(c) = chars.next() {
        match quote {
            Some(q) => {
                out.push(c);
                if c == '\\' {
                    if let Some(n) = chars.next() {
                        out.push(n);
                    }
                } else if c == q {
                    quote = None;
                }
            }
            None => match c {
                '\\' => {
                    out.push(c);
                    if let Some(n) = chars.next() {
                        out.push(n);
                    }
                }
                '"' | '\'' => {
                    quote = Some(c);
                    out.push(c);
                }
                '[' => {
                    bracket += 1;
                    out.push(c);
                }
                ']' => {
                    bracket = (bracket - 1).max(0);
                    out.push(c);
                }
                '&' if bracket == 0 => out.push_str(parent),
                _ => out.push(c),
            },
        }
    }
    out
}

/// Count a part's TOP-LEVEL `&` references (outside parens/brackets) and split
/// it into the segments between them. With k >= 2 refs the part expands to the
/// parents' k-fold cartesian product (`& &` under `ul, ol` is
/// `ul ul, ul ol, ol ul, ol ol`, issue_1710); with fewer, a cheaper path
/// resolves it and there is nothing to split, so `None` comes back having
/// allocated nothing at all — a part with one `&` or none is the common case.
/// The segments are borrowed: they are the substrings between the references,
/// character for character.
fn split_parent_refs(part: &str) -> Option<Vec<&str>> {
    let mut first: Option<usize> = None;
    // Stays empty — and unallocated — until a SECOND reference proves the part
    // is cartesian; only then does the first one become a cut too.
    let mut cuts: Vec<usize> = Vec::new();
    let mut depth = 0i32;
    let mut quote: Option<char> = None;
    let mut escaped = false;
    for (i, c) in part.char_indices() {
        if let Some(q) = quote {
            // `\"` does not end a `"`-quoted value, and a quote that ends
            // early would swallow the `]` after it and hide every top-level
            // `&` that follows.
            if std::mem::take(&mut escaped) {
                continue;
            }
            if c == '\\' {
                escaped = true;
            } else if c == q {
                quote = None;
            }
            continue;
        }
        // The character a backslash escapes is skipped by the branch above on
        // the next turn, so `\&` is a literal rather than a reference.
        if std::mem::take(&mut escaped) {
            continue;
        }
        match c {
            '\\' => escaped = true,
            '"' | '\'' => quote = Some(c),
            '(' | '[' => depth += 1,
            ')' | ']' => depth -= 1,
            '&' if depth == 0 => match first {
                None => first = Some(i),
                Some(f) => {
                    if cuts.is_empty() {
                        cuts.push(f);
                    }
                    cuts.push(i);
                }
            },
            _ => {}
        }
    }
    if cuts.is_empty() {
        return None;
    }
    let mut segments = Vec::with_capacity(cuts.len() + 1);
    let mut start = 0;
    for cut in cuts {
        segments.push(&part[start..cut]);
        start = cut + 1; // '&' is ASCII (1 byte)
    }
    segments.push(&part[start..]);
    Some(segments)
}

/// One rule's resolved selector list: the complexes, and their source
/// line-break flags only when the caller asked for them. A selector list with
/// no newline in it, under parents that carry no break of their own, has
/// all-false flags — which every consumer already reads off an EMPTY vec — so
/// on that shape, which is nearly every rule, the flags are not collected at
/// all. Keeping the two as separate lists is also what lets the caller take the
/// complexes as they are: paired into tuples they would have to be unzipped
/// again, into two fresh vectors, one of which it then drops.
struct ResolvedSelectors {
    sels: Vec<String>,
    /// Empty unless `flags`; parallel to `sels` when collected.
    lbs: Vec<bool>,
    flags: bool,
    /// True unless **every** selector in `sels` was proved canonical by
    /// [`canonical_plain`]. Because that predicate's byte set is disjoint from
    /// `has_bogus_trigger`'s `> + ~ (`, `false` *proves* no selector in the
    /// list can be a bogus-combinator complex — which is what lets the emitter
    /// skip `complex_selector_block_is_bogus` for the whole list instead of
    /// scanning every byte of every selector. `true` means "not proved", never
    /// "has one".
    maybe_bogus: bool,
    /// True if any selector in `sels` contains a `%`. Only a `%`-bearing
    /// selector can be a placeholder rule, so `false` lets the emitter skip its
    /// per-selector placeholder bookkeeping outright.
    any_percent: bool,
}

impl ResolvedSelectors {
    fn new(flags: bool) -> ResolvedSelectors {
        ResolvedSelectors {
            sels: Vec::new(),
            lbs: Vec::new(),
            flags,
            maybe_bogus: false,
            any_percent: false,
        }
    }

    fn len(&self) -> usize {
        self.sels.len()
    }

    fn reserve(&mut self, additional: usize) {
        self.sels.reserve(additional);
        if self.flags {
            self.lbs.reserve(additional);
        }
    }

    /// Push a selector that is already normalized and whose facts are already
    /// accounted for — the row-of-rows merge, where the strings move across
    /// from rows whose flags arrive via [`ResolvedSelectors::absorb`]. Every
    /// other caller goes through [`ResolvedSelectors::push_owned`] or
    /// [`ResolvedSelectors::push_ref`], which is what keeps the flags honest:
    /// normalizing inside the push is the only way they stay free.
    fn push_merged(&mut self, sel: String, lb: bool) {
        self.sels.push(sel);
        if self.flags {
            self.lbs.push(lb);
        }
    }

    /// Normalize an owned selector and push it, recording what its canonical
    /// scan saw.
    fn push_owned(&mut self, sel: String, lb: bool) {
        self.push_normalized(normalize_selector_owned_facts(sel), lb);
    }

    /// Normalize a borrowed selector and push it, recording what its canonical
    /// scan saw.
    fn push_ref(&mut self, sel: &str, lb: bool) {
        self.push_normalized(normalize_selector_facts(sel), lb);
    }

    fn push_normalized(&mut self, n: Normalized, lb: bool) {
        self.maybe_bogus |= !n.canonical;
        self.any_percent |= n.percent;
        self.push_merged(n.sel, lb);
    }

    /// OR another list's facts into this one. Used by the row-of-rows merge,
    /// whose selectors are pushed with [`ResolvedSelectors::push_merged`] and so
    /// carry no facts of their own.
    fn absorb(&mut self, other: &ResolvedSelectors) {
        self.maybe_bogus |= other.maybe_bogus;
        self.any_percent |= other.any_percent;
    }
}

/// Resolve a selector against its parents with dart's `implicitParent` switch: inside
/// `@at-root` (before the first nested style rule) a part WITHOUT `&` stays
/// at the root instead of joining the parent, while `&` still substitutes.
/// Also derives each output complex's source line-break flag (dart carries
/// `lineBreak` on the ComplexSelector object): a part WITHOUT `&` keeps its
/// own flag OR'd with the joined parent's; a part WITH `&` drops its own flag
/// and takes the substituted parent's (dart rebuilds those complexes from a
/// `lineBreak: false` base); a k>=2 cartesian combo ORs its chosen parents'.
/// The flags are only derived when `want_linebreaks` says the caller has a use
/// for them.
fn resolve_selectors_opt(
    sel: &str,
    parents: &[String],
    implicit_parent: bool,
    part_lbs: &[bool],
    parent_lbs: &[bool],
    want_linebreaks: bool,
) -> Result<ResolvedSelectors, Error> {
    // Borrowed: every part is a contiguous substring of `sel` and nothing below
    // needs to own one, so a rule pays no `String` per selector part. A
    // selector with no top-level comma is a single part, which is the common
    // shape of a nested rule, and it reads out of a fixed slot instead of a
    // heap vector.
    let single;
    let many;
    let parts: &[&str] = match split_commas(sel) {
        Segments::One(p) => {
            single = [trim_selector_part(p)];
            if single[0].is_empty() {
                &[]
            } else {
                &single
            }
        }
        Segments::Many(v) => {
            many = v
                .into_iter()
                .map(trim_selector_part)
                .filter(|p| !p.is_empty())
                .collect::<Vec<_>>();
            &many
        }
    };
    // dart: a parent that ends in a combinator can't substitute into a `&`
    // that is part of a compound (`.a > { &.b {} }` errors; `& .b` is fine).
    let check_compound_parent = |part: &str, parent: &str| -> Result<(), Error> {
        let trimmed = parent.trim_end();
        if !matches!(trimmed.chars().last(), Some('>' | '+' | '~')) {
            return Ok(());
        }
        let chars_buf = CharBuf::of(part);
        let chars: &[char] = &chars_buf;
        let mut skip = false;
        let mut bracket = 0i32;
        let mut quote: Option<char> = None;
        for (i, &c) in chars.iter().enumerate() {
            if std::mem::take(&mut skip) {
                continue;
            }
            if c == '\\' {
                skip = true;
                continue;
            }
            if let Some(q) = quote {
                if c == q {
                    quote = None;
                }
                continue;
            }
            match c {
                '"' | '\'' => {
                    quote = Some(c);
                    continue;
                }
                '[' => bracket += 1,
                ']' => bracket = (bracket - 1).max(0),
                _ => {}
            }
            // An `&` inside an attribute is not a parent reference.
            if c == '&' && bracket == 0 {
                if let Some(&next) = chars.get(i + 1) {
                    if next.is_alphanumeric()
                        || matches!(next, '.' | '#' | ':' | '[' | '%' | '\\' | '-' | '_')
                    {
                        return Err(Error::unpositioned(format!(
                            "Selector \"{trimmed}\" can't be used as a parent in a compound selector."
                        )));
                    }
                }
            }
        }
        Ok(())
    };
    // A `&` that sits only inside pseudo arguments takes the WHOLE parent
    // list in place (dart: `:not(&-c)` under `.a, .b` is `:not(.a-c, .b-c)`,
    // ONE complex — no cartesian expansion). A part with any top-level `&`
    // (or a pseudo-`&` glued to a non-suffix simple) uses the normal path.
    let substitute_pseudo_refs = |part: &str| -> Option<String> {
        if !part.contains('&') {
            return None;
        }
        let chars_buf = CharBuf::of(part);
        let chars: &[char] = &chars_buf;
        let mut depth = 0i32;
        let mut bracket = 0i32;
        let mut quote: Option<char> = None;
        let mut out = String::new();
        let mut i = 0;
        let mut replaced = false;
        while i < chars.len() {
            let c = chars[i];
            if let Some(q) = quote {
                out.push(c);
                i += 1;
                if c == '\\' {
                    if let Some(&n) = chars.get(i) {
                        out.push(n);
                        i += 1;
                    }
                } else if c == q {
                    quote = None;
                }
                continue;
            }
            match c {
                '\\' => {
                    out.push(c);
                    i += 1;
                    if let Some(&n) = chars.get(i) {
                        out.push(n);
                        i += 1;
                    }
                    continue;
                }
                '"' | '\'' => quote = Some(c),
                '[' => bracket += 1,
                ']' => bracket = (bracket - 1).max(0),
                '(' => depth += 1,
                ')' => depth -= 1,
                // An `&` inside an attribute is text: copy it and let the
                // normal path handle the part.
                '&' if bracket > 0 => {}
                '&' => {
                    if depth == 0 {
                        return None;
                    }
                    // Collect an identifier suffix (`&-c`); any other glued
                    // simple (`&.x`, `&:h`) bails to the normal path.
                    let mut suffix = String::new();
                    let mut j = i + 1;
                    while j < chars.len() && (chars[j].is_alphanumeric() || matches!(chars[j], '-' | '_')) {
                        suffix.push(chars[j]);
                        j += 1;
                    }
                    if matches!(chars.get(j), Some('.' | '#' | ':' | '[' | '%' | '\\' | '&')) {
                        return None;
                    }
                    let expansion = parents
                        .iter()
                        .map(|p| format!("{p}{suffix}"))
                        .collect::<Vec<_>>()
                        .join(", ");
                    out.push_str(&expansion);
                    replaced = true;
                    i = j;
                    continue;
                }
                _ => {}
            }
            out.push(c);
            i += 1;
        }
        if replaced {
            Some(out)
        } else {
            None
        }
    };
    let expand_cartesian = |segments: &[&str], result: &mut ResolvedSelectors| {
        let k = segments.len() - 1;
        let n = parents.len();
        let mut idx = vec![0usize; k];
        loop {
            let mut s = String::new();
            for (i, seg) in segments[..k].iter().enumerate() {
                s.push_str(seg);
                s.push_str(&parents[idx[i]]);
            }
            s.push_str(segments[k]);
            // A `&` nested in pseudo parens is NOT a cartesian position (the
            // split counts depth-0 refs only) but still substitutes — with
            // the whole parent list, like any pseudo-`&`
            // (quasar: `&-container:not(&--mini-animate) &--mini`).
            let s = substitute_pseudo_refs(&s).unwrap_or(s);
            // The combo's flag ORs its chosen parents' flags (mastodon's
            // adjacent-state selectors break per combo, not per template).
            let flag = idx.iter().any(|&pi| parent_lbs.get(pi).copied().unwrap_or(false));
            result.push_owned(s, flag);
            // Increment with the LAST ref fastest (dart's order).
            let mut j = k;
            loop {
                if j == 0 {
                    return;
                }
                j -= 1;
                idx[j] += 1;
                if idx[j] < n {
                    break;
                }
                idx[j] = 0;
            }
        }
    };
    let mut result = ResolvedSelectors::new(want_linebreaks);
    if parents.is_empty() {
        // At the document root (no enclosing style rule) a parent selector `&`
        // has no parent to substitute, so dart-sass keeps it literal: `& {a: b}`
        // emits `& {\u{2026}}` and `&.foo {\u{2026}}` emits `&.foo {\u{2026}}`. (A `&`-with-suffix
        // such as `&foo` is rejected earlier by `validate_selector`.)
        result.reserve(parts.len());
        for (pi, part) in parts.iter().enumerate() {
            result.push_ref(part, part_lbs.get(pi).copied().unwrap_or(false));
        }
    } else if !implicit_parent {
        // dart resolves per complex: a part with `&` expands across the
        // parents; a part without stays at the root exactly once.
        for (part_i, part) in parts.iter().enumerate() {
            if let Some(s) = substitute_pseudo_refs(part) {
                result.push_owned(s, false);
            } else if let Some(segments) = split_parent_refs(part) {
                for parent in parents {
                    check_compound_parent(part, parent)?;
                }
                expand_cartesian(&segments, &mut result);
            } else if part_has_parent_ref(part) {
                for (pi, parent) in parents.iter().enumerate() {
                    check_compound_parent(part, parent)?;
                    result.push_owned(
                        replace_parent_refs(part, parent),
                        parent_lbs.get(pi).copied().unwrap_or(false),
                    );
                }
            } else {
                result.push_ref(part, part_lbs.get(part_i).copied().unwrap_or(false));
            }
        }
    } else {
        // dart `resolveParentSelectors`: each part resolves to its own ROW of
        // complexes, and the final list is `flattenVertically(rows)` —
        // column-major across the parts. For `&`-less and single-`&` parts
        // (rows of exactly `parents.len()`) that is the familiar parent-major
        // order; a part with k >= 2 top-level refs contributes a row of
        // `parents.len()^k` combos, interleaved column-by-column with its
        // sibling parts (mastodon's `&:hover + &:is(...)` lists).
        // One part's row, appended to `out`.
        let resolve_row = |part_i: usize, part: &str, out: &mut ResolvedSelectors| -> Result<(), Error> {
            // A pseudo-only `&` part resolves ONCE (whole parent list in
            // place): a single-entry row.
            if let Some(s) = substitute_pseudo_refs(part) {
                out.push_owned(s, false);
                return Ok(());
            }
            if let Some(segments) = split_parent_refs(part) {
                for parent in parents {
                    check_compound_parent(part, parent)?;
                }
                expand_cartesian(&segments, out);
                return Ok(());
            }
            let has_ref = part_has_parent_ref(part);
            for (pi, parent) in parents.iter().enumerate() {
                let parent_lb = parent_lbs.get(pi).copied().unwrap_or(false);
                let (combined, flag) = if has_ref {
                    check_compound_parent(part, parent)?;
                    // A `&` part drops its own source flag (dart rebuilds the
                    // complex from a lineBreak:false base) and takes the
                    // substituted parent's.
                    (replace_parent_refs(part, parent), parent_lb)
                } else {
                    // The joined length is known, so the buffer is sized once
                    // here instead of growing out of an empty `format!`.
                    let mut combined = String::with_capacity(parent.len() + 1 + part.len());
                    combined.push_str(parent);
                    combined.push(' ');
                    combined.push_str(part);
                    (
                        combined,
                        part_lbs.get(part_i).copied().unwrap_or(false) || parent_lb,
                    )
                };
                out.push_owned(combined, flag);
            }
            Ok(())
        };
        // A single part is a single row, and flattening one row leaves it in
        // its own order: it resolves straight into the result, without the
        // row-of-rows scaffolding the general case needs.
        if let [part] = parts {
            result.reserve(parents.len());
            resolve_row(0, part, &mut result)?;
        } else {
            let mut rows: Vec<ResolvedSelectors> = Vec::with_capacity(parts.len());
            for (part_i, part) in parts.iter().enumerate() {
                let mut row = ResolvedSelectors::new(want_linebreaks);
                row.reserve(parents.len());
                resolve_row(part_i, part, &mut row)?;
                rows.push(row);
            }
            let longest = rows.iter().map(|r| r.len()).max().unwrap_or(0);
            result.reserve(rows.iter().map(|r| r.len()).sum());
            // The strings move across already normalized, so their facts come
            // from the rows that normalized them.
            for row in &rows {
                result.absorb(row);
            }
            for j in 0..longest {
                // Each slot is read exactly once, so the string moves out instead
                // of being cloned; what stays behind is an empty `String`, which
                // owns no buffer, and `rows` is dropped right after.
                for row in rows.iter_mut() {
                    if let Some(sel) = row.sels.get_mut(j) {
                        let lb = row.lbs.get(j).copied().unwrap_or(false);
                        result.push_merged(std::mem::take(sel), lb);
                    }
                }
            }
        }
    }
    Ok(result)
}

/// `s.trim()` without an allocation when `s` has no surrounding whitespace —
/// the common case for an evaluated property name, which is trimmed on every
/// declaration and almost never has anything to lose. Hands back the same
/// shared buffer (`trim` removed nothing → same length) instead of copying the
/// bytes into a fresh one.
fn trim_shared(s: Rc<str>) -> Rc<str> {
    if s.trim().len() == s.len() {
        s
    } else {
        Rc::from(s.trim())
    }
}

/// The segments [`split_commas`] found. The overwhelmingly common shape has no
/// top-level comma at all, and that case is the whole reason this type exists:
/// it keeps the single segment inline instead of putting it in a one-element
/// `Vec`. Both variants deref to a slice, so a caller reads either shape as
/// `&[&str]`.
enum Segments<'a> {
    One(&'a str),
    Many(Vec<&'a str>),
}

impl<'a> std::ops::Deref for Segments<'a> {
    type Target = [&'a str];

    fn deref(&self) -> &[&'a str] {
        match self {
            Segments::One(s) => std::slice::from_ref(s),
            Segments::Many(v) => v,
        }
    }
}

/// Split `s` on top-level commas (paren/bracket depth 0), returning borrowed
/// slices of `s` — no per-part allocation. Commas inside `(...)`/`[...]` stay
/// within their part. Each part is a contiguous substring of `s`, so callers
/// that need an owned `String` call `.to_string()` themselves.
fn split_commas(s: &str) -> Segments<'_> {
    // No comma anywhere means one segment, whatever the nesting structure.
    if !s.as_bytes().contains(&b',') {
        return Segments::One(s);
    }
    let mut out = Vec::new();
    let mut paren = 0i32;
    let mut bracket = 0i32;
    let mut start = 0usize;
    let mut escaped = false;
    for (idx, c) in s.char_indices() {
        // `\,` is a comma IN AN IDENTIFIER, not a list separator.
        if escaped {
            escaped = false;
            continue;
        }
        match c {
            '\\' => escaped = true,
            '(' => paren += 1,
            ')' => paren -= 1,
            '[' => bracket += 1,
            ']' => bracket -= 1,
            ',' if paren == 0 && bracket == 0 => {
                out.push(&s[start..idx]);
                start = idx + 1; // ',' is ASCII (1 byte)
            }
            _ => {}
        }
    }
    out.push(&s[start..]);
    Segments::Many(out)
}

/// Collapse whitespace and put single spaces around `>`/`+`/`~`
/// combinators (at bracket depth 0), matching dart-sass's selector
/// serialization. Also separates adjacent compounds: a bare type/element
/// selector appearing mid-compound (`[a]b`, `:not(.x)b`) is joined to the
/// preceding simple with a descendant combinator (`[a] b`), matching
/// dart-sass's `[adjacent-compounds]` normalization.
pub(crate) fn normalize_selector(s: &str) -> String {
    normalize_selector_facts(s).sel
}

/// A normalized selector plus the two facts its canonical scan yielded **for
/// free**. `canonical` is a *proof* that the selector carries no
/// bogus-combinator trigger, because [`canonical_plain`]'s byte set is disjoint
/// from `has_bogus_trigger`'s `> + ~ (`; `percent` is the placeholder probe the
/// emitter would otherwise repeat per selector. Both fall out of a loop that had
/// to run anyway to decide the fast path, which is the entire reason they are
/// collected here instead of scanned for downstream.
struct Normalized {
    sel: String,
    /// The selector was *proved* canonical. `false` means "not proved" — it
    /// says nothing about whether a trigger byte is actually present.
    canonical: bool,
    /// The normalized selector contains a `%`.
    percent: bool,
}

/// [`normalize_selector`], reporting what the canonical scan saw.
fn normalize_selector_facts(s: &str) -> Normalized {
    // Fast path: already-canonical selectors skip the two char-vector
    // materializations below. The `debug_assert`s ARE the proof of that: every
    // debug-built test run and every debug spec run re-checks fast == slow on
    // every call, which is the harness this fast path was originally validated
    // against and is cheaper to keep than to rebuild.
    match canonical_plain(s) {
        Some(percent) => {
            debug_assert_canonical(s, percent);
            Normalized {
                sel: s.to_string(),
                canonical: true,
                percent,
            }
        }
        None => {
            let sel = normalize_selector_slow(s);
            let percent = sel.contains('%');
            Normalized {
                sel,
                canonical: false,
                percent,
            }
        }
    }
}

/// The three invariants the canonical fast path rests on, checked on every call
/// in a debug build and compiled out of release: the normalizer would have
/// returned the selector unchanged, the scan's `%` answer matches a plain
/// search, and the accepted byte set really is disjoint from the
/// bogus-combinator triggers — the last one so that widening
/// [`canonical_plain`] cannot silently break `ResolvedSelectors::maybe_bogus`.
#[inline]
fn debug_assert_canonical(s: &str, percent: bool) {
    debug_assert_eq!(
        normalize_selector_slow(s),
        s,
        "canonical_plain accepted a selector the normalizer would rewrite"
    );
    debug_assert_eq!(percent, s.contains('%'), "canonical scan missed a `%`");
    debug_assert!(
        !has_bogus_trigger(s),
        "the canonical byte set overlaps a bogus-combinator trigger"
    );
}

/// Whether `s` is already in canonical form without running the normalizer:
/// only plain compound characters (ASCII letters/digits, `_-.#%:`) separated
/// by single descendant spaces, with no leading/trailing space. `None` means
/// not canonical; `Some(percent)` means canonical, and reports whether the scan
/// passed a `%` — the same loop over the same bytes answers both questions,
/// which is what makes [`ResolvedSelectors::any_percent`] free. Every rewrite
/// `normalize_selector` performs — whitespace collapse, hex-escape handling,
/// attribute/pseudo/combinator canonicalization — is triggered by a character
/// outside this set.
///
/// `:` is in the set, which is what admits the overwhelmingly common
/// `.btn:hover` / `a::before` shape, and it is sound for a reason worth writing
/// down because the set cannot be widened by eye. On input drawn from this set
/// the slow path is the *identity*, in three steps:
///
/// 1. The whitespace-collapse pass rewrites nothing: there is no `\`, no
///    whitespace other than single interior spaces, and no leading or trailing
///    space to trim.
/// 2. A `:` is consumed by `copy_pseudo`, which copies the colon(s) and then
///    the name via `copy_name` — verbatim, since `has_escape` is false — and
///    skips its argument branch entirely because there is no `(`. Both canon
///    probes then decline on their first line: `normalize_nth` and
///    `normalize_pseudo_arg` each open with `text.find('(')?`.
/// 3. The adjacent-compound rewrite (the one that inserts a descendant space
///    mid-compound) cannot fire. It needs `type_selector_starts_at` to be true
///    while `mid_compound` is set, and every boundary character in this set
///    consumes its own name through `copy_name`, whose `is_name_char` excludes
///    `. # % :` — so after any simple selector the next character is one of
///    `. # % :` or a space, and none of those starts a type selector.
///
/// Do **not** add `> + ~` here on the strength of the same argument: the slow
/// path rewrites `>a` to `> a`, so those need a separate proof about spacing
/// and the trailing-combinator case. The set is also deliberately disjoint from
/// `has_bogus_trigger`'s `> + ~ (`, so passing this predicate proves a selector
/// carries no bogus-combinator trigger — an invariant
/// [`ResolvedSelectors::maybe_bogus`] now depends on and
/// [`debug_assert_canonical`] pins.
fn canonical_plain(s: &str) -> Option<bool> {
    let b = s.as_bytes();
    if b.is_empty() || b[0] == b' ' || b[b.len() - 1] == b' ' {
        return None;
    }
    let mut prev_space = false;
    let mut percent = false;
    for &c in b {
        match c {
            b'%' => {
                percent = true;
                prev_space = false;
            }
            b'a'..=b'z' | b'A'..=b'Z' | b'0'..=b'9' | b'_' | b'-' | b'.' | b'#' | b':' => {
                prev_space = false;
            }
            b' ' => {
                if prev_space {
                    return None;
                }
                prev_space = true;
            }
            _ => return None,
        }
    }
    Some(percent)
}

/// [`normalize_selector`] for a string the caller already owns: hands the
/// buffer back untouched when it is already canonical, instead of copying its
/// bytes into a fresh `String`. Every selector this module builds by
/// substituting a parent (`format!("{parent} {part}")`, `replace_parent_refs`)
/// is owned and canonical, which is the common shape of a nested rule.
fn normalize_selector_owned_facts(s: String) -> Normalized {
    match canonical_plain(&s) {
        Some(percent) => {
            debug_assert_canonical(&s, percent);
            Normalized {
                sel: s,
                canonical: true,
                percent,
            }
        }
        None => {
            let sel = normalize_selector_slow(&s);
            let percent = sel.contains('%');
            Normalized {
                sel,
                canonical: false,
                percent,
            }
        }
    }
}

fn normalize_selector_slow(s: &str) -> String {
    // Collapse runs of whitespace to single spaces (and trim) — but a hex
    // escape's single terminating whitespace is PART of the token
    // (`selector\9 ` keeps its trailing space; dart emits `selector\9  {`).
    // Inside pseudo parens, a run that follows a comma and contains a
    // newline collapses to '\n' instead: dart's arg complexes carry their
    // source lineBreak and the serializer honors it anywhere
    // (`:is(a,\n[type=color])` keeps its lines — quasar's field selectors).
    let cs_buf = CharBuf::of(s);
    let cs: &[char] = &cs_buf;
    let mut collapsed = String::with_capacity(s.len());
    let mut prev_space = true; // trims leading whitespace
    let mut paren = 0i32;
    let mut ci = 0;
    while ci < cs.len() {
        let c = cs[ci];
        if c == '\\' && ci + 1 < cs.len() && cs[ci + 1].is_ascii_hexdigit() {
            collapsed.push('\\');
            ci += 1;
            let mut digits = 0;
            while digits < 6 && ci < cs.len() && cs[ci].is_ascii_hexdigit() {
                collapsed.push(cs[ci]);
                ci += 1;
                digits += 1;
            }
            if ci < cs.len() && cs[ci].is_whitespace() {
                collapsed.push(' ');
                ci += 1;
            }
            prev_space = false;
            continue;
        }
        // A literal escape: the next character — even whitespace (`sp\ `) —
        // is part of the token, never a separator to collapse or trim.
        if c == '\\' && ci + 1 < cs.len() {
            collapsed.push('\\');
            collapsed.push(cs[ci + 1]);
            ci += 2;
            prev_space = false;
            continue;
        }
        if c.is_whitespace() {
            let mut has_nl = c == '\n';
            ci += 1;
            while ci < cs.len() && cs[ci].is_whitespace() {
                has_nl |= cs[ci] == '\n';
                ci += 1;
            }
            if !prev_space {
                if paren > 0 && has_nl && collapsed.ends_with(',') {
                    collapsed.push('\n');
                } else {
                    collapsed.push(' ');
                }
            }
            prev_space = true;
            continue;
        }
        match c {
            '(' => paren += 1,
            ')' => paren -= 1,
            _ => {}
        }
        collapsed.push(c);
        prev_space = false;
        ci += 1;
    }
    // Trim a PLAIN trailing space (one belonging to an escape stays).
    if prev_space && collapsed.ends_with(' ') {
        collapsed.pop();
    }
    let chars_buf = CharBuf::of(&collapsed);
    let chars: &[char] = &chars_buf;
    let mut out = String::new();
    let mut i = 0;
    // True when the current top-level compound already holds a simple selector.
    let mut mid_compound = false;
    while i < chars.len() {
        let c = chars[i];
        match c {
            '[' => {
                let end = matching_bracket(chars, i);
                if end < chars.len() {
                    let whole: String = chars[i..=end].iter().collect();
                    out.push_str(&crate::selector::normalize_attribute(&whole));
                } else {
                    let inner: String = chars[i + 1..].iter().collect();
                    out.push('[');
                    out.push_str(&normalize_attribute_text(&inner));
                }
                i = end + 1;
                mid_compound = true;
                continue;
            }
            '.' | '#' | '%' => {
                // A class/id/placeholder sigil plus its name (one simple).
                out.push(c);
                i += 1;
                copy_name(chars, &mut i, &mut out);
                mid_compound = true;
                continue;
            }
            ':' => {
                // A pseudo-class/element (with any `(...)` argument). A
                // selector-argument pseudo re-serializes canonically.
                let start = out.len();
                copy_pseudo(chars, &mut i, &mut out);
                let text = out[start..].to_string();
                // An `:nth-child`/`:nth-last-child` An+B argument
                // canonicalizes (whitespace drops, lowercase `n`); a
                // selector-argument pseudo re-serializes canonically.
                let canon = crate::selector::normalize_nth(&text)
                    .or_else(|| crate::selector::normalize_pseudo_arg(&text));
                if let Some(canon) = canon {
                    out.truncate(start);
                    out.push_str(&canon);
                }
                mid_compound = true;
                continue;
            }
            '*' if chars.get(i + 1) != Some(&'|') || chars.get(i + 2) == Some(&'=') => {
                // A bare universal `*` (not a `*|...` namespace prefix). It does
                // not start a new adjacent compound on its own.
                out.push('*');
                i += 1;
                mid_compound = true;
                continue;
            }
            '>' | '~' | '+' => {
                while out.ends_with(' ') {
                    out.pop();
                }
                out.push(' ');
                out.push(c);
                out.push(' ');
                i += 1;
                while i < chars.len() && chars[i] == ' ' {
                    i += 1;
                }
                mid_compound = false;
                continue;
            }
            ' ' | '\t' | '\n' | '\r' => {
                out.push(c);
                i += 1;
                mid_compound = false;
                continue;
            }
            _ if type_selector_starts_at(chars, i) => {
                // A type/namespaced-type selector. Mid-compound, it is a
                // separate adjacent compound: join with a descendant space.
                if mid_compound && !out.ends_with(' ') {
                    out.push(' ');
                }
                copy_type_selector(chars, &mut i, &mut out);
                mid_compound = true;
                continue;
            }
            _ => {
                // Any other character (e.g. a digit or `%` in a keyframe stop
                // like `1e2%`, which is not a real selector). It does NOT make a
                // following identifier an adjacent compound, so clear the flag.
                out.push(c);
                i += 1;
                mid_compound = false;
            }
        }
    }
    let t = out.trim();
    // dart keeps an escape's trailing space: a hex escape's terminator
    // (`selector\9 `) and an escaped literal space (`sp\ `) both survive;
    // only plain trailing whitespace trims.
    let start = out.len() - out.trim_start().len();
    let end = start + t.len();
    if out[end..].starts_with(' ') && (ends_with_hex_escape(t) || ends_with_escaping_backslash(t)) {
        out[start..=end].to_string()
    } else {
        t.to_string()
    }
}

/// Whether `t` ends in a `\<hex>{1,6}` escape whose terminating space must
/// survive trimming.
fn ends_with_hex_escape(t: &str) -> bool {
    let b = t.as_bytes();
    let mut i = b.len();
    let mut digits = 0;
    while i > 0 && (b[i - 1] as char).is_ascii_hexdigit() && digits < 6 {
        i -= 1;
        digits += 1;
    }
    digits > 0 && i > 0 && b[i - 1] == b'\\'
}

/// Whether `t` ends in an ODD run of backslashes, so the character after it
/// (an escaped literal space, `sp\ `) is part of the identifier.
fn ends_with_escaping_backslash(t: &str) -> bool {
    let b = t.as_bytes();
    let mut n = 0;
    while n < b.len() && b[b.len() - 1 - n] == b'\\' {
        n += 1;
    }
    n % 2 == 1
}

/// Trim a selector part's surrounding whitespace, keeping the one character
/// that belongs to a trailing escape — a hex escape's terminator (`\9 `) or
/// an escaped literal space (`sp\ `).
fn trim_selector_part(p: &str) -> &str {
    let t0 = p.trim_start();
    let t = t0.trim_end();
    if t.len() < t0.len() && (ends_with_hex_escape(t) || ends_with_escaping_backslash(t)) {
        &t0[..t.len() + 1]
    } else {
        t
    }
}

/// One token of a complex selector split at the top level (paren/bracket depth
/// 0): either a combinator or a compound selector (a borrowed slice of the
/// input, trimmed).
enum SelToken<'a> {
    Combinator,
    Compound(&'a str),
}

/// Tokenize a complex selector into combinators and compounds at the top level,
/// honouring `[...]`, `(...)`, strings, and escapes so combinators inside a
/// pseudo argument or attribute aren't split out here. Compounds borrow `s`
/// (no per-token allocation): each is a contiguous, trimmed substring.
fn tokenize_complex(s: &str) -> Vec<SelToken<'_>> {
    let mut tokens = Vec::new();
    let mut paren = 0i32;
    let mut bracket = 0i32;
    let mut start = 0usize; // byte start of the compound being accumulated
    let mut it = s.char_indices();
    while let Some((idx, c)) = it.next() {
        match c {
            '\\' => {
                // An escape consumes the following character verbatim.
                it.next();
            }
            '"' | '\'' => {
                // Skip a quoted string (honouring `\` escapes) so combinators
                // inside it aren't split out. Mirrors `skip_string`.
                while let Some((_, c2)) = it.next() {
                    match c2 {
                        '\\' => {
                            it.next();
                        }
                        q if q == c => break,
                        _ => {}
                    }
                }
            }
            '(' => paren += 1,
            ')' => paren -= 1,
            '[' => bracket += 1,
            ']' => bracket -= 1,
            '>' | '+' | '~' if paren == 0 && bracket == 0 => {
                let t = trim_selector_part(&s[start..idx]);
                if !t.is_empty() {
                    tokens.push(SelToken::Compound(t));
                }
                tokens.push(SelToken::Combinator);
                start = idx + 1; // combinator char is ASCII (1 byte)
            }
            _ => {}
        }
    }
    let t = trim_selector_part(&s[start..]);
    if !t.is_empty() {
        tokens.push(SelToken::Compound(t));
    }
    tokens
}

/// Whether a resolved complex selector is a "bogus combinator" that dart-sass
/// omits from the generated CSS: two combinators in a row anywhere, or — inside
/// a pseudo argument (`in_pseudo`) — a trailing combinator, or a leading
/// combinator unless `allow_leading` (true only for `:has`, a relative selector
/// list). A single leading/trailing combinator at the top level is NOT bogus
/// here (it is kept, or handled separately by the nesting rules). The check
/// recurses into selector pseudo arguments (`:is()`, `:not()`, …).
fn complex_selector_is_bogus(s: &str, in_pseudo: bool, allow_leading: bool) -> bool {
    // Bogus-ness needs a combinator (`>`/`+`/`~`) or a selector-pseudo
    // argument (which needs a `(`); a selector containing none of those
    // bytes cannot be bogus, so skip the tokenization entirely.
    if !has_bogus_trigger(s) {
        return false;
    }
    let tokens = tokenize_complex(s);
    if tokens.is_empty() {
        return false;
    }
    // Two adjacent combinators (no compound between) is always invalid.
    let mut prev_combinator = false;
    for t in &tokens {
        match t {
            SelToken::Combinator => {
                if prev_combinator {
                    return true;
                }
                prev_combinator = true;
            }
            SelToken::Compound(_) => prev_combinator = false,
        }
    }
    if in_pseudo {
        if !allow_leading && matches!(tokens.first(), Some(SelToken::Combinator)) {
            return true;
        }
        if matches!(tokens.last(), Some(SelToken::Combinator)) {
            return true;
        }
    }
    // Recurse into selector pseudo arguments of each compound.
    for t in &tokens {
        if let SelToken::Compound(comp) = t {
            if compound_has_bogus_pseudo(comp) {
                return true;
            }
        }
    }
    false
}

/// Whether a resolved complex selector should be dropped from its own emitted
/// declaration block. This is [`complex_selector_is_bogus`] (double combinators,
/// pseudo leading/trailing combinators) PLUS a top-level trailing combinator
/// (`a >`): a trailing combinator is valid only for nesting, so the leaf block
/// it would head is omitted while the selector still serves as a parent.
/// Source span of one comma-separated entry of a rule's selector list, for a
/// diagnostic that names that entry.
///
/// `sel_str` is the rule's own selector with its interpolations already
/// substituted, so an offset into it is not a position in the source. The
/// authored one is recovered by shifting across the interpolations that
/// precede the entry on its line — the same correction `interp_selector_error`
/// applies to a single column, extended to a list that may span lines
/// (`a,\nb`).
///
/// THREE UNITS MEET HERE and mixing them silently misplaces the caret:
/// [`InterpBounds`] and [`Pos::col`] count CHARACTERS, [`crate::diag::Span`]
/// takes its length in SOURCE BYTES, and `&str` indexing is in bytes. The
/// first version of this used byte offsets throughout and drew the underline
/// twelve columns late on `.日本語テスト, .a > + .b` — one column per
/// multi-byte character before the entry.
///
/// Returns the whole selector's start when the correction cannot be trusted
/// (the interpolation spans do not line up with the bounds), which keeps the
/// diagnostic on the right rule even when the column is approximate.
fn selector_part_span(
    src: &str,
    rule: &Rule,
    sel_str: &str,
    interp_bounds: &InterpBounds,
    part_index: usize,
) -> (Pos, usize) {
    let fallback = (rule.selector_pos, sel_str.len());
    let base = sel_str.as_ptr() as usize;
    let mut chosen: Option<(usize, usize)> = None;
    for (k, part) in split_commas(sel_str).iter().enumerate() {
        if k == part_index {
            // `trim_selector_part`, not `trim`: a trailing space can be the
            // terminator of a hex escape (`.a\9 `) and belongs to the selector.
            let kept = trim_selector_part(part);
            let byte_start = kept.as_ptr() as usize - base;
            chosen = Some((byte_start, kept.chars().count()));
            break;
        }
    }
    let Some((byte_start, part_chars)) = chosen else {
        return fallback;
    };

    let spans = &rule.selector_interp_spans;
    let interp = interp_bounds.as_slice();
    if spans.len() != interp.len() {
        return fallback;
    }

    // Char offset of the entry, and of the start of the line it sits on.
    let before = &sel_str[..byte_start];
    let start = before.chars().count();
    let newlines = before.matches('\n').count();
    let line_start = match before.rfind('\n') {
        Some(i) => sel_str[..i + 1].chars().count(),
        None => 0,
    };

    // `#{ … }` and what it produced are different widths, so every
    // interpolation shifts what follows it. One BEFORE the entry (on the same
    // line) moves its start column; one INSIDE it changes how wide the authored
    // text is — the entry dart underlines is `.#{$name} > + lines`, not the
    // `.inaccuracy > + lines` it resolved to.
    let mut shift: i64 = 0;
    let mut inner: i64 = 0;
    for (k, &(out_start, out_len)) in interp.iter().enumerate() {
        let (_, col_start, col_end) = spans[k];
        // `#{ … }` runs from two columns before the expression to the `}`.
        let src_total = (col_end as i64 + 1) - (col_start as i64 - 2);
        let delta = src_total - out_len as i64;
        if out_start >= line_start && out_start + out_len <= start {
            shift += delta;
        } else if out_start >= start && out_start + out_len <= start + part_chars {
            inner += delta;
        }
    }

    let col = if newlines == 0 {
        rule.selector_pos.col as i64 + start as i64 + shift
    } else {
        // A later line of the list starts at column 1 of the source line.
        1 + (start - line_start) as i64 + shift
    };
    let col = col.max(1) as usize;
    let line = rule.selector_pos.line + newlines;
    // The caret length is SOURCE BYTES; everything above is characters.
    let authored_chars = (part_chars as i64 + inner).max(1) as usize;
    let len = source_byte_len(src, line, col, authored_chars).unwrap_or(sel_str.len());
    (Pos { line, col }, len)
}

/// Byte length of `chars` characters of `src` starting at 1-based `line`/`col`,
/// for a [`crate::diag::Span`] length. `None` when the position is past the end
/// of the source, which means the mapping above produced something the source
/// cannot back.
fn source_byte_len(src: &str, line: usize, col: usize, chars: usize) -> Option<usize> {
    let mut cur_line = 1usize;
    let mut cur_col = 1usize;
    let mut start: Option<usize> = None;
    let mut taken = 0usize;
    for (i, ch) in src.char_indices() {
        if start.is_none() && cur_line == line && cur_col == col {
            start = Some(i);
        }
        if let Some(from) = start {
            if taken == chars {
                return Some(i - from);
            }
            taken += 1;
        }
        if ch == '\n' {
            cur_line += 1;
            cur_col = 1;
        } else {
            cur_col += 1;
        }
    }
    start.map(|b| src.len() - b)
}

fn complex_selector_block_is_bogus(s: &str) -> bool {
    if !has_bogus_trigger(s) {
        return false;
    }
    if complex_selector_is_bogus(s, false, false) {
        return true;
    }
    let tokens = tokenize_complex(s);
    matches!(tokens.last(), Some(SelToken::Combinator))
}

/// Whether `s` contains any byte that could make a complex selector bogus: a
/// combinator, or the `(` of a selector-pseudo argument to recurse into.
/// Escaped spellings (`\>`) still contain the trigger byte, so anything
/// suspicious takes the full tokenizing path.
fn has_bogus_trigger(s: &str) -> bool {
    s.bytes().any(|c| matches!(c, b'>' | b'+' | b'~' | b'('))
}

/// Whether `name` (a pseudo-class/element name, case-insensitive, without the
/// leading colon(s)) is one whose argument dart-sass parses as a selector list,
/// and so is subject to bogus-combinator checking. Mirrors dart-sass's
/// `_selectorPseudoClasses`/`_selectorPseudoElements`. Notably this EXCLUDES
/// `:global`/`:local` (CSS-modules pseudos kept verbatim).
fn is_selector_pseudo(name: &str) -> bool {
    matches!(
        name.to_ascii_lowercase().as_str(),
        "not" | "is" | "matches" | "where" | "current" | "any" | "has" | "host" | "host-context" | "slotted"
    )
}

/// Whether any selector-pseudo argument (`:is(...)`, `:has(...)`, `:not(...)`,
/// `:where(...)`, …) inside a compound contains a bogus-combinator complex
/// selector. Only pseudos in [`is_selector_pseudo`] are scanned (others, like
/// `:nth-child(2n)` or `:global(> a)`, keep their argument verbatim). `:has` is
/// a relative selector list, so a leading combinator there is allowed.
fn compound_has_bogus_pseudo(compound: &str) -> bool {
    let chars_buf = CharBuf::of(compound);
    let chars: &[char] = &chars_buf;
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        if c == '\\' {
            i += 2;
            continue;
        }
        if c == '[' {
            // Skip an attribute selector verbatim.
            i = matching_bracket(chars, i) + 1;
            continue;
        }
        if c == ':' {
            // A pseudo with a `(...)` argument: extract and scan the argument as
            // a selector list (each comma part is one complex selector).
            let mut j = i + 1;
            if j < chars.len() && chars[j] == ':' {
                j += 1;
            }
            let name_start = j;
            while j < chars.len() && (is_name_char(chars[j]) || chars[j] == '\\') {
                if chars[j] == '\\' {
                    j += 1;
                }
                j += 1;
            }
            let name: String = chars[name_start..j.min(chars.len())].iter().collect();
            if j < chars.len() && chars[j] == '(' {
                let open = j;
                let mut depth = 0i32;
                let mut k = open;
                while k < chars.len() {
                    match chars[k] {
                        '\\' => {
                            k += 2;
                            continue;
                        }
                        '"' | '\'' => {
                            k = skip_string(chars, k);
                            continue;
                        }
                        '(' => depth += 1,
                        ')' => {
                            depth -= 1;
                            if depth == 0 {
                                break;
                            }
                        }
                        _ => {}
                    }
                    k += 1;
                }
                if is_selector_pseudo(&name) {
                    let allow_leading = name.eq_ignore_ascii_case("has");
                    let arg: String = chars[open + 1..k.min(chars.len())].iter().collect();
                    for part in split_commas(&arg).iter() {
                        let part = part.trim();
                        if !part.is_empty() && complex_selector_is_bogus(part, true, allow_leading) {
                            return true;
                        }
                    }
                }
                i = k + 1;
                continue;
            }
            i = j;
            continue;
        }
        i += 1;
    }
    false
}

/// Copy a CSS name (the part after a `.`/`#`/`%` sigil or a type name) starting
/// at `*i`, honouring `\` escapes, advancing `*i` past it. The captured name is
/// canonicalized to dart-sass's escape form (a numeric escape of a printable
/// character becomes the escaped character, an inline digit drops its escape,
/// etc.).
fn copy_name(chars: &[char], i: &mut usize, out: &mut String) {
    let start = *i;
    let mut has_escape = false;
    while *i < chars.len() {
        let c = chars[*i];
        if c == '\\' {
            has_escape = true;
            *i += 1;
            if *i < chars.len() {
                let esc = chars[*i];
                *i += 1;
                // A hex escape continues for up to six hex digits plus one
                // optional trailing whitespace; consume the rest of it so it
                // decodes as a single code point.
                if esc.is_ascii_hexdigit() {
                    let mut digits = 1;
                    while digits < 6 && *i < chars.len() && chars[*i].is_ascii_hexdigit() {
                        *i += 1;
                        digits += 1;
                    }
                    if *i < chars.len() && chars[*i].is_whitespace() {
                        *i += 1;
                    }
                }
            }
        } else if is_name_char(c) {
            *i += 1;
        } else {
            break;
        }
    }
    // Fast path: a plain name (no escapes) round-trips through
    // `canonicalize_ident` unchanged, so copy the slice straight out with no
    // intermediate String allocation.
    if has_escape {
        let raw: String = chars[start..*i].iter().collect();
        out.push_str(&crate::selector::canonicalize_ident(&raw));
    } else {
        out.extend(chars[start..*i].iter());
    }
}

/// Copy a pseudo-class/element selector (`:name` / `::name` plus any balanced
/// `(...)` argument) verbatim, advancing `*i` past it.
fn copy_pseudo(chars: &[char], i: &mut usize, out: &mut String) {
    out.push(chars[*i]); // first ':'
    *i += 1;
    let is_element = *i < chars.len() && chars[*i] == ':';
    if is_element {
        out.push(':');
        *i += 1;
    }
    let name_start = *i;
    copy_name(chars, i, out);
    let name: String = chars[name_start..*i].iter().collect();
    if *i < chars.len() && chars[*i] == '(' {
        out.push('(');
        *i += 1;
        // dart-sass trims the whitespace immediately inside a pseudo's argument
        // parens (interior runs are already collapsed to a single space by
        // `normalize_selector`). Leading whitespace is always dropped; trailing
        // whitespace is dropped for a pseudo-CLASS or a selector-argument
        // pseudo-element (`::slotted`), but KEPT for a text-argument
        // pseudo-element such as `::part(foo )` / `::highlight(h )`.
        let trim_trailing = !is_element || is_selector_pseudo_element(&name);
        while *i < chars.len() && chars[*i] == ' ' {
            *i += 1;
        }
        let mut depth = 1i32;
        while *i < chars.len() {
            let c = chars[*i];
            match c {
                '\\' => {
                    out.push(c);
                    *i += 1;
                    if *i < chars.len() {
                        out.push(chars[*i]);
                        *i += 1;
                    }
                    continue;
                }
                '(' => depth += 1,
                ')' => {
                    depth -= 1;
                    if depth == 0 {
                        if trim_trailing {
                            while out.ends_with(' ') {
                                out.pop();
                            }
                        }
                        out.push(')');
                        *i += 1;
                        break;
                    }
                }
                _ => {}
            }
            out.push(c);
            *i += 1;
        }
    }
}

/// Whether a `::name` pseudo-element takes a selector argument (so dart-sass
/// parses and re-serializes it, trimming the argument on both sides). Other
/// pseudo-elements (`::part`, `::highlight`) carry a raw text argument and keep
/// its trailing whitespace. Compared case-insensitively, ignoring a vendor
/// prefix, matching dart-sass's `_selectorPseudoElements`.
fn is_selector_pseudo_element(name: &str) -> bool {
    let lower = name.to_ascii_lowercase();
    let unvendored = lower
        .strip_prefix('-')
        .map_or(lower.as_str(), |rest| match rest.find('-') {
            Some(idx) => &rest[idx + 1..],
            None => lower.as_str(),
        });
    matches!(unvendored, "slotted" | "cue" | "cue-region")
}

/// Copy a type/element selector, including an optional `ns|`/`*|`/`|` namespace
/// prefix and the type name (or `*`), advancing `*i` past it.
fn copy_type_selector(chars: &[char], i: &mut usize, out: &mut String) {
    // Optional namespace prefix.
    if chars[*i] == '*' {
        out.push('*');
        *i += 1;
    } else if chars[*i] == '|' {
        // bare `|type` — no namespace, handled by falling through.
    } else {
        copy_name(chars, i, out);
    }
    if *i < chars.len() && chars[*i] == '|' && chars.get(*i + 1) != Some(&'=') {
        out.push('|');
        *i += 1;
        if *i < chars.len() && chars[*i] == '*' {
            out.push('*');
            *i += 1;
        } else {
            copy_name(chars, i, out);
        }
    }
}

/// Whether a bare type/namespaced-type selector (an identifier, optionally
/// preceded by a `*|`/`ns|`/`|` namespace) begins at `chars[i]`. Used to detect
/// an adjacent compound (`[a]b` → `[a] b`). A `*` universal, the `.#%:` sigils,
/// an attribute `[`, and a combinator are NOT type-selector starts. `*|type`
/// and `|type` count as type starts.
fn type_selector_starts_at(chars: &[char], i: usize) -> bool {
    let c = chars[i];
    // `*|...` is a namespaced type/universal (but not `*|=`, an operator).
    if c == '*' {
        return chars.get(i + 1) == Some(&'|') && chars.get(i + 2) != Some(&'=');
    }
    // `|type` (empty namespace) is a type selector (but not `|=`).
    if c == '|' {
        return chars.get(i + 1) != Some(&'=');
    }
    if is_name_start(c) {
        return true;
    }
    // A leading `-` of an identifier (`-foo`, `--foo`) or an escape `\` begins
    // an identifier-led type selector.
    if c == '-' {
        return matches!(chars.get(i + 1), Some(&n) if is_name_start(n) || n == '-' || n == '\\');
    }
    c == '\\'
}

// ---- media queries -----------------------------------------------------

/// Append an `and`/`or` media-query separator. dart-sass's compressed media
/// serializer omits the space BEFORE the keyword when the text so far ends in
/// `)` (`(a)and (b)`) but keeps it after an identifier (`screen and (a)`); the
/// trailing space is always present. Expanded always emits ` and `/` or `.
/// (`@supports` conditions are serialized elsewhere and are NOT tightened.)
fn push_media_sep(s: &mut String, is_and: bool, compressed: bool) {
    let word = if is_and { "and" } else { "or" };
    if compressed && s.ends_with(')') {
        s.push_str(word);
    } else {
        s.push(' ');
        s.push_str(word);
    }
    s.push(' ');
}

impl ResolvedQuery {
    /// Serialize one query (dart-sass `CssMediaQuery.toString`). `compressed`
    /// tightens the `and`/`or` separators per dart's compressed serializer.
    fn render(&self, compressed: bool) -> String {
        let mut s = String::new();
        if let Some(m) = &self.modifier {
            s.push_str(m);
            s.push(' ');
        }
        if let Some(t) = &self.mtype {
            s.push_str(t);
            if !self.conditions.is_empty() {
                // A media type is an identifier, so the space is kept
                // (`screen and (a)`) — the `ends_with(')')` rule yields that.
                push_media_sep(&mut s, true, compressed);
            }
        }
        for (i, c) in self.conditions.iter().enumerate() {
            if i > 0 {
                push_media_sep(&mut s, self.conjunction_and, compressed);
            }
            s.push_str(c);
        }
        s
    }
}

/// Serialize a comma list of media queries.
/// Whether a parsed media query contains `#{}` interpolation anywhere.
fn media_query_has_interp(q: &MediaQuery) -> bool {
    fn tpl(t: &[TplPiece]) -> bool {
        t.iter().any(|p| matches!(p, TplPiece::Interp(_)))
    }
    fn expr(e: &Expr) -> bool {
        match e {
            Expr::Interp(_) => true,
            Expr::Ident(t) | Expr::QuotedString(t) => tpl(t),
            Expr::Paren(inner) | Expr::Unary { operand: inner, .. } => expr(inner),
            Expr::Binary { lhs, rhs, .. } | Expr::Div { lhs, rhs, .. } => expr(lhs) || expr(rhs),
            Expr::List { items, .. } => items.iter().any(expr),
            _ => false,
        }
    }
    fn in_parens(c: &MediaInParens) -> bool {
        match c {
            MediaInParens::Feature(f) => match &**f {
                MediaFeature::Decl { name, value } => expr(name) || value.as_ref().is_some_and(expr),
                MediaFeature::Range {
                    first, second, rest, ..
                } => expr(first) || expr(second) || rest.as_ref().is_some_and(|(_, e)| expr(e)),
            },
            MediaInParens::Not(inner) => in_parens(inner),
            MediaInParens::Group { conditions, .. } => conditions.iter().any(in_parens),
            MediaInParens::Interp(_) => true,
        }
    }
    match q {
        MediaQuery::Type {
            mtype, conditions, ..
        } => tpl(mtype) || conditions.iter().any(in_parens),
        MediaQuery::Condition { conditions, .. } => conditions.iter().any(in_parens),
    }
}

/// Parse a RESOLVED (interpolation-free) media query list the way dart-sass's
/// `CssMediaQuery.parseList` does: identifiers and `and`/`or` keywords are
/// structural, while each parenthesised condition is kept as raw balanced
/// text (`((a) AnD (b))` survives verbatim).
fn css_media_parse_list(text: &str) -> Result<Vec<ResolvedQuery>, Error> {
    let mut out = Vec::new();
    for part in split_top_level_media_commas(text) {
        let part = part.trim();
        if part.is_empty() {
            continue;
        }
        let mut q = css_media_parse_one(part)?;
        // dart re-parses `(not (a))` as a negation and serializes it WITHOUT
        // the outer parentheses (`@media not (a)`).
        if q.mtype.is_none() && q.modifier.is_none() && q.conditions.len() == 1 {
            let c = q.conditions[0].clone();
            if let Some(inner) = c.strip_prefix('(').and_then(|s| s.strip_suffix(')')) {
                let t = inner.trim();
                let balanced = {
                    let mut d = 0i32;
                    let mut ok = true;
                    for ch in t.chars() {
                        match ch {
                            '(' => d += 1,
                            ')' => {
                                d -= 1;
                                if d < 0 {
                                    ok = false;
                                    break;
                                }
                            }
                            _ => {}
                        }
                    }
                    ok && d == 0
                };
                // Only the exact lowercase `not` keyword re-parses as a
                // negation (dart keeps `(NoT (a))` verbatim).
                if balanced && (t.starts_with("not ") || t.starts_with("not(")) {
                    q.conditions[0] = t.to_string();
                }
            }
        }
        out.push(q);
    }
    Ok(out)
}

fn split_top_level_media_commas(s: &str) -> Vec<String> {
    let mut parts = Vec::new();
    let mut cur = String::new();
    let mut depth = 0i32;
    for c in s.chars() {
        match c {
            '(' | '[' => {
                depth += 1;
                cur.push(c);
            }
            ')' | ']' => {
                depth -= 1;
                cur.push(c);
            }
            ',' if depth == 0 => parts.push(std::mem::take(&mut cur)),
            _ => cur.push(c),
        }
    }
    parts.push(cur);
    parts
}

fn css_media_parse_one(t: &str) -> Result<ResolvedQuery, Error> {
    let chars_buf = CharBuf::of(t);
    let chars: &[char] = &chars_buf;
    let mut i = 0usize;
    let skip_ws = |i: &mut usize| {
        while *i < chars.len() && chars[*i].is_whitespace() {
            *i += 1;
        }
    };
    // A raw balanced `(...)` condition, kept verbatim.
    let take_paren = |i: &mut usize| -> Result<String, Error> {
        let start = *i;
        let mut depth = 0i32;
        while *i < chars.len() {
            match chars[*i] {
                '(' => depth += 1,
                ')' => {
                    depth -= 1;
                    if depth == 0 {
                        *i += 1;
                        return Ok(chars[start..*i].iter().collect());
                    }
                }
                _ => {}
            }
            *i += 1;
        }
        Err(Error::unpositioned("expected \")\"."))
    };
    let take_ident = |i: &mut usize| -> String {
        let start = *i;
        while *i < chars.len() && !chars[*i].is_whitespace() && chars[*i] != '(' {
            *i += 1;
        }
        chars[start..*i].iter().collect()
    };
    skip_ws(&mut i);
    // Condition-only form: `(c) [and|or (c)]*` (possibly `not (c)`).
    if i < chars.len() && chars[i] == '(' {
        let mut conditions = vec![take_paren(&mut i)?];
        let mut conjunction_and = true;
        loop {
            skip_ws(&mut i);
            if i >= chars.len() {
                break;
            }
            let word = take_ident(&mut i);
            skip_ws(&mut i);
            match word.to_ascii_lowercase().as_str() {
                "and" => conditions.push(take_paren(&mut i)?),
                "or" => {
                    conjunction_and = false;
                    conditions.push(take_paren(&mut i)?);
                }
                _ => return Err(Error::unpositioned("expected \"and\" or \"or\".")),
            }
        }
        return Ok(ResolvedQuery {
            modifier: None,
            mtype: None,
            conditions,
            conjunction_and,
        });
    }
    let id1 = take_ident(&mut i);
    skip_ws(&mut i);
    if id1.eq_ignore_ascii_case("not") && i < chars.len() && chars[i] == '(' {
        let cond = take_paren(&mut i)?;
        return Ok(ResolvedQuery {
            modifier: None,
            mtype: None,
            conditions: vec![format!("not {cond}")],
            conjunction_and: true,
        });
    }
    // `[modifier] type [and (c)]*` — a second identifier that isn't `and`
    // makes the first the modifier.
    let mut modifier = None;
    let mut mtype = id1;
    if i < chars.len() && chars[i] != '(' {
        let save = i;
        let id2 = take_ident(&mut i);
        if !id2.is_empty() && !id2.eq_ignore_ascii_case("and") {
            modifier = Some(std::mem::replace(&mut mtype, id2));
        } else {
            i = save;
        }
    }
    let mut conditions = Vec::new();
    loop {
        skip_ws(&mut i);
        if i >= chars.len() {
            break;
        }
        let word = take_ident(&mut i);
        if !word.eq_ignore_ascii_case("and") {
            return Err(Error::unpositioned("expected \"and\"."));
        }
        skip_ws(&mut i);
        conditions.push(take_paren(&mut i)?);
    }
    Ok(ResolvedQuery {
        modifier,
        mtype: Some(mtype),
        conditions,
        conjunction_and: true,
    })
}

fn serialize_media_queries(queries: &[ResolvedQuery], compressed: bool) -> String {
    // Compressed drops the space after the comma between queries (`(a),(b)`).
    let sep = if compressed { "," } else { ", " };
    queries
        .iter()
        .map(|q| q.render(compressed))
        .collect::<Vec<_>>()
        .join(sep)
}

/// Serialize a media query list as dart's PARSER spells it into an `@import`'s
/// modifier interpolation (`_mediaQueryList`), which `visitCssImport` writes
/// verbatim. That spelling is not the media-rule serializer's: `_mediaQuery`
/// writes the space that would separate a media type from a following
/// identifier BEFORE it learns the identifier is `and`, then writes the whole
/// `" and "` separator anyway — so a bare `<type> and <condition>` query goes
/// out with TWO spaces. Only an `@import` can show it, since a real `@media`
/// rule re-serializes from the parsed queries.
fn serialize_import_media_queries(queries: &[ResolvedQuery]) -> String {
    queries
        .iter()
        .map(|q| {
            let mut s = q.render(false);
            // A modifier absorbs the stray space (`only screen and`, and even
            // `not screen and`, are spelled with one), and a query that opens
            // on a condition has no type to be separated from.
            if let (None, Some(t), false) = (&q.modifier, &q.mtype, q.conditions.is_empty()) {
                s.insert(t.len(), ' ');
            }
            s
        })
        .collect::<Vec<_>>()
        .join(", ")
}

/// Merge an enclosing query list with a nested query list (dart-sass
/// `_mergeMediaQueries`). Returns `None` if any pair is unrepresentable (keep
/// the nested rule in place); otherwise the merged list, which is empty when
/// every pair is mutually exclusive (the rule is dropped).
fn merge_media_query_lists(outer: &[ResolvedQuery], inner: &[ResolvedQuery]) -> Option<Vec<ResolvedQuery>> {
    let mut merged = Vec::new();
    for a in outer {
        for b in inner {
            match merge_media_query(a, b) {
                MergeResult::Empty => continue,
                MergeResult::Unrepresentable => return None,
                MergeResult::Query(q) => merged.push(q),
            }
        }
    }
    Some(merged)
}

/// Merge two media queries (dart-sass `CssMediaQuery.merge`).
fn merge_media_query(this: &ResolvedQuery, other: &ResolvedQuery) -> MergeResult {
    if !this.conjunction_and || !other.conjunction_and {
        return MergeResult::Unrepresentable;
    }
    let our_modifier = this.modifier.as_ref().map(|s| s.to_ascii_lowercase());
    let our_type = this.mtype.as_ref().map(|s| s.to_ascii_lowercase());
    let their_modifier = other.modifier.as_ref().map(|s| s.to_ascii_lowercase());
    let their_type = other.mtype.as_ref().map(|s| s.to_ascii_lowercase());

    if our_type.is_none() && their_type.is_none() {
        let mut conditions = this.conditions.clone();
        conditions.extend(other.conditions.iter().cloned());
        return MergeResult::Query(ResolvedQuery {
            modifier: None,
            mtype: None,
            conditions,
            conjunction_and: true,
        });
    }

    let our_not = our_modifier.as_deref() == Some("not");
    let their_not = their_modifier.as_deref() == Some("not");
    let is_all = |t: &Option<String>| t.as_deref() == Some("all");

    let (modifier, mtype, conditions): (Option<String>, Option<String>, Vec<String>);
    if our_not != their_not {
        if our_type == their_type {
            let (neg, pos) = if our_not {
                (&this.conditions, &other.conditions)
            } else {
                (&other.conditions, &this.conditions)
            };
            if neg.iter().all(|c| pos.contains(c)) {
                return MergeResult::Empty;
            }
            return MergeResult::Unrepresentable;
        } else if our_type.is_none() || is_all(&our_type) || their_type.is_none() || is_all(&their_type) {
            return MergeResult::Unrepresentable;
        }
        if our_not {
            modifier = their_modifier.clone();
            mtype = their_type.clone();
            conditions = other.conditions.clone();
        } else {
            modifier = our_modifier.clone();
            mtype = our_type.clone();
            conditions = this.conditions.clone();
        }
    } else if our_not {
        if our_type != their_type {
            return MergeResult::Unrepresentable;
        }
        let (more, fewer) = if this.conditions.len() > other.conditions.len() {
            (&this.conditions, &other.conditions)
        } else {
            (&other.conditions, &this.conditions)
        };
        if !fewer.iter().all(|c| more.contains(c)) {
            return MergeResult::Unrepresentable;
        }
        modifier = our_modifier.clone();
        mtype = our_type.clone();
        conditions = more.clone();
    } else if our_type.is_none() || is_all(&our_type) {
        mtype = if (their_type.is_none() || is_all(&their_type)) && our_type.is_none() {
            None
        } else {
            their_type.clone()
        };
        let mut c = this.conditions.clone();
        c.extend(other.conditions.iter().cloned());
        conditions = c;
        modifier = their_modifier.clone();
    } else if their_type.is_none() || is_all(&their_type) {
        let mut c = this.conditions.clone();
        c.extend(other.conditions.iter().cloned());
        conditions = c;
        modifier = our_modifier.clone();
        mtype = our_type.clone();
    } else if our_type != their_type {
        return MergeResult::Empty;
    } else {
        modifier = our_modifier.clone().or_else(|| their_modifier.clone());
        let mut c = this.conditions.clone();
        c.extend(other.conditions.iter().cloned());
        conditions = c;
        mtype = our_type.clone();
    }

    // dart-sass keeps the raw (original-case) type of whichever query
    // contributed it.
    let final_type = match &mtype {
        None => None,
        Some(_) if mtype == our_type => this.mtype.clone(),
        Some(_) => other.mtype.clone(),
    };
    MergeResult::Query(ResolvedQuery {
        modifier,
        mtype: final_type,
        conditions,
        conjunction_and: true,
    })
}

// ---- modern if() condition evaluation ----------------------------------

/// The tri-state outcome of evaluating a modern `if()` condition: a static
/// boolean, or a residual non-evaluable CSS condition kept for verbatim
/// serialization.
enum CondEval {
    Bool(bool),
    Css(RCond),
}

/// A residual (non-evaluable) modern `if()` condition tree. The raw text of
/// each `Css` leaf already has interpolation resolved; the tree is preserved
/// so `and`/`or`/`not`/parentheses serialize canonically.
enum RCond {
    /// A serialized raw substitution sequence (`css(...)`, `var(...)`, ...).
    Css(String),
    Not(Box<RCond>),
    And(Vec<RCond>),
    Or(Vec<RCond>),
    Paren(Box<RCond>),
}

impl RCond {
    fn to_css(&self) -> String {
        match self {
            RCond::Css(s) => s.clone(),
            RCond::Not(c) => format!("not {}", c.to_css()),
            RCond::And(items) => items.iter().map(RCond::to_css).collect::<Vec<_>>().join(" and "),
            RCond::Or(items) => items.iter().map(RCond::to_css).collect::<Vec<_>>().join(" or "),
            RCond::Paren(c) => format!("({})", c.to_css()),
        }
    }
}

/// Combine the residual operands of an `and`/`or` whose statically-known
/// operands were already folded away. When a single residual remains, the
/// operation collapses to it (and a redundant outer paren is dropped, as in
/// dart-sass); otherwise it stays an `and`/`or` chain.
fn combine_residuals(mut residuals: Vec<RCond>, is_and: bool) -> CondEval {
    match residuals.len() {
        // No residuals: every operand was statically known. An `and` that
        // reached here had no false operand (all true) -> true; an `or`
        // that reached here had no true operand (all false) -> false.
        0 => CondEval::Bool(is_and),
        1 => {
            let single = residuals.pop().unwrap_or(RCond::Css(String::new()));
            // A single surviving operand drops a redundant outer paren.
            let unwrapped = match single {
                RCond::Paren(inner) => *inner,
                other => other,
            };
            CondEval::Css(unwrapped)
        }
        _ => {
            if is_and {
                CondEval::Css(RCond::And(residuals))
            } else {
                CondEval::Css(RCond::Or(residuals))
            }
        }
    }
}

/// Serialize a value for the modern `if()` value position. dart-sass 1.101.4
/// switched this from the `meta.inspect()` format to plain CSS serialization
/// (`serializeValue`, evaluate.dart `visitIfExpression`): lists lose their
/// parens (invisible items drop out), `null` serializes to nothing, and a
/// value with no CSS form (the empty list, a map, a function/mixin reference)
/// is an error. dart's own error here carries no source span, so ours is
/// unpositioned too.
fn serialize_if_value(v: &Value) -> Result<String, Error> {
    match v {
        Value::Null => Ok(String::new()),
        Value::List(l) if l.items.is_empty() && !l.bracketed => {
            Err(Error::unpositioned("() isn't a valid CSS value."))
        }
        Value::Function(f) => Err(Error::unpositioned(format!(
            "{} isn't a valid CSS value.",
            f.inspect()
        ))),
        Value::Mixin(m) => Err(Error::unpositioned(format!(
            "{} isn't a valid CSS value.",
            m.inspect()
        ))),
        other => match find_map(other) {
            Some(m) => Err(Error::unpositioned(format!(
                "{} isn't a valid CSS value.",
                m.to_css(false)
            ))),
            None => Ok(other.to_css(false)),
        },
    }
}

/// The material one deprecation probe was made from, retained by
/// [`Evaluator::dep_memo`] so a fingerprint hit can be VERIFIED with `==`
/// rather than trusted. Lives on the evaluator and dies with it, so nothing
/// here outlives the arena scope of a single compile.
///
/// Every field is a bounded constant plus the current file's URL:
/// [`Evaluator::probe_arg_memoizable`] is what keeps `pos_args` and `named` from
/// holding a `Value` graph, so this struct's size does not depend on the size of
/// the sheet that produced it.
struct DepProbe {
    url: String,
    name: String,
    module: Option<String>,
    pos_args: Vec<Value>,
    named: Vec<(String, Value)>,
}

/// Which question a [`DepProbe`] answered. Part of the memo's key, because two
/// probes made at one span from the same arguments still ask different things —
/// `color.grayscale(1)` is asked about `[global-builtin]`, about
/// `[color-functions]` and about `[color-module-compat]`, and one answering for
/// another would silently drop a warning.
#[derive(Clone, Copy)]
enum DepProbePath {
    /// [`Evaluator::emit_call_deprecations`] — the name-only ids.
    Call = 0,
    /// [`Evaluator::emit_color_function_deprecation`]'s `[color-functions]`
    /// half, whose suggestions come from the argument VALUES.
    ColorFunction = 1,
    /// Its `[color-module-compat]` half, gated on which overload the argument
    /// took.
    ColorModuleCompat = 2,
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The memo's retention bound. [`Evaluator::probe_arg_memoizable`]'s match is
    /// exhaustive, so the compiler already forces a new [`Value`] variant to be
    /// classified; what this locks is the ANSWER, because the answer that costs
    /// memory — admit it, and retain whatever graph it points at — is the one a
    /// hurried patch reaches for. Every shape is written out, so widening the
    /// rule has to be a visible edit here rather than a silent change in
    /// footprint.
    #[test]
    fn the_probe_memo_admits_only_bounded_argument_shapes() {
        // What `color_function_suggestions` actually reads, and nothing else.
        let admitted = vec![
            Value::Number(Number::unitless(1.0)),
            Value::Number(Number::with_unit(10.0, "%")),
            Value::Color(crate::value::Color::rgb(171.0, 205.0, 239.0, 1.0)),
        ];
        for v in &admitted {
            assert!(Evaluator::probe_arg_memoizable(v), "should be memoizable: {v:?}");
        }

        let refused = vec![
            // A simple unit is a shared `Rc<str>`; a complex unit list is a
            // boxed pair of `Vec`s, and it clones deeply.
            Value::Number(Number::with_units(
                1.0,
                vec!["px".into(), "px".into()],
                Vec::new(),
            )),
            Value::Str(SassStr {
                text: "x".into(),
                quoted: true,
            }),
            Value::List(List::new(Vec::<Value>::new(), ListSep::Space, false)),
            Value::Map(Map::new(Vec::new())),
            Value::Bool(true),
            Value::Null,
            Value::Slash(Number::unitless(1.0), "1/2".to_string()),
            Value::Calc(CalcNode::Str("var(--x)".to_string())),
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
        for v in &refused {
            assert!(
                !Evaluator::probe_arg_memoizable(v),
                "should not be memoizable: {v:?}"
            );
        }

        // The two lists together are the whole enum, so a new variant cannot be
        // added without landing on one side of it or the other.
        let variants: std::collections::HashSet<_> = admitted
            .iter()
            .chain(refused.iter())
            .map(std::mem::discriminant)
            .collect();
        assert_eq!(variants.len(), 11, "one case per `Value` variant");
    }

    /// What the reused serialization buffer must never do: leak the tail of the
    /// value before it. Every declaration is written into the same `String`, so a
    /// missing `clear()` — or a later serializer that appends where it means to
    /// overwrite — surfaces as one declaration wearing the end of its
    /// predecessor. This sheet therefore steps DOWN in length twice, and covers
    /// both declaration paths: ordinary declarations and a property set's
    /// leading value (`border: 1px solid #abcdef { radius: 4px; }`), which
    /// serializes through the same buffer while a nested block is being built.
    #[test]
    fn the_reused_value_buffer_never_leaks_the_previous_value() {
        let src = concat!(
            ".a {\n",
            "  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.35), inset 0 1px 0 #ffffff;\n",
            "  color: #abc;\n",
            "  z-index: 1;\n",
            "  border: 1px solid #abcdef { radius: 4px; }\n",
            "  outline: 0;\n",
            "}\n",
        );
        let css = crate::compile(src, &crate::Options::default()).expect("compiles");
        let expected = concat!(
            ".a {\n",
            "  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.35), inset 0 1px 0 #ffffff;\n",
            "  color: #abc;\n",
            "  z-index: 1;\n",
            "  border: 1px solid #abcdef;\n",
            "  border-radius: 4px;\n",
            "  outline: 0;\n",
            "}",
        );
        assert_eq!(css.trim_end(), expected);
    }
}
