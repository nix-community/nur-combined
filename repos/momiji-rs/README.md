# sasso

[![crates.io](https://img.shields.io/crates/v/sasso.svg)](https://crates.io/crates/sasso)
[![docs.rs](https://img.shields.io/docsrs/sasso)](https://docs.rs/sasso)
[![CI](https://github.com/momiji-rs/sasso/actions/workflows/ci.yml/badge.svg)](https://github.com/momiji-rs/sasso/actions/workflows/ci.yml)
[![CodSpeed](https://img.shields.io/endpoint?url=https://codspeed.io/badge.json)](https://app.codspeed.io/momiji-rs/sasso?utm_source=badge)
[![sass-spec](https://img.shields.io/badge/sass--spec-99.0%25_of_attempted-brightgreen)](#conformance)
[![dart-sass](https://img.shields.io/badge/dart--sass-1.104.1_parity-blue)](#conformance)
[![runtime deps](https://img.shields.io/badge/runtime_deps-0-brightgreen)](Cargo.toml)
[![license](https://img.shields.io/crates/l/sasso.svg)](#license)

A pure-Rust **SCSS → CSS compiler** — a from-scratch dart-sass alternative.
Zero runtime dependencies, wasm-friendly, usable as a **library** and a
**CLI**, and designed to match **current** dart-sass byte-for-byte on the
subset it implements.

> Status: v0.x, maturing fast. Compiles real-world SCSS and indented `.sass`
> byte-identically to **dart-sass 1.104.1** — on a 148-entry-point production
> corpus, 147/148 files match byte-for-byte in *both* output styles and
> 148/148 source maps match exactly — and **passes 99.0% of the official
> [sass-spec](https://github.com/sass/sass-spec) suite (14,114 / 14,258
> attempted)**, tracked as a ratchet (see [Conformance](#conformance) for what
> that denominator means). Every divergence we know about is listed in
> [docs/dart-sass-divergences.md](docs/dart-sass-divergences.md).
>
> Re-checked on 2026-09-17 against a **fresh clone** of that corpus with the
> **published** 0.15.0 binary — nothing built into the tree, the compiler
> downloaded from the release page: of its 148 entry points, **138 compile
> without npm dependencies** (dart-sass 1.104.1 fails on the same ten) and
> **137 of those 138 are byte-identical to dart**; the one that differs is the
> `@extend` duplicate-extender case written up in the divergences doc. The npm
> package, installed from the registry, matches that binary on all 138 — on
> either engine.

## Why another Sass compiler?

`grass` is the incumbent Rust implementation and a strong one (it compiles
Bootstrap/Bulma byte-accurately and is ~2× faster than dart-sass). But it is
pinned to dart-sass **1.54.3** (mid-2022) and predates the CSS Color Level 4
overhaul, so it diverges from current dart-sass on, e.g., fractional color
channels (`rgb(63.75, 127.5, 191.25)` vs rounded hex) and emits hex where
dart-sass now keeps `rgb()`/`hsl()` forms. `sasso` targets **current**
dart-sass exactly, with a span-first parser, a modern color model, and a
zero-dependency, sandbox-friendly core.¹ See
[`docs/GRASS_LANDSCAPE.md`](docs/GRASS_LANDSCAPE.md) for the full analysis.

¹ Exactly one dependency exists, only on Windows, and only for the CLI's
`--update`/`--watch` timestamp: `std` exposes no local time on any platform,
and Windows has no tz database to read. A POSIX, wasm or wasip1 build still
resolves to nothing at all. See `Cargo.toml` for why a safe-API crate beats a
second `unsafe` exemption here.

## Features (this slice)

- `$variables`, lexical scoping, `!default`, `!global`
- Nesting, the `&` parent selector (with selector-list multiplication), and
  combinator normalization (`>`, `+`, `~`)
- `#{}` interpolation in selectors, property names and values
- `//` (stripped) and `/* */` (preserved) comments
- Numbers with units and unit arithmetic (`$pad * 2 → 16px`)
- A full color model with fractional channels + author-spelling preservation
  (`red`, `#336699`, `rgb()`/`hsl()` round-trip unchanged)
- Color functions: `rgb`/`rgba`/`hsl`/`hsla`/`mix`/`lighten`/`darken`/
  `percentage` (+ `red`/`green`/`blue`/`alpha`)
- `@import` partial inlining through a pluggable [`Importer`] (CSS imports
  pass through)
- `expanded` and `compressed` output styles
- **Source maps (v3)** — byte-exact to dart-sass 1.104.1, on the library
  (`compile_with_source_map`), the CLI (on by default when writing a file,
  like dart-sass; `--embed-source-map` inlines one), and wasm
  (`compile(scss, { sourceMap: true })`)
- Verbatim preservation of CSS functions it doesn't own (`calc`, `var`,
  `clamp`, `translateX`, …)

Since this slice was written the ratchet has added a great deal more —
`@mixin`/`@function`, control flow (`@if`/`@each`/`@for`/`@while`), `@extend`
and `%placeholder`s, a `calc()` engine, the CSS unit system + math functions,
full CSS Color 4 color spaces (`oklch`/`lab`/`color()`…), structured
`@media`/`@supports`, maps, the `@use`/`@forward` module system (built-in
`sass:*` modules + user files), and the indented `.sass` syntax. **The
compiler passes 99.0% of the attempted sass-spec suite (14,114 / 14,258)**
byte-for-byte against dart-sass 1.104.1 — 11,622 byte-exact CSS outputs plus
2,492 error specs it correctly rejects (see [Conformance](#conformance)), and
every known difference is written down in
[docs/dart-sass-divergences.md](docs/dart-sass-divergences.md).

## Install

**CLI — prebuilt binaries.** Every release ships static binaries for Linux
(gnu + musl), macOS and Windows (x86_64 / aarch64), built with
[cargo-dist](https://github.com/axodotdev/cargo-dist). Grab one from the
[Releases](https://github.com/momiji-rs/sasso/releases) page, or:

```console
$ curl -fsSL https://github.com/momiji-rs/sasso/releases/latest/download/sasso-installer.sh | sh   # Linux/macOS
$ cargo binstall sasso        # fetch the prebuilt binary
$ cargo install sasso         # build from source (needs a Rust toolchain)
```

**CLI — Homebrew.** macOS and Linux, arm64 and x86_64. It installs the same
prebuilt binary as above, from
[momiji-rs/homebrew-tap](https://github.com/momiji-rs/homebrew-tap):

```console
$ brew trust --formula momiji-rs/tap/sasso
$ brew install momiji-rs/tap/sasso
```

`brew trust --formula` grants the narrowest trust there is — this formula, not
the tap — and is what lets `brew info sasso` and `brew upgrade sasso` work by
short name afterwards.

**CLI — Nix.** This repo is a flake, so nothing has to be packaged first:

```console
$ nix run github:momiji-rs/sasso -- --version
$ nix profile install github:momiji-rs/sasso
```

In a NixOS or nix-darwin configuration, add the flake's `overlays.default` and
`pkgs.sasso` resolves to it — alongside `pkgs.sasso-ffi`, the C ABI packaged for
building against (`libsasso`, `sasso.h`, a pkg-config file). `nix develop` drops
you into the toolchain CI uses, dart-sass included, so the opt-in parity suite
runs offline (`SASSO_PARITY=1 cargo test --test parity`). See
[`nix/README.md`](nix/README.md) for the packaging itself.

**Library — crates.io.**

```console
$ cargo add sasso
```

**npm.** Mirrors the dart-sass *modern* JS API, so it is a drop-in for the
`sass` package in build tools (no wasm-bindgen, no build step):

```console
$ npm install sasso
```

One install, two engines. The package carries the wasm build — which works
everywhere, including the browser — and pulls a **native addon**
(`sasso-native-<platform>`) as an `optionalDependency` on macOS and Linux. The
output is byte-identical either way.

**The `sasso` command** prefers the addon when it is there and falls back to
wasm when it is not; `SASSO_ENGINE=wasm|native` forces a choice, and
`sasso --engine` prints which one an install actually runs (a fallback on a
platform that has a prebuilt addon also says so on stderr — it costs roughly
half the throughput). It prefers
neither when there is something better: if a `sasso` **binary** is on `PATH` and
its version matches the package **exactly**, the command line is handed to it
and the run ends with its exit code — so `brew install momiji-rs/tap/sasso`
speeds up the `npx sasso` in a project's scripts without touching them
(momiji-rs/sasso#24). The version has to match because a package pinned in
`devDependencies` must not silently compile with whatever sasso a developer
happens to have; a mismatch is passed over in silence. `SASSO_BINARY=<path>`
names a binary explicitly, version unchecked, and `SASSO_BINARY=0` turns the
hand-off off. `SASSO_DEBUG_ENGINE=1` prints which of these happened and why.
`--watch` always stays in-process, and now by choice rather than for want of
a watcher: the binary has one, and it polls, because a native watcher would
be a runtime dependency. Measured on macOS, one settled save per process,
twelve fresh processes: the npm CLI answers in 34 ms (median), the binary in
45 ms, dart-sass 1.104.1 in **13196 ms**. Handing off would trade the fastest
of the three for the second.

That third number is not a typo and not dart's fault: native filesystem
events are what is slow on macOS. `fs.watch` on its own, no sasso involved,
delivers in 552 ms (median) on one Mac here and drops 12 of 20 events
entirely on another, against 0.2 ms on Linux. So since #164 the npm CLI does
not rely on them either — it keeps `fs.watch` for latency and sweeps beside
it for the guarantee. `--update` hands off only on the version-MATCHED path: the
binary has the flag now, but `SASSO_BINARY` is unchecked by design and may
name one from before it, so that route stays in-process too. `sasso --engine` reports the
hand-off rather than taking it.

**Importing the library** selects nothing: `import … from "sasso"` is always
the size-optimised wasm build and ignores `SASSO_ENGINE`, `"sasso/speed"` is
the faster, larger wasm build, and the addon is the explicit `"sasso/native"`
subpath. Compiling the 138 stylesheets above in one process, with lila's own
flags, best of five, one run for the whole table — every figure measured against
the **published** artifacts, the binary downloaded from the release page and the
package from `npm install sasso` (2026-09-17, macOS / arm64):

| | |
|---|---|
| `npx sasso` (native engine) | **266 ms** |
| `npx sasso` (wasm engine) | 610 ms |
| the `sasso` 0.15.0 binary | 137 ms |
| dart-sass 1.104.1 | 2268 ms |

What the hand-off is worth, on 40 entry points with `--style=compressed
--no-source-map` and the same published artifacts (2026-09-18, macOS / arm64,
one run for all three): the 0.16.0 binary **15.1 ms**, `npx sasso` on the native
addon **104.1 ms**, and `npx sasso` handing the command line to that same binary
**48.2 ms** — identical CSS in all 40 files. The 33 ms it does not recover is
Node: starting it and spawning a child costs 35.0 ms of the 48.2 on a single
tiny file. Nothing about a stylesheet makes that cheaper, which is why the
binary is worth installing on its own.

```js
import { compileString } from "sasso";
compileString("a { color: #ffffff }", { style: "compressed" }).css; // a{color:#fff}
```

Works as the `sass` implementation in **webpack/sass-loader** (`implementation:
require("sasso"), api: "modern"`) and **Vite** (alias `"sass": "npm:sasso"`).

## Library usage

```rust
use sasso::{compile, Options, OutputStyle};

let scss = "$c: #336699; .a { color: $c; &:hover { color: lighten($c, 10%); } }";
let css = compile(scss, &Options::default()).unwrap();
assert!(css.contains("a:hover"));

// Minified:
let min = compile(scss, &Options::default().with_style(OutputStyle::Compressed)).unwrap();
```

`@import` resolution is controlled by an [`Importer`] you supply, so file
access stays on your side of any sandbox:

```rust
use sasso::{compile, Importer, Options};

struct MyFs;
impl Importer for MyFs {
    fn resolve(&self, path: &str) -> Option<String> {
        std::fs::read_to_string(format!("scss/_{path}.scss")).ok()
    }
}
let css = compile("@import \"base\";", &Options::default().with_importer(&MyFs)).unwrap();
```

A ready-made [`FsImporter`] is provided for standalone/CLI use.

## CLI usage

The CLI takes the same arguments as `sass`, so a build script written for
dart-sass runs unchanged:

```console
$ cargo install --path .              # installs the `sasso` binary
$ sasso input.scss                    # CSS to stdout (expanded)
$ sasso input.scss out.css            # to a file, with out.css.map (dart's default)
$ sasso --style=compressed --no-source-map input.scss out.css
$ sasso a.scss:out/a.css b.scss:out/b.css   # many files, compiled in parallel
$ sasso scss/:css/                    # a whole tree (partials skipped)
$ sasso -I scss/ main.scss            # add @use/@import load paths
$ echo '.a{color:red}' | sasso --stdin
```

Several inputs (`in:out` pairs or a directory pair) compile in parallel, one
worker per physical core where the topology is known — Linux, via
`/proc/cpuinfo` — and one per CPU where it is not. That is an upper bound: an
affinity mask or a cgroup CPU quota lowers it, and `-j N` overrides it
outright. Diagnostics are reported in command-line order. Supported dart-sass
flags: `--[no-]source-map`, `--source-map-urls`, `--[no-]embed-sources`,
`--[no-]embed-source-map`, `--[no-]error-css`, `--[no-]charset`, `-q/--quiet`,
`--quiet-deps`, `--stop-on-error`, `--[no-]unicode`, `--[no-]color` (accepted;
sasso never colors), `--indented`, `--stdin`. Exit codes match on both CLIs (64
usage, 65 compile error, 66 unreadable input or unwritable output; the worse
of the two when one batch has both). Not supported by the binary:
`--pkg-importer` and the deprecation-selection flags. `--update` and
`-w/--watch` are on both CLIs (#86): `--update` compares the output against
the entry *and* every stylesheet the entry loads, as dart-sass does, and
`--watch` follows that same set, refuses the same three shapes dart refuses,
and prints the same banner and per-write line. `--[no-]poll` selects how the npm CLI
watches — `--poll` sweeps only, `--no-poll` uses node's `fs.watch` only, and
the default is both (#164). On the binary it is still accepted and still does
nothing, because that one always polls: a native watcher would mean a
dependency. `src/watch.rs` and `wasm/npm/_poller.mjs` have the measurements.
`sasso --help` lists everything.

## Conformance

The official sass-spec suite is the parity oracle. The harness in
[`spec/`](spec/) runs the compiler against every spec case and reports a
pass rate; we ratchet it upward over time.

| Metric | Value |
| --- | --- |
| sass-spec commit | `b39c3276` (2026-09-08), reference dart-sass **1.104.1** |
| Total cases | 14,266 |
| Attempted (excl. 8 dart-sass `:todo`) | 14,258 |
| **Passing** | **14,114 — 98.99% of attempted** (98.93% of all 14,266) |
| ↳ byte-exact CSS output | 11,622 |
| ↳ error specs correctly rejected | 2,492 |

*Passing* = byte-exact CSS output match **plus** error specs the compiler
correctly rejects — the standard sass-spec conformance metric (the harness
checks that an error spec errors; the error *message* is tracked separately as
a non-gating metric). The 8 excluded cases are tagged `:todo` for **dart-sass
itself** upstream — dart-sass doesn't pass them either; sasso matches
dart-sass's actual behaviour on all 8 regardless.

The rate is a ratchet, not a high-water mark: CI fails if it drops. It reads
lower than it once did because the pinned suite moved forward — an earlier
snapshot (`1b03109a`, dart-sass 1.101.0, 13,896 attempted) was passed in full,
and re-pinning to a 2026-09-08 suite added cases we do not pass yet. Re-pinning
is deliberate: a conformance number against a stale oracle measures the wrong
thing.

What the remaining cases are, and every other known difference from dart-sass,
is written down in
[docs/dart-sass-divergences.md](docs/dart-sass-divergences.md) — including the
handful that affect compiled output, so the claim above has a checkable
denominator.

**The numbers above are `expanded` output.** sass-spec ships one expectation per
case and dart-sass generated every one of them in the default `expanded` style,
so for most of this project's life no gate looked at compressed CSS at all. A
second ratchet now does, against a committed manifest of per-case digests of
dart-sass 1.104.1's **compressed** output for the same cases
(`spec/COMPRESSED_EXPECT.txt`, see [spec/REPORT.md](spec/REPORT.md)):

| Metric | Value |
| --- | --- |
| **Passing, compressed** | **14,052 — 98.56% of attempted** |
| ↳ byte-exact compressed CSS | 11,560 |
| ↳ error specs correctly rejected (style-independent) | 2,492 |

The gate found 1,528 cases that compile to byte-exact `expanded` CSS and to
compressed CSS that is not byte-exact — every one of them byte-shortening
rather than meaning. Four mechanisms have accounted for 1,422 of them: the
`%`/`deg` a colour function's lightness and hue keep when compressed, which of
dart's two number writers decides whether a fraction loses its leading zero,
which nodes survive compression empty (`@media {}` goes, `@font-face {}` stays
— dart keeps an at-rule it does not know the semantics of), and whether a
preserved call is a calculation or a string (a string carries one spelling for
both styles, so `round(1px, 2bar)` could not lose its space). A fifth, which of
the legacy `rgb()`/`hsl()` forms a colour is written in, accounted for 28 more,
and five smaller ones for the last 14: the order dart multiplies a channel by
its maximum in, the spelling an `@import` keeps for its media modifiers, the
space a plain-CSS `@function`'s SassScript declaration may drop, the escape a
private-use character trades for its own bytes, and what `meta.inspect` escapes
whatever the style. The last one took a sixth: which of dart's node classes an
at-rule came from, which its NAME cannot answer, because the parser decides the
class and `@#{"media"} (a: 1)` is a generic at-rule that merely spells itself
`@media`. The 62 cases that remain are all ones where dart-sass 1.104.1's own
expanded output no longer matches the expectation sass-spec ships, so they
cannot pass both ratchets at once. This is a ratchet like the other one — it can
only go up.

**Strict input validation, too.** Matching dart-sass means rejecting what
dart-sass rejects, not just reproducing its output. sasso errors — rather than
silently accepting — on an invalid hex literal (`#00000`), out-of-grammar
`rgb()`/`hsl()` arguments, a duplicate `@mixin`/`@function` parameter, a
misplaced `@content`/`@extend`, a style rule or declaration inside a
`@function` body, a malformed `:nth-child()` / empty `:not()` selector, a bad
`@charset` or `@at-root (…)` query, and more — each with dart-sass's exact
message.

Run it yourself:

```console
$ spec/fetch.sh                                      # clone the suite
$ cargo build --release
$ SASS_BIN=target/release/sasso python3 spec/run_spec.py
$ python3 spec/check_baseline.py                     # expanded ratchet
$ python3 spec/check_baseline.py --style compressed  # compressed ratchet
```

## Performance

`sasso` is a native, in-process library — no subprocess, no Node, no Dart VM —
so startup is effectively free, which dominates when a build compiles many
files. On arm64 macOS it is the **fastest** of the three engines measured,
beating dart-sass by 19–30× end-to-end and leading `grass` (the incumbent Rust
compiler) by ~2.3–2.9×:

| Axis | sasso | grass | dart-sass (bin) | npx sass |
| --- | --- | --- | --- | --- |
| Startup² | **1.8 ms** | 1.8 ms | 139 ms | 495 ms |
| Cold single large file | **11.7 ms** | 26.5 ms | 354 ms | 710 ms |
| Batch (40 files, 1 process) | **49.0 ms** | 136 ms | 916 ms | — |
| Pure compile (startup removed) | **7.4 ms** | 21.3 ms | ~216 ms¹ | — |

¹ derived (cold − startup) — dart-sass has no in-process loop mode. So sasso is
~29× faster than dart-sass on **pure compute**, ~30× on a cold single file, and
~77× on startup; vs `grass` it is ~2.3× cold / ~2.8× batch / ~2.9× pure.

² Startup compiles a 1-rule file, so it sits at the OS process-spawn floor —
sasso and grass measure **identically (1.8 ms)** here (the *mean* is dominated
by scheduler jitter at this sub-2 ms scale). The native library and wasm builds
remove process startup entirely. A
**scoped bump-arena allocator** (one audited `unsafe` module, Miri- and
AddressSanitizer-verified; the rest of the library stays `unsafe`-free) gives a
further ~1.5× by turning each compile's allocations into a pointer bump freed
wholesale at the end. Composite values (strings, lists, maps) are
reference-counted, so reading a `$variable` is an O(1) refcount bump, not a
deep copy — on a large list passed through a call chain without mutation this
cuts both instructions (~7×) and peak memory (~13×). A round of evaluator
allocation trimming — skipping the per-rule selector clone when nothing extends
it, iterating `@each` over the list's shared handle, and dropping redundant
per-declaration copies — shaves a further ~2.8% off pure compile on
representative stylesheets (measured by instructions-retired, since the win is
below wall-clock jitter at this ms scale; byte-identical output). Eight further
rounds carry that campaign on — a rule's selector list resolved once and shared,
carried into the output tree rather than re-materialised, the selector scanners
reading from an inline character buffer, `@function` and
`@mixin` frames built only where something lands in them, a built-in call that
stops collecting argument spans nothing will read, a nested selector resolved
without the throwaway scaffolding, a number's unit shared rather than copied,
and a template's literal text handed back rather than rebuilt. On the large
corpus that is **133.840M → 109.616M instructions and 377,761 → 155,656
allocations** — -18.1% and -58.8%, arithmetic on the endpoints each round
reports — every round verifying the sass-spec ratchet at delta +0. The
per-round tables are in the [0.14.0](CHANGELOG.md#0140---2026-09-17) and
[0.15.0](CHANGELOG.md#0150---2026-09-17) changelog entries. Full three-way
methodology, per-file numbers and the correctness diff are in
[`bench/three_way.md`](bench/three_way.md) — which reports through the earlier
−27% round and none of the allocation campaign above; run it yourself with
`cd bench && RUNS=12 WARMUP=3 LOOP_N=200 bash scripts/run_bench.sh`.

## WebAssembly

Because the library is zero-dependency and pure `std` on every target that
is not Windows — and the one Windows dependency is the CLI's clock, not the
library — it compiles to `wasm32-unknown-unknown` and `wasm32-wasip1` out of
the box (built in CI). The
deployable `.wasm` cdylib ships in two variants, published to npm as
[`sasso`](https://www.npmjs.com/package/sasso):

| Variant | Build | Over the wire | Compile (large, in Node)³ |
| --- | --- | --- | --- |
| **size** (default) | `opt-level = "z"` + LTO + `panic = "abort"` + `strip` + `wasm-opt -Oz` | **~854 KB / ~356 KB gzip** | ~27 ms |
| **speed** (`sasso/speed`) | `opt-level = 3` + `wasm-opt -O3` | **~1.84 MB / ~637 KB gzip** | ~12 ms |

³ in-process compile of the same large file, Node 22 (best-of-N). The wasm tax
over native `sasso` (7.7 ms) is ~1.5× for the speed build and ~3.5× for the
size build; the wasm build runs without the bump arena. Even so the **speed
build (~12 ms) beats native `grass` (21 ms)** and every dart-sass form a Node
toolchain can run.

A whole modern Sass compiler — `@use`/`@forward`, `@extend`, the calc engine,
CSS Color 4 — in a few hundred KB gzipped, far smaller than shipping the
dart-sass compiler as JavaScript. A browser playground is tracked in the issues.

## Language bindings

sasso ships as a Rust crate and is usable from other languages too. **First-party**
packages are released by this project and pin a published `sasso` crate version;
**community** bindings are maintained in their own repos.

| Language | Package | Maintained by | How |
| --- | --- | --- | --- |
| **Rust** | [`sasso`](https://crates.io/crates/sasso) (crates.io) | First-party | the core library — see [Library usage](#library-usage) above |
| **JavaScript / wasm** | [`sasso`](https://www.npmjs.com/package/sasso) (npm) | First-party | the in-repo [`wasm/`](wasm/) cdylib — see [WebAssembly](#webassembly) above |
| **Ruby** | [`sasso`](https://rubygems.org/gems/sasso) (RubyGems) | First-party | [`momiji-rs/sasso-ruby`](https://github.com/momiji-rs/sasso-ruby) — an in-process native extension (`magnus` + `rb-sys`) around this crate |
| **Python** | [`sasso`](https://pypi.org/project/sasso/) (PyPI) | First-party | [`momiji-rs/sasso-python`](https://github.com/momiji-rs/sasso-python) — `ctypes` over the C ABI; one prebuilt wheel per platform, no build step |
| **Go** | [`sasso-go`](https://github.com/momiji-rs/sasso-go) (`go get`) | First-party | [`momiji-rs/sasso-go`](https://github.com/momiji-rs/sasso-go) — **pure Go, no cgo**: embeds the [wasm build](#webassembly) and runs it with [`wazero`](https://github.com/tetratelabs/wazero), so `CGO_ENABLED=0` and cross-compilation just work. String-in/CSS-out (for file-based importers use the C ABI via cgo, [below](#from-go)) |
| **PHP** | [`shyim/php-sasso`](https://github.com/shyim/php-sasso) (PIE / pecl) | Community ([@shyim](https://github.com/shyim)) | an [ext-php-rs](https://github.com/davidcole1340/ext-php-rs) extension (`Sasso\Compiler`) wrapping this crate in-process; prebuilt for PHP 8.2–8.5 (Linux glibc/musl, macOS) |

**Ruby framework integrations** build on that gem — drop-in Sass for your stack,
compiled **in-process** (no Node, no Dart, no subprocess) and byte-for-byte
identical to dart-sass:

| Framework | Gem | Repo |
| --- | --- | --- |
| **Rails** (Propshaft + Sprockets) | [`sasso-rails`](https://rubygems.org/gems/sasso-rails) | [`momiji-rs/sasso-rails`](https://github.com/momiji-rs/sasso-rails) |
| **Bridgetown** | [`bridgetown-sasso`](https://rubygems.org/gems/bridgetown-sasso) | [`momiji-rs/bridgetown-sasso`](https://github.com/momiji-rs/bridgetown-sasso) |
| **Hanami** (2.1+) | [`hanami-sasso`](https://rubygems.org/gems/hanami-sasso) | [`momiji-rs/hanami-sasso`](https://github.com/momiji-rs/hanami-sasso) |

Each compiles Sass without a Node toolchain — typically ~6–7× faster per compile
than the Node `sass` default (and far faster cold, with no process spawn).

## C ABI — use sasso from any language

Beyond the packages above, sasso ships a **C ABI** ([`ffi/`](ffi/)) so any
language with a C FFI can drive the compiler in-process. Each
[release](https://github.com/momiji-rs/sasso/releases) attaches a per-target
**`sasso-<version>-<target>-c-api.tar.xz`** (`.zip` on Windows) containing the
prebuilt library and the header — the universal substrate every binding sits on:

```
include/sasso.h
lib/  libsasso.a            # static — link it for a self-contained binary, no runtime dep
      libsasso.so|.dylib    # dynamic (Windows: sasso.dll + sasso.dll.lib + sasso.lib)
```

The ABI is two owned calls plus an optional importer callback — see
[`ffi/include/sasso.h`](ffi/include/sasso.h), the contract notes there, and
runnable bindings for **8 languages** under
[`ffi/examples/`](ffi/examples/) (C, Go, Ruby, Swift, Deno, Bun, LuaJIT, C#).

### From Go

Statically link `libsasso.a` via cgo for a single self-contained binary
(no `CGO_ENABLED=0`, but no runtime dependency either):

```go
package main

/*
#cgo CFLAGS: -I./sasso-c-api/include
#cgo LDFLAGS: ./sasso-c-api/lib/libsasso.a
#include <stdlib.h>
#include "sasso.h"
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func main() {
	src := ".a { .b { color: #336699 } }"
	cs := C.CString(src)
	defer C.free(unsafe.Pointer(cs))
	r := C.sasso_compile(cs, C.size_t(len(src)), nil)
	defer C.sasso_result_free(r)
	if r.ok == 0 {
		panic(C.GoString(r.error))
	}
	fmt.Print(C.GoStringN(r.css, C.int(r.css_len)))
}
```

A fuller cgo binding — options, errors, and a custom importer — is in
[`ffi/examples/go/`](ffi/examples/go/). Prefer no cgo? The first-party
**[`sasso-go`](https://github.com/momiji-rs/sasso-go)** package is ready-made:
`go get` it and it embeds the [wasm build](#webassembly) and runs it with
[`wazero`](https://github.com/tetratelabs/wazero), keeping `CGO_ENABLED=0` and
trivial cross-compilation (string-in/CSS-out; use the cgo path above when you
need file-based importers). Or `dlopen` the dynamic lib at runtime with
[`purego`](https://github.com/ebitengine/purego).

## Testing & coverage

```console
$ cargo test                                  # unit + integration + doctests (offline)
$ SASSO_PARITY=1 cargo test --test parity # live diff vs dart-sass (needs `npx sass`)
$ cargo llvm-cov --workspace                  # coverage report
$ cargo clippy --all-targets -- -D warnings
$ cargo fmt --check
```

## Changelog

Notable changes are recorded in [`CHANGELOG.md`](CHANGELOG.md).

## Code of Conduct

As a Sass implementation, sasso adopts the
[Sass Community Guidelines](https://sass-lang.com/community-guidelines/) — see
[`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## License

Licensed under either of [Apache-2.0](LICENSE-APACHE) or [MIT](LICENSE-MIT)
at your option.

[`Importer`]: https://docs.rs/sasso
[`FsImporter`]: https://docs.rs/sasso
