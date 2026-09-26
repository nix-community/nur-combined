// A tiny, dependency-free subset of the `immutable` package's `List` and
// `OrderedMap` read API — the collection types dart-sass returns from `Value`
// accessors (`asList`, `channels`, `numeratorUnits`, `SassMap.contents`, …).
// Returning these (rather than plain arrays/Maps) lets a custom function written
// for dart-sass use `.get(i)` / `.size` / `.has(key)` / iteration unchanged.
//
// This is the COMMON read subset (+ a few non-mutating producers like map/
// filter/slice). For anything not covered, `.toArray()` / `.toJS()` convert to
// plain JS. Equality uses Sass value semantics via each element's `.equals`.

const UNSET = Symbol("unset");

/** `immutable.is` for our values: reference, or value-equality via `.equals`. */
export function immutableIs(a, b) {
  return a === b || (a != null && typeof a.equals === "function" && a.equals(b));
}

/** An immutable, ordered, indexed collection (subset of `immutable.List`). */
export class List {
  constructor(items = []) {
    this._a = Array.isArray(items) ? items.slice() : [...items];
  }
  get size() {
    return this._a.length;
  }
  get(index, notSetValue) {
    const n = index < 0 ? this._a.length + index : index;
    return n >= 0 && n < this._a.length ? this._a[n] : notSetValue;
  }
  has(index) {
    const n = index < 0 ? this._a.length + index : index;
    return n >= 0 && n < this._a.length;
  }
  first(notSetValue) {
    return this._a.length ? this._a[0] : notSetValue;
  }
  last(notSetValue) {
    return this._a.length ? this._a[this._a.length - 1] : notSetValue;
  }
  isEmpty() {
    return this._a.length === 0;
  }
  includes(value) {
    return this._a.some((x) => immutableIs(x, value));
  }
  indexOf(value) {
    return this._a.findIndex((x) => immutableIs(x, value));
  }
  toArray() {
    return this._a.slice();
  }
  toJS() {
    return this._a.slice();
  }
  map(fn) {
    return new List(this._a.map((v, i) => fn(v, i, this)));
  }
  filter(fn) {
    return new List(this._a.filter((v, i) => fn(v, i, this)));
  }
  forEach(fn) {
    this._a.forEach((v, i) => fn(v, i, this));
    return this._a.length;
  }
  reduce(fn, initial) {
    return arguments.length > 1
      ? this._a.reduce((acc, v, i) => fn(acc, v, i, this), initial)
      : this._a.reduce((acc, v, i) => fn(acc, v, i, this));
  }
  slice(begin, end) {
    return new List(this._a.slice(begin, end));
  }
  concat(...others) {
    return new List(this._a.concat(...others.map((o) => (o instanceof List ? o._a : o))));
  }
  push(...values) {
    return new List(this._a.concat(values));
  }
  equals(other) {
    return (
      other instanceof List &&
      other._a.length === this._a.length &&
      this._a.every((v, i) => immutableIs(v, other._a[i]))
    );
  }
  [Symbol.iterator]() {
    return this._a[Symbol.iterator]();
  }
  toString() {
    return `List [ ${this._a.join(", ")} ]`;
  }
}

/** An immutable, insertion-ordered, value-keyed map (subset of `immutable.OrderedMap`). */
export class OrderedMap {
  constructor(pairs = []) {
    // Accept [[k,v],...], a JS Map, or another OrderedMap.
    if (pairs instanceof OrderedMap) this._p = pairs._p.slice();
    else this._p = [...pairs].map(([k, v]) => [k, v]);
  }
  get size() {
    return this._p.length;
  }
  get(key, notSetValue) {
    const hit = this._p.find(([k]) => immutableIs(k, key));
    return hit ? hit[1] : notSetValue;
  }
  has(key) {
    return this._p.some(([k]) => immutableIs(k, key));
  }
  isEmpty() {
    return this._p.length === 0;
  }
  keys() {
    return this._p.map(([k]) => k)[Symbol.iterator]();
  }
  values() {
    return this._p.map(([, v]) => v)[Symbol.iterator]();
  }
  entries() {
    return this._p.map(([k, v]) => [k, v])[Symbol.iterator]();
  }
  toArray() {
    return this._p.map(([k, v]) => [k, v]);
  }
  toJS() {
    return this.toArray();
  }
  map(fn) {
    return new OrderedMap(this._p.map(([k, v]) => [k, fn(v, k, this)]));
  }
  forEach(fn) {
    this._p.forEach(([k, v]) => fn(v, k, this));
    return this._p.length;
  }
  equals(other) {
    return (
      other instanceof OrderedMap &&
      other._p.length === this._p.length &&
      this._p.every(([k, v]) => {
        const ov = other.get(k, UNSET);
        return ov !== UNSET && immutableIs(ov, v);
      })
    );
  }
  [Symbol.iterator]() {
    return this._p.map(([k, v]) => [k, v])[Symbol.iterator]();
  }
  toString() {
    return `OrderedMap { ${this._p.map(([k, v]) => `${k}: ${v}`).join(", ")} }`;
  }
}

export const list = (items) => new List(items);
export const orderedMap = (pairs) => new OrderedMap(pairs);
