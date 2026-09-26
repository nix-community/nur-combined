use super::*;

/// Resolve `member` against the built-in modules a user module re-exports with
/// `@forward "sass:…"`, returning the owning module and the member's bare name.
///
/// Both the member and the forward's prefix are read in their canonical
/// spelling first: `_` and `-` are one character in a Sass identifier, so
/// `@forward "sass:map" as p-*` answers to `p_get` and `as p_*` answers to
/// `p-get`. (The `show`/`hide` sets are canonicalized when the forward is
/// recorded, so `visible` is asked with the canonical bare name.)
pub(super) fn resolve_forwarded_builtin(module: &Module, member: &str) -> Option<(String, String)> {
    resolve_forwarded(module, member, ForwardKind::Name, |m, b| {
        crate::builtins::module_has_member(m, b)
    })
}

/// The same, for a `$variable` a `@forward "sass:…"` re-exports (`$pi` from
/// `sass:math`).
pub(super) fn resolve_forwarded_builtin_var(module: &Module, member: &str) -> Option<(String, String)> {
    resolve_forwarded(module, member, ForwardKind::Var, |m, b| {
        crate::builtins::module_var(m, b, Pos::NONE).is_ok()
    })
}

/// The same, for a built-in mixin (`load-css`/`apply` from `sass:meta`).
pub(super) fn resolve_forwarded_builtin_mixin(module: &Module, member: &str) -> Option<(String, String)> {
    resolve_forwarded(module, member, ForwardKind::Name, is_builtin_mixin)
}

fn resolve_forwarded(
    module: &Module,
    member: &str,
    kind: ForwardKind,
    owns: impl Fn(&str, &str) -> bool,
) -> Option<(String, String)> {
    let member = member.replace('_', "-");
    for fb in &module.forwarded_builtins {
        let Some(bare) = member.strip_prefix(fb.prefix()) else {
            continue;
        };
        if fb.visible(bare, kind) && owns(&fb.module, bare) {
            return Some((fb.module.clone(), bare.to_string()));
        }
    }
    None
}

impl<'a> Evaluator<'a> {
    /// Dispatch a namespaced call `ns.member(args)`. Resolves a user module
    /// first, then a built-in module bound to `ns`.
    pub(super) fn eval_module_call(
        &mut self,
        ns: &str,
        member: &str,
        args: &[CallArg],
        pos: Pos,
        length: usize,
    ) -> Result<Value, Error> {
        // A user module bound to this namespace.
        if let Some(module) = self.used_user_modules.get(ns).cloned() {
            if is_private_member(member) {
                // Not part of the module's public view: dart reports it missing
                // (a literal `ns.-name` is the parser's privacy error instead).
                return Err(Error::at("Undefined function.".to_string(), pos).with_length(length));
            }
            if let Some(func) = module.function(member) {
                // A forwarded function executes in its DEFINING module's
                // environment (its body closes over that module's globals).
                let exec = module.fn_origin(member).unwrap_or(module);
                return self.call_user_module_function(&exec, &func, args, Some((pos, length)));
            }
            // Fall back to a built-in re-exported by this module via @forward.
            // Its errors report against the call, like a direct built-in's.
            match self.try_forwarded_builtin_call(&module, member, args, pos, length) {
                Ok(Some(v)) => return Ok(v),
                Ok(None) => {}
                Err(e) => return Err(e.with_length_at(pos, length)),
            }
            return Err(Error::at("Undefined function.".to_string(), pos).with_length(length));
        }
        // A built-in module bound to this namespace.
        let module = match self.used_modules.get(ns) {
            Some(m) => *m,
            None => {
                return Err(
                    Error::at(format!("There is no module with the namespace \"{ns}\"."), pos)
                        .with_length(length),
                );
            }
        };
        // `call_module` canonicalizes the member (`_` and `-` are one
        // character in a Sass identifier); so must every lookup here, or
        // `meta.feature_exists(…)` reaches the dispatcher unannounced and
        // `meta.get_function(…)` never reaches the evaluator at all.
        let canonical = if member.contains('_') {
            Cow::Owned(member.replace('_', "-"))
        } else {
            Cow::Borrowed(member)
        };
        let member = canonical.as_ref();
        let (mut pos_args, mut named, _) = self.eval_call_args(args)?;
        // Reported AFTER the arguments, so a deprecated call inside one warns
        // first, as dart's does — and against the module's REAL name, which is
        // not the namespace it was bound to (`@use "sass:meta" as m`).
        self.emit_call_deprecations(member, Some(module), pos, length);
        for v in &mut pos_args {
            *v = std::mem::replace(v, Value::Null).without_slash();
        }
        for (_, v) in &mut named {
            *v = std::mem::replace(v, Value::Null).without_slash();
        }
        // The `sass:meta` introspection predicates need the evaluator's scopes /
        // definitions, which the value-only `call_module` cannot see.
        if module == "meta" {
            if let Some(r) = self.try_meta_eval_call(member, &pos_args, &named, pos, length) {
                return r;
            }
        }
        // Call results are slash-free (dart `withoutSlash()` on every call).
        let v = crate::builtins::call_module(module, member, &pos_args, &named, pos)
            .map_err(|e| e.with_length_at(pos, length))?;
        self.emit_color_function_deprecation(member, Some(module), pos, length, &pos_args, &named);
        Ok(v.without_slash())
    }

    /// Handle a `sass:meta` member that depends on the evaluator's state
    /// (variable/function/mixin/content existence). Returns `None` for any
    /// member this layer does not own, so the caller falls back to the
    /// value-only `call_module`. The arguments are already evaluated.
    pub(super) fn try_meta_eval_call(
        &mut self,
        member: &str,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
        length: usize,
    ) -> Option<Result<Value, Error>> {
        // Whatever these report, dart carets the CALL that reported it.
        let sized = |r: Result<Value, Error>| r.map_err(|e| e.with_length_at(pos, length));
        let out = match member {
            "variable-exists" => Some(self.meta_variable_exists(pos_args, named, pos, false)),
            "global-variable-exists" => Some(self.meta_variable_exists(pos_args, named, pos, true)),
            "mixin-exists" => Some(self.meta_mixin_exists(pos_args, named, pos)),
            "function-exists" => Some(self.meta_function_exists(pos_args, named, pos)),
            "content-exists" => Some(self.meta_content_exists(pos_args, pos)),
            "get-function" => Some(self.meta_get_function(pos_args, named, pos)),
            "get-mixin" => Some(self.meta_get_mixin(pos_args, named, pos)),
            "call" => Some(self.meta_call(pos_args, named, pos, length)),
            "module-variables" => Some(self.meta_module_members(pos_args, named, pos, MemberKind::Variable)),
            "module-functions" => Some(self.meta_module_members(pos_args, named, pos, MemberKind::Function)),
            "module-mixins" => Some(self.meta_module_members(pos_args, named, pos, MemberKind::Mixin)),
            "accepts-content" => Some(self.meta_accepts_content(pos_args, named, pos)),
            "keywords" => Some(Self::meta_keywords(pos_args, named, pos)),
            _ => None,
        };
        out.map(sized)
    }

    /// `meta.keywords($args)`: the keyword arguments captured by a `$args...`
    /// rest parameter, as a map from each name (hyphen-normalized, unquoted) to
    /// its value. The argument must be an argument list, not an ordinary value.
    fn meta_keywords(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
        let v = pos_args
            .first()
            .or_else(|| named.iter().find(|(n, _)| n == "args").map(|(_, v)| v))
            .ok_or_else(|| Error::at("Missing argument $args.".to_string(), pos))?;
        match v {
            Value::List(l) if l.keywords.is_some() => {
                Ok(Value::Map(Map::new(l.keywords.clone().unwrap_or_default())))
            }
            other => Err(Error::at(
                format!("$args: {} is not an argument list.", other.to_css(false)),
                pos,
            )),
        }
    }

    /// `meta.accepts-content($mixin)`: whether the mixin reference's body uses a
    /// `@content` block. The only built-in mixin that does is `meta.apply`.
    fn meta_accepts_content(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
    ) -> Result<Value, Error> {
        let v = pos_args
            .first()
            .or_else(|| named.iter().find(|(n, _)| n == "mixin").map(|(_, v)| v))
            .ok_or_else(|| Error::at("Missing argument $mixin.".to_string(), pos))?;
        let mixin = match v {
            Value::Mixin(m) => m,
            other => {
                return Err(Error::at(
                    format!("$mixin: {} is not a mixin reference.", other.to_css(false)),
                    pos,
                ))
            }
        };
        let accepts = match &mixin.user {
            Some(any) => Rc::clone(any)
                .downcast::<UserCallable>()
                .map(|c| body_uses_content(&c.def.body))
                .unwrap_or(false),
            None => mixin.name == "apply",
        };
        Ok(Value::Bool(accepts))
    }

    /// `meta.get-function($name, $css: false, $module: null)`: capture a
    /// reference to the named function. A `$module` argument needs the user
    /// module loader (unsupported here) and is reported as an error. A user
    /// `@function` is captured by identity; otherwise a built-in (or, with
    /// `$css: true`, a plain-CSS) reference is returned.
    fn meta_get_function(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
    ) -> Result<Value, Error> {
        let params = ["name", "css", "module"];
        crate::builtins::check_arity(params.len(), pos_args, named, pos)?;
        let arg = |i: usize| -> Option<&Value> {
            pos_args
                .get(i)
                .or_else(|| named.iter().find(|(n, _)| n == params[i]).map(|(_, v)| v))
        };
        let name = match arg(0) {
            Some(Value::Str(s)) => s.text.to_string(),
            Some(other) => {
                return Err(Error::at(
                    format!("$name: {} is not a string.", other.to_css(false)),
                    pos,
                ))
            }
            None => return Err(Error::at("Missing argument $name.", pos)),
        };
        let css = matches!(arg(1), Some(v) if v.is_truthy());
        // A `$module` namespace resolves the function from that `@use`d module.
        if let Some(module_v) = arg(2) {
            match module_v {
                Value::Null => {}
                Value::Str(s) => return self.get_function_from_module(&name, &s.text, pos),
                other => {
                    return Err(Error::at(
                        format!("$module: {} is not a string.", other.to_css(false)),
                        pos,
                    ))
                }
            }
        }
        if css {
            return Ok(Value::Function(SassFunction {
                name,
                css: true,
                module: None,
                user: None,
            }));
        }
        match self.resolve_function_name(&name, pos)? {
            Some(f) => Ok(Value::Function(f)),
            None => Err(Error::at(
                format!("Function not found: {}", crate::value::serialize_quoted(&name)),
                pos,
            )),
        }
    }

    /// The function a bare NAME resolves to: a user `@function` first, then a
    /// member a `@use … as *` exposes (from a user module or a built-in one),
    /// then the global. `None` when nothing owns it — `get-function` reports
    /// that as an error, while `call("name")` lets the plain-CSS dispatcher
    /// have it.
    pub(super) fn resolve_function_name(&self, name: &str, pos: Pos) -> Result<Option<SassFunction>, Error> {
        let name = name.to_string();
        // A user `@function` of that name (dash/underscore-insensitive) wins.
        let key = normalize_arg_name(&name);
        if let Some(f) = self.lookup_function_norm(&key) {
            return Ok(Some(SassFunction {
                name,
                css: false,
                module: None,
                user: Some(f as Rc<dyn std::any::Any>),
            }));
        }
        // A function exposed unprefixed via `@use … as *` (or forwarded into one).
        if !is_private_member(&name) {
            // A built-in module's member exposed unprefixed the same way is
            // still that module's: dart keeps `get-function("get")` bound to
            // `map.get` after `@use "sass:map" as *`, not to the global alias.
            // Both kinds compete for the bare name, so one check covers them.
            let star_user: Vec<Rc<UserCallable>> = self
                .star_user_modules
                .iter()
                .filter_map(|m| m.function(&name))
                .collect();
            let star_builtin = self.star_builtin_hits(&name, MemberKind::Function);
            if star_user.len() + star_builtin.len() > 1 {
                return Err(Error::at(
                    "This function is available from multiple global modules.",
                    pos,
                ));
            }
            if let Some(f) = star_user.into_iter().next() {
                return Ok(Some(SassFunction {
                    name,
                    css: false,
                    module: None,
                    user: Some(f as Rc<dyn std::any::Any>),
                }));
            }
            if let Some((owner, bare)) = star_builtin.into_iter().next() {
                if let Some(module) = crate::value::BuiltinModule::from_name(&owner) {
                    return Ok(Some(SassFunction {
                        name: bare,
                        css: false,
                        module: Some(module),
                        user: None,
                    }));
                }
            }
        }
        // The canonical spelling is what a reference is stored under, as dart
        // stores it: `inspect(get-function("map_get"))` is
        // `get-function("map-get")`.
        let canonical = name.replace('_', "-");
        if crate::builtins::is_builtin(&canonical)
            || crate::builtins::EVAL_GLOBAL_NAMES.contains(&canonical.as_str())
        {
            return Ok(Some(SassFunction {
                name: canonical,
                css: false,
                module: None,
                user: None,
            }));
        }
        Ok(None)
    }

    /// `meta.get-mixin($name, $module: null)`: capture a reference to the named
    /// mixin. A user `@mixin` is captured by identity (so a later redefinition
    /// yields a distinct reference); the built-in `sass:meta` mixins
    /// (`load-css`, `apply`) are captured by name. A `$module` argument resolves
    /// the mixin from that `@use`d module's namespace.
    fn meta_get_mixin(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
    ) -> Result<Value, Error> {
        let params = ["name", "module"];
        crate::builtins::check_arity(params.len(), pos_args, named, pos)?;
        let arg = |i: usize| -> Option<&Value> {
            pos_args
                .get(i)
                .or_else(|| named.iter().find(|(n, _)| n == params[i]).map(|(_, v)| v))
        };
        let name = match arg(0) {
            Some(Value::Str(s)) => s.text.to_string(),
            Some(other) => {
                return Err(Error::at(
                    format!("$name: {} is not a string.", other.to_css(false)),
                    pos,
                ))
            }
            None => return Err(Error::at("Missing argument $name.", pos)),
        };
        // A `$module` argument resolves the mixin from another module's scope.
        if let Some(module_val) = arg(1) {
            if !matches!(module_val, Value::Null) {
                let module_name = match module_val {
                    Value::Str(s) => s.text.clone(),
                    other => {
                        return Err(Error::at(
                            format!("$module: {} is not a string.", other.to_css(false)),
                            pos,
                        ))
                    }
                };
                return self.get_mixin_from_module(&name, &module_name, pos);
            }
        }
        // A user `@mixin` of that name (dash/underscore-insensitive) wins.
        let key = normalize_arg_name(&name);
        if let Some(m) = self.lookup_mixin_norm(&key) {
            return Ok(Value::Mixin(Box::new(SassMixin {
                name,
                user: Some(m as Rc<dyn std::any::Any>),
                module: None,
                // Same-module capture: remember the defining file so a later
                // `meta.apply` from elsewhere resolves relative loads here.
            })));
        }
        // A mixin exposed unprefixed via `@use … as *`. Its body runs in the
        // owning module's environment, so capture that module too. A BUILT-IN
        // mixin exposed the same way (`load-css` from a starred `sass:meta`,
        // or from a starred module that forwards it) competes for the same bare
        // name, so one check covers both.
        let builtin_hits = self.star_builtin_hits(&name, MemberKind::Mixin);
        {
            let hits: Vec<&Rc<Module>> = if is_private_member(&name) {
                Vec::new()
            } else {
                self.star_user_modules
                    .iter()
                    .filter(|m| m.mixin(&name).is_some())
                    .collect()
            };
            if hits.len() + builtin_hits.len() > 1 {
                return Err(Error::at(
                    "This mixin is available from multiple global modules.",
                    pos,
                ));
            }
            if let Some(module) = hits.into_iter().next() {
                let m = module.mixin(&name).ok_or_else(|| {
                    Error::at(
                        format!("Mixin not found: {}", crate::value::serialize_quoted(&name)),
                        pos,
                    )
                })?;
                return Ok(Value::Mixin(Box::new(SassMixin {
                    name,
                    user: Some(Rc::clone(&m) as Rc<dyn std::any::Any>),
                    module: Some(Rc::clone(module) as Rc<dyn std::any::Any>),
                })));
            }
            if let Some((_, bare)) = builtin_hits.into_iter().next() {
                return Ok(Value::Mixin(Box::new(SassMixin {
                    name: bare,
                    user: None,
                    module: None,
                })));
            }
        }
        Err(Error::at(
            format!("Mixin not found: {}", crate::value::serialize_quoted(&name)),
            pos,
        ))
    }

    /// Resolve a `$module`-qualified mixin reference for `meta.get-mixin`. The
    /// namespace must name a currently-`@use`d module; a built-in module's
    /// mixins (`meta.load-css`, `meta.apply`) resolve by name.
    /// `meta.get-function($name, $module: ns)`: capture a function reference from
    /// the module bound to `ns` — a user `@function` by identity, or a built-in
    /// member by name.
    fn get_function_from_module(&self, name: &str, module_name: &str, pos: Pos) -> Result<Value, Error> {
        if let Some(module) = self.used_user_modules.get(module_name) {
            if is_private_member(name) {
                // A private member is not in the module's public view, so the
                // by-name lookup simply does not find it.
                return Err(Error::at(
                    format!("Function not found: {}", crate::value::serialize_quoted(name)),
                    pos,
                ));
            }
            if let Some(f) = module.function(name) {
                return Ok(Value::Function(SassFunction {
                    name: name.to_string(),
                    css: false,
                    module: None,
                    user: Some(Rc::clone(&f) as Rc<dyn std::any::Any>),
                }));
            }
            // A built-in this module re-exports with `@forward "sass:…"` is
            // reachable by reference exactly as it is by call, under the name
            // the forward gives it. The reference itself is the MEMBER's
            // (`@forward "sass:map" as p-*` answers to `p-get` and inspects as
            // `get-function("get")`).
            if let Some((owner, bare)) = resolve_forwarded_builtin(module, name) {
                if let Some(owner) = crate::value::BuiltinModule::from_name(&owner) {
                    return Ok(Value::Function(SassFunction {
                        name: bare,
                        css: false,
                        module: Some(owner),
                        user: None,
                    }));
                }
            }
            return Err(Error::at(
                format!("Function not found: {}", crate::value::serialize_quoted(name)),
                pos,
            ));
        }
        if let Some(builtin) = self.used_modules.get(module_name) {
            if crate::builtins::module_has_member(builtin, name) {
                // The reference keeps the MEMBER's name and remembers the
                // module it came from, so invoking it dispatches through that
                // module (`color.scale` is not the global `scale-color`, and
                // dart neither prints nor compares them as the same function).
                let module = crate::value::BuiltinModule::from_name(builtin);
                return Ok(Value::Function(SassFunction {
                    name: name.replace('_', "-"),
                    css: false,
                    module,
                    user: None,
                }));
            }
            return Err(Error::at(
                format!("Function not found: {}", crate::value::serialize_quoted(name)),
                pos,
            ));
        }
        Err(Error::at(
            format!("There is no module with the namespace \"{module_name}\"."),
            pos,
        ))
    }

    fn get_mixin_from_module(&self, name: &str, module_name: &str, pos: Pos) -> Result<Value, Error> {
        if let Some(module) = self.used_user_modules.get(module_name) {
            if is_private_member(name) {
                return Err(Error::at(
                    format!("Mixin not found: {}", crate::value::serialize_quoted(name)),
                    pos,
                ));
            }
            if let Some(m) = module.mixin(name) {
                return Ok(Value::Mixin(Box::new(SassMixin {
                    name: name.to_string(),
                    user: Some(Rc::clone(&m) as Rc<dyn std::any::Any>),
                    module: Some(Rc::clone(module) as Rc<dyn std::any::Any>),
                })));
            }
            // A built-in mixin this module re-exports is part of its public
            // API too (`@forward "sass:meta"` brings `load-css`/`apply`).
            if let Some((_, bare)) = resolve_forwarded_builtin_mixin(module, name) {
                return Ok(Value::Mixin(Box::new(SassMixin {
                    name: bare,
                    user: None,
                    module: None,
                })));
            }
            return Err(Error::at(
                format!("Mixin not found: {}", crate::value::serialize_quoted(name)),
                pos,
            ));
        }
        if let Some(builtin) = self.used_modules.get(module_name) {
            // The RESOLVED module, not the namespace it was bound to: `@use
            // "sass:meta" as m` makes `$module: "m"` the `meta` module.
            if is_builtin_mixin(builtin, name) {
                return Ok(Value::Mixin(Box::new(SassMixin {
                    // Canonical, as dart stores it: `get-mixin("load_css")`
                    // inspects as `get-mixin("load-css")` and compares equal
                    // to one taken under that spelling.
                    name: name.replace('_', "-"),
                    user: None,
                    module: None,
                })));
            }
            return Err(Error::at(
                format!("Mixin not found: {}", crate::value::serialize_quoted(name)),
                pos,
            ));
        }
        Err(Error::at(
            format!("There is no module with the namespace \"{module_name}\"."),
            pos,
        ))
    }

    /// `meta.call($function, $args...)`: invoke a function reference (or, when
    /// `$function` is a string, the named function). The trailing arguments were
    /// already splat-expanded by `eval_call_args`. `pos`/`length` span the
    /// `meta.call(...)` expression, the call site in dart's trace.
    fn meta_call(
        &mut self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
        length: usize,
    ) -> Result<Value, Error> {
        // `$function` is the first positional argument, or the named `$function`.
        let (func_val, rest_pos): (Value, Vec<Value>) = if let Some(first) = pos_args.first() {
            (first.clone(), pos_args[1..].to_vec())
        } else if let Some((_, v)) = named.iter().find(|(n, _)| n == "function") {
            (v.clone(), Vec::new())
        } else {
            return Err(Error::at("Missing argument $function.", pos));
        };
        // The remaining named args (excluding `$function`) are call keywords.
        let rest_named: Vec<(String, Value)> =
            named.iter().filter(|(n, _)| n != "function").cloned().collect();

        match func_val {
            // A first-class function reference.
            Value::Function(f) => self.invoke_function_ref(&f, rest_pos, rest_named, pos, length),
            // The deprecated string form: look up by name.
            Value::Str(s) => {
                self.emit_deprecation(
                    &crate::deprecation::Deprecation::call_string(&s.text),
                    pos,
                    length,
                );
                // The NAME resolves exactly as it would have if it were
                // written: a user `@function`, a member a `@use … as *`
                // exposes, then the global. An unknown one is left alone for
                // the plain-CSS dispatcher.
                let f = self.resolve_function_name(&s.text, pos)?.unwrap_or(SassFunction {
                    name: s.text.to_string(),
                    css: false,
                    module: None,
                    user: None,
                });
                self.invoke_function_ref(&f, rest_pos, rest_named, pos, length)
            }
            other => Err(Error::at(
                format!("$function: {} is not a function reference.", other.to_css(false)),
                pos,
            )),
        }
    }

    /// Invoke a resolved function reference with already-evaluated arguments.
    /// `pos`/`length` span the invoking expression (`meta.call(...)`), which
    /// is the call site in dart's trace and the caret of an `@error` raised in
    /// the body; a caller with no span passes a zero position.
    pub(super) fn invoke_function_ref(
        &mut self,
        f: &SassFunction,
        pos_args: Vec<Value>,
        named: Vec<(String, Value)>,
        pos: Pos,
        length: usize,
    ) -> Result<Value, Error> {
        // Reaching a built-in through a reference is still using it, and dart
        // reports that against the INVOCATION — as the GLOBAL it is only when
        // the reference was taken globally, which is why the module it came
        // from is remembered. (A reference with no position is an internal
        // invocation — the user-overridden `calc()` hook — which reports
        // nothing.)
        // A reference resolves to the same built-in, so it takes the same
        // plain-CSS path for a plain-CSS argument and deprecates as little:
        // `meta.call(meta.get-function("grayscale"), 1)` is the CSS filter and
        // dart says nothing. Fixing only the direct call left this one warning
        // (#122).
        let css_filter_ref =
            f.module.is_none() && crate::builtins::is_plain_css_filter_call(&f.name, &pos_args, &named);
        if f.user.is_none() && !f.css && pos.line > 0 && !css_filter_ref {
            self.emit_call_deprecations(&f.name, f.module.map(|m| m.name()), pos, length);
        }
        // A captured user `@function`: bind the evaluated args and run its
        // body in the callable's lexical closure. The payload is a
        // type-erased `Rc<UserCallable>` (cloning the `Rc` releases the
        // borrow on `f` before running the body).
        if let Some(any) = &f.user {
            if let Ok(callable) = Rc::clone(any).downcast::<UserCallable>() {
                // dart's trace: the `meta.call(...)` expression is a call
                // site (a frame at `pos`, attributed to the current member),
                // and frames inside the body name the function itself
                // (`f()`). An internal invocation with no position (the
                // user-overridden `calc()` hook) records no frame. The body
                // then runs against the function's defining file.
                let saved_member =
                    (pos.line > 0).then(|| self.enter_call(pos, length, &format!("{}()", callable.def.name)));
                let saved_file = self.enter_origin_file(Some(&callable.origin));
                let saved_scopes = std::mem::replace(&mut self.scopes, callable.env.clone());
                let saved_var_spans = std::mem::replace(&mut self.var_spans, callable.env_spans.clone());
                let saved_semi = std::mem::replace(&mut self.scope_semi_global, callable.env_semi.clone());
                let saved_fns = std::mem::replace(&mut self.functions, callable.env_fns.clone());
                let saved_mixins = std::mem::replace(&mut self.mixins, callable.env_mixins.clone());
                // The body resolves `ns.member` against ITS definition site's
                // `@use` namespaces, not the caller's (as the direct-call and
                // mixin-reference paths already do).
                let saved_env_modules = self.install_env_modules(&callable.env_modules);
                self.push_scope(false);
                // Like `invoke_mixin_ref`: the arguments arrive already
                // evaluated and reordered by `meta.call`, so no per-argument
                // span survives. Bind with none rather than guess.
                let result = self
                    .bind_evaled_into_scope(
                        &callable.def.params,
                        (pos_args, named, ListSep::Comma),
                        &ArgSpans::default(),
                        &super::control_flow::declared(&callable),
                    )
                    .and_then(|()| {
                        self.in_mixin.push(false);
                        let r = self.run_fn_body(&callable.def.body);
                        self.in_mixin.pop();
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
                if let Some(saved_member) = saved_member {
                    self.leave_call(saved_member);
                }
                return match result? {
                    Some(v) => Ok(v.without_slash()),
                    None => Err(Error::unpositioned(format!(
                        "Function {}() did not @return a value.",
                        callable.def.name
                    ))),
                };
            }
        }
        // A plain-CSS reference is preserved verbatim as a CSS function call.
        if f.css {
            let mut parts: Vec<String> = pos_args.iter().map(|v| v.to_css(false)).collect();
            for (n, v) in &named {
                parts.push(format!("${n}: {}", v.to_css(false)));
            }
            return Ok(Value::Str(SassStr {
                text: format!("{}({})", f.name, parts.join(", ")).into(),
                quoted: false,
            }));
        }
        // A built-in reference. The `sass:meta` introspection functions need
        // the evaluator's scopes/definitions; everything else dispatches
        // through the value-only builtin library — through the MODULE when the
        // reference was taken from one, since a member and its global alias are
        // not always the same function (`color.scale` vs `scale-color`).
        //
        // The name is looked up canonically (`call("variable_exists", …)` comes
        // straight from a string and has never been through `get-function`),
        // while `f.name` keeps the spelling a plain-CSS reference serializes.
        let canonical = if f.name.contains('_') {
            Cow::Owned(f.name.replace('_', "-"))
        } else {
            Cow::Borrowed(f.name.as_str())
        };
        let canonical = canonical.as_ref();
        if f.module.map_or(true, |m| m == crate::value::BuiltinModule::Meta) {
            if let Some(r) = self.try_meta_eval_call(canonical, &pos_args, &named, pos, length) {
                return r;
            }
        }
        let owner = f.module.map(|m| m.name());
        let v = match owner {
            Some(m) => crate::builtins::call_module(m, canonical, &pos_args, &named, pos)?,
            None => crate::builtins::call(canonical, &pos_args, &named, pos)?,
        };
        // A reference reaches the same function, so it carries the same
        // deprecation — reported against the INVOCATION, as the others are.
        if pos.line > 0 {
            self.emit_color_function_deprecation(canonical, owner, pos, length, &pos_args, &named);
        }
        Ok(v.without_slash())
    }

    /// Read the single string `$name` argument of an existence predicate,
    /// enforcing arity (1 positional, or `$name`) and the string type.
    /// Parse the `$name` (and optional `$module` namespace, when `allow_module`)
    /// arguments of an existence predicate. A `null` `$module` is treated as
    /// absent. Returns `(name, module)`.
    fn exists_name_module_args(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
        allow_module: bool,
    ) -> Result<(String, Option<String>), Error> {
        let max = if allow_module { 2 } else { 1 };
        crate::builtins::check_arity(max, pos_args, named, pos)?;
        let name_v = pos_args
            .first()
            .or_else(|| named.iter().find(|(n, _)| n == "name").map(|(_, v)| v))
            .ok_or_else(|| Error::at("Missing argument $name.".to_string(), pos))?;
        let name = match name_v {
            Value::Str(s) => s.text.to_string(),
            other => {
                return Err(Error::at(
                    format!("$name: {} is not a string.", other.to_css(false)),
                    pos,
                ))
            }
        };
        let module = if allow_module {
            let m = pos_args
                .get(1)
                .or_else(|| named.iter().find(|(n, _)| n == "module").map(|(_, v)| v));
            match m {
                None | Some(Value::Null) => None,
                Some(Value::Str(s)) => Some(s.text.to_string()),
                Some(other) => {
                    return Err(Error::at(
                        format!("$module: {} is not a string.", other.to_css(false)),
                        pos,
                    ))
                }
            }
        } else {
            None
        };
        Ok((name, module))
    }

    /// Whether the module bound to namespace `ns` defines a member `name` of the
    /// given kind (function/mixin/variable). An unknown namespace is an error.
    fn module_member_exists(&self, ns: &str, name: &str, kind: MemberKind, pos: Pos) -> Result<bool, Error> {
        if let Some(m) = self.used_user_modules.get(ns) {
            // A built-in the module re-exports brings its own members along.
            let forwarded = || resolve_forwarded_builtin(m, name);
            return Ok(match kind {
                MemberKind::Function => m.function(name).is_some() || forwarded().is_some(),
                MemberKind::Mixin => {
                    m.mixin(name).is_some() || resolve_forwarded_builtin_mixin(m, name).is_some()
                }
                MemberKind::Variable => {
                    m.var(name).is_some() || resolve_forwarded_builtin_var(m, name).is_some()
                }
            });
        }
        if let Some(builtin) = self.used_modules.get(ns).copied() {
            return Ok(match kind {
                MemberKind::Function => crate::builtins::module_has_member(builtin, name),
                MemberKind::Mixin => is_builtin_mixin(builtin, name),
                MemberKind::Variable => crate::builtins::module_var(builtin, name, pos).is_ok(),
            });
        }
        Err(Error::at(
            format!("There is no module with the namespace \"{ns}\"."),
            pos,
        ))
    }

    /// `meta.module-variables/-functions/-mixins($module)`: a map from each
    /// (non-private) member name of the `@use`d module bound to `$module` to its
    /// value (variables) or a first-class reference (functions/mixins). Members
    /// are ordered by name (dart-sass uses source order; every spec module
    /// defines them alphabetically, so this matches byte-for-byte).
    fn meta_module_members(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
        kind: MemberKind,
    ) -> Result<Value, Error> {
        if pos_args.len() > 1 {
            return Err(Error::at(
                format!("Only 1 argument allowed, but {} were passed.", pos_args.len()),
                pos,
            ));
        }
        let v = pos_args
            .first()
            .or_else(|| named.iter().find(|(n, _)| n == "module").map(|(_, v)| v))
            .ok_or_else(|| Error::at("Missing argument $module.".to_string(), pos))?;
        let ns = match v {
            Value::Str(s) => s.text.to_string(),
            other => {
                return Err(Error::at(
                    format!("$module: {} is not a string.", other.to_css(false)),
                    pos,
                ))
            }
        };
        let Some(module) = self.used_user_modules.get(&ns).cloned() else {
            // A built-in module: `sass:meta` is modeled member-by-member
            // (the suite probes it); other built-ins have no variables and
            // their callables are dispatched, not enumerated, so report the
            // names we know.
            if let Some(builtin) = self.used_modules.get(&ns) {
                // The enumerated references belong to the module, not to the
                // namespace they were reached through.
                let owner = crate::value::BuiltinModule::from_name(builtin);
                let names: Vec<&str> = match (*builtin, kind) {
                    ("meta", MemberKind::Function) => crate::builtins::META_FUNCTION_NAMES.to_vec(),
                    ("meta", MemberKind::Mixin) => crate::builtins::META_MIXIN_NAMES.to_vec(),
                    _ => Vec::new(),
                };
                let entries: Vec<(Value, Value)> = names
                    .into_iter()
                    .map(|name| {
                        let key = Value::Str(SassStr {
                            text: name.to_string().into(),
                            quoted: true,
                        });
                        let val = match kind {
                            MemberKind::Function => Value::Function(SassFunction {
                                name: name.to_string(),
                                css: false,
                                module: owner,
                                user: None,
                            }),
                            MemberKind::Mixin => Value::Mixin(Box::new(SassMixin {
                                name: name.to_string(),
                                user: None,
                                module: None,
                            })),
                            MemberKind::Variable => Value::Null,
                        };
                        (key, val)
                    })
                    .collect();
                return Ok(Value::Map(Map::new(entries)));
            }
            // dart drops the article in the `module-*` functions ONLY: every
            // other namespace error says "with the namespace".
            return Err(Error::at(
                format!("There is no module with namespace \"{ns}\"."),
                pos,
            ));
        };
        let mut names: Vec<String> = match kind {
            MemberKind::Variable => module.vars.borrow().keys().cloned().collect(),
            MemberKind::Function => module.functions.borrow().keys().cloned().collect(),
            MemberKind::Mixin => module.mixins.borrow().keys().cloned().collect(),
        };
        names.retain(|n| !is_private_member(n));
        names.sort();
        let entries: Vec<(Value, Value)> = names
            .into_iter()
            .map(|name| {
                // Member names are canonicalized to the dashed form for the map
                // key (dart-sass: `$e_f` is keyed `"e-f"`); the value keeps the
                // variable's own value verbatim.
                let key = Value::Str(SassStr {
                    text: name.replace('_', "-").into(),
                    quoted: true,
                });
                let val = match kind {
                    MemberKind::Variable => module.var(&name).unwrap_or(Value::Null),
                    MemberKind::Function => Value::Function(SassFunction {
                        name: name.clone(),
                        css: false,
                        module: None,
                        user: module
                            .function(&name)
                            .map(|f| Rc::clone(&f) as Rc<dyn std::any::Any>),
                    }),
                    MemberKind::Mixin => Value::Mixin(Box::new(SassMixin {
                        name: name.clone(),
                        user: module
                            .mixin(&name)
                            .map(|m| Rc::clone(&m) as Rc<dyn std::any::Any>),
                        module: Some(Rc::clone(&module) as Rc<dyn std::any::Any>),
                    })),
                };
                (key, val)
            })
            .collect();
        Ok(Value::Map(Map::new(entries)))
    }

    /// `meta.variable-exists($name)` / `meta.global-variable-exists($name)`:
    /// whether a variable of that name is in scope (globally only when
    /// `global`). Names are matched dash/underscore-insensitively.
    fn meta_variable_exists(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
        global: bool,
    ) -> Result<Value, Error> {
        // Only `global-variable-exists` takes the optional `$module` namespace.
        let (name, module) = self.exists_name_module_args(pos_args, named, pos, global)?;
        if let Some(ns) = module {
            return Ok(Value::Bool(self.module_member_exists(
                &ns,
                &name,
                MemberKind::Variable,
                pos,
            )?));
        }
        let key = normalize_arg_name(&name);
        let scopes: &[Scope] = if global { &self.scopes[..1] } else { &self.scopes };
        let found = scopes
            .iter()
            .any(|s| s.borrow().keys().any(|k| normalize_arg_name(k) == key));
        if found {
            return Ok(Value::Bool(true));
        }
        // A variable exposed unprefixed via `@use … as *` (or forwarded into
        // one) — from a user module or a built-in one. Exposure of two
        // DIFFERENT variables under the name is ambiguous.
        let count = self.star_member_count(&name, MemberKind::Variable)
            + self.star_builtin_hits(&name, MemberKind::Variable).len();
        if count > 1 {
            return Err(Error::at(
                "This variable is available from multiple global modules.",
                pos,
            ));
        }
        Ok(Value::Bool(count >= 1))
    }

    /// `meta.mixin-exists($name)`: whether a mixin of that name is defined.
    fn meta_mixin_exists(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
    ) -> Result<Value, Error> {
        let (name, module) = self.exists_name_module_args(pos_args, named, pos, true)?;
        if let Some(ns) = module {
            return Ok(Value::Bool(self.module_member_exists(
                &ns,
                &name,
                MemberKind::Mixin,
                pos,
            )?));
        }
        let key = normalize_arg_name(&name);
        let local = self.lookup_mixin_norm(&key).is_some();
        if local {
            return Ok(Value::Bool(true));
        }
        let count = self.star_member_count(&name, MemberKind::Mixin)
            + self.star_builtin_hits(&name, MemberKind::Mixin).len();
        if count > 1 {
            return Err(Error::at(
                "This mixin is available from multiple global modules.",
                pos,
            ));
        }
        Ok(Value::Bool(count >= 1))
    }

    /// `meta.function-exists($name)`: whether a user `@function` or a built-in
    /// of that name exists.
    fn meta_function_exists(
        &self,
        pos_args: &[Value],
        named: &[(String, Value)],
        pos: Pos,
    ) -> Result<Value, Error> {
        let (name, module) = self.exists_name_module_args(pos_args, named, pos, true)?;
        if let Some(ns) = module {
            return Ok(Value::Bool(self.module_member_exists(
                &ns,
                &name,
                MemberKind::Function,
                pos,
            )?));
        }
        let key = normalize_arg_name(&name);
        let user = self.lookup_function_norm(&key).is_some();
        if user {
            return Ok(Value::Bool(true));
        }
        // A function exposed unprefixed via `@use … as *` (or forwarded into a
        // module that is itself `@use`d as `*`), and a BUILT-IN module's member
        // exposed the same way — `map.get` is no global, so only that lookup
        // finds it. They compete for one name, so one count covers both.
        let count = self.star_member_count(&name, MemberKind::Function)
            + self.star_builtin_hits(&name, MemberKind::Function).len();
        if count > 1 {
            return Err(Error::at(
                "This function is available from multiple global modules.",
                pos,
            ));
        }
        if count >= 1 {
            return Ok(Value::Bool(true));
        }
        Ok(Value::Bool(
            crate::builtins::is_builtin(&name)
                || crate::builtins::EVAL_GLOBAL_NAMES.contains(&name.replace('_', "-").as_str()),
        ))
    }

    /// Every built-in member a `name` written unprefixed reaches through a
    /// `@use … as *` — a built-in module starred directly, or a user module
    /// starred that re-exports one with `@forward "sass:…"` (under whatever
    /// name that forward gives it).
    ///
    /// Deduplicated by IDENTITY, because that is what dart's ambiguity rule is
    /// about: `@use "fwd" as *` next to `@use "sass:map" as *`, where `fwd`
    /// forwards `sass:map`, exposes ONE `map.get` and resolves fine, while
    /// `sass:list`'s `index` next to `sass:string`'s is two members and an
    /// error.
    pub(super) fn star_builtin_hits(&self, name: &str, kind: MemberKind) -> Vec<(String, String)> {
        // The common case is no `@use … as *` at all; every call, variable and
        // include asks this, so answer it before allocating anything.
        if self.star_modules.is_empty() && self.star_user_modules.is_empty() {
            return Vec::new();
        }
        let name = name.replace('_', "-");
        let mut hits: Vec<(String, String)> = Vec::new();
        for m in &self.star_modules {
            let owns = match kind {
                MemberKind::Function => crate::builtins::module_has_member(m, &name),
                MemberKind::Variable => crate::builtins::module_var(m, &name, Pos::NONE).is_ok(),
                MemberKind::Mixin => is_builtin_mixin(m, &name),
            };
            let hit = (m.to_string(), name.clone());
            if owns && !hits.contains(&hit) {
                hits.push(hit);
            }
        }
        for m in &self.star_user_modules {
            // A module's OWN member shadows the built-in it forwards under the
            // same name — `@forward "sass:string"` beside `@function index` is
            // that module's `index`, namespaced and starred alike — so the
            // forwarded one is not a second member competing for the name.
            let own = match kind {
                MemberKind::Function => m.function(&name).is_some(),
                MemberKind::Variable => m.var(&name).is_some(),
                MemberKind::Mixin => m.mixin(&name).is_some(),
            };
            if own {
                continue;
            }
            let found = match kind {
                MemberKind::Function => resolve_forwarded_builtin(m, &name),
                MemberKind::Variable => resolve_forwarded_builtin_var(m, &name),
                MemberKind::Mixin => resolve_forwarded_builtin_mixin(m, &name),
            };
            if let Some(hit) = found {
                if !hits.contains(&hit) {
                    hits.push(hit);
                }
            }
        }
        hits
    }

    /// Count how many `@use … as *` modules expose `name` as the given member
    /// kind; more than one means an unqualified reference is ambiguous.
    fn star_member_count(&self, name: &str, kind: MemberKind) -> usize {
        if is_private_member(name) {
            return 0;
        }
        self.star_user_modules
            .iter()
            .filter(|m| match kind {
                MemberKind::Variable => m.var(name).is_some(),
                MemberKind::Mixin => m.mixin(name).is_some(),
                MemberKind::Function => m.function(name).is_some(),
            })
            .count()
    }

    /// `meta.content-exists()`: whether the enclosing mixin was passed a
    /// `@content` block. It is an error to call this outside a mixin body.
    fn meta_content_exists(&self, pos_args: &[Value], pos: Pos) -> Result<Value, Error> {
        if !pos_args.is_empty() {
            return Err(Error::at(
                format!("Only 0 arguments allowed, but {} were passed.", pos_args.len()),
                pos,
            ));
        }
        if self.in_mixin.last().copied() != Some(true) {
            return Err(Error::at(
                "content-exists() may only be called within a mixin.",
                pos,
            ));
        }
        let has = matches!(self.content_stack.last(), Some(Some(_)));
        Ok(Value::Bool(has))
    }

    /// Try `member` against a built-in module re-exported by `module` via
    /// `@forward "sass:x"` (honouring an `as p-*` prefix).
    fn try_forwarded_builtin_call(
        &mut self,
        module: &Rc<Module>,
        member: &str,
        args: &[CallArg],
        pos: Pos,
        length: usize,
    ) -> Result<Option<Value>, Error> {
        let Some((owner, bare)) = resolve_forwarded_builtin(module, member) else {
            return Ok(None);
        };
        // Reached through a `@forward "sass:…"`, the member is still that
        // module's — and still deprecated if it is (`m.feature-exists(…)`
        // after `@forward "sass:meta"`).
        let (mut pos_args, mut named, _) = self.eval_call_args(args)?;
        self.emit_call_deprecations(&bare, Some(&owner), pos, length);
        for v in &mut pos_args {
            *v = std::mem::replace(v, Value::Null).without_slash();
        }
        for (_, v) in &mut named {
            *v = std::mem::replace(v, Value::Null).without_slash();
        }
        // The `sass:meta` predicates resolve against the evaluator, which the
        // value-only dispatcher cannot do — a forwarded `meta.get-function` is
        // still `get-function`.
        if owner == "meta" {
            if let Some(r) = self.try_meta_eval_call(&bare, &pos_args, &named, pos, length) {
                return r.map(Some);
            }
        }
        let v = crate::builtins::call_module(&owner, &bare, &pos_args, &named, pos)?;
        self.emit_color_function_deprecation(&bare, Some(&owner), pos, length, &pos_args, &named);
        Ok(Some(v.without_slash()))
    }

    /// Call a user module's function in the module's own environment: bind the
    /// arguments in the caller's context, then swap in the module's globals/
    /// functions/mixins/used-modules so the body resolves against the module.
    pub(super) fn call_user_module_function(
        &mut self,
        module: &Rc<Module>,
        func: &Rc<UserCallable>,
        args: &[CallArg],
        call: Option<(Pos, usize)>,
    ) -> Result<Value, Error> {
        let (evaled, arg_spans) = self.eval_call_args_spanned(args)?;
        let saved_member = call.map(|(pos, len)| self.enter_call(pos, len, &format!("{}()", func.def.name)));
        let saved = self.enter_module(module);
        // The function's own defining file beats the module handed to us (a
        // multi-hop `@forward` can name another module).
        let saved_file = self.enter_origin_file(Some(&func.origin));
        let saved_scopes = std::mem::replace(&mut self.scopes, func.env.clone());
        let saved_var_spans = std::mem::replace(&mut self.var_spans, func.env_spans.clone());
        let saved_semi = std::mem::replace(&mut self.scope_semi_global, func.env_semi.clone());
        let saved_fns = std::mem::replace(&mut self.functions, func.env_fns.clone());
        let saved_mixins = std::mem::replace(&mut self.mixins, func.env_mixins.clone());
        // The captured tables beat the module's own: a multi-hop `@forward`
        // can hand us a module whose namespaces differ from the file that
        // DEFINED the function (uswds `units()` reaching `sass:meta`).
        let saved_env_modules = self.install_env_modules(&func.env_modules);
        self.push_scope(false);
        let result = self
            .bind_evaled_into_scope(
                &func.def.params,
                evaled,
                &arg_spans,
                &super::control_flow::declared(func),
            )
            .and_then(|()| {
                // A function body is not a mixin body: `meta.content-exists()`
                // called from a module function (even one a mixin with a
                // content block invokes) errors, as on the direct-call path.
                self.in_mixin.push(false);
                let r = self.run_fn_body(&func.def.body);
                self.in_mixin.pop();
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
        if let Some(saved_member) = saved_member {
            self.leave_call(saved_member);
        }
        match result? {
            Some(v) => Ok(v.without_slash()),
            None => Err(Error::unpositioned(format!(
                "Function {}() did not @return a value.",
                func.def.name
            ))),
        }
    }
}
