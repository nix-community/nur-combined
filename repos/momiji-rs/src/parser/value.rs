//! The SCSS value / expression parser: a Pratt-style recursive-descent over
//! SassScript expressions (comma/space lists, the operator-precedence ladder,
//! atoms, calls, numbers, colors, strings, `if()`). Byte-sensitive — feeds the
//! value serialization path. Extracted verbatim from [`super`].

use super::*;

impl Parser {
    // ---- value expressions -------------------------------------------

    pub(super) fn parse_value(&mut self) -> Result<Expr, Error> {
        // dart-sass skips whitespace AND comments before an expression
        // (`singleInterpolation` runs `whitespace()` first), so `#{ a }` and
        // `"#{ a /* c */ }"` parse — a comment ends at the first `*/` and is
        // never itself scanned for interpolation. Established callers skip
        // before calling, making this a no-op for them.
        self.skip_ws_inline();
        self.comma_list()
    }

    pub(super) fn at_value_terminator(&self) -> bool {
        match self.sc.peek() {
            None | Some(',') | Some(';') | Some('}') | Some(')') | Some(']') | Some('{') => true,
            // `!important` is a value term (dart `_importantExpression`); any
            // other `!` (a `!default`/`!global` flag) ends the value.
            Some('!') => !self.looking_at_important(),
            _ => false,
        }
    }

    /// Whether the scanner is positioned at the start of a value atom (the
    /// dispatch set of [`primary`]/[`unary`]). Used to decide whether a quoted
    /// string adjacency continues a space-list: only when a real atom follows,
    /// not a separator/operator such as `:` (a map key-value colon) or `=`.
    fn at_value_atom_start(&self) -> bool {
        match self.sc.peek() {
            Some('.') => matches!(self.sc.peek_at(1), Some(d) if d.is_ascii_digit()),
            Some('!') => self.looking_at_important(),
            Some(c) => {
                c.is_ascii_digit()
                    || matches!(c, '$' | '#' | '"' | '\'' | '(' | '[' | '&' | '+' | '-' | '\\')
                    || is_ident_char(c)
            }
            None => false,
        }
    }

    /// Whether the cursor sits on `!` followed (after optional whitespace) by
    /// the identifier `important` (case-insensitively) — dart's
    /// `_importantExpression` lookahead, so a `!default`/`!global` flag never
    /// reads as a value term.
    pub(super) fn looking_at_important(&self) -> bool {
        if self.sc.peek() != Some('!') {
            return false;
        }
        let mut i = 1;
        while matches!(self.sc.peek_at(i), Some(' ' | '\t' | '\n' | '\r' | '\x0c')) {
            i += 1;
        }
        for ch in "important".chars() {
            match self.sc.peek_at(i) {
                Some(c) if c.eq_ignore_ascii_case(&ch) => i += 1,
                _ => return false,
            }
        }
        // The identifier must end here (`!importantx` is not the keyword).
        !matches!(self.sc.peek_at(i), Some(c) if is_ident_char(c))
    }

    fn comma_list(&mut self) -> Result<Expr, Error> {
        let first = self.space_list()?;
        let mut rest = Vec::new();
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if self.sc.peek() == Some(',') {
                self.sc.bump();
                self.skip_ws_inline();
                if self.at_value_terminator() {
                    break;
                }
                rest.push(self.space_list()?);
            } else {
                self.sc.reset(mark);
                break;
            }
        }
        if rest.is_empty() {
            Ok(first)
        } else {
            let mut items = Vec::with_capacity(rest.len() + 1);
            items.push(first);
            items.extend(rest);
            Ok(Expr::List {
                items,
                sep: ListSep::Comma,
                bracketed: false,
            })
        }
    }

    pub(super) fn space_list(&mut self) -> Result<Expr, Error> {
        let first = self.or_expr()?;
        let mut prev_was_string = expr_is_quoted_string(&first);
        let mut rest = Vec::new();
        loop {
            // A `?`-wildcard unicode-range token immediately followed by an
            // identifier inserts an implicit space separator (`U+A?BCDE` ->
            // `U+A? BCDE`), so continue without consuming whitespace.
            if std::mem::take(&mut self.pending_unicode_split) {
                let e = self.or_expr()?;
                prev_was_string = expr_is_quoted_string(&e);
                rest.push(e);
                continue;
            }
            let mark = self.sc.mark();
            let had_ws = self.skip_ws_inline();
            // Two atoms that touch with no whitespace normally end the list, but
            // dart-sass forms an implicit space-separated list when a quoted
            // string abuts an adjacent atom: `"["'foo'"]"` -> `"[" "foo" "]"`,
            // `gamme "'"delta` -> `gamme "'" delta`. This applies when the
            // previous atom was a quoted string, or the next atom begins one
            // (any binary operator was already consumed by `or_expr`, so a
            // remaining non-terminator atom here is a genuine list element).
            let adjacent_string = !had_ws
                && self.at_value_atom_start()
                && (prev_was_string || matches!(self.sc.peek(), Some('"') | Some('\'')));
            // dart-sass's space list doesn't require whitespace between atoms
            // at all (`_spaceListOrValue` loops while `lookingAtExpression`):
            // `(x)y` is `x y`, `5px(3)` is `5px 3`. A touching atom start
            // begins a new term. (Operators were already consumed by
            // `or_expr`, and an ident followed by `(` was consumed as a
            // call, so what reaches here is a genuine new atom.)
            let adjacent_atom = !had_ws && self.at_value_atom_start();
            // An interpolation directly after a complete atom begins a new
            // term with an implicit separator (`1#{0}` is the list `1 0`), as
            // does a `-#{…}` interpolated identifier (`10-#{10}` → `10 -10`);
            // an interpolation that continues an identifier was already
            // consumed by the identifier template, so a `#{` seen here is a
            // fresh atom.
            let adjacent_interp = !had_ws
                && ((self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{'))
                    || (self.sc.peek() == Some('-')
                        && self.sc.peek_at(1) == Some('#')
                        && self.sc.peek_at(2) == Some('{')));
            // A lone `=` (not `==`) ends the space-list so an enclosing
            // argument list can apply the single-`=` Microsoft-filter operator
            // (`foo(a = b)`); `==` stays the equality operator, parsed above.
            // A `:` likewise ends it — a map key may be separated from its
            // colon by whitespace (`(b \n : c)`), which the paren handler
            // then resolves as a map.
            // A `...` splat ends the list too — the value may be separated
            // from its `...` by whitespace (`a($d ...)`, `a($d\n  ...)`).
            if (!had_ws && !adjacent_string && !adjacent_interp && !adjacent_atom)
                || self.at_value_terminator()
                || (self.sc.peek() == Some('=') && self.sc.peek_at(1) != Some('='))
                || (self.sc.peek() == Some(':') && self.sc.peek_at(1) != Some(':'))
                || (self.sc.peek() == Some('.')
                    && self.sc.peek_at(1) == Some('.')
                    && self.sc.peek_at(2) == Some('.'))
            {
                self.sc.reset(mark);
                break;
            }
            let e = self.or_expr()?;
            prev_was_string = expr_is_quoted_string(&e);
            rest.push(e);
        }
        if rest.is_empty() {
            Ok(first)
        } else {
            let mut items = Vec::with_capacity(rest.len() + 1);
            items.push(first);
            items.extend(rest);
            Ok(Expr::List {
                items,
                sep: ListSep::Space,
                bracketed: false,
            })
        }
    }

    // Operator precedence, lowest to highest: `or`, `and`, `not`, equality
    // (== !=), relational (< > <= >=), then additive (below). The logical
    // keywords are bare identifiers recognized only in operator position.

    pub(super) fn or_expr(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.and_expr()?;
        // In plain CSS `or`/`and`/`not` are ordinary identifiers, not operators.
        while !self.plain_css && self.try_keyword("or") {
            self.skip_ws_inline();
            let pos = self.sc.position();
            let rhs = self.and_expr()?;
            lhs = Expr::Binary {
                op: BinOp::Or,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                pos,
            };
        }
        Ok(lhs)
    }

    fn and_expr(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.equality()?;
        while !self.plain_css && self.try_keyword("and") {
            self.skip_ws_inline();
            let pos = self.sc.position();
            let rhs = self.equality()?;
            lhs = Expr::Binary {
                op: BinOp::And,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                pos,
            };
        }
        Ok(lhs)
    }

    fn equality(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.relational()?;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            let op = if self.sc.peek() == Some('=') && self.sc.peek_at(1) == Some('=') {
                self.sc.bump();
                self.sc.bump();
                BinOp::Eq
            } else if self.sc.peek() == Some('!') && self.sc.peek_at(1) == Some('=') {
                self.sc.bump();
                self.sc.bump();
                BinOp::Neq
            } else {
                self.sc.reset(mark);
                break;
            };
            if self.plain_css {
                return Err(Error::at(
                    "Operators aren't allowed in plain CSS.",
                    self.sc.position(),
                ));
            }
            let pos = self.sc.position();
            self.skip_ws_inline();
            let rhs = self.relational()?;
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                pos,
            };
        }
        Ok(lhs)
    }

    fn relational(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.additive()?;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            let op = match (self.sc.peek(), self.sc.peek_at(1)) {
                (Some('<'), Some('=')) => {
                    self.sc.bump();
                    self.sc.bump();
                    BinOp::Le
                }
                (Some('>'), Some('=')) => {
                    self.sc.bump();
                    self.sc.bump();
                    BinOp::Ge
                }
                (Some('<'), _) => {
                    self.sc.bump();
                    BinOp::Lt
                }
                (Some('>'), _) => {
                    self.sc.bump();
                    BinOp::Gt
                }
                _ => {
                    self.sc.reset(mark);
                    break;
                }
            };
            if self.plain_css {
                return Err(Error::at(
                    "Operators aren't allowed in plain CSS.",
                    self.sc.position(),
                ));
            }
            let pos = self.sc.position();
            self.skip_ws_inline();
            let rhs = self.additive()?;
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
                pos,
            };
        }
        Ok(lhs)
    }

    /// Consume the bare keyword `kw` (`and`/`or`/`not`) if it appears next
    /// in operator position (after optional whitespace), matched as a whole
    /// identifier. Restores the cursor and returns false otherwise.
    pub(super) fn try_keyword(&mut self, kw: &str) -> bool {
        let mark = self.sc.mark();
        self.skip_ws_inline();
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
        if word == kw {
            true
        } else {
            self.sc.reset(mark);
            false
        }
    }

    pub(super) fn additive(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.multiplicative()?;
        loop {
            // A `?`-wildcard unicode-range token is terminal: a directly
            // following `-name` begins a fresh space-list element (handled by
            // `space_list`), not a subtraction, so don't consume the operator.
            if self.pending_unicode_split {
                break;
            }
            let mark = self.sc.mark();
            let had_ws = self.skip_ws_inline();
            let op = match self.sc.peek() {
                Some('+') => Some(BinOp::Add),
                Some('-') => Some(BinOp::Sub),
                _ => None,
            };
            // A `-` directly followed by `#{` begins an interpolated
            // identifier (`10-#{10}` is the list `10 -10`), never a
            // subtraction — regardless of surrounding whitespace. After a
            // quoted string a `-` that begins an identifier (`"q"-l`) likewise
            // starts a new term (dart-sass can't continue a string token).
            if matches!(op, Some(BinOp::Sub)) {
                let interp_next = self.sc.peek_at(1) == Some('#') && self.sc.peek_at(2) == Some('{');
                let ident_next = matches!(self.sc.peek_at(1), Some(c) if c.is_alphabetic() || c == '_' || c == '-' || c == '\\');
                // `--` always begins an identifier (a CSS custom-ident like
                // `--em-2--em`), never a subtraction: `1--em` is the space
                // list `1 --em`.
                let custom_ident_next = self.sc.peek_at(1) == Some('-');
                if interp_next || custom_ident_next || (expr_is_quoted_string(&lhs) && ident_next) {
                    self.sc.reset(mark);
                    break;
                }
            }
            match op {
                Some(op) => {
                    // Whitespace OR a comment (`/* */`, `//`) immediately
                    // after the operator counts as separation, matching
                    // dart-sass's `1 /**/+/**/ 2` handling.
                    let ws_after = matches!(self.sc.peek_at(1), Some(c) if c.is_whitespace())
                        || (self.sc.peek_at(1) == Some('/')
                            && matches!(self.sc.peek_at(2), Some('*') | Some('/')));
                    // dart-sass: `+`/`-` in operator position is binary unless
                    // it has whitespace before but NOT after AND begins a new
                    // space-list term. A `+` here is ALWAYS binary (`c +d` is
                    // `c + d`, the strict-unary deprecation case); a `-` starts
                    // a new term only when it begins a number (`1 -2`) or an
                    // identifier (`c -d`, `-#{…}`) — otherwise (`c -$d`,
                    // `10 -(2)`, `c -"x"`) it is binary too. Inside a
                    // calculation it must be surrounded on both sides.
                    let binary = if self.calc_depth > 0 {
                        had_ws && ws_after
                    } else if !had_ws || ws_after {
                        true
                    } else {
                        match op {
                            BinOp::Add => true,
                            _ => {
                                let n1 = self.sc.peek_at(1);
                                let starts_term = matches!(n1, Some(c) if c.is_ascii_digit() || c == '.' || c == '-' || c == '_' || c.is_alphabetic())
                                    || (n1 == Some('#') && self.sc.peek_at(2) == Some('{'))
                                    || n1 == Some('\\');
                                !starts_term
                            }
                        }
                    };
                    if binary {
                        // Outside a calculation, `+`/`-` is a Sass operator,
                        // which plain CSS forbids (inside calc it is real math).
                        if self.plain_css && self.calc_depth == 0 {
                            return Err(Error::at(
                                "Operators aren't allowed in plain CSS.",
                                self.sc.position(),
                            ));
                        }
                        let pos = self.sc.position();
                        self.sc.bump();
                        self.skip_ws_inline();
                        let rhs = self.multiplicative()?;
                        lhs = Expr::Binary {
                            op,
                            lhs: Box::new(lhs),
                            rhs: Box::new(rhs),
                            pos,
                        };
                    } else if self.calc_depth > 0 {
                        // Inside calc(), `+`/`-` must be whitespace-surrounded.
                        return Err(Error::at(
                            "\"+\" and \"-\" must be surrounded by whitespace in calculations.",
                            self.sc.position(),
                        ));
                    } else {
                        self.sc.reset(mark);
                        break;
                    }
                }
                None => {
                    self.sc.reset(mark);
                    break;
                }
            }
        }
        Ok(lhs)
    }

    /// Whether the `%` at the cursor is followed (after whitespace) by
    /// something that can start an operand — otherwise it's a lone `%` token.
    fn percent_has_rhs(&self) -> bool {
        let mut i = 1;
        while matches!(self.sc.peek_at(i), Some(c) if c.is_whitespace()) {
            i += 1;
        }
        !matches!(
            self.sc.peek_at(i),
            None | Some('}') | Some(')') | Some(']') | Some(';') | Some(',') | Some('!')
        )
    }

    fn multiplicative(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.unary()?;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            let op = match self.sc.peek() {
                Some('*') => Some(BinOp::Mul),
                // `%` is modulo only when an operand follows; a trailing `%`
                // (`a {b: c %}`, `f(g %)`) is a lone unquoted-string token
                // handled by the space-list/primary layer (dart-sass).
                Some('%') if self.percent_has_rhs() => Some(BinOp::Mod),
                _ => None,
            };
            // `/` is the deprecated slash operator (handled specially), but
            // never treat `*/` or a `/` opening a comment as an operator —
            // except in plain CSS, where `//` is two slash separators
            // (`1///bar` keeps all three).
            if op.is_none()
                && self.sc.peek() == Some('/')
                && (self.sc.peek_at(1) != Some('/') || self.plain_css)
                && self.sc.peek_at(1) != Some('*')
            {
                let pos = self.sc.position();
                self.sc.bump();
                self.skip_ws_inline();
                let rhs = self.unary()?;
                // Inside calc() `/` is always real division; elsewhere it
                // keeps the slash spelling between number literals.
                let slash = self.calc_depth == 0 && is_slash_operand(&lhs) && is_slash_operand(&rhs);
                lhs = Expr::Div {
                    lhs: Box::new(lhs),
                    rhs: Box::new(rhs),
                    slash,
                    pos,
                };
                continue;
            }
            match op {
                Some(op) => {
                    // `*`/`%` are Sass operators (real math inside calc only).
                    if self.plain_css && self.calc_depth == 0 {
                        return Err(Error::at(
                            "Operators aren't allowed in plain CSS.",
                            self.sc.position(),
                        ));
                    }
                    let pos = self.sc.position();
                    self.sc.bump();
                    self.skip_ws_inline();
                    let rhs = self.unary()?;
                    lhs = Expr::Binary {
                        op,
                        lhs: Box::new(lhs),
                        rhs: Box::new(rhs),
                        pos,
                    };
                }
                None => {
                    self.sc.reset(mark);
                    break;
                }
            }
        }
        Ok(lhs)
    }

    fn unary(&mut self) -> Result<Expr, Error> {
        // `not` is a unary operator over a single expression (dart-sass
        // `identifierLike` → `UnaryOperation(not, singleExpression())`), so it
        // binds tighter than every binary operator: `not 1 + 2` is
        // `(not 1) + 2` and `not $a == $b` is `(not $a) == $b`.
        if !self.plain_css && self.try_keyword("not") {
            self.skip_ws_inline();
            let operand = self.unary()?;
            return Ok(Expr::Unary {
                op: UnOp::Not,
                operand: Box::new(operand),
            });
        }
        // Inside a calculation a unary `+`/`-` is only legal as the sign of a
        // numeric literal written tight against the digit (`-1px`, `+3`,
        // `2 * +3`). Any other unary form — separated by whitespace (`- 1px`),
        // or applied to a parenthesis/variable (`-(1px)`, `-$x`) — is rejected
        // by dart-sass ("This expression can't be used in a calculation."). A
        // tight `-`/`+` before an identifier (`-var(--c)`, `-webkit-x`) is part
        // of the identifier and is handled by `primary`, not here.
        let in_calc = self.calc_depth > 0;
        match self.sc.peek() {
            Some('-') => {
                // `-` directly before a number/paren/variable is numeric
                // negation (`-5`, `-(1)`, `-$x`); when separated by whitespace
                // it is the unary-minus operator over any value (`- red` ->
                // `-red`). A `-` immediately followed by an identifier char is
                // instead part of an identifier (`-webkit-foo`, `-red`) and
                // falls through to `primary`.
                if matches!(self.sc.peek_at(1), Some(c) if c.is_ascii_digit() || c == '.' || c == '$' || c == '(')
                {
                    if in_calc && matches!(self.sc.peek_at(1), Some('$') | Some('(')) {
                        return Err(Error::at(
                            "This expression can't be used in a calculation.",
                            self.sc.position(),
                        ));
                    }
                    self.sc.bump();
                    let operand = self.unary()?;
                    return Ok(Expr::Unary {
                        op: UnOp::Neg,
                        operand: Box::new(operand),
                    });
                }
                if matches!(self.sc.peek_at(1), Some(c) if c.is_whitespace()) {
                    if in_calc {
                        return Err(Error::at(
                            "This expression can't be used in a calculation.",
                            self.sc.position(),
                        ));
                    }
                    self.sc.bump();
                    self.skip_ws_inline();
                    let operand = self.unary()?;
                    return Ok(Expr::Unary {
                        op: UnOp::Neg,
                        operand: Box::new(operand),
                    });
                }
            }
            Some('+') => {
                // `+` is never part of an identifier, so a leading `+` in value
                // position is always the unary-plus operator (numeric identity
                // for a number, otherwise an unquoted `+<value>` string).
                // Optional whitespace separates it from its operand. A `+` with
                // no following operand falls through to `primary` (which reports
                // the error).
                let next = self.sc.peek_at(1);
                if in_calc {
                    // Only a tight `+` against a numeric literal is a legal sign
                    // inside a calculation; everything else is rejected.
                    if matches!(next, Some(c) if c.is_ascii_digit() || c == '.') {
                        self.sc.bump();
                        let operand = self.unary()?;
                        return Ok(Expr::Unary {
                            op: UnOp::Plus,
                            operand: Box::new(operand),
                        });
                    }
                    return Err(Error::at(
                        "This expression can't be used in a calculation.",
                        self.sc.position(),
                    ));
                }
                let starts_operand = matches!(next, Some(c)
                    if c.is_ascii_digit()
                        || c == '.'
                        || c == '$'
                        || c == '('
                        || c == '"'
                        || c == '\''
                        || c == '#'
                        || c == '+'
                        || c == '-'
                        || is_ident_char(c));
                if starts_operand || matches!(next, Some(c) if c.is_whitespace()) {
                    self.sc.bump();
                    self.skip_ws_inline();
                    let operand = self.unary()?;
                    return Ok(Expr::Unary {
                        op: UnOp::Plus,
                        operand: Box::new(operand),
                    });
                }
            }
            _ => {}
        }
        self.primary()
    }

    fn primary(&mut self) -> Result<Expr, Error> {
        match self.sc.peek() {
            Some(c) if c.is_ascii_digit() => self.parse_number(),
            Some('.') if matches!(self.sc.peek_at(1), Some(d) if d.is_ascii_digit()) => self.parse_number(),
            // `!important` (any case, whitespace after `!` allowed) is a value
            // term: the canonical unquoted string `!important` (dart
            // `_importantExpression`).
            Some('!') if self.looking_at_important() => {
                self.sc.bump();
                self.skip_ws_inline();
                let _ = self.read_ident_name()?;
                Ok(Expr::Ident(vec![TplPiece::Lit("!important".into())]))
            }
            Some('$') => {
                let pos = self.sc.position();
                if self.plain_css {
                    return Err(Error::at("Sass variables aren't allowed in plain CSS.", pos));
                }
                self.sc.bump();
                let name = self.read_variable_name()?;
                Ok(Expr::Var { name, pos })
            }
            Some('#') if self.sc.peek_at(1) == Some('{') => {
                let interp_mark = self.sc.mark();
                let interp_pos = self.sc.position();
                self.sc.bump();
                self.sc.bump();
                // Whitespace (including newlines) is permitted around the
                // interpolated expression: `#{ x }` / `#{\n  x\n}`.
                self.skip_ws_inline();
                let e = self.parse_interp_value()?;
                self.skip_ws_inline();
                if !self.sc.eat('}') {
                    return Err(Error::at("expected \"}\"", self.sc.position()));
                }
                self.reject_plain_css_interp(interp_mark)?;
                // A directly-following identifier character (or another
                // interpolation) continues the same interpolated identifier:
                // `#{1}0` is the single token `10`, `#{1}px` is `1px` (a
                // string), matching dart-sass `identifierLike`.
                if matches!(self.sc.peek(), Some(c) if is_ident_char(c))
                    || (self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{'))
                    || self.sc.peek() == Some('\\')
                {
                    let mut pieces = vec![TplPiece::Interp(e)];
                    pieces.extend(self.parse_ident_template_from(1)?);
                    // `(` directly after makes this a dynamic plain-CSS call
                    // (`#{1 + 1}foo(arg)` -> `2foo(arg)`).
                    if self.sc.peek() == Some('(') {
                        self.sc.bump();
                        let args = self.parse_args_after_paren()?;
                        return Ok(Expr::InterpFunc {
                            name: pieces,
                            args,
                            pos: interp_pos,
                        });
                    }
                    return Ok(Expr::Ident(pieces));
                }
                // A directly-following `(` makes the interpolation a dynamic
                // plain-CSS function name (`#{foo}(arg)` -> `foo(arg)`).
                if self.sc.peek() == Some('(') {
                    self.sc.bump();
                    let args = self.parse_args_after_paren()?;
                    return Ok(Expr::InterpFunc {
                        name: vec![TplPiece::Interp(e)],
                        args,
                        pos: interp_pos,
                    });
                }
                Ok(Expr::Interp(Box::new(e)))
            }
            Some('#') => self.parse_hex(),
            // A leading `/` begins a slash-separated value with an empty left
            // operand (`font: / 2` → `/2`, `(1, / 2)` → `1, /2`), matching
            // dart-sass — in plain CSS too (`1/ / /bar` is `1///bar`).
            Some('/') if self.calc_depth == 0 => {
                let pos = self.sc.position();
                self.sc.bump();
                self.skip_ws_inline();
                let rhs = self.multiplicative()?;
                Ok(Expr::Div {
                    lhs: Box::new(Expr::Ident(vec![TplPiece::Lit("".into())])),
                    rhs: Box::new(rhs),
                    slash: true,
                    pos,
                })
            }
            Some('"') | Some('\'') => {
                let pieces = self.parse_quoted_string()?;
                Ok(Expr::QuotedString(pieces))
            }
            Some('(') => {
                // A grouping paren is a Sass construct, but parens INSIDE a
                // calculation are legitimate CSS (`calc(2 * (1px + 1%))`).
                if self.plain_css && self.calc_depth == 0 {
                    return Err(Error::at(
                        "Parentheses aren't allowed in plain CSS.",
                        self.sc.position(),
                    ));
                }
                self.sc.bump();
                self.skip_ws_inline();
                if self.sc.peek() == Some(')') {
                    self.sc.bump();
                    return Ok(Expr::List {
                        items: Vec::new(),
                        sep: ListSep::Undecided,
                        bracketed: false,
                    });
                }
                // Parse the first sub-expression at the space-list level. A
                // following `:` makes this a map literal `(k: v, …)`; anything
                // else is an ordinary parenthesised expression / list.
                let first = self.space_list()?;
                self.skip_ws_inline();
                if self.sc.peek() == Some(':') && self.sc.peek_at(1) != Some(':') {
                    return self.parse_map_after_first_key(first);
                }
                let e = self.finish_paren_list(first)?;
                self.skip_ws_inline();
                if !self.sc.eat(')') {
                    return Err(Error::at("expected \")\"", self.sc.position()));
                }
                Ok(Expr::Paren(Box::new(e)))
            }
            Some('[') => self.parse_bracketed_list(),
            Some('&') => {
                if self.plain_css {
                    return Err(Error::at(
                        "The parent selector isn't allowed in plain CSS.",
                        self.sc.position(),
                    ));
                }
                self.sc.bump();
                Ok(Expr::Parent)
            }
            // CSS unicode-range token: `u`/`U` immediately followed by `+`
            // (no whitespace) commits to the unicode-range grammar, matching
            // dart-sass. `u + 1` (with whitespace) is ordinary concatenation
            // and falls through to the identifier branch below.
            Some('u') | Some('U') if self.sc.peek_at(1) == Some('+') => self.parse_unicode_range(),
            // Any non-ASCII code point starts an identifier (dart isNameStart).
            Some(c) if c.is_ascii_alphabetic() || c == '-' || c == '_' || (c as u32) >= 0x80 => {
                self.parse_ident_or_call()
            }
            // A value beginning with a CSS escape (`\41`, `\9`, …) is an
            // identifier; let `parse_ident_or_call` consume the escape run.
            Some('\\') => self.parse_ident_or_call(),
            // A lone `%` in value position (no left operand, so it is not the
            // modulo operator) is a standalone unquoted-string token, as in
            // dart-sass: `attr(c, %)` keeps the `%`, and `%foo` parses as the
            // two space-list elements `%` and `foo`. Only a single `%` is
            // consumed here.
            Some('%') => {
                self.sc.bump();
                Ok(Expr::Ident(vec![TplPiece::Lit("%".into())]))
            }
            // dart names what it WANTED here, whatever it found — a character
            // that cannot start one, or the end of the file.
            Some(_) | None => Err(Error::at("Expected expression.", self.sc.position())),
        }
    }

    /// Parse a CSS unicode-range token (`U+1A2B`, `U+4??`, `U+0-7F`, …). The
    /// leading `u`/`U` and `+` are not yet consumed; the caller guarantees the
    /// next two characters are `[uU]` and `+`. The original case is preserved
    /// verbatim and the token is lowered to an unquoted [`Expr::Ident`].
    ///
    /// Grammar (mirrors dart-sass `_unicodeRange`):
    ///   - 1–6 hex digits, optionally followed by `?` wildcards (total ≤ 6);
    ///   - if no `?` was seen, an optional `-` then 1–6 hex end digits;
    ///   - the token must end at a non-identifier boundary.
    fn parse_unicode_range(&mut self) -> Result<Expr, Error> {
        let start = self.sc.position();
        let mut s = String::new();
        if let Some(c) = self.sc.bump() {
            s.push(c); // `u` / `U`
        }
        if let Some(c) = self.sc.bump() {
            s.push(c); // `+`
        }
        // First range: up to 6 hex digits, then `?` wildcards (total ≤ 6).
        let mut count = 0usize;
        while count < 6 && matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit()) {
            if let Some(c) = self.sc.bump() {
                s.push(c);
            }
            count += 1;
        }
        let mut saw_question = false;
        while count < 6 && self.sc.peek() == Some('?') {
            self.sc.bump();
            s.push('?');
            saw_question = true;
            count += 1;
        }
        if count == 0 {
            return Err(Error::at("Expected hex digit or \"?\".", self.sc.position()));
        }
        // After a wildcard form, no `-end` range is allowed.
        if !saw_question && self.sc.peek() == Some('-') {
            self.sc.bump();
            s.push('-');
            let mut end_count = 0usize;
            while end_count < 6 && matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit()) {
                if let Some(c) = self.sc.bump() {
                    s.push(c);
                }
                end_count += 1;
            }
            if end_count == 0 {
                return Err(Error::at("Expected hex digit.", self.sc.position()));
            }
        }
        // When the 6-digit cap is reached but more hex digits or `?`
        // wildcards immediately follow, dart-sass reports "Expected at most 6
        // digits." (spanning the whole token). Below the cap the token simply
        // ends and any following identifier becomes the next list element.
        if count == 6 && matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit() || c == '?') {
            return Err(Error::at("Expected at most 6 digits.", start));
        }
        let token = Expr::Ident(vec![TplPiece::Lit(s.into())]);
        if !saw_question {
            // A plain or `-end` range is terminal: any directly-following
            // identifier char (a stray `-name` chain like `U+123-456-ABC`, or
            // a non-hex letter like `U+1234GH`) is "Expected end of
            // identifier." in dart-sass.
            if matches!(self.sc.peek(), Some(c) if is_ident_char(c))
                || (self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{'))
            {
                return Err(Error::at("Expected end of identifier.", self.sc.position()));
            }
            return Ok(token);
        }
        // After a `?` wildcard form, dart-sass does not allow a `-end` range,
        // so the wildcard token is terminal. A directly-following `-<digit>`
        // (no whitespace) continues as a subtraction whose unquoted-string
        // join yields `U+A?-1234`. A directly-following identifier
        // (`U+A?BCDE`, `U+A?-BCDE`) instead begins a fresh space-list element
        // with an implicit separator, handled by `space_list`.
        if self.sc.peek() == Some('-')
            && matches!(self.sc.peek_at(1), Some(c) if c.is_ascii_digit() || c == '.')
        {
            let pos = self.sc.position();
            self.sc.bump(); // '-'
            let rhs = self.multiplicative()?;
            return Ok(Expr::Binary {
                op: BinOp::Sub,
                lhs: Box::new(token),
                rhs: Box::new(rhs),
                pos,
            });
        }
        if matches!(self.sc.peek(), Some(c) if is_ident_char(c) || c == '.')
            || (self.sc.peek() == Some('#') && self.sc.peek_at(1) == Some('{'))
        {
            // Signal `space_list` to continue without requiring whitespace.
            self.pending_unicode_split = true;
        }
        Ok(token)
    }

    /// Continue a comma list whose first element (`first`) has already been
    /// parsed at the space-list level, stopping before the closing `)`. Used
    /// when the leading element of a parenthesised group turned out not to be
    /// a map key. With no following commas this is just `first`.
    /// Like [`finish_paren_list`], but the list ends at `]`.
    fn finish_bracket_list(&mut self, first: Expr) -> Result<Expr, Error> {
        let mut rest = Vec::new();
        let mut trailing = false;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if self.sc.peek() == Some(',') {
                self.sc.bump();
                self.skip_ws_inline();
                if self.sc.peek() == Some(']') {
                    trailing = true;
                    break;
                }
                rest.push(self.space_list()?);
            } else {
                self.sc.reset(mark);
                break;
            }
        }
        if rest.is_empty() && !trailing {
            return Ok(first);
        }
        let mut items = Vec::with_capacity(rest.len() + 1);
        items.push(first);
        items.extend(rest);
        Ok(Expr::List {
            items,
            sep: ListSep::Comma,
            bracketed: false,
        })
    }

    fn finish_paren_list(&mut self, first: Expr) -> Result<Expr, Error> {
        let mut rest = Vec::new();
        let mut trailing = false;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if self.sc.peek() == Some(',') {
                self.sc.bump();
                self.skip_ws_inline();
                if self.sc.peek() == Some(')') {
                    trailing = true;
                    break;
                }
                rest.push(self.space_list()?);
            } else {
                self.sc.reset(mark);
                break;
            }
        }
        if rest.is_empty() && !trailing {
            return Ok(first);
        }
        let mut items = Vec::with_capacity(rest.len() + 1);
        items.push(first);
        items.extend(rest);
        Ok(Expr::List {
            items,
            sep: ListSep::Comma,
            bracketed: false,
        })
    }

    /// Parse the remaining entries of a map literal after the first key was
    /// parsed and the `:` separator confirmed (but not yet consumed). Each
    /// entry is `key: value` at the space-list level, comma-separated, with an
    /// optional trailing comma before `)`.
    fn parse_map_after_first_key(&mut self, first_key: Expr) -> Result<Expr, Error> {
        let mut entries = Vec::new();
        // Consume the `:` for the first entry and read its value.
        self.sc.bump();
        self.skip_ws_inline();
        let first_val = self.space_list()?;
        entries.push((first_key, first_val));
        loop {
            self.skip_ws_inline();
            if !self.sc.eat(',') {
                break;
            }
            self.skip_ws_inline();
            if self.sc.peek() == Some(')') {
                break; // trailing comma
            }
            let key = self.space_list()?;
            self.skip_ws_inline();
            if !(self.sc.peek() == Some(':') && self.sc.peek_at(1) != Some(':')) {
                return Err(Error::at("expected \":\".", self.sc.position()));
            }
            self.sc.bump();
            self.skip_ws_inline();
            let val = self.space_list()?;
            entries.push((key, val));
        }
        self.skip_ws_inline();
        if !self.sc.eat(')') {
            return Err(Error::at("expected \")\"", self.sc.position()));
        }
        Ok(Expr::Map(entries))
    }

    /// Parse a bracketed list literal `[ ... ]`. An empty `[]` is a bracketed
    /// empty space list; otherwise the interior is parsed as an ordinary value
    /// (which may itself be a comma/space list) and re-marked as bracketed.
    fn parse_bracketed_list(&mut self) -> Result<Expr, Error> {
        self.sc.bump(); // '['
        self.skip_ws_inline();
        if self.sc.peek() == Some(']') {
            self.sc.bump();
            return Ok(Expr::List {
                items: Vec::new(),
                sep: ListSep::Undecided,
                bracketed: true,
            });
        }
        // Parse like a paren group so a trailing comma marks a one-element
        // COMMA list (`[1,]` keeps its separator, like `(1,)`).
        let first = self.space_list()?;
        let inner = self.finish_bracket_list(first)?;
        self.skip_ws_inline();
        if !self.sc.eat(']') {
            return Err(Error::at("expected \"]\"", self.sc.position()));
        }
        // An *unbracketed* list interior (the comma/space list produced by
        // parsing several elements) keeps its separator and is simply marked
        // bracketed. A scalar — or a single nested bracketed list like
        // `[[c]]` — becomes a one-item bracketed list instead of being
        // unwrapped.
        match inner {
            Expr::List {
                items,
                sep,
                bracketed: false,
            } => Ok(Expr::List {
                items,
                sep,
                bracketed: true,
            }),
            // A single-element bracketed list (`[1]`, `[[c]]`) has no decided
            // separator yet, so it stays undecided like a bare value would.
            other => Ok(Expr::List {
                items: vec![other],
                sep: ListSep::Undecided,
                bracketed: true,
            }),
        }
    }

    /// The interned `Rc<str>` for a numeric literal's unit (`""` included).
    fn unit_name(&mut self, unit: &str) -> Rc<str> {
        if let Some(u) = self.unit_names.iter().find(|u| u.as_ref() == unit) {
            return Rc::clone(u);
        }
        let interned: Rc<str> = Rc::from(unit);
        self.unit_names.push(Rc::clone(&interned));
        interned
    }

    fn parse_number(&mut self) -> Result<Expr, Error> {
        let mut s = String::new();
        while matches!(self.sc.peek(), Some(c) if c.is_ascii_digit()) {
            if let Some(c) = self.sc.bump() {
                s.push(c);
            }
        }
        if self.sc.peek() == Some('.') && matches!(self.sc.peek_at(1), Some(c) if c.is_ascii_digit()) {
            if let Some(c) = self.sc.bump() {
                s.push(c);
            }
            while matches!(self.sc.peek(), Some(c) if c.is_ascii_digit()) {
                if let Some(c) = self.sc.bump() {
                    s.push(c);
                }
            }
        }
        // Scientific notation: dart-sass commits to an exponent as soon as
        // `e`/`E` is followed by a digit OR a sign, then *requires* at least
        // one digit — so `1e-`, `1e-x`, `1e++5`, `1e--5` are "Expected digit.",
        // not a fall-through to a `1e-` unit. A unit like `1em` (or a spaced
        // `1e + 2`) is unaffected: `e` is followed by a letter / whitespace.
        if matches!(self.sc.peek(), Some('e' | 'E')) {
            let after = self.sc.peek_at(1);
            let is_exp = matches!(after, Some(c) if c.is_ascii_digit() || c == '+' || c == '-');
            if is_exp {
                if let Some(c) = self.sc.bump() {
                    s.push(c);
                }
                if matches!(self.sc.peek(), Some('+' | '-')) {
                    if let Some(c) = self.sc.bump() {
                        s.push(c);
                    }
                }
                if !matches!(self.sc.peek(), Some(c) if c.is_ascii_digit()) {
                    return Err(Error::at("Expected digit.", self.sc.position()));
                }
                while matches!(self.sc.peek(), Some(c) if c.is_ascii_digit()) {
                    if let Some(c) = self.sc.bump() {
                        s.push(c);
                    }
                }
            }
        }
        let value: f64 = s
            .parse()
            .map_err(|_| Error::at(format!("invalid number {s:?}"), self.sc.position()))?;
        let mut unit = String::new();
        if self.sc.peek() == Some('%') {
            self.sc.bump();
            unit.push('%');
        } else {
            loop {
                match self.sc.peek() {
                    Some(c) if c.is_ascii_alphabetic() || c == '_' => {
                        self.sc.bump();
                        unit.push(c);
                    }
                    // An identifier BODY may contain digits (`1a2b3c` is the
                    // single unit `a2b3c`), just not start with one.
                    Some(c) if c.is_ascii_digit() && !unit.is_empty() => {
                        self.sc.bump();
                        unit.push(c);
                    }
                    // dart `identifier(unit: true)`: a `-` joins the unit
                    // unless a digit or dot follows (so `10px-10px` still
                    // subtracts but `10px- 10px` is the unit `px-`).
                    Some('-') if !unit.is_empty() => match self.sc.peek_at(1) {
                        Some(c) if c.is_ascii_digit() || c == '.' => break,
                        _ => {
                            self.sc.bump();
                            unit.push('-');
                        }
                    },
                    // A unit may START with `-` only when an identifier
                    // follows (`1-em` is 1 with unit `-em`; `1--em` is the
                    // list `1 --em`, `1- 2` subtracts).
                    Some('-') if unit.is_empty() => match self.sc.peek_at(1) {
                        Some(c) if c.is_ascii_alphabetic() || c == '_' => {
                            self.sc.bump();
                            unit.push('-');
                        }
                        _ => break,
                    },
                    // A CSS escape is part of the unit, decoded like any
                    // identifier (`1\65 m` is the unit `em`).
                    Some('\\') => {
                        unit.push(self.read_escape_char()?);
                    }
                    _ => break,
                }
            }
        }
        Ok(Expr::Number(value, self.unit_name(&unit)))
    }

    fn parse_hex(&mut self) -> Result<Expr, Error> {
        let pos = self.sc.position();
        self.sc.bump(); // '#'

        // dart-sass splits on the character right after `#`. A *digit* commits
        // to a hex color: it must be 3/4/6/8 hex digits (read in committed
        // stages), and a short or malformed run is "Expected hex digit." —
        // never a hash-identifier (`#0`, `#00000`, `#0g`, `#12g` all error).
        // A *name-start* char is read as a full identifier that is a color only
        // when the whole spelling is a valid hex (`#abc`/`#abcd12` -> color;
        // `#abcde`/`#xyz`/`#foo` -> `#…` string).
        if matches!(self.sc.peek(), Some(c) if c.is_ascii_digit()) {
            return self.parse_hex_color_contents();
        }
        let mut hex = String::new();
        while matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit()) {
            if let Some(c) = self.sc.bump() {
                hex.push(c);
            }
        }
        // A `#` token that isn't a valid color is an ID token (CSS `nav-up`
        // and friends accept IDs): keep consuming the identifier and emit
        // the literal (`#ab`, `#abcde`, `#abcg`).
        let continues = matches!(self.sc.peek(), Some(c) if is_ident_char(c) || c == '\\');
        if !continues {
            if let Some(c) = Color::from_hex(&hex) {
                return Ok(Expr::Color(c));
            }
        }
        let mut ident = hex;
        loop {
            match self.sc.peek() {
                Some(c) if is_ident_char(c) => {
                    self.sc.bump();
                    ident.push(c);
                }
                // Escapes store their canonical spelling (`#f00000\9\0` keeps
                // `\9 \0 ` — a control character re-serializes as a hex
                // escape, like dart's identifier canonicalization).
                Some('\\') => {
                    let c = self.read_escape_char()?;
                    push_ident_escape(&mut ident, c, false);
                }
                _ => break,
            }
        }
        if ident.is_empty() {
            return Err(Error::at("Expected identifier.", pos));
        }
        Ok(Expr::Ident(vec![TplPiece::Lit(format!("#{ident}").into())]))
    }

    /// dart-sass `_hexColorContents`: the character after `#` was a digit, so
    /// this is a hex color or an error. Read 3/4/6/8 hex digits in committed
    /// stages (each `read_hex_digit` is mandatory, mirroring dart's `_hexDigit`)
    /// and leave any trailing token for the caller (`#000g` -> `#000` color +
    /// `g`; `#0000g` -> 4-digit color + `g`).
    fn parse_hex_color_contents(&mut self) -> Result<Expr, Error> {
        let mut hex = String::new();
        // digit1..3 are mandatory (`#0`, `#00`, `#0g` error here).
        self.read_hex_digit(&mut hex)?;
        self.read_hex_digit(&mut hex)?;
        self.read_hex_digit(&mut hex)?;
        if matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit()) {
            // a 4th digit -> #RGBA, unless a 5th follows...
            self.read_hex_digit(&mut hex)?;
            if matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit()) {
                // ...which commits to #RRGGBB — digit5, digit6 are mandatory
                // (`#00000`, `#0000000` error here).
                self.read_hex_digit(&mut hex)?;
                self.read_hex_digit(&mut hex)?;
                if matches!(self.sc.peek(), Some(c) if c.is_ascii_hexdigit()) {
                    // ...and a 7th commits to #RRGGBBAA — digit7, digit8 too.
                    self.read_hex_digit(&mut hex)?;
                    self.read_hex_digit(&mut hex)?;
                }
            }
        }
        // The staged read only ever accumulates 3/4/6/8 digits, so `from_hex`
        // always succeeds; the error arm is unreachable defence (no panic).
        match Color::from_hex(&hex) {
            Some(c) => Ok(Expr::Color(c)),
            None => Err(Error::at("Expected hex digit.", self.sc.position())),
        }
    }

    /// Read one required hex digit into `out`, or raise dart's
    /// "Expected hex digit." at the offending position.
    fn read_hex_digit(&mut self, out: &mut String) -> Result<(), Error> {
        match self.sc.peek() {
            Some(c) if c.is_ascii_hexdigit() => {
                self.sc.bump();
                out.push(c);
                Ok(())
            }
            _ => Err(Error::at("Expected hex digit.", self.sc.position())),
        }
    }

    pub(super) fn parse_quoted_string(&mut self) -> Result<Vec<TplPiece>, Error> {
        let q = match self.sc.bump() {
            Some(c) => c,
            None => return Err(Error::at("expected a string", self.sc.position())),
        };
        let mut pieces = Vec::new();
        let mut lit = String::new();
        loop {
            match self.sc.peek() {
                None => return Err(Error::at("unterminated string", self.sc.position())),
                Some(c) if c == q => {
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
                    let e = self.parse_interp_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                // A `\` before a newline is a CSS line continuation: dart's
                // `string()` drops the pair itself, before the escape reader —
                // which rejects a newline — ever sees it. This is the ONLY
                // place the continuation is legal.
                Some('\\') if matches!(self.sc.peek_at(1), Some('\n' | '\r' | '\u{c}')) => {
                    self.sc.bump();
                    if self.sc.peek() == Some('\r') {
                        self.sc.bump();
                        self.sc.eat('\n'); // CRLF
                    } else {
                        self.sc.bump();
                    }
                }
                Some('\\') => {
                    // Decode the escape to its code point and store it raw; the
                    // string serializer re-escapes only what it must.
                    // `\#{...}` decodes the `#` literally, so the sequence
                    // becomes a plain `#{` rather than interpolation. Inside a
                    // quoted string a NUL escape becomes the Unicode
                    // replacement character (unlike an identifier, where it
                    // serializes as `\0 `).
                    let c = self.consume_escape()?;
                    lit.push(if c == '\0' { '\u{FFFD}' } else { c });
                }
                // A literal newline cannot appear inside a quoted string; it must
                // be written as a `\` line continuation or a `\a` escape. dart-sass
                // reports the unterminated string with `Expected "<quote>".`.
                Some('\n' | '\r' | '\x0c') => {
                    return Err(Error::at(format!("Expected {q}."), self.sc.position()));
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

    fn parse_ident_or_call(&mut self) -> Result<Expr, Error> {
        // Position/mark of the identifier (function name) start, for diagnostic
        // spans that must point at the name (e.g. `rgb(1, 2)` highlights `rgb`).
        let name_pos = self.sc.position();
        let name_mark = self.sc.mark();
        let pieces = self.parse_ident_template()?;
        if pieces.len() == 1 {
            if let Some(TplPiece::Lit(name)) = pieces.first() {
                let name = name.clone();
                // A `namespace.member` reference: a plain identifier followed by
                // `.` and either `member(...)` (a namespaced function call) or
                // `$var` (a namespaced variable). Only recognised when the `.`
                // is directly followed by an identifier start or `$`; otherwise
                // it is left for ordinary parsing.
                if self.sc.peek() == Some('.') {
                    if let Some(expr) = self.try_parse_namespaced(&name, name_pos, name_mark)? {
                        return Ok(expr);
                    }
                }
                if self.sc.peek() == Some('(') {
                    return self.parse_call(name.to_string(), name_pos, name_mark);
                }
                // IE `progid:` special function: `[-vendor-]progid:Name(...)`.
                // The identifier `progid` (or a vendor-prefixed `-x-progid`) is
                // recognised only when immediately followed by a `:`. The
                // argument list (and any further `.Name` chain) is preserved
                // verbatim with only `#{...}` interpolation resolved.
                if self.sc.peek() == Some(':') && is_progid_name(&name) {
                    return self.parse_progid(&name);
                }
                // In plain CSS `true`/`false`/`null` have no special meaning;
                // they stay plain identifiers (dart-sass `CssParser`).
                if !self.plain_css {
                    match &*name {
                        "true" => return Ok(Expr::Bool(true)),
                        "false" => return Ok(Expr::Bool(false)),
                        "null" => return Ok(Expr::Null),
                        _ => {}
                    }
                }
                // A colour KEYWORD is a Sass value, not a CSS one: dart's
                // `CssParser` leaves `white` an identifier, so it passes
                // through with its own spelling instead of compressing to
                // `#fff` (and `TRANSPARENT` keeps its case).
                if !self.plain_css {
                    if let Some(color) = named_color(&name) {
                        return Ok(Expr::Color(color));
                    }
                }
            }
        }
        // An interpolated identifier directly followed by `(` is a plain-CSS
        // call with a dynamic name (`qu#{o}te(arg)` serializes as `quote(arg)`
        // — never dispatched to a real function).
        if self.sc.peek() == Some('(')
            && pieces.iter().any(|p| matches!(p, TplPiece::Interp(_)))
            && !self.plain_css
        {
            self.sc.bump();
            let args = self.parse_args_after_paren()?;
            return Ok(Expr::InterpFunc {
                name: pieces,
                args,
                pos: name_pos,
            });
        }
        Ok(Expr::Ident(pieces))
    }

    /// Try to parse a `namespace.member` reference after the namespace
    /// identifier `ns` has been consumed and the next character is `.`.
    /// Returns `Some(Expr)` for `ns.fn(...)` or `ns.$var`, or `None` (without
    /// consuming the `.`) when the dot does not begin a namespaced member.
    fn try_parse_namespaced(
        &mut self,
        ns: &str,
        name_pos: Pos,
        name_mark: Mark,
    ) -> Result<Option<Expr>, Error> {
        let mark = self.sc.mark();
        self.sc.bump(); // '.'
        match self.sc.peek() {
            // `ns.$var`
            Some('$') => {
                self.sc.bump();
                // Privacy is the LITERAL spelling (`ns.$\2d x` is an ordinary
                // member for dart), and the caret covers the whole `ns.$name`
                // reference as written.
                let literally_private = matches!(self.sc.peek(), Some('-') | Some('_'));
                let name = self.read_variable_name()?;
                if literally_private {
                    return Err(Error::at(
                        "Private members can't be accessed from outside their modules.",
                        name_pos,
                    )
                    .with_length(self.sc.byte_len_from(name_mark)));
                }
                let length = self.sc.byte_len_from(name_mark);
                Ok(Some(Expr::NsVar {
                    module: ns.to_string(),
                    name,
                    pos: name_pos,
                    length,
                }))
            }
            // `ns.member(...)` — the member must be an identifier immediately
            // followed by `(`.
            Some(c) if c.is_ascii_alphabetic() || c == '-' || c == '_' || c == '\\' => {
                let member_pos = self.sc.position();
                let member_mark = self.sc.mark();
                // Privacy is the LITERAL spelling, and the caret covers the
                // member as written (an escape counts its source bytes).
                let literally_private = matches!(self.sc.peek(), Some('-') | Some('_'));
                let member = self.read_ident_name()?;
                if self.sc.peek() == Some('(') {
                    if literally_private {
                        return Err(Error::at(
                            "Private members can't be accessed from outside their modules.",
                            member_pos,
                        )
                        .with_length(self.sc.byte_len_from(member_mark)));
                    }
                    self.sc.bump(); // '('
                    let args = self.parse_args_after_paren()?;
                    Ok(Some(Expr::Func {
                        name: member,
                        args,
                        pos: name_pos,
                        length: self.sc.byte_len_from(name_mark),
                        module: Some(ns.to_string()),
                    }))
                } else {
                    // A namespaced reference that is not a call is not a value
                    // (dart-sass only allows `ns.$var` and `ns.fn(...)`); back
                    // off and let ordinary parsing handle the `.`.
                    self.sc.reset(mark);
                    Ok(None)
                }
            }
            _ => {
                self.sc.reset(mark);
                Ok(None)
            }
        }
    }

    fn parse_ident_template(&mut self) -> Result<Vec<TplPiece>, Error> {
        self.parse_ident_template_from(0)
    }

    /// As [`parse_ident_template`], with `emitted` pre-seeded — the
    /// continuation of `#{foo}\-` is MID-identifier, so its escapes use the
    /// name-char rule, not the name-START rule.
    fn parse_ident_template_from(&mut self, start_emitted: usize) -> Result<Vec<TplPiece>, Error> {
        let mut pieces = Vec::new();
        let mut lit = String::new();
        // `emitted` counts code points written to the identifier so far (across
        // both literal and interpolation pieces) so the leading-digit / first
        // -char escaping rules can be applied. `first_hyphen` records whether
        // the identifier begins with `-` (a digit right after it is escaped).
        let mut emitted = start_emitted;
        let mut first_hyphen = false;
        loop {
            match self.sc.peek() {
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_interp_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                    emitted += 1;
                }
                Some('\\') => {
                    let c = self.consume_escape()?;
                    // The escape is at "identifier start" when it is the very
                    // first code point, or the code point right after a single
                    // leading literal/escaped `-`.
                    let identifier_start = emitted == 0 || (emitted == 1 && first_hyphen);
                    push_ident_escape(&mut lit, c, identifier_start);
                    emitted += 1;
                }
                Some(c) if is_ident_char(c) => {
                    lit.push(c);
                    self.sc.bump();
                    if emitted == 0 && c == '-' {
                        first_hyphen = true;
                    }
                    emitted += 1;
                }
                _ => break,
            }
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(pieces)
    }

    fn parse_call(&mut self, name: String, name_pos: Pos, name_mark: Mark) -> Result<Expr, Error> {
        // A plain-CSS function call is preserved verbatim, but a Sass-only global
        // function (one with no plain-CSS meaning, e.g. `index`) is rejected.
        if self.plain_css && is_sass_only_function(&name) {
            return Err(Error::at("This function isn't allowed in plain CSS.", name_pos));
        }
        self.sc.bump(); // '('
                        // `calc()` interior is parsed as a real arithmetic
                        // expression and simplified at evaluation time. The
                        // name is matched case-insensitively (`CaLc(1px)` ->
                        // `1px`); a vendor-prefixed `-webkit-calc(…)` does not
                        // match and stays a verbatim special function.
        if name.eq_ignore_ascii_case("calc") {
            self.skip_ws_inline();
            if self.sc.peek() == Some(')') {
                // An empty `calc()` is NOT a calculation (calc needs one
                // argument) nor a verbatim special function; it's a regular
                // function call, so a user `@function calc()` can be invoked
                // (dart-sass).
                let args = self.parse_args_after_paren()?;
                return Ok(Expr::Func {
                    name,
                    args,
                    pos: name_pos,
                    length: self.sc.byte_len_from(name_mark),
                    module: None,
                });
            }
            self.calc_depth += 1;
            let inner = self.parse_value();
            self.calc_depth -= 1;
            let inner = inner?;
            self.skip_ws_inline();
            if !self.sc.eat(')') {
                return Err(Error::at("expected \")\"", self.sc.position()));
            }
            return Ok(Expr::Calc {
                inner: Box::new(inner),
            });
        }
        // CSS functions whose contents must be preserved verbatim (they may
        // contain arithmetic that is not Sass math), while still resolving
        // any `#{...}` interpolation inside them. `min`/`max`/`clamp` are
        // NOT here: they route to the math builtins, which evaluate their
        // arguments as Sass values and reduce when every argument is a
        // compatible-unit number, otherwise fall back to a preserved CSS
        // `min()`/`max()`/`clamp()` form (so `min(1px, 2vw)` round-trips).
        // A `url(` function (case-insensitively, with an optional vendor
        // prefix): dart-sass tries to read a plain unquoted URL verbatim. If
        // that succeeds the call is emitted as a bare lower-cased `url(...)`
        // (the vendor prefix is dropped); if the contents contain SassScript
        // (a `$variable`), the trial fails and the call is parsed as an
        // ordinary function so its arguments evaluate (keeping the original
        // name, e.g. `-e-url($a)` -> `-e-url(b)`).
        if is_url_function(&name) {
            let mark = self.sc.mark();
            if let Some(pieces) = self.try_plain_url_contents()? {
                return Ok(Expr::Ident(pieces));
            }
            self.sc.reset(mark);
            let args = self.parse_args_after_paren()?;
            return Ok(Expr::Func {
                name,
                args,
                pos: name_pos,
                length: self.sc.byte_len_from(name_mark),
                module: None,
            });
        }
        // `var()` and `env()` are plain CSS functions whose arguments are
        // ordinary SassScript: dart-sass evaluates the fallback/value
        // arguments, normalises surrounding whitespace, and expands a
        // `var($args...)` splat. They route through the regular function-call
        // eval path (neither is a Sass builtin, so the result is preserved
        // verbatim as `var(...)`/`env(...)`). The single exception is `var`'s
        // `allowEmptySecondArg`: `var(--c,)` keeps a trailing empty argument
        // (`var(--c, )`), case-insensitively for the name `var` only — `env`
        // and every other case follow the normal trailing-comma rules.
        {
            let lower = name.to_ascii_lowercase();
            if lower == "var" || lower == "env" {
                let args = self.parse_args_after_paren_opt_empty_second(lower == "var")?;
                return Ok(Expr::Func {
                    name,
                    args,
                    pos: name_pos,
                    length: self.sc.byte_len_from(name_mark),
                    module: None,
                });
            }
        }
        // Special CSS functions (`calc()`, `element()`, `expression()` with or
        // without a vendor prefix; `type()` unprefixed) preserve their
        // arguments verbatim — they may contain `%`, `@`, `=`, IE-hack syntax,
        // comments, and other non-SassScript characters. Only `#{...}`
        // interpolation is resolved; the function name is lower-cased.
        if let Some(canonical) = special_function_name(&name) {
            return self.parse_special_function(&canonical);
        }
        // The modern CSS `if()` uses `:`/`;` clause syntax and `css()`/
        // `sass()` wrappers, which the comma-arg parser cannot handle. Try
        // the modern grammar first; if it does not match, reset and fall
        // back to the legacy `if($cond, $t, $f)` builtin.
        if name == "if" {
            let mark = self.sc.mark();
            let seen_interp = self.plain_css_interp;
            match self.try_parse_modern_if() {
                Ok(Some(clauses)) => return Ok(Expr::ModernIf(clauses)),
                Ok(None) => self.sc.reset(mark),
                // An attempt that read a `#{…}` in plain CSS cannot be retried:
                // the legacy argument grammar has to reject that text too, and
                // would report its own complaint (`Operators aren't allowed in
                // plain CSS.` at a `>` the raw grammar reads verbatim) in place
                // of the one dart raises inside the interpolation.
                Err(e) if self.plain_css_interp && !seen_interp => return Err(e),
                Err(_) => self.sc.reset(mark),
            }
        }
        let args = self.parse_args_after_paren()?;
        Ok(Expr::Func {
            name,
            args,
            pos: name_pos,
            length: self.sc.byte_len_from(name_mark),
            module: None,
        })
    }

    /// Capture the argument list of a special CSS function verbatim after the
    /// opening `(` has been consumed. `canonical` is the lower-cased function
    /// name to emit. The contents are preserved literally except that:
    ///   - `#{...}` interpolation is resolved;
    ///   - runs of whitespace collapse to a single space;
    ///   - silent `//` comments are dropped (the whitespace around them stays);
    ///   - loud `/* */` comments, quoted strings, and all other characters
    ///     (`%`, `@`, `=`, punctuation, …) are emitted verbatim.
    ///
    /// Nested parentheses are balanced.
    fn parse_special_function(&mut self, canonical: &str) -> Result<Expr, Error> {
        let pieces: Vec<TplPiece> = Vec::new();
        let lit = format!("{canonical}(");
        self.capture_verbatim_args(pieces, lit)
    }

    /// Parse an IE `progid:` special function whose `[-vendor-]progid` prefix
    /// (passed as `name`, with the `:` not yet consumed) has been recognised.
    /// The prefix is lower-cased on emit; a `.`-separated chain of ASCII-letter
    /// name segments follows the `:` (kept verbatim, case preserved), then an
    /// opening `(` is required and the argument list is captured verbatim
    /// (resolving only `#{...}` interpolation). Mirrors dart-sass's `progid`
    /// branch of `_trySpecialFunction`.
    fn parse_progid(&mut self, name: &str) -> Result<Expr, Error> {
        let mut lit = name.to_ascii_lowercase();
        self.sc.bump(); // ':'
        lit.push(':');
        // The name chain: ASCII letters and `.` only (e.g.
        // `DXImageTransform.Microsoft.gradient`). Anything else stops the chain
        // and the required `(` check below produces dart-sass's error.
        while let Some(c) = self.sc.peek() {
            if c.is_ascii_alphabetic() || c == '.' {
                lit.push(c);
                self.sc.bump();
            } else {
                break;
            }
        }
        if !self.sc.eat('(') {
            return Err(Error::at("expected \"(\".", self.sc.position()));
        }
        lit.push('(');
        self.capture_verbatim_args(Vec::new(), lit)
    }

    /// Continue capturing a verbatim special-function argument list, given the
    /// already-accumulated template `pieces`/`lit` (which must end with the
    /// opening `(` that has just been consumed). The closing `)` is consumed.
    /// Used by both the named special functions (`calc()`, `element()`, …) and
    /// the IE `progid:` form, which share dart-sass's interpolated-declaration
    /// value grammar.
    fn capture_verbatim_args(&mut self, mut pieces: Vec<TplPiece>, mut lit: String) -> Result<Expr, Error> {
        let mut depth = 1i32;
        loop {
            match self.sc.peek() {
                None => break,
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_interp_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                // Quoted strings: copy verbatim (parens inside do not
                // nest), but `#{…}` interpolation INSIDE still resolves
                // (`src="#{foo}"` emits `src="foo"`).
                Some(q @ ('"' | '\'')) => {
                    lit.push(q);
                    self.sc.bump();
                    loop {
                        match self.sc.peek() {
                            None => break,
                            Some('#') if self.sc.peek_at(1) == Some('{') => {
                                let interp_mark = self.sc.mark();
                                if !lit.is_empty() {
                                    pieces.push(take_lit(&mut lit));
                                }
                                self.sc.bump();
                                self.sc.bump();
                                let e = self.parse_interp_value()?;
                                self.skip_ws_inline();
                                if !self.sc.eat('}') {
                                    return Err(Error::at("expected \"}\"", self.sc.position()));
                                }
                                self.reject_plain_css_interp(interp_mark)?;
                                pieces.push(TplPiece::Interp(e));
                            }
                            Some('\\') => {
                                lit.push('\\');
                                self.sc.bump();
                                if let Some(esc) = self.sc.bump() {
                                    lit.push(esc);
                                }
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
                // Loud comment: emit verbatim.
                Some('/') if self.sc.peek_at(1) == Some('*') => {
                    lit.push('/');
                    lit.push('*');
                    self.sc.bump();
                    self.sc.bump();
                    loop {
                        match self.sc.peek() {
                            None => break,
                            Some('*') if self.sc.peek_at(1) == Some('/') => {
                                lit.push('*');
                                lit.push('/');
                                self.sc.bump();
                                self.sc.bump();
                                break;
                            }
                            Some(c) => {
                                lit.push(c);
                                self.sc.bump();
                            }
                        }
                    }
                }
                // Silent comment: drop it (surrounding whitespace is kept).
                Some('/') if self.sc.peek_at(1) == Some('/') => {
                    while let Some(c) = self.sc.peek() {
                        if c == '\n' {
                            break;
                        }
                        self.sc.bump();
                    }
                }
                // A backslash escapes the next character: both are emitted
                // verbatim, and the escaped character (e.g. `\(` or `\)`) does
                // NOT affect parenthesis nesting. Mirrors dart-sass's
                // `_interpolatedDeclarationValue` escape handling.
                Some('\\') => {
                    lit.push('\\');
                    self.sc.bump();
                    if let Some(c) = self.sc.bump() {
                        lit.push(c);
                    }
                }
                // Whitespace run collapses to a single space.
                Some(c) if c.is_whitespace() => {
                    while matches!(self.sc.peek(), Some(c) if c.is_whitespace()) {
                        self.sc.bump();
                    }
                    lit.push(' ');
                }
                Some('(') => {
                    depth += 1;
                    lit.push('(');
                    self.sc.bump();
                }
                Some(')') => {
                    depth -= 1;
                    lit.push(')');
                    self.sc.bump();
                    if depth == 0 {
                        break;
                    }
                }
                Some(c) => {
                    lit.push(c);
                    self.sc.bump();
                }
            }
        }
        if depth != 0 {
            return Err(Error::at("expected \")\"", self.sc.position()));
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(Expr::Ident(pieces))
    }

    /// Try to read the contents of a `url(` as a plain unquoted URL (the `(`
    /// is already consumed). Returns `Some(pieces)` emitting a canonical
    /// `url(<contents>)` (vendor prefix dropped, name lower-cased) when the
    /// contents are a plain URL — arbitrary url-safe characters plus `#{...}`
    /// interpolation, balanced parentheses, and quoted strings. Returns `None`
    /// (without committing the cursor — the caller resets) when a top-level
    /// `$variable` appears, signalling that the call must instead be parsed as
    /// an ordinary function so its arguments evaluate.
    pub(super) fn try_plain_url_contents(&mut self) -> Result<Option<Vec<TplPiece>>, Error> {
        let mut pieces: Vec<TplPiece> = Vec::new();
        let mut lit = String::from("url(");
        let mut depth = 1i32;
        // dart-sass skips leading whitespace (without comments, so `/* */`
        // stays literal) right after the opening paren before reading the URL.
        while matches!(self.sc.peek(), Some(' ' | '\t' | '\n' | '\r' | '\x0c')) {
            self.sc.bump();
        }
        loop {
            match self.sc.peek() {
                None => return Ok(None),
                // A top-level `$variable` is SassScript, not a plain URL.
                Some('$') => return Ok(None),
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_interp_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                // A quoted string makes this a NORMAL function call, not a
                // plain-URL token (dart-sass): the string argument then
                // serializes canonically (double quotes preferred), so
                // `url('x.png')` emits `url("x.png")`.
                Some('"' | '\'') => return Ok(None),
                // A CSS escape in unquoted URL contents is decoded and
                // re-serialized with the identifier rules (always in body
                // position, so a leading digit or `-` stays literal). This also
                // makes `\#{}` a literal `#{}` rather than interpolation.
                Some('\\') => {
                    let c = self.consume_escape()?;
                    push_ident_escape(&mut lit, c, false);
                }
                Some('(') => {
                    depth += 1;
                    lit.push('(');
                    self.sc.bump();
                }
                Some(')') => {
                    depth -= 1;
                    lit.push(')');
                    self.sc.bump();
                    if depth == 0 {
                        break;
                    }
                }
                // dart-sass allows whitespace in a plain-URL token only
                // directly before the closing `)`. A space followed by more
                // contents makes this a NORMAL function call instead, so
                // `url(foo + bar)` evaluates SassScript (-> `url(foobar)`).
                Some(' ' | '\t' | '\n' | '\r' | '\x0c') => {
                    while matches!(self.sc.peek(), Some(' ' | '\t' | '\n' | '\r' | '\x0c')) {
                        self.sc.bump();
                    }
                    if self.sc.peek() != Some(')') {
                        return Ok(None);
                    }
                }
                Some(c) => {
                    lit.push(c);
                    self.sc.bump();
                }
            }
        }
        if depth != 0 {
            return Ok(None);
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(Some(pieces))
    }

    /// Attempt to parse the modern `if()` grammar after the opening `(` was
    /// consumed. Returns `Ok(Some(_))` if the input matches the modern
    /// clause syntax (consuming through the closing `)`), `Ok(None)` if it
    /// is clearly the legacy comma-arg form, or `Err` on a genuine modern
    /// syntax error (which surfaces to the caller as a hard error after the
    /// trial succeeds in committing to modern).
    fn try_parse_modern_if(&mut self) -> Result<Option<Vec<IfClause>>, Error> {
        self.skip_ws_inline();
        // Recognise the first clause to decide between modern and legacy.
        // A modern clause starts with `else` or a condition atom; if the
        // first token cannot begin a condition, this is the legacy form.
        let first = match self.parse_if_clause(true)? {
            Some(c) => c,
            None => return Ok(None),
        };
        let mut clauses = vec![first];
        loop {
            self.skip_ws_inline();
            if self.sc.eat(';') {
                self.skip_ws_inline();
                if self.sc.peek() == Some(')') {
                    break; // trailing semicolon
                }
                match self.parse_if_clause(false)? {
                    Some(c) => clauses.push(c),
                    None => return Err(Error::at("Expected identifier.", self.sc.position())),
                }
                continue;
            }
            break;
        }
        self.skip_ws_inline();
        if !self.sc.eat(')') {
            return Err(Error::at("expected \")\".", self.sc.position()));
        }
        Ok(Some(clauses))
    }

    /// Parse one `if()` clause: `<condition>: <value>` or `else: <value>`.
    /// When `probe` is true a failure to recognise the leading condition
    /// returns `Ok(None)` (signalling a fall-back to legacy) rather than an
    /// error.
    fn parse_if_clause(&mut self, probe: bool) -> Result<Option<IfClause>, Error> {
        self.skip_ws_inline();
        // `else` clause: bare keyword, no condition.
        let else_mark = self.sc.mark();
        if self.try_keyword("else") {
            self.skip_ws_inline();
            if self.sc.peek() == Some(':') {
                self.sc.bump();
                self.skip_ws_inline();
                let value = self.space_list()?;
                return Ok(Some(IfClause {
                    condition: None,
                    value,
                }));
            }
            // `else` not followed by `:` — not a modern else clause.
            self.sc.reset(else_mark);
        }
        let condition = match self.parse_if_cond(probe)? {
            Some(c) => c,
            None => return Ok(None),
        };
        // A condition may not mix an evaluated `sass()` with a multi-token
        // "arbitrary substitution" raw sequence at the same boolean level.
        validate_if_cond(&condition)?;
        self.skip_ws_inline();
        if !self.sc.eat(':') {
            return Err(Error::at("expected \":\".", self.sc.position()));
        }
        self.skip_ws_inline();
        let value = self.space_list()?;
        Ok(Some(IfClause {
            condition: Some(condition),
            value,
        }))
    }

    /// Parse a full `if()` condition. dart-sass's grammar:
    ///   `not <operand>`                        (a single negated operand)
    ///   `<operand> (and <operand>)+`           (an `and` chain)
    ///   `<operand> (or <operand>)+`            (an `or` chain)
    ///   `<operand>`                            (a lone operand)
    /// Mixing `and` and `or` at the same level is an error; `not` only
    /// applies to a single non-multi-token operand and cannot be chained.
    /// Keywords (`not`/`and`/`or`) are matched case-insensitively.
    fn parse_if_cond(&mut self, probe: bool) -> Result<Option<IfCond>, Error> {
        self.skip_ws_inline();
        // Leading `not`: a single operand, no following `and`/`or`.
        if self.eat_if_keyword("not") {
            self.require_paren_whitespace_after("not")?;
            self.skip_ws_inline();
            let operand = self.parse_if_operand(false, true)?;
            return Ok(Some(IfCond::Not(Box::new(self.expect_operand(operand)?))));
        }
        let first = match self.parse_if_operand(probe, false)? {
            Some(c) => c,
            None => return Ok(None),
        };
        // Peek for a conjunction (case-insensitive).
        let mark = self.sc.mark();
        self.skip_ws_inline();
        let conj = self.peek_if_conjunction();
        self.sc.reset(mark);
        match conj {
            Some(is_and) => {
                let kw = if is_and { "and" } else { "or" };
                let other = if is_and { "or" } else { "and" };
                let mut items = vec![first];
                loop {
                    let mark = self.sc.mark();
                    self.skip_ws_inline();
                    if self.eat_if_keyword(kw) {
                        self.require_paren_whitespace_after(kw)?;
                        self.skip_ws_inline();
                        let operand = self.parse_if_operand(false, false)?;
                        items.push(self.expect_operand(operand)?);
                        continue;
                    }
                    // Mixing the other conjunction is an error.
                    if self.peek_word_is_ci(other) {
                        return Err(Error::at("expected \":\".", self.sc.position()));
                    }
                    self.sc.reset(mark);
                    break;
                }
                if is_and {
                    Ok(Some(IfCond::And(items)))
                } else {
                    Ok(Some(IfCond::Or(items)))
                }
            }
            None => Ok(Some(first)),
        }
    }

    /// Unwrap an operand that may have failed to parse.
    fn expect_operand(&self, operand: Option<IfCond>) -> Result<IfCond, Error> {
        operand.ok_or_else(|| Error::at("expected \"(\".", self.sc.position()))
    }

    /// Parse one condition operand: a parenthesised condition, `sass(<expr>)`,
    /// or a raw substitution sequence. When `single` is true (the operand of
    /// `not`), only a single raw token is consumed (a paren or one function
    /// call), not a multi-token sequence. Returns `Ok(None)` (when probing)
    /// if the position cannot begin an operand.
    fn parse_if_operand(&mut self, probe: bool, single: bool) -> Result<Option<IfCond>, Error> {
        self.skip_ws_inline();
        match self.sc.peek() {
            Some('(') => {
                self.sc.bump();
                self.skip_ws_inline();
                let inner = match self.parse_if_cond(false)? {
                    Some(c) => c,
                    None => return Err(Error::at("Expected identifier.", self.sc.position())),
                };
                self.skip_ws_inline();
                if !self.sc.eat(')') {
                    return Err(Error::at("expected \")\".", self.sc.position()));
                }
                Ok(Some(IfCond::Paren(Box::new(inner))))
            }
            _ if self.peek_keyword_paren_ci("sass") => {
                if self.plain_css {
                    return Err(Error::at(
                        "sass() conditions aren't allowed in plain CSS",
                        self.sc.position(),
                    ));
                }
                for _ in 0.."sass".chars().count() {
                    self.sc.bump();
                }
                self.sc.bump(); // '('
                self.skip_ws_inline();
                let expr = self.space_list()?;
                self.skip_ws_inline();
                if !self.sc.eat(')') {
                    return Err(Error::at("expected \")\".", self.sc.position()));
                }
                // A `sass()` atom may not be space-adjacent to a raw token
                // ("arbitrary substitution"): `sass(true) var(--x)` is illegal.
                let mark = self.sc.mark();
                let had_ws = self.skip_ws_inline();
                let next_is_raw = had_ws && self.peek_starts_raw_token();
                self.sc.reset(mark);
                if next_is_raw {
                    return Err(Error::at(
                        "if() conditions with arbitrary substitutions may not contain sass() expressions.",
                        self.sc.position(),
                    ));
                }
                Ok(Some(IfCond::Sass(Box::new(expr))))
            }
            _ => self.parse_if_raw_sequence(probe, single),
        }
    }

    /// Parse a sequence of raw substitution tokens (`css(...)`,
    /// `<ident>(...)`, `#{...}`) joined by spaces into a single non-evaluable
    /// condition. When `single` is true, at most one token is read. A
    /// `sass()` token inside the sequence is the "arbitrary substitution"
    /// error. Returns `Ok(None)` (when probing) if the input cannot begin a
    /// raw token.
    fn parse_if_raw_sequence(&mut self, probe: bool, single: bool) -> Result<Option<IfCond>, Error> {
        let mut pieces: Vec<TplPiece> = Vec::new();
        if !self.read_if_raw_token(&mut pieces)? {
            if probe {
                return Ok(None);
            }
            return Err(Error::at("expected \"(\".", self.sc.position()));
        }
        let mut token_count = 1usize;
        if !single {
            loop {
                let mark = self.sc.mark();
                let had_ws = self.skip_ws_inline();
                if !had_ws || !self.peek_starts_raw_token() {
                    self.sc.reset(mark);
                    break;
                }
                // A `sass()` token adjacent to raw substitution is illegal.
                if self.peek_keyword_paren_ci("sass") {
                    return Err(Error::at(
                        "if() conditions with arbitrary substitutions may not contain sass() expressions.",
                        self.sc.position(),
                    ));
                }
                pieces.push(TplPiece::Lit(" ".into()));
                if !self.read_if_raw_token(&mut pieces)? {
                    self.sc.reset(mark);
                    break;
                }
                token_count += 1;
            }
        }
        Ok(Some(IfCond::Raw {
            pieces,
            multi: token_count > 1,
        }))
    }

    /// Whether the next token starts a raw substitution token: an
    /// interpolation or an identifier (which must be followed by `(`).
    fn peek_starts_raw_token(&self) -> bool {
        match self.sc.peek() {
            Some('#') if self.sc.peek_at(1) == Some('{') => true,
            Some(c) if is_ident_char(c) => {
                // A bare keyword (`and`/`or`/`not`) is not a raw token.
                !(self.peek_word_is_ci("and") || self.peek_word_is_ci("or") || self.peek_word_is_ci("not"))
            }
            _ => false,
        }
    }

    /// Read one raw substitution token (`<ident>(...)` or `#{...}`),
    /// appending its serialized pieces. A bare interpolation token is valid;
    /// a bare identifier (not followed by `(`) is not. Returns false if the
    /// position does not start such a token.
    fn read_if_raw_token(&mut self, pieces: &mut Vec<TplPiece>) -> Result<bool, Error> {
        match self.sc.peek() {
            Some('#') if self.sc.peek_at(1) == Some('{') => {
                let interp_mark = self.sc.mark();
                self.sc.bump();
                self.sc.bump();
                let e = self.parse_interp_value()?;
                self.skip_ws_inline();
                if !self.sc.eat('}') {
                    return Err(Error::at("expected \"}\"", self.sc.position()));
                }
                self.reject_plain_css_interp(interp_mark)?;
                pieces.push(TplPiece::Interp(e));
                // An interpolation followed immediately by `(` is a function.
                if self.sc.peek() == Some('(') {
                    self.read_if_raw_parens(pieces)?;
                }
                Ok(true)
            }
            // `not`/`and`/`or` are reserved: written as `not(`/`and(`/`or(`
            // (no space) they are the "whitespace required" error, not a
            // function call.
            Some(c)
                if (c.is_ascii_alphabetic())
                    && (self.peek_keyword_paren_ci("not")
                        || self.peek_keyword_paren_ci("and")
                        || self.peek_keyword_paren_ci("or")) =>
            {
                let kw = if self.peek_keyword_paren_ci("not") {
                    "not"
                } else if self.peek_keyword_paren_ci("and") {
                    "and"
                } else {
                    "or"
                };
                // Skip the keyword to point the error at the `(`.
                for _ in 0..kw.chars().count() {
                    self.sc.bump();
                }
                Err(Error::at(
                    format!("Whitespace is required between \"{kw}\" and \"(\""),
                    self.sc.position(),
                ))
            }
            Some(c) if is_ident_char(c) => {
                let mark = self.sc.mark();
                let name_pieces = self.read_ident_template()?;
                if self.sc.peek() != Some('(') {
                    // Bare identifier — not a raw token unless it contained
                    // interpolation (e.g. `#{"x"}`), which is a valid token.
                    if name_pieces.iter().all(|p| matches!(p, TplPiece::Lit(_))) {
                        self.sc.reset(mark);
                        return Ok(false);
                    }
                    pieces.extend(name_pieces);
                    return Ok(true);
                }
                pieces.extend(name_pieces);
                self.read_if_raw_parens(pieces)?;
                Ok(true)
            }
            _ => Ok(false),
        }
    }

    /// Read a balanced `( ... )` group verbatim (resolving interpolation),
    /// appending to `pieces`. Assumes the next char is `(`.
    fn read_if_raw_parens(&mut self, pieces: &mut Vec<TplPiece>) -> Result<(), Error> {
        let mut lit = String::new();
        let mut depth = 0u32;
        loop {
            match self.sc.peek() {
                None => return Err(Error::at("expected \")\".", self.sc.position())),
                Some('#') if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    let e = self.parse_interp_value()?;
                    self.skip_ws_inline();
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                Some('(') => {
                    depth += 1;
                    lit.push('(');
                    self.sc.bump();
                }
                Some(')') => {
                    depth -= 1;
                    lit.push(')');
                    self.sc.bump();
                    if depth == 0 {
                        break;
                    }
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
        Ok(())
    }

    /// Read an identifier that may contain leading/embedded `#{...}`
    /// interpolation (e.g. `#{css}`), as a template.
    fn read_ident_template(&mut self) -> Result<Vec<TplPiece>, Error> {
        let mut pieces: Vec<TplPiece> = Vec::new();
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
                    let e = self.parse_interp_value()?;
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

    /// Peek whether the next word equals `kw` case-insensitively (followed
    /// by a non-ident char). `if()` keywords are case-insensitive.
    fn peek_word_is_ci(&self, kw: &str) -> bool {
        let rest = self.sc.rest();
        let kw_chars: Vec<char> = kw.chars().collect();
        if rest.len() < kw_chars.len() {
            return false;
        }
        for (i, &kc) in kw_chars.iter().enumerate() {
            if !rest[i].eq_ignore_ascii_case(&kc) {
                return false;
            }
        }
        match rest.get(kw_chars.len()) {
            Some(&c) => !is_ident_char(c),
            None => true,
        }
    }

    /// At the current position, peek whether a conjunction follows.
    /// `Some(true)` for `and`, `Some(false)` for `or`, `None` otherwise.
    fn peek_if_conjunction(&self) -> Option<bool> {
        if self.peek_word_is_ci("and") {
            Some(true)
        } else if self.peek_word_is_ci("or") {
            Some(false)
        } else {
            None
        }
    }

    /// Consume the keyword `kw` (case-insensitively) if it is the next word
    /// (followed by a non-ident char). Does not skip leading whitespace.
    fn eat_if_keyword(&mut self, kw: &str) -> bool {
        if self.peek_word_is_ci(kw) {
            for _ in 0..kw.chars().count() {
                self.sc.bump();
            }
            true
        } else {
            false
        }
    }

    /// After consuming `not`/`and`/`or`, dart-sass requires whitespace
    /// before a following `(` (otherwise `and(` etc. is a function call,
    /// which is an error in condition position).
    fn require_paren_whitespace_after(&mut self, kw: &str) -> Result<(), Error> {
        if self.sc.peek() == Some('(') {
            return Err(Error::at(
                format!("Whitespace is required between \"{kw}\" and \"(\""),
                self.sc.position(),
            ));
        }
        Ok(())
    }

    /// Peek whether the next word is `kw` (case-insensitive) immediately
    /// followed by `(`.
    fn peek_keyword_paren_ci(&self, kw: &str) -> bool {
        let rest = self.sc.rest();
        let kw_chars: Vec<char> = kw.chars().collect();
        if rest.len() <= kw_chars.len() {
            return false;
        }
        for (i, &kc) in kw_chars.iter().enumerate() {
            if !rest[i].eq_ignore_ascii_case(&kc) {
                return false;
            }
        }
        rest.get(kw_chars.len()) == Some(&'(')
    }

    /// Parse a call's argument list, assuming the opening `(` was already
    /// consumed, through the closing `)`. Args are positional or
    /// `$name: value`. Shared by function calls and `@include`.
    /// A function-argument value: a space-list optionally followed by one or
    /// more single-`=` Microsoft-filter operators (`alpha(opacity=80)`). The
    /// `=` is the lowest-precedence value operator and is recognised only here,
    /// inside an argument list (a lone `=` is a syntax error elsewhere). A
    /// `==` is the equality operator and is handled at its own precedence, so
    /// only a `=` not followed by `=` is consumed.
    fn arg_value(&mut self) -> Result<Expr, Error> {
        let mut lhs = self.space_list()?;
        loop {
            let mark = self.sc.mark();
            self.skip_ws_inline();
            if self.sc.peek() == Some('=') && self.sc.peek_at(1) != Some('=') {
                let pos = self.sc.position();
                self.sc.bump();
                self.skip_ws_inline();
                let rhs = self.space_list()?;
                lhs = Expr::Binary {
                    op: BinOp::SingleEq,
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

    pub(super) fn parse_args_after_paren(&mut self) -> Result<Vec<CallArg>, Error> {
        self.parse_args_after_paren_opt_empty_second(false)
    }

    /// Parse a comma-separated argument list after a consumed `(`.
    ///
    /// When `allow_empty_second_arg` is set (dart-sass's `var()` special case),
    /// a `,` immediately followed by `)` right after the *first* argument adds
    /// an empty unquoted-string second argument (`var(--c,)` -> `var(--c, )`)
    /// instead of being treated as a normal ignorable trailing comma.
    fn parse_args_after_paren_opt_empty_second(
        &mut self,
        allow_empty_second_arg: bool,
    ) -> Result<Vec<CallArg>, Error> {
        let mut args = Vec::new();
        self.skip_ws_inline();
        if self.sc.peek() != Some(')') {
            loop {
                self.skip_ws_inline();
                let mut name_opt = None;
                if self.sc.peek() == Some('$') {
                    if self.plain_css {
                        return Err(Error::at(
                            "Sass variables aren't allowed in plain CSS.",
                            self.sc.position(),
                        ));
                    }
                    let mark = self.sc.mark();
                    self.sc.bump();
                    let argname = self.read_variable_name()?;
                    self.skip_ws_inline();
                    if self.sc.peek() == Some(':') && self.sc.peek_at(1) != Some(':') {
                        self.sc.bump();
                        self.skip_ws_inline();
                        name_opt = Some(argname);
                    } else {
                        self.sc.reset(mark);
                    }
                }
                // Source-map: where this argument's value text begins — the
                // span a bound parameter inherits as its definition node.
                let value_pos = self.sc.position();
                let value = self.arg_value()?;
                // A trailing `...` marks a splat argument: a list spreads into
                // positional args and a map into keyword args. A named arg may
                // not be a splat. Whitespace (including newlines) may separate
                // the value from its `...` (`a($d\n  ...)`).
                self.skip_ws_inline();
                let splat = name_opt.is_none()
                    && self.sc.peek() == Some('.')
                    && self.sc.peek_at(1) == Some('.')
                    && self.sc.peek_at(2) == Some('.');
                if splat {
                    if self.plain_css {
                        return Err(Error::at("expected \")\".", self.sc.position()));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    self.sc.bump();
                }
                let is_first = args.is_empty();
                let is_named = name_opt.is_some();
                args.push(CallArg {
                    name: name_opt,
                    value,
                    splat,
                    value_pos,
                });
                self.skip_ws_inline();
                if self.sc.eat(',') {
                    self.skip_ws_inline();
                    if self.sc.peek() == Some(')') {
                        // `var(<first>,)`: the trailing comma after exactly the
                        // first POSITIONAL (non-splat, non-named) argument
                        // introduces an empty second argument rather than being
                        // ignored (dart: `positional.length == 1 &&
                        // named.isEmpty`) — `var($arg: --c, )` keeps the
                        // ordinary trailing-comma behavior.
                        if allow_empty_second_arg && is_first && !splat && !is_named {
                            args.push(CallArg {
                                name: None,
                                value: Expr::Ident(Vec::new()),
                                splat: false,
                                // Synthesized, not written in the source.
                                value_pos: crate::scanner::Pos::NONE,
                            });
                        }
                        break;
                    }
                    continue;
                }
                break;
            }
        }
        self.skip_ws_inline();
        if !self.sc.eat(')') {
            return Err(Error::at("expected \")\"", self.sc.position()));
        }
        Ok(args)
    }
}
