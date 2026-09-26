use super::*;

impl<'a> Evaluator<'a> {
    // ---- scopes ------------------------------------------------------

    pub(super) fn lookup(&self, name: &str) -> Option<Value> {
        for scope in self.scopes.iter().rev() {
            if let Some(v) = scope.borrow().get(name) {
                return Some(v.clone());
            }
        }
        None
    }

    /// The DEFINITION span of `name`, innermost frame first — dart
    /// `Environment.getVariableNode` (environment.dart:488). Walks the same
    /// chain as [`Self::lookup`], falling back to the `@use … as *` modules the
    /// value lookup would have reached. Source-map only.
    pub(super) fn lookup_var_span(&self, name: &str) -> Option<VarSpan> {
        for frame in self.var_spans.iter().rev() {
            if let Some(sp) = frame.borrow().get(name) {
                return Some(*sp);
            }
        }
        // A name resolved through `@use … as *` lives in the module's own
        // frame; mirror `eval_expr`'s fallback order so the span matches the
        // value that was actually read.
        if !is_private_member(name) {
            for m in &self.star_user_modules {
                if m.vars.borrow().contains_key(name) {
                    return m.var_spans.borrow().get(name).copied();
                }
            }
        }
        None
    }

    /// dart `_expressionNode` (evaluate.dart:4538): the node whose span should
    /// be blamed for `expr`'s value. A bare variable reference resolves to
    /// wherever that variable was DEFINED (transitively — `$b: $a` stored `$a`'s
    /// own definition node, so `$b` reaches the original literal); every other
    /// expression shape is its own node, which is `fallback` (the position where
    /// `expr`'s text starts in the current file).
    ///
    /// Note the asymmetry this bakes in, and which dart's boundary confirms:
    /// only a BARE `$x` resolves. `$x * 2`, `f($x)`, `#{$x}` and `$x $x` are
    /// `Binary`/`Func`/`Interp`/`List` nodes, so they keep their own span.
    pub(super) fn expression_node(&mut self, expr: &Expr, fallback: Pos) -> VarSpan {
        if !self.options.source_map {
            return VarSpan::default();
        }
        let resolved = match expr {
            Expr::Var { name, .. } => self.lookup_var_span(name),
            Expr::NsVar { module, name, .. } => self.module_var_span(module, name),
            _ => None,
        };
        match resolved {
            Some(sp) => sp,
            None => self.span_at(fallback),
        }
    }

    /// The definition span of a `ns.$name` module variable, following a
    /// `@forward` to the module that actually defines it (dart
    /// `_getVariableNodeFromGlobalModule` / `Module.variableNodes`).
    fn module_var_span(&self, ns: &str, name: &str) -> Option<VarSpan> {
        let module = self.used_user_modules.get(ns)?;
        let (target, orig) = module
            .var_origin(name)
            .unwrap_or_else(|| (Rc::clone(module), name.to_string()));
        let sp = target.var_spans.borrow().get(&orig).copied();
        sp
    }

    /// Turn a 1-based source position in the CURRENT file into a [`VarSpan`]
    /// (interned file id + 0-based line/col). [`Pos::NONE`] yields the "unknown"
    /// span, which the source map drops.
    pub(super) fn span_at(&mut self, pos: Pos) -> VarSpan {
        if !self.options.source_map || !pos.is_known() {
            return VarSpan::default();
        }
        VarSpan {
            file: self.intern_current_file(),
            line: pos.line as u32 - 1,
            col: pos.col as u32 - 1,
        }
    }

    /// Capture the current variable and function/mixin scope chains as a
    /// callable's lexical closure (dart `Environment.closure()` — shared
    /// frames, not snapshots).
    pub(super) fn capture_callable(&mut self, def: &Rc<Callable>) -> Rc<UserCallable> {
        let env_modules = EnvModules {
            used_modules: self.used_modules.clone(),
            star_modules: self.star_modules.clone(),
            used_user_modules: self.used_user_modules.clone(),
            star_user_modules: self.star_user_modules.clone(),
        };
        self.capture_callable_from(def, self.current_mixin_origin(), env_modules)
    }

    /// Rebind an existing callable's variable/function/mixin scopes to the
    /// current environment while keeping what belongs to its DEFINITION: the
    /// file it was written in and the `@use` namespaces it closed over. A
    /// member `@forward`ed through a textual `@import` becomes a member of the
    /// importing scope (dart's import is textual inclusion), but its body
    /// still maps to and diagnoses against the file that wrote it, and still
    /// resolves `math.div` through THAT file's `@use "sass:math"`.
    pub(super) fn recapture_callable(&mut self, src: &UserCallable) -> Rc<UserCallable> {
        self.capture_callable_from(&src.def, src.origin.clone(), src.env_modules.clone())
    }

    fn capture_callable_from(
        &mut self,
        def: &Rc<Callable>,
        origin: crate::value::MixinOrigin,
        env_modules: EnvModules,
    ) -> Rc<UserCallable> {
        // The closure must SHARE the frames it captures, so every frame it
        // takes has to exist by the time it is cloned.
        materialize_fn_frames(&mut self.functions);
        materialize_fn_frames(&mut self.mixins);
        Rc::new(UserCallable {
            def: Rc::clone(def),
            origin,
            env: self.scopes.clone(),
            env_spans: self.var_spans.clone(),
            env_semi: self.scope_semi_global.clone(),
            env_fns: self.functions.clone(),
            env_mixins: self.mixins.clone(),
            env_modules,
        })
    }

    /// Install a callable's captured `@use` namespace tables for the duration
    /// of its body, returning the caller's tables for [`Self::restore_env_modules`].
    pub(super) fn install_env_modules(&mut self, m: &EnvModules) -> EnvModules {
        EnvModules {
            used_modules: std::mem::replace(&mut self.used_modules, m.used_modules.clone()),
            star_modules: std::mem::replace(&mut self.star_modules, m.star_modules.clone()),
            used_user_modules: std::mem::replace(&mut self.used_user_modules, m.used_user_modules.clone()),
            star_user_modules: std::mem::replace(&mut self.star_user_modules, m.star_user_modules.clone()),
        }
    }

    pub(super) fn restore_env_modules(&mut self, saved: EnvModules) {
        self.used_modules = saved.used_modules;
        self.star_modules = saved.star_modules;
        self.used_user_modules = saved.used_user_modules;
        self.star_user_modules = saved.star_user_modules;
    }

    /// Push a new scope. `semi_global` requests semi-global behavior (control
    /// flow), which only takes effect when the current innermost scope is
    /// already semi-global (dart-sass `Environment.scope`). The function and
    /// mixin chains push in lockstep with the variable chain.
    pub(super) fn push_scope(&mut self, semi_global: bool) {
        let effective = semi_global && self.scope_semi_global.last().copied().unwrap_or(false);
        // A table left behind by a block that has already closed, if there is
        // one: a sheet's blocks come and go in strict LIFO order, and a scope
        // nothing captured is indistinguishable from a fresh one once cleared.
        let scope = self.scope_pool.pop().unwrap_or_else(new_scope);
        self.scopes.push(scope);
        if self.options.source_map {
            let frame = self.span_pool.pop().unwrap_or_else(new_span_scope);
            self.var_spans.push(frame);
        }
        self.scope_semi_global.push(effective);
        // Empty frames: the block gets a table only if it declares something
        // (or a closure captures the chain). See [`FnFrame`].
        self.functions.push(None);
        self.mixins.push(None);
    }

    pub(super) fn pop_scope(&mut self) {
        if let Some(scope) = self.scopes.pop() {
            recycle_scope(&mut self.scope_pool, scope);
        }
        if let Some(frame) = self.var_spans.pop() {
            recycle_scope(&mut self.span_pool, frame);
        }
        self.scope_semi_global.pop();
        self.functions.pop();
        self.mixins.pop();
    }

    /// Define a user `@function` in the innermost frame (dart
    /// `visitFunctionRule`: always `_functions.length - 1`, no semi-global
    /// special case), so the definition is scoped to the enclosing block.
    /// Keys are dash-normalized like dart's parse-time `identifier(normalize:
    /// true)` — `@function a_b` and `@function a-b` define the SAME name (the
    /// AST keeps the original spelling for plain-CSS fallback and messages).
    pub(super) fn define_function(&mut self, name: &str, c: Rc<UserCallable>) {
        if let Some(frame) = self.functions.last_mut() {
            frame
                .get_or_insert_with(new_fn_scope)
                .borrow_mut()
                .insert(normalize_arg_name(name).into_owned(), c);
        }
    }

    /// Define a user `@mixin` in the innermost frame (dart `visitMixinRule`).
    pub(super) fn define_mixin(&mut self, name: &str, c: Rc<UserCallable>) {
        if let Some(frame) = self.mixins.last_mut() {
            frame
                .get_or_insert_with(new_fn_scope)
                .borrow_mut()
                .insert(normalize_arg_name(name).into_owned(), c);
        }
    }

    /// Look up a user `@function` (dash/underscore-insensitively, like dart),
    /// innermost frame first.
    pub(super) fn lookup_function(&self, name: &str) -> Option<Rc<UserCallable>> {
        let key = normalize_arg_name(name);
        for frame in self.functions.iter().rev().flatten() {
            if let Some(f) = frame.borrow().get(key.as_ref()) {
                return Some(Rc::clone(f));
            }
        }
        None
    }

    /// Look up a user `@mixin` (dash/underscore-insensitively), innermost
    /// frame first.
    pub(super) fn lookup_mixin(&self, name: &str) -> Option<Rc<UserCallable>> {
        let key = normalize_arg_name(name);
        for frame in self.mixins.iter().rev().flatten() {
            if let Some(m) = frame.borrow().get(key.as_ref()) {
                return Some(Rc::clone(m));
            }
        }
        None
    }

    /// Look up a user `@function` dash/underscore-insensitively (for the
    /// `meta` introspection functions), innermost frame first.
    pub(super) fn lookup_function_norm(&self, key: &str) -> Option<Rc<UserCallable>> {
        for frame in self.functions.iter().rev().flatten() {
            let frame = frame.borrow();
            if let Some((_, f)) = frame.iter().find(|(k, _)| normalize_arg_name(k) == key) {
                return Some(Rc::clone(f));
            }
        }
        None
    }

    /// Look up a user `@mixin` dash/underscore-insensitively, innermost first.
    pub(super) fn lookup_mixin_norm(&self, key: &str) -> Option<Rc<UserCallable>> {
        for frame in self.mixins.iter().rev().flatten() {
            let frame = frame.borrow();
            if let Some((_, m)) = frame.iter().find(|(k, _)| normalize_arg_name(k) == key) {
                return Some(Rc::clone(m));
            }
        }
        None
    }

    /// Assign a non-global variable (dart-sass `Environment.setVariable`). The
    /// value updates the variable at the innermost scope where it already
    /// exists; if it exists only in the global scope and the current scope is
    /// not semi-global, a new local is created instead so a nested rule cannot
    /// silently rewrite a global.
    pub(super) fn assign(&mut self, name: &str, val: Value, span: VarSpan) {
        if self.scopes.len() == 1 {
            if let Some(g) = self.scopes.first_mut() {
                g.borrow_mut().insert(name.to_string(), val);
            }
            if let Some(g) = self.var_spans.first_mut() {
                g.borrow_mut().insert(name.to_string(), span);
            }
            return;
        }
        // Innermost scope index holding the variable (None if undeclared).
        let mut index = None;
        for (i, scope) in self.scopes.iter().enumerate().rev() {
            if scope.borrow().contains_key(name) {
                index = Some(i);
                break;
            }
        }
        let in_semi_global = self.scope_semi_global.last().copied().unwrap_or(false);
        let target = match index {
            Some(0) if !in_semi_global => self.scopes.len() - 1,
            Some(i) => i,
            None => self.scopes.len() - 1,
        };
        if let Some(scope) = self.scopes.get_mut(target) {
            scope.borrow_mut().insert(name.to_string(), val);
        }
        // The span frame is the same index in the parallel chain (dart writes
        // `_variables[index]` and `_variableNodes[index]` together).
        if let Some(frame) = self.var_spans.get_mut(target) {
            frame.borrow_mut().insert(name.to_string(), span);
        }
    }

    pub(super) fn apply_var(&mut self, v: &VarDecl) -> Result<(), Error> {
        // A namespaced assignment `ns.$name: value` updates the variable in the
        // `@use`d module bound to `ns`.
        if let Some(ns) = &v.namespace {
            return self.assign_module_var(ns, v);
        }
        // A top-level `!default` declaration whose name is exposed by more than
        // one `@use … as *` module can't resolve which global it shadows.
        if v.is_default
            && self.scopes.len() == 1
            && self.lookup(&v.name).is_none()
            && !is_private_member(&v.name)
            && self
                .star_user_modules
                .iter()
                .filter(|m| m.var(&v.name).is_some())
                .count()
                > 1
        {
            return Err(Error::unpositioned(
                "This variable is available from multiple global modules.",
            ));
        }
        // A top-level `!default` variable in a module being evaluated with
        // configuration: the supplied value overrides the default (unless the
        // override itself is `!default` and the variable already has a value).
        // Configuration is keyed by the canonical (dashed) variable name.
        if v.is_default && self.scopes.len() == 1 {
            let key = normalize_var_name(&v.name);
            if let Some((cfg_val, cfg_is_default)) = self.pending_config.get(key.as_ref()).cloned() {
                self.consumed_config.push(key.into_owned());
                let already_set = matches!(self.lookup(&v.name), Some(x) if !matches!(x, Value::Null));
                // A `null` configuration value leaves the `!default` in place;
                // a `@forward ... with ($x !default)` only applies if the module
                // hasn't already defined the variable.
                if !(matches!(cfg_val, Value::Null) || cfg_is_default && already_set) {
                    if let Some(g) = self.scopes.first_mut() {
                        g.borrow_mut().insert(v.name.clone(), cfg_val);
                    }
                    // dart blames `override.assignmentNode` here — the span of
                    // the value inside the `@use … with (...)` clause, which
                    // lives in the CONFIGURING file (evaluate.dart:2679). sasso
                    // does not yet carry configuration spans across that
                    // boundary, so record "unknown" rather than the `!default`
                    // text we are overriding: an unknown span emits no mapping
                    // segment, whereas a wrong one would emit a wrong segment.
                    if let Some(g) = self.var_spans.first_mut() {
                        g.borrow_mut().insert(v.name.clone(), VarSpan::default());
                    }
                    return Ok(());
                }
            }
        }
        // A `!default` assignment whose target already holds a non-null value
        // is a no-op — and crucially, the right-hand side must NOT be evaluated
        // (dart-sass short-circuits a guarded declaration before evaluating its
        // expression). Evaluating it would surface errors from an expression
        // that is never actually used, e.g. Bootstrap's
        // `$x: 1rem + .5em !default` after `$x` was already set to a `rem`.
        if v.is_default {
            if let Some(existing) = self.lookup(&v.name) {
                if !matches!(existing, Value::Null) {
                    return Ok(());
                }
            }
            // Same guard for a name owned by exactly one `@use … as *` module.
            if (self.scopes.len() == 1 || v.is_global) && !is_private_member(&v.name) {
                if let Some(g) = self.scopes.first() {
                    if !g.borrow().contains_key(&v.name) {
                        let mut targets = self.star_user_modules.iter().filter_map(|m| m.var(&v.name));
                        if let Some(existing) = targets.next() {
                            if targets.next().is_none() && !matches!(existing, Value::Null) {
                                return Ok(());
                            }
                        }
                    }
                }
            }
        }
        let val = self.eval_expr(&v.value)?;
        // dart `visitVariableDeclaration` stores `_expressionNode(node
        // .expression)` as the binding's node (evaluate.dart:2721): a bare
        // `$a: $b` inherits `$b`'s ORIGIN, so a chain `$a: red; $b: $a; c: $b`
        // maps `c`'s value all the way back to `red`. Computed AFTER the RHS is
        // evaluated so `$x: $x` still sees the outgoing binding, matching dart's
        // evaluation order.
        let span = self.expression_node(&v.value, v.value_pos);
        // A top-level (or nested `!global`) assignment to a name not in the
        // global scope but exposed by exactly one `@use … as *` module updates
        // that module's variable (so the module's own functions/mixins observe
        // the change).
        if (self.scopes.len() == 1 || v.is_global) && !is_private_member(&v.name) {
            if let Some(g) = self.scopes.first() {
                if !g.borrow().contains_key(&v.name) {
                    let targets: Vec<Rc<Module>> = self
                        .star_user_modules
                        .iter()
                        .filter(|m| m.var(&v.name).is_some())
                        .cloned()
                        .collect();
                    if targets.len() == 1 {
                        targets[0].vars.borrow_mut().insert(v.name.clone(), val);
                        if self.options.source_map {
                            targets[0].var_spans.borrow_mut().insert(v.name.clone(), span);
                        }
                        return Ok(());
                    }
                }
            }
        }
        if v.is_global {
            if let Some(g) = self.scopes.first_mut() {
                g.borrow_mut().insert(v.name.clone(), val);
            }
            if let Some(g) = self.var_spans.first_mut() {
                g.borrow_mut().insert(v.name.clone(), span);
            }
        } else {
            self.assign(&v.name, val, span);
        }
        Ok(())
    }

    /// Assign to a `@use`d module's variable (`ns.$name: value`). The variable
    /// must already exist in the module and be public; `!default` only assigns
    /// when the existing value is null; built-in modules are immutable.
    pub(super) fn assign_module_var(&mut self, ns: &str, v: &VarDecl) -> Result<(), Error> {
        if is_private_member(&v.name) {
            return Err(Error::unpositioned(
                "Private members can't be accessed from outside their modules.",
            ));
        }
        let module = match self.used_user_modules.get(ns).cloned() {
            Some(m) => m,
            None => {
                if self.used_modules.contains_key(ns) {
                    return Err(Error::unpositioned("Cannot modify built-in variable."));
                }
                return Err(Error::unpositioned(format!(
                    "There is no module with the namespace \"{ns}\"."
                )));
            }
        };
        // A forwarded variable writes through to its defining module (under
        // its ORIGINAL name), so the module's own functions see the new value.
        let (target, name) = match module.var_write_origin(&v.name) {
            Some((m, o)) => (m, o),
            None => (Rc::clone(&module), v.name.clone()),
        };
        // One lookup feeds both the existence check and the `!default` guard
        // (`Module::var` clones the value, so don't call it twice).
        let existing = target.var(&name);
        if existing.is_none() {
            return Err(Error::unpositioned("Undefined variable."));
        }
        // Short-circuit a `!default` no-op before evaluating the RHS, so an
        // unused guarded expression can't raise an error (matches dart-sass).
        if v.is_default && existing.is_some_and(|x| !matches!(x, Value::Null)) {
            return Ok(());
        }
        let val = self.eval_expr(&v.value)?.without_slash();
        let span = self.expression_node(&v.value, v.value_pos);
        target.vars.borrow_mut().insert(name.clone(), val);
        if self.options.source_map {
            target.var_spans.borrow_mut().insert(name, span);
        }
        Ok(())
    }

    // ---- loop helpers ------------------------------------------------

    /// Set a variable in the innermost scope. A loop pushes its own scope, so a
    /// loop variable bound here lives in the loop's scope and is re-bound each
    /// iteration (dart-sass `setLocalVariable`).
    pub(super) fn set_local(&mut self, name: &str, val: Value, span: VarSpan) {
        if let Some(sc) = self.scopes.last_mut() {
            rebind(&mut sc.borrow_mut(), name, val);
        }
        if let Some(frame) = self.var_spans.last_mut() {
            rebind(&mut frame.borrow_mut(), name, span);
        }
    }
}

/// Bind `name` in an already-open scope, keeping the key that is already there.
///
/// A loop pushes ONE scope for all of its iterations and rebinds its variable
/// inside it, so from the second iteration on the entry exists and only its
/// value is new — `insert` would spell the name into a fresh `String` and throw
/// away the one the map is already holding.
fn rebind<T>(vars: &mut HashMap<String, T>, name: &str, val: T) {
    match vars.get_mut(name) {
        Some(slot) => *slot = val,
        None => {
            vars.insert(name.to_string(), val);
        }
    }
}
