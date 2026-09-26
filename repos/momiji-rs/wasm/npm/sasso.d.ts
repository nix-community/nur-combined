// sasso — types for the dart-sass *modern* JS API (drop-in for `sass`).

export type OutputStyle = "expanded" | "compressed";

export interface Options {
  /** Output style. Defaults to `"expanded"`. */
  style?: OutputStyle;
  /** Also produce a Source Map v3 (populates {@link CompileResult.sourceMap}). */
  sourceMap?: boolean;
  /** Embed each source's full text in the map's `sourcesContent`. Requires `sourceMap`. */
  sourceMapIncludeSources?: boolean;
  /** Filesystem directories searched (in order) when resolving `@use`/`@import`. */
  loadPaths?: string[];
  /** Custom importers, tried (in order) before the filesystem. **Synchronous only.** */
  importers?: (Importer | FileImporter)[];
  /**
   * Host-defined Sass functions, keyed by signature (`"pow($base, $exponent)"`).
   * Each callback receives the bound {@link Value} arguments and returns a
   * {@link Value}. They override built-in global functions but lose to user
   * `@function`s. A callback may be async, but only under the async compile APIs
   * (`compileStringAsync`/`compileAsync`); the sync APIs throw on a Promise.
   */
  functions?: Record<string, CustomFunction>;
  /**
   * Don't report deprecation warnings raised inside dependencies: stylesheets
   * reached through {@link loadPaths} or a custom importer, and whatever those
   * load relatively. A dependency's own `@warn`/`@debug` still reaches the
   * logger, as in dart-sass.
   */
  quietDeps?: boolean;
  /**
   * Deprecation ids whose warnings are dropped, as dart-sass's
   * `silenceDeprecations` — `["import", "global-builtin"]`. Silencing happens
   * inside the compiler, beside {@link quietDeps}, so a silenced id is not
   * counted towards the "N repetitive deprecation warnings omitted" footer
   * either; filtering in a {@link logger} instead leaves that footer behind.
   *
   * Ids sasso never emits are accepted and do nothing, so a build written for
   * `sass` does not fail here for naming one. An id dart-sass does not know at
   * all warns — `Invalid deprecation "nope".`, through this {@link logger} if
   * there is one, else to stderr — and the compile proceeds, which is what
   * dart's JS API does; only its command line rejects the id outright.
   */
  silenceDeprecations?: string[];
  /**
   * Render diagnostics with the Unicode box glyphs (`╷`/`│`/`╵`), default
   * `true`; `false` selects the ASCII set, like the CLI's `--no-unicode`. A
   * sasso extension — dart-sass exposes it on its command line only.
   */
  unicode?: boolean;
  /**
   * Diagnostic handler for `@warn` / `@debug` / deprecation warnings. When
   * omitted, they print to stderr. Pass {@link Logger.silent} to discard them.
   */
  logger?: Logger;
}

/** A host-defined Sass function. */
export type CustomFunction = (args: Value[]) => Value | Promise<Value>;

/** A diagnostic handler (dart-sass `Logger`). */
export interface Logger {
  warn?(message: string, options: { deprecation: boolean; deprecationType?: string; span?: SourceSpan; stack?: string }): void;
  debug?(message: string, options: { span?: SourceSpan }): void;
}

/** dart-sass `Logger` namespace. */
export const Logger: {
  /** A logger that discards every warning and debug message. */
  silent: Logger;
};

/** A (partial) source span attached to a diagnostic. */
export interface SourceSpan {
  url?: string;
  start: { line: number; column: number };
  end: { line: number; column: number };
  text: string;
  context: string;
}

export interface StringOptions extends Options {
  /**
   * The canonical URL of `source`. Included in {@link CompileResult.loadedUrls}
   * and used as the base for the source's relative imports. Accepts a `file:`
   * (or other-scheme) URL, as a string or `URL`.
   */
  url?: string | URL;
  /** The syntax of `source`. Defaults to `"scss"`. */
  syntax?: "scss" | "indented" | "css";
}

/** Context passed to importer callbacks (dart-sass `CanonicalizeContext`). */
export interface CanonicalizeContext {
  /** `true` for `@import` (which also considers `*.import` files), else `false`. */
  fromImport: boolean;
  /** The canonical URL of the stylesheet containing the rule, if any. */
  containingUrl: URL | undefined;
}

/** What an {@link Importer.load} returns for a canonical URL. */
export interface ImporterResult {
  contents: string;
  /** Defaults to `"scss"`. */
  syntax?: "scss" | "indented" | "css";
  sourceMapUrl?: URL | string;
}

/**
 * A dart-sass *modern* importer. The callbacks may return a value or a
 * `Promise` — but the **synchronous** APIs (`compileString`/`compile`) require
 * the synchronous form (a `Promise` throws there); the **async** APIs
 * (`compileStringAsync`/`compileAsync`/the Compiler API) accept either.
 */
export interface Importer {
  canonicalize(url: string, context: CanonicalizeContext): URL | string | null | Promise<URL | string | null>;
  load(canonicalUrl: URL): ImporterResult | null | Promise<ImporterResult | null>;
}

/**
 * A dart-sass *modern* FileImporter (resolved on disk). Like {@link Importer},
 * `findFileUrl` may be async — but only under the async compile APIs.
 */
export interface FileImporter {
  findFileUrl(url: string, context: CanonicalizeContext): URL | string | null | Promise<URL | string | null>;
}

/** A Source Map v3 (the parsed JSON object). */
export interface RawSourceMap {
  version: 3;
  file?: string;
  sources: string[];
  sourcesContent?: string[];
  names: string[];
  mappings: string;
}

/** The dart-sass `CompileResult` returned by every `compile*` entry point. */
export interface CompileResult {
  css: string;
  /** Canonical URLs of all loaded stylesheets (the entry plus every import). */
  loadedUrls: URL[];
  /** Present only when `options.sourceMap` is `true`. */
  sourceMap?: RawSourceMap;
}

export interface ConfigureOptions {
  /**
   * Bump-arena reservation in MiB (default 32). `0` disables the arena, so
   * every allocation forwards to the system allocator — a lower memory
   * footprint at a lower throughput. Must be set before the first compile.
   */
  arenaMiB?: number;
  /**
   * Maximum number of asyncify engine instances the async APIs
   * (`compileStringAsync`, `compileAsync`) may run concurrently (default:
   * `min(4, cpu cores)`). The pool grows lazily — a process that never
   * overlaps async compiles only ever pays for one instance. Each instance
   * reserves its own wasm memory (incl. the arena) plus a 1 MiB asyncify
   * stack. Lowering the cap drops surplus instances as they become idle.
   */
  asyncInstances?: number;
}

/**
 * A Sass compilation error. Approximates the dart-sass `Exception`: an `Error`
 * subclass with `name === "Exception"` and a `sassMessage` (the message without
 * the leading `Error: `).
 */
export class Exception extends Error {
  readonly name: "Exception";
  /** The raw error message (no `Error:` header or source snippet). */
  readonly sassMessage: string;
  /** The source span of the error, when a position is known. */
  readonly span?: SourceSpan;
}

/** dart-sass-style implementation string: `"sasso\t<version>"`. */
export const info: string;

/** Compile an SCSS source string. dart-sass `compileString`. */
export function compileString(source: string, options?: StringOptions): CompileResult;

/** Async `compileString` — resolves the synchronous result. */
export function compileStringAsync(source: string, options?: StringOptions): Promise<CompileResult>;

/**
 * Compile an SCSS file by path. dart-sass `compile` — **Node only** (reads the
 * file from disk). For an in-memory string, use {@link compileString}.
 */
export function compile(path: string | URL, options?: Options): CompileResult;

/** Async `compile` — resolves the synchronous result. */
export function compileAsync(path: string | URL, options?: Options): Promise<CompileResult>;

/** A reusable synchronous compiler (dart-sass Compiler API). */
export interface Compiler {
  compile(path: string | URL, options?: Options): CompileResult;
  compileString(source: string, options?: StringOptions): CompileResult;
  dispose(): void;
}

/** A reusable async compiler (dart-sass AsyncCompiler API; used by Vite). */
export interface AsyncCompiler {
  compileAsync(path: string | URL, options?: Options): Promise<CompileResult>;
  compileStringAsync(source: string, options?: StringOptions): Promise<CompileResult>;
  dispose(): Promise<void>;
}

/** Create a reusable synchronous compiler. dart-sass `initCompiler`. */
export function initCompiler(): Compiler;

/** Create a reusable async compiler. dart-sass `initAsyncCompiler` (Vite calls this). */
export function initAsyncCompiler(): Promise<AsyncCompiler>;

/**
 * Configure the bump-arena allocator. MUST be called before the first compile —
 * the arena region is reserved on first use and then fixed.
 */
export function configure(options?: ConfigureOptions): void;

// ----- the dart-sass `Value` type system (custom-function arguments/returns) -----

export type ColorSpace =
  | "rgb" | "srgb" | "srgb-linear" | "display-p3" | "a98-rgb" | "prophoto-rgb"
  | "rec2020" | "hsl" | "hwb" | "lab" | "oklab" | "lch" | "oklch"
  | "xyz" | "xyz-d50" | "xyz-d65";

/** Immutable, indexed collection returned by `Value` accessors (subset of `immutable.List`). */
export interface List<T> extends Iterable<T> {
  readonly size: number;
  get(index: number, notSetValue?: T): T | undefined;
  has(index: number): boolean;
  first(notSetValue?: T): T | undefined;
  last(notSetValue?: T): T | undefined;
  isEmpty(): boolean;
  includes(value: T): boolean;
  indexOf(value: T): number;
  toArray(): T[];
  toJS(): T[];
  map<U>(fn: (value: T, index: number, list: List<T>) => U): List<U>;
  filter(fn: (value: T, index: number, list: List<T>) => boolean): List<T>;
  forEach(fn: (value: T, index: number, list: List<T>) => void): number;
  reduce<U>(fn: (acc: U, value: T, index: number, list: List<T>) => U, initial?: U): U;
  slice(begin?: number, end?: number): List<T>;
  equals(other: unknown): boolean;
}

/** Immutable, insertion-ordered, value-keyed map (subset of `immutable.OrderedMap`). */
export interface OrderedMap<K, V> extends Iterable<[K, V]> {
  readonly size: number;
  get(key: K, notSetValue?: V): V | undefined;
  has(key: K): boolean;
  isEmpty(): boolean;
  keys(): IterableIterator<K>;
  values(): IterableIterator<V>;
  entries(): IterableIterator<[K, V]>;
  toArray(): [K, V][];
  forEach(fn: (value: V, key: K, map: OrderedMap<K, V>) => void): number;
  equals(other: unknown): boolean;
}

export type ListSeparator = "," | " " | "/" | null;

/** Base class for every Sass value. */
export abstract class Value {
  readonly isTruthy: boolean;
  readonly realNull: Value | null;
  readonly asList: List<Value>;
  readonly hasBrackets: boolean;
  readonly separator: ListSeparator;
  get(index: number): Value | undefined;
  sassIndexToListIndex(sassIndex: Value, name?: string): number;
  tryMap(): SassMap | null;
  assertNumber(name?: string): SassNumber;
  assertString(name?: string): SassString;
  assertColor(name?: string): SassColor;
  assertMap(name?: string): SassMap;
  assertBoolean(name?: string): SassBoolean;
  assertCalculation(name?: string): SassCalculation;
  assertFunction(name?: string): SassFunction;
  assertMixin(name?: string): SassMixin;
  equals(other: Value): boolean;
  hashCode(): number;
}

export class SassBoolean extends Value {
  constructor(value: boolean);
  readonly value: boolean;
}
export const sassTrue: SassBoolean;
export const sassFalse: SassBoolean;
export const sassNull: Value;

export class SassString extends Value {
  constructor(text?: string, options?: { quotes?: boolean });
  static empty(options?: { quotes?: boolean }): SassString;
  readonly text: string;
  readonly hasQuotes: boolean;
  readonly sassLength: number;
  sassIndexToStringIndex(sassIndex: Value, name?: string): number;
}

export class SassNumber extends Value {
  constructor(value: number, unit?: string);
  constructor(value: number, options: { numeratorUnits?: string[]; denominatorUnits?: string[] });
  readonly value: number;
  readonly numeratorUnits: List<string>;
  readonly denominatorUnits: List<string>;
  readonly hasUnits: boolean;
  readonly isInt: boolean;
  readonly asInt: number | null;
  hasUnit(unit: string): boolean;
  assertInt(name?: string): number;
  assertNoUnits(name?: string): SassNumber;
  assertUnit(unit: string, name?: string): SassNumber;
  assertInRange(min: number, max: number, name?: string): number;
  compatibleWithUnit(unit: string): boolean;
  convert(newNumerators: string[] | List<string>, newDenominators: string[] | List<string>, name?: string): SassNumber;
  convertToMatch(other: SassNumber, name?: string, otherName?: string): SassNumber;
  convertValue(newNumerators: string[] | List<string>, newDenominators: string[] | List<string>, name?: string): number;
  convertValueToMatch(other: SassNumber, name?: string, otherName?: string): number;
  coerce(newNumerators: string[] | List<string>, newDenominators: string[] | List<string>, name?: string): SassNumber;
  coerceToMatch(other: SassNumber, name?: string, otherName?: string): SassNumber;
  coerceValue(newNumerators: string[] | List<string>, newDenominators: string[] | List<string>, name?: string): number;
  coerceValueToMatch(other: SassNumber, name?: string, otherName?: string): number;
}

export class SassColor extends Value {
  constructor(options: {
    space?: ColorSpace;
    alpha?: number;
    /** Channel values by name (e.g. red/green/blue, lightness/chroma/hue); `null` = missing. */
    [channel: string]: ColorSpace | number | null | undefined;
  });
  readonly space: ColorSpace;
  readonly isLegacy: boolean;
  readonly channels: List<number>;
  readonly channelsOrNull: List<number | null>;
  readonly alpha: number;
  readonly red: number;
  readonly green: number;
  readonly blue: number;
  readonly hue: number;
  readonly saturation: number;
  readonly lightness: number;
  readonly whiteness: number;
  readonly blackness: number;
  channel(name: string, options?: { space?: ColorSpace }): number;
  isChannelMissing(name: string): boolean;
  isChannelPowerless(name: string, options?: { space?: ColorSpace }): boolean;
  toSpace(space: ColorSpace): SassColor;
  isInGamut(space?: ColorSpace): boolean;
  toGamut(options?: { space?: ColorSpace; method?: string }): SassColor;
  /** A copy with the named channels (and/or `alpha`/`space`) replaced. */
  change(options: { space?: ColorSpace; alpha?: number; [channel: string]: ColorSpace | number | null | undefined }): SassColor;
  interpolate(color2: SassColor, options?: { weight?: number; method?: string }): SassColor;
}

export class SassList extends Value {
  constructor(contents?: Value[] | List<Value>, options?: { separator?: ListSeparator; brackets?: boolean });
}

export class SassArgumentList extends SassList {
  constructor(contents?: Value[] | List<Value>, keywords?: Map<string, Value>, options?: { separator?: ListSeparator; brackets?: boolean });
  readonly keywords: Map<string, Value>;
}

export class SassMap extends Value {
  constructor(contents?: Map<Value, Value> | OrderedMap<Value, Value>);
  static empty(): SassMap;
  /** The map's contents as a value-keyed, insertion-ordered immutable map. */
  readonly contents: OrderedMap<Value, Value>;
}

/** A value usable inside a calculation. */
export type CalculationValue = SassNumber | SassCalculation | CalculationOperation | SassString | string;

/** A binary operation inside a calculation (`+`, `-`, `*`, `/`). */
export class CalculationOperation {
  constructor(operator: "+" | "-" | "*" | "/", left: CalculationValue, right: CalculationValue);
  readonly operator: "+" | "-" | "*" | "/";
  readonly left: CalculationValue;
  readonly right: CalculationValue;
  equals(other: unknown): boolean;
}

/** A `calc()` / `min()` / `max()` / `clamp()` calculation. */
export class SassCalculation extends Value {
  static calc(argument: CalculationValue): SassCalculation;
  static min(args: CalculationValue[]): SassCalculation;
  static max(args: CalculationValue[]): SassCalculation;
  static clamp(min: CalculationValue, value?: CalculationValue, max?: CalculationValue): SassCalculation;
  readonly name: string;
  readonly arguments: List<CalculationValue>;
}

/** An opaque first-class function reference — round-trips to/from the engine only. */
export class SassFunction extends Value {}

/** An opaque first-class mixin reference — round-trips to/from the engine only. */
export class SassMixin extends Value {}

declare const _default: {
  compile: typeof compile;
  compileAsync: typeof compileAsync;
  compileString: typeof compileString;
  compileStringAsync: typeof compileStringAsync;
  initCompiler: typeof initCompiler;
  initAsyncCompiler: typeof initAsyncCompiler;
  configure: typeof configure;
  info: typeof info;
  Exception: typeof Exception;
  Logger: typeof Logger;
  Value: typeof Value;
  SassBoolean: typeof SassBoolean;
  SassString: typeof SassString;
  SassNumber: typeof SassNumber;
  SassColor: typeof SassColor;
  SassList: typeof SassList;
  SassArgumentList: typeof SassArgumentList;
  SassMap: typeof SassMap;
  SassCalculation: typeof SassCalculation;
  CalculationOperation: typeof CalculationOperation;
  SassFunction: typeof SassFunction;
  SassMixin: typeof SassMixin;
  sassTrue: typeof sassTrue;
  sassFalse: typeof sassFalse;
  sassNull: typeof sassNull;
};
export default _default;
