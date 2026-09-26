use super::*;

/// Where each `#{…}` in a template landed in its output: `(char start, char
/// length)`, in source order. A template with a single interpolation — `.item-#{$i}`
/// and every selector shaped like it — keeps its one range inline, because a
/// vector for it would be an allocation per style rule on the path that resolves
/// every selector in the sheet.
pub(super) enum InterpBounds {
    None,
    One((usize, usize)),
    Many(Vec<(usize, usize)>),
}

impl InterpBounds {
    fn push(&mut self, b: (usize, usize)) {
        match self {
            Self::None => *self = Self::One(b),
            Self::One(first) => *self = Self::Many(vec![*first, b]),
            Self::Many(v) => v.push(b),
        }
    }

    pub(super) fn as_slice(&self) -> &[(usize, usize)] {
        match self {
            Self::None => &[],
            Self::One(b) => std::slice::from_ref(b),
            Self::Many(v) => v,
        }
    }
}

/// How many bytes one `#{…}` is assumed to contribute when a template's buffer
/// is sized: what a serialized value usually is — a short identifier, a number
/// with a unit, a hex color. Only an estimate; the buffer still grows if an
/// interpolation turns out longer.
const INTERP_ALLOWANCE: usize = 8;

/// Room for a template's output: every literal byte, plus an allowance for each
/// interpolation. A template is built by pushing onto a `String`, and one that
/// starts empty takes the allocator's minimum block and then regrows — twice for
/// a selector or a value list of any length. Sizing it up front trades a walk
/// over a handful of pieces for those copies, on a path that runs for every
/// selector, property name and interpolated value in the sheet.
fn template_capacity(pieces: &[TplPiece]) -> usize {
    pieces
        .iter()
        .map(|piece| match piece {
            TplPiece::Lit(t) => t.len(),
            TplPiece::Interp(_) => INTERP_ALLOWANCE,
        })
        .sum()
}

impl<'a> Evaluator<'a> {
    // ---- templates & expressions ------------------------------------

    pub(super) fn eval_template(&mut self, pieces: &[TplPiece]) -> Result<String, Error> {
        let mut s = String::with_capacity(template_capacity(pieces));
        for piece in pieces {
            match piece {
                TplPiece::Lit(t) => s.push_str(t),
                TplPiece::Interp(e) => {
                    let v = self.eval_expr(e)?;
                    interp_checked_into(&mut s, &v)?;
                }
            }
        }
        Ok(s)
    }

    /// The template's text as a shared string. A template that is a single
    /// literal piece — every `color`, every `solid`, every `.card` — already has
    /// its text in the AST, and this hands that buffer out rather than copying
    /// it, so the string it becomes costs a refcount bump. Anything with
    /// interpolation in it has to be built, and pays one buffer for the result
    /// exactly as before.
    pub(super) fn eval_template_shared(&mut self, pieces: &[TplPiece]) -> Result<Rc<str>, Error> {
        if let [TplPiece::Lit(t)] = pieces {
            return Ok(Rc::clone(t));
        }
        Ok(Rc::from(self.eval_template(pieces)?))
    }

    /// Like [`Self::eval_template`], additionally returning each `Interp`
    /// piece's (char start, char length) range in the output — used to decide
    /// whether a resolved-selector error column falls inside interpolated
    /// text (the dual-span "error in interpolated output" diagnostic).
    ///
    /// The text is borrowed from the AST when the template is a single literal —
    /// the shape of nearly every selector — which is why it is a [`Cow`]: that
    /// case has nothing to build and no interpolation to record, so it costs
    /// neither the buffer nor the bounds vector.
    pub(super) fn eval_template_bounds<'p>(
        &mut self,
        pieces: &'p [TplPiece],
    ) -> Result<(Cow<'p, str>, InterpBounds), Error> {
        if let [TplPiece::Lit(t)] = pieces {
            return Ok((Cow::Borrowed(t), InterpBounds::None));
        }
        // One walk sizes both buffers up front, so neither the text nor the
        // ranges reallocate: a generated selector can carry a dozen
        // interpolations. See [`template_capacity`] for the text estimate.
        let mut interps = 0usize;
        let mut capacity = 0usize;
        for piece in pieces {
            match piece {
                TplPiece::Lit(t) => capacity += t.len(),
                TplPiece::Interp(_) => {
                    interps += 1;
                    capacity += INTERP_ALLOWANCE;
                }
            }
        }
        let mut s = String::with_capacity(capacity);
        let mut chars = 0usize;
        let mut bounds = if interps > 1 {
            InterpBounds::Many(Vec::with_capacity(interps))
        } else {
            InterpBounds::None
        };
        for piece in pieces {
            match piece {
                TplPiece::Lit(t) => {
                    s.push_str(t);
                    chars += t.chars().count();
                }
                TplPiece::Interp(e) => {
                    let v = self.eval_expr(e)?;
                    // Written into the output first, then measured there: the
                    // range is what the interpolation occupies in `s`, which is
                    // the same count either way and one buffer cheaper.
                    let at = s.len();
                    interp_checked_into(&mut s, &v)?;
                    let len = s[at..].chars().count();
                    bounds.push((chars, len));
                    chars += len;
                }
            }
        }
        Ok((Cow::Owned(s), bounds))
    }

    /// The value of `&` in value position: the current resolved selector list
    /// as a comma-separated Sass list where each item is one complex selector
    /// (a space-separated list of compound-selector strings). At the document
    /// root (no enclosing style rule) this is `null`. This matches dart-sass,
    /// where `&` is always a comma list even for a single selector.
    pub(super) fn parent_selector_value(&self) -> Value {
        let Some(selectors) = &self.current_selector else {
            return Value::Null;
        };
        if selectors.is_empty() {
            return Value::Null;
        }
        let items: Vec<Value> = selectors
            .iter()
            .map(|complex| {
                // Every complex selector is a SPACE LIST of compounds (dart:
                // `meta.type-of(list.nth(&, 1))` is `list` even for `.foo`).
                let compounds: Vec<Value> = complex
                    .split_whitespace()
                    .map(|c| {
                        Value::Str(SassStr {
                            text: c.to_string().into(),
                            quoted: false,
                        })
                    })
                    .collect();
                Value::List(List {
                    items: compounds.into(),
                    sep: ListSep::Space,
                    bracketed: false,
                    keywords: None,
                })
            })
            .collect();
        Value::List(List {
            items: items.into(),
            sep: ListSep::Comma,
            bracketed: false,
            keywords: None,
        })
    }

    pub(super) fn eval_expr(&mut self, expr: &Expr) -> Result<Value, Error> {
        // Finalize any positioned error into a rendered diagnostic block here,
        // where `current_url`/`current_source`/`call_stack` still describe the
        // file and call context the error was raised in (cross-file safe).
        match self.eval_expr_inner(expr) {
            Ok(v) => Ok(v),
            Err(e) => Err(self.finalize_error(e)),
        }
    }

    pub(super) fn eval_expr_inner(&mut self, expr: &Expr) -> Result<Value, Error> {
        match expr {
            Expr::Number(v, unit) => Ok(Value::Number(Number::with_shared_unit(*v, unit))),
            Expr::Color(c) => Ok(Value::Color(c.clone())),
            Expr::Bool(b) => Ok(Value::Bool(*b)),
            Expr::Null => Ok(Value::Null),
            Expr::Parent => Ok(self.parent_selector_value()),
            // Reading a variable drops a bare slash-division's spelling
            // (dart-sass `withoutSlash`): `$x: 1/2; a {b: $x}` is `0.5`.
            // Slashes nested inside a stored list are preserved.
            Expr::Var { name, pos } => match self.lookup(name) {
                // `lookup` already returns an owned clone out of the scope;
                // `without_slash` consumes it, so a second clone is wasted.
                Some(v) => Ok(v.without_slash()),
                None => {
                    // A user module variable exposed unprefixed via `@use … as *`.
                    let star_hits: Vec<Value> = if is_private_member(name) {
                        Vec::new()
                    } else {
                        self.star_user_modules
                            .iter()
                            .filter_map(|m| m.var(name))
                            .collect()
                    };
                    // A built-in module variable exposed unprefixed the same
                    // way (`$pi` from `sass:math`, directly or through a user
                    // module that forwards it) competes for the same bare name.
                    let builtin_hits = self.star_builtin_hits(name, MemberKind::Variable);
                    if star_hits.len() + builtin_hits.len() > 1 {
                        return Err(Error::at(
                            "This variable is available from multiple global modules.",
                            *pos,
                        ));
                    }
                    if let Some(v) = star_hits.into_iter().next() {
                        return Ok(v.without_slash());
                    }
                    if let Some((owner, bare)) = builtin_hits.into_iter().next() {
                        return crate::builtins::module_var(&owner, &bare, *pos);
                    }
                    // The caret covers `$name` (the `$` plus the identifier).
                    Err(Error::at("Undefined variable.", *pos).with_length(1 + name.len()))
                }
            },
            Expr::NsVar {
                module,
                name,
                pos,
                length,
            } => self
                .eval_module_var(module, name, *pos)
                .map_err(|e| e.with_length(*length)),
            // A string expression (quoted/unquoted/lone-interpolation) resolves
            // its interpolation in a context where the `@supports`-declaration
            // no-simplify flag is OFF, so `(a: #{calc(1 + 2)})` -> `(a: 3)`
            // (the interpolated calc simplifies), matching dart-sass
            // `visitStringExpression`.
            Expr::QuotedString(pieces) => {
                let saved = std::mem::replace(&mut self.in_supports_declaration, false);
                let text = self.eval_template_shared(pieces);
                self.in_supports_declaration = saved;
                Ok(Value::Str(SassStr {
                    text: text?,
                    quoted: true,
                }))
            }
            Expr::Ident(pieces) => {
                let saved = std::mem::replace(&mut self.in_supports_declaration, false);
                let text = self.eval_template_shared(pieces);
                self.in_supports_declaration = saved;
                Ok(Value::Str(SassStr {
                    text: text?,
                    quoted: false,
                }))
            }
            Expr::Interp(inner) => {
                let saved = std::mem::replace(&mut self.in_supports_declaration, false);
                let v = self.eval_expr(inner);
                self.in_supports_declaration = saved;
                // A map or empty list has no CSS serialization, so it cannot be
                // interpolated (`#{(a: 1)}`, `#{()}`); dart-sass errors instead
                // of injecting the inspected/empty text.
                Ok(Value::Str(SassStr {
                    text: interp_checked(&v?)?.into(),
                    quoted: false,
                }))
            }
            Expr::ModernIf(clauses) => self.eval_modern_if(clauses),
            // Parentheses force the deprecated slash to perform real
            // division: `(1/2)` is `0.5`, not the slash value `1/2`.
            Expr::Paren(inner) => Ok(self.eval_expr(inner)?.without_slash()),
            Expr::List {
                items,
                sep,
                bracketed,
            } => {
                let mut vals = Vec::with_capacity(items.len());
                for it in items {
                    vals.push(self.eval_expr(it)?);
                }
                Ok(Value::List(List {
                    items: vals.into(),
                    sep: *sep,
                    bracketed: *bracketed,
                    keywords: None,
                }))
            }
            Expr::Map(entries) => {
                let mut map = Map {
                    entries: std::rc::Rc::new(Vec::new()),
                };
                for (k, v) in entries {
                    let key = self.eval_expr(k)?.without_slash();
                    let val = self.eval_expr(v)?;
                    // A duplicate literal key is an error in dart-sass.
                    if map.get(&key).is_some() {
                        return Err(Error::unpositioned("Duplicate key."));
                    }
                    map.insert(key, val);
                }
                Ok(Value::Map(map))
            }
            Expr::Unary { op, operand } => {
                let v = self.eval_expr(operand)?.without_slash();
                match op {
                    // Unary minus negates a number; on any other operand
                    // dart-sass produces an unquoted `-<value>` string
                    // (`- red` -> `-red`, `- "q"` -> `-"q"`). A calculation that
                    // could not reduce to a number has no negation operator, so
                    // dart-sass rejects it ("Undefined operation \"-calc(…)\".").
                    UnOp::Neg => match v {
                        Value::Number(n) => Ok(Value::Number(n.copy_units(-n.value))),
                        Value::Calc(_) => Err(Error::unpositioned(format!(
                            "Undefined operation \"-{}\".",
                            v.to_css(false)
                        ))),
                        // A map or empty list cannot be serialized into the
                        // unquoted `-<value>` string dart-sass produces, so it
                        // errors before the join (`-(a: 1)`, `-()`).
                        other => match css_value_error_msg(&other) {
                            Some(msg) => Err(Error::unpositioned(msg)),
                            None => Ok(Value::Str(SassStr {
                                text: format!("-{}", other.to_css(false)).into(),
                                quoted: false,
                            })),
                        },
                    },
                    // Unary plus is numeric identity; on any other operand it
                    // prepends `+` as an unquoted string (`+foo` -> `+foo`). A
                    // residual calculation has no unary-plus operator and is
                    // rejected the same way.
                    UnOp::Plus => match v {
                        Value::Number(_) => Ok(v),
                        Value::Calc(_) => Err(Error::unpositioned(format!(
                            "Undefined operation \"+{}\".",
                            v.to_css(false)
                        ))),
                        // As with unary `-`, a map or empty list has no CSS
                        // serialization to prepend `+` to (`+(a: 1)`, `+()`).
                        other => match css_value_error_msg(&other) {
                            Some(msg) => Err(Error::unpositioned(msg)),
                            None => Ok(Value::Str(SassStr {
                                text: format!("+{}", other.to_css(false)).into(),
                                quoted: false,
                            })),
                        },
                    },
                    UnOp::Not => Ok(Value::Bool(!v.is_truthy())),
                }
            }
            Expr::Binary { op, lhs, rhs, pos } => {
                // `and`/`or` short-circuit and yield a value, so the
                // right operand is only evaluated when needed.
                let l = self.eval_expr(lhs)?;
                match op {
                    BinOp::And => {
                        if l.is_truthy() {
                            self.eval_expr(rhs)
                        } else {
                            Ok(l)
                        }
                    }
                    BinOp::Or => {
                        if l.is_truthy() {
                            Ok(l)
                        } else {
                            self.eval_expr(rhs)
                        }
                    }
                    _ => {
                        let r = self.eval_expr(rhs)?;
                        eval_binary(*op, l.without_slash(), r.without_slash(), *pos)
                    }
                }
            }
            Expr::Div {
                lhs, rhs, slash, pos, ..
            } => {
                let l = self.eval_expr(lhs)?;
                let r = self.eval_expr(rhs)?;
                eval_div(l, r, *slash, *pos)
            }
            Expr::Calc { inner, .. } => {
                // dart resolves user functions BEFORE calculation semantics: a
                // user-defined `@function calc(...)` shadows the CSS
                // calculation (issue_1706), receiving the argument evaluated
                // as an ordinary expression. Vendor-prefixed `-x-calc(` stays
                // a parse-time special function and can't be overridden.
                if !self.in_plain_css {
                    if let Some(callable) = self.lookup_function("calc") {
                        let arg = self.eval_expr(inner)?.without_slash();
                        let f = crate::value::SassFunction {
                            name: "calc".to_string(),
                            css: false,
                            module: None,
                            user: Some(callable as Rc<dyn std::any::Any>),
                        };
                        return self
                            .invoke_function_ref(&f, vec![arg], Vec::new(), Pos { line: 0, col: 0 }, 0)
                            .map(Value::without_slash);
                    }
                }
                let node = self.eval_calc(inner)?;
                // Inside a `@supports` declaration the calculation is kept
                // unsimplified: the `calc()` wrapper is always preserved (even
                // around a single number), matching dart-sass `simplify: false`.
                if self.in_supports_declaration {
                    return Ok(Value::Calc(node));
                }
                // A calculation that reduces to a single finite number unwraps
                // to it; a non-finite result (infinity/NaN) stays a
                // calculation so it serializes as `calc(infinity)` etc., and
                // anything still containing an operation stays a calculation.
                match node {
                    // A calculation that reduces to a single number unwraps to
                    // it — including a non-finite result (dart-sass:
                    // `meta.type-of(calc(NaN)) == number`); the Number's own
                    // serialization restores the `calc(NaN)`/`calc(infinity *
                    // 1px)` spelling.
                    CalcNode::Number(n) => Ok(Value::Number(n)),
                    // `calc()` wrapping a single already-complete calculation
                    // (`calc(min(1%, 2px))`, `calc(clamp(…))`, etc.) is
                    // redundant: dart-sass drops the outer `calc()` and emits
                    // the inner calculation directly. (A non-calculation leaf
                    // such as `calc(var(--x))` keeps its wrapper.)
                    CalcNode::Str(s) if is_complete_calculation(&s) => Ok(Value::Str(SassStr {
                        text: s.into(),
                        quoted: false,
                    })),
                    other => Ok(Value::Calc(other)),
                }
            }
            // An interpolated-name call is a *plain CSS* function (dart-sass
            // `PlainCssCallable`): the resolved name is never dispatched to a
            // built-in or user function; the arguments evaluate and the call
            // serializes verbatim. Keyword arguments are rejected.
            Expr::InterpFunc { name, args, pos } => {
                let fname = self.eval_template(name)?;
                if args.iter().any(|a| a.name.is_some()) {
                    return Err(Error::at(
                        "Plain CSS functions don't support keyword arguments.",
                        *pos,
                    ));
                }
                let mut parts: Vec<String> = Vec::with_capacity(args.len());
                for a in args {
                    // As on the ordinary plain-CSS call path: the result is a
                    // STRING, and dart builds one with the default style
                    // whatever the output style is.
                    let v = self.eval_expr(&a.value)?;
                    parts.push(v.to_css(false));
                }
                Ok(Value::Str(SassStr {
                    text: format!("{fname}({})", parts.join(", ")).into(),
                    quoted: false,
                }))
            }
            Expr::Func {
                name,
                args,
                pos,
                length,
                module,
            } => {
                // A namespaced call `ns.fn(...)` resolves only against the used
                // built-in module bound to `ns`.
                if let Some(ns) = module {
                    return self.eval_module_call(ns, name, args, *pos, *length);
                }
                // In a plain-CSS module no function is invoked (dart-sass
                // `plainCss` looks none up): the call re-serializes verbatim
                // with its arguments evaluated. CSS calculations (min/max/…)
                // still simplify through their normal paths below.
                if self.in_plain_css
                    && !is_supports_calc_function(name)
                    && !name.eq_ignore_ascii_case("calc")
                    && !args.iter().any(|a| a.splat || a.name.is_some())
                {
                    let mut parts: Vec<String> = Vec::with_capacity(args.len());
                    for a in args {
                        // The call becomes a STRING here, and dart builds that
                        // string with the default style whatever the output
                        // style is — so `rgb(0.5, 2, 3)` keeps its zero and its
                        // `, ` even when compressing.
                        parts.push(self.eval_expr(&a.value)?.to_css(false));
                    }
                    return Ok(Value::Str(SassStr {
                        text: format!("{name}({})", parts.join(", ")).into(),
                        quoted: false,
                    }));
                }
                // Resolve a user `@function` of this name ONCE (it was probed
                // 6+ times along this arm). A `--`-prefixed call is always plain
                // CSS (dart reserves it for custom functions), so it never binds
                // to a user function even though `@function __a` would normalize
                // to the same `--a` key. Every later "no user override" guard
                // reuses `has_user_fn`.
                let user_fn = if name.starts_with("--") {
                    None
                } else {
                    self.lookup_function(name)
                };
                let has_user_fn = user_fn.is_some();
                // Inside a `@supports` declaration, a CSS math function
                // (`min`/`max`/`clamp`/…) is kept unsimplified: its arguments
                // are resolved through the (non-folding) calc machinery and the
                // call is serialized verbatim, matching dart-sass
                // `simplify: false`. A user-defined function of the same name
                // still wins, so this only applies to builtins.
                if self.in_supports_declaration && is_supports_calc_function(name) && !has_user_fn {
                    return self.eval_supports_calc_func(name, args, *pos);
                }
                // if() is lazy: only the selected branch is evaluated. (Its
                // `[if-function]` deprecation is raised when the FILE is
                // parsed, not here — see `warn_import_rules`.)
                if name == "if" {
                    return self.eval_if_function(args, *pos);
                }
                // User-defined @function takes precedence over builtins.
                if let Some(func) = user_fn {
                    return self.call_function(&func, args, Some((*pos, *length)));
                }
                // `_` and `-` are one character in a Sass identifier, so every
                // built-in lookup from here down runs on the canonical spelling
                // (`map_get(…)` IS the deprecated `map-get(…)`). The name as
                // WRITTEN stays in `name` for the plain-CSS passthrough.
                let canonical = if name.contains('_') {
                    Cow::Owned(name.replace('_', "-"))
                } else {
                    Cow::Borrowed(name.as_str())
                };
                let canonical = canonical.as_ref();
                // A member exposed unprefixed via `@use … as *` — from a user
                // module, or from a built-in one (directly or through a user
                // module that forwards it). All of them compete for the bare
                // name, so ONE ambiguity check covers them, and it runs before
                // the arguments are evaluated: a call that resolves to nothing
                // must not warn about what is inside it.
                let star_user: Vec<(Rc<Module>, Rc<UserCallable>)> = if is_private_member(name) {
                    Vec::new()
                } else {
                    self.star_user_modules
                        .iter()
                        .filter_map(|m| m.function(name).map(|f| (Rc::clone(m), f)))
                        .collect()
                };
                let star_builtin = self.star_builtin_hits(canonical, MemberKind::Function);
                if star_user.len() + star_builtin.len() > 1 {
                    return Err(Error::at(
                        "This function is available from multiple global modules.".to_string(),
                        *pos,
                    ));
                }
                if let Some((m, f)) = star_user.into_iter().next() {
                    return self.call_user_module_function(&m, &f, args, Some((*pos, *length)));
                }
                let via_star = star_builtin.into_iter().next();
                // A bare `calc()` reaches here as a plain call (the parser only
                // treats `calc(<arg>)` as a calculation), so a user
                // `@function calc()` could have handled it above. With no user
                // override it is the CSS `calc()`, which requires an argument.
                if name.eq_ignore_ascii_case("calc") && args.is_empty() {
                    return Err(Error::at("Missing argument.", *pos));
                }
                // The pure CSS-calculation functions are parsed as
                // calculations, which cannot take a `...` rest argument.
                if is_calc_function(name) && args.iter().any(|a| a.splat) {
                    return Err(Error::at("Rest arguments can't be used with calculations.", *pos));
                }
                // The single-/double-argument math calculations (`sin`, `cos`,
                // `sqrt`, `pow`, `log`, `hypot`, …) parse their arguments as
                // calculation expressions, not ordinary SassScript. That means a
                // disallowed operator (`%`, comparison) inside an argument is
                // rejected ("This operation can't be used in a calculation."),
                // and an argument that does not reduce to a single number — it
                // still references a `var()`/interpolation/unknown ident — keeps
                // the whole call as a preserved calculation
                // (`sin(2px + var(--c))`) rather than erroring. When every
                // argument reduces to a plain number the normal builtin path
                // computes the result (and applies its unit checks), so this only
                // changes the two calc-specific behaviours above.
                if is_pure_calc_math_function(name)
                    && !has_user_fn
                    && !args.iter().any(|a| a.splat || a.name.is_some())
                {
                    if let Some(v) = self.try_eval_calc_math_call(name, args, *pos)? {
                        return Ok(v);
                    }
                }
                // `calc-size()` is a two-argument calculation: a sizing keyword
                // (or `var()`/calculation) plus a calculation, always preserved.
                if name.eq_ignore_ascii_case("calc-size")
                    && !has_user_fn
                    && !args.iter().any(|a| a.splat || a.name.is_some())
                {
                    return self.eval_calc_size(args, *pos);
                }
                // A three-argument `clamp()` evaluates its bounds and value as
                // calculations, so a `var()`/operation argument (`1% + 1px`)
                // keeps the call preserved instead of erroring as Sass
                // arithmetic. Other arities (a preserved single argument, or an
                // arity error) fall through to the builtin.
                if name.eq_ignore_ascii_case("clamp")
                    && !has_user_fn
                    && args.len() == 3
                    && !args.iter().any(|a| a.splat || a.name.is_some())
                {
                    return self.try_eval_clamp(args, *pos);
                }
                // `abs()` is a legacy global function that also exists as the CSS
                // `abs()` calculation. When its single positional argument
                // references a `var()`/interpolation it is parsed as a
                // calculation and preserved with its numeric subtree folded
                // (`abs(1px + 2px - var(--c))` -> `abs(3px - var(--c))`).
                // Without such a substitution the argument resolves to a plain
                // number, so the deprecated `math.abs` global handles it as
                // before (`abs(1 + 1px)` -> `2px`, `abs(-3) -> 3`).
                if name.eq_ignore_ascii_case("abs")
                    && !has_user_fn
                    && args.len() == 1
                    && args[0].name.is_none()
                    && !args[0].splat
                    && expr_contains_calc_substitution(&args[0].value)
                {
                    let node = self.eval_calc(&args[0].value)?;
                    return Ok(Value::Str(SassStr {
                        text: format!("abs({})", node.to_calc_css(self.compressed())).into(),
                        quoted: false,
                    }));
                }
                // `round()` is likewise the CSS round() calculation: each
                // argument evaluates as a calculation (so `1.4px + var(--c)`
                // keeps its `+` with the numeric subtree folded, and
                // `1px + 4px` folds to `5px`). If every argument simplifies
                // (numbers, plus a leading strategy keyword), the normal
                // builtin computes the result; otherwise the call is
                // preserved. Calc-incompatible SassScript (`7 % 3`) falls back
                // to the legacy one-argument `math.round` (arity errors and
                // all).
                if name.eq_ignore_ascii_case("round")
                    && !has_user_fn
                    && (1..=3).contains(&args.len())
                    && !args.iter().any(|a| a.splat || a.name.is_some())
                {
                    // A SassScript-only operator (`7 % 3`) makes the call a
                    // plain function, and the only plain `round` is the legacy
                    // one-argument `math.round` — multi-argument forms are an
                    // arity error (dart-sass).
                    if args.iter().any(|a| expr_has_non_calc_op(&a.value)) {
                        if args.len() > 1 {
                            return Err(Error::at(
                                format!("Only 1 argument allowed, but {} were passed.", args.len()),
                                *pos,
                            ));
                        }
                        // A single argument falls through to the legacy builtin.
                    } else if let Ok(nodes) =
                        args.iter()
                            .map(|a| self.eval_calc(&a.value))
                            .collect::<Result<Vec<CalcNode>, Error>>()
                    {
                        let simplified = |i: usize, n: &CalcNode| match n {
                            CalcNode::Number(_) => true,
                            // A leading strategy keyword participates as a
                            // keyword, not an operand.
                            CalcNode::Str(s) => {
                                i == 0
                                    && nodes.len() >= 2
                                    && matches!(
                                        s.to_ascii_lowercase().as_str(),
                                        "nearest" | "up" | "down" | "to-zero"
                                    )
                            }
                            _ => false,
                        };
                        if !nodes.iter().enumerate().all(|(i, n)| simplified(i, n)) {
                            // A preserved round is a first-class Calculation
                            // (`meta.calc-name`/`calc-args` see it).
                            return Ok(Value::Calc(CalcNode::Func {
                                name: "round".to_string(),
                                args: nodes,
                            }));
                        }
                        // Fall through to the normal builtin path below.
                    }
                }
                // `min`/`max` are likewise CSS calculations: their arguments
                // fold as calc expressions, and any unsimplifiable operand
                // (`1px + var(--c)`) preserves the call with the folded
                // subtrees spelled as calc (`max(5px, 1px + var(--c))`). When
                // every argument folds to a number the builtin computes as
                // before, and SassScript-only operators (`7 % 3`) keep the
                // whole call on the legacy path.
                if (name.eq_ignore_ascii_case("min") || name.eq_ignore_ascii_case("max"))
                    && !has_user_fn
                    && !args.is_empty()
                    && !args.iter().any(|a| a.splat || a.name.is_some())
                    && !args.iter().any(|a| expr_has_non_calc_op(&a.value))
                {
                    if let Ok(nodes) = args
                        .iter()
                        .map(|a| self.eval_calc(&a.value))
                        .collect::<Result<Vec<CalcNode>, Error>>()
                    {
                        if !nodes.iter().all(|n| matches!(n, CalcNode::Number(_))) {
                            // A preserved min/max is a first-class Calculation
                            // (`meta.calc-name`/`calc-args` see it).
                            return Ok(Value::Calc(CalcNode::Func {
                                name: name.to_ascii_lowercase(),
                                args: nodes,
                            }));
                        }
                    }
                    // Fall through to the normal builtin path below.
                }
                // Evaluate args, expanding any `...` splat into positional /
                // keyword arguments.
                let (mut pos_args, mut named, call_sep) = self.eval_call_args(args)?;
                // Whatever this call is deprecated for, it is reported here:
                // before every dispatch — the `sass:meta` predicates below
                // resolve against evaluator state and return early — and after
                // the arguments, so a call inside one of them warns first, as
                // dart's does.
                //
                // A `@use "sass:…" as *` makes the bare name that module's
                // MEMBER, so it is deprecated as a function, if at all, and not
                // as a global. A host function of the same name is NOT such a
                // case: dart's `functions` do not shadow a built-in global at
                // all (measured against 1.103.1's JS API — the built-in runs
                // and still warns).
                // The proprietary Microsoft `alpha()` filter overload (below)
                // is not a call to the global `alpha()` at all — dart passes it
                // through as a CSS function and deprecates nothing.
                //
                // GLOBAL calls only, like `css_filter_call` below: after `@use
                // "sass:color" as *` the bare `alpha(opacity=20)` is
                // `color.alpha`, which dart passes through AND deprecates as
                // `color-module-compat`. Returning it from here would skip the
                // star branch that dispatches to the module and emits that
                // warning, so the star path must fall through to it (#124).
                let ms_alpha_filter = via_star.is_none()
                    && canonical == "alpha"
                    && crate::builtins::ms_filter_args(&pos_args, &named).is_some();
                // Same reasoning for the four names that are BOTH a CSS filter
                // function and a Sass global colour function: with a plain-CSS
                // argument (`filter: grayscale(1)`) the call is the CSS filter
                // and dart deprecates nothing. This asks the predicate the
                // builtins themselves use, so the warning cannot disagree with
                // which path the call actually took — it did, and told authors
                // to rewrite CSS filters as `color.adjust` (#122).
                // Global calls only, for the DEPRECATION: a namespaced
                // `color.grayscale(1)` is not a global built-in, so there is
                // nothing to deprecate for being one. (What dart raises there
                // instead is `color-module-compat`, which sasso does not
                // implement yet — #124, a separate gap this does not touch.)
                // ...and only when the built-in is what runs. A registered
                // host function of the same name takes precedence in sasso
                // (see `Options::with_function`), so the call is that
                // callback, not a CSS filter — and the contract there is that
                // a deprecated global's NAME warns whether or not one is
                // registered. Suppressing it here would have made
                // `with_function("grayscale($x)", …)` quietly exempt.
                // Order matters for cost, not just for correctness: the
                // predicate is a match on four names and rejects almost every
                // call outright, while the host-function check normalizes a
                // name and scans the registry. Computing the second one first
                // put that scan on EVERY call in a stylesheet that registers
                // any host function at all.
                let css_filter_call = via_star.is_none()
                    && crate::builtins::is_plain_css_filter_call(canonical, &pos_args, &named)
                    && !(!self.options.functions.is_empty() && {
                        let norm = crate::host_fn::normalize_name(canonical);
                        self.options.functions.iter().any(|f| f.name == norm)
                    });
                if !ms_alpha_filter && !css_filter_call {
                    self.emit_call_deprecations(
                        canonical,
                        via_star.as_ref().map(|(owner, _)| owner.as_str()),
                        *pos,
                        *length,
                    );
                }
                // The global (deprecated) aliases of the `sass:meta` existence
                // predicates resolve against the evaluator state, not the
                // value-only builtin layer. A user-defined function of the same
                // name still wins (checked above).
                if crate::builtins::EVAL_GLOBAL_NAMES.contains(&canonical) {
                    for v in &mut pos_args {
                        *v = std::mem::replace(v, Value::Null).without_slash();
                    }
                    for (_, v) in &mut named {
                        *v = std::mem::replace(v, Value::Null).without_slash();
                    }
                    if let Some(r) = self.try_meta_eval_call(canonical, &pos_args, &named, *pos, *length) {
                        return r;
                    }
                }
                // The proprietary Microsoft `alpha()` filter overload (see
                // `ms_filter_args`): dart-sass passes the call through verbatim
                // as a CSS function instead of treating the argument as a
                // color. Returned from here, ahead of the dispatcher, because
                // the global spelling must not deprecate on the way.
                if ms_alpha_filter {
                    if let Some(args) = crate::builtins::ms_filter_args(&pos_args, &named) {
                        return Ok(Value::Str(SassStr {
                            text: crate::builtins::ms_filter_text(&args).into(),
                            quoted: false,
                        }));
                    }
                }
                // A member exposed unprefixed via `@use "sass:<mod>" as *` is
                // that module's, and it SHADOWS the global of the same name:
                // after `@use "sass:string" as *`, `index("abc", "b")` is
                // `string.index` (2), not the list one.
                if let Some((owner, bare)) = via_star {
                    for v in &mut pos_args {
                        *v = std::mem::replace(v, Value::Null).without_slash();
                    }
                    for (n, v) in &mut named {
                        *v = std::mem::replace(v, Value::Null).without_slash();
                        let _ = n;
                    }
                    // A `sass:meta` member resolves against the evaluator, which
                    // the value-only dispatcher cannot do.
                    if owner == "meta" {
                        if let Some(r) = self.try_meta_eval_call(&bare, &pos_args, &named, *pos, *length) {
                            return r;
                        }
                    }
                    // The caret spans the INVOCATION, as it does for the same
                    // member written with its namespace (which sizes the error
                    // the same way). Without this a member reached through the
                    // star drew a one-column caret under the opening `i` of
                    // `index(1, 2, 3)`.
                    let v = crate::builtins::call_module(&owner, &bare, &pos_args, &named, *pos)
                        .map_err(|e| e.with_length_at(*pos, *length))?;
                    self.emit_color_function_deprecation(
                        &bare,
                        Some(&owner),
                        *pos,
                        *length,
                        &pos_args,
                        &named,
                    );
                    return Ok(v.without_slash());
                }
                // Host-defined custom functions (dart-sass `functions`): they
                // override built-in globals but lose to user `@function`s and
                // module members (checked above). Resolved by calling back into
                // the embedder with the bound args serialized to the host-value
                // wire format.
                if !self.options.functions.is_empty() {
                    let norm = crate::host_fn::normalize_name(name);
                    if let Some(idx) = self.options.functions.iter().position(|f| f.name == norm) {
                        // Extract the owned signature + callback so the immutable
                        // borrow on `self.options` ends before any `&mut self`.
                        let (param_names, rest_name): (Vec<String>, Option<String>) = {
                            let hf = &self.options.functions[idx];
                            match &hf.params {
                                Ok(p) => (p.params.iter().map(|x| x.name.clone()).collect(), p.rest.clone()),
                                Err(e) => return Err(Error::at(e.clone(), *pos)),
                            }
                        };
                        let callback = self.options.functions[idx].callback.clone();
                        // Real Sass function: collapse slash-division args.
                        for v in &mut pos_args {
                            *v = std::mem::replace(v, Value::Null).without_slash();
                        }
                        for (_, v) in &mut named {
                            *v = std::mem::replace(v, Value::Null).without_slash();
                        }
                        let bound = crate::host_fn::bind_host_args(
                            &param_names,
                            rest_name.as_deref(),
                            std::mem::take(&mut pos_args),
                            std::mem::take(&mut named),
                            call_sep,
                            &norm,
                        )
                        .map_err(|e| Error::at(e, *pos))?;
                        // First-class function/mixin args round-trip as opaque
                        // handles into a per-dispatch table; save/restore the
                        // outer table so a nested custom-function call is safe.
                        let saved = crate::host_fn::swap_handles(Vec::new());
                        // The host runs with the bump arena paused, like an
                        // importer or warn handler: whatever it allocates and
                        // keeps (a cache, a nested compile's result) must not
                        // sit in this compile's arena, which is reset on exit.
                        let result: Result<Value, String> = crate::host_fn::serialize_args(&bound)
                            .and_then(|b| {
                                let _paused = crate::arena::pause();
                                callback(&b)
                            })
                            .and_then(|b| crate::host_fn::deserialize_value(&b));
                        crate::host_fn::swap_handles(saved);
                        return result.map_err(|e| Error::at(e, *pos)).map(Value::without_slash);
                    }
                }
                // A bare slash-division argument collapses to its number when
                // passed to a real Sass function (dart-sass `withoutSlash`);
                // plain CSS functions (`foo(1/2)`) keep the slash verbatim.
                if crate::builtins::is_builtin(name) {
                    for v in &mut pos_args {
                        *v = std::mem::replace(v, Value::Null).without_slash();
                    }
                    for (_, v) in &mut named {
                        *v = std::mem::replace(v, Value::Null).without_slash();
                    }
                }
                // A function call's RESULT is slash-free too (dart applies
                // `withoutSlash()` to every call result): `list.nth(3 1/2 4,
                // 2)` returns 0.5, not the slash form.
                // The name as WRITTEN: `builtins::call` canonicalizes its own
                // lookup, and a name that is no builtin passes through as the
                // plain-CSS function it was spelled as.
                let v = crate::builtins::call(name, &pos_args, &named, *pos)?;
                self.emit_color_function_deprecation(canonical, None, *pos, *length, &pos_args, &named);
                Ok(v.without_slash())
            }
        }
    }
}
