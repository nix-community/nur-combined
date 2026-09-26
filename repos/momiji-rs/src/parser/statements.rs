//! Statement and declaration parsing: the top-level statement loop
//! (`parse_statements`), trivia/comment skipping, the rule-vs-declaration
//! lookahead (`classify`), style rules, declarations + nested property sets,
//! and variable declarations. Extracted verbatim from [`super`].

use super::*;

impl Parser {
    pub(super) fn parse_statements(&mut self, top: bool) -> Result<Vec<Stmt>, Error> {
        let mut stmts = Vec::new();
        loop {
            self.skip_trivia(&mut stmts)?;
            match self.sc.peek() {
                None => {
                    if top {
                        break;
                    }
                    // dart names what it wanted, not what it found: a file
                    // that ends inside a block is `expected "}".`
                    return Err(Error::at("expected \"}\".", self.sc.position()));
                }
                Some('}') => {
                    if top {
                        return Err(Error::at("unexpected \"}\"", self.sc.position()));
                    }
                    break;
                }
                // A stray `;` (e.g. after a `}` rule block) is an empty
                // statement: dart-sass accepts and ignores it.
                Some(';') => {
                    self.sc.bump();
                    continue;
                }
                Some('$') => stmts.push(self.parse_var_decl()?),
                Some('@') => stmts.push(self.parse_at_rule()?),
                // The indented syntax's mixin shorthands, read in place so
                // every column after the keyword stays a `.sass` column:
                // `=name(params)` defines a mixin (dart `SassParser`'s `=`),
                // `+name(args)` includes one. A `+` NOT followed by a name is
                // the next-sibling combinator, i.e. a selector.
                Some('=') if self.indented => {
                    self.sc.bump();
                    self.skip_ws_inline();
                    // `=--name` is the plain-CSS mixin spelling dart reserves,
                    // rejected exactly as `@mixin --name` is (dart points at
                    // the name, which is where the shorthand puts it).
                    if self.peek_callable_name_is_custom() {
                        return Err(Error::at(
                            "Sass @mixin names beginning with -- are forbidden for \
                             forward-compatibility with plain CSS mixins.",
                            self.sc.position(),
                        ));
                    }
                    stmts.push(self.parse_callable_def(false)?);
                }
                Some('+')
                    if self.indented
                        && self
                            .sc
                            .peek_at(1)
                            .is_some_and(|c| is_ident_char(c) || c == '#' || c == '\\') =>
                {
                    let pos = self.sc.position();
                    let start_mark = self.sc.mark();
                    self.sc.bump();
                    stmts.push(self.parse_include(pos, start_mark)?);
                }
                // The legacy escaped-selector form: a leading `\` marks the
                // line as a SELECTOR rather than the old `:prop value`
                // declaration syntax, and is not part of it. Consumed here so
                // the selector keeps its own column (dart maps `\:hover` to
                // the `:`), not upstream where dropping it shifted the line.
                Some('\\') if self.indented => {
                    self.sc.bump();
                    stmts.push(self.parse_rule()?);
                }
                // A namespaced variable assignment `ns.$name: value`.
                _ if self.peek_namespaced_var_decl() => stmts.push(self.parse_var_decl()?),
                _ => match self.classify() {
                    NextKind::Rule => stmts.push(self.parse_rule()?),
                    NextKind::Declaration => stmts.push(self.parse_declaration()?),
                },
            }
            // Track, at the top level, whether anything that must follow `@use`
            // has been seen. A variable declaration, `@charset`, `@use`, and
            // `@forward` (and comments, which `skip_trivia` collects) are
            // permitted before `@use`; anything else "uses up" the position.
            if top {
                if let Some(last) = stmts.last() {
                    if !stmt_allowed_before_use(last) {
                        self.seen_non_module_stmt = true;
                    }
                }
            }
        }
        Ok(stmts)
    }

    /// Skip whitespace and comments, collecting loud `/* */` comments into
    /// the statement stream so they emit in source order.
    pub(super) fn skip_trivia(&mut self, out: &mut Vec<Stmt>) -> Result<(), Error> {
        loop {
            match self.sc.peek() {
                Some(c) if c.is_whitespace() => {
                    self.sc.bump();
                }
                Some('/') if self.sc.peek_at(1) == Some('/') => {
                    if self.plain_css {
                        return Err(Error::at(
                            "Silent comments aren't allowed in plain CSS.",
                            self.sc.position(),
                        ));
                    }
                    while let Some(c) = self.sc.peek() {
                        if c == '\n' {
                            break;
                        }
                        self.sc.bump();
                    }
                }
                Some('/') if self.sc.peek_at(1) == Some('*') => {
                    let start = self.sc.position();
                    let col0 = start.col - 1;
                    self.sc.bump();
                    self.sc.bump();
                    let pieces = self.parse_loud_comment_body()?;
                    let end_line = self.sc.position().line as u32;
                    out.push(Stmt::Comment(
                        pieces,
                        SrcLines {
                            file: 0,
                            start: start.line as u32,
                            end: end_line,
                            col: start.col as u32,
                            // The `/*`'s 0-based column, for source-map output.
                            start_col: col0 as u32,
                            map_file: 0,
                            map_line: 0,
                        },
                    ));
                }
                _ => break,
            }
        }
        Ok(())
    }

    /// Look ahead to decide whether the next statement is a rule (a
    /// top-level `{` comes first) or a declaration (`;`/`}` comes first),
    /// skipping over strings, comments, interpolation and bracket pairs.
    ///
    /// A top-level `{` after a `property:` is a *nested property set* (a
    /// declaration with a block) rather than a style rule when the value is
    /// empty (`b: { … }` / `b:{ … }`) or whitespace/comment immediately
    /// follows the colon (`b: c { … }`). Otherwise (`a:hover { … }`) the `{`
    /// opens a style rule — matching dart-sass declaration disambiguation.
    fn classify(&self) -> NextKind {
        let cs = self.sc.rest();
        let mut i = 0;
        let mut paren = 0i32;
        let mut bracket = 0i32;
        // Index just past the first top-level `:`, plus whether whitespace or a
        // comment immediately follows it. `None` until the colon is seen.
        let mut after_colon: Option<usize> = None;
        let mut ws_after_colon = false;
        // Whether the statement's first non-whitespace characters are `--`: a
        // custom-property name. With a top-level `:` it is always a custom
        // declaration (`--ambiguous:foo {…}`), never a style rule.
        let starts_custom = {
            let first = cs.iter().position(|c| !c.is_whitespace());
            matches!(first, Some(p) if cs.get(p) == Some(&'-') && cs.get(p + 1) == Some(&'-'))
        };
        while i < cs.len() {
            let c = cs[i];
            match c {
                '"' | '\'' => {
                    let q = c;
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' {
                            i += 1;
                        }
                        i += 1;
                    }
                    i += 1;
                    continue;
                }
                '/' if cs.get(i + 1) == Some(&'/') => {
                    while i < cs.len() && cs[i] != '\n' {
                        i += 1;
                    }
                    continue;
                }
                '/' if cs.get(i + 1) == Some(&'*') => {
                    i += 2;
                    while i + 1 < cs.len() && !(cs[i] == '*' && cs[i + 1] == '/') {
                        i += 1;
                    }
                    i += 2;
                    continue;
                }
                '#' if cs.get(i + 1) == Some(&'{') => {
                    i += 2;
                    let mut depth = 1;
                    while i < cs.len() && depth > 0 {
                        match cs[i] {
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                        i += 1;
                    }
                    continue;
                }
                // A CSS escape: the next character (`something\:`) is part of
                // the identifier, never a declaration colon.
                '\\' => {
                    i += 2;
                    continue;
                }
                '(' => paren += 1,
                ')' => paren -= 1,
                '[' => bracket += 1,
                ']' => bracket -= 1,
                ':' if paren == 0 && bracket == 0 && after_colon.is_none() => {
                    // A custom-property name with a `:` is always a declaration,
                    // even when a `{` follows (`--ambiguous:foo {…}`).
                    if starts_custom {
                        return NextKind::Declaration;
                    }
                    after_colon = Some(i + 1);
                    ws_after_colon = matches!(
                        cs.get(i + 1),
                        Some(c) if c.is_whitespace())
                        || matches!(
                            (cs.get(i + 1), cs.get(i + 2)),
                            (Some('/'), Some('*')) | (Some('/'), Some('/'))
                        );
                }
                '{' if paren == 0 && bracket == 0 => {
                    return match after_colon {
                        // No `property:` before this `{` — an ordinary rule.
                        None => NextKind::Rule,
                        // `property:` then a block: a nested property set if the
                        // value is empty, or whitespace/comment followed the
                        // colon; otherwise (`a:hover {`) a style rule.
                        Some(start) => {
                            let empty_value = cs[start..i].iter().all(|c| c.is_whitespace())
                                || value_is_only_comments(&cs[start..i]);
                            if empty_value || ws_after_colon {
                                NextKind::Declaration
                            } else {
                                NextKind::Rule
                            }
                        }
                    };
                }
                ';' if paren == 0 && bracket == 0 => return NextKind::Declaration,
                '}' if paren == 0 && bracket == 0 => return NextKind::Declaration,
                _ => {}
            }
            i += 1;
        }
        NextKind::Declaration
    }

    fn parse_rule(&mut self) -> Result<Stmt, Error> {
        let selector_pos = self.sc.position();
        let saved_spans = std::mem::take(&mut self.interp_spans);
        let saved_collect = std::mem::replace(&mut self.collect_interp_spans, true);
        // A top-level `!` is not valid in a selector: dart-sass stops the
        // selector there and then fails to find the `{` (`a !important {…}` →
        // `expected "{".`). It is only a stop at depth 0 — a `!` inside an
        // attribute selector (`[a="x!y"]`) or a string is consumed normally.
        let selector = self.parse_template_mode(&['{', '!'], CommentMode::Strip);
        self.collect_interp_spans = saved_collect;
        let selector_interp_spans = std::mem::replace(&mut self.interp_spans, saved_spans);
        let selector = selector?;
        let brace_line = self.sc.position().line as u32;
        if !self.sc.eat('{') {
            return Err(Error::at("expected \"{\".", self.sc.position()));
        }
        self.block_depth += 1;
        let body = self.parse_statements(false);
        self.block_depth -= 1;
        let body = body?;
        if !self.sc.eat('}') {
            return Err(Error::at("expected \"}\"", self.sc.position()));
        }
        let end_line = self.sc.position().line as u32;
        Ok(Stmt::Rule(Rule {
            selector,
            body,
            selector_pos,
            selector_interp_spans,
            brace_line,
            end_line,
        }))
    }

    fn parse_declaration(&mut self) -> Result<Stmt, Error> {
        let pos = self.sc.position();
        // An IE property hack may start with a single punctuation character;
        // `*x`/`.x`/`#x` fall out of template parsing naturally, but a leading
        // `:` (`:x: y`) must be consumed up front so the property name doesn't
        // terminate at it (dart-sass `_declarationOrBuffer` reads one leading
        // `:`/`*`/`.`/`#` before the identifier).
        let colon_hack = self.sc.peek() == Some(':')
            && matches!(self.sc.peek_at(1), Some(c) if c.is_alphanumeric() || c == '-' || c == '_' || c == '\\');
        if colon_hack {
            self.sc.bump();
        }
        let mut property = self.parse_template_mode(&[':'], CommentMode::DeclName)?;
        if colon_hack {
            match property.first_mut() {
                Some(TplPiece::Lit(lit)) => *lit = Rc::from(format!(":{lit}")),
                _ => property.insert(0, TplPiece::Lit(":".into())),
            }
        }
        if !self.sc.eat(':') {
            return Err(Error::at("expected \":\" in declaration", self.sc.position()));
        }
        // A declaration whose name *literally* begins with `--` is a custom
        // property: its value is captured verbatim (only `#{…}` interpolation
        // resolves, no SassScript), and a trailing `{` is part of the value —
        // never a nested property set.
        if property_is_literal_custom(&property) {
            // Source-map: the verbatim value text starts right after the colon,
            // leading whitespace included (dart's `node.value.span`).
            let value_pos = self.sc.position();
            let value = self.parse_custom_property_value()?;
            let end_line = self.sc.position().line as u32;
            // The value reader stops at `;`, `}`, the end of the file — or at a
            // closer with no opener, which dart reports as a missing separator
            // (`--x: ];` fails at the `]`, not at the end of the file).
            if !matches!(self.sc.peek(), None | Some(';') | Some('}')) {
                return Err(Error::at("expected \";\".", self.sc.position()));
            }
            self.sc.eat(';');
            return Ok(Stmt::CustomDecl(CustomDecl {
                property,
                value,
                pos,
                end_line,
                value_pos,
            }));
        }
        let ws_after_colon = self.skip_ws_inline();
        // Bare nested property set: `prop: { … }` / `prop:{ … }` (no value).
        if self.sc.peek() == Some('{') {
            let body = self.parse_property_set_body()?;
            return Ok(Stmt::PropertySet(PropertySet {
                property,
                value: None,
                important: false,
                body,
                pos,
            }));
        }
        // Source-map: where the value's own text begins (dart's
        // `CssValue.span.start` for a declaration value). Captured before
        // `parse_value` consumes it.
        let value_pos = self.sc.position();
        let value = self.parse_value()?;
        // The line where the declaration's span ends, for the serializer's
        // trailing-comment rule — captured before whitespace is skipped (an
        // `!important` flag extends the span).
        let mut end_line = self.sc.position().line as u32;
        let mut important = false;
        self.skip_ws_inline();
        if self.sc.peek() == Some('!') {
            // `!important` is consumed by the expression layer as a value
            // term, so a `!` here is a stray flag (`!default` after a plain
            // declaration) — dart stops the declaration at the `!` and fails
            // wanting the terminator.
            let bang_pos = self.sc.position();
            if !self.looking_at_important() {
                return Err(Error::at("expected \";\".", bang_pos));
            }
            self.sc.bump();
            self.skip_ws_inline();
            let _ = self.read_ident_name();
            important = true;
            end_line = self.sc.position().line as u32;
        }
        // Value-plus-block nested property set: `prop: value [!important] { … }`.
        // Only a value separated from the colon by whitespace (or comment)
        // qualifies — `prop:value { … }` is a style rule.
        if ws_after_colon {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if self.sc.peek() == Some('{') {
                let body = self.parse_property_set_body()?;
                return Ok(Stmt::PropertySet(PropertySet {
                    property,
                    value: Some(value),
                    important,
                    body,
                    pos,
                }));
            }
            self.sc.reset(mark);
        }
        self.skip_ws_inline();
        self.sc.eat(';');
        Ok(Stmt::Decl(Declaration {
            property,
            value,
            important,
            pos,
            end_line,
            value_pos,
        }))
    }

    /// Parse the `{ … }` block of a nested property set (the cursor is at `{`),
    /// consuming an optional trailing `;` so a following sibling parses cleanly
    /// (`b: { c: { d: e }; f: g }`).
    fn parse_property_set_body(&mut self) -> Result<Vec<Stmt>, Error> {
        if self.plain_css {
            return Err(Error::at(
                "Nested declarations aren't allowed in plain CSS.",
                self.sc.position(),
            ));
        }
        self.sc.bump(); // '{'
        self.block_depth += 1;
        let body = self.parse_statements(false);
        self.block_depth -= 1;
        let body = body?;
        // Unknown at-rules aren't allowed in a nested property set.
        reject_at_rules_in(&body)?;
        // dart's `_declarationChild` parses every non-`@` child of a nested
        // property set as a declaration, so a style rule there is its
        // `expected ":".` (the selector reads as a property name).
        fn reject_rules_in(stmts: &[Stmt]) -> Result<(), Error> {
            for s in stmts {
                match s {
                    Stmt::Rule(_) => {
                        return Err(Error::unpositioned("expected \":\"."));
                    }
                    Stmt::If(branches) => {
                        for b in branches {
                            reject_rules_in(&b.body)?;
                        }
                    }
                    Stmt::For { body, .. } | Stmt::Each { body, .. } | Stmt::While { body, .. } => {
                        reject_rules_in(body)?;
                    }
                    _ => {}
                }
            }
            Ok(())
        }
        reject_rules_in(&body)?;
        if !self.sc.eat('}') {
            return Err(Error::at("expected \"}\".", self.sc.position()));
        }
        let mark = self.sc.mark();
        self.skip_ws_inline();
        if !self.sc.eat(';') {
            self.sc.reset(mark);
        }
        Ok(body)
    }

    fn parse_var_decl(&mut self) -> Result<Stmt, Error> {
        let pos = self.sc.position();
        if self.plain_css {
            return Err(Error::at("Sass variables aren't allowed in plain CSS.", pos));
        }
        // An optional `ns.` prefix: `ns.$name: value` assigns to a module
        // variable. `peek_namespaced_var_decl` guarantees the shape.
        let mut namespace = None;
        if self.sc.peek() != Some('$') {
            namespace = Some(self.read_ident_name()?);
            self.sc.eat('.');
        }
        self.sc.bump(); // '$'
        let name = self.read_variable_name()?;
        self.skip_ws_inline();
        if !self.sc.eat(':') {
            return Err(Error::at(
                "expected \":\" after variable name",
                self.sc.position(),
            ));
        }
        self.skip_ws_inline();
        // Source-map: where the assigned value's text begins. This is the span
        // dart stores in `Environment._variableNodes` as the variable's
        // definition node, which a later bare `$name` reference resolves to.
        let value_pos = self.sc.position();
        let value = self.parse_value()?;
        let mut is_default = false;
        let mut is_global = false;
        loop {
            self.skip_ws_inline();
            if self.sc.peek() == Some('!') {
                self.sc.bump();
                let flag = self.read_ident_name()?;
                match flag.as_str() {
                    "default" => is_default = true,
                    "global" => is_global = true,
                    other => return Err(Error::at(format!("invalid flag !{other}"), pos)),
                }
            } else {
                break;
            }
        }
        self.skip_ws_inline();
        self.sc.eat(';');
        Ok(Stmt::VarDecl(VarDecl {
            name,
            value,
            is_default,
            is_global,
            namespace,
            value_pos,
        }))
    }

    /// Whether the scanner is at the start of a namespaced variable assignment
    /// `ns.$name` (an identifier, then `.`, then `$`). Does not consume input.
    fn peek_namespaced_var_decl(&self) -> bool {
        let mut i = 0;
        // Leading identifier.
        match self.sc.peek_at(0) {
            Some(c) if c == '-' || c == '_' || c.is_ascii_alphabetic() || !c.is_ascii() => {}
            _ => return false,
        }
        while matches!(self.sc.peek_at(i), Some(c) if is_ident_char(c)) {
            i += 1;
        }
        if i == 0 || self.sc.peek_at(i) != Some('.') {
            return false;
        }
        self.sc.peek_at(i + 1) == Some('$')
    }
}
