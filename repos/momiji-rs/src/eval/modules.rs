use super::*;

/// The evaluator file-context fields swapped by [`Evaluator::enter_origin_file`]
/// and restored by [`Evaluator::leave_module_file`]:
/// `(current_url, current_source, current_file_dir, current_canonical)`.
type SavedModuleFile = (String, Rc<str>, Option<String>, Option<CanonicalUrl>);

impl<'a> Evaluator<'a> {
    /// Register an `@extend` directive: validate the (interpolation-resolved)
    /// target, then record one [`PendingExtend`] per comma-separated target.
    /// `parents` is the enclosing style-rule selector list; `@extend` outside a
    /// style rule (top level or directly inside `@at-root`/an at-rule) is an
    /// error.
    pub(super) fn register_extend(
        &mut self,
        selector: &[TplPiece],
        optional: bool,
        pos: Pos,
        parents: &[String],
    ) -> Result<(), Error> {
        // dart checks `_styleRule` (null inside `@at-root` before any nested
        // rule), not `_styleRuleIgnoringAtRoot` (which still feeds `&`).
        if parents.is_empty() || self.at_root_excluding_style_rule {
            return Err(Error::at("@extend may only be used within style rules.", pos));
        }
        let extenders = match &self.current_selector {
            Some(sel) => Rc::clone(sel),
            None => Rc::new(parents.to_vec()),
        };
        let target = self.eval_template(selector)?;
        if target.trim().is_empty() {
            return Err(Error::at("expected selector.", pos));
        }
        // dart rejects a *leading* empty component (`@extend ,a`) as
        // "expected selector.", while still allowing a trailing comma
        // (`@extend a,`); an empty middle component falls through to the
        // usual "target selector was not found." path.
        if target.trim_start().starts_with(',') {
            return Err(Error::at("expected selector.", pos));
        }
        let in_media = !self.media_queries.is_empty();
        for t in split_commas(&target).iter() {
            let t = t.trim();
            if t.is_empty() {
                continue;
            }
            match crate::selector::classify_target(t) {
                crate::selector::TargetClass::Simple(simple) => {
                    self.extends.push(PendingExtend {
                        origin: self.current_module.clone(),
                        target: simple,
                        target_str: t.to_string(),
                        extenders: extenders.clone(),
                        extender_breaks: self.current_linebreaks.clone(),
                        optional,
                        in_media,
                        pos,
                    });
                }
                crate::selector::TargetClass::Complex => {
                    return Err(Error::at("complex selectors may not be extended.", pos));
                }
                crate::selector::TargetClass::Compound => {
                    return Err(Error::at(
                        "compound selectors may no longer be extended.\n\
                         Consider `@extend a, :hover` instead.\n\
                         See https://sass-lang.com/d/extend-compound for details.",
                        pos,
                    ));
                }
                crate::selector::TargetClass::Invalid => {
                    return Err(Error::at("expected selector.", pos));
                }
            }
        }
        Ok(())
    }

    /// Post-eval extension pass: rewrite every emitted style-rule selector list
    /// according to the collected `@extend` directives, drop placeholder-only
    /// rules, and error on an unmatched non-`!optional` extend.
    pub(super) fn apply_extends(&mut self, out: &mut Vec<OutNode>) -> Result<(), Error> {
        // Per-origin upstream closures over the recorded load edges (the
        // module keys each origin can see, including itself).
        let deps = self.module_deps.borrow();
        let bfs = |start: &str| {
            let mut seen: std::collections::HashSet<String> = std::collections::HashSet::new();
            seen.insert(start.to_string());
            let mut stack = vec![start.to_string()];
            while let Some(k) = stack.pop() {
                if let Some(nexts) = deps.get(&k) {
                    for n in nexts {
                        if seen.insert(n.clone()) {
                            stack.push(n.clone());
                        }
                    }
                }
            }
            seen
        };
        let mut raw_cache: HashMap<String, std::collections::HashSet<String>> = HashMap::default();
        for pe in &self.extends {
            if raw_cache.contains_key(&pe.origin) {
                continue;
            }
            let seen = bfs(&pe.origin);
            raw_cache.insert(pe.origin.clone(), seen);
        }
        // A `meta.load-css` copy is also visible to any origin inside the
        // copied module's subtree: the clone carries that subtree's own
        // extensions (dart bakes them into the cloned CSS).
        let copies = self.load_css_copies.borrow();
        for (copy_key, base) in copies.iter() {
            let base_reach = bfs(base);
            for (origin, set) in raw_cache.iter_mut() {
                if base_reach.contains(origin) {
                    set.insert(copy_key.clone());
                }
            }
        }
        // An origin NOT reachable from the root tree (it was only ever
        // pulled in through `meta.load-css`) exists solely inside the
        // clones: its extensions apply to copy scopes only, never to the
        // main tree's module scopes (dart: such a module's extension store
        // never joins the root `_combineCss`).
        if !copies.is_empty() {
            let main_reach = bfs("");
            for (origin, set) in raw_cache.iter_mut() {
                if !origin.is_empty() && !main_reach.contains(origin) {
                    set.retain(|s| copies.iter().any(|(ck, _)| ck == s));
                }
            }
        }
        drop(copies);
        drop(deps);
        let closure_cache: HashMap<String, std::rc::Rc<std::collections::HashSet<String>>> = raw_cache
            .into_iter()
            .map(|(k, v)| (k, std::rc::Rc::new(v)))
            .collect();
        let mut extensions: Vec<crate::selector::Extension> = Vec::new();
        for (reg_idx, pe) in self.extends.iter().enumerate() {
            let mut extenders = Vec::new();
            let mut extender_breaks = Vec::new();
            for (i, ext) in pe.extenders.iter().enumerate() {
                if let Some(c) = crate::selector::parse_complex_one(ext) {
                    // A bogus extender with a trailing combinator (`d +`) can't
                    // extend anything — dart-sass drops it (with a deprecation).
                    if c.trailing.is_empty() {
                        extenders.push(c);
                        extender_breaks.push(pe.extender_breaks.get(i).copied().unwrap_or(false));
                    }
                }
            }
            extensions.push(crate::selector::Extension {
                target: Some(pe.target.clone()),
                extenders,
                extender_breaks,
                optional: pe.optional,
                matched: std::rc::Rc::new(std::cell::Cell::new(false)),
                origin: pe.origin.clone(),
                reg_idx,
                derived: false,
                via_origin: None,
                origin_closure: std::rc::Rc::clone(&closure_cache[&pe.origin]),
            });
        }
        // Keep GLOBAL REGISTRATION ORDER (module eval order): a scope's own
        // extensions register before its downstream loaders', and foreign
        // modules follow first-load order — the incremental fold inserts each
        // later application's products closest to the source complex, which
        // reproduces dart's combine-time sequence (own products innermost,
        // foreign stores reverse-load in the OUTPUT). Same-module extenders
        // stay in document order for the merged per-store batches. (An
        // earlier descending-closure-size sort approximated this but
        // misplaced sibling stores with unequal upstream counts — bulma's
        // form vs elements modules.)

        // An `@extend` registered inside `@media` may not extend a selector
        // outside any media context (dart-sass "You may not @extend selectors
        // across media queries."). Detect when an in-media extend's target
        // matches a root-level (non-media) rule.
        for pe in &self.extends {
            if pe.in_media && root_rule_contains_target(out, &pe.target) {
                return Err(Error::at(
                    "You may not @extend selectors across media queries.",
                    pe.pos,
                ));
            }
        }

        // Per-module visibility: an extension's origin can rewrite a module's
        // CSS when that module is (transitively) loaded by the origin.
        // Parallel to the (sorted) extensions list.
        let mut origins: Vec<String> = extensions.iter().map(|e| e.origin.clone()).collect();
        let closures: HashMap<String, std::collections::HashSet<String>> = closure_cache
            .iter()
            .map(|(k, v)| (k.clone(), (**v).clone()))
            .collect();
        // The store-merge order context: reverse load edges + first-load
        // ranks (an origin's registrations are contiguous, so its smallest
        // reg index is its load rank).
        let mut rev_deps: HashMap<String, Vec<String>> = HashMap::default();
        for (loader, loadeds) in self.module_deps.borrow().iter() {
            for loaded in loadeds {
                rev_deps.entry(loaded.clone()).or_default().push(loader.clone());
            }
        }
        let mut first_reg: HashMap<String, usize> = HashMap::default();
        for (i, pe) in self.extends.iter().enumerate() {
            first_reg.entry(pe.origin.clone()).or_insert(i);
        }
        let has_import_clones = !self.load_css_copies.borrow().is_empty()
            || rev_deps
                .keys()
                .any(|k| k.contains("#import") || k.contains("#copy"));
        if has_import_clones {
            // Legacy order for @import-mixed compiles (the store-merge model
            // below assumes pure-@use module identity): downstream-first by
            // closure size, stable within a module.
            let mut keyed: Vec<(usize, crate::selector::Extension, String)> = extensions
                .into_iter()
                .zip(origins)
                .map(|(e, o)| (closure_cache.get(&o).map_or(0, |c| c.len()), e, o))
                .collect();
            keyed.sort_by_key(|(n, _, _)| std::cmp::Reverse(*n));
            extensions = keyed.iter().map(|(_, e, _)| e.clone()).collect();
            origins = keyed.into_iter().map(|(_, _, o)| o).collect();
        }
        let order = ExtendOrderCtx {
            rev_deps,
            first_reg,
            has_import_clones,
        };
        rewrite_nodes_scoped(out, "", &extensions, &origins, &closures, &order);

        // Report the first unmatched non-optional extend. A target that only
        // appears in an omitted bogus-combinator rule still counts as found
        // (dart extends it; the result is bogus too and is omitted).
        for (pe, ext) in self.extends.iter().zip(extensions.iter()) {
            // A private placeholder (`%-x`/`%_x`) is only visible within its
            // own module; any other target is visible across the extension's
            // module closure.
            let private = matches!(&pe.target,
                crate::selector::Simple::Placeholder(n) if n.starts_with('-') || n.starts_with('_'));
            if !ext.optional
                && !ext.matched.get()
                && !self
                    .bogus_selectors
                    .iter()
                    .any(|s| crate::selector::selector_contains_simple(s, &pe.target))
                && !self.placeholder_rules.iter().any(|(m, s)| {
                    let visible = if private {
                        *m == ext.origin
                    } else {
                        ext.origin_closure.contains(m)
                    };
                    visible && crate::selector::selector_contains_simple(s, &pe.target)
                })
            {
                return Err(Error::at(
                    format!(
                        "The target selector was not found.\nUse \"@extend {} !optional\" to avoid this error.",
                        pe.target_str
                    ),
                    pe.pos,
                ));
            }
        }
        Ok(())
    }

    /// `@include meta.load-css($url, $with: (...))`: load the module at `$url`
    /// and emit its CSS into the current sink, optionally configuring it with
    /// `$with`. Unlike `@use`, it binds no namespace and exposes no members; it
    /// reuses the shared `load_module` machinery (cache, cycle guard, CSS emit).
    pub(super) fn exec_load_css(
        &mut self,
        args: &[CallArg],
        content: Option<Rc<Vec<Stmt>>>,
        pos: Pos,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        let (pos_args, named, _) = self.eval_call_args(args)?;
        self.load_css_evaled(pos_args, named, content, pos, parents, sink)
    }

    /// `meta.load-css` with its arguments already evaluated — the form a
    /// first-class reference to it arrives in (`meta.apply(meta.get-mixin(
    /// "load-css"), …)`).
    pub(super) fn load_css_evaled(
        &mut self,
        pos_args: Vec<Value>,
        named: Vec<(String, Value)>,
        content: Option<Rc<Vec<Stmt>>>,
        pos: Pos,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        if content.is_some() {
            return Err(Error::at(
                "Mixin doesn't accept a content block.".to_string(),
                pos,
            ));
        }
        let mut iter = pos_args.into_iter();
        let mut url_val = iter.next();
        let mut with_val = iter.next();
        if iter.next().is_some() {
            return Err(Error::at(
                "Only 2 arguments allowed, but 3 were passed.".to_string(),
                pos,
            ));
        }
        for (n, v) in named {
            match n.as_str() {
                "url" => url_val = Some(v),
                "with" => with_val = Some(v),
                other => return Err(Error::at(format!("No argument named ${other}."), pos)),
            }
        }
        let url = match url_val {
            Some(Value::Str(s)) => s.text,
            Some(other) => {
                return Err(Error::at(
                    format!("$url: {} is not a string.", other.to_css(false)),
                    pos,
                ))
            }
            None => return Err(Error::at("Missing argument $url.".to_string(), pos)),
        };
        // Build the configuration from the `$with` map (string keys → variables).
        let mut config: HashMap<String, (Value, bool)> = HashMap::default();
        match with_val.take() {
            None => {}
            // An empty literal `()` parses as an empty list, not a map.
            Some(Value::List(l)) if l.items.is_empty() => {}
            Some(Value::Map(m)) => {
                for (k, v) in m.entries.as_ref().clone() {
                    let key = match k {
                        Value::Str(s) => normalize_var_name(&s.text).into_owned(),
                        other => {
                            return Err(Error::at(
                                format!("$with key: {} is not a string.", other.to_css(false)),
                                pos,
                            ))
                        }
                    };
                    // Dash/underscore-insensitive: `a-b` and `a_b` collide.
                    if config.contains_key(&key) {
                        return Err(Error::at(
                            format!("The variable ${key} was configured twice."),
                            pos,
                        ));
                    }
                    config.insert(key, (v.without_slash(), false));
                }
            }
            Some(other) => {
                return Err(Error::at(
                    format!("$with: {} is not a map.", other.to_css(false)),
                    pos,
                ))
            }
        }
        // A built-in `sass:*` module emits no CSS (and can't be configured).
        if let Some(m) = url.strip_prefix("sass:") {
            if crate::builtins::is_module(m) {
                if !config.is_empty() {
                    return Err(Error::at(
                        format!("Built-in module sass:{m} can't be configured."),
                        pos,
                    ));
                }
                return Ok(());
            }
            return Err(Error::at("Can't find stylesheet to import.".to_string(), pos));
        }
        let conf_keys: Vec<String> = config.keys().cloned().collect();
        // Evaluate the module into a fresh TOP-LEVEL buffer so its body runs in
        // its own top-level context — a module top-level declaration errors no
        // matter where load-css is invoked (dart-sass) — then splice the emitted
        // nodes into the caller's position.
        let mut buf: Vec<OutNode> = Vec::new();
        let consumed = {
            let mut module_sink = Sink::Top(&mut buf);
            let config_id = if config.is_empty() {
                0
            } else {
                self.fresh_config_id()
            };
            let (_module, consumed) =
                self.load_module(&url, config, config_id, pos, parents, true, &mut module_sink)?;
            consumed
        };
        if conf_keys.iter().any(|k| !consumed.contains(k)) {
            return Err(Error::at(
                "This variable was not declared with !default in the @used module.".to_string(),
                pos,
            ));
        }
        splice_nodes(sink, buf);
        Ok(())
    }

    /// Install a saved environment snapshot, returning the displaced one to
    /// restore afterwards.
    pub(super) fn install_env(&mut self, env: SavedModuleEnv) -> SavedModuleEnv {
        SavedModuleEnv {
            scopes: std::mem::replace(&mut self.scopes, env.scopes),
            var_spans: std::mem::replace(&mut self.var_spans, env.var_spans),
            scope_semi_global: std::mem::replace(&mut self.scope_semi_global, env.scope_semi_global),
            functions: std::mem::replace(&mut self.functions, env.functions),
            mixins: std::mem::replace(&mut self.mixins, env.mixins),
            used_modules: std::mem::replace(&mut self.used_modules, env.used_modules),
            star_modules: std::mem::replace(&mut self.star_modules, env.star_modules),
            used_user_modules: std::mem::replace(&mut self.used_user_modules, env.used_user_modules),
            star_user_modules: std::mem::replace(&mut self.star_user_modules, env.star_user_modules),
            write_back: None,
        }
    }

    /// Clone the current per-module environment (for capturing a content block's
    /// call-site closure).
    pub(super) fn snapshot_env(&mut self) -> SavedModuleEnv {
        // Like a callable's closure, the snapshot SHARES its frames with the
        // chain it was taken from, so they have to exist first.
        materialize_fn_frames(&mut self.functions);
        materialize_fn_frames(&mut self.mixins);
        SavedModuleEnv {
            scopes: self.scopes.clone(),
            var_spans: self.var_spans.clone(),
            scope_semi_global: self.scope_semi_global.clone(),
            functions: self.functions.clone(),
            mixins: self.mixins.clone(),
            used_modules: self.used_modules.clone(),
            star_modules: self.star_modules.clone(),
            used_user_modules: self.used_user_modules.clone(),
            star_user_modules: self.star_user_modules.clone(),
            write_back: None,
        }
    }

    /// Process a `@use "<url>" [as ns|as *] [with (...)];` for a built-in
    /// `sass:*` module or a user stylesheet.
    #[allow(clippy::too_many_arguments)]
    pub(super) fn exec_use(
        &mut self,
        url: &str,
        namespace: Option<&str>,
        star: bool,
        config: &[crate::ast::ConfigEntry],
        pos: Pos,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // Built-in `sass:<mod>` modules.
        if let Some(m) = url.strip_prefix("sass:") {
            let Some(module) = crate::builtins::module_name(m) else {
                return Err(Error::at("Can't find stylesheet to import.".to_string(), pos));
            };
            if !config.is_empty() {
                return Err(Error::at(
                    "Built-in modules can't be configured.".to_string(),
                    pos,
                ));
            }
            if star {
                if !self.star_modules.contains(&module) {
                    self.star_modules.push(module);
                }
                return Ok(());
            }
            let ns = namespace.unwrap_or(module).to_string();
            self.check_namespace_free(&ns, pos)?;
            self.used_modules.insert(ns, module);
            return Ok(());
        }

        // A user stylesheet module.
        let conf = self.eval_config(config)?;
        let conf_keys: Vec<String> = conf.keys().cloned().collect();
        let config_id = if conf.is_empty() {
            0
        } else {
            self.fresh_config_id()
        };
        // `parents` is only non-empty when this `@use` sits at the top of a
        // sheet imported INSIDE a style rule: the module still evaluates in a
        // clean context, but its emitted CSS joins the importing rule's
        // selectors (dart nests the whole import subtree's CSS —
        // nested_import_into_use).
        // The load runs under a diagnostic `@use` frame so an error anywhere
        // in the module (parse or eval) carries the loader chain
        // (dart: `_mod.scss 3:19  @use` / `main.scss 1:1  root stylesheet`).
        let saved_member = self.enter_call(pos, 0, "@use");
        let result = self.load_module(url, conf, config_id, pos, parents, false, sink);
        self.leave_call(saved_member);
        let (module, consumed) = result?;
        // Any configured variable the module did not consume via a `!default`
        // declaration is an error.
        if conf_keys.iter().any(|k| !consumed.contains(k)) {
            return Err(Error::at(
                "This variable was not declared with !default in the @used module.".to_string(),
                pos,
            ));
        }
        if star {
            // A member the new global module exposes that the current sheet
            // already defines at the top level is a conflict.
            if let Some(g) = self.scopes.first() {
                for name in module.vars.borrow().keys() {
                    if !is_private_member(name) && g.borrow().contains_key(name) {
                        return Err(Error::at(
                            format!(
                                "This module and the new module both define a variable named \"${name}\"."
                            ),
                            pos,
                        ));
                    }
                }
            }
            // `@use`ing the same module twice as `*` is idempotent (no
            // ambiguity), so de-duplicate by module identity.
            let ptr = Rc::as_ptr(&module);
            if !self.star_user_modules.iter().any(|m| Rc::as_ptr(m) == ptr) {
                self.star_user_modules.push(module);
            }
            return Ok(());
        }
        let ns = match namespace {
            Some(n) => n.to_string(),
            None => default_namespace(url, pos)?,
        };
        self.check_namespace_free(&ns, pos)?;
        self.used_user_modules.insert(ns, module);
        Ok(())
    }

    /// Reject a namespace already bound by another `@use` in the same sheet.
    fn check_namespace_free(&self, ns: &str, pos: Pos) -> Result<(), Error> {
        if self.used_modules.contains_key(ns) || self.used_user_modules.contains_key(ns) {
            return Err(Error::at(
                format!("There's already a module with namespace \"{ns}\"."),
                pos,
            ));
        }
        Ok(())
    }

    /// Evaluate a `with (...)` configuration clause into a name -> (value,
    /// is_default) map.
    fn eval_config(
        &mut self,
        config: &[crate::ast::ConfigEntry],
    ) -> Result<HashMap<String, (Value, bool)>, Error> {
        let mut map = HashMap::default();
        for entry in config {
            let v = self.eval_expr(&entry.value)?.without_slash();
            // Variable names are dash/underscore-insensitive: store the
            // canonical (dashed) form so `$a_b` and `$a-b` configure the same
            // variable. A duplicate key is an error.
            let key = normalize_var_name(&entry.name).into_owned();
            if map.contains_key(&key) {
                return Err(Error::unpositioned(format!(
                    "The variable ${} was configured twice.",
                    entry.name
                )));
            }
            map.insert(key, (v, entry.is_default));
        }
        Ok(map)
    }

    /// Load (and cache) a user module: resolve its URL, evaluate it once into an
    /// isolated environment with `config` applied to its `!default` variables,
    /// emit its CSS into `sink`, and return the shared module instance plus the
    /// list of config keys the module consumed (for `@forward ... with`
    /// pass-through).
    /// Collect a module's full subtree CSS (dependencies upstream-first,
    /// each module once), un-wrapping embedded module-scope nodes — used for
    /// `meta.load-css`, which re-emits the whole subtree at the call site
    /// (dart `_combineCss` with `clone: true`).
    /// A fresh explicit-configuration identity.
    fn fresh_config_id(&self) -> usize {
        let n = self.config_id_counter.get() + 1;
        self.config_id_counter.set(n);
        n
    }

    fn subtree_css(&self, key: &str) -> Vec<OutNode> {
        let mut out = Vec::new();
        let mut visited = std::collections::HashSet::new();
        self.walk_subtree(key, &mut visited, &mut out);
        trim_leading_blanks(&mut out);
        out
    }

    fn walk_subtree(
        &self,
        key: &str,
        visited: &mut std::collections::HashSet<String>,
        out: &mut Vec<OutNode>,
    ) {
        if !visited.insert(key.to_string()) {
            return;
        }
        let deps = self
            .module_dep_order
            .borrow()
            .get(key)
            .cloned()
            .unwrap_or_default();
        for d in deps {
            self.walk_subtree(&d, visited, out);
        }
        if let Some(m) = self.module_cache.borrow().get(key) {
            for n in &m.css {
                // An embedded dependency's scope wrapper is covered by the
                // dependency walk above; a materialized clone (no load edge)
                // stays.
                if let OutNode::ModuleScope { key: k, .. } = n {
                    if !k.contains("#copy") && !k.contains("#import") {
                        continue;
                    }
                }
                out.push(n.clone());
            }
        }
    }

    /// Register a unique `meta.load-css` copy scope for `key` at the current
    /// call site: the caller gains a load edge to the copy (its extensions
    /// apply to it), and origins inside the base's subtree are linked during
    /// `apply_extends`.
    fn register_load_css_copy(&self, key: &str) -> String {
        let n = self.copy_counter.get() + 1;
        self.copy_counter.set(n);
        let copy_key = format!("{key}#copy{n}");
        self.module_deps
            .borrow_mut()
            .entry(self.current_module.clone())
            .or_default()
            .insert(copy_key.clone());
        self.load_css_copies
            .borrow_mut()
            .push((copy_key.clone(), key.to_string()));
        copy_key
    }

    /// The copy scope and subtree CSS for one forced re-emit. Inside a
    /// module-loading `@import`, all loads share the import's single copy key
    /// and visited set (a diamond's shared upstream emits once per import);
    /// a `meta.load-css` call gets its own key and a fresh walk.
    fn clone_module_css(&mut self, key: &str) -> (String, Vec<OutNode>) {
        let state = self.import_clone.take();
        if let Some((k, mut visited)) = state {
            let copy_key = k.clone();
            self.module_deps
                .borrow_mut()
                .entry(self.current_module.clone())
                .or_default()
                .insert(copy_key.clone());
            self.load_css_copies
                .borrow_mut()
                .push((copy_key.clone(), key.to_string()));
            let mut out = Vec::new();
            self.walk_subtree(key, &mut visited, &mut out);
            trim_leading_blanks(&mut out);
            self.import_clone = Some((k, visited));
            (copy_key, out)
        } else {
            let copy_key = self.register_load_css_copy(key);
            (copy_key, self.subtree_css(key))
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn load_module(
        &mut self,
        url: &str,
        config: HashMap<String, (Value, bool)>,
        config_id: usize,
        pos: Pos,
        parents: &[String],
        force_reemit: bool,
        sink: &mut Sink<'_>,
    ) -> Result<(Rc<Module>, Vec<String>), Error> {
        // Inside a module-loading `@import`, every load re-emits as a clone.
        // A TRUE `meta.load-css` call (not an @import clone): dart re-visits
        // the combined css node-by-node, so every re-visited top-level style
        // rule re-acquires isGroupEnd — the copy's rules blank-separate like
        // freshly written ones (reveal.js print/pdf.scss).
        let is_load_css = force_reemit;
        let force_reemit = force_reemit || self.import_clone.is_some();
        let importer = self.options.importer;
        // The caller's importer runs OUTSIDE the arena scope: anything it
        // allocates (e.g. a cache of paths it owns) must survive past this
        // compile's arena reset, so route its allocations to the system
        // allocator. The returned `String`s are then deep-copied into the arena
        // below by the parse/eval pipeline.
        let paused = crate::arena::pause();
        // Phase 1 of resolution: canonicalize, inside the arena pause so the
        // importer's owned allocations survive this compile's arena reset.
        // `@use`/`@forward` never consider import-only files.
        //
        // Phase 2 (`load`) used to run here too, unconditionally. It is now
        // deferred past the module-cache probe below, because the canonical URL
        // is the cache key and a hit never reads the loaded text: a second
        // `@use` of an already-evaluated module re-emits nothing and re-parses
        // nothing, so reading the file again is a syscall spent on a string
        // that is dropped. dart-sass caches the same way and at the same
        // granularity -- `ImportCache.importCanonical` memoizes per canonical
        // URL, not per edge -- and this file's `@import` path already probes
        // `import_cache` ahead of both phases.
        let phase1 = match importer {
            Some(imp) => {
                let ctx = CanonicalizeContext {
                    from_import: false,
                    containing_url: self.current_canonical.as_ref(),
                };
                match imp.canonicalize(url, &ctx) {
                    Err(e) => return Err(Error::at(e.message, pos)),
                    Ok(None) => None,
                    // The key is built inside the pause: it outlives this
                    // compile's arena reset in `module_cache`. `imp` rides
                    // along so phase 2 cannot be handed a different importer
                    // than the one that produced `canon`.
                    Ok(Some(canon)) => Some((canon.as_str().to_string(), canon, imp)),
                }
            }
            None => None,
        };
        drop(paused);
        let (key, canon, imp) = match phase1 {
            Some(triple) => triple,
            None => {
                return Err(Error::at("Can't find stylesheet to import.".to_string(), pos));
            }
        };
        // The cache probe, and phase 2 only on a miss. Both sit ABOVE the sink
        // mutation below on purpose: popping the pre-module comment run is an
        // edit to the output, and an error out of `load` must not leave it
        // already popped.
        let cached = self.module_cache.borrow().get(&key).cloned();
        let loaded = if cached.is_some() {
            None
        } else {
            let paused = crate::arena::pause();
            let res = match imp.load(&canon) {
                Err(e) => return Err(Error::at(e.message, pos)),
                Ok(v) => v,
            };
            drop(paused);
            match res {
                Some(res) => Some((res.contents, res.syntax, res.source_map_url)),
                None => {
                    return Err(Error::at("Can't find stylesheet to import.".to_string(), pos));
                }
            }
        };
        // Pop the comment run textually preceding this `@use`/`@forward` so
        // each outcome below can put it back in front of the module's CSS.
        // dart-sass 1.104.1 emits such a comment exactly ONCE: up to 1.104.0 a
        // repeat edge into an already-loaded module re-emitted the comments
        // that preceded its first load, which is the duplication that release
        // fixed.
        let own_run: Vec<OutNode> = match sink {
            Sink::Top(out) => {
                let mut i = out.len();
                while i > 0 && matches!(out[i - 1], OutNode::Comment(..) | OutNode::Blank) {
                    i -= 1;
                }
                out.split_off(i)
            }
            _ => Vec::new(),
        };
        fn push_run(sink: &mut Sink<'_>, run: Vec<OutNode>) {
            if let Sink::Top(out) = sink {
                out.extend(run);
            }
        }
        // A module evaluated once and cached is shared; its CSS is NOT
        // re-emitted. Re-loading it with configuration is an error — unless the
        // configuration targets no variable the module actually defines (a
        // module with no configurable variables may be loaded with or without
        // config). The keys it *does* define count as consumed for the caller.
        if let Some(existing) = cached {
            let consumed: Vec<String> = config
                .keys()
                .filter(|k| existing.var(k).is_some())
                .cloned()
                .collect();
            if !consumed.is_empty() {
                // An *implicit* configuration (an `@import`'s visible
                // variables) silently reuses the already-evaluated module —
                // `$a: changed; @import "fwd"` keeps the first load's values
                // (dart `Configuration.implicit`) — and re-emits its CSS at
                // this import site (dart clones the module's CSS per import).
                if self.config_is_implicit {
                    self.module_deps
                        .borrow_mut()
                        .entry(self.current_module.clone())
                        .or_default()
                        .insert(key.clone());
                    {
                        let mut ord = self.module_dep_order.borrow_mut();
                        let v = ord.entry(self.current_module.clone()).or_default();
                        if !v.contains(&key) {
                            v.push(key.clone());
                        }
                    }
                    push_run(sink, own_run);
                    splice_nodes(
                        sink,
                        vec![OutNode::ModuleScope {
                            key: key.clone(),
                            nodes: reparent_nodes(existing.css.clone(), parents),
                        }],
                    );
                    return Ok((existing, consumed));
                }
                // A configuration distributed through several forwards keeps
                // its ORIGINAL identity: re-reaching an already-loaded module
                // with the same original silently reuses it (dart-sass
                // sameOriginal).
                if config_id != 0 && existing.config_origin.get() == config_id {
                    push_run(sink, own_run);
                    return Ok((existing, consumed));
                }
                return Err(Error::at(
                    "This module was already loaded, so it can't be configured using \"with\".".to_string(),
                    pos,
                ));
            }
            // The cached module consumed nothing (it defines none of the
            // configured variables); the caller's own/forwarded handling decides
            // whether the leftover configuration is an error. `meta.load-css`
            // still re-emits the cached CSS at the call site — WITHOUT a load
            // edge to the base module (the caller only gains the copy edge, so
            // a module pulled in solely through load-css never joins the main
            // tree's extension reachability).
            if !force_reemit {
                self.module_deps
                    .borrow_mut()
                    .entry(self.current_module.clone())
                    .or_default()
                    .insert(key.clone());
                let mut ord = self.module_dep_order.borrow_mut();
                let v = ord.entry(self.current_module.clone()).or_default();
                if !v.contains(&key) {
                    v.push(key.clone());
                }
            }
            // A repeat edge emits nothing of its own: this site's comments stay
            // in place, and dart-sass 1.104.1 no longer re-emits the ones that
            // preceded the module's first load.
            push_run(sink, own_run);
            if force_reemit {
                // A `meta.load-css` copy re-emits the module's whole SUBTREE
                // at the call site under a unique copy scope: the caller's
                // extensions apply to it (caller -> copy edge), the subtree's
                // own extensions apply to the clone, and other loaders'
                // extensions do not (dart `_combineCss` with `clone: true`).
                let (copy_key, nodes) = self.clone_module_css(&key);
                let nodes = if is_load_css {
                    let mut prev_rule = false;
                    regroup_load_css_copy(nodes, &mut prev_rule)
                } else {
                    nodes
                };
                splice_nodes(
                    sink,
                    vec![OutNode::ModuleScope {
                        key: copy_key,
                        nodes: reparent_nodes(nodes, parents),
                    }],
                );
            } else if !existing.emitted_main.get() {
                // First loaded inside an import/load-css clone: this plain
                // load is the module's first appearance in the MAIN tree.
                existing.emitted_main.set(true);
                splice_nodes(
                    sink,
                    vec![OutNode::ModuleScope {
                        key: key.clone(),
                        nodes: reparent_nodes(existing.css.clone(), parents),
                    }],
                );
            }
            return Ok((existing, Vec::new()));
        }
        // Guard against a load cycle.
        if self.loading.iter().any(|p| p == &key) {
            return Err(Error::at(
                "Module loop: this module is already being loaded.".to_string(),
                pos,
            ));
        }
        // Past the cache-hit block, every branch of which returns, so phase 2
        // ran and this is `Some`. Erring rather than unwrapping keeps a later
        // edit to that block from turning a missed `return` into a panic.
        let Some((src, syntax, source_map_url)) = loaded else {
            return Err(Error::at("Can't find stylesheet to import.".to_string(), pos));
        };
        // The display URL a snippet/frame shows for this file.
        let diag_url = self.module_diag_url(url, &key);
        // One shared copy of the module's text: for the source-map table, for
        // the module's own evaluation context, and — through that context —
        // for the `MixinOrigin` every callable defined in the file captures,
        // which is what a later cross-module invocation renders against.
        // Nothing reads it when diagnostics and source maps are both off, so
        // skip the copy.
        let text: Rc<str> = if self.diag_enabled() || self.options.source_map {
            Rc::from(src.as_str())
        } else {
            Rc::from("")
        };
        if self.options.source_map {
            self.file_texts.insert(key.clone(), Rc::clone(&text));
        }
        // A loaded sheet is validated like the entry (a misplaced `@import`
        // in a mixin body is dart's "This at-rule is not allowed here.");
        // plain CSS has nothing to validate.
        let parsed = parse_with_syntax(&src, syntax).and_then(|sheet| {
            if !matches!(syntax, Syntax::Css) {
                super::validate_declarations(&sheet)?;
            }
            Ok(sheet)
        });
        let sheet = match parsed {
            Ok(sheet) => sheet,
            Err(e) => {
                // A parse or validation error names the LOADED file: render
                // eagerly under its url/source (the caller's `@use`/`@forward`
                // frame is already on the stack), like dart's
                // `_mod.scss 3:19  @use` + loader chain.
                let saved_url = std::mem::replace(&mut self.current_url, diag_url.clone());
                let saved_source = std::mem::replace(&mut self.current_source, Rc::clone(&text));
                let e = self.finalize_error(e);
                self.current_url = saved_url;
                self.current_source = saved_source;
                return Err(e);
            }
        };
        // If the importer asked for a custom source-map URL for this file, record
        // it under the canonical key the source map keys on (the `@import`
        // path in mod.rs does the same for a file it loads).
        if let Some(smu) = source_map_url {
            self.file_map_urls.insert(key.clone(), smu);
        }
        let is_css = matches!(syntax, Syntax::Css);
        // A `meta.load-css` first load also records only the copy edge (see
        // the cache-hit branch above).
        if !force_reemit {
            self.module_deps
                .borrow_mut()
                .entry(self.current_module.clone())
                .or_default()
                .insert(key.clone());
            let mut ord = self.module_dep_order.borrow_mut();
            let v = ord.entry(self.current_module.clone()).or_default();
            if !v.contains(&key) {
                v.push(key.clone());
            }
        }
        // Evaluate into a buffer so the emitted CSS can be captured on the
        // module (for per-import re-emission) before splicing into the
        // caller's sink.
        let mut css_buf: Vec<OutNode> = Vec::new();
        let (mut module, consumed) = {
            let mut buf_sink = Sink::Top(&mut css_buf);
            self.eval_module(
                &key,
                &diag_url,
                Rc::clone(&text),
                &sheet,
                config,
                config_id,
                pos,
                &mut buf_sink,
                is_css,
            )?
        };
        module.css = css_buf.clone();
        let module = Rc::new(module);
        self.module_cache
            .borrow_mut()
            .insert(key.clone(), Rc::clone(&module));
        push_run(sink, own_run);
        // A first load through `meta.load-css` (force_reemit) splices the
        // module's whole subtree under a unique copy scope at the call site;
        // an ordinary `@use`/`@forward` load wraps its own CSS in its module
        // scope.
        if force_reemit {
            let (copy_key, nodes) = self.clone_module_css(&key);
            let nodes = if is_load_css {
                let mut prev_rule = false;
                regroup_load_css_copy(nodes, &mut prev_rule)
            } else {
                nodes
            };
            splice_nodes(
                sink,
                vec![OutNode::ModuleScope {
                    key: copy_key,
                    nodes: reparent_nodes(nodes, parents),
                }],
            );
        } else {
            module.emitted_main.set(true);
            splice_nodes(
                sink,
                vec![OutNode::ModuleScope {
                    key: key.clone(),
                    nodes: reparent_nodes(css_buf, parents),
                }],
            );
        }
        Ok((module, consumed))
    }

    /// Evaluate a parsed module sheet in an isolated environment. The module's
    /// top-level CSS is emitted into `sink`; its members are captured into a
    /// [`Module`]. `config` overrides its `!default` variables.
    #[allow(clippy::too_many_arguments)]
    fn eval_module(
        &mut self,
        key: &str,
        diag_url: &str,
        module_source: Rc<str>,
        sheet: &Stylesheet,
        config: HashMap<String, (Value, bool)>,
        config_id: usize,
        pos: Pos,
        sink: &mut Sink<'_>,
        css: bool,
    ) -> Result<(Module, Vec<String>), Error> {
        // Save and reset the per-module environment, then restore on the way out.
        // The module's body runs against its own source file for diagnostics
        // (`module_source` is the loaded text itself, not a display-url lookup).
        // Relative URLs inside the module resolve against ITS directory.
        let module_dir = dirname_of(key);
        let saved_dir = std::mem::replace(&mut self.current_file_dir, module_dir);
        // Track the module's canonical URL in lockstep with its directory, so a
        // relative `@use`/`@import` inside the module resolves against IT.
        let saved_canonical = self.current_canonical.replace(CanonicalUrl::new(key));
        let saved_url = std::mem::replace(&mut self.current_url, diag_url.to_string());
        self.current_url_stamp = 0;
        let saved_source = std::mem::replace(&mut self.current_source, module_source);
        let saved_scopes = std::mem::replace(&mut self.scopes, vec![new_scope()]);
        let saved_var_spans = std::mem::replace(
            &mut self.var_spans,
            if self.options.source_map {
                vec![new_span_scope()]
            } else {
                Vec::new()
            },
        );
        let saved_semi = std::mem::replace(&mut self.scope_semi_global, vec![true]);
        let saved_funcs = std::mem::replace(&mut self.functions, vec![None]);
        let saved_mixins = std::mem::replace(&mut self.mixins, vec![None]);
        let saved_used = std::mem::take(&mut self.used_modules);
        let saved_star = std::mem::take(&mut self.star_modules);
        let saved_used_user = std::mem::take(&mut self.used_user_modules);
        let saved_star_user = std::mem::take(&mut self.star_user_modules);
        let saved_fwd = std::mem::take(&mut self.forwarded);
        let saved_config = std::mem::replace(&mut self.pending_config, config);
        let saved_config_id = std::mem::replace(&mut self.pending_config_id, config_id);
        let saved_consumed = std::mem::take(&mut self.consumed_config);
        let saved_selector = self.current_selector.take();
        let saved_module = std::mem::replace(&mut self.current_module, key.to_string());
        self.loading.push(key.to_string());

        // A `$var: ... !global` anywhere in the module — even in a branch that
        // never evaluates — creates a variable slot defaulting to null, so the
        // module always exposes the same members regardless of how it's
        // evaluated (dart-sass).
        if !css {
            let mut slots: Vec<String> = Vec::new();
            collect_global_var_decls(&sheet.stmts, &mut slots);
            if let Some(g) = self.scopes.first() {
                let mut g = g.borrow_mut();
                for name in slots {
                    g.entry(name).or_insert(Value::Null);
                }
            }
        }

        // A plain-CSS module preserves its nesting (no Sass flattening, `&` kept
        // literal); a Sass module runs the normal evaluator — after its own
        // `@import` deprecations, which dart emits at parse time.
        let result = if css {
            self.exec_css(&sheet.stmts, &[], sink)
        } else {
            self.warn_import_rules(&sheet.stmts);
            self.exec(&sheet.stmts, &[], sink)
        };
        // Render a body error NOW, while the module's url/source and the
        // loader's `@use`/`@forward` frame are still current — after the
        // restores below, finalize would name the caller's file instead.
        let result = result.map_err(|e| self.finalize_error(e));

        self.loading.pop();
        // Capture this module's evaluated members before restoring the caller's
        // environment.
        let vars_scope = std::mem::take(&mut self.scopes)
            .into_iter()
            .next()
            .unwrap_or_else(new_scope);
        // The definition-span frame parallel to `vars_scope` (source-map only).
        let var_spans_scope = std::mem::take(&mut self.var_spans)
            .into_iter()
            .next()
            .unwrap_or_else(new_span_scope);
        // The module's top-level function/mixin frames, shared by Rc with the
        // chains the module's own callables captured. A module always exposes a
        // table even when it declares nothing (its members are looked up
        // through the `Module`, not through a chain), so an empty frame
        // materializes here.
        let functions = std::mem::take(&mut self.functions)
            .into_iter()
            .next()
            .flatten()
            .unwrap_or_else(new_fn_scope);
        let mixins = std::mem::take(&mut self.mixins)
            .into_iter()
            .next()
            .flatten()
            .unwrap_or_else(new_fn_scope);
        let used_user_modules = std::mem::take(&mut self.used_user_modules);
        let star_user_modules = std::mem::take(&mut self.star_user_modules);
        let used_builtin_modules = std::mem::take(&mut self.used_modules);
        let star_builtin_modules = std::mem::take(&mut self.star_modules);
        let forwarded = std::mem::take(&mut self.forwarded);
        // Config keys this module actually consumed (via a `!default` declaration
        // or by passing them through a `@forward ... with`).
        let consumed = std::mem::take(&mut self.consumed_config);

        // Restore the caller's environment.
        self.scopes = saved_scopes;
        self.var_spans = saved_var_spans;
        self.scope_semi_global = saved_semi;
        self.functions = saved_funcs;
        self.mixins = saved_mixins;
        self.used_modules = saved_used;
        self.star_modules = saved_star;
        self.used_user_modules = saved_used_user;
        self.star_user_modules = saved_star_user;
        self.forwarded = saved_fwd;
        self.pending_config = saved_config;
        self.pending_config_id = saved_config_id;
        self.consumed_config = saved_consumed;
        self.current_selector = saved_selector;
        self.current_module = saved_module;
        self.current_file_dir = saved_dir;
        self.current_canonical = saved_canonical;
        self.current_url = saved_url;
        self.current_url_stamp = 0;
        self.current_source = saved_source;

        result?;
        let _ = pos;

        // Merge `@forward`ed members (lower precedence than the module's own).
        // A member the module did NOT shadow keeps its origin binding, so
        // reads/writes/calls route to the defining module.
        let mut var_origins: HashMap<String, (Rc<Module>, String)> = HashMap::default();
        let mut fn_origins: HashMap<String, Rc<Module>> = HashMap::default();
        let mut mixin_origins: HashMap<String, Rc<Module>> = HashMap::default();
        // Assignments write through to the forwarded module even when the
        // module's own same-named variable shadows it for reads.
        let var_write_origins: HashMap<String, (Rc<Module>, String)> = forwarded
            .var_origins
            .iter()
            .map(|(k, (m, o))| (k.clone(), (Rc::clone(m), o.clone())))
            .collect();
        {
            let mut vars = vars_scope.borrow_mut();
            let mut spans = var_spans_scope.borrow_mut();
            for (k, v) in forwarded.vars {
                if let std::collections::hash_map::Entry::Vacant(e) = vars.entry(k.clone()) {
                    e.insert(v);
                    // Carry the forwarded definition span alongside the value.
                    if let Some(sp) = forwarded.var_spans.get(&k) {
                        spans.insert(k.clone(), *sp);
                    }
                    if let Some(o) = forwarded.var_origins.get(&k) {
                        var_origins.insert(k, (Rc::clone(&o.0), o.1.clone()));
                    }
                }
            }
        }
        {
            let mut fns = functions.borrow_mut();
            for (k, v) in forwarded.functions {
                if let std::collections::hash_map::Entry::Vacant(e) = fns.entry(k.clone()) {
                    e.insert(v);
                    if let Some(o) = forwarded.fn_origins.get(&k) {
                        fn_origins.insert(k, Rc::clone(o));
                    }
                }
            }
        }
        {
            let mut mxs = mixins.borrow_mut();
            for (k, v) in forwarded.mixins {
                if let std::collections::hash_map::Entry::Vacant(e) = mxs.entry(k.clone()) {
                    e.insert(v);
                    if let Some(o) = forwarded.mixin_origins.get(&k) {
                        mixin_origins.insert(k, Rc::clone(o));
                    }
                }
            }
        }

        Ok((
            Module {
                vars: vars_scope,
                var_spans: var_spans_scope,
                functions,
                mixins,
                used_user_modules,
                star_user_modules,
                used_builtin_modules,
                star_builtin_modules,
                forwarded_builtins: forwarded.builtins,
                var_origins,
                var_write_origins,
                fn_origins,
                mixin_origins,
                config_origin: std::cell::Cell::new(self.pending_config_id),
                emitted_main: std::cell::Cell::new(false),
                css: Vec::new(),
            },
            consumed,
        ))
    }

    /// Process a `@forward "<url>" [as p-*] [show ..|hide ..] [with (..)];`:
    /// load the target module (emitting its CSS), then re-export its public
    /// members from the module currently being evaluated, applying prefix and
    /// show/hide filters.
    #[allow(clippy::too_many_arguments)]
    pub(super) fn exec_forward(
        &mut self,
        url: &str,
        prefix: Option<&str>,
        show: &Option<Vec<crate::ast::ForwardMember>>,
        hide: &Option<Vec<crate::ast::ForwardMember>>,
        config: &[crate::ast::ConfigEntry],
        pos: Pos,
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // `@forward "sass:<mod>"` re-exports a built-in module. Built-ins can't
        // be configured.
        if let Some(m) = url.strip_prefix("sass:") {
            if !crate::builtins::is_module(m) {
                return Err(Error::at("Can't find stylesheet to import.".to_string(), pos));
            }
            if !config.is_empty() {
                return Err(Error::at(
                    "Built-in modules can't be configured.".to_string(),
                    pos,
                ));
            }
            self.forwarded.builtins.push(ForwardedBuiltin {
                module: m.to_string(),
                // The prefix is stored canonically, like the `show`/`hide`
                // names: `@forward "sass:map" as p_*` answers to `p-get`.
                filters: vec![ForwardFilter {
                    prefix: prefix.map(|p| p.replace('_', "-")).unwrap_or_default(),
                    has_show: show.is_some(),
                    show: member_set(show, false),
                    hide: member_set(hide, false),
                    show_vars: member_set(show, true),
                    hide_vars: member_set(hide, true),
                }],
            });
            return Ok(());
        }

        // Build the configuration passed to the forwarded module. The forward's
        // own `with (...)` entries combine with the configuration of the module
        // currently being evaluated (`pending_config`): a non-`!default` forward
        // entry hard-overrides; a `!default` forward entry yields to a matching
        // downstream override; downstream entries for variables the forward
        // re-exports (visible and matching its `as` prefix) flow through.
        let forward_conf = self.eval_config(config)?;
        let downstream = self.pending_config.clone();
        // Only downstream config for variables this forward actually re-exports
        // flows through. A `show`/`hide` filter or an `as p-*` prefix that hides
        // a variable also makes it unconfigurable through this forward. The map
        // value tracks (upstream-name, downstream-name) so consumption maps back.
        let var_visible = forward_var_visibility(show, hide);
        let pfx_opt = prefix;
        let mut passthrough: HashMap<String, (Value, bool)> = HashMap::default();
        // upstream config key -> downstream key it came from.
        let mut passthrough_origin: HashMap<String, String> = HashMap::default();
        for (dk, dv) in &downstream {
            // Map a downstream (prefixed) name back to the upstream member name.
            let upstream_name = match pfx_opt {
                Some(p) => match dk.strip_prefix(p) {
                    Some(rest) => rest.to_string(),
                    None => continue,
                },
                None => dk.clone(),
            };
            if is_private_member(&upstream_name) || !var_visible(&upstream_name) {
                continue;
            }
            passthrough.insert(upstream_name.clone(), dv.clone());
            passthrough_origin.insert(upstream_name, dk.clone());
        }
        let mut combined: HashMap<String, (Value, bool)> = passthrough.clone();
        // Keys whose downstream entry a `!default` forward override consumed.
        let mut forward_claimed: Vec<String> = Vec::new();
        // The forward's own (non-passthrough) keys, which the forwarded module
        // must consume (else configuring a non-`!default` variable -> error).
        let mut forward_own: Vec<String> = Vec::new();
        // Keys (upstream-side) a non-`!default` forward entry hard-overrode.
        let mut forward_shadowed: Vec<String> = Vec::new();
        for (name, (val, is_default)) in &forward_conf {
            if *is_default {
                // A downstream override wins over a `!default` forward entry —
                // but a `null` downstream value counts as "not configured", so
                // the forward default still applies.
                let downstream_overrides = passthrough
                    .get(name)
                    .is_some_and(|(v, _)| !matches!(v, Value::Null));
                if downstream_overrides {
                    forward_claimed.push(name.clone());
                } else {
                    combined.insert(name.clone(), (val.clone(), false));
                    forward_own.push(name.clone());
                }
            } else {
                if passthrough.contains_key(name) {
                    forward_shadowed.push(name.clone());
                }
                combined.insert(name.clone(), (val.clone(), false));
                forward_own.push(name.clone());
            }
        }

        // A forward with its own `with (...)` entries makes the configuration
        // explicit (already-loaded then errors); pure passthrough keeps the
        // caller's implicit/explicit status.
        let saved_implicit = self.config_is_implicit;
        if !forward_conf.is_empty() {
            self.config_is_implicit = false;
        }
        // A pure passthrough keeps the original configuration identity; a
        // forward with its own `with (...)` starts a new one.
        let combined_id = if forward_conf.is_empty() {
            self.pending_config_id
        } else {
            self.fresh_config_id()
        };
        // Diagnostic `@forward` frame — see the matching `@use` wrap in
        // `exec_use`.
        let saved_member = self.enter_call(pos, 0, "@forward");
        let load_result = self.load_module(url, combined, combined_id, pos, parents, false, sink);
        self.leave_call(saved_member);
        self.config_is_implicit = saved_implicit;
        let (module, consumed) = load_result?;

        // A non-passthrough forward entry the module never consumed configured a
        // variable that isn't `!default` in the forwarded module.
        if forward_own.iter().any(|k| !consumed.contains(k)) {
            return Err(Error::at(
                "This variable was not declared with !default in the @used module.".to_string(),
                pos,
            ));
        }
        // Mark the downstream config keys this forward consumed (passthrough +
        // `!default`-claimed) as consumed in the enclosing module, so they are
        // not reported as unused. A key a non-`!default` forward entry shadowed
        // stays unconsumed (the downstream override is then an error). The
        // consumed keys are upstream-side; map them back to downstream names.
        for up in consumed.iter().chain(forward_claimed.iter()) {
            if forward_shadowed.contains(up) {
                continue;
            }
            if let Some(dk) = passthrough_origin.get(up) {
                if !self.consumed_config.contains(dk) {
                    self.consumed_config.push(dk.clone());
                }
            }
        }

        let show_vars = member_set(show, true);
        let show_names = member_set(show, false);
        let hide_vars = member_set(hide, true);
        let hide_names = member_set(hide, false);
        let has_show = show.is_some();

        // `show`/`hide` names are dash/underscore-insensitive, so compare the
        // canonical (dashed) form.
        let visible_var = |name: &str| -> bool {
            if is_private_member(name) {
                return false;
            }
            let n = normalize_var_name(name);
            if has_show {
                show_vars
                    .as_ref()
                    .map(|s| s.contains(n.as_ref()))
                    .unwrap_or(false)
            } else {
                !hide_vars
                    .as_ref()
                    .map(|s| s.contains(n.as_ref()))
                    .unwrap_or(false)
            }
        };
        let visible_name = |name: &str| -> bool {
            if is_private_member(name) {
                return false;
            }
            let n = normalize_var_name(name);
            if has_show {
                show_names
                    .as_ref()
                    .map(|s| s.contains(n.as_ref()))
                    .unwrap_or(false)
            } else {
                !hide_names
                    .as_ref()
                    .map(|s| s.contains(n.as_ref()))
                    .unwrap_or(false)
            }
        };

        // Two `@forward`s that bring the same member name from DIFFERENT modules
        // conflict — an error reported immediately, even when the member is
        // never used. Re-forwarding the SAME module is idempotent.
        // With a prefix, `show`/`hide` names match the PREFIXED member name.
        // Private members (by their ORIGINAL name) are never re-exported.
        let src: *const Module = Rc::as_ptr(&module);
        let pfx = prefix.unwrap_or("");
        let module_vars: Vec<(String, Value)> = module
            .vars
            .borrow()
            .iter()
            .map(|(k, v)| (k.clone(), v.clone()))
            .collect();
        for (name, val) in &module_vars {
            let key = format!("{pfx}{name}");
            if !is_private_member(name) && visible_var(&key) {
                // The member's true home: follow the module's own origin
                // entry (a re-forward stays bound to the defining module).
                let origin = module
                    .var_origin(name)
                    .unwrap_or_else(|| (Rc::clone(&module), name.clone()));
                // Conflict identity is that home module, so two forwards that
                // both re-export the SAME upstream member don't collide
                // (distributed configuration trees).
                let member_src: *const Module = Rc::as_ptr(&origin.0);
                if let Some(prev) = self.forwarded.var_src.get(&key) {
                    if *prev != member_src {
                        return Err(Error::at(
                            format!("Two forwarded modules both define a variable named ${key}."),
                            pos,
                        ));
                    }
                }
                self.forwarded.vars.insert(key.clone(), val.clone());
                if let Some(sp) = module.var_spans.borrow().get(name) {
                    self.forwarded.var_spans.insert(key.clone(), *sp);
                }
                self.forwarded.var_origins.insert(key.clone(), origin);
                self.forwarded.var_src.insert(key, member_src);
            }
        }
        for (name, f) in module.functions.borrow().iter() {
            let key = format!("{pfx}{name}");
            if !is_private_member(name) && visible_name(&key) {
                let f_src: *const Module = module.fn_origin(name).map(|m| Rc::as_ptr(&m)).unwrap_or(src);
                if let Some(prev) = self.forwarded.fn_src.get(&key) {
                    if *prev != f_src {
                        return Err(Error::at(
                            format!("Two forwarded modules both define a function named {key}."),
                            pos,
                        ));
                    }
                }
                let origin = module.fn_origin(name).unwrap_or_else(|| Rc::clone(&module));
                self.forwarded.functions.insert(key.clone(), Rc::clone(f));
                self.forwarded.fn_origins.insert(key.clone(), origin);
                self.forwarded.fn_src.insert(key, f_src);
            }
        }
        for (name, m) in module.mixins.borrow().iter() {
            let key = format!("{pfx}{name}");
            if !is_private_member(name) && visible_name(&key) {
                let m_src: *const Module = module.mixin_origin(name).map(|m| Rc::as_ptr(&m)).unwrap_or(src);
                if let Some(prev) = self.forwarded.mixin_src.get(&key) {
                    if *prev != m_src {
                        return Err(Error::at(
                            format!("Two forwarded modules both define a mixin named {key}."),
                            pos,
                        ));
                    }
                }
                let origin = module.mixin_origin(name).unwrap_or_else(|| Rc::clone(&module));
                self.forwarded.mixins.insert(key.clone(), Rc::clone(m));
                self.forwarded.mixin_origins.insert(key.clone(), origin);
                self.forwarded.mixin_src.insert(key, m_src);
            }
        }
        // A built-in this module re-exports is re-exported again: its members
        // are as public here as the module's own. Each inner filter is re-based
        // under this forward's prefix and this forward's own `show`/`hide` is
        // appended, so a member has to survive every rule it passed through.
        let outer_prefix = pfx.replace('_', "-");
        for fb in &module.forwarded_builtins {
            let mut filters = fb.filters.clone();
            // Each existing filter keeps the prefix it was DECLARED under — an
            // inner `show p-get` names `p-get`, whatever the outer rule renames
            // it to. Only the filter this `@forward` adds sees the full name.
            filters.push(ForwardFilter {
                prefix: format!("{outer_prefix}{}", fb.prefix()),
                has_show,
                show: show_names.clone(),
                hide: hide_names.clone(),
                show_vars: show_vars.clone(),
                hide_vars: hide_vars.clone(),
            });
            self.forwarded.builtins.push(ForwardedBuiltin {
                module: fb.module.clone(),
                filters,
            });
        }
        Ok(())
    }

    /// Enter the file a callable or content block was written in, for the
    /// duration of its body (dart evaluates a mixin, function, or `@content`
    /// block where it was written: its output maps to that file, and its
    /// diagnostics show that file's name and source). Returns `None` — and
    /// swaps nothing — when the body is in the current file already, so a
    /// same-file call costs a string comparison; pass the result to
    /// [`Self::leave_module_file`].
    pub(super) fn enter_origin_file(
        &mut self,
        origin: Option<&crate::value::MixinOrigin>,
    ) -> Option<SavedModuleFile> {
        let o = origin?;
        if o.diag_url == self.current_url && o.canonical == self.current_path() {
            return None;
        }
        // The source comes from the origin ITSELF (see `MixinOrigin::source`):
        // a display url is a name two files can share, never an identity.
        let dir = (!o.file_dir.is_empty()).then(|| o.file_dir.clone());
        self.current_url_stamp = 0;
        Some((
            std::mem::replace(&mut self.current_url, o.diag_url.clone()),
            std::mem::replace(&mut self.current_source, Rc::clone(&o.source)),
            std::mem::replace(&mut self.current_file_dir, dir),
            self.current_canonical
                .replace(CanonicalUrl::new(o.canonical.clone())),
        ))
    }

    /// Snapshot the current file context as a [`crate::value::MixinOrigin`]:
    /// the defining file of a callable being captured, or of a content block
    /// at its `@include` (so a later `meta.apply` from another file still
    /// resolves its relative loads here). There is always a context to
    /// snapshot — an entry compiled without `Options::url` has an empty
    /// display url and canonical, and a callable it defines must still switch
    /// back to it (so its diagnostics report the entry's empty `url`/`path`)
    /// when invoked from inside a loaded file.
    pub(super) fn current_mixin_origin(&self) -> crate::value::MixinOrigin {
        crate::value::MixinOrigin {
            source: Rc::clone(&self.current_source),
            diag_url: self.current_url.clone(),
            file_dir: self.current_file_dir.clone().unwrap_or_default(),
            canonical: self
                .current_canonical
                .as_ref()
                .map(|c| c.as_str().to_string())
                .unwrap_or_default(),
        }
    }

    /// Restore the file swapped out by [`Self::enter_origin_file`].
    pub(super) fn leave_module_file(&mut self, saved: Option<SavedModuleFile>) {
        if let Some((url, source, dir, canonical)) = saved {
            self.current_url = url;
            self.current_url_stamp = 0;
            self.current_source = source;
            self.current_file_dir = dir;
            self.current_canonical = canonical;
        }
    }

    /// The diagnostic display URL for a `@use`/`@import`ed module, as dart-sass
    /// spells it in stack frames. A filesystem path — the `FsImporter`'s
    /// canonical key is the resolved absolute path — is shown relative to the
    /// current directory (`src/sub/_partial.scss`, whether it was reached
    /// relatively or through a load path), unless that spelling has more
    /// segments than the absolute path, which is then shown as is (dart's
    /// `p.prettyUri`). Any other canonical URL (a custom importer's key) shows
    /// its last segment, falling back to the `@use` url when the key has none.
    pub(super) fn module_diag_url(&self, url: &str, key: &str) -> String {
        // `pretty_name` answers only for a key that names a file absolutely —
        // a path or a `file://` URL. A custom importer's key is neither, and
        // `virtual/foo.scss` must keep showing as `foo.scss` rather than
        // whole.
        if let Some(named) = self.pretty_name(key) {
            return named;
        }
        let base = key.rsplit(['/', '\\']).next().unwrap_or(key);
        if base.is_empty() {
            url.to_string()
        } else {
            base.to_string()
        }
    }

    /// How a stack frame names `key`, when `key` names a file at all.
    ///
    /// A path and a `file://` URL are two spellings the two front ends
    /// arrive with — the binary passes paths, the JS API passes URLs because
    /// its importer bridge resolves relative `@use` against them — and both
    /// must produce the frame dart produces. `None` is "not a file": a
    /// `data:` URL, or a custom importer's key, which keep their own rule.
    pub(crate) fn pretty_name(&self, key: &str) -> Option<String> {
        let cwd = self
            .cwd_cache
            .get_or_init(|| match self.options.cwd {
                Some(c) => Some(std::path::PathBuf::from(c)),
                None => std::env::current_dir().ok(),
            })
            .as_deref()
            .map(|c| c.to_string_lossy().into_owned());
        let cwd = cwd.as_deref();
        // The style the DATA is in, not the one this build was compiled for:
        // the wasm module is always `Posix` by that measure and still has to
        // read `C:\work` on Windows node. See `pathstyle::style_for`.
        crate::pathstyle::pretty_name(crate::pathstyle::style_for(cwd, key), key, cwd)
    }

    /// Install `module`'s environment for a cross-module member invocation,
    /// returning the previous environment to restore with [`leave_module`].
    pub(super) fn enter_module(&mut self, module: &Rc<Module>) -> SavedModuleEnv {
        // The module's global scope is SHARED (the same Rc its callables
        // captured), so writes inside the module are immediately visible to
        // its closures and to later cross-module reads.
        let module_scope = std::rc::Rc::clone(&module.vars);
        let module_spans = if self.options.source_map {
            vec![std::rc::Rc::clone(&module.var_spans)]
        } else {
            Vec::new()
        };
        SavedModuleEnv {
            scopes: std::mem::replace(&mut self.scopes, vec![module_scope]),
            var_spans: std::mem::replace(&mut self.var_spans, module_spans),
            scope_semi_global: std::mem::replace(&mut self.scope_semi_global, vec![true]),
            functions: std::mem::replace(
                &mut self.functions,
                vec![Some(std::rc::Rc::clone(&module.functions))],
            ),
            mixins: std::mem::replace(&mut self.mixins, vec![Some(std::rc::Rc::clone(&module.mixins))]),
            used_modules: std::mem::replace(&mut self.used_modules, module.used_builtin_modules.clone()),
            star_modules: std::mem::replace(&mut self.star_modules, module.star_builtin_modules.clone()),
            used_user_modules: std::mem::replace(
                &mut self.used_user_modules,
                module.used_user_modules.clone(),
            ),
            star_user_modules: std::mem::replace(
                &mut self.star_user_modules,
                module.star_user_modules.clone(),
            ),
            write_back: Some(Rc::clone(module)),
        }
    }

    /// Restore the environment captured by [`enter_module`]. If the saved env
    /// recorded a module, its (possibly mutated) global scope is written back so
    /// a `!global` assignment inside the module persists.
    pub(super) fn leave_module(&mut self, saved: SavedModuleEnv) {
        // The module scope is shared by Rc; writes already land in
        // module.vars without an explicit copy-back.
        let _ = &saved.write_back;
        self.scopes = saved.scopes;
        self.scope_semi_global = saved.scope_semi_global;
        self.functions = saved.functions;
        self.mixins = saved.mixins;
        self.used_modules = saved.used_modules;
        self.star_modules = saved.star_modules;
        self.used_user_modules = saved.used_user_modules;
        self.star_user_modules = saved.star_user_modules;
    }

    /// Resolve a namespaced module variable `ns.$name`. Resolves a user module
    /// first, then a built-in module bound to `ns`.
    pub(super) fn eval_module_var(&self, ns: &str, name: &str, pos: Pos) -> Result<Value, Error> {
        if let Some(module) = self.used_user_modules.get(ns) {
            if is_private_member(name) {
                // Not part of the module's public view: dart reports it missing
                // (a literal `ns.-name` is the parser's privacy error instead).
                return Err(Error::at("Undefined variable.".to_string(), pos));
            }
            if let Some(v) = module.var(name) {
                return Ok(v.without_slash());
            }
            // A built-in this module re-exports brings its variables along
            // (`@forward "sass:math"` re-exports `$pi`).
            if let Some((owner, bare)) = super::meta::resolve_forwarded_builtin_var(module, name) {
                return crate::builtins::module_var(&owner, &bare, pos);
            }
            return Err(Error::at("Undefined variable.".to_string(), pos));
        }
        match self.used_modules.get(ns) {
            Some(module) => crate::builtins::module_var(module, name, pos),
            None => Err(Error::at(
                format!("There is no module with the namespace \"{ns}\"."),
                pos,
            )),
        }
    }
}

/// dart `meta.load-css` re-visits the combined css node-by-node
/// (`_combineCss(module, clone: true).accept(this)`), so each re-visited
/// top-level STYLE RULE re-acquires `isGroupEnd` and the next visible node
/// blank-separates — regardless of how the rules were grouped in the source
/// module. Rebuild the copy's separators to that rule: drop the cloned
/// grouping (blanks + sentinels), walk through module-scope wrappers, leave
/// at-rule bodies untouched (their children keep their own separators).
fn regroup_load_css_copy(nodes: Vec<OutNode>, prev_rule: &mut bool) -> Vec<OutNode> {
    let mut out: Vec<OutNode> = Vec::new();
    for n in nodes {
        match n {
            OutNode::Blank | OutNode::GroupEnd | OutNode::AtRootPackTight => {}
            OutNode::ModuleScope { key, nodes } => {
                let inner = regroup_load_css_copy(nodes, prev_rule);
                out.push(OutNode::ModuleScope { key, nodes: inner });
            }
            other => {
                if *prev_rule {
                    out.push(OutNode::Blank);
                }
                *prev_rule = matches!(other, OutNode::Rule { .. });
                out.push(other);
            }
        }
    }
    out
}
