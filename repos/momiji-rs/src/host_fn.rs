//! Host-defined (embedder) custom Sass functions — the engine side of the
//! dart-sass `functions` option.
//!
//! An embedder registers a function via [`crate::Options::with_function`] with a
//! signature (`"pow($base, $exponent)"`) and a **byte-protocol callback**
//! `Fn(&[u8]) -> Result<Vec<u8>, String>`. At call time the evaluator binds the
//! arguments, serializes them to the wire format below, invokes the callback,
//! and deserializes its returned bytes back into a [`Value`]. Keeping the
//! callback byte-oriented means the public API never exposes the internal
//! `Value` type, while the (de)serializers here — which DO touch `Value`'s
//! internals — stay crate-private. The wasm/FFI layers are then dumb pipes that
//! forward the bytes to the real host (e.g. a JS function).
//!
//! ## Wire format
//! A value is a tag byte followed by a payload; integers are little-endian, and
//! a "str" is a `u32` byte length followed by UTF-8. `serialize_args` writes a
//! `u32` count then that many values (the bound, ordered arguments).
//!
//! Supported value types: null, bool, number (with full unit lists), string,
//! list (separator + brackets + an optional argument-list keyword map), map, and
//! color (any CSS Color 4 space — serialized uniformly as a space name + three
//! optional channels + optional alpha; legacy sRGB folds to the `rgb` space).
//! Calculations and first-class function/mixin references are not yet
//! representable across the boundary and surface a clear error (added
//! incrementally); slash-divisions never reach here (call args are collapsed to
//! plain numbers before binding).

use std::rc::Rc;

use crate::ast::{Param, ParamList};
use crate::builtins::{legacy_to_modern, make_modern_in};
use crate::value::{
    unit_lists_factor, CalcNode, CalcOp, Color, ColorSpace, List, ListSep, Map, ModernColor, Number, SassStr,
    Value,
};

/// An embedder's custom-function callback: it receives the bound arguments
/// serialized to sasso's host-value wire format and returns the result
/// serialized the same way (or an `Err(message)` that becomes a compile error).
pub type HostFunction = Rc<dyn Fn(&[u8]) -> Result<Vec<u8>, String>>;

/// A registered host function: the matched (normalized) name, its parsed
/// signature (or a parse error to surface when the function is called), and the
/// embedder's byte-protocol callback.
pub(crate) struct HostFn {
    /// Hyphen-normalized function name used for call-site matching.
    pub name: String,
    /// The parsed parameter list, or an error message if the signature was
    /// malformed (surfaced as a compile error only if the function is called).
    pub params: Result<ParamList, String>,
    /// `Fn(serialized args) -> Ok(serialized return) | Err(message)`.
    pub callback: HostFunction,
}

/// Sass treats `_` and `-` as equivalent in identifiers.
pub(crate) fn normalize_name(s: &str) -> String {
    s.replace('_', "-")
}

/// Parse a `name($a, $b, $rest...)` signature into a normalized name plus its
/// parameter list. Default values (`$a: 1`) are not yet supported and yield an
/// error (kept with the name so calling the function reports it).
pub(crate) fn parse_signature(sig: &str) -> (String, Result<ParamList, String>) {
    let sig = sig.trim();
    let open = sig.find('(');
    let (raw_name, args_src) = match open {
        Some(i) => {
            let rest = sig[i + 1..].trim_end();
            let inner = rest.strip_suffix(')');
            match inner {
                Some(inner) => (&sig[..i], inner),
                None => {
                    return (
                        normalize_name(sig[..i].trim()),
                        Err("sasso: function signature is missing its closing ')'".into()),
                    )
                }
            }
        }
        // No parens: a zero-arg function.
        None => (sig, ""),
    };
    let name = normalize_name(raw_name.trim());
    if name.is_empty() {
        return (name, Err("sasso: function signature has no name".into()));
    }

    let mut params = Vec::new();
    let mut rest = None;
    for part in args_src.split(',') {
        let part = part.trim();
        if part.is_empty() {
            continue;
        }
        let var = match part.strip_prefix('$') {
            Some(v) => v.trim(),
            None => {
                return (
                    name,
                    Err(format!("sasso: signature parameter \"{part}\" must start with $")),
                )
            }
        };
        if let Some(r) = var.strip_suffix("...") {
            rest = Some(normalize_name(r.trim()));
            // A rest parameter must be last; ignore anything after it.
            break;
        }
        if var.contains(':') {
            return (
                name,
                Err("sasso: default values in custom-function signatures are not yet supported".into()),
            );
        }
        params.push(Param {
            name: var.to_string(),
            default: None,
            // A host-function signature has no source text to point at.
            default_pos: crate::scanner::Pos::NONE,
        });
    }
    (name, Ok(ParamList { params, rest }))
}

/// Bind evaluated call arguments to a host function's parameters, producing the
/// ordered positional values (plus a trailing argument-list value for a `$rest`
/// parameter) that are handed to the callback — mirroring `bind_evaled` for the
/// no-default host-function case. Names compare hyphen/underscore-insensitively.
pub(crate) fn bind_host_args(
    param_names: &[String],
    rest: Option<&str>,
    positional: Vec<Value>,
    named: Vec<(String, Value)>,
    rest_sep: ListSep,
    fn_name: &str,
) -> Result<Vec<Value>, String> {
    use std::collections::HashMap;
    let mut keyword: HashMap<String, Value> = HashMap::new();
    let mut keyword_order: Vec<String> = Vec::new();
    for (n, v) in named {
        let norm = normalize_name(&n);
        if !keyword.contains_key(&norm) {
            keyword_order.push(norm.clone());
        }
        keyword.insert(norm, v);
    }
    let mut out = Vec::with_capacity(param_names.len() + rest.is_some() as usize);
    let mut pos_iter = positional.into_iter();
    for p in param_names {
        let val = if let Some(v) = pos_iter.next() {
            v
        } else if let Some(v) = keyword.remove(&normalize_name(p)) {
            v
        } else {
            return Err(format!("Missing argument ${p}."));
        };
        out.push(val);
    }
    if let Some(rest_name) = rest {
        let remaining: Vec<Value> = pos_iter.collect();
        let kw: Vec<(Value, Value)> = keyword_order
            .iter()
            .filter_map(|norm| {
                keyword.remove(norm).map(|v| {
                    (
                        Value::Str(SassStr {
                            text: norm.clone().into(),
                            quoted: false,
                        }),
                        v,
                    )
                })
            })
            .collect();
        let _ = rest_name;
        out.push(Value::List(List {
            items: remaining.into(),
            sep: rest_sep,
            bracketed: false,
            keywords: Some(kw),
        }));
    } else if pos_iter.next().is_some() {
        return Err(format!("{fn_name} was passed too many arguments."));
    } else if let Some(extra) = keyword_order.into_iter().find(|k| keyword.contains_key(k)) {
        return Err(format!("No argument named ${extra}."));
    }
    Ok(out)
}

// ---------------- value operations (engine-routed Value methods) ----------------
//
// dart-sass `Value` methods that need unit / color-space math (e.g.
// `SassNumber.convert`, `SassColor.toSpace`) route from JS back into the engine
// here, so the conversions reuse the exact Rust math instead of being
// reimplemented (and drifting) in JS. The JS side calls a wasm `sasso_value_op`
// export that forwards to [`host_value_op`]; both sides speak the same byte
// protocol as custom functions, on a value instance that is independent of any
// in-flight compile (so the methods also work standalone).

/// Convert/coerce a number to target units. dart-sass:
/// - **convert**: both unitless → ok; one unitless and the other not → error;
///   both have units → must be compatible.
/// - **coerce**: a unitless side is treated as compatible (factor 1).
const OP_NUMBER_CONVERT: u32 = 1;
/// Test whether a number is convertible to a single unit (`compatibleWithUnit`).
const OP_NUMBER_COMPATIBLE: u32 = 2;
/// `SassColor.toSpace(space)` — `[color, Str(space)]` -> color.
const OP_COLOR_TO_SPACE: u32 = 3;
/// `SassColor.isInGamut(space?)` — `[color, Str(space)]` -> bool.
const OP_COLOR_IN_GAMUT: u32 = 4;
/// `SassColor.toGamut(space, method)` — `[color, Str(space), Str(method)]` -> color.
const OP_COLOR_TO_GAMUT: u32 = 5;
/// `SassColor.isChannelPowerless(channel, space?)` — `[color, Str(channel), Str(space)]` -> bool.
const OP_COLOR_POWERLESS: u32 = 6;
/// `SassColor.interpolate(other, weight%, method)` — `[c1, c2, Number, Str(method)]` -> color.
const OP_COLOR_INTERPOLATE: u32 = 7;

/// Run a value operation: deserialize the operands, dispatch on `op`, and return
/// the serialized result (or an `Err(message)` surfaced to the JS caller).
pub fn host_value_op(op: u32, input: &[u8]) -> Result<Vec<u8>, String> {
    let args = deserialize_args(input)?;
    let result = match op {
        OP_NUMBER_CONVERT => number_convert(&args)?,
        OP_NUMBER_COMPATIBLE => {
            let n = as_number(args.first())?;
            let unit = as_string(args.get(1))?;
            let from = (n.numer_units(), n.denom_units());
            let to_numer: Vec<Rc<str>> = if unit.is_empty() {
                vec![]
            } else {
                vec![unit.into()]
            };
            let ok = number_factor(from, (&to_numer, &[]), true).is_some();
            Value::Bool(ok)
        }
        OP_COLOR_TO_SPACE => {
            let space = unquoted(as_string(args.get(1))?);
            call_color("to-space", &[arg(&args, 0)?, space], &[])?
        }
        OP_COLOR_IN_GAMUT => {
            let space = unquoted(as_string(args.get(1))?);
            call_color("is-in-gamut", &[arg(&args, 0)?], &[("space", space)])?
        }
        OP_COLOR_TO_GAMUT => {
            let space = unquoted(as_string(args.get(1))?);
            let method = unquoted(as_string(args.get(2))?);
            call_color(
                "to-gamut",
                &[arg(&args, 0)?],
                &[("space", space), ("method", method)],
            )?
        }
        OP_COLOR_POWERLESS => {
            // `color.is-powerless($color, $channel, $space)` — channel is quoted.
            let channel = Value::Str(SassStr {
                text: as_string(args.get(1))?.into(),
                quoted: true,
            });
            let space = unquoted(as_string(args.get(2))?);
            call_color("is-powerless", &[arg(&args, 0)?, channel], &[("space", space)])?
        }
        OP_COLOR_INTERPOLATE => {
            // `color.mix($c1, $c2, $weight, $method)` — weight already a %, method a string.
            let method = unquoted(as_string(args.get(3))?);
            call_color(
                "mix",
                &[arg(&args, 0)?, arg(&args, 1)?, arg(&args, 2)?, method],
                &[],
            )?
        }
        _ => return Err(format!("sasso: unknown value op {op}")),
    };
    serialize_one(&result)
}

fn arg(args: &[Value], i: usize) -> Result<Value, String> {
    args.get(i)
        .cloned()
        .ok_or_else(|| "sasso: value op missing an argument".to_string())
}
fn unquoted(text: String) -> Value {
    Value::Str(SassStr {
        text: text.into(),
        quoted: false,
    })
}
/// Route a color value-op to the corresponding `color.*` builtin.
fn call_color(member: &str, pos_args: &[Value], named: &[(&str, Value)]) -> Result<Value, String> {
    let named: Vec<(String, Value)> = named.iter().map(|(k, v)| (k.to_string(), v.clone())).collect();
    crate::builtins::call_module(
        "color",
        member,
        pos_args,
        &named,
        crate::scanner::Pos { line: 1, col: 1 },
    )
    .map_err(|e| e.message)
}

fn as_number(v: Option<&Value>) -> Result<&Number, String> {
    match v {
        Some(Value::Number(n)) => Ok(n),
        _ => Err("sasso: value op expected a number".to_string()),
    }
}
fn as_string(v: Option<&Value>) -> Result<String, String> {
    match v {
        Some(Value::Str(s)) => Ok(s.text.to_string()),
        _ => Err("sasso: value op expected a string".to_string()),
    }
}
/// Extract a unit list from a list (or single string / empty / null) value.
fn as_string_list(v: Option<&Value>) -> Vec<Rc<str>> {
    match v {
        Some(Value::List(l)) => l
            .items
            .iter()
            .filter_map(|i| {
                if let Value::Str(s) = i {
                    Some(Rc::clone(&s.text))
                } else {
                    None
                }
            })
            .collect(),
        Some(Value::Str(s)) => vec![Rc::clone(&s.text)],
        _ => vec![],
    }
}

/// The multiplier from `from` units to `to` units under convert/coerce rules,
/// or `None` if the conversion is illegal.
fn number_factor(from: (&[Rc<str>], &[Rc<str>]), to: (&[Rc<str>], &[Rc<str>]), coerce: bool) -> Option<f64> {
    let from_unitless = from.0.is_empty() && from.1.is_empty();
    let to_unitless = to.0.is_empty() && to.1.is_empty();
    if from_unitless || to_unitless {
        if coerce || (from_unitless && to_unitless) {
            Some(1.0)
        } else {
            None // convert: can't cross the unitless boundary
        }
    } else {
        unit_lists_factor(from, to)
    }
}

fn number_convert(args: &[Value]) -> Result<Value, String> {
    let n = as_number(args.first())?;
    let numer = as_string_list(args.get(1));
    let denom = as_string_list(args.get(2));
    let coerce = matches!(args.get(3), Some(Value::Bool(true)));
    let from = (n.numer_units(), n.denom_units());
    match number_factor(from, (&numer, &denom), coerce) {
        Some(f) => Ok(Value::Number(Number::with_units(n.value * f, numer, denom))),
        None => {
            let to = if numer.is_empty() && denom.is_empty() {
                "no units".to_string()
            } else {
                let mut s = numer.join("*");
                if !denom.is_empty() {
                    s.push('/');
                    s.push_str(&denom.join("*"));
                }
                s
            };
            Err(format!(
                "{} can't be converted to {to}.",
                Value::Number(n.clone()).to_css(false)
            ))
        }
    }
}

// ---------------- serialization ----------------

const TAG_NULL: u8 = 0;
const TAG_BOOL: u8 = 1;
const TAG_NUMBER: u8 = 2;
const TAG_STRING: u8 = 3;
const TAG_LIST: u8 = 4;
const TAG_MAP: u8 = 5;
const TAG_COLOR: u8 = 6;
const TAG_CALC: u8 = 7;
const TAG_FUNCTION: u8 = 8;
const TAG_MIXIN: u8 = 9;

// First-class function/mixin references can't be reconstructed on the JS side, so
// they cross the boundary as OPAQUE HANDLES: serialization stores the `Value` here
// and emits its index; the JS side holds an opaque object and, when it passes the
// reference back, sends the index, which deserialization looks up. The table is
// per custom-function dispatch (expr.rs swaps a fresh one in, restoring the outer
// one afterwards, so a nested custom-function call is safe).
thread_local! {
    static HANDLES: std::cell::RefCell<Vec<Value>> = const { std::cell::RefCell::new(Vec::new()) };
}

/// Install a fresh handle table and return the previous one (to restore). Called
/// by the evaluator around each custom-function call.
pub(crate) fn swap_handles(next: Vec<Value>) -> Vec<Value> {
    HANDLES.with(|h| std::mem::replace(&mut *h.borrow_mut(), next))
}
fn push_handle(v: Value) -> usize {
    HANDLES.with(|h| {
        let mut b = h.borrow_mut();
        b.push(v);
        b.len() - 1
    })
}
fn get_handle(i: usize) -> Result<Value, String> {
    HANDLES
        .with(|h| h.borrow().get(i).cloned())
        .ok_or_else(|| "sasso: stale function/mixin reference from a custom function".to_string())
}

/// Write an optional channel: a present flag then (if present) the f64.
fn put_opt_f64(out: &mut Vec<u8>, v: Option<f64>) {
    match v {
        Some(n) => {
            out.push(1);
            put_f64(out, n);
        }
        None => out.push(0),
    }
}

fn put_u32(out: &mut Vec<u8>, n: usize) {
    out.extend_from_slice(&(n as u32).to_le_bytes());
}
fn put_str(out: &mut Vec<u8>, s: &str) {
    put_u32(out, s.len());
    out.extend_from_slice(s.as_bytes());
}
fn put_f64(out: &mut Vec<u8>, n: f64) {
    out.extend_from_slice(&n.to_le_bytes());
}

/// Serialize the ordered, bound arguments: a `u32` count then each value.
pub(crate) fn serialize_args(args: &[Value]) -> Result<Vec<u8>, String> {
    let mut out = Vec::new();
    put_u32(&mut out, args.len());
    for a in args {
        serialize_value(&mut out, a)?;
    }
    Ok(out)
}

/// Serialize a single value (the host side serializing a function's return).
///
/// Host-side helper: the wasm path encodes in JS (not Rust), so this is used by
/// the in-crate tests now and the FFI host-function bridge later.
#[allow(dead_code)]
pub(crate) fn serialize_one(v: &Value) -> Result<Vec<u8>, String> {
    let mut out = Vec::new();
    serialize_value(&mut out, v)?;
    Ok(out)
}

fn serialize_value(out: &mut Vec<u8>, v: &Value) -> Result<(), String> {
    match v {
        Value::Null => out.push(TAG_NULL),
        Value::Bool(b) => {
            out.push(TAG_BOOL);
            out.push(*b as u8);
        }
        Value::Number(n) => {
            out.push(TAG_NUMBER);
            write_number_body(out, n);
        }
        Value::Str(s) => {
            out.push(TAG_STRING);
            out.push(s.quoted as u8);
            put_str(out, &s.text);
        }
        Value::List(l) => {
            out.push(TAG_LIST);
            out.push(sep_code(l.sep));
            out.push(l.bracketed as u8);
            put_u32(out, l.items.len());
            for it in l.items.iter() {
                serialize_value(out, it)?;
            }
            match &l.keywords {
                Some(kw) => {
                    out.push(1);
                    put_u32(out, kw.len());
                    for (k, val) in kw {
                        serialize_value(out, k)?;
                        serialize_value(out, val)?;
                    }
                }
                None => out.push(0),
            }
        }
        Value::Map(m) => {
            out.push(TAG_MAP);
            put_u32(out, m.entries.len());
            for (k, val) in m.entries.iter() {
                serialize_value(out, k)?;
                serialize_value(out, val)?;
            }
        }
        Value::Color(c) => {
            // Represent every color uniformly as a space + 3 channels + alpha
            // (legacy sRGB folds to the "rgb" space). Missing channels (`none`)
            // round-trip via the present flag.
            out.push(TAG_COLOR);
            let mc = legacy_to_modern(c);
            put_str(out, mc.space.name());
            for ch in mc.channels {
                put_opt_f64(out, ch);
            }
            put_opt_f64(out, mc.alpha);
        }
        Value::Calc(node) => {
            out.push(TAG_CALC);
            write_calc_node(out, node);
        }
        Value::Slash(..) => {
            // A slash-division never reaches here (call args are slash-collapsed
            // before binding, and JS can't construct one).
            return Err("sasso: slash-division values are not supported as custom-function values".into());
        }
        Value::Function(_) => {
            out.push(TAG_FUNCTION);
            put_u32(out, push_handle(v.clone()));
        }
        Value::Mixin(_) => {
            out.push(TAG_MIXIN);
            put_u32(out, push_handle(v.clone()));
        }
    }
    Ok(())
}

/// The `[f64 value][numer units][denom units]` body of a number (shared by the
/// `TAG_NUMBER` value and a calc `Number` node).
fn write_number_body(out: &mut Vec<u8>, n: &Number) {
    put_f64(out, n.value);
    put_u32(out, n.numer_units().len());
    for u in n.numer_units() {
        put_str(out, u);
    }
    put_u32(out, n.denom_units().len());
    for u in n.denom_units() {
        put_str(out, u);
    }
}

fn calc_op_code(op: CalcOp) -> u8 {
    match op {
        CalcOp::Add => 0,
        CalcOp::Sub => 1,
        CalcOp::Mul => 2,
        CalcOp::Div => 3,
    }
}

/// Serialize a `CalcNode` tree: tag byte (0 Number, 1 Str, 2 Op, 3 Func) + payload.
fn write_calc_node(out: &mut Vec<u8>, node: &CalcNode) {
    match node {
        CalcNode::Number(n) => {
            out.push(0);
            write_number_body(out, n);
        }
        CalcNode::Str(s) => {
            out.push(1);
            put_str(out, s);
        }
        CalcNode::Op { op, left, right } => {
            out.push(2);
            out.push(calc_op_code(*op));
            write_calc_node(out, left);
            write_calc_node(out, right);
        }
        CalcNode::Func { name, args } => {
            out.push(3);
            put_str(out, name);
            put_u32(out, args.len());
            for a in args {
                write_calc_node(out, a);
            }
        }
    }
}

fn sep_code(sep: ListSep) -> u8 {
    match sep {
        ListSep::Space => 0,
        ListSep::Comma => 1,
        ListSep::Slash => 2,
        ListSep::Undecided => 3,
    }
}
fn sep_from(code: u8) -> Result<ListSep, String> {
    Ok(match code {
        0 => ListSep::Space,
        1 => ListSep::Comma,
        2 => ListSep::Slash,
        3 => ListSep::Undecided,
        _ => return Err("sasso: bad list separator in custom-function result".into()),
    })
}

// ---------------- deserialization ----------------

struct Reader<'a> {
    buf: &'a [u8],
    pos: usize,
}
impl<'a> Reader<'a> {
    fn u8(&mut self) -> Result<u8, String> {
        let b = *self
            .buf
            .get(self.pos)
            .ok_or("sasso: truncated custom-function result")?;
        self.pos += 1;
        Ok(b)
    }
    fn u32(&mut self) -> Result<usize, String> {
        let end = self
            .pos
            .checked_add(4)
            .ok_or("sasso: truncated custom-function result")?;
        let b = self
            .buf
            .get(self.pos..end)
            .ok_or("sasso: truncated custom-function result")?;
        self.pos = end;
        Ok(u32::from_le_bytes([b[0], b[1], b[2], b[3]]) as usize)
    }
    fn f64(&mut self) -> Result<f64, String> {
        let end = self
            .pos
            .checked_add(8)
            .ok_or("sasso: truncated custom-function result")?;
        let b = self
            .buf
            .get(self.pos..end)
            .ok_or("sasso: truncated custom-function result")?;
        self.pos = end;
        let mut a = [0u8; 8];
        a.copy_from_slice(b);
        Ok(f64::from_le_bytes(a))
    }
    fn opt_f64(&mut self) -> Result<Option<f64>, String> {
        if self.u8()? != 0 {
            Ok(Some(self.f64()?))
        } else {
            Ok(None)
        }
    }
    fn str(&mut self) -> Result<String, String> {
        let len = self.u32()?;
        let end = self
            .pos
            .checked_add(len)
            .ok_or("sasso: truncated custom-function result")?;
        let b = self
            .buf
            .get(self.pos..end)
            .ok_or("sasso: truncated custom-function result")?;
        self.pos = end;
        String::from_utf8(b.to_vec())
            .map_err(|_| "sasso: invalid UTF-8 in custom-function result".to_string())
    }
}

/// Deserialize a single value (the function's return) from the wire format.
pub(crate) fn deserialize_value(buf: &[u8]) -> Result<Value, String> {
    let mut r = Reader { buf, pos: 0 };
    let v = read_value(&mut r)?;
    Ok(v)
}

/// Deserialize the argument vector (the host side reading what `serialize_args`
/// produced): a `u32` count then that many values.
///
/// Host-side helper (see [`serialize_one`]): used by the in-crate tests now and
/// the FFI host-function bridge later; the wasm path decodes in JS.
#[allow(dead_code)]
pub(crate) fn deserialize_args(buf: &[u8]) -> Result<Vec<Value>, String> {
    let mut r = Reader { buf, pos: 0 };
    let n = r.u32()?;
    let mut args = Vec::with_capacity(n);
    for _ in 0..n {
        args.push(read_value(&mut r)?);
    }
    Ok(args)
}

fn read_value(r: &mut Reader<'_>) -> Result<Value, String> {
    let tag = r.u8()?;
    Ok(match tag {
        TAG_NULL => Value::Null,
        TAG_BOOL => Value::Bool(r.u8()? != 0),
        TAG_NUMBER => Value::Number(read_number_body(r)?),
        TAG_STRING => {
            let quoted = r.u8()? != 0;
            let text = r.str()?;
            Value::Str(SassStr {
                text: text.into(),
                quoted,
            })
        }
        TAG_LIST => {
            let sep = sep_from(r.u8()?)?;
            let bracketed = r.u8()? != 0;
            let n = r.u32()?;
            let mut items = Vec::with_capacity(n);
            for _ in 0..n {
                items.push(read_value(r)?);
            }
            let keywords = if r.u8()? != 0 {
                let kn = r.u32()?;
                let mut kw = Vec::with_capacity(kn);
                for _ in 0..kn {
                    let k = read_value(r)?;
                    let v = read_value(r)?;
                    kw.push((k, v));
                }
                Some(kw)
            } else {
                None
            };
            Value::List(List {
                items: items.into(),
                sep,
                bracketed,
                keywords,
            })
        }
        TAG_MAP => {
            let n = r.u32()?;
            let mut entries = Vec::with_capacity(n);
            for _ in 0..n {
                let k = read_value(r)?;
                let v = read_value(r)?;
                entries.push((k, v));
            }
            Value::Map(Map::new(entries))
        }
        TAG_COLOR => {
            let space_name = r.str()?;
            let space = ColorSpace::from_name(&space_name).ok_or_else(|| {
                format!("sasso: unknown color space \"{space_name}\" from a custom function")
            })?;
            let channels = [r.opt_f64()?, r.opt_f64()?, r.opt_f64()?];
            let alpha = r.opt_f64()?;
            if space == ColorSpace::Rgb {
                // The legacy sRGB space: reconstruct a plain legacy color so it
                // serializes via the legacy (hex / rgb()) path, like dart-sass.
                Value::Color(Color::rgb(
                    channels[0].unwrap_or(0.0),
                    channels[1].unwrap_or(0.0),
                    channels[2].unwrap_or(0.0),
                    alpha.unwrap_or(1.0),
                ))
            } else {
                let mc = ModernColor {
                    space,
                    channels,
                    alpha,
                };
                Value::Color(make_modern_in(mc, space))
            }
        }
        TAG_CALC => Value::Calc(read_calc_node(r)?),
        // Opaque handles: look the original Value back up in the per-dispatch table.
        TAG_FUNCTION | TAG_MIXIN => get_handle(r.u32()?)?,
        other => {
            return Err(format!(
                "sasso: unknown value tag {other} in custom-function result"
            ))
        }
    })
}

/// Read a number body written by [`write_number_body`].
fn read_number_body(r: &mut Reader<'_>) -> Result<Number, String> {
    let value = r.f64()?;
    let nn = r.u32()?;
    let mut numer: Vec<Rc<str>> = Vec::with_capacity(nn);
    for _ in 0..nn {
        numer.push(r.str()?.into());
    }
    let dn = r.u32()?;
    let mut denom: Vec<Rc<str>> = Vec::with_capacity(dn);
    for _ in 0..dn {
        denom.push(r.str()?.into());
    }
    Ok(Number::with_units(value, numer, denom))
}

fn calc_op_from(code: u8) -> Result<CalcOp, String> {
    Ok(match code {
        0 => CalcOp::Add,
        1 => CalcOp::Sub,
        2 => CalcOp::Mul,
        3 => CalcOp::Div,
        _ => return Err("sasso: bad calc operator in custom-function result".into()),
    })
}

/// Read a `CalcNode` tree written by [`write_calc_node`].
fn read_calc_node(r: &mut Reader<'_>) -> Result<CalcNode, String> {
    Ok(match r.u8()? {
        0 => CalcNode::Number(read_number_body(r)?),
        1 => CalcNode::Str(r.str()?),
        2 => {
            let op = calc_op_from(r.u8()?)?;
            let left = Box::new(read_calc_node(r)?);
            let right = Box::new(read_calc_node(r)?);
            CalcNode::Op { op, left, right }
        }
        3 => {
            let name = r.str()?;
            let n = r.u32()?;
            let mut args = Vec::with_capacity(n);
            for _ in 0..n {
                args.push(read_calc_node(r)?);
            }
            CalcNode::Func { name, args }
        }
        other => {
            return Err(format!(
                "sasso: bad calc node tag {other} in custom-function result"
            ))
        }
    })
}

#[cfg(test)]
mod tests {
    use crate::{compile, Options};
    use std::rc::Rc;

    use super::{deserialize_args, serialize_one};
    use crate::value::{ListSep, Number, SassStr, Value};

    fn opts_pow() -> Options<'static> {
        // pow($base, $exponent) -> number
        let cb: super::HostFunction = Rc::new(|bytes| {
            let args = deserialize_args(bytes)?;
            let base = match &args[0] {
                Value::Number(n) => n.value,
                _ => return Err("base must be a number".into()),
            };
            let exp = match &args[1] {
                Value::Number(n) => n.value,
                _ => return Err("exponent must be a number".into()),
            };
            serialize_one(&Value::Number(Number::unitless(base.powf(exp))))
        });
        Options::default().with_function("pow($base, $exponent)", cb)
    }

    #[test]
    fn custom_function_number() {
        let css = compile(".a { width: pow(2, 10) * 1px; }", &opts_pow()).unwrap();
        assert!(css.contains("width: 1024px"), "got: {css}");
    }

    #[test]
    fn custom_function_keyword_args() {
        let css = compile(".a { x: pow($exponent: 3, $base: 2); }", &opts_pow()).unwrap();
        assert!(css.contains("x: 8"), "got: {css}");
    }

    #[test]
    fn custom_function_overrides_builtin_but_not_user() {
        // A custom function shadows the builtin global of the same name...
        let cb: super::HostFunction = Rc::new(|_| {
            serialize_one(&Value::Str(SassStr {
                text: "custom".into(),
                quoted: false,
            }))
        });
        let o = Options::default().with_function("type-of($v)", cb);
        let css = compile(".a { x: type-of(1); }", &o).unwrap();
        assert!(css.contains("x: custom"), "custom should override builtin: {css}");
        // ...but a user @function still wins.
        let cb2: super::HostFunction = Rc::new(|_| {
            serialize_one(&Value::Str(SassStr {
                text: "custom".into(),
                quoted: false,
            }))
        });
        let o2 = Options::default().with_function("foo($v)", cb2);
        let css2 = compile("@function foo($v) { @return user; }\n.a { x: foo(1); }", &o2).unwrap();
        assert!(css2.contains("x: user"), "user @function should win: {css2}");
    }

    #[test]
    fn custom_function_string_list_map_roundtrip() {
        // Receive a MAP + a LIST, read into them, and return a quoted STRING —
        // exercising deserialization of all three on the way in.
        let cb: super::HostFunction = Rc::new(|bytes| {
            let args = deserialize_args(bytes)?;
            let map = match &args[0] {
                Value::Map(m) => m,
                _ => return Err("arg 1 must be a map".into()),
            };
            // map value for key `b`
            let b = map
                .get(&Value::Str(SassStr {
                    text: "b".into(),
                    quoted: false,
                }))
                .cloned()
                .unwrap_or(Value::Null);
            let bn = if let Value::Number(n) = b { n.value } else { -1.0 };
            let list = match &args[1] {
                Value::List(l) => l,
                _ => return Err("arg 2 must be a list".into()),
            };
            let count = list.items.len();
            serialize_one(&Value::Str(SassStr {
                text: format!("b={bn} n={count}").into(),
                quoted: true,
            }))
        });
        let o = Options::default().with_function("probe($m, $l)", cb);
        let css = compile(".a { x: probe((a: 1, b: 2), (x y z)); }", &o).unwrap();
        assert!(
            css.contains("\"b=2 n=3\""),
            "map+list deserialized, string round-trips: {css}"
        );
        let _ = ListSep::Comma;
    }

    #[test]
    fn custom_function_rest_args() {
        // sum($nums...) -> number
        let cb: super::HostFunction = Rc::new(|bytes| {
            let args = deserialize_args(bytes)?;
            let list = match &args[0] {
                Value::List(l) => l,
                _ => return Err("expected an arglist".into()),
            };
            let total: f64 = list
                .items
                .iter()
                .map(|v| if let Value::Number(n) = v { n.value } else { 0.0 })
                .sum();
            serialize_one(&Value::Number(Number::unitless(total)))
        });
        let o = Options::default().with_function("sum($nums...)", cb);
        let css = compile(".a { x: sum(1, 2, 3, 4); }", &o).unwrap();
        assert!(css.contains("x: 10"), "got: {css}");
    }

    #[test]
    fn custom_function_color_roundtrip() {
        use crate::value::{Color, ColorSpace, ModernColor};
        // ident($c) returns the color unchanged (forces a full serialize +
        // reconstruct cycle); a legacy color stays legacy and re-emits as hex.
        let ident: super::HostFunction = Rc::new(|bytes| {
            let args = deserialize_args(bytes)?;
            serialize_one(&args[0])
        });
        let o = Options::default().with_function("ident($c)", ident);
        let css = compile(".a { color: ident(#0080ff); }", &o).unwrap();
        assert!(css.contains("#0080ff"), "legacy color round-trips: {css}");

        // read a channel out of a received color
        let red: super::HostFunction = Rc::new(|bytes| {
            let args = deserialize_args(bytes)?;
            let c = match &args[0] {
                Value::Color(c) => c,
                _ => return Err("not a color".into()),
            };
            serialize_one(&Value::Number(Number::unitless(c.r)))
        });
        let o2 = Options::default().with_function("redof($c)", red);
        let css2 = compile(".a { x: redof(rgb(12, 0, 0)); }", &o2).unwrap();
        assert!(css2.contains("x: 12"), "channel read: {css2}");

        // return a MODERN color (oklch) built by the callback
        let mk: super::HostFunction = Rc::new(|_| {
            let mc = ModernColor {
                space: ColorSpace::Oklch,
                channels: [Some(0.5), Some(0.2), Some(180.0)],
                alpha: Some(1.0),
            };
            serialize_one(&Value::Color(super::make_modern_in(mc, ColorSpace::Oklch)))
        });
        let o3 = Options::default().with_function("mkcolor()", mk);
        let css3 = compile(".a { color: mkcolor(); }", &o3).unwrap();
        assert!(css3.contains("oklch("), "modern color round-trips: {css3}");
        let _ = Color::rgb(0.0, 0.0, 0.0, 1.0);
    }

    #[test]
    fn custom_function_error_surfaces() {
        let cb: super::HostFunction = Rc::new(|_| Err("boom".into()));
        let o = Options::default().with_function("bad($x)", cb);
        let err = compile(".a { x: bad(1); }", &o).unwrap_err();
        assert!(err.message.contains("boom"), "got: {}", err.message);
    }

    #[test]
    fn value_op_number_convert() {
        use super::{deserialize_value, host_value_op, serialize_args, OP_NUMBER_CONVERT};
        use crate::value::List;
        let strs = |u: &str| {
            Value::List(List::new(
                vec![Value::Str(SassStr {
                    text: u.into(),
                    quoted: false,
                })],
                ListSep::Space,
                false,
            ))
        };
        let empty = Value::List(List::new(Vec::<Value>::new(), ListSep::Space, false));
        // 96px -> in == 1in (convert)
        let args = vec![
            Value::Number(Number::with_unit(96.0, "px")),
            strs("in"),
            empty.clone(),
            Value::Bool(false),
        ];
        let out = host_value_op(OP_NUMBER_CONVERT, &serialize_args(&args).unwrap()).unwrap();
        match deserialize_value(&out).unwrap() {
            Value::Number(n) => assert!((n.value - 1.0).abs() < 1e-9, "got {}", n.value),
            v => panic!("expected number, got {v:?}"),
        }
        // incompatible (s -> px) errors
        let bad = vec![
            Value::Number(Number::with_unit(1.0, "s")),
            strs("px"),
            empty,
            Value::Bool(false),
        ];
        assert!(host_value_op(OP_NUMBER_CONVERT, &serialize_args(&bad).unwrap()).is_err());
    }
}
