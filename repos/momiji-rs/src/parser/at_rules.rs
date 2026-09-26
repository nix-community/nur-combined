//! At-rule parsing: the largest cluster — `parse_at_rule` dispatch plus
//! `@use`/`@forward`/`@import`/`@include`, `@supports`, `@media`,
//! `@function`/`@mixin` definitions, `@at-root`, keyframes, generic and
//! interpolated at-rules, and their helpers. Extracted verbatim from [`super`].

use super::*;

/// Source-map: stamp the `@` keyword's position onto the lines-carrying
/// at-rule variants — its 0-based column, and its line, which is not the brace
/// line when the prelude spans several lines (dart maps the rule's span
/// start). Purely additive: `start_col`/`map_line` are read only by source-map
/// generation, never by the serializer.
fn stamp_at_keyword(stmt: &mut Stmt, pos: Pos) {
    if let Stmt::AtRule { lines, .. }
    | Stmt::InterpAtRule { lines, .. }
    | Stmt::Media { lines, .. }
    | Stmt::Supports { lines, .. }
    | Stmt::Keyframes { lines, .. } = stmt
    {
        lines.start_col = (pos.col as u32).saturating_sub(1);
        lines.map_line = pos.line as u32;
    }
}

impl Parser {
    pub(super) fn parse_at_rule(&mut self) -> Result<Stmt, Error> {
        let pos = self.sc.position();
        // Mark at the `@` so span-carrying at-rules (`@error`, `@include`) can
        // measure their byte length for the diagnostic caret.
        let start_mark = self.sc.mark();
        self.sc.bump(); // '@'
                        // An interpolated NAME makes this a generic (unknown) at-rule with no
                        // Sass parse-time behavior (`@#{"media"} …`).
        if self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{') {
            let mut stmt = self.parse_interp_at_rule(Vec::new())?;
            stamp_at_keyword(&mut stmt, pos);
            return Ok(stmt);
        }
        let name = self.read_ident_name()?;
        if self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{') {
            let mut stmt = self.parse_interp_at_rule(vec![TplPiece::Lit(name.into())])?;
            stamp_at_keyword(&mut stmt, pos);
            return Ok(stmt);
        }
        // In plain CSS the Sass control/definition at-rules are rejected; only
        // genuine CSS at-rules (`@media`, `@supports`, `@font-face`,
        // `@keyframes`, `@import`, `@charset`, `@page`, and unknown vendor
        // at-rules emitted verbatim) are allowed.
        if self.plain_css {
            // `@function --x`/`@mixin --x` are plain-CSS custom callables (the
            // `--` prefix), which CSS allows; a bare `@function`/`@mixin` is the
            // Sass definition and is rejected like the other control at-rules.
            let sass_callable =
                matches!(name.as_str(), "function" | "mixin") && !self.peek_callable_name_is_custom();
            if sass_callable
                || matches!(
                    name.as_str(),
                    "if" | "else"
                        | "each"
                        | "for"
                        | "while"
                        | "include"
                        | "content"
                        | "return"
                        | "warn"
                        | "debug"
                        | "error"
                        | "extend"
                        | "at-root"
                        | "use"
                        | "forward"
                )
            {
                return Err(Error::at("This at-rule isn't allowed in plain CSS.", pos));
            }
        }
        let stmt = match name.as_str() {
            "import" => self.parse_import(pos, start_mark),
            "if" => self.parse_if(),
            // A stray `@else` (one not consumed as part of an `@if` chain by
            // `parse_if`) is never valid on its own.
            "else" => Err(Error::at("This at-rule is not allowed here.", pos)),
            "for" => self.parse_for(),
            "each" => self.parse_each(),
            "while" => self.parse_while(),
            // Lowercase `@function`/`@mixin` define Sass callables — UNLESS the
            // name begins with `--`, which dart-sass reserves for plain CSS
            // custom functions/mixins (a function then passes through verbatim;
            // a mixin is a hard error).
            "function" if self.peek_callable_name_is_custom() => self.parse_css_custom_callable(name),
            "mixin" if self.peek_callable_name_is_custom() => Err(Error::at(
                "Sass @mixin names beginning with -- are forbidden for \
                     forward-compatibility with plain CSS mixins.",
                pos,
            )),
            "function" => self.parse_callable_def(true),
            "mixin" => self.parse_callable_def(false),
            "return" => self.parse_return(),
            "include" => self.parse_include(pos, start_mark),
            "content" => {
                self.skip_ws_inline();
                let args = if self.sc.peek() == Some('(') {
                    self.sc.bump();
                    self.parse_args_after_paren()?
                } else {
                    Vec::new()
                };
                self.skip_ws_inline();
                self.sc.eat(';');
                Ok(Stmt::Content { args, pos })
            }
            "warn" => self.parse_message(MessageKind::Warn, pos, start_mark),
            "debug" => self.parse_message(MessageKind::Debug, pos, start_mark),
            "error" => self.parse_message(MessageKind::Error, pos, start_mark),
            "at-root" => self.parse_at_root(),
            "media" => self.parse_media(),
            "keyframes" | "-webkit-keyframes" | "-moz-keyframes" | "-o-keyframes" | "-ms-keyframes" => {
                self.parse_keyframes(name)
            }
            "extend" => self.parse_extend(pos),
            // `@charset` takes exactly one quoted string. A non-string (or
            // missing) argument is dart's "Expected string."; anything after
            // the string is left for the next statement (so `@charset "a" "b"`
            // fails as a malformed following rule, `expected "{".`). The value
            // itself is not emitted — the serializer re-derives `@charset` from
            // the output's own non-ASCII content.
            "charset" => {
                self.skip_ws_inline();
                let line = self.sc.position().line as u32;
                if !matches!(self.sc.peek(), Some('"' | '\'')) {
                    return Err(Error::at("Expected string.", self.sc.position()));
                }
                let mut prelude = vec![TplPiece::Lit("\"".into())];
                prelude.extend(self.parse_quoted_string()?);
                prelude.push(TplPiece::Lit("\"".into()));
                self.skip_ws_inline();
                self.sc.eat(';');
                Ok(Stmt::AtRule {
                    name,
                    prelude,
                    body: None,
                    lines: SrcLines {
                        file: 0,
                        start: line,
                        end: line,
                        col: 0,
                        start_col: 0,
                        map_file: 0,
                        map_line: 0,
                    },
                })
            }
            "supports" => self.parse_supports(),
            "use" => self.parse_use(pos, start_mark),
            // @forward is parked for the module-system epic.
            "forward" => self.parse_forward(pos, start_mark),
            // A non-lowercase spelling of `@function`/`@mixin` (e.g. `@FUNCTION`,
            // `@Mixin`) is never a Sass definition; dart-sass parses it as a
            // plain CSS custom function/mixin (verbatim body), regardless of
            // whether the name begins with `--`.
            _ if name.eq_ignore_ascii_case("function") || name.eq_ignore_ascii_case("mixin") => {
                self.parse_css_custom_callable(name)
            }
            _ => self.parse_generic_at_rule(name),
        };
        let mut stmt = stmt?;
        stamp_at_keyword(&mut stmt, pos);
        Ok(stmt)
    }

    /// Parse `@import <arg> [, <arg>]* ;`. Each argument is either a Sass
    /// import (a bare quoted string with no modifiers and a non-CSS URL,
    /// which is inlined) or a plain CSS `@import` (a `url(...)` URL, a `.css`/
    /// protocol URL, or a URL followed by media-query/`supports()` modifiers,
    /// which is emitted verbatim).
    fn parse_import(&mut self, pos: Pos, start_mark: Mark) -> Result<Stmt, Error> {
        let mut args = Vec::new();
        // Byte length of the rule from `@import` up to (not including) the
        // `;` — trailing whitespace included, which is how dart spans a
        // misplaced `@import "x"   ;` (verified against 1.103.1).
        let mut length;
        loop {
            self.skip_ws_trivia();
            let arg = self.parse_import_arg(pos)?;
            args.push(arg);
            length = self.sc.byte_len_from(start_mark);
            self.skip_ws_trivia();
            if self.sc.peek() == Some(',') {
                // Plain CSS `@import` takes a single URL — a comma-separated
                // list is a Sass-only feature.
                if self.plain_css {
                    return Err(Error::at("expected \";\".", self.sc.position()));
                }
                self.sc.bump();
                continue;
            }
            break;
        }
        self.skip_ws_trivia();
        // After the last argument only `;`, `}`, or EOF may follow; anything
        // else (e.g. a supports()/identifier after a media query list, the
        // `wrong_order` cases) is a syntax error like dart-sass.
        match self.sc.peek() {
            None | Some(';') | Some('}') => {}
            _ => return Err(Error::at("expected \";\".", self.sc.position())),
        }
        self.sc.eat(';');
        Ok(Stmt::Import { args, pos, length })
    }

    /// Parse `@use "<url>" [as <namespace>|as *];`. The URL is a quoted string
    /// without interpolation; an explicit `as ns` / `as *` overrides the
    /// default namespace (the segment after the last `/`, or after `sass:`).
    fn parse_use(&mut self, pos: Pos, start_mark: Mark) -> Result<Stmt, Error> {
        if self.block_depth > 0 {
            return Err(Error::at("This at-rule is not allowed here.", pos));
        }
        // dart reads the whole rule before complaining about its placement, and
        // carets all of it — so the check waits for the length.
        let misplaced = self.seen_non_module_stmt;
        self.skip_ws_trivia();
        let url = self.parse_module_url(pos)?;
        self.skip_ws_trivia();
        let mut namespace = None;
        let mut star = false;
        if self.try_keyword("as") {
            self.skip_ws_inline();
            if self.sc.eat('*') {
                star = true;
            } else {
                namespace = Some(self.read_namespace_ident()?);
            }
            self.skip_ws_trivia();
        }
        // `with (...)` overrides the module's `!default` variables.
        let mut config = Vec::new();
        if self.try_keyword("with") {
            config = self.parse_config_clause(pos)?;
        }
        // dart reports against everything before the `;`, including the
        // whitespace in front of it (`@use "x" with ($a: 1)   ;`).
        self.skip_ws_trivia();
        let length = self.sc.byte_len_from(start_mark);
        self.sc.eat(';');
        if misplaced {
            return Err(
                Error::at("@use rules must be written before any other rules.", pos).with_length(length),
            );
        }
        Ok(Stmt::Use {
            url,
            namespace,
            star,
            config,
            pos,
            length,
        })
    }

    /// Parse `@forward "<url>" [as <prefix>-*] [show ...|hide ...] [with (...)];`.
    fn parse_forward(&mut self, pos: Pos, start_mark: Mark) -> Result<Stmt, Error> {
        if self.block_depth > 0 {
            return Err(Error::at("This at-rule is not allowed here.", pos));
        }
        let misplaced = self.seen_non_module_stmt;
        self.skip_ws_trivia();
        let url = self.parse_module_url(pos)?;
        self.skip_ws_trivia();
        let mut prefix = None;
        if self.try_keyword("as") {
            self.skip_ws_inline();
            let name = self.read_namespace_ident()?;
            if !self.sc.eat('*') {
                return Err(Error::at("expected \"*\".", self.sc.position()));
            }
            prefix = Some(name);
            self.skip_ws_trivia();
        }
        let mut show = None;
        let mut hide = None;
        if self.try_keyword("show") {
            show = Some(self.parse_forward_members(pos)?);
            self.skip_ws_trivia();
        } else if self.try_keyword("hide") {
            hide = Some(self.parse_forward_members(pos)?);
            self.skip_ws_trivia();
        }
        let mut config = Vec::new();
        if self.try_keyword("with") {
            config = self.parse_config_clause(pos)?;
        }
        self.skip_ws_trivia();
        let length = self.sc.byte_len_from(start_mark);
        self.sc.eat(';');
        if misplaced {
            return Err(
                Error::at("@forward rules must be written before any other rules.", pos).with_length(length),
            );
        }
        Ok(Stmt::Forward {
            url,
            prefix,
            show,
            hide,
            config,
            pos,
            length,
        })
    }

    /// Parse a `with ( $name: value [!default], ... )` configuration clause.
    fn parse_config_clause(&mut self, pos: Pos) -> Result<Vec<ConfigEntry>, Error> {
        self.skip_ws_trivia();
        if !self.sc.eat('(') {
            return Err(Error::at("expected \"(\".", self.sc.position()));
        }
        let mut entries = Vec::new();
        loop {
            self.skip_ws_trivia();
            if self.sc.eat(')') {
                break;
            }
            let entry_pos = self.sc.position();
            if self.sc.peek() != Some('$') {
                return Err(Error::at("expected \"$\".", entry_pos));
            }
            self.sc.bump();
            let name = self.read_variable_name()?;
            self.skip_ws_trivia();
            if !self.sc.eat(':') {
                return Err(Error::at("expected \":\".", self.sc.position()));
            }
            self.skip_ws_trivia();
            // A configuration value is a single (space-list) expression: a
            // comma is the entry separator, so a comma-list value needs parens.
            let value = self.space_list()?;
            let mut is_default = false;
            self.skip_ws_inline();
            if self.sc.peek() == Some('!') {
                self.sc.bump();
                let flag = self.read_ident_name()?;
                if flag == "default" {
                    is_default = true;
                } else {
                    return Err(Error::at("Invalid flag name.".to_string(), entry_pos));
                }
            }
            entries.push(ConfigEntry {
                name,
                value,
                is_default,
            });
            self.skip_ws_trivia();
            if self.sc.eat(',') {
                continue;
            }
            self.skip_ws_trivia();
            if self.sc.eat(')') {
                break;
            }
            return Err(Error::at("expected \")\".", self.sc.position()));
        }
        let _ = pos;
        Ok(entries)
    }

    /// Parse a `show`/`hide` member list: comma-separated identifiers and
    /// `$variable` names.
    fn parse_forward_members(&mut self, pos: Pos) -> Result<Vec<ForwardMember>, Error> {
        let mut members = Vec::new();
        loop {
            self.skip_ws_trivia();
            if self.sc.peek() == Some('$') {
                self.sc.bump();
                let name = self.read_variable_name()?;
                members.push(ForwardMember::Var(name));
            } else {
                let name = self.read_ident_name()?;
                members.push(ForwardMember::Name(name));
            }
            self.skip_ws_trivia();
            if self.sc.eat(',') {
                continue;
            }
            break;
        }
        if members.is_empty() {
            return Err(Error::at("Expected variable, mixin, or function name", pos));
        }
        Ok(members)
    }

    /// Read a quoted module URL (no interpolation allowed) for `@use`/`@forward`.
    fn parse_module_url(&mut self, pos: Pos) -> Result<String, Error> {
        match self.sc.peek() {
            Some('"') | Some('\'') => {
                let pieces = self.parse_quoted_string()?;
                let mut url = String::new();
                for p in &pieces {
                    match p {
                        TplPiece::Lit(s) => url.push_str(s),
                        TplPiece::Interp(_) => {
                            return Err(Error::at("dynamic module URLs are not supported", pos));
                        }
                    }
                }
                Ok(url)
            }
            _ => Err(Error::at("expected a string.", pos)),
        }
    }

    /// Skip whitespace and `/* */` / `//` comments (discarding them); used
    /// between the `@import` keyword, URLs, modifiers, and commas.
    fn skip_ws_trivia(&mut self) {
        loop {
            match self.sc.peek() {
                Some(c) if c.is_whitespace() => {
                    self.sc.bump();
                }
                Some('/') if self.sc.peek_at(1) == Some('/') => {
                    while let Some(c) = self.sc.peek() {
                        if c == '\n' {
                            break;
                        }
                        self.sc.bump();
                    }
                }
                Some('/') if self.sc.peek_at(1) == Some('*') => {
                    self.sc.bump();
                    self.sc.bump();
                    loop {
                        match self.sc.peek() {
                            None => break,
                            Some('*') if self.sc.peek_at(1) == Some('/') => {
                                self.sc.bump();
                                self.sc.bump();
                                break;
                            }
                            Some(_) => {
                                self.sc.bump();
                            }
                        }
                    }
                }
                _ => break,
            }
        }
    }

    /// Parse one `@import` argument and classify it as Sass or plain CSS.
    fn parse_import_arg(&mut self, pos: Pos) -> Result<ImportArg, Error> {
        // `url(...)` form — always a plain CSS import.
        if self.peek_is_url_func() {
            let url_pos = self.sc.position();
            let url = self.parse_import_url()?;
            self.skip_ws_trivia();
            let modifiers = self.parse_import_modifiers()?;
            return Ok(ImportArg::Css {
                url,
                modifiers,
                pos: url_pos,
            });
        }
        // The indented syntax allows an UNQUOTED URL (`@import foo, sub/bar`,
        // `@import other.css`). dart `SassParser.importArgument` reads it to
        // the next top-level comma or the end of the statement — SPACES
        // INCLUDED, so `@import foo screen` is one url `foo screen` (dart:
        // "Can't find stylesheet to import." pointing at all ten characters),
        // not a url plus a modifier. Only a quoted url takes modifiers.
        if self.indented && !matches!(self.sc.peek(), Some('"') | Some('\'')) {
            let url_pos = self.sc.position();
            let mut raw = String::new();
            let mut has_interp = false;
            while let Some(c) = self.sc.peek() {
                // A CSS escape hides the character after it, so `\#{` is the
                // literal text `#{` — a STATIC path, as the quoted form reads
                // it — and an escaped comma is url text rather than a
                // separator.
                if c == '\\' {
                    raw.push(c);
                    self.sc.bump();
                    if let Some(n) = self.sc.peek() {
                        raw.push(n);
                        self.sc.bump();
                    }
                    continue;
                }
                // `#{…}` is opaque: a comma inside it does not end the url.
                if c == '#' && self.sc.peek_at(1) == Some('{') {
                    has_interp = true;
                    let mut depth = 0usize;
                    while let Some(c) = self.sc.peek() {
                        raw.push(c);
                        self.sc.bump();
                        match c {
                            '{' => depth += 1,
                            '}' => {
                                depth -= 1;
                                if depth == 0 {
                                    break;
                                }
                            }
                            _ => {}
                        }
                    }
                    continue;
                }
                if matches!(c, ',' | ';' | '\n') {
                    break;
                }
                raw.push(c);
                self.sc.bump();
            }
            // Trailing whitespace before the `,`/`;` is not part of the url,
            // and the deprecation caret is sized from the trimmed token.
            let path = raw.trim_end().to_string();
            if path.is_empty() {
                return Err(Error::at("expected a string after @import", self.sc.position()));
            }
            let url_len = path.len();
            // A `.css`/protocol url is a plain-CSS import, emitted QUOTED with
            // its text verbatim — dart writes `@import "#{$x}o.css";`, leaving
            // even an interpolation unresolved.
            if import_url_is_css(&[TplPiece::Lit(path.as_str().into())]) {
                return Ok(ImportArg::Css {
                    url: vec![TplPiece::Lit(crate::value::serialize_quoted(&path).into())],
                    modifiers: Vec::new(),
                    pos: url_pos,
                });
            }
            // A Sass import's path is static here, as in the quoted form —
            // an ESCAPED `\#{` is literal text and does not make it dynamic.
            if has_interp {
                return Err(Error::at("dynamic @import paths are not supported", pos));
            }
            return Ok(ImportArg::Sass {
                path,
                pos: url_pos,
                length: url_len,
            });
        }
        // Quoted-string form.
        match self.sc.peek() {
            Some('"') | Some('\'') => {
                let url_pos = self.sc.position();
                let mark = self.sc.mark();
                let pieces = self.parse_quoted_string()?;
                let url_len = self.sc.byte_len_from(mark);
                let raw_url = self.sc.slice_from(mark);
                self.skip_ws_trivia();
                let modifiers = self.parse_import_modifiers()?;
                let css_url = import_url_is_css(&pieces);
                if modifiers.is_empty() && !css_url {
                    // A bare Sass path. Reject interpolation (dynamic paths).
                    let mut path = String::new();
                    for p in &pieces {
                        match p {
                            TplPiece::Lit(s) => path.push_str(s),
                            TplPiece::Interp(_) => {
                                return Err(Error::at("dynamic @import paths are not supported", pos));
                            }
                        }
                    }
                    Ok(ImportArg::Sass {
                        path,
                        pos: url_pos,
                        length: url_len,
                    })
                } else {
                    Ok(ImportArg::Css {
                        url: vec![TplPiece::Lit(raw_url.into())],
                        modifiers,
                        pos: url_pos,
                    })
                }
            }
            _ => Err(Error::at("expected a string after @import", self.sc.position())),
        }
    }

    /// Whether the cursor is at a `url(` function call — the name matched the
    /// way dart matches it, case-insensitively and with CSS escapes decoded
    /// (`u\72l(` IS `url(`). A vendor-prefixed spelling does NOT count here:
    /// dart rejects `@import -c-url(…)` with "Expected string.", unlike in a
    /// value position where `-c-url(` is a url token.
    fn peek_is_url_func(&self) -> bool {
        let cs = self.sc.rest();
        let (name, k) = crate::parser::decode_ident(cs, 0);
        name.eq_ignore_ascii_case("url") && cs.get(k) == Some(&'(')
    }

    /// Read the `url(...)` argument of an `@import`, mirroring dart-sass
    /// `dynamicUrl`: the contents are tried as a plain URL token first — the
    /// same trial a url in a value position uses, so whitespace padding is
    /// dropped, escapes decode canonically and `#{…}` resolves — and when that
    /// fails (a quoted string, a `$variable`, whitespace in the MIDDLE of the
    /// token) the call is parsed as an ordinary function whose arguments
    /// evaluate, so `@import url($base + "x.css")` imports the computed url
    /// rather than emitting the SassScript verbatim.
    fn parse_import_url(&mut self) -> Result<Vec<TplPiece>, Error> {
        let url_pos = self.sc.position();
        let name_mark = self.sc.mark();
        // The name is whatever spells `url` (`URL(`, `u\72l(`); step past it
        // and the `(`.
        let (_, name_len) = crate::parser::decode_ident(self.sc.rest(), 0);
        for _ in 0..=name_len {
            self.sc.bump();
        }
        if let Some(pieces) = self.try_plain_url_contents()? {
            return Ok(pieces);
        }
        self.sc.reset(name_mark);
        for _ in 0..=name_len {
            self.sc.bump();
        }
        let args = self.parse_args_after_paren()?;
        Ok(vec![TplPiece::Interp(Expr::Func {
            // dart writes the canonical spelling, not the one in the source.
            name: "url".to_string(),
            args,
            pos: url_pos,
            length: self.sc.byte_len_from(name_mark),
            module: None,
        })])
    }

    /// Parse the optional modifiers that follow an `@import` URL, mirroring
    /// dart-sass `tryImportModifiers`: a run of bare identifiers and unknown
    /// functions (kept near-verbatim), at most interleaved `supports(<query>)`
    /// clauses (parsed structurally so they re-serialize canonically), then —
    /// terminally — a media query list, entered either at a `(`-feature or at
    /// a comma following a bare identifier (a media type). After the media
    /// list the modifiers END: a following `supports(...)`/identifier is a
    /// syntax error surfaced by `parse_import`'s `;` check.
    fn parse_import_modifiers(&mut self) -> Result<Vec<ImportModifier>, Error> {
        let mut mods: Vec<ImportModifier> = Vec::new();
        // The current run of identifiers/unknown-functions, space-joined.
        let mut raw: Vec<TplPiece> = Vec::new();
        let flush = |raw: &mut Vec<TplPiece>, mods: &mut Vec<ImportModifier>| {
            if !raw.is_empty() {
                mods.push(ImportModifier::Raw(std::mem::take(raw)));
            }
        };
        let space = |raw: &mut Vec<TplPiece>| {
            if !raw.is_empty() {
                if let Some(TplPiece::Lit(s)) = raw.last_mut() {
                    *s = Rc::from(format!("{s} "));
                } else {
                    raw.push(TplPiece::Lit(" ".into()));
                }
            }
        };
        loop {
            self.skip_ws_trivia();
            if self.looking_at_interpolated_identifier() {
                let identifier = self.parse_interpolated_identifier()?;
                let name = tpl_plain(&identifier).map(|s| s.to_ascii_lowercase());
                if name.as_deref() != Some("and") && self.sc.peek() == Some('(') {
                    if name.as_deref() == Some("supports") {
                        self.sc.bump(); // '('
                        flush(&mut raw, &mut mods);
                        let (condition, declaration) = self.parse_import_supports_query()?;
                        if !self.sc.eat(')') {
                            return Err(Error::at("expected \")\"", self.sc.position()));
                        }
                        mods.push(ImportModifier::Supports {
                            condition,
                            declaration,
                        });
                    } else {
                        // Unknown function: `name(<declaration-value>)` verbatim.
                        self.sc.bump(); // '('
                        space(&mut raw);
                        raw.extend(identifier);
                        push_lit(&mut raw, '(');
                        let args = self.parse_supports_decl_value(true, true, true)?;
                        raw.extend(args);
                        if !self.sc.eat(')') {
                            return Err(Error::at("expected \")\"", self.sc.position()));
                        }
                        push_lit(&mut raw, ')');
                    }
                    continue;
                }
                // A bare identifier (or `and`).
                space(&mut raw);
                raw.extend(identifier);
                self.skip_ws_trivia();
                if self.sc.peek() == Some(',') {
                    // The identifier was a media type; the comma continues its
                    // media query LIST (only media queries may follow).
                    self.sc.bump();
                    flush(&mut raw, &mut mods);
                    let list = self.parse_media_query_list()?;
                    mods.push(ImportModifier::Media {
                        list,
                        comma_before: true,
                    });
                    return Ok(mods);
                }
                continue;
            } else if self.sc.peek() == Some('(') {
                // A media feature begins the terminal media query list.
                flush(&mut raw, &mut mods);
                let list = self.parse_media_query_list()?;
                mods.push(ImportModifier::Media {
                    list,
                    comma_before: false,
                });
                return Ok(mods);
            } else {
                flush(&mut raw, &mut mods);
                return Ok(mods);
            }
        }
    }

    /// dart-sass `_importSupportsQuery`: the content of an `@import ...
    /// supports(...)` modifier. Returns the condition and whether it was a bare
    /// declaration (`supports(a: b)`), whose serialization carries its own
    /// parens.
    fn parse_import_supports_query(&mut self) -> Result<(SupportsCondition, bool), Error> {
        self.skip_ws_trivia();
        if self.scan_keyword_ci("not") {
            self.skip_ws_trivia();
            let inner = self.parse_supports_condition_in_parens()?;
            return Ok((SupportsCondition::Negation(Box::new(inner)), false));
        }
        if self.sc.peek() == Some('(') {
            let condition = self.parse_supports_condition()?;
            let declaration = matches!(condition, SupportsCondition::Declaration { .. });
            return Ok((condition, declaration));
        }
        // `name(<args>)` function form (e.g. `supports(calc(1))`).
        if self.looking_at_interpolated_identifier() {
            let mark = self.sc.mark();
            let identifier = self.parse_interpolated_identifier()?;
            if self.sc.eat('(') {
                let arguments = self.parse_supports_decl_value(true, true, true)?;
                if !self.sc.eat(')') {
                    return Err(Error::at("expected \")\"", self.sc.position()));
                }
                return Ok((
                    SupportsCondition::Function {
                        name: identifier,
                        arguments,
                    },
                    false,
                ));
            }
            self.sc.reset(mark);
        }
        // Bare declaration: `<name>: <value>`.
        let name = self.parse_supports_decl_name()?;
        self.skip_ws_trivia();
        if !self.sc.eat(':') {
            return Err(Error::at("expected \":\".", self.sc.position()));
        }
        let custom = expr_is_custom_property(&name);
        let value = if custom {
            let raw = self.parse_supports_decl_value(false, false, true)?;
            SupportsValue::Raw(raw)
        } else {
            self.skip_ws_trivia();
            let v = self.parse_value()?;
            self.skip_ws_trivia();
            SupportsValue::Expr(v)
        };
        Ok((
            SupportsCondition::Declaration {
                name,
                value: Box::new(value),
                custom,
            },
            true,
        ))
    }

    /// Parse `@warn`/`@debug`/`@error <expr>;`.
    fn parse_message(&mut self, kind: MessageKind, pos: Pos, start_mark: Mark) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let value = self.parse_value()?;
        // Byte length of the `@error <expr>` span (from the `@` through the end
        // of the value, before the trailing `;`), for the diagnostic caret.
        let length = self.sc.byte_len_from(start_mark);
        self.skip_ws_inline();
        self.sc.eat(';');
        Ok(match kind {
            MessageKind::Warn => Stmt::Warn { value, pos },
            MessageKind::Debug => Stmt::Debug { value, pos },
            MessageKind::Error => Stmt::Error { value, pos, length },
        })
    }

    /// Parse `@extend <selector> [!optional];`. The selector is captured as a
    /// template (resolving `#{...}` at eval time); a trailing `!optional`
    /// suppresses the "didn't match" error.
    fn parse_extend(&mut self, pos: Pos) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let selector = trim_prelude(self.parse_template_mode(&['!', ';', '}', '{'], CommentMode::Strip)?);
        let mut optional = false;
        if self.sc.peek() == Some('!') {
            self.sc.bump();
            self.skip_ws_inline();
            let flag = self.read_ident_name()?;
            if !flag.eq_ignore_ascii_case("optional") {
                return Err(Error::at(format!("Invalid flag name: !{flag}"), pos));
            }
            optional = true;
        }
        self.skip_ws_inline();
        self.sc.eat(';');
        Ok(Stmt::Extend {
            selector,
            optional,
            pos,
        })
    }

    // ---- @supports --------------------------------------------------

    /// Parse `@supports <condition> { body }`. The condition is parsed into a
    /// structured [`SupportsCondition`] (dart-sass grammar) so it serializes
    /// canonically and malformed conditions are rejected; the body bubbles like
    /// any at-rule.
    fn parse_supports(&mut self) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let condition = self.parse_supports_condition()?;
        let (body, lines) = self.parse_braced_body_lines()?;
        Ok(Stmt::Supports {
            condition,
            body,
            lines,
        })
    }

    /// dart-sass `_supportsCondition`: an optional leading `not`, otherwise a
    /// condition-in-parens followed by a uniform `and`/`or` chain.
    fn parse_supports_condition(&mut self) -> Result<SupportsCondition, Error> {
        if self.scan_keyword_ci("not") {
            self.skip_ws_inline();
            let inner = self.parse_supports_condition_in_parens()?;
            return Ok(SupportsCondition::Negation(Box::new(inner)));
        }
        let mut condition = self.parse_supports_condition_in_parens()?;
        self.skip_ws_inline();
        let mut operator: Option<Conjunction> = None;
        while self.looking_at_plain_identifier() {
            match operator {
                Some(Conjunction::And) => self.expect_keyword_ci("and")?,
                Some(Conjunction::Or) => self.expect_keyword_ci("or")?,
                None => {
                    if self.scan_keyword_ci("or") {
                        operator = Some(Conjunction::Or);
                    } else {
                        self.expect_keyword_ci("and")?;
                        operator = Some(Conjunction::And);
                    }
                }
            }
            self.skip_ws_inline();
            let right = self.parse_supports_condition_in_parens()?;
            condition = SupportsCondition::Operation {
                left: Box::new(condition),
                right: Box::new(right),
                op: operator.unwrap_or(Conjunction::And),
            };
            self.skip_ws_inline();
        }
        Ok(condition)
    }

    /// dart-sass `_supportsConditionInParens`: a parenthesised condition, a
    /// function call, or a lone interpolation.
    fn parse_supports_condition_in_parens(&mut self) -> Result<SupportsCondition, Error> {
        if self.looking_at_interpolated_identifier() {
            let pos = self.sc.position();
            let identifier = self.parse_interpolated_identifier()?;
            if tpl_plain(&identifier).map(|s| s.eq_ignore_ascii_case("not")) == Some(true) {
                return Err(Error::at("\"not\" is not a valid identifier here.", pos));
            }
            if self.sc.eat('(') {
                let arguments = self.parse_supports_decl_value(true, true, true)?;
                if !self.sc.eat(')') {
                    return Err(Error::at("expected \")\"", self.sc.position()));
                }
                return Ok(SupportsCondition::Function {
                    name: identifier,
                    arguments,
                });
            } else if let Some(expr) = tpl_single_interp(identifier) {
                return Ok(SupportsCondition::Interpolation(expr));
            } else {
                return Err(Error::at("Expected @supports condition.", pos));
            }
        }

        let start = self.sc.position();
        if !self.sc.eat('(') {
            return Err(Error::at("expected \"(\"", start));
        }
        self.skip_ws_inline();
        if self.scan_keyword_ci("not") {
            self.skip_ws_inline();
            let condition = self.parse_supports_condition_in_parens()?;
            if !self.sc.eat(')') {
                return Err(Error::at("expected \")\"", self.sc.position()));
            }
            return Ok(SupportsCondition::Negation(Box::new(condition)));
        } else if self.sc.peek() == Some('(') {
            let condition = self.parse_supports_condition()?;
            if !self.sc.eat(')') {
                return Err(Error::at("expected \")\"", self.sc.position()));
            }
            return Ok(condition);
        }

        // Backtracking branch: try `<expression> ":" <value>` (a declaration),
        // and on failure re-parse as an interpolated identifier followed either
        // by an `and`/`or` operation or by an arbitrary "anything" value.
        let name_mark = self.sc.mark();
        let parsed = match self.parse_supports_decl_name() {
            Ok(name) => {
                self.skip_ws_inline();
                if self.sc.eat(':') {
                    Ok(Some(name))
                } else {
                    Ok(None)
                }
            }
            Err(e) => Err(e),
        };
        match parsed {
            Ok(Some(name)) => {
                let custom = expr_is_custom_property(&name);
                let value = if custom {
                    // A custom-property value is captured verbatim.
                    let raw = self.parse_supports_decl_value(false, false, true)?;
                    SupportsValue::Raw(raw)
                } else {
                    self.skip_ws_inline();
                    let v = self.parse_value()?;
                    // Consume any trailing whitespace/comments before `)`
                    // (dart-sass `_expression` leaves the cursor at `)`).
                    self.skip_ws_inline();
                    SupportsValue::Expr(v)
                };
                if !self.sc.eat(')') {
                    return Err(Error::at("expected \")\"", self.sc.position()));
                }
                Ok(SupportsCondition::Declaration {
                    name,
                    value: Box::new(value),
                    custom,
                })
            }
            _ => {
                self.sc.reset(name_mark);
                let identifier = self.parse_interpolated_identifier()?;
                match self.try_supports_operation(identifier)? {
                    Ok(op) => {
                        if !self.sc.eat(')') {
                            return Err(Error::at("expected \")\"", self.sc.position()));
                        }
                        Ok(op)
                    }
                    Err(mut contents) => {
                        // Otherwise parse an `<anything>` value (forbidding a
                        // top-level colon: a colon there means this was meant to
                        // be a declaration, so we report the missing-`:` error).
                        let rest = self.parse_supports_decl_value(true, true, false)?;
                        contents.extend(rest);
                        if self.sc.peek() == Some(':') {
                            return Err(Error::at("expected \":\".", self.sc.position()));
                        }
                        if !self.sc.eat(')') {
                            return Err(Error::at("expected \")\"", self.sc.position()));
                        }
                        Ok(SupportsCondition::Anything(contents))
                    }
                }
            }
        }
    }

    /// Parse the name expression of a `@supports` declaration: a space-/comma-
    /// separated SassScript expression that stops at a top-level `:` (dart-sass
    /// `_expression`). Unlike the general value grammar, a trailing `:` cleanly
    /// terminates the expression rather than erroring, so `(a /**/: b)` and
    /// `(a : b)` parse as declarations.
    fn parse_supports_decl_name(&mut self) -> Result<Expr, Error> {
        let mut commas: Vec<Expr> = Vec::new();
        loop {
            let mut spaces: Vec<Expr> = vec![self.or_expr()?];
            loop {
                let mark = self.sc.mark();
                let had_ws = self.skip_ws_inline();
                // Stop the space-list before a top-level `:`, a `,`, or any
                // value terminator; require whitespace to continue otherwise.
                if !had_ws || self.sc.peek() == Some(':') || self.at_value_terminator() {
                    self.sc.reset(mark);
                    break;
                }
                spaces.push(self.or_expr()?);
            }
            let element = if spaces.len() == 1 {
                spaces.pop().unwrap_or(Expr::Null)
            } else {
                Expr::List {
                    items: spaces,
                    sep: ListSep::Space,
                    bracketed: false,
                }
            };
            commas.push(element);
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if self.sc.peek() == Some(',') {
                self.sc.bump();
                self.skip_ws_inline();
                if self.sc.peek() == Some(':') || self.at_value_terminator() {
                    self.sc.reset(mark);
                    break;
                }
                continue;
            }
            self.sc.reset(mark);
            break;
        }
        Ok(if commas.len() == 1 {
            commas.pop().unwrap_or(Expr::Null)
        } else {
            Expr::List {
                items: commas,
                sep: ListSep::Comma,
                bracketed: false,
            }
        })
    }

    /// dart-sass `_trySupportsOperation`: if a single-interpolation identifier
    /// is followed by `and`/`or`, parse the operation chain (`Ok`); otherwise
    /// restore the scanner position and return the identifier for reuse (`Err`).
    fn try_supports_operation(
        &mut self,
        mut identifier: Vec<TplPiece>,
    ) -> Result<Result<SupportsCondition, Vec<TplPiece>>, Error> {
        // Only a single-interpolation identifier can form an operation. Pull
        // the lone interpolation expression out; if it isn't one, give back the
        // identifier untouched.
        let expr = if matches!(identifier.as_slice(), [TplPiece::Interp(_)]) {
            match identifier.pop() {
                Some(TplPiece::Interp(e)) => e,
                other => {
                    // Unreachable given the guard above, but stay panic-free.
                    if let Some(p) = other {
                        identifier.push(p);
                    }
                    return Ok(Err(identifier));
                }
            }
        } else {
            return Ok(Err(identifier));
        };

        let before_ws = self.sc.mark();
        self.skip_ws_inline();
        let mut operation: Option<SupportsCondition> = None;
        let mut left_expr = Some(expr);
        let mut operator: Option<Conjunction> = None;
        while self.looking_at_plain_identifier() {
            match operator {
                Some(Conjunction::And) => self.expect_keyword_ci("and")?,
                Some(Conjunction::Or) => self.expect_keyword_ci("or")?,
                None => {
                    if self.scan_keyword_ci("and") {
                        operator = Some(Conjunction::And);
                    } else if self.scan_keyword_ci("or") {
                        operator = Some(Conjunction::Or);
                    } else {
                        self.sc.reset(before_ws);
                        // Reconstruct the single-interpolation identifier.
                        let e = left_expr.take().unwrap_or(Expr::Null);
                        return Ok(Err(vec![TplPiece::Interp(e)]));
                    }
                }
            }
            self.skip_ws_inline();
            let right = self.parse_supports_condition_in_parens()?;
            let left = match operation.take() {
                Some(op) => op,
                None => SupportsCondition::Interpolation(left_expr.take().unwrap_or(Expr::Null)),
            };
            operation = Some(SupportsCondition::Operation {
                left: Box::new(left),
                right: Box::new(right),
                op: operator.unwrap_or(Conjunction::And),
            });
            self.skip_ws_inline();
        }
        match operation {
            Some(op) => Ok(Ok(op)),
            None => {
                let e = left_expr.take().unwrap_or(Expr::Null);
                Ok(Err(vec![TplPiece::Interp(e)]))
            }
        }
    }

    /// dart-sass `_interpolatedDeclarationValue`, specialized for `@supports`
    /// (silent comments are dropped, loud comments kept; whitespace collapses;
    /// `#{…}` interpolation captured as template pieces). Stops at an unbalanced
    /// `)`/`}`/`]`, at `;` (unless `allow_semicolon`), at a top-level `:` (unless
    /// `allow_colon`), or at `{`. Errors "Expected token." when `!allow_empty`
    /// and nothing was read.
    fn parse_supports_decl_value(
        &mut self,
        allow_empty: bool,
        allow_semicolon: bool,
        allow_colon: bool,
    ) -> Result<Vec<TplPiece>, Error> {
        let start = self.sc.position();
        let mut pieces: Vec<TplPiece> = Vec::new();
        let mut lit = String::new();
        let mut brackets: Vec<char> = Vec::new();
        // Whether the immediately-preceding source character was a newline
        // (dart-sass `wroteNewline`/`peekChar(-1).isNewline`): used to preserve
        // indentation and collapse consecutive newlines.
        let mut prev_newline = false;
        let mut wrote_anything = false;
        while let Some(c) = self.sc.peek() {
            match c {
                '\\' => {
                    // A hex escape is more than two characters, and dart
                    // re-serializes it canonically (`\\61 b` prints as `ab`).
                    let ch = self.read_escape_char()?;
                    push_ident_escape(&mut lit, ch, true);
                    prev_newline = false;
                    wrote_anything = true;
                }
                '"' | '\'' => {
                    lit.push(c);
                    self.sc.bump();
                    loop {
                        match self.sc.peek() {
                            None => break,
                            Some('\\') => {
                                lit.push('\\');
                                self.sc.bump();
                                if let Some(n) = self.sc.bump() {
                                    lit.push(n);
                                }
                            }
                            // Interpolation resolves inside a quoted string as
                            // well as outside it — the string's TEXT is
                            // verbatim, `#{…}` is not part of it.
                            Some('#') if self.sc.peek_at(1) == Some('{') => {
                                let interp_mark = self.sc.mark();
                                if !lit.is_empty() {
                                    pieces.push(take_lit(&mut lit));
                                }
                                self.sc.bump();
                                self.sc.bump();
                                let e = self.parse_value()?;
                                self.skip_ws_inline();
                                if !self.sc.eat('}') {
                                    return Err(Error::at("expected \"}\"", self.sc.position()));
                                }
                                self.reject_plain_css_interp(interp_mark)?;
                                pieces.push(TplPiece::Interp(e));
                            }
                            Some(ch) => {
                                lit.push(ch);
                                self.sc.bump();
                                if ch == c {
                                    break;
                                }
                            }
                        }
                    }
                    prev_newline = false;
                    wrote_anything = true;
                }
                '/' if self.sc.peek_at(1) == Some('*') => {
                    lit.push_str(&self.consume_loud_comment());
                    prev_newline = false;
                    wrote_anything = true;
                }
                '/' if self.sc.peek_at(1) == Some('/') => {
                    self.consume_silent_comment();
                    prev_newline = false;
                }
                '#' if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                    prev_newline = false;
                    wrote_anything = true;
                }
                ' ' | '\t'
                    if !prev_newline
                        && matches!(self.sc.peek_at(1), Some(w) if w == ' ' || w == '\t' || w == '\n' || w == '\r' || w == '\u{c}') =>
                {
                    // Collapse runs of whitespace to a single character, unless
                    // following a newline (then it's indentation, preserved).
                    self.sc.bump();
                }
                ' ' | '\t' => {
                    lit.push(c);
                    self.sc.bump();
                    wrote_anything = true;
                }
                '\n' | '\r' | '\u{c}' => {
                    // Collapse multiple newlines into one.
                    if !prev_newline {
                        lit.push('\n');
                        wrote_anything = true;
                    }
                    self.sc.bump();
                    prev_newline = true;
                }
                '(' | '[' | '{' => {
                    // Open brackets are always pushed (dart-sass
                    // `allowOpenBrace` defaults true): a `@supports` value reader
                    // always lives inside `(...)`, so the at-rule body `{` is
                    // never reached here — it follows the unbalanced `)`.
                    self.sc.bump();
                    lit.push(c);
                    brackets.push(match c {
                        '(' => ')',
                        '[' => ']',
                        _ => '}',
                    });
                    prev_newline = false;
                    wrote_anything = true;
                }
                ')' | ']' | '}' => {
                    let Some(expected) = brackets.last().copied() else {
                        break;
                    };
                    if c != expected {
                        return Err(Error::at(format!("expected \"{expected}\"."), self.sc.position()));
                    }
                    brackets.pop();
                    self.sc.bump();
                    lit.push(c);
                    prev_newline = false;
                    wrote_anything = true;
                }
                ';' => {
                    if !allow_semicolon && brackets.is_empty() {
                        break;
                    }
                    lit.push(c);
                    self.sc.bump();
                    prev_newline = false;
                    wrote_anything = true;
                }
                ':' => {
                    if !allow_colon && brackets.is_empty() {
                        break;
                    }
                    lit.push(c);
                    self.sc.bump();
                    prev_newline = false;
                    wrote_anything = true;
                }
                _ => {
                    lit.push(c);
                    self.sc.bump();
                    prev_newline = false;
                    wrote_anything = true;
                }
            }
        }
        if let Some(expected) = brackets.last() {
            return Err(Error::at(format!("expected \"{expected}\""), self.sc.position()));
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        if !allow_empty && !wrote_anything {
            return Err(Error::at("Expected token.", start));
        }
        Ok(pieces)
    }

    /// dart-sass `_lookingAtInterpolatedIdentifier`: whether the cursor begins
    /// an identifier (possibly with `#{…}` interpolation).
    fn looking_at_interpolated_identifier(&self) -> bool {
        match self.sc.peek() {
            None => false,
            Some('\\') => true,
            Some('#') => self.sc.peek_at(1) == Some('{'),
            Some('-') => match self.sc.peek_at(1) {
                None => false,
                Some('#') => self.sc.peek_at(2) == Some('{'),
                Some('-') | Some('\\') => true,
                Some(c) => is_name_start_codepoint(c),
            },
            Some(c) => is_name_start_codepoint(c),
        }
    }

    /// Whether the cursor begins a plain (non-interpolated) identifier — used to
    /// detect a trailing `and`/`or` keyword in a supports condition.
    fn looking_at_plain_identifier(&self) -> bool {
        match self.sc.peek() {
            Some('\\') => true,
            Some('-') => {
                matches!(self.sc.peek_at(1), Some(c) if is_name_start_codepoint(c) || c == '-' || c == '\\')
            }
            Some(c) => is_name_start_codepoint(c),
            None => false,
        }
    }

    /// Parse a loud comment's body — the text after `/*`, consuming the closing
    /// `*/` — into template pieces so `#{…}` interpolation resolves at eval
    /// time. Literal text (including newlines) is preserved verbatim. An
    /// unterminated comment ends at EOF, matching dart-sass.
    pub(super) fn parse_loud_comment_body(&mut self) -> Result<Vec<TplPiece>, Error> {
        let mut pieces = Vec::new();
        let mut lit = String::new();
        loop {
            match self.sc.peek() {
                None => break,
                Some('*') if self.sc.peek_at(1) == Some('/') => {
                    self.sc.bump();
                    self.sc.bump();
                    break;
                }
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\".", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                // CSS treats CR, FF, and CRLF as newlines inside a comment;
                // dart-sass normalizes them all to LF in the comment contents.
                Some(c @ ('\r' | '\u{c}')) => {
                    self.sc.bump();
                    if c == '\r' && self.sc.peek() == Some('\n') {
                        self.sc.bump();
                    }
                    lit.push('\n');
                }
                Some(c) => {
                    lit.push(c);
                    self.sc.bump();
                }
            }
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(pieces)
    }

    /// dart-sass `interpolatedIdentifier`: an identifier with optional `#{…}`
    /// interpolation, returned as template pieces. Errors if no identifier.
    fn parse_interpolated_identifier(&mut self) -> Result<Vec<TplPiece>, Error> {
        let mut pieces: Vec<TplPiece> = Vec::new();
        let mut lit = String::new();
        // A leading `--` (custom-property-style) is always a valid start.
        if self.sc.peek() == Some('-') {
            lit.push('-');
            self.sc.bump();
            if self.sc.peek() == Some('-') {
                lit.push('-');
                self.sc.bump();
                self.interpolated_identifier_body(&mut pieces, &mut lit)?;
                if !lit.is_empty() {
                    pieces.push(take_lit(&mut lit));
                }
                return Ok(pieces);
            }
        }
        match self.sc.peek() {
            None => return Err(Error::at("Expected identifier.", self.sc.position())),
            Some('\\') => {
                let ch = self.consume_escape()?;
                lit.push(ch);
            }
            Some('#') if self.sc.peek_at(1) == Some('{') => {
                let interp_mark = self.sc.mark();
                self.sc.bump();
                self.sc.bump();
                let e = self.parse_value()?;
                self.skip_ws_inline();
                if !self.sc.eat('}') {
                    return Err(Error::at("expected \"}\"", self.sc.position()));
                }
                self.reject_plain_css_interp(interp_mark)?;
                if !lit.is_empty() {
                    pieces.push(take_lit(&mut lit));
                }
                pieces.push(TplPiece::Interp(e));
            }
            Some(c) if is_name_start_codepoint(c) => {
                lit.push(c);
                self.sc.bump();
            }
            _ => return Err(Error::at("Expected identifier.", self.sc.position())),
        }
        self.interpolated_identifier_body(&mut pieces, &mut lit)?;
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(pieces)
    }

    /// Consume the body of an interpolated identifier (name chars, escapes,
    /// `#{…}`) into the given piece/literal accumulators.
    fn interpolated_identifier_body(
        &mut self,
        pieces: &mut Vec<TplPiece>,
        lit: &mut String,
    ) -> Result<(), Error> {
        loop {
            match self.sc.peek() {
                Some(c) if c == '_' || c == '-' || c.is_ascii_alphanumeric() || (c as u32) >= 0x80 => {
                    lit.push(c);
                    self.sc.bump();
                }
                Some('\\') => {
                    let ch = self.consume_escape()?;
                    lit.push(ch);
                }
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    if !lit.is_empty() {
                        pieces.push(take_lit(lit));
                    }
                    pieces.push(TplPiece::Interp(e));
                }
                _ => break,
            }
        }
        Ok(())
    }

    /// Scan a bare keyword (case-insensitive) when it stands as a complete
    /// identifier; on a match consume it and return true, else leave the
    /// position unchanged.
    fn scan_keyword_ci(&mut self, kw: &str) -> bool {
        let mark = self.sc.mark();
        let cs = self.sc.rest();
        let mut i = 0;
        while i < cs.len() && is_ident_char(cs[i]) {
            i += 1;
        }
        let word: String = cs[..i].iter().collect();
        if word.eq_ignore_ascii_case(kw) {
            for _ in 0..i {
                self.sc.bump();
            }
            true
        } else {
            self.sc.reset(mark);
            false
        }
    }

    /// Expect a bare keyword (case-insensitive); error in dart-sass's spelling
    /// (`Expected "and".`) when it doesn't match.
    fn expect_keyword_ci(&mut self, kw: &str) -> Result<(), Error> {
        if self.scan_keyword_ci(kw) {
            Ok(())
        } else {
            Err(Error::at(format!("Expected \"{kw}\"."), self.sc.position()))
        }
    }

    /// Parse `@at-root [query] { body }`. The optional query is the
    /// parenthesised `(with: …)` / `(without: …)` form; an inline selector
    /// (`@at-root .x { … }`) is desugared into a single rule inside the body.
    fn parse_at_root(&mut self) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let query = if self.sc.peek() == Some('(') {
            Some(self.parse_at_root_query()?)
        } else if self.sc.peek() == Some('{') {
            None
        } else {
            // The shorthand prelude is a SELECTOR; an at-rule there is
            // dart's "expected selector." (issue_238764 `@at-root @bar`).
            if self.sc.peek() == Some('@') {
                return Err(Error::at("expected selector.", self.sc.position()));
            }
            let selector_pos = self.sc.position();
            let selector = self.parse_template(&['{'])?;
            let (body, lines) = self.parse_braced_body_lines()?;
            return Ok(Stmt::AtRoot {
                query: None,
                body: vec![Stmt::Rule(Rule {
                    selector,
                    body,
                    selector_pos,
                    selector_interp_spans: Vec::new(),
                    brace_line: lines.start,
                    end_line: lines.end,
                })],
            });
        };
        // Whitespace / comments / newlines may sit between a `(…)` query (or
        // the bare `@at-root`) and the body block.
        self.skip_ws_trivia();
        let body = self.parse_braced_body()?;
        Ok(Stmt::AtRoot { query, body })
    }

    /// Parse and validate the `@at-root (with: …)` / `(without: …)` query
    /// (the scanner is on the opening `(`), returning the reconstructed query
    /// template for eval. dart-sass requires `( "with"|"without" : <expr> )`:
    /// a bad keyword is `Expected "with" or "without".`, a missing colon
    /// `expected ":".`, an empty value `Expected expression.`, and a stray
    /// token (e.g. a comma in the value, or junk after `)`) errors in turn
    /// (`expected ")".` / `expected "{".`) — none are silently accepted.
    fn parse_at_root_query(&mut self) -> Result<Vec<TplPiece>, Error> {
        self.sc.bump(); // '('
        self.skip_ws_inline();
        let kw_pos = self.sc.position();
        let kw = self.read_ident_name().unwrap_or_default();
        if !kw.eq_ignore_ascii_case("with") && !kw.eq_ignore_ascii_case("without") {
            return Err(Error::at("Expected \"with\" or \"without\".", kw_pos));
        }
        self.skip_ws_inline();
        if !self.sc.eat(':') {
            return Err(Error::at("expected \":\".", self.sc.position()));
        }
        self.skip_ws_inline();
        let value_pos = self.sc.position();
        // The value is a space-separated expression; a top-level comma ends it
        // and then dart expects `)` (`(with: rule, media)` → `expected ")".`).
        let value = self.parse_template(&[')', ','])?;
        if value
            .iter()
            .all(|p| matches!(p, TplPiece::Lit(s) if s.trim().is_empty()))
        {
            return Err(Error::at("Expected expression.", value_pos));
        }
        if !self.sc.eat(')') {
            return Err(Error::at("expected \")\".", self.sc.position()));
        }
        let mut pieces = vec![TplPiece::Lit(format!("({kw}: ").into())];
        pieces.extend(trim_prelude(value));
        pieces.push(TplPiece::Lit(")".into()));
        Ok(pieces)
    }

    /// Parse `@keyframes <name> { from {…} 50% {…} … }`. The body is parsed as
    /// ordinary statements; each frame block classifies as a rule (its keyframe
    /// selector is terminated by `{`). Parent resolution is suppressed at eval
    /// time so the frame selectors emit verbatim.
    fn parse_keyframes(&mut self, name: String) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let prelude = trim_prelude(self.parse_template(&['{'])?);
        let (body, lines) = self.parse_braced_body_lines()?;
        Ok(Stmt::Keyframes {
            name,
            prelude,
            body,
            lines,
        })
    }

    /// Parse a generic/unknown at-rule: `@name <prelude up to { ; or }>` then
    /// either a `{ … }` body or a terminating `;` (or an immediate `}` closing
    /// the enclosing block, as in `@page … {@g}`). Covers `@font-face`,
    /// `@page`, `@charset`, vendor `@foo`, and unknown directives.
    /// Parse the rest of an at-rule whose name contains interpolation:
    /// finish the name template, then a generic prelude and optional body.
    fn parse_interp_at_rule(&mut self, mut name: Vec<TplPiece>) -> Result<Stmt, Error> {
        loop {
            if self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{') {
                let interp_mark = self.sc.mark();
                self.sc.bump();
                self.sc.bump();
                self.skip_ws_inline();
                let e = self.parse_value()?;
                self.skip_ws_inline();
                if !self.sc.eat('}') {
                    return Err(Error::at("expected \"}\"", self.sc.position()));
                }
                self.reject_plain_css_interp(interp_mark)?;
                name.push(TplPiece::Interp(e));
                continue;
            }
            match self.sc.peek() {
                Some(c) if is_ident_char(c) => {
                    let lit = self.read_ident_name()?;
                    name.push(TplPiece::Lit(lit.into()));
                }
                _ => break,
            }
        }
        self.skip_ws_inline();
        let prelude = trim_prelude(self.parse_template_mode(&['{', ';', '}'], CommentMode::UnknownPrelude)?);
        self.skip_ws_inline();
        let (body, lines) = if self.sc.peek() == Some('{') {
            let (body, lines) = self.parse_braced_body_lines()?;
            (Some(body), lines)
        } else {
            self.sc.eat(';');
            // The `;` form: the statement starts and ends on the `;` line.
            let line = self.sc.position().line as u32;
            (
                None,
                SrcLines {
                    file: 0,
                    start: line,
                    end: line,
                    col: 0,
                    start_col: 0,
                    map_file: 0,
                    map_line: 0,
                },
            )
        };
        Ok(Stmt::InterpAtRule {
            name,
            prelude,
            body,
            lines,
        })
    }

    fn parse_generic_at_rule(&mut self, name: String) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        // dart-sass parses `@-moz-document` (only the exact lowercase spelling)
        // with a structured grammar that strips trivia comments between tokens;
        // every other at-rule keeps loud comments verbatim and treats silent
        // comments as whitespace. (`@supports` has its own dedicated parser.)
        let comment_mode = if name == "-moz-document" {
            CommentMode::StripTopLevel
        } else {
            CommentMode::UnknownPrelude
        };
        let prelude = self.parse_template_mode(&['{', ';', '}'], comment_mode)?;
        let prelude = trim_prelude(prelude);
        self.skip_ws_inline();
        let (body, lines) = if self.sc.peek() == Some('{') {
            let (body, lines) = self.parse_braced_body_lines()?;
            (Some(body), lines)
        } else {
            self.sc.eat(';');
            // The `;` form: the statement starts and ends on the `;` line.
            let line = self.sc.position().line as u32;
            (
                None,
                SrcLines {
                    file: 0,
                    start: line,
                    end: line,
                    col: 0,
                    start_col: 0,
                    map_file: 0,
                    map_line: 0,
                },
            )
        };
        Ok(Stmt::AtRule {
            name,
            prelude,
            body,
            lines,
        })
    }

    // ---- @media -----------------------------------------------------

    /// Parse `@media <media-query-list> { body }`. The query is parsed into a
    /// structured form: a comma list of queries, each a media-type form
    /// (`[not|only]? <type> (and <cond>)*`) or a condition form (one or more
    /// parenthesised conditions joined by `and`/`or`). SassScript expressions
    /// inside feature values are kept as `Expr`s for eval-time resolution.
    /// Malformed queries are rejected, matching dart-sass.
    fn parse_media(&mut self) -> Result<Stmt, Error> {
        let query = self.parse_media_query_list()?;
        let (body, lines) = self.parse_braced_body_lines()?;
        Ok(Stmt::Media { query, body, lines })
    }

    /// Skip whitespace and `/* */` / `//` comments (allowed between media
    /// query tokens). Reports whether any whitespace or comment was consumed.
    fn skip_media_ws(&mut self) -> bool {
        let mut any = false;
        loop {
            match self.sc.peek() {
                Some(c) if c.is_whitespace() => {
                    self.sc.bump();
                    any = true;
                }
                Some('/') if self.sc.peek_at(1) == Some('*') => {
                    self.sc.bump();
                    self.sc.bump();
                    while let Some(c) = self.sc.peek() {
                        if c == '*' && self.sc.peek_at(1) == Some('/') {
                            self.sc.bump();
                            self.sc.bump();
                            break;
                        }
                        self.sc.bump();
                    }
                    any = true;
                }
                Some('/') if self.sc.peek_at(1) == Some('/') => {
                    while let Some(c) = self.sc.peek() {
                        if c == '\n' {
                            break;
                        }
                        self.sc.bump();
                    }
                    any = true;
                }
                _ => break,
            }
        }
        any
    }

    fn parse_media_query_list(&mut self) -> Result<MediaQueryList, Error> {
        let mut queries = Vec::new();
        loop {
            self.skip_media_ws();
            queries.push(self.parse_media_query()?);
            self.skip_media_ws();
            if self.sc.eat(',') {
                continue;
            }
            break;
        }
        Ok(MediaQueryList { queries })
    }

    /// Parse one media query (dart-sass `_mediaQuery`).
    fn parse_media_query(&mut self) -> Result<MediaQuery, Error> {
        // Condition-only form: a leading `(` (a media-in-parens).
        if self.sc.peek() == Some('(') {
            let first = self.parse_media_in_parens()?;
            let (conditions, conjunction) = self.parse_media_logic_sequence(first)?;
            return Ok(MediaQuery::Condition {
                conditions,
                conjunction,
            });
        }

        let ident1 = self.parse_media_identifier()?;
        // `not (...)` → condition form (only when `not` is a raw keyword and a
        // media-in-parens follows rather than another identifier). dart-sass
        // requires whitespace after `not`.
        if media_ident_is(&ident1, "not") {
            self.parse_media_keyword_whitespace()?;
            if !self.looking_at_media_identifier() {
                let inner = self.parse_media_or_interp()?;
                let first = MediaInParens::Not(Box::new(inner));
                let (conditions, conjunction) = self.parse_media_logic_sequence(first)?;
                return Ok(MediaQuery::Condition {
                    conditions,
                    conjunction,
                });
            }
        }
        self.skip_media_ws();
        if !self.looking_at_media_identifier() {
            // `@media screen { … }` — bare media type.
            return Ok(MediaQuery::Type {
                modifier: None,
                mtype: ident1,
                conditions: Vec::new(),
            });
        }
        let ident2 = self.parse_media_identifier()?;
        let (modifier, mtype) = if media_ident_is(&ident2, "and") {
            // `@media screen and …` — ident1 is the type, "and" begins the
            // condition sequence.
            (None, ident1)
        } else {
            self.skip_media_ws();
            // `@media only screen [and …]` — ident1 is the modifier (kept as
            // a template verbatim: it may contain interpolation, and dart
            // preserves its original case).
            let modifier = Some(ident1);
            if !self.try_media_keyword("and") {
                return Ok(MediaQuery::Type {
                    modifier,
                    mtype: ident2,
                    conditions: Vec::new(),
                });
            }
            (modifier, ident2)
        };
        // We have consumed `and`; parse the condition sequence (and-only).
        let conditions = self.parse_media_and_conditions()?;
        Ok(MediaQuery::Type {
            modifier,
            mtype,
            conditions,
        })
    }

    /// After a leading condition, parse the rest of an `and`/`or` sequence.
    /// All conjunctions in one condition must match (no mixing `and`/`or`).
    fn parse_media_logic_sequence(
        &mut self,
        first: MediaInParens,
    ) -> Result<(Vec<MediaInParens>, Conjunction), Error> {
        let mut conditions = vec![first];
        let mut conjunction = Conjunction::And;
        let mut chosen: Option<Conjunction> = None;
        loop {
            let mark = self.sc.mark();
            self.skip_media_ws();
            let next = if self.try_media_keyword("and") {
                Conjunction::And
            } else if self.try_media_keyword("or") {
                Conjunction::Or
            } else {
                self.sc.reset(mark);
                break;
            };
            if let Some(prev) = chosen {
                if prev != next {
                    return Err(Error::at("expected \"{\".", self.sc.position()));
                }
            }
            chosen = Some(next);
            conjunction = next;
            self.parse_media_keyword_whitespace()?;
            conditions.push(self.parse_media_or_interp()?);
        }
        Ok((conditions, conjunction))
    }

    /// Parse one or more `and`-separated media-in-parens (used after a media
    /// type's `and`). `or` is not allowed here. The first operand may be a
    /// `not <media-in-parens>`, which terminates the query (no more conditions).
    fn parse_media_and_conditions(&mut self) -> Result<Vec<MediaInParens>, Error> {
        self.parse_media_keyword_whitespace()?;
        // `<type> and not (<feature>)` — a single negated condition, nothing
        // may follow it (matching dart-sass).
        if self.try_media_keyword("not") {
            self.parse_media_keyword_whitespace()?;
            let inner = self.parse_media_or_interp()?;
            return Ok(vec![MediaInParens::Not(Box::new(inner))]);
        }
        let mut conditions = vec![self.parse_media_or_interp()?];
        loop {
            let mark = self.sc.mark();
            self.skip_media_ws();
            if self.try_media_keyword("and") {
                self.parse_media_keyword_whitespace()?;
                conditions.push(self.parse_media_or_interp()?);
            } else if self.try_media_keyword("or") {
                // `or` after a media type's `and` chain is invalid.
                return Err(Error::at("expected \"{\".", self.sc.position()));
            } else {
                self.sc.reset(mark);
                break;
            }
        }
        Ok(conditions)
    }

    /// Parse a `_mediaOrInterp`: a raw `#{…}` interpolation operand or a single
    /// `(...)` media-in-parens.
    fn parse_media_or_interp(&mut self) -> Result<MediaInParens, Error> {
        self.skip_media_ws();
        if self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{') {
            let interp_mark = self.sc.mark();
            self.sc.bump();
            self.sc.bump();
            let e = self.parse_value()?;
            self.skip_ws_inline();
            if !self.sc.eat('}') {
                return Err(Error::at("expected \"}\"", self.sc.position()));
            }
            self.reject_plain_css_interp(interp_mark)?;
            return Ok(MediaInParens::Interp(e));
        }
        self.parse_media_in_parens()
    }

    /// Parse a single media-in-parens (dart-sass `_mediaInParens`): `(feature)`,
    /// `(not <in-parens>)` → `not <in-parens>`, `((cond) and/or (cond)…)` group,
    /// or a raw `#{…}` interpolation operand.
    fn parse_media_in_parens(&mut self) -> Result<MediaInParens, Error> {
        self.skip_media_ws();
        // A raw interpolation operand is spliced verbatim.
        if self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{') {
            let interp_mark = self.sc.mark();
            self.sc.bump();
            self.sc.bump();
            let e = self.parse_value()?;
            self.skip_ws_inline();
            if !self.sc.eat('}') {
                return Err(Error::at("expected \"}\"", self.sc.position()));
            }
            self.reject_plain_css_interp(interp_mark)?;
            return Ok(MediaInParens::Interp(e));
        }
        if !self.sc.eat('(') {
            return Err(Error::at(
                "expected media condition in parentheses.",
                self.sc.position(),
            ));
        }
        self.skip_media_ws();
        // `(not (...))` → `not (...)`: the wrapping parens are dropped.
        if self.media_at_not_keyword() {
            self.parse_media_identifier()?; // consume "not"
            self.parse_media_keyword_whitespace()?;
            let inner = self.parse_media_in_parens()?;
            self.skip_media_ws();
            if !self.sc.eat(')') {
                return Err(Error::at("expected \")\".", self.sc.position()));
            }
            return Ok(MediaInParens::Not(Box::new(inner)));
        }
        // Nested parens → a sub-condition group, kept wrapped.
        if self.sc.peek() == Some('(') {
            let first = self.parse_media_in_parens()?;
            let (conditions, conjunction) = self.parse_media_logic_sequence(first)?;
            self.skip_media_ws();
            if !self.sc.eat(')') {
                return Err(Error::at("expected \")\".", self.sc.position()));
            }
            return Ok(MediaInParens::Group {
                conditions,
                conjunction,
            });
        }
        // Otherwise a media feature: `<expr> [: <expr> | <op> <expr> [<op> <expr>]]`.
        let feature = self.parse_media_feature()?;
        self.skip_media_ws();
        if !self.sc.eat(')') {
            return Err(Error::at("expected \")\".", self.sc.position()));
        }
        Ok(MediaInParens::Feature(Box::new(feature)))
    }

    /// Whether the cursor is at a raw `not` keyword (used to start a nested
    /// `(not (...))` group).
    fn media_at_not_keyword(&self) -> bool {
        let mut i = 0;
        let mut word = String::new();
        while let Some(c) = self.sc.peek_at(i) {
            if is_ident_char(c) {
                word.push(c);
                i += 1;
            } else {
                break;
            }
        }
        word.eq_ignore_ascii_case("not")
    }

    /// Parse the interior of a single `(...)` media feature.
    fn parse_media_feature(&mut self) -> Result<MediaFeature, Error> {
        let first = self.media_expression()?;
        self.skip_media_ws();
        match self.sc.peek() {
            Some(':') => {
                self.sc.bump();
                self.skip_media_ws();
                let value = self.parse_value()?;
                Ok(MediaFeature::Decl {
                    name: first,
                    value: Some(value),
                })
            }
            Some('<') | Some('>') | Some('=') => {
                let op1 = self.parse_media_comparison()?;
                self.skip_media_ws();
                let second = self.media_expression()?;
                self.skip_media_ws();
                let rest = match self.sc.peek() {
                    Some('<') | Some('>') | Some('=') => {
                        let op2 = self.parse_media_comparison()?;
                        // A range must use a consistent direction. `=` may not
                        // be the second operator either.
                        if !range_ops_compatible(&op1, &op2) {
                            return Err(Error::at("expected \")\".", self.sc.position()));
                        }
                        self.skip_media_ws();
                        let third = self.media_expression()?;
                        self.skip_media_ws();
                        // A third comparison operator is invalid.
                        if matches!(self.sc.peek(), Some('<') | Some('>') | Some('=')) {
                            return Err(Error::at("expected \")\".", self.sc.position()));
                        }
                        Some((op2, third))
                    }
                    _ => None,
                };
                Ok(MediaFeature::Range {
                    first,
                    op1,
                    second,
                    rest,
                })
            }
            _ => Ok(MediaFeature::Decl {
                name: first,
                value: None,
            }),
        }
    }

    /// Parse a comparison operator (`<`, `<=`, `>`, `>=`, `=`). The two-char
    /// forms may not contain whitespace (`< =` is rejected).
    fn parse_media_comparison(&mut self) -> Result<String, Error> {
        match self.sc.peek() {
            Some('=') => {
                self.sc.bump();
                Ok("=".to_string())
            }
            Some('<') | Some('>') => {
                let c = self.sc.bump().unwrap_or('<');
                if self.sc.peek() == Some('=') {
                    self.sc.bump();
                    Ok(format!("{c}="))
                } else {
                    Ok(c.to_string())
                }
            }
            _ => Err(Error::at("Expected expression.", self.sc.position())),
        }
    }

    /// Parse a media-feature expression (a SassScript expression that stops
    /// before a top-level comparison operator: the additive level).
    fn media_expression(&mut self) -> Result<Expr, Error> {
        self.skip_media_ws();
        // `=` directly here (e.g. after `<` with a space) is invalid.
        if matches!(self.sc.peek(), Some('=')) {
            return Err(Error::at("Expected expression.", self.sc.position()));
        }
        // dart `_expressionUntilComparison`: a full SassScript expression
        // stopping at `<`, `>`, or a single `=` — `(screen and (color))`
        // evaluates as ONE boolean expression (issue_485: `and` returns its
        // second operand, so the feature renders `(color)`), while range
        // syntax `(width > 0)` still leaves the comparison to the media
        // grammar (the additive operand never consumes those).
        let mut lhs = self.media_and_chain()?;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if !self.plain_css && self.try_keyword("or") {
                self.skip_ws_inline();
                let pos = self.sc.position();
                let rhs = self.media_and_chain()?;
                lhs = Expr::Binary {
                    op: BinOp::Or,
                    lhs: Box::new(lhs),
                    rhs: Box::new(rhs),
                    pos,
                };
            } else {
                self.sc.reset(mark);
                break;
            }
        }
        Ok(lhs)
    }

    /// The `and` level of [`Self::media_expression`], over additive operands.
    fn media_and_chain(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.additive()?;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if !self.plain_css && self.try_keyword("and") {
                self.skip_ws_inline();
                let pos = self.sc.position();
                let rhs = self.additive()?;
                lhs = Expr::Binary {
                    op: BinOp::And,
                    lhs: Box::new(lhs),
                    rhs: Box::new(rhs),
                    pos,
                };
            } else {
                self.sc.reset(mark);
                break;
            }
        }
        Ok(lhs)
    }

    /// Parse an identifier/template that may include interpolation, used for a
    /// media modifier or type. Stops at whitespace, `,`, `(`, `{`, or `;`.
    fn parse_media_identifier(&mut self) -> Result<Vec<TplPiece>, Error> {
        let mut pieces = Vec::new();
        let mut lit = String::new();
        loop {
            match self.sc.peek() {
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                Some(c) if is_ident_char(c) => {
                    lit.push(c);
                    self.sc.bump();
                }
                // A media type/modifier may carry identifier escapes
                // (`@media screen\9`); decode and re-serialize canonically
                // (`screen\9 ` keeps the escape's terminating space).
                Some('\\') => {
                    let at_start = lit.is_empty() && pieces.is_empty();
                    let c = self.read_escape_char()?;
                    push_ident_escape(&mut lit, c, at_start);
                }
                _ => break,
            }
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        if pieces.is_empty() {
            return Err(Error::at("Expected identifier.", self.sc.position()));
        }
        Ok(pieces)
    }

    /// Whether the cursor is positioned at the start of a media identifier
    /// (a letter, `-`, `_`, or interpolation) — used to distinguish a type
    /// from a following condition.
    fn looking_at_media_identifier(&self) -> bool {
        match self.sc.peek() {
            Some('#') if self.sc.peek_at(1) == Some('{') => true,
            Some(c) => c.is_ascii_alphabetic() || c == '-' || c == '_',
            None => false,
        }
    }

    /// Consume the bare keyword `kw` (`and`/`or`) if it is next as a whole
    /// identifier; restores the cursor and returns false otherwise. Matched
    /// case-insensitively.
    fn try_media_keyword(&mut self, kw: &str) -> bool {
        let mark = self.sc.mark();
        if !matches!(self.sc.peek(), Some(c) if c.is_ascii_alphabetic()) {
            self.sc.reset(mark);
            return false;
        }
        let mut word = String::new();
        while matches!(self.sc.peek(), Some(c) if is_ident_char(c)) {
            if let Some(c) = self.sc.bump() {
                word.push(c);
            }
        }
        if word.eq_ignore_ascii_case(kw) {
            true
        } else {
            self.sc.reset(mark);
            false
        }
    }

    /// After a media `and`/`or`/`not` keyword, dart-sass requires whitespace
    /// (or a comment) before the next operand: `and(b)` is an error.
    fn parse_media_keyword_whitespace(&mut self) -> Result<(), Error> {
        if !self.skip_media_ws() {
            // An interpolation operand needs no space; `(` does.
            if !(self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{')) {
                return Err(Error::at("Expected whitespace.", self.sc.position()));
            }
        }
        Ok(())
    }

    /// Parse a `@function name(params) { … }` or `@mixin name(params) { … }`.
    pub(super) fn parse_callable_def(&mut self, is_function: bool) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let name_pos = self.sc.position();
        let name_mark = self.sc.mark();
        let name = self.read_ident_name()?;
        // A user `@function` may not reuse a name the parser treats as a
        // SassScript operator or a special plain-CSS function (dart-sass).
        if is_function && is_reserved_function_name(&name) {
            return Err(Error::at("Invalid function name.", name_pos));
        }
        // The `declaration` span an argument error points back at is
        // `name(params)` — or just the name when no parameter list follows, so
        // the whitespace `parse_param_list` skips on its way to nothing is not
        // underlined.
        let name_length = self.sc.byte_len_from(name_mark);
        let before_params = self.sc.mark();
        self.skip_ws_inline();
        let has_params = self.sc.peek() == Some('(');
        self.sc.reset(before_params);
        let params = self.parse_param_list()?;
        let decl_length = if has_params {
            self.sc.byte_len_from(name_mark)
        } else {
            name_length
        };
        let body = self.parse_braced_body()?;
        // Unknown at-rules aren't allowed in a function body (parse-time in
        // dart-sass: "This at-rule is not allowed here.").
        if is_function {
            reject_at_rules_in(&body)?;
        }
        let callable = Rc::new(Callable {
            name,
            params,
            body,
            decl_pos: name_pos,
            decl_length,
        });
        Ok(if is_function {
            Stmt::FunctionDef(callable)
        } else {
            Stmt::MixinDef(callable)
        })
    }

    /// After a lowercase `@function`/`@mixin` keyword, peek whether the name
    /// that follows begins with `--` (a plain CSS custom function/mixin).
    pub(super) fn peek_callable_name_is_custom(&self) -> bool {
        let cs = self.sc.rest();
        let mut i = 0;
        while i < cs.len() && cs[i].is_whitespace() {
            i += 1;
        }
        cs.get(i) == Some(&'-') && cs.get(i + 1) == Some(&'-')
    }

    /// Parse a plain CSS custom `@function`/`@mixin` (`keyword` is the literal
    /// at-rule name, e.g. `function`/`FUNCTION`/`mixin`). The prelude (the name,
    /// optional parameter list, and optional `returns <type>` clause) is
    /// captured as a template up to `{`; the body's top-level declarations keep
    /// their values verbatim. Only `#{...}` interpolation is resolved.
    fn parse_css_custom_callable(&mut self, keyword: String) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let prelude = trim_prelude(self.parse_template(&['{', ';', '}'])?);
        self.skip_ws_inline();
        if self.sc.peek() != Some('{') {
            // A bodyless form (`@mixin --a;`) is not valid CSS here.
            return Err(Error::at("expected \"{\".", self.sc.position()));
        }
        self.sc.bump(); // '{'
        let body = self.parse_css_custom_body()?;
        Ok(Stmt::CssCustomAtRule {
            name: keyword,
            prelude,
            body,
        })
    }

    /// Parse the `{ … }` body of a plain CSS custom `@function`/`@mixin` after
    /// the `{` has been consumed, up to and including the matching `}`. Each
    /// top-level item is a declaration `property: value`. When the property is
    /// a plain literal the value is captured verbatim (a template); when it
    /// contains interpolation the value is parsed as SassScript.
    fn parse_css_custom_body(&mut self) -> Result<Vec<CssCustomItem>, Error> {
        let mut items = Vec::new();
        loop {
            self.skip_ws_inline();
            match self.sc.peek() {
                None => return Err(Error::at("expected \"}\".", self.sc.position())),
                Some('}') => {
                    self.sc.bump();
                    break;
                }
                Some(';') => {
                    self.sc.bump();
                    continue;
                }
                _ => {}
            }
            // Property name up to `:` (interpolation allowed).
            let property = trim_prelude(self.parse_template(&[':', '{', ';', '}'])?);
            if !self.sc.eat(':') {
                return Err(Error::at("expected \":\".", self.sc.position()));
            }
            let has_interp = property.iter().any(|p| matches!(p, TplPiece::Interp(_)));
            if has_interp {
                self.skip_ws_inline();
                // An interpolated property name follows the ordinary nested-
                // property rules: a value-less `{ … }` block expands each
                // child as `property-child` (`#{re}sult: {b: c}` emits
                // `result-b: c`) — unlike a literal `result`, whose value is
                // captured verbatim (braces and all).
                if self.sc.peek() == Some('{') {
                    self.sc.bump();
                    let mut children: Vec<(Vec<TplPiece>, Expr)> = Vec::new();
                    loop {
                        self.skip_ws_inline();
                        match self.sc.peek() {
                            None => return Err(Error::at("expected \"}\".", self.sc.position())),
                            Some('}') => {
                                self.sc.bump();
                                break;
                            }
                            Some(';') => {
                                self.sc.bump();
                                continue;
                            }
                            _ => {}
                        }
                        let child = trim_prelude(self.parse_template(&[':', '{', ';', '}'])?);
                        if !self.sc.eat(':') {
                            return Err(Error::at("expected \":\".", self.sc.position()));
                        }
                        self.skip_ws_inline();
                        let expr = self.parse_value()?;
                        self.skip_ws_inline();
                        self.sc.eat(';');
                        children.push((child, expr));
                    }
                    items.push(CssCustomItem {
                        property,
                        value: CssCustomValue::Set(children),
                    });
                    continue;
                }
                let expr = self.parse_value()?;
                self.skip_ws_inline();
                self.sc.eat(';');
                items.push(CssCustomItem {
                    property,
                    value: CssCustomValue::Script(expr),
                });
            } else {
                let raw = self.parse_css_custom_value()?;
                // The reader consumes its `;` and stops at `}` or at the end of
                // the file — except at a closer with no opener, which dart
                // reports as a missing separator rather than as a bad property
                // name (`result: ];` fails at the `]`).
                if matches!(self.sc.peek(), Some(')' | ']')) {
                    return Err(Error::at("expected \";\".", self.sc.position()));
                }
                items.push(CssCustomItem {
                    property,
                    value: CssCustomValue::Raw(raw),
                });
            }
        }
        Ok(items)
    }

    /// Capture a verbatim CSS custom declaration value after the `:`, up to the
    /// terminating top-level `;` or `}`. Whitespace runs collapse to a single
    /// space (matching dart-sass serialization); `#{...}` interpolation is
    /// resolved; each closer is matched against the bracket it opened, so a
    /// braced value such as `{b: c}` is captured whole and `(]` is an error.
    /// The terminating `;` is consumed; a `}` is left for the body loop.
    fn parse_css_custom_value(&mut self) -> Result<Vec<TplPiece>, Error> {
        let mut pieces: Vec<TplPiece> = Vec::new();
        let mut lit = String::new();
        let mut brackets: Vec<char> = Vec::new();
        loop {
            match self.sc.peek() {
                None => break,
                Some(';') if brackets.is_empty() => {
                    self.sc.bump();
                    break;
                }
                // An escape is one token, so an escaped delimiter is literal
                // text rather than a bracket (dart re-serializes it canonically).
                Some('\\') => {
                    let c = self.read_escape_char()?;
                    push_ident_escape(&mut lit, c, true);
                }
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                Some(q @ ('"' | '\'')) => {
                    lit.push(q);
                    self.sc.bump();
                    loop {
                        match self.sc.peek() {
                            None => break,
                            Some('\\') => {
                                lit.push('\\');
                                self.sc.bump();
                                if let Some(esc) = self.sc.bump() {
                                    lit.push(esc);
                                }
                            }
                            // Interpolation resolves inside the string too, as
                            // the documented behaviour of this reader says and
                            // as the custom-property reader already did.
                            Some('#') if self.sc.peek_at(1) == Some('{') => {
                                let interp_mark = self.sc.mark();
                                if !lit.is_empty() {
                                    pieces.push(take_lit(&mut lit));
                                }
                                self.sc.bump();
                                self.sc.bump();
                                let e = self.parse_value()?;
                                self.skip_ws_inline();
                                if !self.sc.eat('}') {
                                    return Err(Error::at("expected \"}\"", self.sc.position()));
                                }
                                self.reject_plain_css_interp(interp_mark)?;
                                pieces.push(TplPiece::Interp(e));
                            }
                            Some(ch) => {
                                lit.push(ch);
                                self.sc.bump();
                                if ch == q {
                                    break;
                                }
                            }
                        }
                    }
                }
                Some(c) if c.is_whitespace() => {
                    while matches!(self.sc.peek(), Some(c) if c.is_whitespace()) {
                        self.sc.bump();
                    }
                    lit.push(' ');
                }
                Some(c @ ('(' | '[' | '{')) => {
                    brackets.push(match c {
                        '(' => ')',
                        '[' => ']',
                        _ => '}',
                    });
                    lit.push(c);
                    self.sc.bump();
                }
                Some(c @ (')' | ']' | '}')) => {
                    // A closer with no opener ENDS the value (the caller then
                    // wants its `;`); a closer that does not match the bracket
                    // it would close is an error, as in every other verbatim
                    // value reader.
                    let Some(expected) = brackets.last().copied() else {
                        break;
                    };
                    if c != expected {
                        return Err(Error::at(format!("expected \"{expected}\"."), self.sc.position()));
                    }
                    brackets.pop();
                    lit.push(c);
                    self.sc.bump();
                }
                Some(c) => {
                    lit.push(c);
                    self.sc.bump();
                }
            }
        }
        if let Some(expected) = brackets.last() {
            return Err(Error::at(format!("expected \"{expected}\"."), self.sc.position()));
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(pieces)
    }

    /// Capture a custom-property (`--name`) declaration value verbatim, from
    /// just after the colon up to the terminating top-level `;` or `}`. This
    /// mirrors dart-sass `_interpolatedDeclarationValue`: `#{…}` interpolation
    /// resolves *everywhere* (including inside strings), `//` and `/* */` are
    /// literal value characters (not comments), strings and `()`/`[]`/`{}` keep
    /// their delimiters, and whitespace runs collapse to a single space. The
    /// captured pieces are trimmed of surrounding whitespace; the terminating
    /// `;` is left for the caller.
    pub(super) fn parse_custom_property_value(&mut self) -> Result<Vec<TplPiece>, Error> {
        let mut pieces: Vec<TplPiece> = Vec::new();
        let mut lit = String::new();
        // dart-sass matches each closer against the bracket it opened, so `(]`
        // is an error rather than a pair that cancels out, and a closer with no
        // opener ENDS the value (the caller then expects its `;`).
        let mut brackets: Vec<char> = Vec::new();
        // dart-sass `_interpolatedDeclarationValue` writes whitespace lazily:
        // a run of spaces/tabs collapses to its *last* character (a tab survives
        // a tab-only run), while a run containing a newline emits one `\n` plus
        // the following indentation verbatim. `wrote_newline` tracks whether the
        // most recently written character was a newline so indentation after a
        // newline is preserved and blank lines are not duplicated. The value is
        // NOT trimmed — leading whitespace after the colon and trailing
        // whitespace are both significant for a custom property.
        let mut wrote_newline = false;
        loop {
            match self.sc.peek() {
                None => break,
                Some(';') if brackets.is_empty() => break,
                // An escape is one token: the delimiter behind it is literal
                // text, so `--x: \\{` is a complete value rather than an open
                // brace that swallows everything after it. dart re-serializes
                // the escape canonically (`\\7b` and `\\{` both print as `\\{`,
                // `\\61 b` as `ab`), passing `identifierStart: true`.
                Some('\\') => {
                    let c = self.read_escape_char()?;
                    push_ident_escape(&mut lit, c, true);
                    wrote_newline = false;
                }
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                    wrote_newline = false;
                }
                Some(q @ ('"' | '\'')) => {
                    // Capture the string, resolving interpolation inside it but
                    // keeping the quotes and other characters verbatim.
                    lit.push(q);
                    self.sc.bump();
                    loop {
                        match self.sc.peek() {
                            None => break,
                            Some('\\') => {
                                lit.push('\\');
                                self.sc.bump();
                                if let Some(esc) = self.sc.peek() {
                                    lit.push(esc);
                                    self.sc.bump();
                                }
                            }
                            Some('#') if self.sc.peek_at(1) == Some('{') => {
                                let interp_mark = self.sc.mark();
                                if !lit.is_empty() {
                                    pieces.push(take_lit(&mut lit));
                                }
                                self.sc.bump();
                                self.sc.bump();
                                let e = self.parse_value()?;
                                self.skip_ws_inline();
                                if !self.sc.eat('}') {
                                    return Err(Error::at("expected \"}\"", self.sc.position()));
                                }
                                self.reject_plain_css_interp(interp_mark)?;
                                pieces.push(TplPiece::Interp(e));
                            }
                            Some(c) => {
                                lit.push(c);
                                self.sc.bump();
                                if c == q {
                                    break;
                                }
                            }
                        }
                    }
                    wrote_newline = false;
                }
                Some(c @ ('\n' | '\r' | '\u{c}')) => {
                    self.sc.bump();
                    // Treat `\r\n` as one newline.
                    if c == '\r' && self.sc.peek() == Some('\n') {
                        self.sc.bump();
                    }
                    if !wrote_newline {
                        lit.push('\n');
                        wrote_newline = true;
                    }
                }
                Some(c) if c == ' ' || c == '\t' => {
                    // Write this space/tab only if we just emitted a newline (so
                    // indentation is preserved) or it is the last whitespace of
                    // the run (so an inline run collapses to its final char).
                    let next_is_inline_ws = matches!(self.sc.peek_at(1), Some(' ') | Some('\t'));
                    if wrote_newline || !next_is_inline_ws {
                        lit.push(c);
                    }
                    self.sc.bump();
                }
                Some(c @ ('(' | '[' | '{')) => {
                    brackets.push(match c {
                        '(' => ')',
                        '[' => ']',
                        _ => '}',
                    });
                    lit.push(c);
                    self.sc.bump();
                    wrote_newline = false;
                }
                Some(c @ (')' | ']' | '}')) => {
                    let Some(expected) = brackets.last().copied() else {
                        break;
                    };
                    if c != expected {
                        return Err(Error::at(format!("expected \"{expected}\"."), self.sc.position()));
                    }
                    brackets.pop();
                    lit.push(c);
                    self.sc.bump();
                    wrote_newline = false;
                }
                Some(c) => {
                    lit.push(c);
                    self.sc.bump();
                    wrote_newline = false;
                }
            }
        }
        if let Some(expected) = brackets.last() {
            return Err(Error::at(format!("expected \"{expected}\"."), self.sc.position()));
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        // A trailing newline-run collapses to a single space (dart-sass emits a
        // trailing newline before the terminator as a space, not a line break).
        if let Some(TplPiece::Lit(s)) = pieces.last_mut() {
            if s.ends_with('\n') {
                *s = Rc::from(format!("{} ", s.trim_end_matches([' ', '\t', '\n'])));
            }
        }
        Ok(pieces)
    }

    /// Parse a declared parameter list `($a, $b: default, $rest...)`.
    /// Missing parentheses means no parameters.
    fn parse_param_list(&mut self) -> Result<ParamList, Error> {
        let mut params = Vec::new();
        let mut rest = None;
        // dart-sass forbids two parameters with the same name, treating `-` and
        // `_` as identical (`$a-b` and `$a_b` collide) — track the normalized
        // names seen so far and reject a repeat with "Duplicate parameter.".
        let mut seen: Vec<String> = Vec::new();
        self.skip_ws_inline();
        if self.sc.peek() != Some('(') {
            return Ok(ParamList { params, rest });
        }
        self.sc.bump(); // '('
        self.skip_ws_inline();
        if self.sc.peek() == Some(')') {
            self.sc.bump();
            return Ok(ParamList { params, rest });
        }
        loop {
            self.skip_ws_inline();
            let name_pos = self.sc.position();
            if !self.sc.eat('$') {
                return Err(Error::at("expected a parameter", self.sc.position()));
            }
            let name = self.read_variable_name()?;
            let norm = name.replace('_', "-");
            if seen.contains(&norm) {
                return Err(Error::at("Duplicate parameter.", name_pos));
            }
            seen.push(norm);
            self.skip_ws_inline();
            if self.sc.peek() == Some('.')
                && self.sc.peek_at(1) == Some('.')
                && self.sc.peek_at(2) == Some('.')
            {
                self.sc.bump();
                self.sc.bump();
                self.sc.bump();
                rest = Some(name);
                self.skip_ws_inline();
                // An optional trailing comma is allowed after `$rest...`.
                self.sc.eat(',');
                self.skip_ws_inline();
                break;
            }
            // Source-map: a parameter bound from its declared default takes
            // that default's span as its definition node, so record where the
            // default's text starts (Pos::NONE when there is no default).
            let mut default_pos = crate::scanner::Pos::NONE;
            let default = if self.sc.peek() == Some(':') {
                self.sc.bump();
                self.skip_ws_inline();
                default_pos = self.sc.position();
                Some(self.space_list()?)
            } else {
                None
            };
            params.push(Param {
                name,
                default,
                default_pos,
            });
            self.skip_ws_inline();
            if self.sc.eat(',') {
                self.skip_ws_inline();
                // A trailing comma before `)` ends the list.
                if self.sc.peek() == Some(')') {
                    break;
                }
                continue;
            }
            break;
        }
        self.skip_ws_inline();
        if !self.sc.eat(')') {
            return Err(Error::at("expected \")\"", self.sc.position()));
        }
        Ok(ParamList { params, rest })
    }

    /// Parse `@return <expr>;`.
    fn parse_return(&mut self) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let value = self.parse_value()?;
        self.skip_ws_inline();
        self.sc.eat(';');
        Ok(Stmt::Return(value))
    }

    /// Parse `@include name[(args)] [{ content }];`.
    pub(super) fn parse_include(&mut self, pos: Pos, start_mark: Mark) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let include_name_pos = self.sc.position();
        let mut name = self.read_ident_name()?;
        // `@include --a` is reserved for plain CSS mixins (dart-sass), even
        // though `@mixin __a` normalizes to the same name.
        if name.starts_with("--") {
            return Err(Error::at(
                "Sass @mixin names beginning with -- are forbidden for \
                     forward-compatibility with plain CSS mixins.",
                include_name_pos,
            ));
        }
        // `@include ns.mixin(...)` — a namespaced mixin reference.
        let mut module = None;
        if self.sc.peek() == Some('.') {
            self.sc.bump();
            module = Some(name);
            let member_pos = self.sc.position();
            let member_mark = self.sc.mark();
            // Privacy is the LITERAL spelling: dart reads `ns.\2d priv` as an
            // ordinary member (and then fails to find it); only a written
            // `-`/`_` is private.
            let literally_private = matches!(self.sc.peek(), Some('-') | Some('_'));
            name = self.read_ident_name()?;
            if literally_private {
                // The caret covers the member name AS WRITTEN, escapes and all.
                return Err(Error::at(
                    "Private members can't be accessed from outside their modules.",
                    member_pos,
                )
                .with_length(self.sc.byte_len_from(member_mark)));
            }
        }
        // Byte length of `@include name` so far, before any whitespace that
        // separates the name from a content block (`@include m {`).
        let name_length = self.sc.byte_len_from(start_mark);
        self.skip_ws_inline();
        let (args, length) = if self.sc.peek() == Some('(') {
            self.sc.bump();
            let args = self.parse_args_after_paren()?;
            // Byte length of `@include name(args)` through the closing `)`.
            (args, self.sc.byte_len_from(start_mark))
        } else {
            (Vec::new(), name_length)
        };
        // How much of the statement is WRITTEN in the source: the call, plus a
        // `using (…)` clause if there is one. Whitespace and braces after that
        // can be the indented front end's own (it wraps a child block to hand
        // the parser SCSS), so they are not a source span to point at.
        let mut source_length = length;
        self.skip_ws_inline();
        // An optional `using (params)` clause names the content block's
        // parameters, bound from the `@content(args)` call.
        let using_mark = self.sc.mark();
        let content_params = if self
            .read_ident_name()
            .ok()
            .is_some_and(|kw| kw.eq_ignore_ascii_case("using"))
        {
            self.skip_ws_inline();
            // `using` must be followed by a parenthesized parameter list.
            if self.sc.peek() != Some('(') {
                return Err(Error::at("expected \"(\".", self.sc.position()));
            }
            let params = self.parse_param_list()?;
            source_length = self.sc.byte_len_from(start_mark);
            Some(Rc::new(params))
        } else {
            self.sc.reset(using_mark);
            None
        };
        self.skip_ws_inline();
        // dart carets an error about the RULE (an undefined mixin) over all of
        // it, `using` clause and content block included, and an error about the
        // CALL (a content block the mixin does not take) over
        // `@include name(args)` only. Neither covers the terminating `;`.
        let full_length;
        let content = if self.sc.peek() == Some('{') {
            let body = self.parse_braced_body()?;
            // In the indented syntax the braces around a child block are
            // SYNTHETIC — the front end wrote them into the reconstruction —
            // so the text they enclose is not a source span to point at, and
            // the span stops where the WRITTEN text does. dart spans the
            // children; matching that needs the front end to map a
            // reconstruction span back to source.
            full_length = if self.indented {
                source_length
            } else {
                self.sc.byte_len_from(start_mark)
            };
            Some(Rc::new(body))
        } else if content_params.is_some() {
            // A `using (params)` clause requires a content block to bind into.
            return Err(Error::at("expected \"{\".", self.sc.position()));
        } else {
            full_length = self.sc.byte_len_from(start_mark);
            self.sc.eat(';');
            None
        };
        Ok(Stmt::Include {
            name,
            args,
            content,
            content_params,
            module,
            pos,
            length,
            full_length,
        })
    }
}
