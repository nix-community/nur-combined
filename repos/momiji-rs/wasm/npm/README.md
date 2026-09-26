# sasso

[sasso](https://github.com/momiji-rs/sasso) — a pure-Rust SCSS → CSS compiler
(a dart-sass alternative). The package is a tiny, **dependency-free**
WebAssembly module: no wasm-bindgen, one small `.wasm` plus a hand-written
loader, and it is all you need — nothing here requires a native build step. On
macOS and Linux it additionally pulls a prebuilt **native addon**
(`sasso-native-<platform>`) as an `optionalDependency`; the `sasso` command
uses it when it is there, and importing the library reaches it through the
`"sasso/native"` subpath. Both produce byte-identical output. It mirrors the
**dart-sass *modern* JS API**, so it's a drop-in for the
[`sass`](https://www.npmjs.com/package/sass) npm package in build tools.

```bash
npm install sasso
```

## Quick start

```js
import { compileString } from "sasso";

const { css } = compileString(`
  @use "sass:color";
  $brand: #2a7ae2;
  .button {
    color: $brand;
    &:hover { color: color.adjust($brand, $lightness: -10%); }
  }
`);
console.log(css);

// compressed output
compileString("a { color: #ffffff }", { style: "compressed" }).css; // a{color:#fff}
```

## API — dart-sass *modern* compatible

```ts
compileString(source, options?)      -> CompileResult
compileStringAsync(source, options?) -> Promise<CompileResult>
compile(path, options?)              -> CompileResult            // Node only (reads the file)
compileAsync(path, options?)         -> Promise<CompileResult>

interface CompileResult { css: string; loadedUrls: URL[]; sourceMap?: object }
```

- `options`: `{ style?: "expanded" | "compressed", sourceMap?: boolean,
  sourceMapIncludeSources?: boolean, loadPaths?: string[], importers?: [...],
  functions?: {...}, charset?: boolean, quietDeps?: boolean,
  silenceDeprecations?: string[], logger?: Logger }`.
  `compileString` also accepts `url?: string | URL` (the source's canonical URL,
  the base for its relative imports) and `syntax?: "scss" | "indented" | "css"`.
- **Imports.** `@use` / `@forward` / `@import` resolve via `loadPaths`, relative
  paths (against `url` / the `compile(path)` file), and custom `importers` —
  dart-sass *modern* `Importer` (`{ canonicalize, load }`) and `FileImporter`
  (`{ findFileUrl }`). All loaded URLs are reported in `loadedUrls`.
- A Sass error throws an `Exception` (an `Error` subclass with `name ===
  "Exception"`, the raw `sassMessage`, and a `span` — `{ url, start, end }`).
- **Warnings.** `@warn` / `@debug` / deprecation warnings print to stderr by
  default, or go to a `logger` (`{ warn(message, opts), debug(message, opts) }`,
  dart-sass-shaped). `Logger.silent` discards them.
- `unicode: false` renders diagnostics with the ASCII glyph set (`,`/`|`/`'`
  instead of `╷`/`│`/`╵`), like the CLI's `--no-unicode`. A sasso extension:
  dart-sass exposes this on its command line only.
- `quietDeps: true` drops deprecation warnings raised inside *dependencies* —
  stylesheets reached through a `loadPaths` directory or a custom importer, and
  whatever those load relatively. It is about how a file was REACHED, not where
  it lives: one the entry loads relatively still warns, even from inside a load
  path. A dependency's own `@warn` / `@debug` still reaches the logger, as in
  dart-sass.
- `silenceDeprecations: ["import", ...]` drops those deprecations by id, leaving
  every other warning in place — dart-sass's flag of the same name, and the CLI's
  `--silence-deprecation`. Silencing happens inside the compiler, beside
  `quietDeps`, so a silenced id is not counted towards the `N repetitive
  deprecation warnings omitted` footer either. Ids sasso never emits are accepted
  and do nothing, so a build written for `sass` does not fail for naming one; an
  id dart-sass does not know at all warns (`Invalid deprecation "nope".`, through
  the `logger` if there is one) and the compile proceeds, as in dart's JS API —
  it is the CLI that rejects an unknown id, with dart's exit 64.
- `charset: false` suppresses the `@charset` / BOM prefix for non-ASCII output.
- `info` is exported for build-tool auto-detection; `initCompiler()` /
  `initAsyncCompiler()` implement the dart-sass Compiler API (Vite uses these).

```js
import { compileString } from "sasso";

// loadPaths + a relative partial
compileString(`@use "theme";`, { url: "file:///app/main.scss", loadPaths: ["scss"] });

// a custom (synchronous) importer
compileString(`@use "virtual:colors" as c; .a { color: c.$brand; }`, {
  importers: [{
    canonicalize: (url) => url === "virtual:colors" ? new URL("virtual:colors") : null,
    load: (u) => u.href === "virtual:colors" ? { contents: "$brand: #2a7ae2;", syntax: "scss" } : null,
  }],
});
```

> **Sync vs. async importers.** The **async** APIs (`compileStringAsync`,
> `compileAsync`, the Compiler API) support **asynchronous** importers — the kind
> sass-loader and Vite inject by default — via an `asyncify`'d wasm module that
> suspends the compile across each `await`. The **synchronous** APIs
> (`compileString`, `compile`) run a faster non-asyncify'd module and therefore
> require synchronous importers; an importer (or `findFileUrl`) that returns a
> `Promise` throws there. Use the async API when your importers are async.
>
> Importers that happen to resolve **synchronously** on the async API (plain
> return values, `loadPaths`, cache hits inside bundler importers) are
> delivered without any suspension since 0.8.0 — you don't pay for asyncify
> unless a callback actually returns a `Promise`.

## Concurrent compiles (async APIs)

Since 0.8.0, concurrent `compileStringAsync` / `compileAsync` calls no longer
queue behind one another: while one compile awaits an asynchronous importer,
others run on their own engine instances. A pool of asyncify instances grows
lazily up to `min(4, cpu cores)` — a process that never overlaps async compiles
only ever pays for one instance. Each extra instance reserves its own wasm
memory (including the arena) plus a 1 MiB asyncify stack; tune or pin the cap
with `configure()`:

```js
import { configure } from "sasso";

configure({ asyncInstances: 2 }); // cap the pool (memory-constrained hosts)
// configure({ asyncInstances: 1 }); // pre-0.8.0 behavior: fully serialized
```

Lowering the cap drops surplus instances as they finish their compiles. Note
the pool overlaps compiles across importer *waits* (the bundler fan-out case) —
pure CPU-bound compiles still share the one JS thread.

## Custom functions

Define Sass functions in JS with the dart-sass `functions` option. A callback
receives the bound `Value` arguments and returns a `Value` (the **full** dart-sass
type system is exported — `SassNumber` (with unit conversion), `SassString`,
`SassColor` (every CSS Color 4 space + conversions), `SassList`, `SassMap`,
`SassBoolean`, `sassNull`, `SassCalculation`, and first-class `SassFunction` /
`SassMixin`):

```js
import { compileString, SassNumber, SassColor } from "sasso";

compileString(`.a { width: pow(2, 10) * 1px; color: brand(); }`, {
  functions: {
    "pow($base, $exp)": (args) =>
      new SassNumber(args[0].assertNumber().value ** args[1].assertNumber().value),
    "brand()": () =>
      new SassColor({ space: "oklch", lightness: 0.7, chroma: 0.15, hue: 250 }),
  },
});
```

Custom functions override built-in globals but lose to user `@function`s. A
callback may be **async** — but only under the async APIs (`compileStringAsync`
/ `compileAsync` / the Compiler API); the sync APIs throw on a `Promise`.

> **Migrating from `@momiji-rs/sasso`?** The old `compile(scss) → string` is now
> `compileString(scss).css`, and `compile` takes a **file path** (to match
> dart-sass). See the [changelog](https://github.com/momiji-rs/sasso/releases).

## Drop-in for `sass` in build tools

Both tools drive sasso through the dart-sass *modern* async API and its default
asynchronous importer — both work **zero-config**, including cross-file
`@use`/`@import`.

**webpack / sass-loader** — pass sasso as the implementation:

```js
{
  loader: "sass-loader",
  options: { implementation: require("sasso"), api: "modern" },
}
```

**Vite** — Vite resolves its Sass implementation by the package name `sass`, so
alias it to sasso in `package.json`, then use it as usual:

```json
{ "devDependencies": { "sass": "npm:sasso@^0.8.0" } }
```

```js
// vite.config.js — modern API (Vite's default)
export default { css: { preprocessorOptions: { scss: {} } } };
```

## CLI — `npx sasso`

The package ships a `sasso` bin — pure Node, no dependencies of its own,
compiling through the native addon when the platform package is installed and
the wasm build otherwise — with a subset of the dart-sass `sass` CLI flags:

```bash
npx sasso input.scss                      # compile to stdout
npx sasso input.scss output.css           # write output.css (+ output.css.map)
npx sasso -o output.css input.scss        # the same, as a flag
npx sasso a.scss:a.css b.scss:b.css       # multiple input:output pairs
npx sasso scss:public/css                 # a whole tree, mirrored
npx sasso --style=compressed input.scss
npx sasso -I node_modules -I scss main.scss   # add load paths
npx sasso --watch input.scss output.css   # recompile on change (deps tracked)
echo '.a{b:1+2}' | npx sasso --stdin
npx sasso --help
```

Flags: `-s/--style <expanded|compressed>`, `-I/--load-path <dir>` (repeatable),
`-o/--output <file>`, `--stdin`, `--indented`, `--[no-]source-map` (on by
default when writing a file), `--source-map-urls <relative|absolute>`,
`--embed-sources`, `--embed-source-map` (inline the map), `--[no-]charset`,
`-q/--quiet` (silence `@warn`/`@debug`), `--[no-]quiet-deps`, `--[no-]unicode`
(ASCII glyphs in diagnostics), `--[no-]stop-on-error`, `--no-css`, `--update`
(leave outputs newer than their input *and* every stylesheet it imports),
`-w/--watch` (re-compiles when the input or any dependency changes), `--loop <N>` (recompile N times and report
throughput), `--help`, `--version`, and `-j/--jobs <N>` (how many files to
compile at once; the default is at most one per physical core on Linux — the
cores `/proc/cpuinfo` reports, which on an SMT machine is fewer than the CPU
count, because threads sharing a core contend for the same execution units. An
affinity mask (`taskset`, a cpuset) or a cgroup CPU quota (`docker --cpus`, a
Kubernetes CPU limit) lowers it further. On a Linux that publishes no topology
the core count is unknown, so the default is one per CPU the process may
actually use — still under those caps. Off Linux it is one per CPU the runtime
reports). An input of `-` is standard input. Accepted for dart-sass
compatibility: `-c/--[no-]color` (a no-op — sasso never colors its output).

**When a compile fails**, `--[no-]error-css` decides what happens to the
output, following dart-sass in each case: by default the file is replaced by a
stylesheet describing the error, so the page says what broke instead of showing
the CSS of an earlier build; `--no-error-css` removes it instead; `--no-css`
leaves it exactly as it was, as does a failure to READ the entry, which is not
a compile error. Writing to stdout rather than a file, the stylesheet is
printed only when `--error-css` is given explicitly.

**Which engine the CLI uses.** It prefers the native addon — `npm install
sasso` already fetched `sasso-native-<platform>` as an optionalDependency on
macOS and Linux — and falls back to the wasm build (the speed-optimised one)
everywhere else. Both produce byte-identical output; `SASSO_ENGINE=wasm` or
`SASSO_ENGINE=native` forces one. Compiling a 138-stylesheet tree on a 12-core
machine, that tree's own flags, best of five, measured against the published
package (2026-09-17): **266 ms** on the native engine, 610 ms on wasm, against
dart-sass 1.104.1's 2268 ms.

`sasso --engine` prints which one this install runs and why, which is the thing
to paste into a bug report about speed:

```
$ sasso --engine
engine:   native (Node addon) — the default here: the native addon loaded
platform: darwin-arm64 (prebuilt addon: sasso-native-darwin-arm64)
sasso:    0.16.0
```

Where an addon **is** prebuilt but did not load — `--omit=optional`, a partial
lockfile, a broken install — the fallback is a silent halving of throughput, so
every compile warns about it on stderr (what happened, and what to do). It stays
quiet in the four cases where it would be noise: under `--quiet`, which means
"don't print warnings"; under `SASSO_ENGINE=wasm`, which says wasm was the
intent; on platforms with no prebuild — musl and Windows today — where wasm is
the engine that is supposed to run; and for an addon refused over a version
mismatch, which says so already and names the fix. `sasso --engine` answers
whatever the flags say.

Importing the library selects nothing: `"sasso"` is always the size-optimised
wasm build and ignores `SASSO_ENGINE`, and the addon is the `"sasso/native"`
subpath below.

An `<in>:<out>` pair may name **directories**: every `.scss`/`.sass`/`.css` file
under `<in>` that is not a partial compiles to the matching path under `<out>`,
following symlinked directories once each. `sasso <dir>` compiles a tree in
place.

The same flags as the native `sasso` binary, whose parser this one is tested
against — a flag the native CLI accepts and this one rejects fails the suite.

## Native addon — `sasso/native`

For the fastest engine, import the **native Node addon** — same API, byte-identical
output (CI-verified against the wasm build), no wasm and no asyncify:

```js
import { compileString, compileStringAsync } from "sasso/native";
```

- **~3× engine speed** over the wasm modules, and **true multi-core concurrency**:
  each async compile runs on its own OS thread, so a bundler fanning out N
  entries finishes in roughly one compile's wall time instead of N.
- **Zero extra install steps.** Prebuilt binaries ship as `optionalDependencies`
  (`sasso-native-<platform>`); npm fetches only the one matching your machine.
  Prebuilt platforms: macOS arm64/x64, Linux x64/arm64 (glibc).
- On an unsupported platform the import throws a clear error — the wasm entries
  (`sasso`, `sasso/speed`) work everywhere and remain the zero-surprise default.
- `configure()` is accepted but a no-op here (`asyncInstances`/`arenaMiB` are
  wasm-engine knobs); a repo checkout can also point `SASSO_NATIVE_BINARY` at a
  locally built binary.

```js
// webpack / sass-loader
{ loader: "sass-loader", options: { implementation: require("sasso/native"), api: "modern" } }
```

## Two builds: size vs speed

The default import is the **size-optimized** build (~350 KB gzip sync + ~580 KB
gzip async module). For ~2× compile throughput on larger modules, import the
**speed-optimized** build instead — same API, same output:

```js
import { compileString } from "sasso";        // default: smallest modules
import { compileString } from "sasso/speed";  // ~2x faster, larger modules
```

Since 0.8.0 the speed entry's **async** APIs also run a speed-optimized
asyncify module (~1 MB gzip) instead of sharing the size-optimized one, so
bundler pipelines that only ever call `compileStringAsync` get the ~2× too.
The speedup applies at V8 steady state — long-lived processes like a bundler
watch/dev server; a one-shot CLI-style compile is dominated by V8's wasm
tiering and won't see the difference.

## Tuning the bump-arena allocator

Both builds bump-allocate a single compile from a reusable arena region, which
is the bulk of the speed advantage. The region defaults to **32 MiB** of wasm
linear memory (grown once on the first compile, then reused). Tune or disable
it with `configure()` — **before the first compile**:

```js
import { configure, compileString } from "sasso/speed";

configure({ arenaMiB: 16 }); // smaller footprint (enough for typical sheets)
// configure({ arenaMiB: 0 }); // disable the arena: lowest memory, slower
compileString(scss);
```

A stylesheet larger than the arena spills to the system allocator with no loss
of correctness — just less speedup. The compile-time default is also settable
when building from source: `SASSO_WASM_ARENA_MB=16 bash wasm/build.sh`.

The loader reads the `.wasm` from disk via `node:fs`, so it targets **Node** (and
bundlers that resolve `node:fs`). For the CLI and the Rust library, see the
[main repository](https://github.com/momiji-rs/sasso).

Licensed under MIT OR Apache-2.0.
