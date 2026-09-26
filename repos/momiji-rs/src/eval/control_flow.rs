use super::*;

/// Iteration source for `@each`. A list is held as its shared `Rc<[Value]>`
/// handle so each iteration clones a single element on demand (avoiding the
/// up-front `Vec<Value>` copy of the whole collection); maps and scalars are
/// materialised into a small owned set.
pub(super) enum EachItems {
    Shared(std::rc::Rc<[Value]>),
    Owned(Vec<Value>),
}

impl EachItems {
    pub(super) fn len(&self) -> usize {
        match self {
            EachItems::Shared(items) => items.len(),
            EachItems::Owned(items) => items.len(),
        }
    }

    /// Clone the `i`th item — one element, never the whole collection.
    pub(super) fn get(&self, i: usize) -> Value {
        match self {
            EachItems::Shared(items) => items[i].clone(),
            EachItems::Owned(items) => items[i].clone(),
        }
    }
}

impl<'a> Evaluator<'a> {
    /// Evaluate a `@for` bound to a [`Number`], preserving its unit (the loop
    /// variable inherits the `from` bound's unit).
    fn eval_for_number(&mut self, e: &Expr) -> Result<Number, Error> {
        match self.eval_expr(e)? {
            Value::Number(n) => Ok(n),
            other => Err(Error::unpositioned(format!(
                "{} is not a number.",
                other.type_name()
            ))),
        }
    }

    /// Resolve a `@for`'s bounds: the integer start, the integer end (the TO
    /// bound converted to the FROM bound's unit), and the loop variable's unit
    /// (taken from FROM). Errors on incompatible units or a non-integer bound,
    /// matching dart-sass.
    pub(super) fn for_bounds(&mut self, from: &Expr, to: &Expr) -> Result<(i64, i64, String), Error> {
        let start = self.eval_for_number(from)?;
        let end = self.eval_for_number(to)?;
        // The loop variable takes FROM's unit; TO is converted to match. A
        // unitless side defers (no conversion); two incompatible real units err.
        let end_value = if start.is_unitless() || end.is_unitless() {
            end.value
        } else {
            match crate::value::convert_factor(end.unit(), start.unit()) {
                Some(f) => end.value * f,
                None => {
                    return Err(Error::unpositioned(format!(
                        "Expected {} to have unit {}.",
                        Value::Number(end.clone()).to_css(false),
                        start.unit(),
                    )))
                }
            }
        };
        // Both bounds must be integers (dart-sass: "<n> is not an int.").
        let to_int = |v: f64, n: Number| -> Result<i64, Error> {
            if (v - v.round()).abs() < 1e-11 {
                Ok(v.round() as i64)
            } else {
                Err(Error::unpositioned(format!(
                    "{} is not an int.",
                    Value::Number(n).to_css(false)
                )))
            }
        };
        let start_i = to_int(start.value, start.clone())?;
        let end_i = to_int(end_value, Number::with_unit(end_value, start.unit()))?;
        Ok((start_i, end_i, start.unit().to_string()))
    }

    /// The values `@each` iterates: a list yields its items, `null` yields
    /// nothing, and any other value is iterated once. A list returns its
    /// `Rc<[Value]>` handle directly (a refcount bump) so the loop can clone
    /// one element per iteration instead of deep-copying the whole collection
    /// up front; maps and scalars build a small owned set.
    pub(super) fn eval_each_items(&mut self, e: &Expr) -> Result<EachItems, Error> {
        match self.eval_expr(e)? {
            Value::List(l) => Ok(EachItems::Shared(l.items)),
            // `@each` over a map yields each `key value` pair as a two-element
            // space list, so `@each $k, $v in $map` destructures correctly.
            Value::Map(m) => Ok(EachItems::Owned(
                m.entries
                    .as_ref()
                    .clone()
                    .into_iter()
                    .map(|(k, v)| {
                        Value::List(List {
                            items: vec![k, v].into(),
                            sep: ListSep::Space,
                            bracketed: false,
                            keywords: None,
                        })
                    })
                    .collect(),
            )),
            // Any non-list — INCLUDING null — iterates as a singleton (dart
            // `Value.asList` defaults to `[this]`; bootstrap's `valid-radius`
            // relies on `@each $v in null` running once with `$v: null`).
            other => Ok(EachItems::Owned(vec![other])),
        }
    }

    /// Bind `@each` variables to an item, destructuring a list across
    /// multiple variables (missing elements become `null`).
    /// `span` is the definition span every bound variable gets — dart binds all
    /// of them to `_expressionNode(node.list)`, the list expression itself
    /// (evaluate.dart:1441, `_setMultipleVariables` at 1465).
    pub(super) fn bind_each(&mut self, vars: &[String], item: Value, span: VarSpan) {
        if vars.len() == 1 {
            self.set_local(&vars[0], item, span);
            return;
        }
        match item {
            // Index the list's `Rc<[Value]>` directly — cloning only the
            // elements the vars need, with no intermediate `Vec<Value>`.
            Value::List(l) => {
                for (i, v) in vars.iter().enumerate() {
                    let val = l.items.get(i).cloned().unwrap_or(Value::Null);
                    self.set_local(v, val, span);
                }
            }
            // A non-list binds to the first var; the remaining vars are null.
            other => {
                self.set_local(&vars[0], other, span);
                for v in &vars[1..] {
                    self.set_local(v, Value::Null, span);
                }
            }
        }
    }

    /// Evaluate a call's argument list into separate positional and keyword
    /// vectors, expanding any `...` splat (a list spreads into positional
    /// args, a map into keyword args). Duplicate keyword names (after
    /// hyphen/underscore normalization) are rejected, and a positional arg
    /// after a keyword arg is an error — matching dart-sass.
    ///
    /// This form discards the source-map definition spans — and so never
    /// collects them; callers that bind the results to user parameters want
    /// [`Self::eval_call_args_spanned`].
    pub(super) fn eval_call_args(&mut self, args: &[CallArg]) -> Result<EvaledArgs, Error> {
        Ok(self.eval_call_args_inner(args, false)?.0)
    }

    /// As [`Self::eval_call_args`], but also returns each argument's definition
    /// span (dart `ArgumentResults.positionalNodes` / `namedNodes`), so a bound
    /// parameter can inherit the span of the argument it was bound to.
    pub(super) fn eval_call_args_spanned(
        &mut self,
        args: &[CallArg],
    ) -> Result<(EvaledArgs, ArgSpans), Error> {
        self.eval_call_args_inner(args, true)
    }

    /// The shared body. `want_spans` is the caller's answer to "will anything
    /// read the spans?" — a built-in binds its arguments by position and by
    /// name, never by span, so `math.div($a, $b)` was building a vector of them
    /// and dropping it on return.
    ///
    /// Together with `EvalOptions::source_map`, which gates definition-span
    /// bookkeeping everywhere else, that decides whether spans are tracked at
    /// all. When they are not, the three span vectors below stay EMPTY and
    /// never allocate: an [`ArgSpans`] entry that is absent reads back as the
    /// "unknown" span, which is what an untracked argument carries anyway.
    fn eval_call_args_inner(
        &mut self,
        args: &[CallArg],
        want_spans: bool,
    ) -> Result<(EvaledArgs, ArgSpans), Error> {
        let track_spans = want_spans && self.options.source_map;
        // Explicit positional args are gathered first; positionals spread from
        // a `...` splat are appended after them, so `f([1, 2]..., 3)` binds
        // `3` before `1, 2` (matching dart-sass's misplaced-rest behaviour).
        let mut explicit_pos = Vec::with_capacity(args.len());
        let mut splat_pos = Vec::new();
        let mut keyword: Vec<(String, Value)> = Vec::new();
        let mut seen_named = false;
        // Definition spans tracked in lockstep with the three value vectors
        // above (dart builds `positionalNodes`/`namedNodes` the same way,
        // evaluate.dart:3812-3824). Every element a splat expands to gets the
        // SPLAT EXPRESSION's own span, not a per-element one — dart fills the
        // whole run with `restNodeForSpan` (evaluate.dart:3851).
        let mut explicit_pos_spans: Vec<VarSpan> =
            Vec::with_capacity(if track_spans { args.len() } else { 0 });
        let mut splat_pos_spans: Vec<VarSpan> = Vec::new();
        let mut keyword_spans: Vec<(String, VarSpan)> = Vec::new();
        // A splatted list's separator survives into the callee's rest arglist
        // (`foo(c d e...)` binds `$zs` as a SPACE-separated arglist).
        let mut rest_sep = ListSep::Comma;
        let push_named = |keyword: &mut Vec<(String, Value)>,
                          spans: &mut Vec<(String, VarSpan)>,
                          name: String,
                          v: Value,
                          sp: VarSpan|
         -> Result<(), Error> {
            let norm = normalize_arg_name(&name);
            if keyword.iter().any(|(n, _)| normalize_arg_name(n) == norm) {
                return Err(Error::unpositioned("Duplicate argument."));
            }
            if track_spans {
                spans.push((name.clone(), sp));
            }
            keyword.push((name, v));
            Ok(())
        };
        for a in args {
            let v = self.eval_expr(&a.value)?;
            // dart resolves each argument's node right after evaluating it
            // (evaluate.dart:3814), so a bare `$x` argument carries `$x`'s
            // DEFINITION rather than the call site. Resolving one walks the
            // scope chain, so it waits until something wants the answer too.
            let sp = if track_spans {
                self.expression_node(&a.value, a.value_pos)
            } else {
                VarSpan::default()
            };
            if a.splat {
                // A splat list spreads into positional args; a map spreads
                // into keyword args (string keys only). A single non-list/map
                // value acts as one positional arg; `null` spreads to nothing.
                match v {
                    Value::Map(m) => {
                        for (k, val) in m.entries.as_ref().clone() {
                            let key = match &k {
                                Value::Str(s) => s.text.to_string(),
                                other => {
                                    return Err(Error::unpositioned(format!(
                                        "{} is not a string in $args.",
                                        other.to_css(false)
                                    )))
                                }
                            };
                            push_named(&mut keyword, &mut keyword_spans, key, val, sp)?;
                        }
                    }
                    Value::List(l) => {
                        if !matches!(l.sep, ListSep::Undecided) {
                            rest_sep = l.sep;
                        }
                        // `iter::repeat_n` is 1.82; the crate's MSRV is 1.74.
                        if track_spans {
                            splat_pos_spans.extend(std::iter::repeat(sp).take(l.items.len()));
                        }
                        splat_pos.extend(l.items.to_vec());
                        // An argument-list splat (`$args...`) also forwards its
                        // captured keyword arguments as named arguments.
                        if let Some(kw) = l.keywords {
                            for (k, val) in kw {
                                if let Value::Str(s) = k {
                                    push_named(
                                        &mut keyword,
                                        &mut keyword_spans,
                                        s.text.to_string(),
                                        val,
                                        sp,
                                    )?;
                                }
                            }
                        }
                    }
                    Value::Null => {}
                    other => {
                        splat_pos.push(other);
                        if track_spans {
                            splat_pos_spans.push(sp);
                        }
                    }
                }
                continue;
            }
            match &a.name {
                Some(n) => {
                    push_named(&mut keyword, &mut keyword_spans, n.clone(), v, sp)?;
                    seen_named = true;
                }
                None => {
                    // A plain positional arg may not follow a keyword arg.
                    if seen_named {
                        return Err(Error::unpositioned(
                            "Positional arguments must come before keyword arguments.",
                        ));
                    }
                    explicit_pos.push(v);
                    if track_spans {
                        explicit_pos_spans.push(sp);
                    }
                }
            }
        }
        explicit_pos.extend(splat_pos);
        explicit_pos_spans.extend(splat_pos_spans);
        Ok((
            (explicit_pos, keyword, rest_sep),
            ArgSpans {
                positional: explicit_pos_spans,
                named: keyword_spans,
            },
        ))
    }

    /// Bind evaluated arguments into the CURRENT (freshly pushed) scope.
    /// Parameter defaults evaluate inside the callee environment with the
    /// already-bound parameters visible (`@mixin m($a, $b: $a)`), matching
    /// dart's progressive binding.
    ///
    /// `spans` carries each argument's definition span; a parameter inherits the
    /// span of whatever it was bound to — the matching argument, or, when it
    /// falls back to its declared default, that default's own expression node
    /// (dart evaluate.dart:3572-3592). Source-map only.
    pub(super) fn bind_evaled_into_scope(
        &mut self,
        params: &ParamList,
        evaled: EvaledArgs,
        spans: &ArgSpans,
        decl: &Declared<'_>,
    ) -> Result<(), Error> {
        let (positional, keyword_vec, rest_sep) = evaled;
        let mut keyword: HashMap<String, Value> = HashMap::default();
        let mut keyword_order: Vec<(String, String)> = Vec::new();
        for (n, v) in keyword_vec {
            let norm = normalize_arg_name(&n).into_owned();
            if !keyword.contains_key(&norm) {
                keyword_order.push((norm.clone(), n));
            }
            keyword.insert(norm, v);
        }
        let positional_count = positional.len();
        let mut pos_iter = positional.into_iter().enumerate();
        for param in &params.params {
            let (val, span) = if let Some((i, v)) = pos_iter.next() {
                (v, spans.positional(i))
            } else if let Some(v) = keyword.remove(normalize_arg_name(&param.name).as_ref()) {
                (v, spans.named(&param.name))
            } else if let Some(def) = &param.default {
                let v = self.eval_expr(def)?;
                // A default is resolved through `_expressionNode` too, so
                // `@mixin m($a, $b: $a)` gives `$b` whatever `$a` points at.
                let sp = self.expression_node(def, param.default_pos);
                (v, sp)
            } else {
                // dart reports a missing argument against the INVOCATION as
                // its primary span, with the declaration it was measured
                // against beside it. Every call path pushes the call's frame
                // before binding, so it is the innermost one.
                return Err(
                    self.error_at_call_with_declaration(format!("Missing argument ${}.", param.name), decl)
                );
            };
            if let Some(sc) = self.scopes.last() {
                sc.borrow_mut().insert(param.name.clone(), val);
            }
            if let Some(frame) = self.var_spans.last() {
                frame.borrow_mut().insert(param.name.clone(), span);
            }
        }
        if let Some(rest) = &params.rest {
            let remaining: Vec<Value> = pos_iter.map(|(_, v)| v).collect();
            let kw: Vec<(Value, Value)> = keyword_order
                .iter()
                .filter_map(|(norm, _)| {
                    keyword.remove(norm).map(|v| {
                        (
                            Value::Str(SassStr {
                                text: norm.clone().into(),
                                quoted: false,
                            }),
                            v,
                        )
                    })
                })
                .collect();
            if let Some(sc) = self.scopes.last() {
                sc.borrow_mut().insert(
                    rest.clone(),
                    Value::List(List {
                        items: remaining.into(),
                        sep: rest_sep,
                        bracketed: false,
                        keywords: Some(kw),
                    }),
                );
            }
            // dart blames the CALL node for a `$rest...` arglist
            // (evaluate.dart:3609), which is not a value position sasso maps;
            // record "unknown" so no segment is emitted for it.
            if let Some(frame) = self.var_spans.last() {
                frame.borrow_mut().insert(rest.clone(), VarSpan::default());
            }
        } else if pos_iter.next().is_some() {
            // dart counts what was DECLARED against what was passed, and
            // agrees with itself about the verb.
            let allowed = params.params.len();
            let passed = positional_count;
            return Err(self.error_at_call_with_declaration(
                format!(
                    "Only {allowed} {}argument{} allowed, but {passed} {} passed.",
                    // dart says "positional" the moment a NAMED argument is in
                    // play, and counts only the positional ones.
                    if keyword_order.is_empty() {
                        ""
                    } else {
                        "positional "
                    },
                    if allowed == 1 { "" } else { "s" },
                    if passed == 1 { "was" } else { "were" }
                ),
                decl,
            ));
        }
        if params.rest.is_none() && !keyword.is_empty() {
            let leftover: Vec<&str> = keyword_order
                .iter()
                .filter(|(norm, _)| keyword.contains_key(norm))
                .map(|(_, orig)| orig.as_str())
                .collect();
            if let Some((last, init)) = leftover.split_last() {
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
                return Err(self.error_at_call_with_declaration(msg, decl));
            }
        }
        Ok(())
    }

    /// Call a user-defined `@function`, returning its `@return` value. `call`,
    /// when present, is the (name-start position, byte length) of the call
    /// expression, recorded as a diagnostic stack frame around the body.
    pub(super) fn call_function(
        &mut self,
        func: &Rc<UserCallable>,
        args: &[CallArg],
        call: Option<(Pos, usize)>,
    ) -> Result<Value, Error> {
        // Arguments evaluate in the CALLER's environment; the body (and the
        // parameter defaults) run against the callable's LEXICAL closure.
        let (evaled, arg_spans) = self.eval_call_args_spanned(args)?;
        // The call frame records the CALL site (this file); the body then runs
        // against the function's defining file.
        let saved = call.map(|(pos, len)| self.enter_call(pos, len, &format!("{}()", func.def.name)));
        let saved_file = self.enter_origin_file(Some(&func.origin));
        let saved_scopes = std::mem::replace(&mut self.scopes, func.env.clone());
        let saved_var_spans = std::mem::replace(&mut self.var_spans, func.env_spans.clone());
        let saved_semi = std::mem::replace(&mut self.scope_semi_global, func.env_semi.clone());
        let saved_fns = std::mem::replace(&mut self.functions, func.env_fns.clone());
        let saved_mixins = std::mem::replace(&mut self.mixins, func.env_mixins.clone());
        let saved_env_modules = self.install_env_modules(&func.env_modules);
        self.push_scope(false);
        let result = self
            .bind_evaled_into_scope(&func.def.params, evaled, &arg_spans, &declared(func))
            .and_then(|()| {
                // A function body is not a mixin body: `meta.content-exists()`
                // called from a function (even one invoked by a mixin) errors.
                self.in_mixin.push(false);
                let r = self.run_fn_body(&func.def.body);
                self.in_mixin.pop();
                r
            })
            // Render a positioned error while its file is still current.
            .map_err(|e| self.finalize_error(e));
        self.pop_scope();
        self.scopes = saved_scopes;
        self.var_spans = saved_var_spans;
        self.scope_semi_global = saved_semi;
        self.functions = saved_fns;
        self.mixins = saved_mixins;
        self.restore_env_modules(saved_env_modules);
        self.leave_module_file(saved_file);
        if let Some(saved) = saved {
            self.leave_call(saved);
        }
        match result? {
            // A bare slash-division returned from a function collapses to
            // its number (dart-sass `withoutSlash`); slashes nested in a
            // returned list are preserved.
            Some(v) => Ok(v.without_slash()),
            None => Err(Error::unpositioned(format!(
                "Function {}() did not @return a value.",
                func.def.name
            ))),
        }
    }

    /// Run a function body, propagating the first `@return` (including from
    /// nested control flow). Functions emit no CSS, so a returned value
    /// short-circuits the whole call.
    pub(super) fn run_fn_body(&mut self, stmts: &[Stmt]) -> Result<Option<Value>, Error> {
        for stmt in stmts {
            match stmt {
                Stmt::VarDecl(v) => self.apply_var(v)?,
                Stmt::Comment(..) => {}
                Stmt::Return(e) => return Ok(Some(self.eval_expr(e)?)),
                Stmt::FunctionDef(c) => {
                    let captured = self.capture_callable(c);
                    self.define_function(&c.name, captured);
                }
                Stmt::If(branches) => {
                    for branch in branches {
                        let take = match &branch.cond {
                            None => true,
                            Some(c) => self.eval_expr(c)?.is_truthy(),
                        };
                        if take {
                            self.push_scope(true);
                            let result = self.run_fn_body(&branch.body);
                            self.pop_scope();
                            if let Some(v) = result? {
                                return Ok(Some(v));
                            }
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
                    self.push_scope(true);
                    // dart resolves the loop variable's node INSIDE the loop
                    // scope (evaluate.dart:1666) — but `@for` pushes a fresh
                    // frame, so the lookup still sees the outer bindings.
                    let span = self.expression_node(from, *from_pos);
                    let mut result = Ok(None);
                    for i in for_indices(start_i, end_i, *inclusive) {
                        self.set_local(var, Value::Number(Number::with_unit(i as f64, &unit)), span);
                        result = self.run_fn_body(body);
                        if matches!(result, Ok(None)) {
                            continue;
                        }
                        break;
                    }
                    self.pop_scope();
                    if let Some(v) = result? {
                        return Ok(Some(v));
                    }
                }
                Stmt::Each {
                    vars,
                    list,
                    body,
                    list_pos,
                } => {
                    let items = self.eval_each_items(list)?;
                    // Resolved BEFORE the loop scope is pushed, like dart
                    // (evaluate.dart:1441 precedes `_environment.scope`).
                    let span = self.expression_node(list, *list_pos);
                    self.push_scope(true);
                    let mut result = Ok(None);
                    for i in 0..items.len() {
                        self.bind_each(vars, items.get(i), span);
                        result = self.run_fn_body(body);
                        if matches!(result, Ok(None)) {
                            continue;
                        }
                        break;
                    }
                    self.pop_scope();
                    if let Some(v) = result? {
                        return Ok(Some(v));
                    }
                }
                Stmt::While { cond, body } => {
                    self.push_scope(true);
                    let mut result: Result<Option<Value>, Error> = Ok(None);
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
                        result = self.run_fn_body(body);
                        if !matches!(result, Ok(None)) {
                            break;
                        }
                        guard += 1;
                        if guard >= 100_000 {
                            result = Err(Error::unpositioned("@while exceeded 100000 iterations"));
                            break;
                        }
                    }
                    self.pop_scope();
                    if let Some(v) = result? {
                        return Ok(Some(v));
                    }
                }
                Stmt::Warn { value, pos } => self.emit_warn(value, *pos)?,
                Stmt::Debug { value, pos } => self.emit_debug(value, *pos)?,
                Stmt::Error { value, pos, length } => {
                    return Err(self.build_error(value, *pos, *length));
                }
                _ => {
                    return Err(Error::unpositioned(
                        "only variable assignments, control flow and @return are allowed in a function.",
                    ));
                }
            }
        }
        Ok(None)
    }

    /// Execute an `@include`: bind args into a call frame, make the content
    /// block available, and run the mixin body into the current sink.
    #[allow(clippy::too_many_arguments)]
    pub(super) fn exec_include(
        &mut self,
        name: &str,
        args: &[CallArg],
        content: Option<Rc<Vec<Stmt>>>,
        content_params: Option<Rc<ParamList>>,
        module: Option<&str>,
        pos: Pos,
        // The CALL's byte length, content block excluded — dart's
        // `spanWithoutContent`, which sizes an error about the call itself.
        length: usize,
        // The whole statement's byte length — an error about the RULE (this
        // mixin does not exist, that namespace does not exist) carets all of
        // it, content block included, as dart's `span` does.
        full_length: usize,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // NOTE: the diagnostic call frame for this `@include` is pushed by the
        // caller (the `Stmt::Include` arm) so it wraps every resolution path.
        // The built-in `@include meta.apply(...)` / `meta.load-css(...)` are
        // bound to the `sass:meta` namespace, so resolve them before the generic
        // module path.
        if let Some(ns) = module {
            if self.used_modules.get(ns).copied() == Some("meta") {
                // `_` and `-` are one character in a Sass identifier, so
                // `meta.load_css(…)` is `meta.load-css(…)`.
                match normalize_arg_name(name).as_ref() {
                    "apply" => {
                        return self.exec_apply(args, content, content_params, pos, length, parents, sink)
                    }
                    "load-css" => return self.exec_load_css(args, content, pos, parents, sink),
                    _ => {}
                }
            }
        }
        // A namespaced `@include ns.mixin`: resolve a user module bound to the
        // namespace, then a built-in (which exposes no mixins in this build).
        if let Some(ns) = module {
            if let Some(target) = self.used_user_modules.get(ns).cloned() {
                if is_private_member(name) {
                    // dart omits private members from a module's public view,
                    // so a reference to one is simply not found. (A LITERAL
                    // `ns.-name` never reaches here — the parser rejects it
                    // with dart's privacy error; what does is an ESCAPED
                    // spelling, which dart treats as an ordinary member.)
                    return Err(Error::at("Undefined mixin.", pos).with_length(full_length));
                }
                // A built-in this module re-exports brings its mixins along
                // (`@forward "sass:meta"` re-exports `load-css`/`apply`).
                if target.mixin(name).is_none() {
                    if let Some((owner, bare)) = super::meta::resolve_forwarded_builtin_mixin(&target, name) {
                        if owner == "meta" && bare == "apply" {
                            return self.exec_apply(
                                args,
                                content,
                                content_params,
                                pos,
                                length,
                                parents,
                                sink,
                            );
                        }
                        if owner == "meta" && bare == "load-css" {
                            return self.exec_load_css(args, content, pos, parents, sink);
                        }
                    }
                }
                let mixin = target
                    .mixin(name)
                    .ok_or_else(|| Error::at("Undefined mixin.", pos).with_length(full_length))?;
                // A forwarded mixin runs in its DEFINING module's environment.
                let exec = target.mixin_origin(name).unwrap_or(target);
                return self.run_module_mixin(
                    &exec,
                    &mixin,
                    args,
                    content,
                    content_params,
                    pos,
                    length,
                    parents,
                    sink,
                );
            }
            if !self.used_modules.contains_key(ns) {
                return Err(
                    Error::at(format!("There is no module with the namespace \"{ns}\"."), pos)
                        .with_length(full_length),
                );
            }
            return Err(Error::at("Undefined mixin.", pos).with_length(full_length));
        }
        // A bare `@include` may resolve a user module mixin exposed unprefixed
        // via `@use … as *`.
        if self.lookup_mixin(name).is_none() && !is_private_member(name) {
            let hits: Vec<(Rc<Module>, Rc<UserCallable>)> = self
                .star_user_modules
                .iter()
                .filter_map(|m| m.mixin(name).map(|mx| (Rc::clone(m), mx)))
                .collect();
            // A built-in mixin exposed unprefixed the same way (`load-css` and
            // `apply` from `sass:meta`, directly or through a user module that
            // forwards it) competes for the same bare name.
            let builtin_hits = self.star_builtin_hits(name, MemberKind::Mixin);
            if hits.len() + builtin_hits.len() > 1 {
                // dart carets the `@include` (and adds a secondary row per
                // `@use`, which this renderer cannot draw yet).
                return Err(
                    Error::at("This mixin is available from multiple global modules.", pos)
                        .with_length(full_length),
                );
            }
            if let Some((m, mx)) = hits.into_iter().next() {
                return self.run_module_mixin(
                    &m,
                    &mx,
                    args,
                    content,
                    content_params,
                    pos,
                    length,
                    parents,
                    sink,
                );
            }
            if let Some((owner, bare)) = builtin_hits.into_iter().next() {
                if owner == "meta" && bare == "apply" {
                    return self.exec_apply(args, content, content_params, pos, length, parents, sink);
                }
                if owner == "meta" && bare == "load-css" {
                    return self.exec_load_css(args, content, pos, parents, sink);
                }
            }
        }
        let mixin = self
            .lookup_mixin(name)
            .ok_or_else(|| Error::at("Undefined mixin.", pos).with_length(full_length))?;
        // dart-sass: passing a content block to a mixin that never uses
        // `@content` is an error, even when the block is empty.
        if content.is_some() && !body_uses_content(&mixin.def.body) {
            // Raised BEFORE the mixin is entered, so its own frame is not on
            // the stack — dart shows only the caller's.
            return Err(self.error_with_declaration_at(
                "Mixin doesn't accept a content block.",
                pos,
                length,
                &declared(&mixin),
            ));
        }
        // Arguments evaluate in the caller's environment; the body runs in
        // the mixin's lexical closure. The content block captures the CALL
        // SITE so `@content` sees the includer's variables.
        let (evaled, arg_spans) = self.eval_call_args_spanned(args)?;
        let content_block = content.map(|stmts| {
            let snapshot = self.snapshot_env();
            ContentBlock {
                stmts,
                params: content_params.clone(),
                caller_env: Some(Box::new(snapshot)),
                origin: Some(self.current_mixin_origin()),
            }
        });
        // The body runs against the mixin's defining file (the `@include`
        // frame, recorded by the caller, already names this file).
        let saved_file = self.enter_origin_file(Some(&mixin.origin));
        let saved_scopes = std::mem::replace(&mut self.scopes, mixin.env.clone());
        let saved_var_spans = std::mem::replace(&mut self.var_spans, mixin.env_spans.clone());
        let saved_semi = std::mem::replace(&mut self.scope_semi_global, mixin.env_semi.clone());
        let saved_fns = std::mem::replace(&mut self.functions, mixin.env_fns.clone());
        let saved_mixins = std::mem::replace(&mut self.mixins, mixin.env_mixins.clone());
        let saved_env_modules = self.install_env_modules(&mixin.env_modules);
        self.push_scope(false);
        let result = self
            .bind_evaled_into_scope(&mixin.def.params, evaled, &arg_spans, &declared(&mixin))
            .and_then(|()| {
                self.content_stack.push(content_block);
                self.in_mixin.push(true);
                let r = self.exec(&mixin.def.body, parents, sink);
                self.in_mixin.pop();
                self.content_stack.pop();
                r
            })
            .map_err(|e| self.finalize_error(e));
        self.pop_scope();
        self.scopes = saved_scopes;
        self.var_spans = saved_var_spans;
        self.scope_semi_global = saved_semi;
        self.functions = saved_fns;
        self.mixins = saved_mixins;
        self.restore_env_modules(saved_env_modules);
        self.leave_module_file(saved_file);
        result
    }

    /// Execute an `@include ns.mixin` where `ns` is a user module: run the mixin
    /// body in the module's own environment, while its `@content` block (if any)
    /// runs back in the call site's environment.
    #[allow(clippy::too_many_arguments)]
    fn run_module_mixin(
        &mut self,
        module: &Rc<Module>,
        mixin: &Rc<UserCallable>,
        args: &[CallArg],
        content: Option<Rc<Vec<Stmt>>>,
        content_params: Option<Rc<ParamList>>,
        pos: Pos,
        length: usize,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        if content.is_some() && !body_uses_content(&mixin.def.body) {
            // Raised BEFORE the mixin is entered, so its own frame is not on
            // the stack — dart shows only the caller's.
            return Err(self.error_with_declaration_at(
                "Mixin doesn't accept a content block.",
                pos,
                length,
                &declared(mixin),
            ));
        }
        // Evaluate the arguments at the call site (so they resolve in the
        // caller's scope), then enter the module's environment and the
        // mixin's lexical closure for the body. Snapshot the call-site env
        // so a `@content` block runs there, not in the module.
        let (evaled, arg_spans) = self.eval_call_args_spanned(args)?;
        let content_block = content.map(|stmts| {
            let snapshot = self.snapshot_env();
            ContentBlock {
                stmts,
                params: content_params.clone(),
                caller_env: Some(Box::new(snapshot)),
                origin: Some(self.current_mixin_origin()),
            }
        });
        let saved = self.enter_module(module);
        // The mixin's own defining file beats the module handed to us: a
        // multi-hop `@forward` can name a module other than the file that
        // wrote the mixin.
        let saved_file = self.enter_origin_file(Some(&mixin.origin));
        let saved_scopes = std::mem::replace(&mut self.scopes, mixin.env.clone());
        let saved_var_spans = std::mem::replace(&mut self.var_spans, mixin.env_spans.clone());
        let saved_semi = std::mem::replace(&mut self.scope_semi_global, mixin.env_semi.clone());
        let saved_fns = std::mem::replace(&mut self.functions, mixin.env_fns.clone());
        let saved_mixins = std::mem::replace(&mut self.mixins, mixin.env_mixins.clone());
        let saved_env_modules = self.install_env_modules(&mixin.env_modules);
        self.push_scope(false);
        let result = self
            .bind_evaled_into_scope(&mixin.def.params, evaled, &arg_spans, &declared(mixin))
            .and_then(|()| {
                self.content_stack.push(content_block);
                // A mixin body: `meta.content-exists()` is allowed and answers
                // for THIS include (as on the direct include path).
                self.in_mixin.push(true);
                let r = self.exec(&mixin.def.body, parents, sink);
                self.in_mixin.pop();
                self.content_stack.pop();
                r
            })
            .map_err(|e| self.finalize_error(e));
        self.pop_scope();
        self.scopes = saved_scopes;
        self.var_spans = saved_var_spans;
        self.scope_semi_global = saved_semi;
        self.functions = saved_fns;
        self.mixins = saved_mixins;
        self.restore_env_modules(saved_env_modules);
        self.leave_module_file(saved_file);
        self.leave_module(saved);
        result
    }

    /// `@include meta.apply($mixin, $args...)`: invoke a first-class mixin
    /// reference. The first argument is the mixin reference; the rest are the
    /// arguments passed on to that mixin (which may also accept a `@content`
    /// block).
    #[allow(clippy::too_many_arguments)]
    fn exec_apply(
        &mut self,
        args: &[CallArg],
        content: Option<Rc<Vec<Stmt>>>,
        content_params: Option<Rc<ParamList>>,
        pos: Pos,
        // The CALL's byte length, content block excluded — what an error about
        // the call itself carets, exactly as a direct `@include` does.
        length: usize,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // Evaluate apply's own arguments (expanding any `...` splat). The first
        // positional (or named `$mixin`) is the mixin reference; the remainder
        // are forwarded to the mixin.
        let (mut pos_args, mut named, _) = self.eval_call_args(args)?;
        for v in &mut pos_args {
            *v = std::mem::replace(v, Value::Null).without_slash();
        }
        for (_, v) in &mut named {
            *v = std::mem::replace(v, Value::Null).without_slash();
        }
        self.apply_evaled(
            pos_args,
            named,
            content,
            content_params,
            pos,
            length,
            parents,
            sink,
        )
    }

    /// `meta.apply` with its arguments already evaluated — the form a
    /// first-class reference to it arrives in.
    #[allow(clippy::too_many_arguments)]
    fn apply_evaled(
        &mut self,
        pos_args: Vec<Value>,
        mut named: Vec<(String, Value)>,
        content: Option<Rc<Vec<Stmt>>>,
        content_params: Option<Rc<ParamList>>,
        // The `@include` this invocation came from — what an error inside the
        // mixin carets, exactly as a direct `@include meta.load-css(…)` does.
        pos: Pos,
        length: usize,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        let (mixin_val, rest_pos): (Value, Vec<Value>) = if !pos_args.is_empty() {
            let mut iter = pos_args.into_iter();
            let first = iter.next().unwrap_or(Value::Null);
            (first, iter.collect())
        } else if let Some(idx) = named.iter().position(|(n, _)| n == "mixin") {
            (named.remove(idx).1, Vec::new())
        } else {
            return Err(Error::unpositioned("Missing argument $mixin."));
        };
        let rest_named: Vec<(String, Value)> = named.into_iter().filter(|(n, _)| n != "mixin").collect();
        let mixin = match mixin_val {
            Value::Mixin(m) => m,
            other => {
                return Err(Error::unpositioned(format!(
                    "$mixin: {} is not a mixin reference.",
                    other.to_css(false)
                )))
            }
        };
        self.invoke_mixin_ref(
            &mixin,
            rest_pos,
            rest_named,
            content,
            content_params,
            pos,
            length,
            parents,
            sink,
        )
    }

    /// Invoke a resolved mixin reference with already-evaluated arguments and an
    /// optional `@content` block, emitting into `sink`.
    #[allow(clippy::too_many_arguments)]
    fn invoke_mixin_ref(
        &mut self,
        mixin: &SassMixin,
        pos_args: Vec<Value>,
        named: Vec<(String, Value)>,
        content: Option<Rc<Vec<Stmt>>>,
        content_params: Option<Rc<ParamList>>,
        pos: Pos,
        length: usize,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // A captured user `@mixin`: recover the type-erased `Callable`.
        let callable = match &mixin.user {
            Some(any) => match Rc::clone(any).downcast::<UserCallable>() {
                Ok(c) => c,
                Err(_) => return Err(Error::unpositioned("Undefined mixin.")),
            },
            // A built-in mixin reference (`meta.load-css`/`meta.apply`): dart
            // invokes it like any other, so dispatch by name.
            None => {
                return match mixin.name.replace('_', "-").as_str() {
                    "load-css" => self.load_css_evaled(pos_args, named, content, pos, parents, sink),
                    "apply" => self.apply_evaled(
                        pos_args,
                        named,
                        content,
                        content_params,
                        pos,
                        length,
                        parents,
                        sink,
                    ),
                    _ => {
                        if content.is_some() {
                            return Err(Error::unpositioned("Mixin doesn't accept a content block."));
                        }
                        Err(Error::unpositioned("Undefined mixin."))
                    }
                };
            }
        };
        if content.is_some() && !body_uses_content(&callable.def.body) {
            // Raised BEFORE the mixin is entered, so its own frame is not on
            // the stack — dart shows only the caller's.
            return Err(self.error_with_declaration_at(
                "Mixin doesn't accept a content block.",
                pos,
                length,
                &declared(&callable),
            ));
        }
        let content_block = content.map(|stmts| {
            let snapshot = self.snapshot_env();
            ContentBlock {
                stmts,
                params: content_params.clone(),
                caller_env: Some(Box::new(snapshot)),
                origin: Some(self.current_mixin_origin()),
            }
        });
        // A mixin captured from another module runs in that module's
        // environment; either way the body runs in its lexical closure and
        // the `@content` block runs back at the call site.
        let module = mixin
            .module
            .as_ref()
            .and_then(|m| Rc::clone(m).downcast::<Module>().ok());
        let saved = module.as_ref().map(|m| self.enter_module(m));
        // Frames inside the body name the mixin itself (`m()`), not the
        // `meta.apply` that invoked it.
        let saved_member_name = std::mem::replace(&mut self.member, format!("{}()", callable.def.name));
        // The body runs against the mixin's defining file (so its output and
        // diagnostics belong there, and a relative `meta.load-css` resolves
        // against it): the callable's own capture, which every callable has.
        let saved_file = self.enter_origin_file(Some(&callable.origin));
        let saved_scopes = std::mem::replace(&mut self.scopes, callable.env.clone());
        let saved_var_spans = std::mem::replace(&mut self.var_spans, callable.env_spans.clone());
        let saved_semi = std::mem::replace(&mut self.scope_semi_global, callable.env_semi.clone());
        let saved_fns = std::mem::replace(&mut self.functions, callable.env_fns.clone());
        let saved_mixins = std::mem::replace(&mut self.mixins, callable.env_mixins.clone());
        let saved_env_modules = self.install_env_modules(&callable.env_modules);
        self.push_scope(false);
        // A first-class mixin reference arrives here with already-evaluated,
        // RESHUFFLED arguments (`meta.apply` strips `$mixin` off the front), so
        // the caller's per-argument spans no longer line up positionally. Bind
        // with no spans: the parameters get the "unknown" span and emit no
        // mapping segment, rather than a plausible-but-wrong one.
        let result = self
            .bind_evaled_into_scope(
                &callable.def.params,
                (pos_args, named, ListSep::Comma),
                &ArgSpans::default(),
                &declared(&callable),
            )
            .and_then(|()| {
                self.content_stack.push(content_block);
                self.in_mixin.push(true);
                let r = self.exec(&callable.def.body, parents, sink);
                self.in_mixin.pop();
                self.content_stack.pop();
                r
            })
            .map_err(|e| self.finalize_error(e));
        self.pop_scope();
        self.scopes = saved_scopes;
        self.var_spans = saved_var_spans;
        self.scope_semi_global = saved_semi;
        self.functions = saved_fns;
        self.mixins = saved_mixins;
        self.restore_env_modules(saved_env_modules);
        self.leave_module_file(saved_file);
        self.member = saved_member_name;
        if let Some(saved) = saved {
            self.leave_module(saved);
        }
        result
    }

    /// Run the innermost active `@content` block. For a cross-module include the
    /// block carries a snapshot of the call-site environment, which is installed
    /// for the duration so the content resolves there rather than in the mixin's
    /// module.
    pub(super) fn exec_content(
        &mut self,
        args: &[CallArg],
        pos: Pos,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        let (stmts, params, caller_env, origin) = match self.content_stack.last() {
            Some(Some(block)) => (
                Rc::clone(&block.stmts),
                block.params.clone(),
                block.caller_env.as_ref().map(|e| (**e).clone()),
                block.origin.clone(),
            ),
            _ => return Ok(()),
        };
        // `@content(args)` evaluates its arguments at the call site (the mixin
        // body); they are bound to the block's `using (params)` below, once the
        // block's own environment is in place, so a parameter DEFAULT evaluates
        // where the block was written (dart: a content block is a callable
        // closing over its `@include`; `using ($y: $caller)` sees the
        // includer's `$caller`, not the mixin module's variables).
        let evaled = match &params {
            Some(_) => Some(self.eval_call_args_spanned(args)?),
            None => {
                // A content block with no `using (params)` accepts no
                // arguments; passing any is an error (dart-sass).
                if !args.is_empty() {
                    let n = args.len();
                    let verb = if n == 1 { "was" } else { "were" };
                    return Err(Error::unpositioned(format!(
                        "Only 0 arguments allowed, but {n} {verb} passed."
                    )));
                }
                None
            }
        };
        // dart's trace: the `@content;` statement is a call site in the mixin
        // body (a frame in the mixin's file, attributed to the mixin), and the
        // block's own statements belong to the `@content` member, back in the
        // file that wrote the block — where its output maps to as well.
        let saved_member = self.enter_content_call(pos);
        let saved_file = self.enter_origin_file(origin.as_ref());
        let restore = caller_env.map(|env| self.install_env(env));
        // A content block is a user-defined callable in dart: its body always
        // runs in a fresh child scope, so a `$var:` first declared inside it
        // stays local to the block (and the `using` parameters bind there).
        self.push_scope(false);
        // The block runs in its DEFINITION environment's content context: a
        // `@content` inside it forwards to the block one level up, not to
        // itself (a recursive mixin chaining `@content` must terminate).
        let running = self.content_stack.pop();
        let result = match (&params, evaled) {
            (Some(p), Some((evaled, spans))) => self.bind_evaled_into_scope(
                p,
                evaled,
                &spans,
                // A `using (…)` clause has no `name(params)` declaration to
                // point back at; dart reports these against the call alone.
                &Declared {
                    pos: Pos::NONE,
                    length: 0,
                    origin: None,
                },
            ),
            _ => Ok(()),
        }
        .and_then(|()| self.exec(&stmts, parents, sink))
        .map_err(|e| self.finalize_error(e));
        if let Some(top) = running {
            self.content_stack.push(top);
        }
        self.pop_scope();
        if let Some(restore) = restore {
            self.leave_module(restore);
        }
        self.leave_module_file(saved_file);
        self.leave_call(saved_member);
        result
    }

    /// The lazy `if($condition, $if-true, $if-false)` function: evaluates
    /// the condition, then only the selected branch.
    pub(super) fn eval_if_function(&mut self, args: &[CallArg], pos: Pos) -> Result<Value, Error> {
        // An argument is lazy (an unevaluated branch expression) unless it
        // came from a `...` splat: dart's macro-argument handling evaluates
        // the splat eagerly and reconstitutes its elements (and an argument
        // list's keywords) as already-evaluated arguments.
        enum IfArg<'a> {
            Lazy(&'a Expr),
            Eager(Value),
        }
        fn slot_index(name: &str) -> Option<usize> {
            match name {
                "condition" => Some(0),
                "if-true" => Some(1),
                "if-false" => Some(2),
                _ => None,
            }
        }
        let mut by_pos: Vec<IfArg<'_>> = Vec::new();
        // $condition / $if-true / $if-false by name.
        let mut named: [Option<IfArg<'_>>; 3] = [None, None, None];
        for a in args {
            if a.splat {
                match self.eval_expr(&a.value)? {
                    Value::List(l) => {
                        if let Some(kw) = &l.keywords {
                            for (k, v) in kw {
                                if let Value::Str(s) = k {
                                    match slot_index(&s.text) {
                                        Some(i) => named[i] = Some(IfArg::Eager(v.clone())),
                                        None => {
                                            return Err(Error::at(
                                                format!("if() has no argument named ${}.", s.text),
                                                pos,
                                            ))
                                        }
                                    }
                                }
                            }
                        }
                        for item in l.items.iter().cloned() {
                            by_pos.push(IfArg::Eager(item));
                        }
                    }
                    Value::Map(m) => {
                        for (k, v) in m.entries.as_ref().clone() {
                            let name = match k {
                                Value::Str(s) => s.text,
                                other => {
                                    return Err(Error::at(
                                        format!(
                                            "Variable keyword argument map must have string keys.\n{} is not a string.",
                                            other.to_css(false)
                                        ),
                                        pos,
                                    ))
                                }
                            };
                            match slot_index(&name) {
                                Some(i) => named[i] = Some(IfArg::Eager(v)),
                                None => {
                                    return Err(Error::at(
                                        format!("if() has no argument named ${name}."),
                                        pos,
                                    ))
                                }
                            }
                        }
                    }
                    other => by_pos.push(IfArg::Eager(other)),
                }
                continue;
            }
            match a.name.as_deref() {
                Some(name) => match slot_index(name) {
                    Some(i) => named[i] = Some(IfArg::Lazy(&a.value)),
                    None => {
                        return Err(Error::at(format!("if() has no argument named ${name}."), pos));
                    }
                },
                None => by_pos.push(IfArg::Lazy(&a.value)),
            }
        }
        let [cond, t_val, f_val] = named;
        let mut pos_iter = by_pos.into_iter();
        let cond = cond.or_else(|| pos_iter.next());
        let t_val = t_val.or_else(|| pos_iter.next());
        let f_val = f_val.or_else(|| pos_iter.next());
        match (cond, t_val, f_val) {
            (Some(c), Some(t), Some(f)) => {
                let truthy = match c {
                    IfArg::Lazy(e) => self.eval_expr(e)?.is_truthy(),
                    IfArg::Eager(v) => v.is_truthy(),
                };
                // if() is a function boundary: a bare slash-division branch
                // collapses to its number (dart-sass `withoutSlash`).
                let branch = if truthy { t } else { f };
                match branch {
                    IfArg::Lazy(e) => Ok(self.eval_expr(e)?.without_slash()),
                    IfArg::Eager(v) => Ok(v.without_slash()),
                }
            }
            _ => Err(Error::at(
                "if() requires arguments $condition, $if-true, $if-false.",
                pos,
            )),
        }
    }

    /// Evaluate a modern CSS `if()`: a `;`-separated list of clauses, each
    /// `<condition>: <value>` (or `else: <value>`). Conditions mix evaluated
    /// `sass(<expr>)` with non-evaluable `css(...)` / arbitrary substitution
    /// pieces. If every reachable condition resolves statically, the matching
    /// value is returned; otherwise the whole `if()` is re-serialized
    /// verbatim (with statically-true/false conditions folded away) as an
    /// unquoted string.
    pub(super) fn eval_modern_if(&mut self, clauses: &[IfClause]) -> Result<Value, Error> {
        let mut verbatim: Option<Vec<String>> = None;
        for clause in clauses {
            // The `else` clause has no condition: it always matches.
            let result = match &clause.condition {
                None => CondEval::Bool(true),
                Some(cond) => self.eval_if_cond(cond)?,
            };
            match (&mut verbatim, result) {
                // Not yet verbatim: a static-true (or `else`) clause wins.
                (None, CondEval::Bool(true)) => {
                    return Ok(self.eval_expr(&clause.value)?.without_slash());
                }
                // Not yet verbatim: a static-false clause is skipped.
                (None, CondEval::Bool(false)) => {}
                // First non-evaluable condition: enter verbatim mode.
                (None, CondEval::Css(rc)) => {
                    let value = self.eval_if_value(&clause.value)?;
                    verbatim = Some(vec![format!("{}: {}", rc.to_css(), value)]);
                }
                // Already verbatim: fold each remaining clause.
                (Some(out), CondEval::Bool(true)) => {
                    let value = self.eval_if_value(&clause.value)?;
                    out.push(format!("else: {value}"));
                }
                (Some(_), CondEval::Bool(false)) => {}
                (Some(out), CondEval::Css(rc)) => {
                    let value = self.eval_if_value(&clause.value)?;
                    out.push(format!("{}: {}", rc.to_css(), value));
                }
            }
        }
        match verbatim {
            Some(parts) => Ok(Value::Str(SassStr {
                text: format!("if({})", parts.join("; ")).into(),
                quoted: false,
            })),
            // No clause matched and no `else`: the modern `if()` is null.
            None => Ok(Value::Null),
        }
    }

    /// Evaluate an `if()` clause value. dart-sass emits it in plain CSS
    /// serialization format (since 1.101.4), not `meta.inspect()` format.
    fn eval_if_value(&mut self, expr: &Expr) -> Result<String, Error> {
        // No without_slash: dart serializes the clause value as-is, so a
        // preserved slash-division (`20/10`) keeps its slash form.
        let v = self.eval_expr(expr)?;
        serialize_if_value(&v)
    }

    /// Evaluate a modern `if()` condition into a tri-state result: a static
    /// boolean (from `sass(...)` atoms) or a residual non-evaluable CSS
    /// condition that must be re-serialized verbatim.
    fn eval_if_cond(&mut self, cond: &IfCond) -> Result<CondEval, Error> {
        match cond {
            IfCond::Sass(expr) => Ok(CondEval::Bool(self.eval_expr(expr)?.is_truthy())),
            IfCond::Raw { pieces, .. } => {
                let text = self.eval_template(pieces)?;
                // dart re-serializes the raw token run with collapsed
                // whitespace and no space inside empty parens
                // (`css(\n)` is `css()`).
                let mut collapsed = String::with_capacity(text.len());
                let mut prev_ws = false;
                for c in text.chars() {
                    if c.is_whitespace() {
                        prev_ws = true;
                        continue;
                    }
                    if prev_ws && !collapsed.is_empty() && c != ')' {
                        collapsed.push(' ');
                    }
                    prev_ws = false;
                    collapsed.push(c);
                }
                let collapsed = collapsed.replace("( ", "(");
                Ok(CondEval::Css(RCond::Css(collapsed)))
            }
            IfCond::Not(inner) => match self.eval_if_cond(inner)? {
                CondEval::Bool(b) => Ok(CondEval::Bool(!b)),
                CondEval::Css(rc) => Ok(CondEval::Css(RCond::Not(Box::new(rc)))),
            },
            IfCond::Paren(inner) => match self.eval_if_cond(inner)? {
                CondEval::Bool(b) => Ok(CondEval::Bool(b)),
                CondEval::Css(rc) => Ok(CondEval::Css(RCond::Paren(Box::new(rc)))),
            },
            IfCond::And(items) => {
                let mut residuals: Vec<RCond> = Vec::new();
                for item in items {
                    match self.eval_if_cond(item)? {
                        // A statically-false operand makes the whole `and`
                        // false and short-circuits the rest.
                        CondEval::Bool(false) => return Ok(CondEval::Bool(false)),
                        // A statically-true operand drops out of the `and`.
                        CondEval::Bool(true) => {}
                        CondEval::Css(rc) => residuals.push(rc),
                    }
                }
                Ok(combine_residuals(residuals, true))
            }
            IfCond::Or(items) => {
                let mut residuals: Vec<RCond> = Vec::new();
                for item in items {
                    match self.eval_if_cond(item)? {
                        // A statically-true operand makes the whole `or`
                        // true and short-circuits the rest.
                        CondEval::Bool(true) => return Ok(CondEval::Bool(true)),
                        // A statically-false operand drops out of the `or`.
                        CondEval::Bool(false) => {}
                        CondEval::Css(rc) => residuals.push(rc),
                    }
                }
                Ok(combine_residuals(residuals, false))
            }
        }
    }
}

/// The declaration description a bound callable carries: its `name(params)`
/// span, in the file it was written in.
pub(super) fn declared(callable: &Rc<UserCallable>) -> Declared<'_> {
    Declared {
        pos: callable.def.decl_pos,
        length: callable.def.decl_length,
        origin: Some(&callable.origin),
    }
}
