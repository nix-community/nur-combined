use super::*;
use crate::emit::at_rule_drops_when_empty;

impl<'a> Evaluator<'a> {
    /// Emit a plain-CSS (`.css`) module's statements, preserving nesting (no
    /// Sass flattening), keeping `&` parent references literal, and resolving
    /// only `#{…}` interpolation. The parser has already rejected Sass-only
    /// constructs, so the remaining statements are plain CSS.
    pub(super) fn exec_css(
        &mut self,
        stmts: &[Stmt],
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        let saved = std::mem::replace(&mut self.in_plain_css, true);
        let result = self.exec_css_inner(stmts, parents, sink);
        self.in_plain_css = saved;
        result
    }

    fn exec_css_inner(
        &mut self,
        stmts: &[Stmt],
        parents: &[String],
        sink: &mut Sink<'_>,
    ) -> Result<(), Error> {
        // When the plain-CSS sheet is imported inside a style rule, top-level
        // rules whose selector contains a parent reference `&` keep native
        // CSS-nesting semantics: they are emitted VERBATIM as nested children
        // of one leading parent-selector shell (dart `nestWithin` with
        // `preserveParentSelectors`), while `&`-less rules get the descendant
        // join below.
        if !parents.is_empty() {
            let mut preserved: Vec<OutItem> = Vec::new();
            for stmt in stmts {
                if let Stmt::Rule(r) = stmt {
                    let (own, own_lbs) = self.css_selectors(&r.selector, true)?;
                    if own.iter().any(|s| part_has_parent_ref(s)) {
                        let inner = self.css_body(&r.body)?;
                        if !inner.is_empty() {
                            let lines = self.map_only_lines(r.selector_pos);
                            preserved.push(OutItem::NestedRule {
                                selectors: own,
                                linebreaks: own_lbs,
                                items: inner,
                                lines,
                            });
                        }
                    }
                }
            }
            if !preserved.is_empty() {
                sink.push_at_rule(OutNode::plain_rule(
                    parents.to_vec(),
                    preserved,
                    SrcLines::default(),
                ));
            }
        }
        for stmt in stmts {
            match stmt {
                Stmt::Rule(r) => {
                    // When the plain-CSS sheet is imported inside a style rule,
                    // its outermost rules nest under the Sass parent (descendant
                    // join); inner nesting stays native (dart-sass `nestWithin`
                    // with `preserveParentSelectors`). The sheet's own top level
                    // always rejects leading combinators — also when merged
                    // under a Sass parent (dart checks in the merge branch).
                    let (own, own_lbs) = self.css_selectors(&r.selector, true)?;
                    // A `&`-bearing rule was already emitted in the leading
                    // parent shell above.
                    if !parents.is_empty() && own.iter().any(|s| part_has_parent_ref(s)) {
                        continue;
                    }
                    // Line structure carries through only for the sheet's own
                    // top level; the descendant join under a Sass parent
                    // re-shapes the list.
                    let linebreaks = if parents.is_empty() { own_lbs } else { Vec::new() };
                    let selectors: Vec<String> = if parents.is_empty() {
                        own
                    } else {
                        parents
                            .iter()
                            .flat_map(|p| own.iter().map(move |s| format!("{p} {s}")))
                            .collect()
                    };
                    let (items, bubbled) = self.css_rule_children(&r.body, &selectors)?;
                    // A childless rule is invisible (dart-sass skips it when
                    // serializing) — e.g. when its whole body bubbled out.
                    if !items.is_empty() {
                        sink.push_at_rule(OutNode::Rule {
                            selectors: RuleSelectors::Raw(Rc::new(selectors)),
                            linebreaks,
                            items,
                            lines: self.stamp(SrcLines {
                                file: 0,
                                start: r.brace_line,
                                end: r.end_line,
                                col: 0,
                                start_col: (r.selector_pos.col as u32).saturating_sub(1),
                                map_file: 0,
                                // Source-map: the selector's own line.
                                map_line: r.selector_pos.line as u32,
                            }),
                            extend_base: usize::MAX,
                        });
                    }
                    for node in bubbled {
                        sink.push_at_rule(node);
                    }
                }
                Stmt::Comment(c, lines) => {
                    let text = self.eval_template(c)?;
                    let lines = self.stamp(*lines);
                    sink.push_at_rule(OutNode::Comment(text, lines));
                }
                // A plain CSS file never inlines an `@import`; every entry is
                // emitted verbatim (`@import "x";` / `@import url(x);`), matching
                // dart-sass loading a `.css` stylesheet.
                Stmt::Import { args, .. } => {
                    for arg in args {
                        let (text, pos) = match arg {
                            ImportArg::Css { url, modifiers, pos } => {
                                (self.serialize_css_import(url, modifiers)?, *pos)
                            }
                            ImportArg::Sass { path, pos, .. } => (crate::value::serialize_quoted(path), *pos),
                        };
                        // Source-map: the rule maps to its URL token.
                        let lines = self.map_only_lines(pos);
                        sink.push_at_rule(OutNode::Raw(
                            format!("@import{}{text};", self.at_rule_gap()),
                            lines,
                        ));
                    }
                }
                Stmt::Media { query, body, lines } => {
                    let queries = self.resolve_media_queries(query)?;
                    let prelude = serialize_media_queries(&queries, self.compressed());
                    let out_body = self.css_at_body(body, false)?;
                    if !out_body.is_empty() {
                        let lines = self.stamp(*lines);
                        sink.push_at_rule(OutNode::AtRule {
                            name: "media".to_string(),
                            prelude,
                            body: out_body,
                            has_block: true,
                            kind: AtRuleKind::Conditional,
                            lines,
                        });
                    }
                }
                Stmt::Supports {
                    condition,
                    body,
                    lines,
                } => {
                    let prelude = self.serialize_supports_condition(condition)?;
                    let out_body = self.css_at_body(body, false)?;
                    if !out_body.is_empty() {
                        sink.push_at_rule(OutNode::AtRule {
                            name: "supports".to_string(),
                            prelude,
                            body: out_body,
                            has_block: true,
                            kind: AtRuleKind::Conditional,
                            lines: self.stamp(*lines),
                        });
                    }
                }
                Stmt::AtRule {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    // dart-sass never copies a loaded file's top-level
                    // `@charset`: the output's own is re-derived from its
                    // content. One nested in an at-rule or a style rule is
                    // kept verbatim, as dart keeps it.
                    if body.is_none() && name.eq_ignore_ascii_case("charset") {
                        continue;
                    }
                    let prelude_s = self.eval_template(prelude)?.trim().to_string();
                    let lines = self.stamp(*lines);
                    match body {
                        None => sink.push_at_rule(OutNode::AtRule {
                            name: name.clone(),
                            prelude: prelude_s,
                            body: Vec::new(),
                            has_block: false,
                            kind: AtRuleKind::Generic,
                            lines,
                        }),
                        Some(b) => {
                            let out_body = self.css_at_body(b, false)?;
                            sink.push_at_rule(OutNode::AtRule {
                                name: name.clone(),
                                prelude: prelude_s,
                                body: out_body,
                                has_block: true,
                                kind: AtRuleKind::Generic,
                                lines,
                            });
                        }
                    }
                }
                Stmt::Keyframes {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    let prelude_s = self.eval_template(prelude)?.trim().to_string();
                    let out_body = self.css_at_body(body, true)?;
                    let lines = self.stamp(*lines);
                    sink.push_at_rule(OutNode::AtRule {
                        name: name.clone(),
                        prelude: prelude_s,
                        body: out_body,
                        has_block: true,
                        kind: AtRuleKind::Generic,
                        lines,
                    });
                }
                // A plain-CSS custom `@function --x` is emitted verbatim, same
                // as in an SCSS sheet.
                Stmt::CssCustomAtRule { name, prelude, body } => {
                    self.eval_css_custom_at_rule(name, prelude, body, sink)?;
                }
                _ => {}
            }
        }
        Ok(())
    }

    /// Build the body of a top-level plain-CSS at-rule: style rules (with their
    /// own first-level bubbling), bare declarations, comments, and nested
    /// at-rules.
    fn css_at_body(&mut self, stmts: &[Stmt], frames: bool) -> Result<Vec<OutNode>, Error> {
        if frames {
            check_keyframes_body(stmts)?;
        }
        let mut out: Vec<OutNode> = Vec::new();
        for stmt in stmts {
            match stmt {
                Stmt::Rule(r) => {
                    let (selectors, linebreaks) = if frames {
                        (self.css_frame_selectors(&r.selector)?, Vec::new())
                    } else {
                        self.css_selectors(&r.selector, false)?
                    };
                    // Inside `@keyframes` this rule is a FRAME, and nothing in
                    // it bubbles: dart keeps a nested at-rule where it is
                    // (`@keyframes k {from {@foo {a: b}}}`), while hoisting it
                    // would move it out of the frame and wrap the frame
                    // selector around its body. A frame body is therefore read
                    // the way any deeper level is, with no hoisting.
                    let (items, bubbled) = if frames {
                        (self.css_body(&r.body)?, Vec::new())
                    } else {
                        self.css_rule_children(&r.body, &selectors)?
                    };
                    if !items.is_empty() {
                        out.push(OutNode::Rule {
                            selectors: RuleSelectors::Raw(Rc::new(selectors)),
                            linebreaks,
                            items,
                            lines: self.stamp(SrcLines {
                                file: 0,
                                start: r.brace_line,
                                end: r.end_line,
                                col: 0,
                                start_col: (r.selector_pos.col as u32).saturating_sub(1),
                                map_file: 0,
                                // Source-map: the selector's own line.
                                map_line: r.selector_pos.line as u32,
                            }),
                            extend_base: usize::MAX,
                        });
                    }
                    out.extend(bubbled);
                }
                Stmt::Decl(d) => {
                    let prop = trim_shared(self.eval_template_shared(&d.property)?);
                    let value = self.eval_expr(&d.value)?.to_css(self.compressed());
                    // Plain CSS has no variables, so the value node is always
                    // the value's own text (dart's `_expressionNode` fallback).
                    let value_span = self.span_at(d.value_pos);
                    out.push(OutNode::AtDecl {
                        prop,
                        value,
                        important: d.important,
                        custom: false,
                        lines: self.stamp(SrcLines {
                            file: 0,
                            start: d.pos.line as u32,
                            end: d.end_line,
                            col: 0,
                            start_col: (d.pos.col as u32).saturating_sub(1),
                            map_file: 0,
                            map_line: 0,
                        }),
                        value_span,
                    });
                }
                Stmt::CustomDecl(d) => {
                    let prop = trim_shared(self.eval_template_shared(&d.property)?);
                    let value = self.eval_template(&d.value)?;
                    let value_span = self.span_at(d.value_pos);
                    out.push(OutNode::AtDecl {
                        prop,
                        value,
                        important: false,
                        custom: true,
                        lines: self.stamp(SrcLines {
                            file: 0,
                            start: d.pos.line as u32,
                            end: d.end_line,
                            col: 0,
                            start_col: (d.pos.col as u32).saturating_sub(1),
                            map_file: 0,
                            map_line: 0,
                        }),
                        value_span,
                    });
                }
                Stmt::Comment(c, lines) => {
                    let text = self.eval_template(c)?;
                    let lines = self.stamp(*lines);
                    out.push(OutNode::Comment(text, lines));
                }
                Stmt::Media { query, body, lines } => {
                    let queries = self.resolve_media_queries(query)?;
                    let prelude = serialize_media_queries(&queries, self.compressed());
                    let inner = self.css_at_body(body, false)?;
                    if !inner.is_empty() {
                        let lines = self.stamp(*lines);
                        out.push(OutNode::AtRule {
                            name: "media".to_string(),
                            prelude,
                            body: inner,
                            has_block: true,
                            kind: AtRuleKind::Conditional,
                            lines,
                        });
                    }
                }
                Stmt::Supports {
                    condition,
                    body,
                    lines,
                } => {
                    let prelude = self.serialize_supports_condition(condition)?;
                    let inner = self.css_at_body(body, false)?;
                    if !inner.is_empty() {
                        out.push(OutNode::AtRule {
                            name: "supports".to_string(),
                            prelude,
                            body: inner,
                            has_block: true,
                            kind: AtRuleKind::Conditional,
                            lines: self.stamp(*lines),
                        });
                    }
                }
                Stmt::AtRule {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    let prelude_s = self.eval_template(prelude)?.trim().to_string();
                    let lines = self.stamp(*lines);
                    match body {
                        None => out.push(OutNode::AtRule {
                            name: name.clone(),
                            prelude: prelude_s,
                            body: Vec::new(),
                            has_block: false,
                            kind: AtRuleKind::Generic,
                            lines,
                        }),
                        Some(b) => {
                            let inner = self.css_at_body(b, false)?;
                            out.push(OutNode::AtRule {
                                name: name.clone(),
                                prelude: prelude_s,
                                body: inner,
                                has_block: true,
                                kind: AtRuleKind::Generic,
                                lines,
                            });
                        }
                    }
                }
                Stmt::Import { args, .. } => {
                    for arg in args {
                        let (text, pos) = match arg {
                            ImportArg::Css { url, modifiers, pos } => {
                                (self.serialize_css_import(url, modifiers)?, *pos)
                            }
                            ImportArg::Sass { path, pos, .. } => (crate::value::serialize_quoted(path), *pos),
                        };
                        let lines = self.map_only_lines(pos);
                        out.push(OutNode::Raw(
                            format!("@import{}{text};", self.at_rule_gap()),
                            lines,
                        ));
                    }
                }
                // `@keyframes` and a plain-CSS custom `@function` have
                // statements of their own, so they need arms of their own here:
                // falling through to `_` dropped them, and with them everything
                // they held (`@media screen {@keyframes k {from {a: b}}}` came
                // out empty, which then took the `@media` with it).
                Stmt::Keyframes {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    let prelude_s = self.eval_template(prelude)?.trim().to_string();
                    let out_body = self.css_at_body(body, true)?;
                    let lines = self.stamp(*lines);
                    out.push(OutNode::AtRule {
                        name: name.clone(),
                        prelude: prelude_s,
                        body: out_body,
                        has_block: true,
                        kind: AtRuleKind::Generic,
                        lines,
                    });
                }
                Stmt::CssCustomAtRule { name, prelude, body } => {
                    let mut sink = Sink::AtRoot {
                        body: &mut out,
                        group_ends: false,
                    };
                    self.eval_css_custom_at_rule(name, prelude, body, &mut sink)?;
                }
                _ => {}
            }
        }
        Ok(out)
    }

    /// Build the children of a *top-level* plain-CSS style rule: declarations
    /// and nested rules stay in the block; a block at-rule (`@media` etc.)
    /// bubbles out wrapping a copy of the parent rule (dart-sass's standard
    /// at-rule bubbling — `a {@media b {c: d}}` → `@media b { a { c: d } }`).
    /// Deeper levels never bubble (see [`Evaluator::css_body`]).
    #[allow(clippy::type_complexity)]
    fn css_rule_children(
        &mut self,
        stmts: &[Stmt],
        parent_selectors: &[String],
    ) -> Result<(Vec<OutItem>, Vec<OutNode>), Error> {
        let mut items = Vec::new();
        let mut bubbled: Vec<OutNode> = Vec::new();
        let bubble = |name: &str,
                      kind: AtRuleKind,
                      prelude: String,
                      inner: Vec<OutItem>,
                      bubbled: &mut Vec<OutNode>| {
            // Nothing to wrap means no copy of the parent rule, but the at-rule
            // itself still survives unless it is one of the two that go away
            // when their block is empty: `.a {@foo {}}` is `@foo {}`, while
            // `.a {@media b {}}` is nothing (see `at_rule_drops_when_empty`).
            let body = if inner.is_empty() {
                if at_rule_drops_when_empty(kind) {
                    return;
                }
                Vec::new()
            } else {
                vec![OutNode::plain_rule(
                    parent_selectors.to_vec(),
                    inner,
                    SrcLines::default(),
                )]
            };
            bubbled.push(OutNode::AtRule {
                name: name.to_string(),
                prelude,
                body,
                has_block: true,
                kind,
                lines: SrcLines::default(),
            });
        };
        for stmt in stmts {
            match stmt {
                Stmt::Media {
                    query,
                    body,
                    lines: _,
                } => {
                    let queries = self.resolve_media_queries(query)?;
                    let prelude = serialize_media_queries(&queries, self.compressed());
                    let inner = self.css_body(body)?;
                    bubble("media", AtRuleKind::Conditional, prelude, inner, &mut bubbled);
                }
                Stmt::Supports { condition, body, .. } => {
                    let prelude = self.serialize_supports_condition(condition)?;
                    let inner = self.css_body(body)?;
                    bubble("supports", AtRuleKind::Conditional, prelude, inner, &mut bubbled);
                }
                Stmt::AtRule {
                    name,
                    prelude,
                    body: Some(b),
                    ..
                } => {
                    let prelude_s = self.eval_template(prelude)?.trim().to_string();
                    let inner = self.css_body(b)?;
                    bubble(name, AtRuleKind::Generic, prelude_s, inner, &mut bubbled);
                }
                // `@keyframes` hoists out like any other block at-rule, but
                // takes no copy of the parent selectors with it: its block holds
                // keyframe selectors, not declarations. Dropping it here lost
                // the whole rule.
                Stmt::Keyframes {
                    name,
                    prelude,
                    body,
                    lines,
                } => {
                    let prelude_s = self.eval_template(prelude)?.trim().to_string();
                    let out_body = self.css_at_body(body, true)?;
                    let lines = self.stamp(*lines);
                    bubbled.push(OutNode::AtRule {
                        name: name.clone(),
                        prelude: prelude_s,
                        body: out_body,
                        has_block: true,
                        kind: AtRuleKind::Generic,
                        lines,
                    });
                }
                // A custom `@function` bubbles like the at-rules above, parent
                // copy included: `.a {@function --f(--a) {result: 1}}` is
                // `@function --f(--a) {.a {result: 1 }}`. Its body holds
                // declarations rather than statements, so it is built here from
                // the same `(property, value)` pairs the at-root path uses.
                Stmt::CssCustomAtRule { name, prelude, body } => {
                    let prelude_s = self.eval_template(prelude)?;
                    let inner = self.css_custom_decl_items(body)?;
                    bubble(name, AtRuleKind::Generic, prelude_s, inner, &mut bubbled);
                }
                other => self.css_body_stmt(other, &mut items)?,
            }
        }
        Ok((items, bubbled))
    }

    /// Build a plain-CSS custom at-rule's body as nested output items: each
    /// declaration is a custom property, which emits its value verbatim right
    /// after the colon, exactly as [`Self::eval_css_custom_at_rule`] writes it.
    fn css_custom_decl_items(&mut self, body: &[CssCustomItem]) -> Result<Vec<OutItem>, Error> {
        Ok(self
            .css_custom_at_rule_decls(body)?
            .into_iter()
            .map(|(prop, value)| OutItem::Decl {
                prop: prop.into(),
                value,
                important: false,
                custom: true,
                lines: SrcLines::default(),
                value_span: VarSpan::default(),
            })
            .collect())
    }

    /// Resolve a plain-CSS selector to its comma-separated parts, keeping `&`
    /// and combinators verbatim (no parent resolution), and rejecting the
    /// Sass-only selector forms that plain CSS forbids. The parts come back
    /// re-serialized the way dart's parser emits them (identifier attribute
    /// values lose their quotes, whitespace collapses), along with the
    /// source's per-complex line-break flags (`a,\nb` keeps its lines).
    fn css_selectors(
        &mut self,
        sel: &[crate::ast::TplPiece],
        top_level: bool,
    ) -> Result<(Vec<String>, Vec<bool>), Error> {
        let s = self.eval_template(sel)?;
        let parts: Vec<String> = split_commas(&s)
            .iter()
            .map(|p| p.trim().to_string())
            .filter(|p| !p.is_empty())
            .collect();
        for p in &parts {
            validate_plain_css_selector(p, top_level)?;
        }
        let normalized: Vec<String> = parts.iter().map(|p| normalize_selector(p)).collect();
        let linebreaks = if s.contains('\n') {
            comma_linebreaks(&s, false)
        } else {
            Vec::new()
        };
        Ok((normalized, linebreaks))
    }

    /// Convert a `@keyframes` frame's selector list. A frame selector is a list
    /// of keyframe STOPS (`from`, `50%`), not of CSS selectors, and dart
    /// re-serializes the stops joined with `", "`: the author's line breaks do
    /// not survive it, none of the selector normalization applies (`+5%` is a
    /// stop, not a sibling combinator), and `from`/`to` and a percentage's
    /// exponent marker come back lowercased.
    fn css_frame_selectors(&mut self, sel: &[crate::ast::TplPiece]) -> Result<Vec<String>, Error> {
        let s = self.eval_template(sel)?;
        let mut stops = Vec::new();
        for part in split_commas(&s).iter() {
            let part = part.trim();
            if part.is_empty() {
                continue;
            }
            // The stop grammar is `from` | `to` | `<number>%`, stricter than
            // this: dart rejects `foo`, `&` and `50 %` in a frame, where the
            // checks below only catch the Sass-only selector forms. The
            // remaining strictness gap is recorded in the plan.
            validate_plain_css_selector(part, false)?;
            stops.push(normalize_keyframe_selector(part));
        }
        Ok(stops)
    }

    /// Build the body of a `@keyframes` below the bubbling level: as
    /// [`Evaluator::css_body`], except that a rule at this level is a FRAME —
    /// its selector is a stop list, and its own body nests natively.
    fn css_frames_body(&mut self, stmts: &[Stmt]) -> Result<Vec<OutItem>, Error> {
        check_keyframes_body(stmts)?;
        let mut items = Vec::new();
        for stmt in stmts {
            match stmt {
                Stmt::Rule(r) => {
                    let selectors = self.css_frame_selectors(&r.selector)?;
                    let inner = self.css_body(&r.body)?;
                    // An (recursively) empty frame is invisible, like any rule.
                    if !inner.is_empty() {
                        let lines = self.map_only_lines(r.selector_pos);
                        items.push(OutItem::NestedRule {
                            selectors,
                            linebreaks: Vec::new(),
                            items: inner,
                            lines,
                        });
                    }
                }
                other => self.css_body_stmt(other, &mut items)?,
            }
        }
        Ok(items)
    }

    /// Build a plain-CSS rule body below the first nesting level: declarations
    /// and nested style rules with nesting preserved (`OutItem::NestedRule`),
    /// and block at-rules kept in place (`OutItem::NestedAtRule`) — dart-sass
    /// `_hasCssNesting` skips bubbling once nesting is already native.
    fn css_body(&mut self, stmts: &[Stmt]) -> Result<Vec<OutItem>, Error> {
        let mut items = Vec::new();
        for stmt in stmts {
            self.css_body_stmt(stmt, &mut items)?;
        }
        Ok(items)
    }

    /// Process one plain-CSS statement into rule-body items (the shared body of
    /// [`Evaluator::css_body`] and the non-bubbling arm of
    /// [`Evaluator::css_rule_children`]).
    fn css_body_stmt(&mut self, stmt: &Stmt, items: &mut Vec<OutItem>) -> Result<(), Error> {
        match stmt {
            Stmt::Decl(d) => {
                let prop = trim_shared(self.eval_template_shared(&d.property)?);
                let value = self.eval_expr(&d.value)?.to_css(self.compressed());
                // Plain CSS has no variables, so the value node is always the
                // value's own text (dart's `_expressionNode` fallback).
                let value_span = self.span_at(d.value_pos);
                items.push(OutItem::Decl {
                    prop,
                    value,
                    important: d.important,
                    custom: false,
                    lines: self.stamp(SrcLines {
                        file: 0,
                        start: d.pos.line as u32,
                        end: d.end_line,
                        col: 0,
                        start_col: (d.pos.col as u32).saturating_sub(1),
                        map_file: 0,
                        map_line: 0,
                    }),
                    value_span,
                });
            }
            Stmt::CustomDecl(d) => {
                let prop = trim_shared(self.eval_template_shared(&d.property)?);
                let value = self.eval_template(&d.value)?;
                let value_span = self.span_at(d.value_pos);
                items.push(OutItem::Decl {
                    prop,
                    value,
                    important: false,
                    custom: true,
                    lines: self.stamp(SrcLines {
                        file: 0,
                        start: d.pos.line as u32,
                        end: d.end_line,
                        col: 0,
                        start_col: (d.pos.col as u32).saturating_sub(1),
                        map_file: 0,
                        map_line: 0,
                    }),
                    value_span,
                });
            }
            Stmt::Rule(r) => {
                let (selectors, linebreaks) = self.css_selectors(&r.selector, false)?;
                let inner = self.css_body(&r.body)?;
                // An (recursively) empty nested rule is invisible (dart-sass
                // skips childless rules when serializing).
                if !inner.is_empty() {
                    let lines = self.map_only_lines(r.selector_pos);
                    items.push(OutItem::NestedRule {
                        selectors,
                        linebreaks,
                        items: inner,
                        lines,
                    });
                }
            }
            Stmt::Comment(c, lines) => {
                let text = self.eval_template(c)?;
                let lines = self.stamp(*lines);
                items.push(OutItem::Comment(text, lines));
            }
            // A nested `@import` inside a plain-CSS rule is preserved
            // verbatim, like a top-level one (see `exec_css`).
            Stmt::Import { args, .. } => {
                for arg in args {
                    let (prelude, pos) = match arg {
                        ImportArg::Css { url, modifiers, pos } => {
                            (self.serialize_css_import(url, modifiers)?, *pos)
                        }
                        ImportArg::Sass { path, pos, .. } => (crate::value::serialize_quoted(path), *pos),
                    };
                    let lines = self.map_only_lines(pos);
                    items.push(OutItem::ChildlessAtRule {
                        // A real CSS `@import`, whatever the parser made of its
                        // url — compressed output spells it with no gap.
                        css_import: true,
                        name: "import".to_string(),
                        prelude,
                        lines,
                    });
                }
            }
            Stmt::Media { query, body, lines } => {
                let queries = self.resolve_media_queries(query)?;
                let prelude = serialize_media_queries(&queries, self.compressed());
                let inner = self.css_body(body)?;
                if !inner.is_empty() {
                    let lines = self.stamp(*lines);
                    items.push(OutItem::NestedAtRule {
                        name: "media".to_string(),
                        prelude,
                        items: inner,
                        kind: AtRuleKind::Conditional,
                        lines,
                    });
                }
            }
            Stmt::Supports {
                condition,
                body,
                lines,
                ..
            } => {
                let prelude = self.serialize_supports_condition(condition)?;
                let inner = self.css_body(body)?;
                if !inner.is_empty() {
                    let lines = self.stamp(*lines);
                    items.push(OutItem::NestedAtRule {
                        name: "supports".to_string(),
                        prelude,
                        items: inner,
                        kind: AtRuleKind::Conditional,
                        lines,
                    });
                }
            }
            Stmt::AtRule {
                name,
                prelude,
                body,
                lines,
            } => {
                let prelude_s = self.eval_template(prelude)?.trim().to_string();
                match body {
                    None => {
                        let lines = self.stamp(*lines);
                        items.push(OutItem::ChildlessAtRule {
                            css_import: false,
                            name: name.clone(),
                            prelude: prelude_s,
                            lines,
                        });
                    }
                    Some(b) => {
                        let inner = self.css_body(b)?;
                        // An empty block below the bubbling level stays where it
                        // is, on the same terms as above: this is a generic
                        // at-rule, and only a conditional group rule goes away.
                        let lines = self.stamp(*lines);
                        items.push(OutItem::NestedAtRule {
                            name: name.clone(),
                            prelude: prelude_s,
                            items: inner,
                            kind: AtRuleKind::Generic,
                            lines,
                        });
                    }
                }
            }
            // Below the bubbling level it stays put, like any other at-rule.
            Stmt::Keyframes {
                name,
                prelude,
                body,
                lines,
            } => {
                let prelude_s = self.eval_template(prelude)?.trim().to_string();
                let inner = self.css_frames_body(body)?;
                let lines = self.stamp(*lines);
                items.push(OutItem::NestedAtRule {
                    name: name.clone(),
                    prelude: prelude_s,
                    items: inner,
                    kind: AtRuleKind::Generic,
                    lines,
                });
            }
            // Below the bubbling level it stays put, with no copy of the
            // parent selectors: `.a {.b {@function --f(--a) {result: 1}}}` is
            // `.a {.b {@function --f(--a) {result: 1 }}}`.
            Stmt::CssCustomAtRule { name, prelude, body } => {
                let prelude_s = self.eval_template(prelude)?;
                let inner = self.css_custom_decl_items(body)?;
                items.push(OutItem::NestedAtRule {
                    name: name.clone(),
                    prelude: prelude_s,
                    items: inner,
                    kind: AtRuleKind::Generic,
                    lines: SrcLines::default(),
                });
            }
            _ => {}
        }
        Ok(())
    }
}

/// A style rule inside a keyframe block is invalid, and dart rejects it in plain
/// CSS exactly as it does in SCSS: `@keyframes k {from {.x {a: b}}}` is an
/// error, not output. A frame may hold declarations, comments and at-rules --
/// nothing that needs a selector of its own. Both evaluators check here, so the
/// message and the span they blame cannot drift apart.
pub(super) fn check_keyframes_body(body: &[Stmt]) -> Result<(), Error> {
    for stmt in body {
        if let Stmt::Rule(frame) = stmt {
            for inner in &frame.body {
                if let Stmt::Rule(inner) = inner {
                    return Err(Error::at(
                        "Style rules may not be used within keyframe blocks.",
                        inner.selector_pos,
                    ));
                }
            }
        }
    }
    Ok(())
}
