//! `@for` / `@each` / `@while` / `@if`-`@else` control-flow statement
//! parsing. Extracted verbatim from [`super`].

use super::*;

impl Parser {
    /// `@for $i from <start> through|to <end> { … }`. Bounds are parsed at
    /// the additive level so the `through`/`to` keywords are not swallowed
    /// into a space list.
    pub(super) fn parse_for(&mut self) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        if !self.sc.eat('$') {
            return Err(Error::at("expected a variable after @for", self.sc.position()));
        }
        let var = self.read_variable_name()?;
        if !self.try_keyword("from") {
            return Err(Error::at("expected \"from\"", self.sc.position()));
        }
        self.skip_ws_inline();
        // Source-map: the loop variable's definition span is `from`'s.
        let from_pos = self.sc.position();
        let from = self.additive()?;
        let inclusive = if self.try_keyword("through") {
            true
        } else if self.try_keyword("to") {
            false
        } else {
            return Err(Error::at("expected \"through\" or \"to\"", self.sc.position()));
        };
        self.skip_ws_inline();
        let to = self.additive()?;
        let body = self.parse_braced_body()?;
        Ok(Stmt::For {
            var,
            from,
            to,
            inclusive,
            body,
            from_pos,
        })
    }

    /// `@each $v[, $k…] in <list> { … }`.
    pub(super) fn parse_each(&mut self) -> Result<Stmt, Error> {
        let mut vars = Vec::new();
        loop {
            self.skip_ws_inline();
            if !self.sc.eat('$') {
                return Err(Error::at("expected a variable after @each", self.sc.position()));
            }
            vars.push(self.read_variable_name()?);
            self.skip_ws_inline();
            if self.sc.eat(',') {
                continue;
            }
            break;
        }
        if !self.try_keyword("in") {
            return Err(Error::at("expected \"in\"", self.sc.position()));
        }
        self.skip_ws_inline();
        // Source-map: every `@each` variable's definition span is the list's.
        let list_pos = self.sc.position();
        let list = self.parse_value()?;
        let body = self.parse_braced_body()?;
        Ok(Stmt::Each {
            vars,
            list,
            body,
            list_pos,
        })
    }

    /// `@while <cond> { … }`.
    pub(super) fn parse_while(&mut self) -> Result<Stmt, Error> {
        self.skip_ws_inline();
        let cond = self.parse_value()?;
        let body = self.parse_braced_body()?;
        Ok(Stmt::While { cond, body })
    }

    /// Parse an `@if <cond> { … }` with its `@else if` / `@else` chain.
    pub(super) fn parse_if(&mut self) -> Result<Stmt, Error> {
        let mut branches = Vec::new();
        self.skip_ws_inline();
        let cond = self.parse_value()?;
        let body = self.parse_braced_body()?;
        branches.push(IfBranch {
            cond: Some(cond),
            body,
        });
        loop {
            let mark = self.sc.mark();
            let mut discard = Vec::new();
            self.skip_trivia(&mut discard)?;
            if self.sc.peek() != Some('@') {
                self.sc.reset(mark);
                break;
            }
            self.sc.bump(); // '@'
                            // `@elseif` is a deprecated spelling of `@else if` (dart still
                            // accepts it with an [elseif] deprecation warning).
            let kw = self.read_ident_name().unwrap_or_default();
            if kw == "elseif" {
                self.skip_ws_inline();
                let cond = self.parse_value()?;
                let body = self.parse_braced_body()?;
                branches.push(IfBranch {
                    cond: Some(cond),
                    body,
                });
                continue;
            }
            if kw != "else" {
                self.sc.reset(mark);
                break;
            }
            if self.try_keyword("if") {
                self.skip_ws_inline();
                let cond = self.parse_value()?;
                let body = self.parse_braced_body()?;
                branches.push(IfBranch {
                    cond: Some(cond),
                    body,
                });
            } else {
                let body = self.parse_braced_body()?;
                branches.push(IfBranch { cond: None, body });
                break;
            }
        }
        Ok(Stmt::If(branches))
    }
}
