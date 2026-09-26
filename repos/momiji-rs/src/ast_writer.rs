//! Writing an [`Expr`] back out as Sass source.
//!
//! dart-sass embeds expression text in one diagnostic: the `[if-function]`
//! deprecation quotes the three arguments of a legacy `if()` inside the modern
//! syntax it suggests. It does that by writing the parsed AST back out, NOT by
//! slicing the source — `if(true,1+2,3)` suggests `1 + 2`, `1e3` becomes
//! `1000`, and `"a\41 b"` becomes `"aAb"` — so this mirrors
//! `Expression.toString()` rather than remembering spans. Every shape here was
//! measured against dart-sass 1.103.1 (scratch `dartref/if3..if7.sh`).

use crate::ast::{
    BinOp, CallArg, CssCustomValue, Expr, IfClause, IfCond, ImportArg, ImportModifier, MediaFeature,
    MediaInParens, MediaQuery, MediaQueryList, ParamList, Stmt, SupportsCondition, SupportsValue, TplPiece,
    UnOp,
};
use crate::scanner::Pos;
use crate::value::{ListSep, Number, Value};

fn write_into(out: &mut String, e: &Expr) {
    match e {
        // A number is written as its VALUE, not as it was typed: `1e3` is
        // `1000` and `.5` is `0.5`.
        Expr::Number(v, unit) => {
            out.push_str(&Value::Number(Number::with_unit(*v, unit)).to_css(false));
        }
        // A colour keeps the spelling it was authored with (`#ABCDEF`, `red`).
        Expr::Color(c) => out.push_str(&Value::Color(c.clone()).to_css(false)),
        Expr::QuotedString(pieces) => write_quoted(out, pieces),
        Expr::Ident(pieces) => write_template(out, pieces),
        Expr::Bool(b) => out.push_str(if *b { "true" } else { "false" }),
        Expr::Null => out.push_str("null"),
        Expr::Var { name, .. } => {
            out.push('$');
            out.push_str(name);
        }
        Expr::NsVar { module, name, .. } => {
            out.push_str(module);
            out.push_str(".$");
            out.push_str(name);
        }
        Expr::Parent => out.push('&'),
        Expr::Binary { op, lhs, rhs, .. } => {
            write_into(out, lhs);
            out.push(' ');
            out.push_str(binop(*op));
            out.push(' ');
            write_into(out, rhs);
        }
        Expr::Div { lhs, rhs, .. } => {
            write_into(out, lhs);
            out.push_str(" / ");
            write_into(out, rhs);
        }
        Expr::Calc { inner } => {
            out.push_str("calc(");
            write_into(out, inner);
            out.push(')');
        }
        Expr::Unary { op, operand } => write_unary(out, *op, operand),
        Expr::Func {
            name, args, module, ..
        } => {
            if let Some(m) = module {
                out.push_str(m);
                out.push('.');
            }
            out.push_str(name);
            write_args(out, args);
        }
        Expr::InterpFunc { name, args, .. } => {
            write_template(out, name);
            write_args(out, args);
        }
        Expr::List {
            items,
            sep,
            bracketed,
        } => write_list(out, items, *sep, *bracketed),
        Expr::Paren(inner) => {
            out.push('(');
            write_into(out, inner);
            out.push(')');
        }
        Expr::Map(pairs) => {
            out.push('(');
            for (i, (k, v)) in pairs.iter().enumerate() {
                if i > 0 {
                    out.push_str(", ");
                }
                write_into(out, k);
                out.push_str(": ");
                write_into(out, v);
            }
            out.push(')');
        }
        Expr::Interp(inner) => {
            out.push_str("#{");
            write_into(out, inner);
            out.push('}');
        }
        Expr::ModernIf(clauses) => write_modern_if(out, clauses),
    }
}

/// A unary operation. dart parenthesises an operand that is ITSELF a unary
/// operation — and writes the parentheses' CHARACTER CODES rather than the
/// characters, so `not not true` really is `not 40not true41` in dart-sass
/// 1.103.1 (`buffer.write($lparen)` where `writeCharCode` was meant). Mirrored
/// deliberately: this crate's output is compared to dart's byte for byte, and
/// the shape is unreachable without a doubled unary operator.
fn write_unary(out: &mut String, op: UnOp, operand: &Expr) {
    out.push_str(match op {
        UnOp::Neg => "-",
        UnOp::Plus => "+",
        UnOp::Not => "not ",
    });
    if matches!(operand, Expr::Unary { .. }) {
        out.push_str("40");
        write_into(out, operand);
        out.push_str("41");
    } else {
        write_into(out, operand);
    }
}

/// A list. An empty one, or a single-element comma-separated one, is written
/// parenthesised — without that it would not parse back as a list.
fn write_list(out: &mut String, items: &[Expr], sep: ListSep, bracketed: bool) {
    let comma = matches!(sep, ListSep::Comma);
    let needs_parens = !bracketed && (items.is_empty() || (items.len() == 1 && comma));
    if bracketed {
        out.push('[');
    } else if needs_parens {
        out.push('(');
    }
    let joiner = match sep {
        ListSep::Comma => ", ",
        ListSep::Slash => " / ",
        _ => " ",
    };
    for (i, item) in items.iter().enumerate() {
        if i > 0 {
            out.push_str(joiner);
        }
        write_into(out, item);
    }
    // A one-element comma list keeps its trailing comma only when the
    // parentheses are what make it a list: inside brackets the brackets
    // already do, and dart writes `[1]` for `[1,]`.
    if needs_parens && comma && !items.is_empty() {
        out.push(',');
    }
    if bracketed {
        out.push(']');
    } else if needs_parens {
        out.push(')');
    }
}

fn write_args(out: &mut String, args: &[CallArg]) {
    out.push('(');
    for (i, a) in args.iter().enumerate() {
        if i > 0 {
            out.push_str(", ");
        }
        if let Some(n) = &a.name {
            out.push('$');
            out.push_str(n);
            out.push_str(": ");
        }
        write_into(out, &a.value);
        if a.splat {
            out.push_str("...");
        }
    }
    out.push(')');
}

/// A quoted string. With no interpolation it is the STRING's serialization
/// (escapes decoded, best quote chosen), which is why `"a\41 b"` comes back as
/// `"aAb"` and `"he said \"hi\""` as `'he said "hi"'`. With interpolation the
/// pieces are written between quotes chosen the same way.
fn write_quoted(out: &mut String, pieces: &[TplPiece]) {
    let literal: String = pieces
        .iter()
        .map(|p| match p {
            TplPiece::Lit(s) => s,
            TplPiece::Interp(_) => "",
        })
        .collect();
    if pieces.iter().all(|p| matches!(p, TplPiece::Lit(_))) {
        out.push_str(&crate::value::serialize_quoted(&literal));
        return;
    }
    // `serialize_quoted` picks the quote from the literal text alone; an
    // interpolation cannot change it, since its value is not known here.
    let quote = if literal.contains('"') && !literal.contains('\'') {
        '\''
    } else {
        '"'
    };
    out.push(quote);
    for p in pieces {
        match p {
            // Escaped exactly as a quote-less string would be — a literal
            // newline in the source is `\a` in the suggestion, not a newline
            // in the middle of the diagnostic.
            TplPiece::Lit(s) => {
                let quoted = crate::value::serialize_quoted_with(s, quote);
                out.push_str(&quoted[1..quoted.len() - 1]);
            }
            TplPiece::Interp(e) => {
                out.push_str("#{");
                write_into(out, e);
                out.push('}');
            }
        }
    }
    out.push(quote);
}

/// An unquoted identifier or a raw interpolated sequence: literal text
/// verbatim, interpolations as `#{…}`.
fn write_template(out: &mut String, pieces: &[TplPiece]) {
    for p in pieces {
        match p {
            TplPiece::Lit(s) => out.push_str(s),
            TplPiece::Interp(e) => {
                out.push_str("#{");
                write_into(out, e);
                out.push('}');
            }
        }
    }
}

/// The modern `if()` — the syntax the deprecation suggests, and a legal
/// expression in its own right.
fn write_modern_if(out: &mut String, clauses: &[IfClause]) {
    out.push_str("if(");
    for (i, c) in clauses.iter().enumerate() {
        if i > 0 {
            out.push_str("; ");
        }
        match &c.condition {
            Some(cond) => {
                write_cond(out, cond);
                out.push_str(": ");
            }
            None => out.push_str("else: "),
        }
        write_into(out, &c.value);
    }
    out.push(')');
}

fn write_cond(out: &mut String, c: &IfCond) {
    match c {
        IfCond::Sass(e) => {
            out.push_str("sass(");
            write_into(out, e);
            out.push(')');
        }
        IfCond::Raw { pieces, .. } => write_template(out, pieces),
        IfCond::Not(inner) => {
            out.push_str("not ");
            write_cond(out, inner);
        }
        IfCond::And(parts) => write_cond_chain(out, parts, " and "),
        IfCond::Or(parts) => write_cond_chain(out, parts, " or "),
        IfCond::Paren(inner) => {
            out.push('(');
            write_cond(out, inner);
            out.push(')');
        }
    }
}

fn write_cond_chain(out: &mut String, parts: &[IfCond], joiner: &str) {
    for (i, p) in parts.iter().enumerate() {
        if i > 0 {
            out.push_str(joiner);
        }
        write_cond(out, p);
    }
}

fn binop(op: BinOp) -> &'static str {
    match op {
        BinOp::Add => "+",
        BinOp::Sub => "-",
        BinOp::Mul => "*",
        BinOp::Mod => "%",
        BinOp::Eq => "==",
        BinOp::Neq => "!=",
        BinOp::Lt => "<",
        BinOp::Gt => ">",
        BinOp::Le => "<=",
        BinOp::Ge => ">=",
        BinOp::And => "and",
        BinOp::Or => "or",
        BinOp::SingleEq => "=",
    }
}

/// The modern `if()` that replaces a legacy `if($c, $t, $f)`, or `None` when
/// the call is not the three plain positional arguments the rewrite needs —
/// dart omits the suggestion for a named, splatted or wrong-arity call and
/// deprecates it all the same.
///
/// A literal `null` branch is dropped rather than written: dart suggests
/// `if(sass($c): $t)` when the else branch is `null`, and flips the condition
/// to `if(not sass($c): $f)` when the then branch is.
pub(crate) fn legacy_if_suggestion(args: &[CallArg]) -> Option<String> {
    if args.len() != 3 || args.iter().any(|a| a.name.is_some() || a.splat) {
        return None;
    }
    let cond = &args[0].value;
    let when_true = &args[1].value;
    let when_false = &args[2].value;
    let mut out = String::from("if(");
    if matches!(when_false, Expr::Null) {
        out.push_str("sass(");
        write_into(&mut out, cond);
        out.push_str("): ");
        write_into(&mut out, when_true);
    } else if matches!(when_true, Expr::Null) {
        out.push_str("not sass(");
        write_into(&mut out, cond);
        out.push_str("): ");
        write_into(&mut out, when_false);
    } else {
        out.push_str("sass(");
        write_into(&mut out, cond);
        out.push_str("): ");
        write_into(&mut out, when_true);
        out.push_str("; else: ");
        write_into(&mut out, when_false);
    }
    out.push(')');
    Some(out)
}

/// A deprecation dart raises when a file is PARSED rather than when its code
/// runs — so it fires for a mixin nobody includes and an `@if false` branch,
/// exactly once however many times the code executes, with the load site as its
/// only stack frame.
pub(crate) enum ParseTimeDeprecation {
    /// A Sass `@import` rule.
    Import { pos: Pos, length: usize },
    /// A legacy `if($c, $t, $f)`, with the modern rewrite dart suggests (absent
    /// for a named, splatted or wrong-arity call).
    LegacyIf {
        pos: Pos,
        length: usize,
        suggestion: Option<String>,
    },
}

/// Every parse-time deprecation in a sheet, in the order dart reports them:
/// source order across statements — the two kinds interleave — and INNERMOST
/// FIRST within one expression, which falls out of dart building the
/// expression bottom up.
pub(crate) fn collect_parse_time_deprecations(stmts: &[Stmt]) -> Vec<ParseTimeDeprecation> {
    let mut out = Vec::new();
    walk_stmts(stmts, &mut out);
    out
}

type Found = Vec<ParseTimeDeprecation>;

fn walk_stmts(stmts: &[Stmt], out: &mut Found) {
    for stmt in stmts {
        walk_stmt(stmt, out);
    }
}

fn walk_stmt(stmt: &Stmt, out: &mut Found) {
    match stmt {
        Stmt::VarDecl(v) => walk_expr(&v.value, out),
        Stmt::Rule(r) => {
            walk_template(&r.selector, out);
            walk_stmts(&r.body, out);
        }
        Stmt::Decl(d) => {
            walk_template(&d.property, out);
            walk_expr(&d.value, out);
        }
        Stmt::PropertySet(p) => {
            walk_template(&p.property, out);
            if let Some(v) = &p.value {
                walk_expr(v, out);
            }
            walk_stmts(&p.body, out);
        }
        Stmt::CustomDecl(c) => {
            walk_template(&c.property, out);
            walk_template(&c.value, out);
        }
        Stmt::Import { args, .. } => {
            for arg in args {
                match arg {
                    ImportArg::Sass { path, pos, length } => {
                        if !crate::eval::is_css_import(path) {
                            out.push(ParseTimeDeprecation::Import {
                                pos: *pos,
                                length: *length,
                            });
                        }
                    }
                    // A plain-CSS import still holds parsed expressions: its
                    // url's interpolations (`@import url(if(…))`) and its
                    // `supports()`/media modifiers.
                    ImportArg::Css { url, modifiers, .. } => {
                        walk_template(url, out);
                        for m in modifiers {
                            match m {
                                ImportModifier::Raw(pieces) => walk_template(pieces, out),
                                ImportModifier::Supports { condition, .. } => walk_supports(condition, out),
                                ImportModifier::Media { list, .. } => walk_media(list, out),
                            }
                        }
                    }
                }
            }
        }
        Stmt::Content { args, .. } => walk_args(args, out),
        Stmt::Extend { selector, .. } => walk_template(selector, out),
        Stmt::Use { config, .. } | Stmt::Forward { config, .. } => {
            for entry in config {
                walk_expr(&entry.value, out);
            }
        }
        Stmt::Comment(pieces, _) => walk_template(pieces, out),
        Stmt::If(branches) => {
            for b in branches {
                if let Some(c) = &b.cond {
                    walk_expr(c, out);
                }
                walk_stmts(&b.body, out);
            }
        }
        Stmt::For { from, to, body, .. } => {
            walk_expr(from, out);
            walk_expr(to, out);
            walk_stmts(body, out);
        }
        Stmt::Each { list, body, .. } => {
            walk_expr(list, out);
            walk_stmts(body, out);
        }
        Stmt::While { cond, body } => {
            walk_expr(cond, out);
            walk_stmts(body, out);
        }
        Stmt::FunctionDef(c) | Stmt::MixinDef(c) => {
            walk_params(&c.params, out);
            walk_stmts(&c.body, out);
        }
        Stmt::Return(e) => walk_expr(e, out),
        Stmt::Include {
            args,
            content,
            content_params,
            ..
        } => {
            walk_args(args, out);
            if let Some(p) = content_params {
                walk_params(p, out);
            }
            if let Some(body) = content {
                walk_stmts(body, out);
            }
        }
        Stmt::AtRule { prelude, body, .. } => {
            walk_template(prelude, out);
            if let Some(b) = body {
                walk_stmts(b, out);
            }
        }
        Stmt::InterpAtRule {
            name, prelude, body, ..
        } => {
            walk_template(name, out);
            walk_template(prelude, out);
            if let Some(b) = body {
                walk_stmts(b, out);
            }
        }
        Stmt::CssCustomAtRule { prelude, body, .. } => {
            walk_template(prelude, out);
            for item in body {
                walk_template(&item.property, out);
                match &item.value {
                    CssCustomValue::Raw(pieces) => walk_template(pieces, out),
                    CssCustomValue::Script(e) => walk_expr(e, out),
                    CssCustomValue::Set(children) => {
                        for (suffix, value) in children {
                            walk_template(suffix, out);
                            walk_expr(value, out);
                        }
                    }
                }
            }
        }
        Stmt::Media { query, body, .. } => {
            walk_media(query, out);
            walk_stmts(body, out);
        }
        Stmt::Supports { condition, body, .. } => {
            walk_supports(condition, out);
            walk_stmts(body, out);
        }
        Stmt::Keyframes { prelude, body, .. } => {
            walk_template(prelude, out);
            walk_stmts(body, out);
        }
        Stmt::AtRoot { query, body } => {
            if let Some(q) = query {
                walk_template(q, out);
            }
            walk_stmts(body, out);
        }
        Stmt::Warn { value, .. } | Stmt::Debug { value, .. } | Stmt::Error { value, .. } => {
            walk_expr(value, out)
        }
    }
}

fn walk_params(params: &ParamList, out: &mut Found) {
    for p in &params.params {
        if let Some(d) = &p.default {
            walk_expr(d, out);
        }
    }
}

fn walk_args(args: &[CallArg], out: &mut Found) {
    for a in args {
        walk_expr(&a.value, out);
    }
}

fn walk_template(pieces: &[TplPiece], out: &mut Found) {
    for p in pieces {
        if let TplPiece::Interp(e) = p {
            walk_expr(e, out);
        }
    }
}

fn walk_expr(e: &Expr, out: &mut Found) {
    match e {
        Expr::Number(..)
        | Expr::Color(_)
        | Expr::Bool(_)
        | Expr::Null
        | Expr::Var { .. }
        | Expr::NsVar { .. }
        | Expr::Parent => {}
        Expr::QuotedString(pieces) | Expr::Ident(pieces) => walk_template(pieces, out),
        Expr::Binary { lhs, rhs, .. } | Expr::Div { lhs, rhs, .. } => {
            walk_expr(lhs, out);
            walk_expr(rhs, out);
        }
        Expr::Calc { inner } | Expr::Paren(inner) | Expr::Interp(inner) => walk_expr(inner, out),
        Expr::Unary { operand, .. } => walk_expr(operand, out),
        Expr::Func {
            name,
            args,
            pos,
            length,
            module,
        } => {
            // The arguments first: dart builds the expression bottom up, so a
            // nested `if()` is reported before the one holding it.
            walk_args(args, out);
            if module.is_none() && name == "if" {
                out.push(ParseTimeDeprecation::LegacyIf {
                    pos: *pos,
                    length: *length,
                    suggestion: legacy_if_suggestion(args),
                });
            }
        }
        Expr::InterpFunc { name, args, .. } => {
            walk_template(name, out);
            walk_args(args, out);
        }
        Expr::List { items, .. } => {
            for item in items {
                walk_expr(item, out);
            }
        }
        Expr::Map(pairs) => {
            for (k, v) in pairs {
                walk_expr(k, out);
                walk_expr(v, out);
            }
        }
        Expr::ModernIf(clauses) => {
            for c in clauses {
                if let Some(cond) = &c.condition {
                    walk_cond(cond, out);
                }
                walk_expr(&c.value, out);
            }
        }
    }
}

fn walk_cond(c: &IfCond, out: &mut Found) {
    match c {
        IfCond::Sass(e) => walk_expr(e, out),
        IfCond::Raw { pieces, .. } => walk_template(pieces, out),
        IfCond::Not(inner) | IfCond::Paren(inner) => walk_cond(inner, out),
        IfCond::And(parts) | IfCond::Or(parts) => {
            for p in parts {
                walk_cond(p, out);
            }
        }
    }
}

/// A `@media` prelude: its feature values are SassScript, so an `if()` can hide
/// in one.
fn walk_media(list: &MediaQueryList, out: &mut Found) {
    for q in &list.queries {
        match q {
            MediaQuery::Type {
                modifier,
                mtype,
                conditions,
            } => {
                if let Some(m) = modifier {
                    walk_template(m, out);
                }
                walk_template(mtype, out);
                for c in conditions {
                    walk_media_in_parens(c, out);
                }
            }
            MediaQuery::Condition { conditions, .. } => {
                for c in conditions {
                    walk_media_in_parens(c, out);
                }
            }
        }
    }
}

fn walk_media_in_parens(c: &MediaInParens, out: &mut Found) {
    match c {
        MediaInParens::Feature(f) => match f.as_ref() {
            MediaFeature::Decl { name, value } => {
                walk_expr(name, out);
                if let Some(v) = value {
                    walk_expr(v, out);
                }
            }
            MediaFeature::Range {
                first, second, rest, ..
            } => {
                walk_expr(first, out);
                walk_expr(second, out);
                if let Some((_, third)) = rest {
                    walk_expr(third, out);
                }
            }
        },
        MediaInParens::Not(inner) => walk_media_in_parens(inner, out),
        MediaInParens::Group { conditions, .. } => {
            for c in conditions {
                walk_media_in_parens(c, out);
            }
        }
        MediaInParens::Interp(e) => walk_expr(e, out),
    }
}

/// A `@supports` condition: a declaration's value is SassScript too.
fn walk_supports(c: &SupportsCondition, out: &mut Found) {
    match c {
        SupportsCondition::Declaration { name, value, .. } => {
            walk_expr(name, out);
            match value.as_ref() {
                SupportsValue::Expr(e) => walk_expr(e, out),
                SupportsValue::Raw(pieces) => walk_template(pieces, out),
            }
        }
        SupportsCondition::Negation(inner) => walk_supports(inner, out),
        SupportsCondition::Operation { left, right, .. } => {
            walk_supports(left, out);
            walk_supports(right, out);
        }
        SupportsCondition::Interpolation(e) => walk_expr(e, out),
        SupportsCondition::Function { name, arguments } => {
            walk_template(name, out);
            walk_template(arguments, out);
        }
        SupportsCondition::Anything(pieces) => walk_template(pieces, out),
    }
}
