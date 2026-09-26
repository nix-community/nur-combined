// The dart-sass `Value` type system for custom functions (the `functions`
// option), plus the wire (de)serializers that bridge it to sasso's engine.
//
// A custom function registered via `compileString(src, { functions: { ... } })`
// receives an array of `Value` objects and returns a `Value`. The engine speaks
// a compact byte protocol (see ../src/host_fn.rs); `deserializeArgs` decodes the
// engine's serialized arguments into `Value`s, and `serializeValue` encodes the
// function's returned `Value` back. The two encodings MUST stay in lockstep with
// the Rust `host_fn` (de)serializers.
//
// Collection accessors (`asList`, `channels`, `numeratorUnits`,
// `SassMap.contents`, …) return the immutable `List`/`OrderedMap` from
// `./_immutable.mjs`, matching dart-sass so a function written for `sass` runs
// unchanged.
//
// Supported types: SassNumber (with units), SassString, SassColor (every CSS
// Color 4 space), SassList / SassArgumentList, SassMap, SassBoolean
// (sassTrue/sassFalse) and sassNull. (calc() and first-class function/mixin refs
// are not yet representable — see ../../docs/CUSTOM_FUNCTIONS_COMPAT.md.)

import { List, OrderedMap, list, immutableIs } from "./_immutable.mjs";

const enc = new TextEncoder();
const dec = new TextDecoder();

// Engine-routed value operations: methods that need unit / color-space math
// (e.g. SassNumber.convert, SassColor.toSpace) call back into the wasm engine so
// the conversions reuse the exact Rust math. The loader injects `engine` (an
// independent value instance, so these work standalone and re-entrantly).
let engine = null;
/** Injected by the loader: `(op, argsBytes) => resultBytes` (throws on error). */
export function setEngine(fn) {
  engine = fn;
}
const OP_NUMBER_CONVERT = 1;
const OP_NUMBER_COMPATIBLE = 2;
const OP_COLOR_TO_SPACE = 3;
const OP_COLOR_IN_GAMUT = 4;
const OP_COLOR_TO_GAMUT = 5;
const OP_COLOR_POWERLESS = 6;
const OP_COLOR_INTERPOLATE = 7;

function runOp(op, args) {
  if (!engine) throw new Error("sasso: the value engine is not initialized (import the package first)");
  const w = new Writer();
  w.u32(args.length);
  for (const a of args) writeValue(w, a);
  return readValue(new Reader(engine(op, w.finish())));
}

/** A space-separated SassList of unquoted unit-name strings, for a convert op. */
function unitList(units) {
  return new SassList(toArray(units).map((u) => new SassString(String(u), { quotes: false })), { separator: " " });
}

// ---------------- value classes ----------------

/** Base class for every Sass value. dart-sass `Value`. */
export class Value {
  get isTruthy() {
    return true;
  }
  /** `null` for `sassNull`, else the value itself (dart-sass `realNull`). */
  get realNull() {
    return this;
  }
  /** This value as an immutable list (a scalar is a one-element list). */
  get asList() {
    return list([this]);
  }
  get hasBrackets() {
    return false;
  }
  get separator() {
    return null;
  }
  /** dart-sass `Value.get(index)` — 0-based, supports negative indexing. */
  get(index) {
    return this.asList.get(index);
  }
  /** Convert a 1-based Sass index (negatives count from the end) to 0-based. */
  sassIndexToListIndex(sassIndex, name) {
    const index = sassIndex.assertNumber(name).assertInt(name);
    if (index === 0) throw new Error(prefix(name) + "List index may not be 0.");
    const size = this.asList.size;
    if (Math.abs(index) > size) {
      throw new Error(prefix(name) + `Invalid index ${index} for a list with ${size} elements.`);
    }
    return index < 0 ? size + index : index - 1;
  }
  /** This value as a map if it is one (or the empty list `()`), else `null`. */
  tryMap() {
    return null;
  }
  assertNumber(name) {
    throw new Error(notA(this, name, "a number"));
  }
  assertString(name) {
    throw new Error(notA(this, name, "a string"));
  }
  assertColor(name) {
    throw new Error(notA(this, name, "a color"));
  }
  assertMap(name) {
    throw new Error(notA(this, name, "a map"));
  }
  assertBoolean(name) {
    throw new Error(notA(this, name, "a boolean"));
  }
  assertCalculation(name) {
    throw new Error(notA(this, name, "a calculation"));
  }
  assertFunction(name) {
    throw new Error(notA(this, name, "a function reference"));
  }
  assertMixin(name) {
    throw new Error(notA(this, name, "a mixin reference"));
  }
  equals(other) {
    return this === other;
  }
  hashCode() {
    return 0;
  }
}

function prefix(name) {
  return name ? `$${name}: ` : "";
}
function notA(value, name, expected) {
  return `${prefix(name)}${value} is not ${expected}.`;
}
function hashStr(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
  return h;
}

// dart-sass fuzzy numeric equality: equal when rounded to 1e-11 precision.
const INV_EPSILON = 1e11;
function fuzzyEquals(a, b) {
  return a === b || (Math.abs(a - b) <= 1e-11 && Math.round(a * INV_EPSILON) === Math.round(b * INV_EPSILON));
}
function fuzzyHashInt(v) {
  return Math.round(v * INV_EPSILON) | 0;
}

class SassNull extends Value {
  get isTruthy() {
    return false;
  }
  get realNull() {
    return null;
  }
  get asList() {
    return list([]);
  }
  hashCode() {
    return 0;
  }
  toString() {
    return "null";
  }
}
export const sassNull = new SassNull();

export class SassBoolean extends Value {
  constructor(value) {
    super();
    this.value = value;
  }
  get isTruthy() {
    return this.value;
  }
  assertBoolean() {
    return this;
  }
  equals(o) {
    return o instanceof SassBoolean && o.value === this.value;
  }
  hashCode() {
    return this.value ? 1 : 2;
  }
  toString() {
    return String(this.value);
  }
}
export const sassTrue = new SassBoolean(true);
export const sassFalse = new SassBoolean(false);

export class SassString extends Value {
  /** `new SassString("text", { quotes: true })`. */
  constructor(text = "", options = {}) {
    super();
    this.text = String(text);
    this.hasQuotes = options.quotes !== false;
  }
  static empty(options = {}) {
    return new SassString("", options);
  }
  get sassLength() {
    return [...this.text].length;
  }
  /** Convert a 1-based Sass string index (by code point) to a 0-based one. */
  sassIndexToStringIndex(sassIndex, name) {
    const index = sassIndex.assertNumber(name).assertInt(name);
    if (index === 0) throw new Error(prefix(name) + "String index may not be 0.");
    const len = this.sassLength;
    if (Math.abs(index) > len) {
      throw new Error(prefix(name) + `Invalid index ${index} for a string with ${len} characters.`);
    }
    return index < 0 ? len + index : index - 1;
  }
  assertString() {
    return this;
  }
  equals(o) {
    return o instanceof SassString && o.text === this.text;
  }
  hashCode() {
    return hashStr(this.text);
  }
  toString() {
    return this.hasQuotes ? JSON.stringify(this.text) : this.text;
  }
}

export class SassNumber extends Value {
  /**
   * `new SassNumber(8)`, `new SassNumber(8, "px")`, or
   * `new SassNumber(8, { numeratorUnits: ["px"], denominatorUnits: ["s"] })`.
   */
  constructor(value, unitOrOptions) {
    super();
    this.value = value;
    if (typeof unitOrOptions === "string") {
      this._numeratorUnits = [unitOrOptions];
      this._denominatorUnits = [];
    } else if (unitOrOptions) {
      this._numeratorUnits = toArray(unitOrOptions.numeratorUnits);
      this._denominatorUnits = toArray(unitOrOptions.denominatorUnits);
    } else {
      this._numeratorUnits = [];
      this._denominatorUnits = [];
    }
  }
  get numeratorUnits() {
    return list(this._numeratorUnits);
  }
  get denominatorUnits() {
    return list(this._denominatorUnits);
  }
  get hasUnits() {
    return this._numeratorUnits.length > 0 || this._denominatorUnits.length > 0;
  }
  get isInt() {
    return Number.isInteger(this.value) || Math.abs(this.value - Math.round(this.value)) < 1e-11;
  }
  get asInt() {
    return this.isInt ? Math.round(this.value) : null;
  }
  hasUnit(unit) {
    return this._denominatorUnits.length === 0 && this._numeratorUnits.length === 1 && this._numeratorUnits[0] === unit;
  }
  assertNumber() {
    return this;
  }
  assertInt(name) {
    const i = this.asInt;
    if (i === null) throw new Error(notA(this, name, "an int"));
    return i;
  }
  assertNoUnits(name) {
    if (this.hasUnits) throw new Error(prefix(name) + `Expected ${this} to have no units.`);
    return this;
  }
  assertUnit(unit, name) {
    if (!this.hasUnit(unit)) throw new Error(prefix(name) + `Expected ${this} to have unit "${unit}".`);
    return this;
  }
  assertInRange(min, max, name) {
    if (this.value < min - 1e-11 || this.value > max + 1e-11) {
      throw new Error(prefix(name) + `Expected ${this} to be within ${min} and ${max}.`);
    }
    return this.value < min ? min : this.value > max ? max : this.value;
  }
  // --- unit conversion (routed to the engine's Rust math) ---
  compatibleWithUnit(unit) {
    return runOp(OP_NUMBER_COMPATIBLE, [this, new SassString(unit, { quotes: false })]).value;
  }
  convert(newNumerators, newDenominators, name) {
    const r = runOp(OP_NUMBER_CONVERT, [this, unitList(newNumerators), unitList(newDenominators), sassFalse]);
    if (name && r instanceof SassNumber === false) throw new Error(prefix(name) + "conversion failed");
    return r;
  }
  coerce(newNumerators, newDenominators) {
    return runOp(OP_NUMBER_CONVERT, [this, unitList(newNumerators), unitList(newDenominators), sassTrue]);
  }
  convertToMatch(other) {
    return this.convert(other.numeratorUnits.toArray(), other.denominatorUnits.toArray());
  }
  coerceToMatch(other) {
    return this.coerce(other.numeratorUnits.toArray(), other.denominatorUnits.toArray());
  }
  convertValue(newNumerators, newDenominators) {
    return this.convert(newNumerators, newDenominators).value;
  }
  convertValueToMatch(other) {
    return this.convertToMatch(other).value;
  }
  coerceValue(newNumerators, newDenominators) {
    return this.coerce(newNumerators, newDenominators).value;
  }
  coerceValueToMatch(other) {
    return this.coerceToMatch(other).value;
  }
  equals(o) {
    if (!(o instanceof SassNumber)) return false;
    // Same units: a plain fuzzy value comparison.
    if (sameUnits(o._numeratorUnits, this._numeratorUnits) && sameUnits(o._denominatorUnits, this._denominatorUnits)) {
      return fuzzyEquals(this.value, o.value);
    }
    // Different units: a unitless operand is never equal to a united one;
    // otherwise convert through the engine (incompatible units → not equal).
    if (!this.hasUnits || !o.hasUnits) return false;
    try {
      return fuzzyEquals(this.value, o.convertValueToMatch(this));
    } catch {
      return false;
    }
  }
  hashCode() {
    // Equal numbers must hash equal (1in == 96px). Unitless values hash by
    // value; united values that compare equal across different units can't share
    // a raw-value hash, so they share one bucket (collision-safe — our maps key
    // by `equals`, and a cross-impl hash integer never matches dart anyway).
    return this.hasUnits ? 0x7fffffff : fuzzyHashInt(this.value);
  }
  toString() {
    return this.value + this._numeratorUnits.join("*");
  }
}

function toArray(x) {
  if (!x) return [];
  return Array.isArray(x) ? x.slice() : typeof x.toArray === "function" ? x.toArray() : [...x];
}
function sameUnits(a, b) {
  return a.length === b.length && a.every((u, i) => u === b[i]);
}

// CSS Color 4 channel names per space (positional order matches the engine).
const COLOR_CHANNELS = {
  rgb: ["red", "green", "blue"],
  srgb: ["red", "green", "blue"],
  "srgb-linear": ["red", "green", "blue"],
  "display-p3": ["red", "green", "blue"],
  "display-p3-linear": ["red", "green", "blue"],
  "a98-rgb": ["red", "green", "blue"],
  "prophoto-rgb": ["red", "green", "blue"],
  rec2020: ["red", "green", "blue"],
  hsl: ["hue", "saturation", "lightness"],
  hwb: ["hue", "whiteness", "blackness"],
  lab: ["lightness", "a", "b"],
  oklab: ["lightness", "a", "b"],
  lch: ["lightness", "chroma", "hue"],
  oklch: ["lightness", "chroma", "hue"],
  xyz: ["x", "y", "z"],
  "xyz-d50": ["x", "y", "z"],
  "xyz-d65": ["x", "y", "z"],
};
const LEGACY_SPACES = new Set(["rgb", "hsl", "hwb"]);

export class SassColor extends Value {
  /**
   * `new SassColor({ space: "oklch", lightness, chroma, hue, alpha })`, or legacy
   * `new SassColor({ red, green, blue, alpha })` (space defaults to `"rgb"`). A
   * channel may be `null` for a missing channel.
   */
  constructor(options = {}) {
    super();
    const space = options.space ?? "rgb";
    const names = COLOR_CHANNELS[space];
    if (!names) throw new Error(`sasso: unknown color space "${space}"`);
    this.space = space;
    this._channels = names.map((n) => (options[n] === undefined ? null : options[n]));
    this.alpha = options.alpha === undefined ? 1 : options.alpha;
  }
  get isLegacy() {
    return LEGACY_SPACES.has(this.space);
  }
  get channelsOrNull() {
    return list(this._channels);
  }
  get channels() {
    return list(this._channels.map((c) => c ?? 0));
  }
  /** `channel(name)` reads the current space; `channel(name, {space})` converts first. */
  channel(name, options) {
    if (options && options.space && options.space !== this.space) {
      return this.toSpace(options.space).channel(name);
    }
    const i = (COLOR_CHANNELS[this.space] || []).indexOf(name);
    if (i < 0) throw new Error(`sasso: color space "${this.space}" has no channel "${name}"`);
    return this._channels[i] ?? 0;
  }
  isChannelMissing(name) {
    const i = (COLOR_CHANNELS[this.space] || []).indexOf(name);
    return i >= 0 && this._channels[i] === null;
  }
  // --- space conversion (routed to the engine's CSS Color 4 math) ---
  toSpace(space) {
    return space === this.space ? this : runOp(OP_COLOR_TO_SPACE, [this, new SassString(space, { quotes: false })]);
  }
  isInGamut(space) {
    return runOp(OP_COLOR_IN_GAMUT, [this, new SassString(space ?? this.space, { quotes: false })]).value;
  }
  toGamut(options = {}) {
    return runOp(OP_COLOR_TO_GAMUT, [
      this,
      new SassString(options.space ?? this.space, { quotes: false }),
      new SassString(options.method ?? "local-minde", { quotes: false }),
    ]);
  }
  isChannelPowerless(name, options) {
    return runOp(OP_COLOR_POWERLESS, [
      this,
      new SassString(name, { quotes: false }),
      new SassString((options && options.space) || this.space, { quotes: false }),
    ]).value;
  }
  interpolate(color2, options = {}) {
    const weight = options.weight === undefined ? 0.5 : options.weight;
    return runOp(OP_COLOR_INTERPOLATE, [
      this,
      color2,
      new SassNumber(weight * 100, "%"),
      new SassString(options.method ?? "oklab", { quotes: false }),
    ]);
  }
  /** Return a copy with the named channels (and/or alpha/space) replaced. */
  change(options = {}) {
    const space = options.space ?? this.space;
    const base = space === this.space ? this : this.toSpace(space);
    const names = COLOR_CHANNELS[space];
    const opts = { space, alpha: options.alpha !== undefined ? options.alpha : base.alpha };
    names.forEach((n, i) => {
      opts[n] = n in options ? options[n] : base._channels[i];
    });
    return new SassColor(opts);
  }
  _legacyChannel(space, name) {
    return (this.space === space ? this : this.toSpace(space)).channel(name);
  }
  // Legacy accessors: convert to the relevant legacy space, then read.
  get red() {
    return this._legacyChannel("rgb", "red");
  }
  get green() {
    return this._legacyChannel("rgb", "green");
  }
  get blue() {
    return this._legacyChannel("rgb", "blue");
  }
  get hue() {
    return this._legacyChannel("hsl", "hue");
  }
  get saturation() {
    return this._legacyChannel("hsl", "saturation");
  }
  get lightness() {
    return this._legacyChannel("hsl", "lightness");
  }
  get whiteness() {
    return this._legacyChannel("hwb", "whiteness");
  }
  get blackness() {
    return this._legacyChannel("hwb", "blackness");
  }
  assertColor() {
    return this;
  }
  equals(o) {
    return (
      o instanceof SassColor &&
      o.space === this.space &&
      o.alpha === this.alpha &&
      sameUnits(o._channels.map(String), this._channels.map(String))
    );
  }
  hashCode() {
    return hashStr(this.space) ^ ((this.alpha * 1000) | 0);
  }
  toString() {
    return `${this.space}(${this._channels.join(" ")} / ${this.alpha})`;
  }
}

const SEP_TO_STR = [" ", ",", "/", null];
const STR_TO_SEP = { " ": 0, ",": 1, "/": 2 };

export class SassList extends Value {
  /** `new SassList([...], { separator: ",", brackets: false })`. */
  constructor(contents = [], options = {}) {
    super();
    this._contents = toArray(contents);
    this._separator = options.separator === undefined ? "," : options.separator;
    this._brackets = !!options.brackets;
  }
  get asList() {
    return list(this._contents);
  }
  get separator() {
    return this._separator;
  }
  get hasBrackets() {
    return this._brackets;
  }
  tryMap() {
    return this._contents.length === 0 ? new SassMap() : null;
  }
  assertMap(name) {
    if (this._contents.length === 0) return new SassMap();
    throw new Error(notA(this, name, "a map"));
  }
  equals(o) {
    return (
      o instanceof SassList &&
      o._separator === this._separator &&
      o._brackets === this._brackets &&
      o._contents.length === this._contents.length &&
      o._contents.every((v, i) => immutableIs(v, this._contents[i]))
    );
  }
  hashCode() {
    return this._contents.reduce((h, v) => (Math.imul(31, h) + (v.hashCode?.() ?? 0)) | 0, 7);
  }
  toString() {
    return this._contents.map(String).join(this._separator === " " ? " " : `${this._separator} `);
  }
}

/** A `$rest...` argument list: a list that also carries trailing keywords. */
export class SassArgumentList extends SassList {
  constructor(contents = [], keywords = new Map(), options = {}) {
    super(contents, options);
    this.keywords = keywords; // Map<string, Value>
  }
}

export class SassMap extends Value {
  /** `new SassMap(new Map([[key, value], ...]))` — keys are `Value`s. */
  constructor(contents = new Map()) {
    super();
    // Store as pairs for Sass value-equality lookups.
    if (contents instanceof OrderedMap) this._pairs = contents.toArray();
    else this._pairs = [...contents].map(([k, v]) => [k, v]);
  }
  static empty() {
    return new SassMap();
  }
  /** The map's contents as an immutable, value-keyed `OrderedMap`. */
  get contents() {
    return new OrderedMap(this._pairs);
  }
  get asList() {
    return list(this._pairs.map(([k, v]) => new SassList([k, v], { separator: " " })));
  }
  get separator() {
    return ",";
  }
  tryMap() {
    return this;
  }
  assertMap() {
    return this;
  }
  equals(o) {
    return (
      o instanceof SassMap &&
      o._pairs.length === this._pairs.length &&
      this._pairs.every(([k, v]) => {
        const ov = o.contents.get(k);
        return ov !== undefined && immutableIs(ov, v);
      })
    );
  }
  hashCode() {
    return this._pairs.reduce((h, [k, v]) => (h + ((k.hashCode?.() ?? 0) ^ (v.hashCode?.() ?? 0))) | 0, 11);
  }
  toString() {
    return `(${this._pairs.map(([k, v]) => `${k}: ${v}`).join(", ")})`;
  }
}

/** A binary operation inside a calculation (dart-sass `CalculationOperation`). */
export class CalculationOperation {
  constructor(operator, left, right) {
    this.operator = operator; // "+" | "-" | "*" | "/"
    this.left = left;
    this.right = right;
  }
  equals(o) {
    return (
      o instanceof CalculationOperation &&
      o.operator === this.operator &&
      immutableIs(o.left, this.left) &&
      immutableIs(o.right, this.right)
    );
  }
  toString() {
    return `${this.left} ${this.operator} ${this.right}`;
  }
}

/** A `calc()` / `min()` / `max()` / `clamp()` calculation (dart-sass `SassCalculation`). */
export class SassCalculation extends Value {
  /** Prefer the `calc`/`min`/`max`/`clamp` static constructors. */
  constructor(name, args) {
    super();
    this.name = name;
    this._args = [...args];
  }
  static calc(argument) {
    return new SassCalculation("calc", [argument]);
  }
  static min(args) {
    return new SassCalculation("min", toArray(args));
  }
  static max(args) {
    return new SassCalculation("max", toArray(args));
  }
  static clamp(min, value, max) {
    const args = [min];
    if (value !== undefined) args.push(value);
    if (max !== undefined) args.push(max);
    return new SassCalculation("clamp", args);
  }
  get arguments() {
    return list(this._args);
  }
  assertCalculation() {
    return this;
  }
  equals(o) {
    return (
      o instanceof SassCalculation &&
      o.name === this.name &&
      o._args.length === this._args.length &&
      o._args.every((v, i) => immutableIs(v, this._args[i]))
    );
  }
  hashCode() {
    return hashStr(this.name);
  }
  toString() {
    return `${this.name}(${this._args.join(", ")})`;
  }
}

/**
 * An opaque first-class function reference (dart-sass `SassFunction`). It can't
 * be invoked from JS — only received from, and passed back to, the engine (which
 * resolves it via the handle); it round-trips by an engine-side handle id.
 */
export class SassFunction extends Value {
  constructor(id) {
    super();
    this.__handle = id;
  }
  assertFunction() {
    return this;
  }
  equals(o) {
    return o instanceof SassFunction && o.__handle === this.__handle;
  }
  toString() {
    return "get-function(...)";
  }
}

/** An opaque first-class mixin reference (dart-sass `SassMixin`). */
export class SassMixin extends Value {
  constructor(id) {
    super();
    this.__handle = id;
  }
  assertMixin() {
    return this;
  }
  equals(o) {
    return o instanceof SassMixin && o.__handle === this.__handle;
  }
  toString() {
    return "get-mixin(...)";
  }
}

// ---------------- wire (de)serialization (mirrors ../src/host_fn.rs) ----------------

const TAG = { NULL: 0, BOOL: 1, NUMBER: 2, STRING: 3, LIST: 4, MAP: 5, COLOR: 6, CALC: 7, FUNCTION: 8, MIXIN: 9 };
const CALC_OP_CODE = { "+": 0, "-": 1, "*": 2, "/": 3 };
const CALC_OP_SYM = ["+", "-", "*", "/"];

function writeNumberBody(w, n) {
  w.f64(n.value);
  w.u32(n._numeratorUnits.length);
  for (const u of n._numeratorUnits) w.str(u);
  w.u32(n._denominatorUnits.length);
  for (const u of n._denominatorUnits) w.str(u);
}
function readNumberBody(r) {
  const value = r.f64();
  const numeratorUnits = [];
  for (let n = r.u32(); n > 0; n--) numeratorUnits.push(r.str());
  const denominatorUnits = [];
  for (let n = r.u32(); n > 0; n--) denominatorUnits.push(r.str());
  return new SassNumber(value, { numeratorUnits, denominatorUnits });
}

// A calc node (a `CalculationValue`): tag 0 number, 1 string, 2 operation, 3 calc.
function writeCalcNode(w, v) {
  if (v instanceof SassNumber) {
    w.u8(0);
    writeNumberBody(w, v);
  } else if (typeof v === "string") {
    w.u8(1);
    w.str(v);
  } else if (v instanceof SassString) {
    w.u8(1);
    w.str(v.text);
  } else if (v instanceof CalculationOperation) {
    w.u8(2);
    w.u8(CALC_OP_CODE[v.operator]);
    writeCalcNode(w, v.left);
    writeCalcNode(w, v.right);
  } else if (v instanceof SassCalculation) {
    w.u8(3);
    w.str(v.name);
    w.u32(v._args.length);
    for (const a of v._args) writeCalcNode(w, a);
  } else {
    throw new Error(`sasso: a calculation contains a value it can't represent (${v})`);
  }
}
function readCalcNode(r) {
  const t = r.u8();
  if (t === 0) return readNumberBody(r);
  if (t === 1) return new SassString(r.str(), { quotes: false });
  if (t === 2) {
    const op = CALC_OP_SYM[r.u8()];
    const left = readCalcNode(r);
    const right = readCalcNode(r);
    return new CalculationOperation(op, left, right);
  }
  if (t === 3) {
    const name = r.str();
    const args = [];
    for (let n = r.u32(); n > 0; n--) args.push(readCalcNode(r));
    return new SassCalculation(name, args);
  }
  throw new Error(`sasso: bad calc node tag ${t} from the engine`);
}

class Writer {
  constructor() {
    this.bytes = [];
  }
  u8(n) {
    this.bytes.push(n & 0xff);
  }
  u32(n) {
    this.bytes.push(n & 0xff, (n >>> 8) & 0xff, (n >>> 16) & 0xff, (n >>> 24) & 0xff);
  }
  f64(n) {
    const b = new Uint8Array(8);
    new DataView(b.buffer).setFloat64(0, n, true);
    for (const x of b) this.bytes.push(x);
  }
  str(s) {
    const b = enc.encode(s);
    this.u32(b.length);
    for (const x of b) this.bytes.push(x);
  }
  optF64(v) {
    if (v === null || v === undefined) {
      this.u8(0);
    } else {
      this.u8(1);
      this.f64(v);
    }
  }
  finish() {
    return new Uint8Array(this.bytes);
  }
}

function writeValue(w, v) {
  if (v === null || v === undefined || v instanceof SassNull) {
    w.u8(TAG.NULL);
  } else if (v instanceof SassBoolean) {
    w.u8(TAG.BOOL);
    w.u8(v.value ? 1 : 0);
  } else if (v instanceof SassNumber) {
    w.u8(TAG.NUMBER);
    writeNumberBody(w, v);
  } else if (v instanceof SassCalculation) {
    w.u8(TAG.CALC);
    // Unwrap a single-argument `calc(...)`; otherwise emit the calc as a func node.
    if (v.name === "calc" && v._args.length === 1) writeCalcNode(w, v._args[0]);
    else writeCalcNode(w, v);
  } else if (v instanceof SassString) {
    w.u8(TAG.STRING);
    w.u8(v.hasQuotes ? 1 : 0);
    w.str(v.text);
  } else if (v instanceof SassColor) {
    w.u8(TAG.COLOR);
    w.str(v.space);
    for (const c of v._channels) w.optF64(c);
    w.optF64(v.alpha);
  } else if (v instanceof SassList) {
    w.u8(TAG.LIST);
    w.u8(v._separator === null ? 3 : (STR_TO_SEP[v._separator] ?? 1));
    w.u8(v._brackets ? 1 : 0);
    w.u32(v._contents.length);
    for (const it of v._contents) writeValue(w, it);
    const kw = v instanceof SassArgumentList ? v.keywords : null;
    if (kw && kw.size) {
      w.u8(1);
      w.u32(kw.size);
      for (const [k, val] of kw) {
        writeValue(w, new SassString(k, { quotes: false }));
        writeValue(w, val);
      }
    } else {
      w.u8(0);
    }
  } else if (v instanceof SassMap) {
    w.u8(TAG.MAP);
    w.u32(v._pairs.length);
    for (const [k, val] of v._pairs) {
      writeValue(w, k);
      writeValue(w, val);
    }
  } else if (v instanceof SassFunction) {
    w.u8(TAG.FUNCTION);
    w.u32(v.__handle);
  } else if (v instanceof SassMixin) {
    w.u8(TAG.MIXIN);
    w.u32(v.__handle);
  } else {
    throw new Error(`sasso: a custom function returned a value sasso can't represent (${v})`);
  }
}

/** Serialize a single returned `Value` to the engine's wire format. */
export function serializeValue(v) {
  const w = new Writer();
  writeValue(w, v);
  return w.finish();
}

class Reader {
  constructor(buf) {
    this.view = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
    this.bytes = buf;
    this.pos = 0;
  }
  u8() {
    return this.bytes[this.pos++];
  }
  u32() {
    const n = this.view.getUint32(this.pos, true);
    this.pos += 4;
    return n;
  }
  f64() {
    const n = this.view.getFloat64(this.pos, true);
    this.pos += 8;
    return n;
  }
  str() {
    const len = this.u32();
    const s = dec.decode(this.bytes.subarray(this.pos, this.pos + len));
    this.pos += len;
    return s;
  }
  optF64() {
    return this.u8() ? this.f64() : null;
  }
}

function readValue(r) {
  const tag = r.u8();
  switch (tag) {
    case TAG.NULL:
      return sassNull;
    case TAG.BOOL:
      return r.u8() ? sassTrue : sassFalse;
    case TAG.NUMBER:
      return readNumberBody(r);
    case TAG.CALC: {
      const top = readCalcNode(r);
      // A bare operand/operation is the single argument of an implicit `calc()`.
      return top instanceof SassCalculation ? top : new SassCalculation("calc", [top]);
    }
    case TAG.STRING: {
      const quotes = r.u8() !== 0;
      return new SassString(r.str(), { quotes });
    }
    case TAG.COLOR: {
      const space = r.str();
      const names = COLOR_CHANNELS[space] || ["c0", "c1", "c2"];
      const opts = { space };
      for (let i = 0; i < 3; i++) opts[names[i]] = r.optF64();
      opts.alpha = r.optF64();
      return new SassColor(opts);
    }
    case TAG.LIST: {
      const sep = SEP_TO_STR[r.u8()];
      const brackets = r.u8() !== 0;
      const n = r.u32();
      const items = [];
      for (let i = 0; i < n; i++) items.push(readValue(r));
      let keywords = null;
      if (r.u8() !== 0) {
        keywords = new Map();
        for (let k = r.u32(); k > 0; k--) {
          const key = readValue(r);
          const val = readValue(r);
          keywords.set(key instanceof SassString ? key.text : String(key), val);
        }
      }
      const options = { separator: sep, brackets };
      return keywords ? new SassArgumentList(items, keywords, options) : new SassList(items, options);
    }
    case TAG.MAP: {
      const n = r.u32();
      const m = new Map();
      for (let i = 0; i < n; i++) {
        const k = readValue(r);
        const v = readValue(r);
        m.set(k, v);
      }
      return new SassMap(m);
    }
    case TAG.FUNCTION:
      return new SassFunction(r.u32());
    case TAG.MIXIN:
      return new SassMixin(r.u32());
    default:
      throw new Error(`sasso: unknown value tag ${tag} from the engine`);
  }
}

/** Decode the engine's serialized argument list (`u32` count + values). */
export function deserializeArgs(buf) {
  const r = new Reader(buf);
  const n = r.u32();
  const args = [];
  for (let i = 0; i < n; i++) args.push(readValue(r));
  return args;
}

/** The public `Value` API, for re-export on the package's named + default exports. */
export const valueApi = {
  Value,
  SassBoolean,
  SassColor,
  SassList,
  SassArgumentList,
  SassMap,
  SassNumber,
  SassString,
  SassCalculation,
  CalculationOperation,
  SassFunction,
  SassMixin,
  sassTrue,
  sassFalse,
  sassNull,
  List,
  OrderedMap,
};
