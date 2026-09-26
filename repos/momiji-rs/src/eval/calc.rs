use super::*;

impl<'a> Evaluator<'a> {
    /// Serialize a CSS math function (`min`/`max`/`clamp`/…) verbatim inside a
    /// `@supports` declaration: each argument is resolved through the
    /// (non-folding) calc machinery and joined with `, `. Used only when
    /// `in_supports_declaration` is set.
    pub(super) fn eval_supports_calc_func(
        &mut self,
        name: &str,
        args: &[CallArg],
        pos: Pos,
    ) -> Result<Value, Error> {
        if args.iter().any(|a| a.splat) {
            return Err(Error::at("Rest arguments can't be used with calculations.", pos));
        }
        let mut parts = Vec::with_capacity(args.len());
        for a in args {
            let inner = self.eval_calc(&a.value)?.to_calc_css(self.compressed());
            // A named argument (`min($a: 1)`) is not valid in a calculation, but
            // we preserve any name verbatim to mirror the surface syntax.
            match &a.name {
                Some(n) => parts.push(format!("${n}: {inner}")),
                None => parts.push(inner),
            }
        }
        Ok(Value::Str(SassStr {
            text: format!("{name}({})", parts.join(", ")).into(),
            quoted: false,
        }))
    }

    /// Try to evaluate a single-/double-argument math calculation (`sin`,
    /// `sqrt`, `pow`, `log`, `hypot`, …) as a calculation. Each argument is
    /// evaluated through the calc machinery, which rejects disallowed operators
    /// (`%`, comparisons) the way dart-sass does.
    ///
    /// - When *every* argument folds to a single number, returns `Ok(None)`:
    ///   the caller falls through to the ordinary builtin, which computes the
    ///   result and applies its unit checks (so `sqrt(2)`, `sin(1deg)`,
    ///   `sin(1px)`-the-error all behave exactly as before).
    /// - When an argument still carries an opaque operand — a `var()`,
    ///   interpolation, or unknown identifier — the whole call is preserved as a
    ///   calculation string (`sin(2px + var(--c))`).
    /// - When an argument reduces to a numeric operation we cannot collapse to a
    ///   single number (compound/inverse units), returns `Ok(None)` so the
    ///   builtin re-evaluates and reports its own error, rather than silently
    ///   preserving a value dart-sass would reject.
    pub(super) fn try_eval_calc_math_call(
        &mut self,
        name: &str,
        args: &[CallArg],
        _pos: Pos,
    ) -> Result<Option<Value>, Error> {
        let mut nodes = Vec::with_capacity(args.len());
        for a in args {
            nodes.push(self.eval_calc(&a.value)?);
        }
        // Every argument is a plain number: let the builtin compute.
        if nodes.iter().all(|n| matches!(n, CalcNode::Number(_))) {
            return Ok(None);
        }
        // No opaque operand anywhere: the calculation is purely numeric but did
        // not collapse (compound/inverse units). Defer to the builtin so it can
        // raise the dart-sass error instead of us preserving an invalid value.
        if !nodes.iter().any(calc_node_has_opaque) {
            return Ok(None);
        }
        let lname = name.to_ascii_lowercase();
        let parts: Vec<String> = nodes.iter().map(|n| n.to_calc_css(self.compressed())).collect();
        Ok(Some(Value::Str(SassStr {
            text: format!("{lname}({})", parts.join(self.calc_arg_sep())).into(),
            quoted: false,
        })))
    }

    /// What separates a preserved calculation's arguments: compressed output
    /// takes the space out, exactly as `CalcNode::Func` does for the calls that
    /// reach emit as a typed node rather than as text.
    fn calc_arg_sep(&self) -> &'static str {
        if self.compressed() {
            ","
        } else {
            ", "
        }
    }

    /// Evaluate a three-argument `clamp(min, value, max)` calculation. Each
    /// argument is evaluated through the calc machinery (rejecting `%` and other
    /// non-calculation operators). When every argument folds to a single number,
    /// the builtin clamps/unit-checks them as before; when an argument keeps a
    /// `var()`/calculation operand the call is preserved
    /// (`clamp(1% + 1px, 2px, 3px)`). A resolved operand with complex units is
    /// rejected like dart-sass.
    pub(super) fn try_eval_clamp(&mut self, args: &[CallArg], pos: Pos) -> Result<Value, Error> {
        let mut nodes = Vec::with_capacity(args.len());
        for a in args {
            let node = self.eval_calc(&a.value)?;
            if let Some(complex) = calc_complex_unit_operand(&node) {
                return Err(Error::at(
                    format!(
                        "Number calc({}) isn't compatible with CSS calculations.",
                        complex.to_calc_css(false)
                    ),
                    pos,
                ));
            }
            nodes.push(node);
        }
        // Every argument is a plain number: let the builtin clamp them (and run
        // its incompatible-unit and complex-unit checks).
        if nodes.iter().all(|n| matches!(n, CalcNode::Number(_))) {
            let values: Vec<Value> = nodes
                .into_iter()
                .map(|n| match n {
                    CalcNode::Number(num) => Value::Number(num),
                    // Unreachable: guarded by the `all` check above.
                    other => Value::Calc(other),
                })
                .collect();
            return crate::builtins::call("clamp", &values, &[], pos);
        }
        let parts: Vec<String> = nodes.iter().map(|n| n.to_calc_css(self.compressed())).collect();
        Ok(Value::Str(SassStr {
            text: format!("clamp({})", parts.join(self.calc_arg_sep())).into(),
            quoted: false,
        }))
    }

    /// Evaluate a `calc-size(target, value)` calculation. The target (`auto`,
    /// `none`, `size`, a `var()`, or a nested calculation) and the optional
    /// value are each evaluated through the calc machinery and the call is kept
    /// preserved (`calc-size()` never reduces to a number). Exactly one or two
    /// arguments are accepted.
    pub(super) fn eval_calc_size(&mut self, args: &[CallArg], pos: Pos) -> Result<Value, Error> {
        if args.is_empty() {
            return Err(Error::at("Missing argument.", pos));
        }
        if args.len() > 2 {
            return Err(Error::at(
                format!("Only 2 arguments allowed, but {} were passed.", args.len()),
                pos,
            ));
        }
        let mut parts = Vec::with_capacity(args.len());
        for a in args {
            parts.push(self.eval_calc(&a.value)?.to_calc_css(self.compressed()));
        }
        Ok(Value::Str(SassStr {
            text: format!("calc-size({})", parts.join(self.calc_arg_sep())).into(),
            quoted: false,
        }))
    }

    /// Evaluate the interior of a `calc()` into a simplified node tree.
    /// Numeric `number <op> number` subtrees with compatible units fold;
    /// everything else (variables, interpolations, incompatible units) is
    /// preserved for canonical serialization, mirroring dart-sass's
    /// "only simplify number+number" rule.
    pub(super) fn eval_calc(&mut self, expr: &Expr) -> Result<CalcNode, Error> {
        match expr {
            Expr::Binary { op, lhs, rhs, pos } => {
                let calc_op = match op {
                    BinOp::Add => CalcOp::Add,
                    BinOp::Sub => CalcOp::Sub,
                    BinOp::Mul => CalcOp::Mul,
                    // Modulo, comparisons, and `and`/`or` are not arithmetic;
                    // dart-sass rejects them inside a calculation rather than
                    // evaluating them (`calc(1px % 2px)`, `calc(1 > 2)`).
                    _ => return Err(Error::at("This operation can't be used in a calculation.", *pos)),
                };
                let l = self.eval_calc(lhs)?;
                let r = self.eval_calc(rhs)?;
                if self.in_supports_declaration {
                    return Ok(CalcNode::Op {
                        op: calc_op,
                        left: Box::new(l),
                        right: Box::new(r),
                    });
                }
                fold_calc(calc_op, l, r, *pos)
            }
            Expr::Div { lhs, rhs, pos, .. } => {
                let l = self.eval_calc(lhs)?;
                let r = self.eval_calc(rhs)?;
                if self.in_supports_declaration {
                    return Ok(CalcNode::Op {
                        op: CalcOp::Div,
                        left: Box::new(l),
                        right: Box::new(r),
                    });
                }
                fold_calc(CalcOp::Div, l, r, *pos)
            }
            Expr::Unary {
                op: UnOp::Neg,
                operand,
            } => {
                let node = self.eval_calc(operand)?;
                match node {
                    CalcNode::Number(n) => Ok(CalcNode::Number(n.copy_units(-n.value))),
                    other => Ok(CalcNode::Op {
                        op: CalcOp::Mul,
                        left: Box::new(CalcNode::Number(Number::unitless(-1.0))),
                        right: Box::new(other),
                    }),
                }
            }
            // Parentheses around a single opaque operand (a `var()`,
            // identifier, or interpolation) are preserved verbatim; around a
            // number or an operation they are redundant and dropped (operator
            // precedence reintroduces them where needed).
            Expr::Paren(inner) => {
                let node = self.eval_calc(inner)?;
                match node {
                    CalcNode::Str(s) => Ok(CalcNode::Str(format!("({s})"))),
                    other => Ok(other),
                }
            }
            // A nested calc() flattens into the surrounding calculation —
            // except inside a `@supports` declaration, where dart-sass keeps the
            // calculation unsimplified, so the inner `calc(...)` stays wrapped.
            // Otherwise an unresolved single-string operand (an interpolation or
            // a `var()` substitution that is not a clean operand) is
            // parenthesized: dart-sass writes `calc(calc(#{"c*"}))` as
            // `calc((c*))` and `calc(1 + calc(var(--c)))` as `calc(1 +
            // (var(--c)))`. A clean identifier, number, operation, or complete
            // sub-calculation flattens without extra parens.
            Expr::Calc { inner, .. } => {
                if self.in_supports_declaration {
                    let s = self.eval_calc(inner)?.to_calc_css(self.compressed());
                    return Ok(CalcNode::Str(format!("calc({s})")));
                }
                let node = self.eval_calc(inner)?;
                match node {
                    CalcNode::Str(s) if nested_calc_needs_parens(&s) => Ok(CalcNode::Str(format!("({s})"))),
                    other => Ok(other),
                }
            }
            // A space-separated list written directly in the calc interior is
            // an "unparsed" run: it is only valid when it contains a `var()`/
            // `env()` substitution, an interpolation, or a variable holding an
            // unquoted string — all of which dart-sass splices verbatim
            // (`calc(var(--c) 1)`, `calc(#{"1 +"} 2)` -> `calc(1 + 2)`,
            // `calc(1 $c)` with `$c: unquote("+ 2")` -> `calc(1 + 2)`). A
            // space-list of ordinary operands (`calc(1 2)`, `calc(c 1 2)`) or
            // of number-valued variables (`calc(1 $n)`) has no operator
            // between adjacent terms: "Missing math operator.".
            Expr::List {
                items,
                sep: ListSep::Space,
                bracketed: false,
            } => {
                let has_subst = items.iter().any(expr_has_substitution);
                if !has_subst
                    && !items
                        .iter()
                        .any(|e| matches!(e, Expr::Var { .. } | Expr::NsVar { .. }))
                {
                    return Err(Error::unpositioned("Missing math operator."));
                }
                let mut parts = Vec::with_capacity(items.len());
                let mut any_str = false;
                for it in items {
                    let node = self.eval_calc(it)?;
                    if matches!(node, CalcNode::Str(_)) {
                        any_str = true;
                    }
                    parts.push(node.to_calc_css(false));
                }
                // Variables alone only justify the splice when at least one
                // resolved to raw text.
                if !has_subst && !any_str {
                    return Err(Error::unpositioned("Missing math operator."));
                }
                Ok(CalcNode::Str(parts.join(" ")))
            }
            // Any leaf (number, var(), interpolation, ident) evaluates to a
            // value and becomes a calc operand.
            other => {
                let v = self.eval_expr(other)?;
                // The calc constants `pi`/`e`/`infinity`/`-infinity`/`nan`
                // (case-insensitive) resolve to their numeric values inside a
                // calculation, so `calc(infinity * 2)` folds to `calc(infinity)`
                // and `calc(NaN)` canonicalizes its spelling.
                if let Value::Str(s) = &v {
                    if !s.quoted {
                        if let Some(value) = calc_constant(&s.text) {
                            return Ok(CalcNode::Number(Number::unitless(value)));
                        }
                    }
                }
                // Only a number, a nested calculation, or an unquoted string
                // (a `var()`, interpolation, ident, or other special CSS value)
                // is a legal calculation operand. A null, bool, color, list,
                // map, or quoted string evaluated into the calc — typically via
                // a `$variable` or function call — is rejected the way
                // dart-sass does ("Value … can't be used in a calculation.").
                match &v {
                    Value::Number(_) | Value::Calc(_) | Value::Slash(_, _) => {}
                    Value::Str(s) if !s.quoted => {}
                    other => {
                        return Err(Error::unpositioned(format!(
                            "Value {} can't be used in a calculation.",
                            calc_value_repr(other)
                        )));
                    }
                }
                Ok(value_to_calc_node(v))
            }
        }
    }
}
