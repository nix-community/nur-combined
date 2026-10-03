# Changelog

All notable changes to **sasso** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Conformance is tracked separately as a ratchet against the official
[sass-spec](https://github.com/sass/sass-spec) suite — see the
[Conformance](README.md#conformance) section for the current pass rate.

## [Unreleased]

### Performance

- **`map.get` and `map.has-key` no longer copy the map they read.** Each call
  copied every entry of the map before looking one up, so a lookup cost the
  size of the map. A design system that reads its large configuration maps on
  nearly every rule paid that each time. They now read the map in place, and
  so do `map.keys`, `map.values`, and `length` and `nth` on a map. On a
  200-entry map, a `map.get` went from 45,805 to 11,041 instructions and a
  `length` from 36,357 to 1,608. Marginal instructions on Linux/x86_64, output
  byte-identical:

  ```
                                  before     now        change
    uswds                         3447.7M    3004.0M    -12.88%
    module_calls.scss             26.67M     25.44M     -4.62%
    govuk-frontend                192.2M     186.3M     -3.07%
    vuetify                       316.4M     306.7M     -3.05%
    bulma                         1874.2M    1826.2M    -2.57%
    bootstrap                     808.2M     797.1M     -1.36%
  ```

- **`@extend` across many modules hashes with FxHash, not SipHash.** When
  extensions span modules, sasso tracks which module loads which, and in what
  order, to merge their extension stores the way dart does. The sets and maps
  doing that are keyed by each module's full URL, and they used Rust's default
  hasher, SipHash, which is built to resist hash flooding and is slow on long
  keys. They now use the FxHash the rest of the evaluator uses. Only the hash
  changes, and none of these tables is read in an order that reaches the
  output. Marginal instructions on Linux/x86_64, output byte-identical:

  ```
                                  before     now        change
    extend_modules (new corpus)   69.2M      43.5M      -37.1%
    chirpy                        109.7M     88.7M      -19.11%
    govuk-frontend                186.3M     168.2M     -9.70%
    uswds                         3004.0M    2754.5M    -8.30%
    bulma                         1826.2M    1811.6M    -0.80%
  ```

  `bench/corpus/gate/extend_modules/` is new: the existing `@extend` corpus is
  a single file, and the multi-file one has no `@extend`.

- **A call no longer scans a `@use … as *` module that lacks it, when the
  module's names are all spelled with `-`.** A function or mixin called
  without a namespace is looked up in each module `@use`d `as *`, built-ins
  included, and each module that lacked the name was scanned name by name in
  case one was spelled with `_`. Names are stored with `-`, so for such a module
  one lookup now gives the same answer, as variable lookup already does (#273).
  A module whose names keep a `_`, such as one forwarded `as p_*`, still scans.
  With three starred modules of 80 functions each, a call to `abs()` went from
  33,915 to 4,197 instructions. Marginal instructions on
  Linux/x86_64, output byte-identical: govuk-frontend −0.88%, uswds −0.72%.

## [0.21.0] - 2026-10-02

_A faster npm CLI, and a way around node for the tools that spawn it. One
entry through the npm CLI on the native addon is 24–31% faster (#274). The
release binary now ships in each platform package, and `"sasso/binary"`
returns its path: 4.3 ms for the same entry, against 38.3 ms through node
(#275). A variable reached through `@use … as *` no longer scans every module
it misses in, which takes 41% of uswds's instructions (#273). Output is
byte-identical to 0.20.0._

### Added

- **`"sasso/binary"`: the native `sasso` binary ships in the npm package**
  (#272). Each prebuilt platform package (`sasso-native-<target>`) now carries
  the release's command-line binary beside the addon, byte-identical to the
  one on the Releases page, and `binaryPath()` returns its absolute path. It
  returns `null` where there is no prebuild (Windows, musl) or optional
  dependencies were skipped, and it throws, as `"sasso/native"` does, when
  the binary it would return is from another version. It is for tools that
  spawn the compiler, and for those it removes node from the run. One entry
  of a real-world project, Linux/x86_64:
  38.3 ms through `node_modules/.bin/sasso`, 4.3 ms through the binary, 20.7 ms
  for dart-sass. Nothing uses the binary unless asked. `.bin/sasso` stays the
  node CLI, and there is no install script: npm 12, pnpm 12 and yarn 4 skip
  dependency install scripts by default, and pnpm 12 fails the install over
  one. Each platform package's tarball grows by 1.2–1.4 MB (darwin-arm64: 1.45
  → 2.62 MB).

### Performance

- **The npm CLI compiles a single entry 24–31% faster on the native addon**
  (#272). A build watcher that spawns the CLI on every save compiles one
  entry each time, and most of that run went to loading code the command
  line never used. It loaded the whole JS API (importers, the Value classes,
  the wasm loader) to reach the addon, and it imported `node:fs` through
  ESM, whose export facade loads node's stream stack. It also loaded
  `node:child_process` and `node:worker_threads` with nothing to spawn, and
  on Linux it checked glibc by building the full diagnostic report three
  times. The CLI now loads the addon core and what a command line uses. One
  entry of a real-world project, run through a pnpm `.bin` shim, on
  Linux/x86_64, medians of 60 interleaved runs:

  ```
                                             0.20.0     now        change
    --embed-sources                          51.3 ms    39.0 ms    -24.1%
    --style=compressed --no-source-map       49.6 ms    34.4 ms    -30.7%
  ```

  The second row is faster partly because it writes no source map: only
  `--embed-sources` still triggers one young-generation GC (3.4 ms).

  148 entries in one process: −5.4% (196.2 → 185.6 ms). On macOS/arm64, which
  never paid the Linux glibc check, one entry is −6.6%. The wasm engine and the
  hand-off to a binary on `PATH` are within 3%. Output, stderr and exit codes
  are byte-identical to 0.20.0 on every engine.

- **A variable reached through `@use … as *` no longer scans every module it
  misses in.** A variable written without a namespace is looked up in each
  module `@use`d `as *`, in order, and in each module's forwarded members, until
  one has it. `-` and `_` are one character in a variable name, so a miss
  compared the name against every variable the module had, one by one, in case
  one was spelled the other way. The parser already writes every variable name
  with `-`, so when none of a module's names contains `_` (nearly always), one
  lookup now gives the same answer. A design system whose packages each
  star-load a large shared core pays for that on every reference. uswds spent
  a third of its compile there. Marginal instructions on Linux/x86_64, output
  byte-identical:

  ```
                                  before     now        change
    uswds                         5840.9M    3447.7M    -40.97%
    star_forward (new corpus)     186.3M     17.5M      -90.6%
    govuk-frontend                193.0M     192.2M     -0.38%
  ```

  `bench/corpus/gate/star_forward/` is new: no corpus reached this path
  before.

## [0.20.0] - 2026-10-02

_Faster, and nothing else changes: output and diagnostics are byte-identical
to 0.19.3 on every project and corpus measured, and sass-spec scores the
same, stderr included. A call to a built-in or to a user `@function` or `@mixin` does much
less work per call, and that is most of a compile for a framework built on
them. Against 0.19.3, in instructions on Linux/x86_64: vuetify -24%, bulma
-21%, govuk-frontend and minimal-mistakes -11%, bootstrap -8%, uswds -7%,
and `large.scss` -10%. The argument checks 0.19.1 added to every built-in
call (#260) no longer cost what they did._

### Performance

- **Built-in calls cost about what they did before 0.19.1 again** (#260).
  0.19.1 began checking every built-in call against dart's declaration (#62),
  and 0.19.2 added the passed-twice rule (#147). No output changed, but a
  stylesheet heavy in built-in calls ran 6–8% more instructions. Three
  things did most of the work, and they still do the same checks. Each call
  used to walk all seven module tables to find its declaration; that is now
  a lookup in an index built once per process. A call with no named argument
  now checks two counts instead of running the full four-rule verification.
  And whether a function takes a rest parameter is decided when the table is
  built, not by a suffix test on every call. Marginal instructions on
  Linux/x86_64, output byte-identical:

  ```
                                  0.19.3     now        change
    large.scss, expanded          104.15M    99.19M     -4.77%
    large.scss, compressed        117.36M   112.40M     -4.23%
    legacy_deprecations.scss      131.27M   123.45M     -5.96%
  ```

  With the checks switched off entirely, `large.scss` would run 97.30M. What
  is left, about 1.9M, is the lookup itself: roughly 180 instructions for each
  of the ~10,400 built-in calls `large.scss` makes.
- **A built-in called by namespace is verified once, not twice** (#260).
  `color.adjust(…)`, `map.get(…)` and every other module call that has a
  global spelling was checked against its declaration, then handed to the
  global path, which looked the function up again and checked the same row a
  second time. It now goes straight to the dispatch. The evaluator's
  is-this-a-built-in test, asked on every global call, now uses the same
  index instead of walking every family's name list. Marginal instructions on
  Linux/x86_64, output byte-identical:

  ```
                                  before     now        change
    module_calls.scss (new)       28.74M     27.60M     -3.96%
    legacy_deprecations.scss      123.35M    121.63M    -1.40%
    large.scss, expanded          99.17M     98.86M     -0.31%
  ```

  Per call, a global whose name came late in the old scan saves the most
  (`nth` −324, plain-CSS `foo()` −334), and a module call saves 135–184.
  `large.scss` moves least because most of its calls (`percentage`,
  `lighten`) were found early. `bench/corpus/gate/module_calls.scss` is new:
  until now no benchmark called a module function other than `math.div`,
  which returns before this path.
- **Repeating a deprecated global call costs half what it did.** dart
  reports a `[global-builtin]` warning once per place, so sasso remembers
  every call site it has already warned about and skips the rest. Checking
  that memo was itself about 290 instructions a call. It hashed the whole
  file URL and compared it as text, for a question that takes no arguments.
  That question now has a memo of its own, keyed by a small per-file id, and
  costs about 145. Which warnings print is unchanged, byte for byte. Marginal
  instructions on Linux/x86_64:

  ```
                                  before     now        change
    legacy_deprecations.scss      121.53M    119.11M    -1.99%
    large.scss, expanded          98.87M     98.23M     -0.65%
  ```
- **A user `@function` or `@mixin` call no longer copies its `@use` tables
  or its stack-frame name** (#260's analysis). Each call used to clone the
  `@use` tables its callable captured, four of them, every entry copied.
  That made a call ~140 instructions dearer for each module in scope. Each
  call also formatted its `name()` for the diagnostics stack and copied the
  file's url there. The tables are now shared and copied only when a `@use`
  changes them. A function's frame name is made once per definition, an
  `@include`'s once when it is parsed, and the url is shared between frames.
  The five scope chains a call runs against are the next entry. A call to a one-argument function went
  from 4,904 to 4,091 instructions, the same with six modules in scope as
  with none, and an `@include` from 4,401 to 3,590. Errors and warnings print
  byte for byte as before. Marginal instructions on Linux/x86_64:

  ```
                                  before     now        change
    user_functions.scss (new)     27.26M     23.34M     -14.38%
    bulma                         2141.2M    1990.4M    -7.04%
    govuk-frontend                207.0M     199.6M     -3.58%
    vuetify                       350.3M     342.0M     -2.37%
    uswds                         6096.7M    5968.4M    -2.10%
    minimal-mistakes              172.1M     169.3M     -1.64%
  ```

  The last five are pinned real-world projects from `bench/real-world`, with
  output byte-identical before and after. `bench/corpus/gate/user_functions.scss`
  is new: no benchmark defined a `@function` until now.
- **A user call reuses its scope-chain buffers.** Running a `@function` or
  `@mixin` body means swapping in the five scope chains the callable
  captured. Each call cloned them into fresh `Vec`s and freed them on the
  way out, though each usually holds a single entry: four allocations and
  four frees a call, five of each with a source map (the span chain is
  empty without one, and an empty `Vec` allocates nothing). The callee now
  copies the entries into buffers it takes from a pool, one set per call
  depth, and clears them when it returns. They are the same entries,
  dropped at the same moment, without the allocator. A one-argument
  call went from 4,091 to 3,300 instructions, a function calling a function
  from 7,148 to 5,563, and an `@include` from 3,590 to 2,799. Marginal
  instructions on Linux/x86_64, output byte-identical:

  ```
                                  before     now        change
    user_functions.scss           23.34M     21.49M     -7.93%
    bulma                         1990.4M    1932.2M    -2.92%
    vuetify                       342.0M     335.3M     -1.96%
    govuk-frontend                199.6M     196.1M     -1.76%
    minimal-mistakes              169.3M     166.7M     -1.55%
    uswds                         5968.8M    5905.6M    -1.06%
    large.scss                    97.87M     97.35M     -0.53%
  ```

  The six places a user callable can run (a call, two mixin paths, a mixin
  reference, `meta.call`, a module function) shared one swap, written out
  six times. It is one `enter_callable` / `leave_callable` pair now, which
  is what let this change be made once.
- **A global built-in call asks its name-only questions once per call site.**
  Before it dispatched, every call to a global function ran a series of
  string tests on its name, about fifteen of them: is it `if`, `calc`,
  `clamp`, `round`, `min`/`max`, a calculation, a private name, a `sass:meta`
  global, a built-in at all, deprecated in favour of what, and so on. None of
  those answers can change between two evaluations of the same call. They now
  live on the call's AST node, worked out on its first evaluation
  (`CallFacts`), and every later evaluation reads them. A call site that
  never runs costs nothing. Per call, a global built-in saves ~530–690
  instructions (`nth($l, 1)` went from 3,534 to 2,877). Marginal instructions
  on Linux/x86_64, output byte-identical:

  ```
                                  before     now        change
    legacy_deprecations.scss      117.19M    108.92M    -7.06%
    large.scss, expanded          97.36M     94.32M     -3.12%
    minimal-mistakes              166.7M     161.9M     -2.87%
    bootstrap                     839.1M     820.6M     -2.20%
    forem                         308.0M     304.5M     -1.13%
    bulma                         1932.2M    1911.9M    -1.05%
  ```

  An earlier version computed the facts in the parser. That made a call that
  runs once, or never, pay for all fifteen answers, and it made mastodon
  0.3% slower. The lazy version is no slower than before on any project
  measured.
- **A built-in call skips the families that cannot answer it.** A built-in is
  dispatched down a chain of eight families (colour, the colour extras, math,
  string, map, list, meta, selector). Each one compares the name against its
  own list and passes the call on, so a call to `nth` was turned down five
  times before the list family took it. Each call site now records where in
  the chain its name can first be claimed, and it also records the
  declaration a global call is verified against, so neither is looked up
  again. Namespaced calls get the same skip from the member index they
  already consult. Per call, a global built-in saves 100–510 instructions
  (`nth($l, 1)` went from 2,876 to 2,457) and a namespaced one 120–330
  (`list.nth` from 2,721 to 2,393). Marginal instructions on Linux/x86_64,
  output byte-identical:

  ```
                                  before     now        change
    vuetify                       334.0M     316.4M     -5.28%
    module_calls.scss             27.47M     26.67M     -2.91%
    legacy_deprecations.scss      109.07M    106.16M    -2.67%
    bulma                         1911.9M    1874.2M    -1.98%
    minimal-mistakes              161.9M     159.0M     -1.78%
    bootstrap                     820.6M     808.3M     -1.50%
    govuk-frontend                195.5M     193.0M     -1.32%
    large.scss                    94.31M     93.62M     -0.73%
  ```

## [0.19.3] - 2026-09-30

_More of a selector survives as written. sasso used to treat NBSP and the
other Unicode spaces as whitespace, and it no longer does, in a selector (#71)
or anywhere else (#237). Whitespace inside a quoted attribute value is kept as
well. Selectors, attribute selectors and keyframe stops now follow dart's
grammar (#238). Input that dart rejects, such as `a^b`, `[a=1]` or a keyframe
block named `foo`, used to compile and may now fail. A type error names the
parameter and writes the value the way dart does (#139). The flake's package
no longer runs the test suite, so a devenv or flake input builds sasso in
about a fifth of the time._

### Changed

- **The flake's `sasso` package no longer runs the test suite when it is
  built.** Nothing serves the flake from a binary cache, so every consumer
  builds sasso from source. With the tests on, most of that build was
  `checkPhase` recompiling every test target under the release profile. On a
  4-core Linux/x86_64 builder the build took 43 s instead of 201 s. This is
  the package that `packages.{sasso,default}` and `overlays.default` give, and
  that a devenv or flake input pulls in. The suite still runs where it belongs:
  `checks.sasso` and `nur.nix` build `nix/package.nix` unchanged, and
  `nix flake check` builds `checks.sasso`.

### Fixed

- **A non-ASCII space in a selector is kept, not turned into a plain space**
  (#71). CSS whitespace is space, tab, LF, CR and form feed; the selector
  normalizer used Rust's `char::is_whitespace()`, which also matches NBSP and
  the other Unicode spaces, and rewrote them to U+0020. So a rule written to
  match `x&nbsp;y` silently matched `x y`:

  ```
    [a="x\u{a0}y"]   dart  [a=x\u{a0}y]   (and @charset "UTF-8")
                     sasso [a="x y"]
    a\u{a0}b         dart  a\u{a0}b       one type selector
                     sasso a b            a descendant combinator
  ```

  An unquoted attribute value had the same flaw one step later: it stopped at
  the NBSP and read the rest as a modifier, so `[a=x\u{a0}y]` became `[a=x y]`
  — which is also what a quoted value turned into once it had lost its quotes
  and was re-parsed, as a parent selector or by `@extend`.

  A hex escape made it worse: its one delimiter must be CSS whitespace, but an
  NBSP was accepted as the delimiter and so deleted — `\61\u{a0}b` came out
  `ab`, and `.a\9\u{a0}b` lost its NBSP. Compressed output dropped one beside
  a combinator as if it were the space around it (`.a > \u{a0}b` → `.a>b`).

  The selector parser that nesting, `@extend` and the `selector` functions
  share trimmed and split with `str::trim`, so an NBSP at the edge of a
  compound was deleted there too: `:is(\u{a0}b)` came out `:is(b)`,
  `selector.append(".a", "\u{a0}.c")` gave `.a.c` for dart's `.a\u{a0}.c`,
  and `:nth-child(2n \u{a0}+ 1)` compiled to `2n+1` where dart rejects it.
  The attribute validator was the mirror image: it rejected the valid
  `[a=x\u{a0}yz]` (reading `yz` as a modifier) and accepted the invalid
  `[a="x"\u{a0}]`. And `&` in SassScript split its compounds at an NBSP:
  `list.length(list.nth(&, 1))` was 2 for `.a\u{a0}b`, and `x: &` printed
  `.a b`.

- **A paren or bracket inside a quoted attribute value no longer swallows the
  rest of the selector list.** The top-level comma splitter did not skip
  strings, so after `[a="("]` every following comma looked nested: `[a="("],
  b { &.c {} }` produced `[a="("], b.c`, and `@extend` from that rule failed
  with "The target selector was not found". A pseudo argument's list had the
  same flaw: `selector.is-superselector(':is([a="("], b)', "b")` was false.

- **Whitespace inside a quoted string in a selector is kept.** The
  normalizer collapsed it like the whitespace between compounds, so
  `[a="x   y"]` came out `[a="x y"]` and `[a="x\ty"]` lost its tab — a
  different string, matching different elements.

- **`&` in SassScript splits a selector only between its compounds.** It cut
  at every space, so one inside a string, an attribute or a pseudo argument
  split a compound: `list.nth(list.nth(&, 1), 1)` of `:not(.a .b) .c` was
  `:not(.a`, and `list.length` of `.a\ b .c`'s first complex was 3, not 2.

- **Compressed output drops the space before a quoted attribute value's
  modifier**, as dart does: `[a="x y" i]` is `[a="x y"i]`. After an unquoted
  value the space stays (`[a=x i]`).

- **A missing attribute operator gets dart's message.** `[a b]` failed with
  `expected "]".`; dart says `Expected "]".` when no operator follows the
  name, and `expected "=".` for `[a~b]`, where only an operator's first
  character does.

- **A non-ASCII space outside a selector is kept too** (#237). The
  statement and value parser skipped NBSP and the other Unicode spaces as
  whitespace, so one was dropped before a rule, after a `:`, inside an
  argument list, a media query or an interpolation. dart-sass reads it as a
  name character: `c:\u{a0}d` is the value `\u{a0}d`, `1 ==\u{a0}1` is
  false, and `rgba(0,\u{a0}0, 0, 0.5)` is an error. An unknown at-rule's
  prelude keeps a leading or trailing one (`@foo bar\u{a0};`). So does the
  evaluator's resolved text: an NBSP at the edge of an interpolated selector
  or property name, an `@at-root` query, an `if()` condition, an
  interpolated media query, or a plain-CSS at-rule prelude or `@keyframes`
  name is no longer dropped or read as a separator.

- **A unit may be non-ASCII.** `1µs` was the list `1 µs`, and `math.unit(1é)`
  an error; a unit, like any name, may begin with any non-ASCII character,
  so both are one number, as in dart. The same rule makes `1 -\u{a0}2` the
  list `1 -\u{a0}2` rather than a subtraction.

- **A newline anywhere in a complex selector breaks the next one's line.**
  dart compares line numbers, so `a\nb, c` puts `c` on its own line, as
  `a,\nc` does; sasso only looked at the whitespace beside the comma. Inside
  a style rule, `@mixin`, a content block or an unknown at-rule, dart first
  rewrites the whitespace after a leading identifier as one space, so there
  `.p { a\nb, c {…} }` stays `.p a b, .p c`, and sasso now does the same.

- **An NBSP at the edge of an `@extend` target is part of it** (#238).
  `@extend .a\u{a0}` extended `.a`; it now fails as dart's does, with "The
  target selector was not found.", and `.a \u{a0}` and `\u{a0}.a` are the
  complex and compound selectors they are.

- **A keyframe selector is parsed as stops** (#238). A block inside
  `@keyframes` may be named `from`, `to` (in any case, escaped or not) or a
  percentage, in a comma list, and nothing else. sasso passed anything through
  — `foo`, `10px`, `10% 20%`, `from,` and an NBSP beside `from` all compiled —
  and ran the CSS selector checks on the stops instead, which rejected the
  valid `.5%` with "Expected identifier.". Each now fails with dart's message,
  in a plain CSS module too, and `\74o` and `1E1%` come out `to` and `1e1%`.

- **An unescaped line break ends no quoted string** (#238). A raw LF, CR or
  form feed inside quotes is dart's `Expected "<quote>".` wherever the string
  is; the value parser already said so, but the readers that copy a string
  verbatim let it through. `[a="x` + newline + `y"]` compiled to
  `[a="x\ay"]`, and a custom property value, an unknown at-rule's prelude, an
  `@supports (--a: …)` declaration, a plain CSS `@function` body and
  `expression()` kept the raw line break. A `\` line continuation is still
  dropped.

- **An attribute selector follows dart's grammar** (#238). Its name and its
  unquoted value are identifiers, an optional namespace comes before a `|`,
  and only a single-letter modifier may follow the value. sasso took any
  characters: `[]`, `[@a=b]`, `[a=1]`, `[a==b]`, `[*a]` and `[a=b$]` all
  compiled. Each now fails with dart's message: "Expected identifier.",
  `expected "|".` or `expected "]".`.

- **A character that starts no selector is an error** (#238). A C0 control
  character other than CSS whitespace (the vertical tab from #238 among
  them), DEL, a quote, and `` $ ^ ` ? < = / `` compiled in a selector:
  `a^b`, `:is(a$b)`, `a"b"`. A quoted string is only a selector's part
  inside an attribute value or an unknown pseudo's argument. dart's message depends on where the character is:
  "expected selector." at the top level, and `expected ")".` inside `:is()`
  and the other selector pseudos, unless nothing comes before it there.
  sasso now gives the same messages, in plain CSS, in `@extend` and in the
  selector functions too. `@` was already an error, but it now gets the
  same messages, and `:x(a@b)`, an unknown pseudo whose argument dart does
  not parse as a selector, compiles.

- **A form feed separates compound selectors.** Like a space, it starts a
  new compound, so `a { b` + form feed + `& { … } }` compiles to `b a` and
  `selector.nest("a", "b\c &")` returns `b a`, where both said `"&" may only
  used at the beginning of a compound selector.`. In plain CSS, a
  placeholder after a form feed is now dart's `Placeholder selectors aren't
  allowed in plain CSS.`

- **A pseudo's name is read with its escapes.** dart decodes the name before
  it picks the argument's grammar, so `:\78(a$b)` is the unknown `:x(a$b)`,
  whose argument is a declaration value, and `:\69s(a$b)` is `:is(a$b)`,
  whose argument must be a selector. sasso scanned the raw name: the first
  was "expected selector." and the second got the wrong message. `:\78 (a)`
  now opens an argument list too, as the escape's delimiter is not a space.

- **After a quoted string, a `-` before any name start begins a new term.**
  A name start is any code point from U+0080 up, or an escape, so
  `"q"-\u{a0}x` is the list `"q" -\u{a0}x` and `"q"-\78` is `"q" -x`,
  where both were read as a subtraction.

- **An interpolated media condition may not mix `and` and `or`.**
  `@media #{"(a) and (b) or (c)"}` compiled to `(a) or (b) or (c)`; it is an
  error, as it is when written out. A word other than the first operator now
  gets dart's "expected no more input.", `and(b)` needs its whitespace, and
  `and foo` asks for a condition in parentheses.

- **A type error names the parameter the value was bound to, and spells the
  value dart's way** (#139). Two helpers carried no parameter name at all, so
  the sentence started mid-air; and four separate copies of "how a diagnostic
  writes a value" disagreed with dart and with each other:

  ```
    color.grayscale(null)          dart  $color: null is not a color.
                                   sasso  is not a color.
    math.round((1 2))              dart  $number: (1 2) is not a number.
                                   sasso 1 2 is not a number.
    string.index("abc" "b", "x")   dart  $string: ("abc" "b") is not a string.
                                   sasso $string: "abc" "b" is not a string.
    @for $i from "x" through 3     dart  "x" is not a number.
                                   sasso string is not a number.
  ```

  The prefix names the **parameter**, which is not always the one the sentence
  goes on to talk about. One channels list binds `$channels` and everything
  inside it is reported under that name; the same values written out bind
  `$alpha`; `color()`'s binds `$description`; and `color.hwb`'s comma form binds
  none of them, because that channels list is synthesized rather than received:

  ```
    rgb(1, 2, 3, "x")           $alpha: "x" is not a number.
    rgb(1 2 3 / "x")            $channels: "x" is not a number.
    color(srgb 1 2 3 / "x")     $description: "x" is not a number.
    color.hwb(1, 2%, 3%, "x")   "x" is not a number.
  ```

  Where dart has no parameter to name — a value out of a rest list —
  it prints no prefix, so the name is an `Option` a caller has to decide rather
  than a string it can forget: `math.max(1, "x")` stays unprefixed.

  `Expected <n> to have no units.` is the same assertion and was missing the
  same prefix (`math.pow(1, 2px)` is `$exponent: …`), and `adjust-hue`, whose
  module spelling was removed so only the global reaches it, named nothing at
  all. Going the other way, dart is not uniform about `<n> is not an int.`:
  `string.insert` and `list.nth` name their parameter and `string.slice` does
  not, from the same rule reached two ways. sasso shared one helper across all
  three, so it could only ever match two of them.

  The spelling is `Value::to_inspect_message`, which already existed and whose
  doc already claimed every message read from it. It had four callers.
  Diagnostics wrote CSS instead, and three colour helpers (`channel_err_css`,
  `list_paren_css`, `color_desc_css`) plus four hand-written
  bracketed/unbracketed branches held copies of the rule, each wrong in a shape
  it had never been measured in — `null` and `()` printed as nothing at all, and
  a one-element list lost its parentheses. `@for`'s bounds were the rule's
  absence rather than a copy — they printed the value's TYPE NAME. All the copies
  are gone and the helper has 73 call sites where it had 4 (`grep -o` over `src/`,
  against `7045759`; `to_css(false)` falls 298 -> 232 the same way), so the claim
  in the doc is now true;
  the one that survives is filed (#234), because dart writes no value in that
  sentence at all and the fix deletes the helper rather than correcting it.

  Found by the same sweep and filed rather than fixed, each a different rule:
  seven `sass:map` members end the sentence with a `` for `<function>` ``
  suffix dart never writes (#230); `color.to-gamut` checks its `$method` enum
  before checking the type (#231); `invert(1, "x")` answers with the plain-CSS
  overload's arity message where dart reports the `$weight` type error (#232);
  a keyword splat with a non-string key writes the wrong sentence, from two more
  copies of one rule (#233); and two calculation diagnostics carry an older dart
  wording, again from two copies each (#234). The value inside #233 is right now
  — it is the sentence around it that is not. A sixth is not a message at all:
  `string.split` rejects a unit on `$limit` that dart ignores outright (#235), so
  a stylesheet dart compiles fails, and the unit check hides the two errors that
  should have fired in its place.

  Measured against dart-sass 1.104.1 over 336 comparisons, and on sass-spec with
  `--check-stderr --stderr-arg=--no-unicode`: **67 more cases** print dart's
  stderr byte for byte (1,269 -> 1,336 of the 3,250 that ship an expectation),
  none regress, and no CSS verdict moves — every one of these is an error path,
  so the ratchet stays at 14,114.

## [0.19.2] - 2026-09-29

_Faster again through the npm package, on the paths 0.19.1 missed. The wasm
engine stops throwing an error for every file it probes and does not find
(#227), which takes a full Lichess build on it from 631 ms to 498 ms. The CLI
stops loading its `--watch` modules on every run (#228), so handing one file
to a `sasso` binary costs what it did in 0.18.0 again. An argument given both
positionally and by name is now an error, as it is in dart-sass (#147): a
stylesheet that did that used to compile, and may now fail._

### Fixed

- **An argument given both positionally and by name is an error** (#147).
  dart's first argument rule, which sasso had nowhere: a built-in let the
  positional win and compiled, and a user callable rejected the call with the
  wrong sentence — naming a real parameter as one that does not exist.

  ```
    color.mix(red, blue, 10%, $color1: green)   dart  Argument $color1 was passed both by position and by name.
                                               sasso rgb(10%, 0%, 90%)
    f(1, $a: 2)   @function f($a, $b: 2)       dart  Argument $a was passed both by position and by name.
                                               sasso No parameter named $a.
  ```

  One `argument_passed_twice`, called from both the built-in verifier and the
  user-callable binder, so the two cannot drift. It outranks every other
  argument error, measured: `list.nth(1 2 3, $list: 4)` reports the duplicate
  although `$n` is missing too, `list.nth(1, 2, 3, $list: 4)` reports it rather
  than the overflow, and `list.nth(1 2 3, 1, $list: 4, $nope: 5)` rather than
  the unrecognized name.

  Three details a plausible implementation gets wrong, each with a case: there
  is **no plural** (`f(1, 2, 3, $a: 9, $b: 9, $c: 9)` names `$a` alone, where
  the unrecognized-name rule would have said `$a, $b or $c`); the parameter
  reported is the first in **declaration** order, not in the order the names
  were written; and the comparison canonicalizes the argument while the message
  quotes the parameter, so `$start_at` is reported against `$start-at`.

  It also corrected an offline test that had pinned sasso's own answer rather
  than dart's: `f(1, 2, 3, $y: 4)` was asserted to report the positional
  overflow. It cannot — an overflow means every parameter was filled
  positionally, which makes naming one of them a duplicate.

  Not fixed here, both measured and filed: a user callable's rest parameter
  still accepts an unrecognized name, because dart decides that by whether the
  body READ the keywords at runtime (#225); and a parameter declared `$a_b` is
  still quoted back as `$a-b`, because the parser normalizes it before any
  message exists (#224).

### Performance

- **npm, wasm engine:** resolving an `@use`/`@import` no longer throws an
  error for every candidate file that is not there. Most probes miss (about 850
  of the 980 made by Lichess's heaviest entry point), and building an ENOENT
  error for each was a quarter of the compile. That entry point compiles in
  about 100 ms instead of 134 ms on Linux/x86_64. The native engine and the
  binary resolve in Rust and are unaffected.
- **npm CLI:** starting up is back to 0.18.0's cost. 0.19.x loaded the six
  `--watch` modules and the whole importer on every run, including one that
  only hands its command line to a `sasso` binary on PATH. They now load only
  where they are used. Handing one small entry point to the binary takes
  33.6 ms instead of 38.5 ms on Linux/x86_64 (0.18.0: 33.0 ms).

## [0.19.1] - 2026-09-28

_Faster builds through the npm package: on Lichess's 148 entry points on
Linux/x86_64, a full build takes about half as long as under 0.18.0, with
byte-identical output. `@extend` stops comparing module paths per rule
(#219), and the npm CLI compiles a batch on the native addon's own threads
instead of a pool of Node workers (#221). Built-ins now reject an argument name
they do not declare, as dart-sass does (#62): a stylesheet that passed one
used to compile, and may now fail._

### Fixed

- **A built-in rejects an argument name it does not declare** (#62).
  `string.to-upper-case("a", $nope: 1)` compiled, and so did `math.abs`,
  `map.get`, `color.red` and most of the rest: nothing read the argument, so
  nothing noticed it. Worse for the variadic ones, which used its VALUE — the
  named argument silently became an argument and changed the answer:

  ```
    math.max(1, 2, $x: 999)    dart  Error: No parameter named $x.    sasso  999
    math.min(5, 4, $x: -7)     dart  Error                           sasso  -7
    math.hypot(3, 4, $x: 12)   dart  Error                           sasso  13
  ```

  `hypot(3, 4, 12)` is `sqrt(9 + 16 + 144)`, so the value really was in the
  computation, and nothing warned.

  Every member now carries dart's own parameter declaration, read from what
  dart prints under an argument error, and the checks run in dart's order:

  ```
    1. Missing argument $x.
    2. Only N positional arguments allowed, but M were passed.
    3. No parameter named $x. / No parameters named $x, $y or $z.
  ```

  The order matters more than the missing check did: 105 of the 116 members
  answer `f($nope: 1)` with `Missing argument $X.`, not with the unrecognized
  name, so raising the name first would have been wrong far more often than it
  was right. `list.nth` was the one built-in that already answered, from a copy
  of the rule in `list.rs` that had exactly that backwards — and a third copy of
  "Only N argument(s) allowed" went with it.

  A REST parameter is checked in two halves, because dart binds the rest, runs
  the body, and only then complains about a name the body did not consume:

  ```
    math.max($x: 1)          At least one argument must be passed.   the body
    list.slash(1, $x: 2)     At least two elements are required.
    math.max(1, 2, $x: 3)    No parameter named $x.                  the leftover
  ```

  `color.adjust`/`change`/`scale`, `map.merge`/`set` and `meta.call` are
  excluded: keywords are their interface (`color.adjust(red, $lightness: 10%)`).
  dart decides that at runtime by whether the body read them, which `map.set`
  shows — it reads them in the `$key`/`$value` form and not in the positional
  one — so those two still differ from dart by one message where dart's own body
  would have complained instead.

  `sass:color`'s `hwb` and `alpha` verify nothing, both measured: `hwb` is
  overloaded by arity with different parameter names, and `alpha` prints no
  declaration at all (dart answers `alpha(red, blue)` with the
  self-contradictory `Only 1 argument allowed, but 1 were passed.`).

  **The overloaded colour constructors are NOT covered** (#220), and that
  includes the shape #62 was opened with:

  ```
    rgb(1, 2, 3, $nope: 4)                          still returns the colour
    color.hwb($channels: (240 10% 20%), $nope: 2)   still returns the colour
  ```

  dart chooses an overload and then verifies against that one, so the same
  name is a parameter or not depending on its company —
  `rgb(1, 2, 3, $channels: 1)` is `No parameter named $channels.` while
  `rgb($red: 1, $green: 2, $blue: 3, $channels: 1)` is
  `No parameters named $red, $green or $blue.`. Guessing that rule would
  REJECT valid stylesheets, which is worse than the silence it replaces.

  Also not fixed here, each measured and filed: dart's fourth rule,
  `Argument $x was passed both by position and by name.` (#147, which sasso
  implements nowhere and which outranks all three); the CSS math functions,
  whose named-argument error is `Keyword arguments can't be used with
  calculations.` (#215) — the bare `sin(…)` is one of those, while
  `math.sin(…)` is verified here; and the deprecated global spellings, where
  `lighten` shares a name with a module-only member.

### Performance

- **`@extend` no longer compares module paths per rule.** On a codebase that
  spreads its `@extend`s over many modules, most of a compile went to comparing
  strings: every style rule checked each `@extend` batch's origin module against
  its own scope, and every `@extend` checked the origin of every extension
  registered before it — both on full module paths, which share long prefixes,
  so each comparison ran most of the way down the string. The first is now a
  flag resolved once per scope; the second asks about the handful of distinct
  origins in the store instead of every entry in it. Output is byte-identical.

  Measured on Lichess's `ui/` tree (148 entry points, about 1,500 `@extend`s in
  380 files) through the npm package's native engine on Linux/x86_64, the way
  its build script calls sasso: a full build is 27.5% faster in dev mode
  (source maps with embedded sources) and 31.6% faster in production mode
  (compressed), and recompiling its heaviest entry point alone, which bounds how
  soon a save in that area shows up, takes half the time. The binary compiles
  that entry point 2.7× faster.

- **The npm CLI compiles a batch on the native addon's own threads.** A
  parallel run used to start a pool of Node workers, and each one re-imported
  the CLI and the engine before compiling anything: 50–65 ms per worker, paid
  on every run. On the native engine the whole batch now goes to the addon in
  one call; it compiles on Rust threads and hands results back as they
  finish, so writing one file overlaps compiling the next. Warnings, errors
  and `--update` output are still printed in command-line order, and
  `--stop-on-error` stops claiming new files at the first failure. Source maps
  come back pre-serialised rather than rebuilt in JavaScript. On Lichess's 148
  entry points on Linux/x86_64, a full dev build (CSS plus source maps, 296
  files) drops from 265 to 182 ms and a production build from 240 to 170 ms;
  output is byte-identical. The wasm engine, stdin input and `-j 1` keep their old
  paths.

## [0.19.0] - 2026-09-28

_Watch mode on both front ends: the binary gains `--watch` and `--update`
(#86), and the npm CLI's `--watch` takes any number of pairs and compiles
large rounds on a worker pool (#200) — on Lichess's 147 entries, a save that
reaches 138 of them lands in about 350 ms on Linux. Compressed output now matches
dart-sass in fourteen more places, built-in modules list their members, and
the npm CLI exits with dart-sass's codes._

### Added

- **`nur.repos.momiji-rs.sasso` resolves** — the NUR registration
  ([nix-community/NUR#1229](https://github.com/nix-community/NUR/pull/1229))
  merged, so the `nix/nur.nix` entry point from #82 is now a channel anyone
  can name, not just us. It serves `sasso` and `sasso-ffi` from whatever
  `master` NUR last locked — normally re-locked daily, but a revision that
  fails NUR's evaluation is skipped, so it can trail longer. The top-level
  README now advertises it beside the flake.

- **`-w`/`--watch` in the binary** (#86), which closes the flag gap that made
  a `sass` build script work under `npm install sasso` and fail with the
  binary. It follows the entry and everything the entry loaded, re-resolving
  after every compile, and it keeps running through an error.

  **It polls, and that was the decision the issue asked for rather than a
  default.** Every native watcher — inotify, kqueue, `ReadDirectoryChangesW`
  — is a syscall this crate cannot make: `[dependencies]` is empty and stays
  empty, and `unsafe_code = "deny"` outside the Miri-verified arena rules out
  the FFI those APIs need. What `std` offers is `fs::metadata`, and asking it
  repeatedly is a watcher.

  Measured, it is not the slow option — it is the fast one. macOS, one
  settled save per process, twelve fresh processes, median:

  ```
    dart-sass 1.104.1   13196 ms   (its own native watcher)
    sasso binary           45 ms   (this poll)
    sasso npm CLI          34 ms   (fs.watch AND a poll beside it, #164)
  ```

  An earlier version of this entry reported 51/29/20 ms from *one save each*,
  which is not a measurement of a distribution whose tail runs to seconds.
  See #164: native filesystem events on macOS are the slow part, in dart and
  in node alike, and polling is what makes any of these three predictable.

  The interval is not a constant, because the cost is not: a sweep is about
  1.3 us per file, so 50 ms is free for ten files and 18% of a core for five
  thousand. It scales so the watcher spends at most 2% of its time asking,
  between a 50 ms floor and a 500 ms ceiling.

  **A save recompiles the entries that depend on it, and no others** (#198),
  which is dart's rule. The first cut recompiled and rewrote every entry on
  every save — invisible with one entry, and the dominant cost with many,
  because a build that wraps `--watch` post-processes per `Compiled` line and
  every output's mtime moved. Lichess's 147 entry points, their own flags,
  macOS/arm64, one save each:

  ```
                                               before         now
    save a partial 10 entries use:
      `Compiled` lines printed                   147           10
      outputs whose CSS changed                   10           10
      CPU spent on the save                   3.70 s       0.63 s
      edit-to-CSS, median of 8 (max)    685 (897) ms  118 (218) ms
    atomic save of one of the 56 entries
    sharing a directory, `Compiled` lines        147            1
  ```

  dart's own rule, measured with `--watch --poll` on three entries where
  `_x.scss` is used by one: it rewrites and narrates that one, and so does
  this now.

  A directory still counts — it is followed so a dependency that does not
  exist yet can arrive in it — but it calls for the entries that follow that
  directory, and only when what is IN it changed. An editor's atomic save
  (temp file, rename over the original) moves the directory's mtime with its
  names unchanged; the file it replaced reports that save under its own name.

  What it prints matches dart — one `[stamp] Compiled x to y.` per file
  actually written, `--quiet` suppressing the lines but not the banner, and
  the banner printed **after** the first compile, once every initial output
  is on disk (#199). The first cut printed it before, under a comment saying
  dart does the same; measured against dart-sass 1.104.1 with one entry, with
  147, and with a failing entry beside a good one, dart writes and narrates
  everything first. Tools wait on that line to mean "the initial build is
  done". dart's three usage refusals are refused with
  dart's wording and exit code: `--watch` to stdout, `--watch` with `--stdin`,
  and `--poll` without `--watch`. `--[no-]poll` still does nothing on the
  binary, which always polls; on the npm CLI it now chooses (#164).

  A burst of saves costs two compiles, not one per event: a provisional run
  at the head and an authoritative one behind it. A provisional FAILURE is
  silent and leaves the output alone, because the likeliest cause of one is
  a file still being written; a provisional SUCCESS writes, which is the
  whole latency win. Because that write can be wrong, the authoritative run
  is guaranteed — and `--update`'s freshness check is off for every run
  after the first, since otherwise the output it measures against is one
  this session just wrote. The same rule as the npm CLI's `_coalesce.mjs`,
  and tested the same way — against a clock the test supplies, because the
  spacing of real writes cannot be pinned on a loaded machine.

- **`--update` in the binary** (#86). It was npm-only, so a build script
  written for `sass` worked under `npm install sasso` and failed with the
  binary — the mirror image of #24. It walks the dependency graph like
  dart-sass and like the npm CLI, so a changed partial rebuilds and an
  unchanged output keeps its mtime.

  The flag-parity guard now checks **both** directions. It only ever asserted
  that the npm CLI accepts every native flag, which is how the binary fell two
  behind unnoticed; differences are now split into ones that will never cross
  and ones that are gaps, and a gap that has since been closed fails the build
  so the list cannot go stale. `--watch` was the second of the two, and the
  entry above closes it.

### Changed

- **CI checks that the published file list carries no benchmark** (#178).
  The bug that PR fixed — `exclude` dropping `/bench`, where the CodSpeed
  corpora live, but not `/benches`, where the target that reads them lives
  — shipped in eleven versions without anything noticing, because nothing
  builds a published bench: `cargo publish`'s verify step does not, and a
  consumer has no reason to. So the invariant is checked where it is
  cheap and visible instead, on the file list itself.

  ```
    manifest state                       cargo package --list   step
    /benches excluded (today)            239 files, no bench     passes
    /benches off the exclude list        benches/compile.rs      fails
    manifest does not parse              cargo exits 101         fails
  ```

  The third row is why the step assigns before it greps, with its own
  `|| exit 1`: piping `cargo` into `grep` would report a manifest that
  cannot be parsed as carrying no benchmark, and relying on the runner's
  default `bash -e` would make the abort conditional on that default.

- **One `file:` URL decoder instead of two** (#163). `src/pathstyle.rs`
  and `napi/src/lib.rs` each had their own, and the two had already
  drifted twice:

  ```
    file://localhost/a   napi accepted it, pathstyle declined   (fixed #161)
    file:///a%FFb        pathstyle decoded lossily, napi refused
  ```

  The first was a bug in one copy. The second is not — they want
  different answers, because one produces a path to SHOW and the other
  one to OPEN. So the structure is shared (`pathstyle::file_url_bytes`:
  the `file://` prefix, the empty and `localhost` authorities, percent
  escapes, a Windows drive letter arriving as `/C:/`, a UNC authority,
  which separator comes out) and the UTF-8 policy is stated at each edge
  rather than copied along with the rest.

  `sasso::file_url_to_path` is the new public half, strict because its
  caller is about to open the path. napi's copy is one line now.

  One layer up, three more places decided "is this canonical an absolute
  path" with a leading-`/` test or a hand-written list of spellings, and
  a UNC canonical matched none of them — it has no leading `/` and no
  colon:

  ```
    canonical                win32.isAbsolute  old JS  old Rust
    \\server\share\a.scss    true              false   false
    \\?\C:\w\a.scss          true              false   true
    C:\w\a.scss              true              true    true
    /w/a.scss                true              true    true
  ```

  A file reached through a share crossed the bridge as "no containing
  url", so every relative `@use` beside it fell through to the load
  paths instead of resolving next to its importer. All three ask the
  platform now — `Path::is_absolute` in Rust, `node:path`'s `isAbsolute`
  in JS — which is the question the core itself asked when it BUILT the
  canonical, so the answers cannot drift apart again. Windows-only, and
  there is no Windows prebuild of the addon yet (#172), so this is
  correctness ahead of reach rather than a fix anyone was hitting.

- **CI checks the MSRV** (#169). `Cargo.toml` promises `rust-version =
  "1.74"` and no job built against it; two APIs above it reached review
  in #166 before anyone noticed.

  `--lib --bins`, not `--all-targets`, and the reason is not a
  preference: a dev-dependency pulls in crates that need edition 2024, so
  the tests cannot build at 1.74 whatever they contain. The library and
  the binary are also exactly what the MSRV is a promise about — a
  consumer depends on `sasso`, not on its test suite.

  What it adds over the clippy job, measured by putting each back into
  `src/main.rs`:

  ```
    Option::is_none_or   (1.82, API)      clippy catches it, so does this
    File::set_modified   (1.75, API)      clippy catches it, so does this
    c"hello"             (1.77, SYNTAX)   only this
  ```

  Clippy's `incompatible_msrv` reads `rust-version` and knows the std
  APIs it has version data for. It does not know about syntax, so a
  literal, a language feature or an edition bump passes it and fails a
  real 1.74 build.

- **CI now scores compressed output against dart-sass, not only expanded.** The
  conformance ratchet has always run sass-spec's own expectations, and
  dart-sass generated every one of them in the default `expanded` style — the
  suite contains no compressed expectation anywhere, so a compressed-only
  serialization difference could never fail CI. A second ratchet
  (`spec/check_baseline.py --style compressed`) now scores against
  `spec/COMPRESSED_EXPECT.txt`: a committed manifest of per-case digests of the
  **compressed** CSS dart-sass 1.104.1 emits for the same 11,766 cases,
  generated by `spec/gen_compressed.py`. It needs neither node nor the network,
  and it refuses to run unless every one of the manifest's headers is present
  and agrees with the pins: the output style, the dart-sass version, the
  sass-spec commit, and a case count matching the body. It also refuses a run
  that scored fewer cases than the baseline records, or one where the manifest
  did not cover every case the run was eligible to score -- a case that stops
  being measured cannot be seen to fail.

  The first score is `spec/BASELINE_COMPRESSED.json`: 12,579 of 14,258
  attempted, against 14,107 for expanded. **1,528 cases compile to byte-exact
  expanded CSS and to wrong compressed CSS** — mostly number and unit
  shortening inside colour functions (a negative number keeps its leading zero;
  a redundant `%` or `deg` is kept where dart drops it). No output changes in
  this release; the divergences are now counted, and the count can only go up.

### Fixed

- **`--watch` in the npm CLI takes any number of pairs** (#200). dart-sass
  watches every `in:out` pair it is given; the npm CLI accepted one, so a
  build with many entries had to run a watcher per entry or keep its own
  dependency graph and spawn one-shot compiles. All pairs now share one set
  of watchers, one sweep and one coalesce window, and a save recompiles the
  entries that read the changed file and no others. Another pair's OUTPUT
  landing in a watched directory is not a change unless some entry reads it,
  or an entry failed for want of it: one that is failing is compiled again
  when another pair's output appears beside it. Pairs that write another
  pair's input compile one at a time, write included, as one-shot mode does.

  A round that reaches two or more entries compiles on a pool of workers
  that lives for the whole watch, with diagnostics replayed in command-line
  order. On a 147-entry tree:

  ```
    Linux/x86_64            pool (8)   -j 1     one-shot spawn, 0.18.0
    first round              447 ms   1458 ms   360 ms
    save reaching 10         196 ms    417 ms   265 ms
    save reaching 138        354 ms   1549 ms   359 ms
  ```

  The pool is `--jobs` wide, defaulting as one-shot mode does. Each thread
  that has compiled keeps its arena's high-water mark, so that watch holds
  about 1.35 GB after a large round against about 350 MB at `-j 1`: pass
  `-j` to trade latency for memory. It plateaus rather than grows.

  `SASSO_DEBUG_WATCH=1` prints `sasso: compiling <input>` to stderr per
  compile. An unchanged stylesheet writes and prints nothing, so without it
  a wasted recompile is invisible — the tests assert on it.

- **Built-in modules have a member table** (#64). `meta.module-functions()`,
  `meta.module-mixins()` and `meta.module-variables()` listed members for
  `sass:meta` and answered every other built-in with an empty map, because
  there was no table to enumerate — only a `match` that could say whether
  `get` is in `sass:map` and not what `sass:map` contains.

  One `(member, global alias)` table per module now answers all three
  questions, and the order is dart's: the result is a map, a Sass map keeps
  insertion order, and dart returns members as declared rather than sorted.
  Measured against dart-sass 1.104.1 — all seven modules identical, names and
  order, 116 function members in total:

  ```
    sass:math      24    sass:selector   8
    sass:color     37    sass:string    10
    sass:list      10    sass:meta      18
    sass:map        9
  ```

  And the members that are not functions: `sass:meta`'s two mixins
  (`load-css`, `apply`) and `sass:math`'s seven variables.

  Three membership differences went with it:

  ```
    math.exp     sasso had it, dart does not
    math.sign    sasso had it, dart does not
    list.slash   dart had it, sasso's predicate said no (the call worked)
  ```

  `exp` and `sign` still COMPUTE in both compilers — `exp(1)` is
  `2.7182818285` — because they are CSS math functions, which is a different
  thing from a Sass function. What changes is that
  `meta.function-exists("exp", $module: "math")` answers `false`, as dart does.

  `meta.module-variables("math")` also carries values now instead of `null`
  for every key: `("e": 2.7182818285, "pi": 3.1415926536, …)`. `module_var`
  already owned them and nothing was asking it.

- **A deleted dependency is no longer resurrected through the output symlink**
  (#177). With `out.css -> _v.scss` under `--watch`, deleting `_v.scss` made
  the compile fail — and writing the error stylesheet through the link
  RECREATED the file the user had just deleted, with CSS in it. The next
  compile then found that file and could succeed on garbage.

  ```
    dart                  _v.scss stays gone
    npm CLI, before #176  _v.scss RECREATED holding the error stylesheet
    binary, before #177   _v.scss RECREATED holding the error stylesheet
    both, now             _v.scss stays gone
  ```

  Two things had to change, and neither alone is enough:

  - the guard asked `canonicalize`, which answers nothing for a DANGLING link,
    so it stepped aside. It follows the link CHAIN now, resolving each hop
    against its own holder — and compares through the holder rather than
    lexically, because the file is gone and the directory is the only part a
    symlink can still rename. Three shapes, each its own regression:
    `out.css -> _v.scss`; `out.css -> middle.scss -> _v.scss`, where one hop
    stops at a file no compile ever read; and a link reached through a
    symlinked directory, where the entry and the output spell one directory
    two ways (both mixed orders failed, in both directions). A relative target
    climbing out with `..` through a symlinked holder is the fourth, and the
    one the final parent's resolution alone cannot save; a DEPENDENCY that is
    itself a symlink is the fifth — the importer reports the link it opened
    and the output link resolves to the target, so both names are remembered;
  - a failed compile reports no dependencies at all, so once `_v.scss` was
    deleted nothing was left to recognise it by. The watch remembers every
    file it has read, across failures, the way the npm CLI keeps its `known`
    set.

  The memory is consulted on the FAILURE path only. A successful compile's
  dependency list is accurate, and asking the history there kept a dropped
  `@use` alive forever — `out.css -> _v.scss` was then never written again,
  silently. It is reduced to comparison keys as it is built, held behind an
  `Arc` so no round copies it, and looked up rather than scanned. The guard runs once per unit per round while the memory
  grows for the life of the watch, so canonicalising it per comparison cost
  10.5 ms per unit per round at 500 files ever read and 42.3 ms at 2000. Two
  set lookups cost 8-9 us regardless of history size:

  ```
    files ever read   scanned    looked up
              10      217 us      8.6 us
             100      2.24 ms     9.4 us
             500     10.48 ms     8.4 us
            2000     42.28 ms     9.3 us
  ```

  Not done by refusing to write through a dangling link at all:
  `out.css -> dist/out.css` before the first build is a legitimate and common
  setup, and dart writes it. That half-measure is now caught by a test rather
  than warned about in a comment.

- **The third `file:` URL decoder is gone** (#188). #163 unified the copies in
  `src/pathstyle.rs` and `napi/src/lib.rs` after they had drifted twice; a
  third lived in `src/main.rs` with its own `percent_decode` beside it, and it
  had drifted the same way. It declined a `localhost` authority — the exact
  disagreement #161 fixed between the other two — and declined a UNC form that
  `pathstyle` resolves on Windows and correctly refuses on POSIX.

  `url_to_path` calls `sasso::file_url_to_path` now, which deletes ~30 lines
  and the duplicate decoder with them.

  Nothing user-visible changes: the arm is unreachable today. `FsImporter`'s
  canonical form IS the absolute filesystem path, so every canonical the
  binary sees takes the earlier path arm — measured by instrumenting both and
  running the CLI suite, 11 hits on the path arm and 0 on the `file:` one.
  That is precisely why it now has tests of its own: dead-but-defensive code
  nobody checks is how this copy drifted from the other two unnoticed.

  The doc comment also claimed "the only caller". There are two, and they read
  `None` in opposite directions — `--update`'s freshness test treats it as
  "rebuild" (safe: one extra write), while the watch's pre-read stamp records
  nothing for that file (not safe: a save landing mid-read is not seen). Both
  are written down now, with the note that the second is latent rather than
  live for the same reason.

- **The binary stamps `--update`/`--watch` on Windows too** (#189). dart prints
  a timestamp on all three platforms; sasso printed one on two. `local_stamp`
  learns the local offset by reading `/etc/localtime`, and Windows has no TZif
  file, so the line came out bare:

  ```
    dart    [2026-09-23 04:21:49] Compiled stamp.scss to stamp.css.
    sasso                         Compiled one.scss to one.css.
  ```

  `std` exposes no local time on any platform, so the offset has to come from
  FFI or a crate. FFI would need a second `#[allow(unsafe_code)]` — this crate
  allows one, in `arena`, audited under Miri, and a Win32 call cannot be
  checked under Miri at all. So: one dependency, Windows only, optional, and
  behind a default-on `cli-clock` feature.

  Measured by LOCKFILE entries, which is what every platform carries (a
  lockfile is target-independent, so `cargo tree --target` understates it):

  ```
    candidate   lockfile   1.74 + windows   ours unsafe   shipped weight
    chrono          37     builds           no            none
    time            13     FAILS            no            none
    jiff            21     builds           no            ~427 KB
    windows-sys     11     builds           YES           none
  ```

  `time` is the smallest and unusable: `time-core` ships an edition-2024
  manifest that Cargo 1.74 cannot parse, so it breaks the MSRV promise on the
  one platform that resolves it. `jiff` embeds the whole tz database on
  Windows, which has no system copy — the ~427 KB `src/localtime`'s header had
  already weighed and rejected, and unlike lockfile metadata it is weight in
  every shipped binary. `windows-sys` still needs an `unsafe` block at each
  call site, so it buys a dependency *and* the exemption.

  chrono's 37 are mostly `iana-time-zone`'s other platforms (wasm-bindgen,
  js-sys, core-foundation-sys) — crates a Windows build never compiles; on
  Windows `clock` resolves to the platform API, so nothing is embedded.

  `localtime` is a module of the BINARY and the library never refers to it, so
  a Windows embedder who wants the zero-dependency build asks for
  `default-features = false` and gets exactly that, at the cost of the stamp.
  Every other target resolves nothing either way.

  The platform seam stays where the module already put it: only
  `local_offset_at` differs now, and `local_stamp`, the formatter and the
  calendar are one implementation for every target. The Windows CI step that
  pinned the ABSENCE of a stamp — and that was written so a clock would have
  to fail it — now asserts its presence and its shape, which is the only
  place the Windows path is ever executed. The MSRV job cross-checks the
  Windows target from ubuntu, because a host-only check resolves chrono on no
  platform at all.

- **The `--update`/`--watch` stamp keeps its seconds** (#190). Both front ends
  printed `[2026-09-23 22:57]`; dart prints `[2026-09-23 22:57:40]`. We had
  been matching the wrong one of dart's two builds — and the one we matched is
  wrong by accident. dart-sass builds the stamp by stripping a fixed seven
  characters off `DateTime.now().toString()`:

  ```js
    nowStr = DateTime.now().toString();
    timestamp = nowStr.substring(0, nowStr.length - 7);
  ```

  Seven is `.` plus six microsecond digits, which is what the Dart VM prints.
  dart2js prints three, so on the npm build the slice eats `:SS` too:

  ```
    VM       2026-09-22 23:36:00.123456   len 26   ->  2026-09-22 23:36:00
    dart2js  2026-09-22 23:36:00.123      len 23   ->  2026-09-22 23:36
  ```

  So one dart version has two answers, and the shorter is a truncation bug
  rather than a format: the code means to drop a fractional part and keep the
  seconds. Every dart measurement in this project is taken against the npm
  build, which is why this went unnoticed — the native build had never been
  compared. Both sasso front ends now match dart's intent, which is also what
  `brew install sass` and every Windows user see:

  ```
    dart native    [2026-09-23 22:57:40] Compiled one.scss to one.css.
    dart npm       [2026-09-23 22:57]    Compiled one.scss to one.css.
    sasso binary   [2026-09-23 22:57:40] Compiled one.scss to one.css.
    sasso npm      [2026-09-23 22:57:40] Compiled one.scss to one.css.
  ```

- **The drive-letter pair grammar was three different rules** (#172). A
  `<source>:<destination>` operand is split at the first colon that is not a
  drive letter's, and each front end decided that differently — the binary
  only on Windows (`cfg!(windows)`, so a POSIX run took the false branch and
  no test ran on Windows to take the other), the npm CLI on every platform but
  only when a separator followed (`C:\`, not `C:`), and dart on every platform
  with no separator required. Measured against dart-sass 1.104.1 on macOS:

  ```
    operand                 dart          binary before   npm CLI before
    C:\in.scss              one path      pair C+\in…     one path
    C:in.scss               one path      pair C+in…      pair C+in…
    C:\in.scss:C:\out.css   pair          one-":" error   pair
    in.scss:C:\out.css      pair          one-":" error   pair
    a:b                     one path      pair a+b        pair a+b
    a:b:c                   pair a:b+c    one-":" error   one-":" error
  ```

  All three agree now, on exit code, on what is written, and on the message.
  Two consequences worth stating: `sasso C:\in.scss` compiles that file
  instead of failing to read a file called `C`, and a POSIX directory named
  with a single letter can no longer be the source of a pair — `a:b` is one
  path, as it already was on Windows and as dart has it everywhere.

  The `may only contain one ":"` message quoted the operand with `{:?}`, which
  escapes a backslash, so the message for the operand this rule exists for came
  out naming `C:\\in.scss…` — two backslashes where the user typed one. It
  prints what the user typed now, as dart and the npm CLI already did.

  The grammar had no test anywhere before this: no `C:\` literal existed under
  `tests/`, and the binary's rule was `cfg!`-gated, so a POSIX run could not
  reach it and the Windows job had nothing to run. It is platform-independent
  now, so the cases run everywhere.

- **The nested-destination rule is checkable off Windows** (#172). `path_key`
  folds case on Windows — where dart lowercases each part of a canonical, so
  `Src` and `src` name one directory — and it was `#[cfg(windows)]`-gated, so
  the fold existed only in a build no test ran. The rule it serves ("is this
  file inside the destination, and would a second run mirror the output tree
  into itself") therefore had no case at all.

  The fold is a value now: `path_key_in(style, path)` is the one
  style-dependent step, and the two rules built on it — `key_inside` and
  `dest_nested_in_src` — are pure comparisons of its output, so a test keys
  with `Style::Windows` and asks the Windows question on any host. Keeping the
  keying out of the comparisons is also what lets the directory walk key the
  destination once rather than once per file.

  Behaviour is unchanged; the POSIX column is measured against dart-sass
  1.104.1 on macOS, with a stylesheet already in the destination:

  ```
    sass Src:src/css  ->  src/css/a.css AND src/css/css/old.css
    sass src:src/css  ->  src/css/a.css only
  ```

  The first row is the proof that dart does not fold off Windows even on a
  case-insensitive volume, where `Src/` and `src/` are one directory on disk.

- **The binary made a failed `--no-error-css` removal the run's verdict**
  (#182). `--no-error-css` means there is no output to produce, so a
  cleanup that fails does not change what went wrong with the stylesheet.
  The message stays; the exit code goes back to 65.

  Measured 2026-09-23 against dart-sass 1.104.1, a stale output whose
  holding directory is read-only:

  ```
    dart     65   says nothing about the removal
    binary   66   says it                          (before)
    npm      65   says it                          (#181)
  ```

  dart does ATTEMPT the removal rather than skipping it — with a writable
  directory all three delete the stale file and all three exit 65 — so
  this was dart swallowing the failure, not declining to try. Telling
  someone their stale output is still there is worth saying; making it
  the run's answer is what diverged.

- **The npm CLI exited 1 for every kind of failure** (#91). dart-sass and
  the native CLI both use the `sysexits` codes and agree with each other;
  a build script that switches on the code to tell "your stylesheet is
  wrong" from "I could not write where you told me" got neither from the
  package advertised as a drop-in.

  Measured 2026-09-22 against dart-sass 1.104.1 and the binary:

  ```
                             dart   binary   npm before   npm after
    compile error             65      65         1           65
    missing import            65      65         1           65
    input does not exist      66      66         1           66
    output is a directory     66      66         1           66
    usage error               64      64         1           64
    a batch with both         66      66         1           66
  ```

  The mixed batch answered the issue's open question: **66 wins in either
  command-line order**, so it is severity that decides and not recency —
  the same rule `worse()` spells out in `src/main.rs`. `worst` is a plain
  numeric maximum here because 66 > 65 > 0 is already that order.

  Four paths had to learn it, not one: the batch loop, the worker pool
  (which aggregates separately), `--loop`, and `--stdin`. The last two
  already told the three causes apart for the MESSAGE and answered 1 for
  all of them anyway.

  A compile error whose ERROR-CSS WRITE also fails is an I/O failure —
  the output could not be produced, and dart answers 66. A failed
  REMOVAL under `--no-error-css` is not: there was no output to produce,
  and dart stays at 65 and says nothing about the removal at all. The
  binary upgrades there and diverges from dart; #182 has it.

  Twenty existing cases asserted `status === 1`. They are classified now
  — by what each one does, not by what the code returns — and the one
  disagreement that produced was real: `--loop` on a broken stylesheet
  was answering 64 where the binary answers 65.


- **The npm package compiled stylesheets that are not valid UTF-8 into
  replacement characters, and said nothing** (#179). `readFileSync(path,
  "utf8")` does not reject invalid UTF-8 — it substitutes U+FFFD and
  returns a string — and four reads went through it: the entry on three
  code paths and every dependency on one.

  ```
    $c: \xff\xfered;                    entry          dependency
    dart-sass 1.104.1                  Invalid UTF-8.  Invalid UTF-8.
    sasso binary                       Invalid UTF-8.  Cannot read …
    npm, native addon, before          COMPILED        Cannot read …
    npm, wasm, before                  COMPILED        COMPILED
    npm, either, after                 Invalid UTF-8.  Cannot read …
  ```

  Note which cells were wrong: the dependency half only on wasm, the
  entry half on both. A suite that runs one engine at a time saw neither,
  which is how it survived — it took a test written on a machine with the
  addon and run in CI without it (#176) to surface any of it.

  The decoding is one exported rule now rather than four call sites, and
  the new case exercises BOTH engines wherever both are present.

  Standard input was still outside that rule. `sasso --stdin`, a `-` job
  and `--loop` read fd 0 with `readFileSync(0, "utf8")`, which substitutes
  U+FFFD, and the `-` job decoded the result again non-fatally — so the
  same bytes a file entry refuses compiled when they arrived on stdin.
  Stdin is an entry: it uses the same decoder and reports
  `Error: Invalid UTF-8.`, and a file target gets the error stylesheet,
  as the binary does.

  Still divergent, and deliberately left: for a DEPENDENCY dart says
  `Invalid UTF-8.` with a span at the offending byte inside the file,
  while every sasso engine says `Cannot read <path>: stream did not
  contain valid UTF-8` with a span at the `@use` that pulled it in.
  Matching dart there means decoding inside the compiler rather than at
  the read, so that the error carries a position — a core change, not a
  read-site one. #179 keeps it.


- **`--watch` in the npm CLI overwrote a stylesheet reached through a
  symlink** (#168). `out.css -> main.scss` and then
  `sasso --watch main.scss out.css` replaced the stylesheet with its own
  CSS. Both CLIs already decline the lexical form of this — `--watch
  main.scss main.scss` writes nothing and says nothing — and a symlink is
  the same situation spelled differently, which a path-string comparison
  cannot see.

  `aliasesASource` asks the filesystem as well now, exactly as the
  binary's `aliases_a_source` does: `realpath` both sides, and only when
  the destination exists, since a path that is not there cannot alias
  anything.

  Measured 2026-09-22, `out.css -> main.scss` under `--watch`:

  ```
    dart-sass 1.104.1   declines 26 runs in 29, DESTROYS the file in 3
    sasso binary        declines                              (#166)
    npm, before         DESTROYS every time
    npm, after          declines
  ```

  A link that leads NOWHERE is the half that bites hardest, and it is a
  different question. `out.css -> _v.scss` and then `rm _v.scss` made the
  failure path write the error stylesheet THROUGH the link, recreating
  the file it was complaining about — in three shapes: the deletion, a
  chain (`out.css -> middle.scss -> _v.scss`), and a watch that starts
  with the dependency already missing. The last cannot be answered by
  comparing paths at all: the first compile throws before it reports what
  it loaded, so there is nothing to compare against.

  A fourth shape has nothing to do with dangling links at all: a
  dependency that EXISTS and fails to load — invalid UTF-8, a parse error
  — never reaches `known` either, because the compile throws before it
  reports what it loaded, and the link to it resolves perfectly well. The
  error's own span is no help: what reaches the write is `Undefined
  variable` in the entry, not the read failure in the dependency.

  One rule settles all four, and it is about the output rather than about
  links: **the error stylesheet goes through a SYMLINKED output only once
  this watch has written that output itself.** A link we have written
  through is demonstrably an output, whatever it points at; one we have
  not could be anything, and nothing available at that moment can tell.
  A plain path is unaffected, so a failing first compile still writes its
  error stylesheet into a `dist/css/` that never existed, as dart does.

  The cost is one case: a symlinked output whose FIRST build fails gets
  no error stylesheet. The error still reaches stderr, and everything
  after the first successful build behaves exactly as before — including
  a second failure in a row, since what the watch has written is a fact
  about the run and not something a failure undoes.

  The binary has the same defect and cannot take the same fix; #177
  carries it with the measurement.

  That dart row corrects this repo's own record. `tests/cli_dart_compat.rs`
  said "dart Compiled x1, the source is DESTROYED" from a single run, and
  concluded "nobody protects it". dart does protect it — with a guard that
  loses about one time in ten. So the divergence is not that dart permits
  this and we refuse: it is that dart decides it by a coin toss and we
  decide it every time.


- **`--watch` in the npm CLI printed every diagnostic twice per save**
  (#165). A burst is a provisional run plus an authoritative catch-up, and
  both reported. A provisional FAILURE was already silent, for the reason
  `_coalesce.mjs` gives — what it read is not always what the save finally
  left there — and a `@warn` is the same claim about the same bytes.

  Measured, one `@warn` and three saves:

  ```
    dart-sass 1.104.1   WARNING x4    (one at startup, one per save)
    sasso binary        WARNING x4
    npm, before         WARNING x7
    npm, after          WARNING x4
  ```

  Two rules do it, and the second matters more than it looks. A
  provisional run compiles with `Logger.silent` and narrates nothing at
  all — the binary drops its whole stdout for the same reason — so the
  catch-up 50 ms behind it is the run that speaks. That also puts the
  warning BEFORE the `Compiled` line, which is the order dart and the
  binary both print (measured 2026-09-22, all three).

  And an authoritative run's diagnostics are captured rather than let
  through, so a run that turns out to have produced exactly the CSS
  already on disk can say nothing at all. Without that, macOS delivering
  one save twice — once from the sweep, once from an `fs.watch` event
  seconds later (#164) — printed the warning again for work that produced
  nothing. Measured before this, four runs of three saves: 5, 8, 7, 8
  warnings where dart prints 4.

  ```
    cli --watch — one save prints one @warn, and a save that changes
                  nothing prints none
  ```

  Verified on Linux too, where the watcher fires once and the count is
  exact in all three modes: 4, 4, 4.


- **`--watch` in the npm CLI answered a save in about a second on macOS, and
  sometimes not at all** (#164). It waited on `fs.watch`, and `fs.watch` is
  the thing that is broken there. Measured with no sasso involved — watch a
  directory, settle, write one file, time the callback, 20 samples 1200 ms
  apart:

  ```
    macOS 26, Apple Silicon   node v22.22.3   20/20 delivered   median  552 ms
    macOS 26, Intel           node v26.7.0     8/20 delivered   median 9132 ms
    Linux, inotify            node v26.8.1    20/20 delivered   median  0.2 ms
  ```

  Twelve of twenty events never arrived at all on the Intel Mac, inside
  fifteen seconds; a directory in `$HOME` rather than `/var/folders` made no
  difference. dart-sass has the same problem for the same reason, and worse:
  13196 ms median for a settled save on this machine.

  So the watcher can no longer be what guarantees a save is seen. `fs.watch`
  stays for latency — on Linux it answers in 0.2 ms and nothing beats it —
  and a sweep runs beside it for the guarantee, on the binary's rule: a 50 ms
  floor, an interval that grows with what a sweep costs, a 500 ms ceiling. A
  sweep is 0.054 ms for ten files and 13.2 ms for five thousand, so a small
  project spends 0.1% of a core.

  ```
    settled dependency save, macOS, median      before        after
      npm CLI                                   2036 ms       24 ms
      npm CLI, worst of 32                     13553 ms       46 ms
    a save made the instant the watch starts
      npm CLI, median                           1116 ms       55 ms
      npm CLI, over 500 ms                       32/40         0/40
  ```

  The startup half needed its own fix: the sweep's baseline is now taken
  BEFORE the compile reads anything, so a save made while that compile is
  running is still seen. Stamping afterwards adopts the save as the baseline
  and no later sweep can find it — the same rule as the binary's
  `Snapshot::follow`, which keeps the earliest observation of a path.

  `--[no-]poll` stops being a no-op on this CLI and starts meaning what it
  means in dart: `--poll` sweeps only, `--no-poll` uses `fs.watch` only, and
  the default is both.

  Nothing was ever lost, which is what the issue originally claimed: the
  saves it recorded as dropped were delivered 2.7 seconds later, past the
  probe's own timeout.

- **The published crate carried a benchmark that could not compile.** `exclude`
  dropped `/bench`, where every corpus the CodSpeed target reads lives, but not
  `/benches`, where the target itself lives — so the tarball shipped
  `benches/compile.rs` with none of the six files it `include_str!`s. `cargo
  publish` never caught it because its verify step does not build bench targets;
  `cargo build --benches` inside the unpacked 0.18.0 crate fails with six
  `couldn't read benches/../bench/corpus/...` errors. Nothing that consumes
  sasso as a library or installs the binary was affected — `cargo bench` and
  `cargo test --all-targets` against the published source were, which is what a
  distribution packager runs. `/benches` is now excluded too, so Cargo drops the
  target from the published manifest and prints `warning: ignoring benchmark
  'compile' as 'benches/compile.rs' is not included in the published package`.

  The benchmark stays where it is rather than moving beside its corpora, for a
  reason worth recording: CodSpeed's benchmark identity is
  `{file}::{module_path}{bench_name}`, so relocating the file retires every URI
  and resets the gate's regression history.

- **Plain CSS rejects every `#{…}`, where eight positions let one through.** A
  `.css` file has no interpolation at all in dart — its parser raises
  `Interpolation isn't allowed in plain CSS.` wherever one appears — and sasso
  raised it in a value, a selector and a keyframes name but not in an at-rule's
  NAME, a media query's type or raw operand, a `@supports` condition, a loud
  comment, a plain-CSS custom callable's body, a custom property's value inside
  a string, a special function's verbatim arguments (`element()`,
  `expression()`, a vendor-prefixed spelling, the IE `progid:` form), or the
  modern CSS `if()`'s raw operands (a condition's parentheses, the function name
  before them, a clause value the raw grammar reached first). The at-rule name
  was the worst: `@#{"media"} (a: 1) { .x { y: z } }` parsed into a node the
  plain-CSS evaluator has no arm for, so the whole rule was dropped in silence.
  The rest compiled as though the interpolation were text, which is a stylesheet
  dart refuses being accepted.

  The rejection also moved to where dart raises it — the END of its
  `singleInterpolation`, after the body has parsed and the `}` is consumed — so
  a body that is invalid on its own terms reports ITSELF (`#{$x}` is "Sass
  variables aren't allowed in plain CSS", `#{ }` is "Expected expression") and
  the caret spans the whole `#{…}` instead of its first column. Inside `if()`
  the rejection also has to ESCAPE a backtracking attempt: sasso tries the
  modern clause grammar and rewinds on error to the legacy `if($c, $t, $f)`
  argument parse, which would report the `>` the raw grammar reads verbatim as
  an operator. An interpolation in plain CSS is fatal wherever it stands, so no
  retry can accept that text and the error propagates.

  `[measured]` against dart-sass 1.104.1: of the 37 forms the tests pin, 35 are
  byte-identical diagnostics — message, position and underline alike — and the
  two that are not differ only in the caret length of a `$variable` inside the
  interpolation, an already-recorded divergence. Both ratchets are unchanged,
  because no sass-spec `.css` file contains an interpolation to score.

- **An at-rule's node CLASS decides how it is written, not its name** — the
  fifteenth and last of the compressed-only divergences the triage found. dart's
  parser picks the class: `@media` and `@supports` become `CssMediaRule` /
  `CssSupportsRule`, and every other at-rule — including one whose name arrived
  through interpolation, whatever that name spells — becomes a generic
  `CssAtRule`. `@#{"media"} (a: 1)` therefore only SPELLS itself `@media`, and
  neither thing the conditional group rules do applies to it: it keeps the
  compressed space before a `(` prelude (`@media (a: 1){.x{y:z}}`, not
  `@media(a: 1){.x{y:z}}`), and it survives an empty block, because
  `_isInvisible` short-circuits on `CssAtRule` — "we can't guarantee that (for
  example) `@foo {}` isn't meaningful". The output tree now carries the class as
  a field of its own, so no writer re-reads a name to guess it.

  `[measured]` against dart-sass 1.104.1 in both styles: compressed passing
  14,051 → **14,052** of 14,258 (98.55% → **98.56%**), expanded `+0`. The
  empty-block half shows in BOTH styles — `@#{"media"} screen {}` is output, not
  nothing — where no sass-spec case scores it, so tests pin it. That leaves the
  compressed ratchet with no known serialization divergence at all: its 62-case
  gap to the expanded one is entirely cases whose shipped expectation dart-sass
  1.104.1 itself no longer matches.

- **Fourteen of the fifteen compressed-only divergences the last triage left**,
  by five mechanisms. All of it `[measured]` against dart-sass 1.104.1 in both
  styles: compressed passing 14,037 → **14,051** of 14,258 (98.45% →
  **98.55%**), expanded `+0`, nothing lost in either style.

  **A percent channel is `max * value / 100`, in dart's order.** The triage had
  read this family as a leading-zero bug; probing it showed both leading-zero
  rules already right and the arithmetic wrong. dart's `_percentageOrUnitless`
  multiplies before it divides, and that is observable: `0.4 * -40 / 100` is
  exactly -0.16 where `-40 / 100 * 0.4` is -0.16000000000000003. The dust
  reaches the writer, which shortens the spelling — and a shortened spelling
  loses the leading zero the exact one keeps, so `oklab(50% -40% -75%)`
  compressed to `oklab(.5 -.16 -0.3)` instead of `oklab(.5 -0.16 -0.3)`. It
  governs every percent channel, over every channel maximum: 255, 125, 150, 0.4
  and 100, in the constructors and in `color.change` alike. `[measured]` **+5**,
  gated on its own with a per-case set diff.

  **An `@import`'s modifiers are one string, spelled by the parser.** dart
  builds it while parsing and `visitCssImport` writes it verbatim, so the
  compressed media-query form — which belongs to `visitCssMediaRule` — can
  never reach an `@import`. **5 cases.** Two divergences in the same spelling
  show in BOTH styles, which is why no compressed case scored them: dart's
  `_mediaQuery` writes the space that would separate a media type from the next
  identifier *before* it learns that identifier is `and`, then writes the whole
  `" and "` anyway, so `@import url("a.css") x, print and (orientation:
  landscape)` carries TWO spaces where a real `@media` rule has one. Only an
  `@import` can show it; a media rule re-serializes from its parsed queries.

  **A plain-CSS `@function`'s SassScript declaration takes dart's optional
  space.** dart keeps `result:` as verbatim source text and parses every other
  declaration in that body as SassScript, so only the SassScript one gets the
  space a minifier exists to drop: `@function --a() { #{result}: 1 + 1 }`
  compresses to `@function --a(){result:2}` while `result: 1 + 1` keeps the gap
  it was written with. **3 cases.**

  **A private-use character is written raw when compressing**, in the unquoted
  writer as well as the quoted one. `_tryPrivateUseCharacter` gives up
  immediately when compressing — an escape is for a reader, and compressed
  output has none — and the raw character is what makes the file non-ASCII and
  earns it the BOM. **1 case**, byte-for-byte including the BOM.

  Making that writer style-aware exposed a fifth mechanism, in `meta.inspect`:
  dart inspects with `serializeValue(inspect: true)`, whose style is the DEFAULT
  one, so the string it hands back already carries `\e000`. That string is five
  characters long, not one — `string.length(inspect(unquote("\e000")))` is 5 —
  and being ASCII it leaves a compressed stylesheet with no BOM at all. No
  sass-spec case scores it either way; it is pinned by tests.

  One case was left, and the entry above closes it: `@#{"media"}` builds a
  generic node in dart, which never reaches the media-rule writer, while sasso
  re-read the name the interpolation spells.

- **The legacy `rgb()`/`hsl()` form choice follows dart's two rules**, which
  closes the largest remaining family behind the compressed conformance gate.
  All of it `[measured]` against dart-sass 1.104.1 in both styles.

  Whether a legacy triple is written as numbers or as percentages turns on when
  a channel counts as an integer, and dart tests that **exactly** for CSS output
  and **fuzzily** for `meta.inspect` — so one color has two spellings.
  `color.to-space(hsl(180, 60%, 50%, 0.4), rgb)`, whose channels are
  50.999999999999986, 203.99999999999997 and 204, is `rgba(20%, 80%, 80%, 0.4)`
  as CSS and `rgba(51, 204, 204, 0.4)` under inspect; sasso applied one fuzzy
  rule in both places, so the dust an hsl conversion leaves behind was invisible
  where dart shows it. The fuzzy side needs both clauses of dart's
  `fuzzyEquals` — a channel 5e-12 short of 20 is *not* an integer to dart — and
  the same exactness governs the `[0, 256)` bound on the hex form.

  An out-of-gamut legacy color is written as `hsl()`, and how out-of-gamut is
  measured was wrong: dart tests each channel against **its own space's**
  bounds, so hsl and hwb are bounded to `[0, 100]` on channels 1 and 2, not to
  the `[0, 255]` of the rgb conversion compressed output would otherwise write.
  `color.to-space(oklch(0.5 0.2 200), hsl)` carries a 655% saturation over a
  shadow that is ordinary black, and measuring the shadow printed `#000`.

  Making the first rule exact exposed a third divergence, in the arithmetic
  rather than the serializer: a modified color is built in the working space,
  and dart reduces a polar hue into `[0, 360)` *before* the conversion back
  reads it.
  Only a conversion can see it — `(390 % 360) / 360` is exactly `1/12` while
  `(390 / 360) % 1` is an ulp short — and one ulp is the difference between
  `color.complement(rgba(10, 20, 30, 0.4))` writing `rgba(30, 20, 10, 0.4)` and
  writing a percentage triple.

  Every OTHER decision in that form choice runs through the same comparison,
  and each was a bare epsilon or a looser tolerance of its own. A `0` hue now
  survives the 180° offset a negative saturation asks for, because dart matches
  `0` before it shifts — `color.change(hsl(120, 50%, 50%), $hue: 0,
  $saturation: -50%)` is `hsl(0, 50%, 50%)`, where a shift-then-reduce turns red
  into cyan. Whether that saturation counts as negative, whether a channel is
  past its bound, whether a triple matches a named color (dart looks it up in a
  map, so `fuzzyHashCode` — the same rounding — has to agree), whether a
  conversion leaves a powerless hue, and whether an alpha is opaque are all the
  one rule now: `color.change(red, $red: 255.000000000006)` is
  `hsl(0, 100%, 50%)` rather than `red`, `color.change(red, $red:
  254.9999999999)` is `rgb(100%, 0%, 0%)`, and
  `color.change(red, $alpha: 0.9999999999999)` is `red` rather than an
  `rgba()` whose alpha prints as `1`.

  One rule still differs: inspect mode writes numbers at full precision, with no
  10-decimal rounding, so dart's inspect of the first color above is
  `rgba(3.9215686274500006%, …)` where sasso rounds each channel. That is a
  number-writer change with a blast radius well beyond colors.

  Compressed passing 14,009 → **14,037** of 14,258 (98.25% → 98.45%); expanded
  14,107 → **14,114**, the 7 being cases where exact integrality is what dart
  writes in expanded output too.

- **A degenerate legacy color is a color, not a string**, and an out-of-gamut
  one serializes the way dart-sass serializes it. All of it `[measured]`
  against dart-sass 1.104.1 in both styles.

  `hsl(0, 100%, calc(-infinity * 1%))` — a channel whose `calc()` folds to an
  infinity or a NaN — was preserved as an unquoted string, so `meta.type-of`
  answered `string`, the color module rejected it as "not a color",
  `string.length()` succeeded on it and `1px + $it` concatenated. dart stores
  the infinity in the channel and serializes it from there, which is what
  `hsl()`/`hsla()` now do: the hue reduces modulo 360, a negative saturation
  floors at 0, a NaN channel reads as 0, a degenerate alpha folds (`infinity`
  is opaque, `-infinity` and NaN are transparent), and the surviving infinity
  stays in its channel, where the legacy serializer writes it back as
  `calc(-infinity * 1%)`. `color()` needed no special case at all once its own
  string early-return was removed. `[measured]` **+8 cases**.

  Being colors, they reach the color module — and their out-of-gamut channels
  reach three serialization rules with them, each a divergence of its own:

  - An out-of-gamut legacy rgb color is written through its hsl form, and a
    COMPUTED one never was, because it carried no space tag to reach that rule:
    `color.mix(hsl(0, 100%, calc(-infinity * 1%)), red)` was
    `rgb(NaN%, NaN%, NaN%)` against dart's `hsl(0, 0%, 0%)`. The degenerate
    color's own rgb channels are now the plain hsl -> sRGB conversion,
    unclamped, so mixing one mixes the channels dart mixes rather than NaN
    throughout.
  - That hsl form nulls the hue when the saturation is fuzzy-zero, the way the
    compressed rgb-or-hsl choice already did: an out-of-gamut gray was
    `hsl(345, 0%, 100%)` here and `hsl(0, 0%, 100%)` in dart.
  - `meta.inspect` of the same color skips the hsl form and writes `rgb()`, but
    with the channel rules CSS output uses, which it did not: one non-integral
    channel re-spells all three as percentages (`rgb(510, 0, 127.5)` ->
    `rgb(200%, 0%, 50%)`), and a non-finite channel is a `%`-unit `calc()`
    constant — where a bare `NaN` or `-Infinity` used to reach the stylesheet.

  One rule still differs, in the other direction: dart converts a NaN channel
  to 0 when a color is CONSTRUCTED and not when one is CONVERTED, while sasso
  normalizes in both places, so
  `color.to-space(hsl(0, 100%, calc(-infinity * 1%)), lab)` is `lab(0% 0 0)`
  here and `lab(calc(NaN)% calc(NaN) calc(NaN))` in dart. No sass-spec case
  covers it.

  Compressed passing 14,001 → **14,009** of 14,258 (98.20% → 98.25%); expanded
  unchanged at 14,107 `+0`.

- **A stack frame names the file, not a `file://` URL** (#153). The npm CLI
  printed `file:///Users/you/proj/src/main.scss 1:1  root stylesheet` where
  dart-sass and the binary print `src/main.scss 1:1`. A frame is the line a
  person reads to find what they broke and the line a build log carries to
  someone else's machine; a URL is neither pasteable into an editor nor
  meaningful anywhere but the machine that produced it.

  It could not be repaired in the JS layer, which is where it looked like it
  came from. The entry URL is load-bearing — the importer bridge resolves a
  relative `@use` against it, so handing the compiler a path instead makes
  imports stop resolving — and the wasm engine could not relativise anything
  even if it wanted to: the target is `wasm32-unknown-unknown`, not wasip1, so
  `getcwd` does not exist. That second half had its own symptom, measured on
  the way: the two npm engines disagreed with **each other**, wasm naming a
  dependency `_dep.scss` where the native addon named it `src/_dep.scss`.

  So `Options` gained the directory diagnostics are spelled against
  (`Options::cwd`, `None` = ask the OS, which is what the binary keeps doing),
  the wasm ABI gained `sasso_compile4` beside the `compile3` that stays for
  hosts built against it, and both JS bridges pass `process.cwd()`. One rule
  now names a file wherever a frame does — a path or a `file://` URL, shown
  relative to that directory, with percent escapes decoded and a Windows drive
  letter kept out of the scheme's way — so the entry frame and a dependency
  frame cannot drift apart again.

  Measured against dart-sass 1.104.1, one error with two frames, before:

  ```
  dart         src/_dep.scss 2:10  m()   src/main.scss 2:6  root stylesheet
  binary       src/_dep.scss 2:14  m()   src/main.scss 2:6  root stylesheet
  npm native   src/_dep.scss 2:14  m()   file:///…/src/main.scss 2:6
  npm wasm     _dep.scss 2:14      m()   file:///…/src/main.scss 2:6
  ```

  and after, all four agree on every name. (The `2:10` against `2:14` is #157,
  which is about where the caret goes, not what the file is called.)

- **An empty at-rule survives compression, and a preserved `round()` is a
  calculation.** Two more of the compressed ratchet's divergences, both
  measured against dart-sass 1.104.1.

  dart drops a node from compressed output when everything inside it does —
  which is why `@media x { /* c */ }` compresses to nothing — but
  `_isInvisible` short-circuits on an unknown at-rule on purpose: "because we
  don't know the semantics of unknown rules, we can't guarantee that (for
  example) `@foo {}` isn't meaningful". `@media` and `@supports` have their own
  AST classes and so keep the all-children-invisible rule; every other at-rule
  stays, empty block and all. sasso dropped them all, so `@font-face {}`,
  `@keyframes k { 10% { /* c */ } }`, `@page {}` and an `@flooblehoof {}` left
  empty by `@extend` all vanished. `[measured]` **+22 cases**.

  A `round()` whose operands' units keep it from folding (`round(1px, 2bar)`,
  `round(nearest, 1px, 10%)`) was preserved as an unquoted STRING built with
  expanded spacing, which carries one spelling for both styles; it is now a
  calculation like every other preserved call, so compressed drops the space
  after each comma and `meta.type-of` reports `calculation` rather than
  `string`, both as dart does. `[measured]` **+4 cases**.

  The rule has to hold in the **plain-CSS** evaluator too, which builds its own
  output nodes: a `.css` file reached through `@use`/`@import` dropped
  `.a {@foo {}}` in *both* styles. None of that evaluator's three body
  dispatchers had an arm for `@keyframes` or for a plain-CSS custom `@function`
  either, so both were dropped outright, contents and all: `@media screen
  {@keyframes k {from {a: b}}}` came out empty, which then took the `@media`
  with it, and `.a {@function --f(--a) {result: 1}}` produced nothing at all.
  A custom `@function` in a style rule now bubbles out with a copy of the parent
  selectors wrapped around its declarations — `@function --f(--a) {.a {result: 1
  }}` — and stays where it is one level deeper, as dart does in both places.

  A `@keyframes` **frame** is not a style rule, and nothing inside one bubbles:
  the same dispatcher was reached for `from`/`50%` blocks, so every at-rule in a
  frame was hoisted out of the animation with the frame selector wrapped round
  its body — `@keyframes k {from {@foo {a: b}}}` came out
  `@keyframes k{@foo{from{a:b}}}`, and a nested `@keyframes` lost its frame
  entirely. A frame body is now read the way any deeper level is, with no
  hoisting. A **style rule** inside a frame is meanwhile an error, as dart's
  plain-CSS parser makes it (`@keyframes k {from {.x {a: b}}}`), where this
  evaluator produced output for it at every depth; both evaluators now raise
  that error from one place, and it points at the offending rule instead of
  carrying no position at all.

  A frame's selector is a list of keyframe **stops**, not of CSS selectors, and
  dart re-serializes the stops joined with `", "`. The plain-CSS evaluator ran
  them through ordinary selector normalization instead, so a line break between
  stops survived (`0%,\n50%` stayed on two lines where dart writes
  `0%, 50%`), `+5%` gained a space as though `+` were a sibling combinator, and
  an exponent marker kept its case (`130E-1%`). The `from`/`to` keywords were
  left verbatim on **both** paths, where dart lowercases them (`FROM` ->
  `from`); that normalization now lives in one function both evaluators use.
  What neither checks yet is the stop *grammar* — dart rejects anything but
  `from`, `to` and `<number>%` in a frame, so `@keyframes k {foo {a: b}}` is an
  error there and output here.

  All of it `[measured]` against dart-sass 1.104.1 in both styles; no sass-spec
  case covers any of these shapes, so neither gate number moves.

  Compressed passing 13,975 → **14,001** of 14,258 (98.02% → 98.20%); expanded
  unchanged at 14,107 `+0`.

- **Compressed output serializes colors and long fractions the way dart-sass
  does** (#142's gate made this measurable). The compressed ratchet landed
  scoring 12,579 of 14,258 cases, and 1,528 of those 1,679 failures were cases
  whose *expanded* CSS is byte-exact, so the expanded gate could not see them
  at all. Two rules account for 1,396 of the 1,528:

  - A `lab()`/`lch()`/`oklab()`/`oklch()` lightness is written as the
    channel's own stored number with no `%` — the same digits for lab and lch,
    whose lightness runs 0-100, and the unscaled 0-1 value for oklab and oklch,
    so `oklab(1% 0 0)` compresses to `oklab(.01 0 0)`, which is *longer*. A hue
    drops its `deg` in every function that takes one, including the modern form
    of `hsl()` and `hwb()`.
  - Whether a fraction loses its leading zero depends on which of dart's two
    number writers renders it, and sasso implemented only the first rule of
    three: the direct writer tests for a literal `0.` prefix, so `-0.5` keeps
    its zero; `_writeRounded` drops the integer `0` for either sign once it has
    digits to round away (`-0.00123456789` -> `-.0012345679`); and a spelling
    long enough for `_writeRounded` but with nothing to round passes through
    verbatim, keeping the zero even when positive (`0.0123456789`).

  Compressed conformance goes from 12,579 to 13,975 of 14,258 (88.22% ->
  98.02%); expanded is unchanged at 14,107. Of the 132 cases still diverging,
  62 are ones where dart-sass 1.104.1's own expanded output no longer matches
  the expectation sass-spec ships.

- **The nine members dart removed from `sass:color` exist, and say what
  replaced them** (#65). `opacify`, `fade-in`, `transparentize`, `fade-out`,
  `lighten`, `darken`, `saturate`, `desaturate` and `adjust-hue` are gone from
  the module but not *unknown*: dart keeps each as a member that always fails,
  with a three-part message naming the `color.adjust` that replaces it. sasso
  said `Undefined function.`, which sends the reader looking for a typo instead
  of at a migration:

  ```
  Error: The function opacify() isn't in the sass:color module.

  Recommendation: color.adjust(rgba(1, 2, 3, 0.5), $alpha: 0.1)

  More info: https://sass-lang.com/documentation/functions/color#opacify
  ```

  The recommendation is built from the call's OWN arguments, which is what
  separates it from the global `[color-functions]` deprecation next to it: that
  one prints a `$color` placeholder, negates arithmetically and folds `turn`/
  `rad` to degrees. Here nothing is converted and nothing is validated — the
  amount is negated *textually* (`-10%` suggests `--10%`), `0.5turn` stays
  `0.5turn`, and a non-colour first argument is quoted back as written, because
  the line is a suggestion rather than a call. Arity is still checked first, so
  a call that could not have worked is reported as the wrong call it is.

  Making them members rather than a special case in one call path is what makes
  every spelling agree: `meta.function-exists`, `meta.get-function` and
  `meta.call` see them, `@forward` re-exports and re-prefixes them (reached as
  `c-lighten`, the message still says `lighten()`), and — the visible half — a
  `@use "sass:color" as *` binds them OVER the global of the same name, so
  `saturate(#abcdef, 10%)` fails there while the bare global still computes a
  colour.

  Two pre-existing bugs found while measuring this and fixed with it. dart's
  `Value.toString()` — the spelling a diagnostic gives a value it embeds whole —
  had three drifting copies in sasso, which disagreed on a one-element space
  list: `@error list.append((), 1)` printed `1` where dart prints `(1)`, and
  `rgb(list.append((), 1), 0.5)` said `$color: 1 is not a color.` for dart's
  `$color: (1) is not a color.` There is now one serializer. And a member
  reached through `@use … as *` drew a one-column caret instead of spanning the
  invocation, which was visible for every starred built-in, not just these
  (`@use "sass:string" as *; b: index(1, 2, 3)`).

  Against dart-sass 1.104.1 the CSS ratchet is unchanged at 14,107/14,258.

- **`color-module-compat` is emitted, and the filter overload has one rule**
  (#124). A `sass:color` member used in its plain-CSS *filter* sense —
  `color.grayscale(1)`, `color.invert(0.5)`, `color.opacity(0.5)`,
  `color.alpha(opacity=20)` — is deprecated by dart-sass. sasso took the
  overload and produced the same CSS, but said nothing in any of dart's five
  shapes.

  The module rule is narrower than the global one, so this was more than a
  missing warning. On `sass:color` only a NUMBER takes the filter overload:
  `var(--c)`, `env(…)` and a `calc()` that cannot fold to a number are colour
  arguments there and fail as ones, where the global spelling passes them
  through verbatim. sasso rejected only an unquoted string, and only for
  `grayscale`/`opacity`, so `color.invert(var(--c))` compiled to a CSS filter
  dart-sass refuses to produce.

  Both halves now come from one predicate each, read by the dispatcher that
  raises the error and by the evaluator that deprecates exactly the calls that
  did take the overload — the same fix shape as #122, where those two decisions
  lived apart and drifted.

  Two adjacent divergences the shared predicate settles: `alpha($color:
  opacity=20)`, the Microsoft filter overload reached by name, which dart takes
  on both paths while sasso errored (and globally also warned
  `global-builtin`); and `color.invert(c)`, which now carries dart's `$color: `
  message prefix that only `grayscale`/`opacity` had.

  dart's `opacity` message is missing its closing parenthesis (`Passing a
  number (1 to color.opacity()`) and sass-spec locks that text, so parity means
  reproducing it. Against dart-sass 1.104.1 the CSS ratchet is unchanged and
  the stderr-conformance metric gains 12 cases.

- **`--update` now looks at the stylesheets the entry imports** (#133). It
  compared the output's mtime against the entry alone, so editing a partial
  left the old CSS on disk and said nothing — on an `@import`-heavy tree the
  common case rather than a corner. dart-sass walks the graph; so does this.

  The compile always runs and `--update` decides whether to *write*, which
  keeps an unchanged output's mtime stable — the property downstream watchers
  key on. That ordering is measured, not conceded: on Lichess's 147 entry
  points dart's `--update` takes 1.19s to decide nothing changed and sasso
  takes 0.57s having compiled everything.

- **On Windows, an imported file is named by its path again, not by an absolute
  one** (#146). Every file reached through the importer printed in full —

  ```
  WARNING: b
      C:\Users\you\app\src\sub\_dep.scss 2:1  @use
      src/rel.scss 2:1                        root stylesheet
  ```

  where dart prints `src\sub\_dep.scss`, and a relative source map named the
  same files through a seven-deep `../../../..` chain. Stack frames, warn
  events, `--quiet-deps` provenance, dependency tracking and source maps were
  all affected, because all of them relativise the same way.

  The canonical key a resolved file is stored under is lowercased on Windows,
  mirroring dart's `p.canonicalize`; both relativisations then compared it
  against the working directory, which keeps the filesystem's spelling. On
  `std::path::Component` the drive letter compares case-insensitively and a
  name does not, so the common prefix was the drive and nothing more. Any
  uppercase letter in any segment was enough — and a Windows user profile is
  always `C:\Users\…`, so this was every project, not a CI artifact.

  Path spelling is now a value rather than a `#[cfg]`, the way dart's `path`
  package takes an explicit `Context`: one relativisation, shared by the
  library and the CLI, that folds ASCII case and accepts either separator under
  Windows rules, treats a drive or UNC share as the root, and ignores a
  verbatim `\\?\` marker when comparing roots. A path with no relative
  spelling at all — another drive, another share — now falls back the way dart
  does instead of emitting a `..` chain that resolves somewhere else; that was
  a second, silent bug. The Windows rules are unit-tested on every platform,
  which is where this bug hid: `std::path` splits by the host's rules, so off
  Windows `c:\a\b` is a single component and the Windows branch was
  unreachable.

  The suite now runs on Windows in CI (#143), with a by-name ledger of what
  still fails there.

- **The entry stylesheet's frame is spelled the way dart spells it, not the way
  it was typed** (#151). Every file reached through the importer went through
  dart's `p.prettyUri` — lexically normalize, then take the path relative to the
  working directory in the platform's separator, unless the absolute spelling is
  the shorter of the two in segments — while the entry's path was echoed
  verbatim from the command line. dart makes no exception for the entry, so one
  file named five ways produced five transcripts where dart produces one:

  ```
  $ sasso ./src/entry.scss
  WARNING: dep
      src/_dep.scss 1:1     @use
      ./src/entry.scss 1:1  root stylesheet
  ```

  `src/entry.scss`, `./src/entry.scss`, `src//entry.scss`,
  `src/../src/entry.scss` and an absolute path now all report `src/entry.scss`,
  and an entry above the working directory reports `../src/entry.scss` instead
  of an absolute path sitting beside relative dependency frames — one warning
  block in two spellings, which dart never emits. The location column is padded
  to the longest frame, so the whole block shifted with the argument rather than
  just the one line.

  On Windows the same bug put two separators in one block: the entry stayed
  `/`-separated as typed while every loaded file beside it was `\`-separated.
  That is where it was noticed, but neither the bug nor the fix is
  Windows-specific — the entry's display path is now decided in one place, from
  the working directory, on every platform, by the same function the module
  graph uses. `-` for stdin is left alone, being a marker rather than a path.

  The gated dart-sass differential asserts the whole transcript for each of
  those spellings and for a directory pair, so the rule is checked against dart
  rather than against our reading of it.

### Performance

- **Selectors with a plain pseudo-class skip the normalizer entirely.** A
  compile of a stylesheet whose selectors look like `.button:hover` or
  `.card::before` retires **3.9% fewer instructions** (3.3% compressed), with
  byte-identical CSS. sasso's selector normalizer has a fast path for selectors
  that are already in canonical form; `:` was missing from the set of bytes that
  path accepts, so every pseudo-class fell into the slow path — which, on this
  input, does an exact amount of nothing: it materializes two `Vec<char>`
  buffers and three or four `String`s, copies the selector through them
  character by character, and returns the same bytes it was given.

  The fast path now accepts `:`, which is sound rather than merely plausible.
  On paren-free, escape-free pseudo input the slow path is provably the
  identity: the whitespace-collapse pass has nothing to collapse, pseudo
  bodies are copied verbatim and both `nth`/argument rewrites bail at their
  opening `text.find('(')?`, and the adjacent-compound rewrite cannot fire
  because `.`, `#`, `%` and `:` are all excluded from the name-character set.
  The combinators `>`, `+` and `~` are deliberately *not* admitted — the slow
  path really does rewrite `>a` into `> a` — and neither are `:not(…)`,
  `:is(…)` or attribute selectors, which keep taking the slow path.

  `[measured]` macOS / arm64, interleaved arms with a byte-identical copy of
  the old binary as a control: marginal instructions per compile of
  `bench/corpus/generated/large.scss` 99.2697M → 95.4463M (**−3.852%**,
  negative in 6 of 6 paired rounds, against a control that read 0.044%), and
  112.0030M → 108.2545M compressed (−3.347%, 4 of 4, control 0.000%); marginal
  cycles −2.60% and −3.67%. That is ~3,150 instructions saved per pseudo
  selector emitted, so the gain scales with how many of them a stylesheet has:
  −0.179% on the `@extend` corpus and unmeasurably zero on a corpus with no
  pseudo selectors at all.

  A `debug_assert_eq!` now asserts, on every accepted selector, that the slow
  normalizer would have returned it unchanged. It compiles out of release
  builds and ran against the full 14,258-case sass-spec suite in a debug build
  without firing; output was compared over 118 corpus/style pairs and is
  byte-identical, as are the diagnostics and the exit codes.

- **A rule's selector list is scanned once, not three times.** Another **1.4%**
  fewer instructions per compile (1.3% compressed), byte-identical CSS. After
  resolving a selector list, sasso asked two more questions of every selector in
  it, each a full byte scan: could this be a "bogus combinator" selector that
  CSS drops, and does it contain a `%` placeholder? Both answers were already
  determined by the scan that had just run — the one that decides whether the
  selector is canonical — because its accepted byte set (`[a-zA-Z0-9_\-.#%:]`
  plus single spaces) contains no combinator, and it passes the `%` on the way.
  The resolved list now carries the two aggregate answers out of that one pass.

  So the saving is not a faster scan, it is two scans that no longer happen. It
  applies to every canonical selector rather than only the pseudo-class shape of
  the entry above, which is why it shows up on stylesheets that entry did not
  move at all: `[measured]` marginal instructions per compile of
  `bench/corpus/generated/large.scss` 95.4362M → 94.0820M (**−1.419%**, 6 of 6
  paired rounds, control 0.019%), 108.2085M → 106.8357M compressed (−1.269%, 4
  of 4, control 0.004%), and 116.1350M → 115.8636M on a deprecation-heavy sheet
  (−0.234%, 3 of 3, control 0.006%). That is ~226 instructions per emitted
  selector; together with the pseudo-class fast path above, `large.scss` is
  **−5.2%** on the same measure.

  The placeholder probe in the `@extend` pass is also no longer computed when
  extensions are in scope, where its answer was never read. On its own that is
  too small to measure (−0.047% on the `@extend` corpus, inside a 0.028%
  control band), and it is reported here only because it is part of the same
  change.

  A debug-only assertion pins the invariant the flags rest on — that the
  canonical byte set really is disjoint from the combinator triggers — and
  checks the `%` answer against a plain search, alongside the existing
  fast-versus-slow normalizer oracle. All three ran over the full 14,258-case
  sass-spec suite in a debug build without firing; output was compared over 118
  corpus/style pairs and is byte-identical, as are the diagnostics and the exit
  codes.

## [0.18.0] - 2026-09-18

_A smaller, slightly faster binary, and one fix. `panic = "abort"` and `strip`
take 24% off the shipped binary and ~1.2% off every compile, with byte-identical
output. And sasso no longer tells authors to rewrite CSS filters as Sass colour
functions: `filter: grayscale(1)` is a CSS filter, not a deprecated global
built-in, and sasso compiled it correctly while deprecating it anyway — 20
spurious warnings on Lichess's tree, where it now reports exactly what dart-sass
reports._

### Fixed

- **No more `global-builtin` deprecation for CSS filter functions** (#122).
  `grayscale`, `invert`, `opacity` and `saturate` are CSS *filter* functions
  when their argument is a number and Sass colour functions when it is a
  colour. sasso compiled both correctly but deprecated both, so
  `filter: grayscale(1)` told the author to rewrite a CSS filter as
  `color.grayscale`. dart-sass warns only on the Sass path.

  The evaluator and the builtins were deciding this separately, which is how
  they came to disagree: the call was passed through as CSS while the warning
  said otherwise. Both now consult one predicate, so the deprecation cannot
  contradict the path the call actually took.

  Two cases deliberately keep warning, both matching dart. A registered host
  function of the same name is the implementation sasso selects, so the call
  is that callback rather than a CSS filter and `with_function`'s contract
  keeps the deprecation. And `grayscale(1, 2)` reports its arity error alone,
  as dart does, rather than an arity error plus a deprecation.

  The namespaced spelling (`color.grayscale(1)`) is unchanged: it produces the
  same CSS filter dart produces. dart additionally raises
  `color-module-compat` there, which sasso still does not emit — #124.

  On Lichess's tree this was 20 spurious warnings out of 55; sasso and
  dart-sass now report the same 35, and agree file-by-file across all 147
  entry points.

### Performance

- **`panic = "abort"` and `strip` on the release and dist profiles.** The
  shipped binary is **24% smaller** and every compile retires **~1.2% fewer
  instructions**, with byte-identical CSS. Rust emits a landing pad per
  potentially-panicking call so a panic can unwind and run destructors; a
  compiler that never catches one pays for all of them. `abort` deletes that
  machinery, which shrinks the code *and* speeds it up — an unusual pairing,
  and the reason this is filed under Performance rather than a size note.

  `[measured]` macOS / arm64, four interleaved ABBA rounds on
  `bench/corpus/generated/large.scss`: marginal instructions per compile
  100.464M → 99.278M (**−1.18%**, within-arm spread ≤0.04%, against a
  control-vs-control noise band of ±0.03%), `__text` 2,285,104 → 2,101,408
  (−8.0%), file 3,122,816 → 2,377,984 (−23.9%, of which −15.4% is `abort`
  dropping landing pads and the remainder is the symbol table). The win holds
  across corpus shapes and is largest where allocation traffic is: −1.16%
  compressed, −1.47% on the deprecation corpus, and **−2.39% on
  `extend_heavy`** — the one corpus the whole 16-batch allocation campaign
  moved by only −0.94%. Output was compared over 286 corpus/style pairs and is
  byte-identical, as are the diagnostics and the exit codes.

  `[measured]` confirmed on Linux / x86_64, 12 interleaved rounds on an idle
  machine, where it reads slightly larger: 103.358M → 101.907M marginal
  instructions (**−1.404%**, both arms identical to three decimals in all 12
  rounds), marginal cycles −4.0% in 12 of 12 paired rounds, file 3,730,352 →
  2,969,192 (−20.4%), `.text` 2,872,078 → 2,626,910 (−8.5%).

  Nothing in the crate unwinds outside `#[cfg(test)]` — its only
  `catch_unwind` is in the arena's test module — and Cargo ignores the `panic`
  setting for the `test` and `bench` profiles, so the test suite and the
  CodSpeed benchmarks are unaffected (`cargo test --release` still passes
  153/153 in the lib, including the unwinding arena test). `ffi/` deliberately
  keeps `panic = "unwind"`, because its C boundary relies on `catch_unwind`,
  and `wasm/` already used `abort`; `napi/` keeps `unwind` because napi-rs
  turns a panic into a thrown JS error by catching it at the boundary. Of the
  four manifests the core was the one that had never said. Cargo profiles
  apply to their own workspace only, so a crate that depends on `sasso` as a
  library is unaffected, and
  `strip` costs only a symbolized panic backtrace, which no user-facing error
  path uses.

## [0.17.0] - 2026-09-18

_A warning for 45 rules that were vanishing from Lichess's CSS with nothing
said, and everything a user asked for in #24, plus the bug that issue turned up
on the way. `bogus-combinators` is now reported when a selector with a repeated
or leading combinator run is dropped. dart's `--silence-deprecation` /
`silenceDeprecations` on both CLIs, both engines and the JS API — Lichess moved
off `--quiet` to it precisely so the deprecations they still mean to fix keep
printing, and found sasso rejecting the flag. A Homebrew channel, and an npm CLI
that hands the command line to a matching release binary when it finds one, so
`npx sasso` is not paying for Node. `sasso --engine`, because which engine an
install actually runs was unobservable, and a fallback to wasm costs roughly
half the throughput without saying so. And a native addon whose version does not
match the `sasso` loading it is now refused rather than used to silently ignore
the options it does not know._

### Added

- **`bogus-combinators` is now reported** when a selector with a repeated or
  leading combinator run (`a > + b`) is dropped (#119). sasso already omitted
  those rules, the way dart-sass does — it just never said so, and the warning
  is the only sign the CSS lost them. On Lichess's tree that was **45 rules
  disappearing with no notice**; sasso now reports the same 45, in dart's
  order, byte-for-byte.

  dart raises these AFTER the rule's body, so a nested rule's own bogus
  selector is reported before its parent's. The message names the RESOLVED
  selector (`.tview2 .inaccuracy > + lines`) while the span points at the
  authored one (`.#{$name} > + lines`), which means mapping back across the
  interpolations that sit before and inside the entry.

  dart's other `bogus-combinators` message — a TRAILING combinator on a rule
  that has declarations of its own — carries a second span labelling the
  offending child, which this renderer cannot draw yet, and stays silent. That
  shape does not occur in the Lichess corpus.

- **Homebrew**: `brew install momiji-rs/tap/sasso` installs the same prebuilt
  binary the release page serves, on macOS and Linux, arm64 and x86_64 (#24).

  The formula is generated here and PULLED from there. `installers` gains
  `"homebrew"` and `tap = "momiji-rs/homebrew-tap"` is set, which is enough to
  make `dist` emit `sasso.rb` as a release artifact with the four target
  checksums already in it; a scheduled workflow in
  [momiji-rs/homebrew-tap](https://github.com/momiji-rs/homebrew-tap) reads the
  latest release, verifies what it downloaded (the class name, the version
  against the tag, exactly four `sha256` lines) and commits it with its own
  built-in `GITHUB_TOKEN`. `publish-jobs` deliberately does **not** include
  `"homebrew"`: that job pushes the formula from this repo into the tap, which
  needs a cross-repo write token held here as a secret. Inverting the direction
  means neither repo holds one. `dist plan` warns about the disabled publish
  job — that warning is this choice, not a misconfiguration.

  homebrew-core is the endpoint that would need no workflow at all, since
  BrewTestBot autobumps it, but its Notability rule asks 225 stars / 90 forks /
  90 watchers of an owner submitting their own project and sasso has 5 / 2 / 1
  (2026-09-18). An upstream tap is the route Homebrew documents until then.

  Verified end to end on macOS/arm64, Homebrew 7.0.4, 2026-09-18: the published
  tarball's checksum against the release's own `sha256.sum`, then a clean
  `brew install momiji-rs/tap/sasso` landing `sasso 0.16.0` and compiling a real
  stylesheet. The README leads with `brew trust --formula momiji-rs/tap/sasso` —
  the narrowest trust Homebrew has, this formula rather than the whole tap, and
  what makes `brew info sasso` and `brew upgrade sasso` work by short name
  afterwards.

- **The npm CLI hands the whole command line to a release binary when it finds
  one of exactly its own version** (#24), and exits with that process's status.
  So `brew install momiji-rs/tap/sasso` — or a `cargo install`, or a binary
  already on the box — speeds up the `sasso` in a project's npm scripts without
  editing any of them.

  Measured on 40 entry points with `--style=compressed --no-source-map`,
  published artifacts, macOS/arm64, one run for all three (2026-09-18): the
  binary **15.1 ms**, this CLI on the native addon **104.1 ms**, this CLI
  delegating **48.2 ms**, with identical CSS in all 40 files. That also corrects
  0.16.0's summary above, which put the remaining gap down to Node start-up:
  start-up plus the spawn is 35.0 ms of the 48.2 (the same delegated command
  line on one tiny file), so of the 89 ms the binary was ahead by, roughly a
  third is Node starting and the rest is work the binary does not do at all —
  moving every file's source and CSS across the napi boundary, and the
  per-file JS around it. What is left after the hand-off is Node itself, which
  no stylesheet makes cheaper.

  The version has to match EXACTLY. A `sasso` pinned in `devDependencies` must
  not quietly compile with whatever is on a developer's `PATH`, which is #114 —
  a version-skewed engine used anyway, silently dropping options it could not
  apply — one process further out. A mismatch is passed over in silence, because
  it is an ordinary state of the world and not something to interrupt a build
  over. `SASSO_BINARY=<path>` names a binary explicitly, version unchecked
  (which is how an unreleased build gets driven); `SASSO_BINARY=0` turns the
  hand-off off; `SASSO_ENGINE=wasm|native` turns it off too, because it demands
  an in-process engine and a subprocess is not one. `--watch` and `--update`
  never delegate — the binary has neither (#86) — and `--help`/`--version` still
  answer from the package alone.

  Whichever way it went is one string, so the two things that report it cannot
  disagree: `SASSO_DEBUG_ENGINE=1` prints it as it happens, and `sasso --engine`
  reports it afterwards, on a `binary:` line above the engine it loaded and did
  not use — including, when there is no hand-off, what was in the way, which is
  the question that follows. `--engine` reports the hand-off rather than taking
  it: it asks what THIS install does, and the binary has no `--engine`.

  Two hazards were not guessable from a path. `npm install -g sasso` puts a
  `sasso` on `PATH` that IS this CLI behind a `#!/usr/bin/env node` line, so
  delegating to it would fork bomb: the candidate must be a native executable
  image (ELF / Mach-O / PE magic bytes), and the child is marked so that a
  second hop is refused whatever it turns out to be. Identity is the whole
  `--version` output, `sasso <version>` and nothing else: reading only the
  version out of it would let any other project's `sasso` that prints a matching
  number take the command line, and reading only its first line would let
  anything that leads with a plausible one. And `wasm/test.mjs` had to
  turn delegation off for itself — every CLI case there is about what `cli.mjs`
  does, and on a machine with a matching binary installed the flag-parity guard
  (which exists because the two CLIs drifted apart in the first place) would
  have interrogated the binary twice and agreed with itself.

  One thing comes out better than it went in: a delegated compile error exits
  65, as dart does, where this CLI exits 1 for everything (#91).

- **`--silence-deprecation=<ids>`**, on both CLIs and as `silenceDeprecations`
  in the JS API (#24). dart's flag for dropping named deprecations while every
  other warning still prints — which is the point of it over `--quiet`, and
  why Lichess moved to it and then found sasso rejecting the flag.

  The accepted ids are dart-sass 1.104.1's whole `Deprecation` enum — all 31,
  of which sasso emits six today. The rest are accepted and do nothing, so a
  build script written for `sass` does not fail for naming one.

  An id dart does not know is handled as dart handles it, which differs between
  the two front ends and is measured rather than assumed: the CLI rejects it
  with `Invalid deprecation "nope".` (dart exits 64, so a typo is caught rather
  than quietly leaving the warning in place), while the JS API warns with that
  same text through the caller's own `logger` and compiles anyway. Throwing
  from the API would be stricter than dart and would fail builds dart accepts.

  Silencing happens inside the compiler, beside `quietDeps`, not in a warn
  handler. Filtering further out drops the warnings but still counts them, and
  the run then ends with "N repetitive deprecation warnings omitted" tallying
  exactly the ones the caller silenced — dart prints nothing at all there.

  The wasm module gains `sasso_compile3` for it; `sasso_compile2` stays and
  delegates, so a host built against it keeps linking.

- **`sasso --engine`**, and a loud wasm fallback, in the npm CLI (#24). The
  engine the CLI picked was unobservable: an install whose native addon did not
  land compiled through wasm at roughly half the throughput and said nothing
  about it, so "which engine am I running?" was answerable only by bisecting the
  install. `--engine` now prints the engine, why it is that one, the platform
  key the decision came from, and — when the addon was tried and failed — the
  reason it failed.

  A compile that fell back on a platform that HAS a prebuilt addon also warns on
  stderr, once per run. It stays quiet under `--quiet` (dart's contract: that
  flag means "don't print warnings"), under `SASSO_ENGINE=wasm` (which states
  the intent), on platforms where no addon is prebuilt at all (musl, Windows),
  since wasm is the engine that is supposed to run there, and for an addon
  refused over a version skew (above), which has already been reported in more
  detail. The prebuilt-platform table the loader resolves from now answers the
  CLI too, so the CLI's idea of which engine is "expected" cannot drift from the
  list of prebuilds.

### Fixed

- **A native addon whose version does not match the `sasso` loading it is now
  refused** instead of being used (#114). `sasso` pins the four
  `sasso-native-*` packages as exact-version `optionalDependencies`, so a plain
  install cannot drift; a consumer that also names them itself has a second
  place to bump, and the two can fall out of step.

  That was silent, and silently wrong: napi ignores config fields it does not
  know without erroring, so an addon one release behind accepted every option
  the newer JS sent and applied only the ones it recognised — the compile
  succeeded and quietly did something else. A flag accepted that does nothing
  is the bug that opened #24; this was the same bug with no flag to blame.

  `sasso/native` now throws, naming both versions and the fix. The CLI, which
  picks an engine itself, falls back to wasm — byte-identical output, so the
  build stays correct — but says so on stderr, because replacing a wrong
  compile with a silently slower one is not a fix. `SASSO_NATIVE_BINARY` and
  the repo-local `napi/npm/sasso.node` are development paths with no manifest
  to compare and stay unchecked.

- `info` from `sasso/native` reported `napi/Cargo.toml`'s version (`0.1.0`) as
  `(sasso-native <ver>)`, which reads as the sasso version and is not one. It
  now reports the platform package's real version.

- **Compressed `color()` output was not a color** (#110). The predefined
  `color()` spaces separate their space name and channels with mandatory
  whitespace, but compressed mode ran that separator through the same variable
  that strips the spaces around `/`, so `color(display-p3 0.5 0.2 0.9)` came out
  as `color(display-p3.5.2.9)` — one token no browser resolves, which drops the
  declaration. Expanded output was always correct, so this only ever hit
  production builds. Legacy spaces reaching the modern space-separated form
  through a missing channel (`rgb(1 2 none)`) were unaffected.

- **A calc's `+ -n` operator flip is not an expanded-mode courtesy** (#110).
  dart-sass performs it while it builds the operation
  (`SassCalculation._operateInternal` negates the operand and swaps the
  operator when `right.value < 0`), so the flipped form is what its serializer
  receives in every output style. sasso did it at serialization time and only
  when expanded, so compressed builds kept `calc(var(--a) + -2px)` where dart
  writes `calc(var(--a) - 2px)`. The condition is now exactly dart's `< 0`,
  which also fixes the other half: `-infinity` flips
  (`calc(1px + -infinity * 1em)` → `calc(1px - infinity * 1em)`) in both styles,
  while `-0` and `NaN` correctly keep their operator.

  Neither divergence is covered by a spec the ratchet counts as passing
  (conformance runs expanded output only), so both now have offline goldens in
  `tests/integration.rs` and live dart cross-checks in `tests/parity.rs`.

## [0.16.0] - 2026-09-18

_The release that closes #83. The npm CLI had three reasons to be slower than
the binary running the same compiler; the last of them was that the addon ran
it on the system allocator while the binary ran it on a bump arena. On the
Lichess tree the npm CLI is now 9.7x dart-sass rather than 8.5x — measured
from the published packages, not a build tree — and its remaining gap to the
binary is Node start-up rather than compile work. `-j`
also stops counting SMT threads as cores, on both front ends._

### Added

- **A NUR entry point, `nix/nur.nix`** (#82). nixpkgs declined the CLI for the
  time being on the maturity questions in its own `pkgs/README.md`
  ([NixOS/nixpkgs#564362](https://github.com/NixOS/nixpkgs/pull/564362)) and
  pointed at the [Nix User Repository](https://github.com/nix-community/NUR)
  instead, so `nur.repos.momiji-rs.sasso` becomes the channel-shaped way in for
  configurations that would rather name a package than a flake URL. It
  re-exports the two derivations the flake already builds, which is why it
  carries no hash and no version of its own: a release bumps `Cargo.toml` and
  the channel follows. Registration against nix-community/NUR is open, not yet
  merged — `nix/README.md` says what flips when it lands.

### Changed

- **The native addon compiles 14-26% faster**, closing the last of the three
  gaps in #83. It was running the compiler on the system allocator: the binary
  installs sasso's bump arena as its `#[global_allocator]` and the addon never
  did, so `compile()`'s scope primitives were inert and every allocation in the
  compiler went to the system. Measured on 138 Lichess stylesheets through the
  npm CLI, native engine: `-j 1` 1.05 s -> 0.86 s, `-j 4` 0.36 -> 0.31, `-j 12`
  0.31 -> 0.23. Output is unchanged — CSS and `loadedUrls` for all 138 are
  byte-identical with and without it.

  The arena trades memory for speed and now does so here as it already does in
  the binary: peak RSS at `-j 12` goes from 318 MB to 677 MB, against the
  binary's own 124 MB to 478 MB for the same corpus. `-j 1` costs 55 MB.

- **`-j` defaults to physical cores, not SMT threads**, in both the binary and
  the npm CLI, wherever the core count can be known — Linux, from
  `/proc/cpuinfo`. Off Linux the default stays the CPU count, exactly as
  before. On a Linux that publishes no topology the core count is unknown, so
  the default is the CPU count the process may actually use — which on Node 16
  to 18.13 is a change in its own right, since the old fallback counted the
  host and ignored both an affinity mask and a CPU quota. A compile is pure
  computation, so two hyperthreads on one core contend for the same execution
  units rather than overlapping each other's stalls. On Linux / x86_64, 8 cores
  and 16 threads, over 138 Lichess stylesheets, at each CLI's own default:
  the binary goes 229 ms -> 207 ms and the npm CLI 444 ms -> 364 ms, with
  byte-identical output (138 of 138). On a machine without SMT the two counts
  are equal and nothing changes. `-j N` still means exactly what it says.

  The count comes from `/proc/cpuinfo` on Linux and is capped by what the
  process may actually use, so an affinity mask (`taskset`, a cpuset) or a
  cgroup CPU quota (`docker --cpus`, a Kubernetes CPU limit, a systemd
  `CPUQuota=`) still wins, whether the quota sits on the process's own cgroup
  or on a slice above it. The binary and Node 22 get the quota from the runtime
  — earlier Node does not, including the 18 and 20 LTS lines — so the npm CLI
  reads the standard `/sys/fs/cgroup` paths itself on every version; a
  hierarchy mounted elsewhere falls back to the core count. It is deliberately
  not the number of cores *inside* an affinity mask: SMT only stops paying once
  enough cores are in play, and restricted to two cores, using both SMT
  siblings measured 50% faster.

### Fixed

- **The bump arena no longer leaks a reservation per thread** (#107). A
  thread's region was never given back — on native that is 2 GiB of address
  space each — so an embedder whose threads are short-lived accumulated one per
  thread that had ever compiled. The binary never noticed, with its fixed pool
  for the process lifetime; the napi addon spawns a thread per async compile,
  and grew the process by a full reservation per compile until Linux refused
  the next `fork()` with `ENOMEM` and the host could not spawn a child at all.
  Regions are pooled now and leased for the length of one compile.

  Two consequences beyond the leak. `MAX_ARENAS` caps *concurrent compiles*
  rather than threads that have ever run: the registry handed slots out from a
  counter that only went up, so past 128 threads a slot claim failed
  permanently and every later compile on that thread ran on the system
  allocator — silently, at the speed the arena exists to avoid. And
  `in_any_arena` reads the published `base` with `Acquire`; relaxed paired with
  a `Release` store is no pairing at all, and a weakly ordered target (aarch64,
  which this ships on) could see a fresh `base` beside the `end` that preceded
  it and hand a live arena pointer to `System` to free.

  Only embedders that install `ScopedAlloc` are affected, which today means the
  binary, the wasm module and — as of this release — the native addon.

### Performance

- **Five more rounds of allocation work, and the campaign's close** (#96, #97,
  #100, #101, #106), each verifying the sass-spec ratchet at delta +0 (14,107
  passing throughout). Same corpus and the same two metrics as the rounds in
  0.14.0 and 0.15.0 — instructions retired and allocation count on
  `bench/corpus/generated/large.scss`. These rounds report their instruction
  result as a percentage, because a round's two arms are built and measured
  interleaved in one window rather than against a standing absolute:

  | | change | instructions | allocations |
  |---|---|---|---|
  | #96 | every value serializes into the buffer it is destined for, instead of building a string per nested element, per color channel and per interpolation | -3.185% | 155,656 → 131,289 (-15.65%) |
  | #97 | a block reuses a closed block's scope table, and rebinding a loop variable overwrites the value through the key the map already holds | -1.149% | 131,289 → 117,700 (-10.35%) |
  | #100 | a color literal's authored spelling is a shared `Rc<str>`, and `Color` shrinks 64 → 56 bytes | -1.121% | 117,700 → 110,835 (-5.83%) |
  | #101 | a declaration value serializes through one reused buffer, and a template reserves its literal bytes up front | -1.530% | 110,835 → 99,614 (-10.12%) |
  | #106 | a `calc()` writes itself into the caller's buffer, retiring the last value that could not | -0.090% | unchanged — that corpus evaluates no calculation |

  #106 is the round that pays elsewhere: a calc-heavy sheet goes **-19.28%
  instructions and -28.40% allocations**, and it held the largest single
  allocation site left in the compiler.

  End to end that is **109.616M → 102.048M instructions (-6.90%)** and
  **155,656 → 99,614 allocations (-36.0%)** on that corpus. Measured over the
  whole campaign — one interleaved comparison of the tree before its first round
  against this one — **133.839M → 102.048M (-23.75%)** and **377,761 → 99,614
  (-73.63%)**, with `wrap` -31.15%, `calc` -27.20%, `modcalls` -19.63%,
  `colors` -19.49%, `units` -17.09% and a `@use` graph -11.81% instructions.

  **The campaign is closed**, and what closed it is worth recording. Building a
  list literal's `Rc<[Value]>` in one allocation instead of two removed
  allocations on five corpora and made every one of them *slower* (+0.010% to
  +0.611% instructions): a compile runs on a bump arena, where an allocation is
  a pointer bump, while moving 64-byte values into the slice one at a time
  replaces a single bulk copy. It was measured and never committed.
  `docs/PERF_PLAN_2026-09-16.md` Part D has that bisect, what an allocation
  turned out to be worth (~17 to ~287 instructions, median ~103), and where the
  remaining instructions are.

## [0.15.0] - 2026-09-17

_The release that makes `npm install sasso` as fast as the binary the release
notes describe, and puts sasso on Nix. The npm CLI had been compiling one file
at a time through the size-optimised wasm build while the native addon it had
already downloaded sat unused — 2340 ms for a tree the binary does in 137 ms.
It is 266 ms now. `nix run github:momiji-rs/sasso` works, which is what #24's
NixOS maintainer asked for. Five more rounds of allocation work ride along._

### Added

- **A Nix flake: the `sasso` CLI and the C ABI** (#82, #90). `nix run
  github:momiji-rs/sasso -- --version` works the moment this tag exists, with
  no nixpkgs review to wait for. `nix/ffi.nix` packages the C ABI the way a
  consumer needs it — `libsasso.{so,dylib}`, `libsasso.a`, `sasso.h` and a
  pkg-config file — and both derivations read their version from the
  `Cargo.toml` they are built from, so a release bumps one number and the flake
  follows. `nix flake check` builds three derivations, and because the sandbox
  has no network it runs all 15 suites rather than merely compiling; a `nix
  flake` CI job runs them on ubuntu and macos so the packaging cannot rot
  silently between releases.

### Changed

- **The npm CLI uses the native addon when it is installed, and compiles files
  in parallel.** It did neither: it hard-coded the size-optimised wasm build
  even though `npm install sasso` had already fetched
  `sasso-native-<platform>` as an optionalDependency, and it compiled
  sequentially while `-j/--jobs` was accepted and ignored. Compiling the 138
  Lichess stylesheets that build without npm dependencies, with lila's own
  flags (it passes no load paths) on a 12-core machine, best of five, one run
  for the whole table (2026-09-17):

  | | |
  |---|---|
  | `npx sasso` before | 2340 ms |
  | `npx sasso` after (native engine) | **266 ms** |
  | `npx sasso` after (wasm engine) | 610 ms |
  | the `sasso` 0.15.0 binary | 137 ms |
  | dart-sass 1.104.1 | 2268 ms |

  So the npm package was at parity with the thing it replaces, and is now
  within 1.9× of the release binary — with output byte-identical to that
  binary in every engine/concurrency combination (138 of 138, both engines,
  checked against the published artifacts).

  The "after" figures are measured against what `npm install sasso` actually
  fetches. An earlier draft of this entry quoted 228 ms, taken from a locally
  built addon that no commit in this repository produces — 318 KB larger than
  any build of this source, most likely a leftover from an abandoned
  experiment. Building v0.15.0 here reproduces the published artifact to
  within 64 bytes and the same speed, and every perf round from #81 to the tag
  measures within noise of it, so the number was wrong, not the release.

  The pool is `node:worker_threads` with workers pulling from a shared index,
  so one heavy stylesheet cannot leave the others idle, and `--stop-on-error`
  is a shared flag: whoever fails stops the rest from taking new work, which is
  the native CLI's "don't start more files once one fails". A single job and
  `-j 1` stay in-process — a worker costs more than the compile — and so does a
  batch whose writes overlap its own paths, because dart's last-one-wins and
  its write-then-read are orders and an order needs a sequence: two jobs naming
  one output file (a job's `<output>.map` sidecar counts, so `a.scss:out.css`
  and `b.scss:out.css.map` collide), or one job writing a path another job
  reads (`a.scss:b.scss b.scss:out.css`). Under `--no-css` none of that applies
  — nothing is written — so the batch keeps the pool. A `-` job reads standard
  input once, in the parent, so it no longer costs the rest of the batch its
  parallelism (138 Lichess stylesheets plus one `-` job: 767 ms to 217 ms).
  `SASSO_ENGINE=wasm|native` forces an engine — and only for the CLI:
  `import … from "sasso"` is always the wasm build.

  Only entry paths are compared: a job that writes a file another job `@use`s
  is the same hazard and cannot be seen before compiling, so it stays a
  scheduling race, as it is in the native CLI (#87).

  The job list and standard input reach the workers through shared memory
  rather than being structure-cloned into every one: a 5,000-file directory
  build at `-j 12` peaks at 234 MB instead of 283 MB, and 5.1 MB on stdin
  beside 24 file jobs at 838 MB instead of 901 MB, with no change in wall time.

  Each job's warnings and errors are collected and printed in **command-line
  order**, as whole blocks, however the threads interleaved — the order the
  native binary reports at every `-j`. A job with no output file is the
  exception: its CSS goes to the same terminal, so its warnings are written
  before it, which is what dart and the native binary do.

  What that flag means now differs at the edges: `--stop-on-error` skips the
  remaining files at `-j 1` but not necessarily at the default, because they
  have already started — the native CLI behaves the same way (measured
  2026-09-17), and the test that assumed otherwise was pinning a
  sequential-only accident (#83).

### Fixed

- **`sasso --version` on the npm package prints the package's version.** It
  parsed the engine's `info` string, which names the engine crate: with the
  native addon installed the pattern missed, and the fallback printed
  dart-sass's compatibility version as if it were sasso's.

- **`--help` and `--version` no longer need a working engine.** The CLI loaded
  the compiler before parsing arguments, so `SASSO_ENGINE=native sasso
  --version` on a machine without the addon answered with the addon error
  instead of the version.

- **A trace-frame test no longer depends on where the build tree sits.**
  `module_callables_know_whether_they_are_a_mixin` asserted on the whitespace
  padding of a stack frame, which varies with the scratch tree's path relative
  to the working directory — so the suite failed inside a build sandbox (Nix
  builds in `/build/source` with `$TMPDIR=/build`) while passing everywhere
  else. Nothing about sasso's behaviour differed; a test's assumption did.
  Downstream packagers can build this tag without carrying a patch.

### Performance

- **Five more rounds of allocation work in the evaluator** (#81, #88, #89, #92,
  #93), each verifying the sass-spec ratchet at delta +0 (14,107 passing
  throughout). Continuing the campaign the four rounds in 0.14.0 began, and
  measured the same way — instructions retired on
  `bench/corpus/generated/large.scss`, which is the corpus every round reports:

  | | change | instructions | allocations |
  |---|---|---|---|
  | #81 | a block gets `@function`/`@mixin` frames only when a declaration lands in one or a closure captures the chain, instead of ~14,400 empty tables per compile | 126.330M → 124.843M (-1.176%) | 275,297 → 260,895 (-5.23%) |
  | #88 | a built-in call stops collecting argument spans nothing will read — a compile that is not building a source map — and stops cloning a module's name on every `ns.member()` | 124.843M → 122.939M (-1.525%) | 260,895 → 244,093 (-6.44%) |
  | #89 | the nested-selector resolver borrows segments instead of copying every character into a `Vec<String>`, and a comma-free selector skips the row-of-rows scaffolding | 122.939M → 117.993M (-4.023%) | 244,093 → 212,093 (-13.11%) |
  | #92 | a number's unit is an `Rc<str>` shared on clone and interned per file, so cloning a `Number` is a refcount bump | 117.993M → 113.883M (-3.483%) | 212,093 → 181,630 (-14.36%) |
  | #93 | an interpolation template hands back its literal text instead of rebuilding it, and a literal selector borrows the AST's text | 113.883M → 109.616M (-3.747%) | 181,630 → 155,656 (-14.30%) |

  End to end that is **126.330M → 109.616M instructions (-13.2%)** and
  **275,297 → 155,656 allocations (-43.5%)** on that corpus. (Those two totals
  are arithmetic on the endpoints above; each round reports only its own pair.)

  Where a round lands depends on what a sheet does, and the spread is the point:
  #89 takes a deeply nested sheet -10.417% on its own, #92 takes a unit-heavy
  one -7.039% and a namespaced-call one -6.506%, #93 takes those two -4.780%
  and -4.494%. `extend_heavy.scss` moves least in every round (-0.013% to
  -0.149%), which is the expected shape: it spends its time in `@extend`, not
  in the paths these rounds touch.

## [0.14.0] - 2026-09-17

_The release that makes the npm package the CLI the release notes have been
describing. 0.10.0 gave the `sasso` binary a dart-compatible command line and
the npm package did not get it — reported on #24 by someone whose build it
broke — so `npm install sasso` shipped a command that rejected every flag a
dart-sass build script passes except `--quiet`. It accepts them all now, and
behaves as the native CLI does down to the argument grammar, the source-map
shapes and the error wording._

_**0.14.0, not 0.11.0**: the crate skips forward to meet the npm package, which
is at 0.13.0 and cannot go back — npm forbids republishing a version, so the
packaging iterations of June and July 2026 burned three minors that the crate
never spent. From here the two lines carry the same number, and
`release-wasm.yml` enforces it: an `npm-v*` tag whose version does not equal
`Cargo.toml`'s fails before anything reaches the registry._

_No output changes: the sass-spec ratchet is unchanged at 14,107 of 14,258
attempted (98.94%, delta +0) against dart-sass 1.104.1 and sass-spec
`b39c3276`._

### Added

- **`DependencySet::mark` (crate)**: record a stylesheet as a dependency from an
  embedder's own importer. `FsImporter` fills its record from its own
  resolution, but an embedder that resolves load paths itself — the wasm bridge,
  whose host does every file lookup — needs a way in, or `quietDeps` has nothing
  to consult. Previously crate-private as `insert`.
- **`unicode` in the npm package's JS API** (the CLI's `--[no-]unicode`):
  `unicode: false` renders diagnostics with the ASCII glyph set. dart-sass
  exposes this on its command line only, so it is a sasso extension — but its
  CLI flag is not a no-op there, and was one here.
- **`quietDeps` in the npm package's JS API** (dart-sass `quietDeps`): drops
  deprecation warnings raised inside dependencies — stylesheets reached through
  a `loadPaths` directory or a custom importer, and whatever those load
  relatively. The compiler applies it from how each file was RESOLVED, which is
  what dart does: a stylesheet the entry loads relatively still warns, even from
  inside a load path, and a dependency's own `@warn`/`@debug` still reaches the
  logger. Doing it inside the compiler also keeps a silenced warning from
  counting toward the deprecation repetition cap.

### Fixed

- **The npm package's CLI accepts the dart-sass flags.** `sasso` ships two
  command-line implementations — the Rust binary and `cli.mjs` in the npm
  package — and 0.10.0's dart-compatible CLI work only reached the first. So
  `npm install sasso` gave a command that rejected every flag a dart-sass build
  script passes except `--quiet`:

  ```
  $ sasso --no-error-css --stop-on-error --no-color --quiet --quiet-deps in.scss:out.css
  error: unknown option "--no-error-css" (try --help)
  ```

  Reported on #24 by someone whose build it broke, after release notes that
  advertised a CLI one of the two distribution channels did not have. The npm
  CLI now accepts every flag the native one does — implementing
  `--quiet-deps`, `--stop-on-error`, `--no-css`, `--source-map-urls`, the
  `--no-*` negations and `<dir>:<dir>` pairs, and accepting `-c/--color` and
  `-j/--jobs` as documented no-ops (the first is one in the native CLI too, the
  second has no meaning without parallelism). `--error-css` is accepted but not
  implemented: a failing compile still behaves as `--no-error-css`, which the
  help text says.

  A test derives the flag set from the Rust parser and fails if this CLI
  rejects any of them, so the next flag added to one has to reach the other.
- **The npm CLI's source maps are the ones dart writes.** Its `sources[]` were
  absolute `file://` URLs where dart's default (`--source-map-urls=relative`)
  is the path from the `.map` file — `../sub/_x.scss`, not
  `file:///home/me/app/sub/_x.scss` — so a map moved with its CSS resolved
  nothing. `--embed-source-map` wrote base64 where dart writes a percent-encoded
  `data:application/json;charset=utf-8,…` URI, expanded output lost dart's blank
  line before the `/*# sourceMappingURL=… */` footer, and the JSON's fields came
  out in a different order without `sourceRoot`. `--source-map-urls` is now
  implemented rather than parsed and dropped, and a `<dir>:<dir>` job into a
  fresh tree no longer dies with `ENOENT` writing the `.map` before creating the
  directory.
- **The npm CLI's directory mode walks dart's tree.** It listed entries with
  `Dirent.isDirectory()`, which is false for a *symlinked* directory, so whole
  subtrees silently vanished from the output; it also skipped plain `.css`
  sources, which dart compiles. It now follows symlinked directories — each one
  once, by canonical identity, so a cycle cannot loop — sorts for a
  reproducible mirror, and skips sources inside the destination when the
  destination is nested in the source tree. `sasso <dir>` compiles a tree in
  place, and `-o`/`--output` names an output file, both as the native CLI does.
- **The npm CLI enforces the same argument grammar as the native one.** It
  accepted shapes the native CLI (and dart) reject, so one command line meant
  different things depending on which sasso was installed: a third positional
  argument was silently ignored rather than `Only two positional args may be
  passed.`, a second one under `--stdin` likewise, `:out.css` / `in.scss:` /
  `in.scss:out:other.css` were taken as paths, `in.scss:a.css in.scss:b.css`
  compiled twice instead of `Duplicate source "in.scss".`, and a file named by
  both a directory pair and an explicit pair was compiled twice and published
  to both destinations rather than once to the last. `--jobs`/`--loop` now
  reject a non-positive value, `-` (and `-:out.css`) reads standard input, a
  directory pair that expands to nothing exits 0 rather than claiming there was
  no input, and the source-map combinations dart rejects
  (`--embed-sources`/`--embed-source-map`/`--source-map-urls` with
  `--no-source-map`) are rejected for a file output too, not only for stdout.
- **`--no-unicode` and `--loop` did nothing in the npm CLI.** Both are real
  flags of the native CLI, and both were accepted and dropped on the floor:
  `--no-unicode` left every diagnostic in Unicode box glyphs where the native
  CLI and dart switch to ASCII, and `--loop N` compiled once instead of N times
  and reported no throughput. The compiler now takes `unicode` through the wasm
  bridge and the native addon alike, and `--loop` measures and reports as the
  native CLI does (stdout only, warnings silenced, no source map).
- **The npm CLI's source-map URLs are encoded as dart encodes them.** Segments
  were run through `encodeURIComponent`, which escapes the sub-delimiters dart
  keeps, so a source or output named `the+me,1.scss` was spelled
  `the%2Bme%2C1.scss` in `sources[]`, in the map's `file` and in the
  `sourceMappingURL` footer. A `--stdin` entry also named itself `stdin` where
  dart records the source TEXT as a `data:;charset=utf-8,…` URI. `--no-css` no
  longer builds a source map it is about to discard.
- **The npm CLI drops a stale output when a compile fails.** It always behaves
  as `--no-error-css`, and dart then *removes* the output file rather than leave
  the last good build in place for a server to keep serving. `--no-css` now
  means no output-side effects at all — it applies to `--stdin` and `--watch`
  too, not only to batch jobs.
- **An attribute selector's value is decoded and re-quoted, not echoed.** The
  value between the quotes was copied through verbatim and wrapped in double
  quotes, so a single-quoted value containing a `"` produced invalid CSS:
  `[a='b"c']` came out `[a="b"c"]`, which a browser reads as `[a="b"` followed
  by garbage, silently dropping the rule. dart decodes the escapes and
  re-serializes — an identifier loses its quotes, everything else takes
  whichever quote needs fewer escapes — so `[a='b"c']` is `[a='b"c']`,
  `[a="b\"c"]` is `[a='b"c']`, `[a='b"c\'d']` is `[a="b\"c'd"]`, and
  `[a="-leading"]` is `[a=-leading]`. Hex escapes decode too, delimiter
  whitespace and all (`[a="\61 bc"]` is `[a=abc]`) (#61).

### Performance

- **Four rounds of allocation work in the evaluator** (#68, #73, #76, #77), each
  verifying the sass-spec ratchet at delta +0. Two corpora run through all four
  — `bench/corpus/generated/large.scss` and `bench/corpus/gate/extend_heavy.scss`
  — and the later rounds add more (`handwritten/main.scss` from #73, a
  long-selector sheet from #77). On `large.scss`, instructions retired:

  | | change | delta |
  |---|---|---|
  | #68 | a one-element `Vec` in `split_commas`, and a lowercased copy allocated only to compare a function name | -0.516% |
  | #73 | a rule's selector list resolved once and shared, rather than per use | -2.614% |
  | #76 | that shared list carried into the output tree instead of re-materialized | -0.764% |
  | #77 | selector scanners reading from a 64-character inline buffer, so a scan over a selector that fits touches the allocator not at all (longer input keeps the heap `collect`) | -1.825% |

  Together **133.840M → 126.330M instructions (-5.61%)** and **377,761 →
  275,297 allocations (-27.1%)** on that corpus — the reallocation share fell
  furthest, since the scanners had been growing a `Vec<char>` from a quarter of
  the size it needed. `extend_heavy.scss` moved least, 59.395M → 59.143M
  (**-0.424%**), which is the expected shape: it spends its time in `@extend`,
  not in scanning. The sheet of deliberately long selectors — the one that
  spills past the inline buffer — still improved in #77, -0.987% instructions
  and -2.79% allocations, so the spill path costs nothing it did not cost
  before.

## [0.10.0] - 2026-09-17

_A dart-sass-compatible CLI, alignment with dart-sass 1.104.1, and the
compatibility work that came out of compiling the Lichess stylesheets (#24).
Minor rather than patch: the CLI gains a whole argument grammar, and several
outputs change — a negative zero keeps its sign, colors convert their
degenerate channels, and the legacy color adjusters keep the color's own
space._

_Against the 148-entry-point Lichess corpus, sasso is byte-identical to
dart-sass 1.104.1 on 147 files in **both** output styles, with 148/148
identical source maps. Every known remaining difference is written down in
[`docs/dart-sass-divergences.md`](docs/dart-sass-divergences.md)._

### Added

- **dart-sass-compatible CLI.** `sasso` now takes the same arguments as
  `sass`, so a build script written for dart-sass runs unchanged (#24, the
  Lichess build spawns one process with ~150 `src:out` pairs):
  - the positional grammar is `<input> [output]` (a second positional is the
    output file; `--stdin [output]`; an input of `-` is standard input, and a
    `-:<out>` pair is standard input to a file alongside other pairs — dart's
    rules, including `Duplicate source` for a repeated one; a bare directory
    positional compiles in place, `sass dir` being `dir:dir`; `--` ends option
    parsing so a name starting with `-` can be an input or output), and
    `<in>:<out>` pairs — files or a whole directory tree (`scss/:css/`,
    partials skipped, `.sass` and `.css` inputs by exact lowercase suffix as
    in dart, a `.css` whose destination would be itself skipped as in dart;
    two spellings of one source — explicit or directory-expanded — coalesce
    to the later destination) — compile many stylesheets in one process;
  - **several inputs compile in parallel**, one worker per CPU (`-j/--jobs N`
    to cap it), with diagnostics and exit status reported in command-line
    order; `--stop-on-error` stops scheduling more files after a failure.
    The full Lichess corpus (148 entry points, source maps with embedded
    sources) builds in 0.79 s against dart-sass's 1.40 s on arm64 macOS;
  - `--[no-]source-map` (on by default when writing a file, like dart; the
    `.map` is written before the CSS that references it, and the map's `file`
    and the footer URL are percent-encoded like dart's),
    `--[no-]embed-source-map` (the map inlined as a `data:` URI, byte-exact
    to dart including its percent-encoding; absolute `file://` sources and no
    `file` field on stdout), `--[no-]embed-sources`, `--source-map-urls`; the
    combinations dart rejects are usage errors here too, with dart's wording;
  - `--[no-]error-css`: on a compile error, a file target receives dart's
    error stylesheet (the diagnostic as a comment plus a `body::before` that
    shows it in the browser), byte-exact to dart-sass; with it off, a stale
    output from an earlier build is removed instead, as dart does. Invalid
    UTF-8 input counts as a compile error here too. `--error-css` also
    prints the stylesheet to stdout;
  - `-q/--quiet` (no warnings), `--quiet-deps` (no compiler warnings from
    dependencies — files resolved through a load path, by how they were
    resolved rather than where they live; their `@warn` still prints),
    `--[no-]charset`, `-c/--[no-]color` (accepted; sasso never colors),
    `--no-css` (compile, report diagnostics, write nothing);
  - dart's exit codes: 64 for a usage error, 65 for a compile error, 66 for
    an unreadable input (`Error reading <path>: Cannot open file.`) or an
    output that cannot be written (invalid UTF-8 on stdin is a compile error
    with the same error-CSS handling as a file's — dart crashes there);
    missing output directories are created; a CSS file always ends in one
    newline, an empty stylesheet included (stdout gets nothing for empty
    output), as dart writes it; one unit's diagnostics are separated from the
    next by a blank line, as dart prints them.
- **`WarnEvent::path`**: the stylesheet a `@warn`/`@debug`/deprecation came
  from, as an identity rather than dart's short display form in `url` (a
  load-path file's basename): for a file the importer loaded, the importer's
  canonical URL (an absolute path with `FsImporter`); for the entry
  stylesheet, `Options::url` exactly as supplied. Lets an embedder tell a
  dependency from the entry, which is what `--quiet-deps` needs.
- **`FsImporter::dependencies()`** returns a shared `DependencySet` that fills
  in as the compile resolves imports: which files were reached through a load
  path (or loaded relatively from one that was) — dart-sass's "dependencies".
  Keyed by canonical URL, so it pairs with `WarnEvent::path`.
  **`Options::with_quiet_deps(set)`** (dart-sass `quietDeps`) drops
  deprecation warnings raised inside those files before they are counted, so
  they neither use up the five visible repetitions nor surface as "N
  repetitive deprecation warnings omitted". The record is per compilation:
  a compile scoped on the set starts it empty, and a nested compile (a warn
  handler running `compile` with the same importer) hands the enclosing
  record back when it ends, so an importer reused sequentially or nested
  cannot leak one compile's classification into another — concurrent
  compiles sharing one set are not supported (`DependencySet::clear` for
  embedders reading the set by hand). Provenance
  also follows the evaluator's `@import` cache: a file a dependency loads is
  a dependency even when its resolution was cached by an earlier load.

### Changed (dart-sass 1.104.x alignment)

- **The reference pins move to dart-sass 1.104.1** — the CI parity binary
  (`sass@1.103.1` → `sass@1.104.1`), the sass-spec pin (`4a9eea66` →
  `b39c3276`, 2026-09-08) and `spec/BASELINE.json` (14061 → 14107 passing).
  Every behaviour change in 1.104.0 and 1.104.1 is implemented below, except
  two: the indented-syntax parser crash 1.104.1 fixes has no reproduction
  here, and the output file's modification time now reflecting when
  compilation STARTED is a watch-mode rebuild concern that sasso, having no
  watch mode, has nothing to rebuild from. On the Lichess corpus sasso stays
  byte-identical to dart on 147 of the 148 entry points in BOTH output
  styles.
- **A negative zero keeps its sign.** `0 * -1`, `-0` and `math.div(0, -1)`
  now serialize as `-0`. The sign is the IEEE sign bit, not the way the
  number was written, so `0 - 0`, `0 + -0` and `-0 * -1` stay `0`, and a tiny
  negative that merely rounds to zero (`-1e-11`) was never a zero at all. A
  rounding RESULT is an integer and so is never a negative zero:
  `math.round(-0.4)`, `math.ceil(-0.4)` and `round(to-zero, -0.4, 1)` are `0`.
- **Colors convert their degenerate channels.** A `NaN` channel becomes `0`
  in every color function — it stops being degenerate at all, so the call
  parses into an ordinary color instead of a preserved `calc()` spelling —
  and a polar HUE converts every non-finite value: `hsl(calc(NaN), 50%, 50%)`
  is `hsl(0, 50%, 50%)`, `lch(1% 2 calc(infinity))` is `lch(1% 2 0deg)`,
  `color(srgb calc(NaN) 0 0)` is `color(srgb 0 0 0)`. An infinite non-hue
  channel is the only one still written as a `calc()`
  (`hsl(0, calc(infinity * 1%), 50%)`). The conversion runs wherever a color
  is built, so it also reaches a channel a computation produced — an hwb
  color with an infinite whiteness, or `color.change(red, $hue: NaN)`, which
  is red. A color channel also drops a negative zero, the alpha included
  (`color(srgb 0 0 0 / -0)` is `… / 0`), which is the exception to the rule
  above.
- **A comment before `@use` is emitted exactly once.** Up to 1.104.0 a REPEAT
  edge into an already-loaded module re-emitted the comments that had
  preceded its first load — a second `@use` of it from the same file, or a
  sibling or nested module's, each wrote another copy. 1.104.1 removed the
  behaviour, and so does this release, along with the machinery that mirrored
  it.
- **A many-to-many compile skips sources inside a nested output directory.**
  `sasso .:css` run twice used to mirror `css/` into `css/css/`. Nesting is
  strict — `sasso dir` (which is `dir:dir`) still compiles every file — and
  it is the destination that counts, not an intermediate directory.

### Changed

- **Library:** `WarnEvent` is now `#[non_exhaustive]` and gained the `path`
  field. Code that receives events (every handler in this repo and its
  napi/wasm bridges) is unaffected; code that built a `WarnEvent` with a
  struct literal or matched it exhaustively must adapt.
- **CLI (breaking):** `-q/--quiet` now means "don't print warnings", as in
  dart-sass. The old meaning — compile but discard the CSS, for timing runs —
  is `--no-css`. Writing to a file (`-o`, a second positional, or a pair) now
  produces a source map by default; pass `--no-source-map` to opt out. More
  than one positional input is no longer a multi-file stdout batch (dart
  reads a second positional as the output); use `in:out` pairs. `--source-map`
  to stdout is a usage error unless `--embed-source-map` is given. Usage
  errors exit 64 (was 1).

### Fixed

- **Only positional arguments count toward a function's arity.** Every
  built-in summed the positional and named counts, so both halves of
  dart-sass's sentence came out wrong: `lighten(red, 10%, 3, $nope: 1)` said
  `Only 2 arguments allowed, but 4 were passed.` where dart says `Only 2
  positional arguments allowed, but 3 were passed.` — the word "positional"
  appears the moment any named argument is in play, and the count is of the
  positional ones alone. User-defined functions gain the same wording, and
  `hwb($nope: 1)` no longer reports an overflow for a call with no positional
  arguments at all. Where two errors could both apply, dart's order now holds:
  a positional overflow is reported before an unrecognized parameter name.
- **`Missing argument $x.` no longer names a function, and no longer names the
  wrong one.** Every built-in appended ` for <name>()` to dart-sass's message,
  and the name it appended was the GLOBAL alias — so `color.adjust()` reported
  `Missing argument $color for adjust-color().`, blaming a function the author
  never wrote, where dart says `Missing argument $color.` (the frame underneath
  already points at the declaration the parameter belongs to). User-defined
  functions always read the dart way; the built-ins now match, across every
  module and their global spellings alike — including the three that built the
  message by hand rather than through the shared helper: the channels functions
  (`rgb()`, `hsl()`, `hwb()`, …) and the evaluator-owned `meta.function-exists`
  / `variable-exists` / `mixin-exists` / `global-variable-exists` and
  `meta.module-functions` / `module-variables`. A variadic member names no
  parameter at all: `math.hypot()` is now `At least one argument must be
  passed.`, as `math.min()` already was.
- **`hwb()` with no arguments is a missing argument, not an arity overflow.**
  It reported `Only 1 argument allowed, but 0 were passed.` — which is not even
  true of zero — where dart-sass says `Missing argument $channels.`. Only an
  overflow is an arity error now; `hwb(1, 2)` still reports one.
- **A missing alpha reads as 0 everywhere, not just in some places.** A color
  written `/ none` carries an opaque `1` alongside its missing alpha, for
  serialization to fall back to — and every reader that wanted the alpha as a
  number took that `1` instead of the channel. So
  `color.alpha(hsl(240 100% 50% / none))` answered 1 where dart-sass answers
  0, and `color.opacity`, the global `alpha`/`opacity`, `ie-hex-str`
  (`#FF0000FF` for `#000000FF`), `mix` (`mix(hsl(240 100% 50% / none), white,
  50%)` was an opaque blend, not the `rgba(255, 255, 255, 0.5)` a fully
  transparent color mixes to) and the `[color-functions]` deprecation's
  suggested `color.scale` percentage all inherited it.
- **A conversion between spaces resolves a missing alpha.** Converting a color
  resolves its missing alpha to 0 whatever the destination — only a LEGACY
  destination also zero-fills the channels — while a same-space conversion
  stays the identity and keeps everything missing. So
  `color.is-missing(color.to-space(oklch(50% 0.1 20deg / none), oklab),
  "alpha")` is now `false`, as are the results of `complement`, `mix`, and
  `change`/`adjust`/`scale` reached through a `$space`/`$method` other than the
  color's own. `color.to-gamut()`, which hands the color back in its own space,
  still keeps it; so does an op given no `$space`. `invert()` rebuilds the
  color like `change` does, so its alpha comes out concrete even with no
  conversion.
- **`color.scale($color, $alpha: …)` rejects a missing alpha** on the shortcut
  that preserves a color's missing channels, instead of reading it as opaque:
  `color.scale(hsl(240 none 50% / none), $alpha: 10%)` now raises dart-sass's
  "doesn't currently support modifying missing channels" error, which the
  common path already raised.
- **`color.change()` hands back a concrete alpha.** dart rebuilds the result
  with the alpha the getter above reports, so changing any channel of a color
  with a missing alpha resolves it to 0:
  `color.change(hsl(240 100% 50% / none), $lightness: 60%)` is
  `hsla(240, 100%, 60%, 0)`, not `hsl(240deg 100% 60% / none)`. This holds in
  every space, for non-legacy colors, and with no channel named at all;
  `grayscale()` rebuilds the same way. An explicit `$alpha: none` still sets
  it missing, and `color.adjust`/`color.scale` — which would have to read it —
  are unchanged.
- **`change`/`adjust`/`scale` work in the color's own space when no channel
  names one.** A channel-less or alpha-only call fell back to `rgb`, and the
  round trip filled in any missing channel:
  `color.change(hsl(240 none 50%), $alpha: 0.5)` came out
  `hsla(0, 0%, 50%, 0.5)` instead of `hsl(240deg none 50% / 0.5)`. The
  unknown-channel error follows the same resolution, so
  `color.change(hsl(240 none 50%), $foo: 1)` now reports `Color space hsl`
  rather than `rgb`. (`$hue` alone still means `hsl`, as in dart.)
- **The legacy color adjusters keep the color's own space.**
  `lighten`/`darken`, `saturate`/`desaturate`, `adjust-hue` and
  `opacify`/`fade-in`/`transparentize`/`fade-out` converted every input to
  sRGB, so `lighten(hsl(240, 100%, 50%), 10%)` came out `#3333ff` where
  dart-sass writes `hsl(240, 100%, 60%)`. They now shift the hsl channel (or
  the alpha) and rebuild the color in the space it arrived in, so
  `color.space()` of the result is the input's. That also keeps an untouched
  channel bit-exact — `lighten(hsl(240, 150%, 50%), 10%)` stays
  `hsl(240, 150%, 60%)`, out of gamut and all, only the shifted channel being
  clamped — and lets an `hwb()` result pick up a powerless `none` hue the way
  a conversion does. An `rgb()`/hex/named input still becomes a computed sRGB
  color.
- **`opacify`/`transparentize` shift a MISSING alpha from 0.** A legacy color
  written `/ none` reads its alpha as 0, like any other missing channel; the
  `1` the color carries alongside it is only the opaque default serialization
  falls back to. So `opacify(hsl(240 100% 50% / none), 0.2)` is
  `hsla(240, 100%, 50%, 0.2)` (was the opaque `hsl(240, 100%, 50%)`) and
  `transparentize` of the same color stays at 0 (was `0.8`).
- **`calc(#{-$x} …)` no longer errors** with "This expression can't be used
  in a calculation." Interpolation is a full SassScript context even inside a
  calculation, so the calc-only grammar restrictions (no `-$x`, no `- 1px`)
  are now suspended for the duration of a `#{…}` — matching dart-sass, which
  evaluates the expression and splices its text into the calc (#24, reported
  from the Lichess stylesheets).
- **A mixin whose `@content` sits inside `@supports` now accepts a content
  block.** The "does this mixin use `@content`" scan descended into `@media`,
  `@at-root`, `@keyframes` and generic at-rules but skipped `@supports`, so
  `@include` with a block hit "Mixin doesn't accept a content block." (#24).
- **Source maps name imported files by their resolved path and list only
  mapped files.** `sources` were keyed by a file's display url — an imported
  partial's basename — so `../_dep.scss` stood where dart writes
  `../lp/_dep.scss`, and two partials sharing a basename collapsed into one
  entry with the second one's mappings pointing into the first. The file
  table is now keyed by the canonical URL (the resolved path with
  `FsImporter`; the entry's `url` as given), and `sources` holds exactly the
  files the mappings reference, in order of first appearance: an entry that
  only imports or only declares variables is not a source, and an empty
  stylesheet has `"sources":[]`, as in dart-sass. Library API note: an
  embedder now sees absolute paths for imported files in
  `SourceMap::sources` (the CLI relativizes them to the map).
- **Stack frames name a loaded file by its path from the current directory**
  (`src/sub/_partial.scss`, `lp/_dep.scss`), as dart-sass does, instead of its
  bare basename — so two partials that share a name are told apart in a
  trace. A file outside the tree whose relative spelling would be longer than
  its absolute path is shown absolute (dart's `prettyUri`); the entry stays
  as given. `WarnEvent::url` carries the same spelling.
- **`FsImporter` canonical URLs leave symlinks unresolved, as dart-sass
  does.** The canonical URL was the file's `realpath`, so a stylesheet reached
  through a symlinked directory — a pnpm `node_modules/<pkg>` link — was named
  by its `.pnpm` store path in a source map's `sources`, in `WarnEvent::path`
  and in `DependencySet`, and two links to one file were one module. dart's
  `p.canonicalize` is the absolute, lexically normalized path with links kept;
  sasso now matches (10 of 148 Lichess bundles had `sources` differing from
  dart's for this alone). Library note: imported files now appear as the
  absolute path they were reached by, not their realpath.
- **Indented-syntax (`.sass`) diagnostics and source maps point at the `.sass`
  file.** The front-end rebuilds SCSS from the indentation-structured source,
  and it used to rebuild it compactly: statements were re-indented by nesting
  depth, blank and comment-only lines vanished, every block's `}` took a line
  of its own. Every line and column downstream — an error, a `@warn`, a
  deprecation span, a source-map entry — was therefore a position in that
  reconstruction rather than in the file the user wrote. The reconstruction is
  now position-preserving (one output line per source line, the source
  indentation kept, a block's `}` riding on its last line), and the two
  constructs that cannot be rewritten without moving columns are read by the
  parser in place instead:
  - the mixin shorthands `=name`/`+name`, which used to be expanded to
    `@mixin`/`@include` — eight columns wider, so `+mx(1)`'s argument mapped
    eight columns to the right of where it is;
  - unquoted `@import` urls, which used to be quoted (two bytes wider, moving
    the deprecation caret). dart reads such a url to the next top-level comma,
    spaces included, so `@import foo screen` is one url named `foo screen`;
    a `.css`/protocol url is a plain-CSS import written back quoted.

  On the shapes dart-sass 1.103.1 was measured against — errors, warnings,
  `[import]` deprecations, and six source maps covering comments, blank lines,
  multi-line selector lists, `@media`, custom properties and the shorthands —
  every line, column and `mappings` string now matches it exactly.
- **An escape is one token in a custom-property value, and a `}` inside a
  string does not close an interpolation.** dart-sass captures a custom
  property's value with `_interpolatedDeclarationValue`, which consumes a `\`
  escape whole and writes it back canonically; sasso weighed the escaped
  character itself, so an escaped delimiter changed what the value meant.
  `--x: \{` left a brace open and swallowed every line after it (`unexpected
  end of input, expected "}"`), `--x: \"` opened a string, and `a\;b` ended the
  declaration early. An escape now round-trips the way dart spells it (`\7b`
  and `\{` both print `\{`, `\61 b` prints `ab`, an invalid code point becomes
  U+FFFD), each closer is matched against the bracket it opened (`--x: (]` is
  `expected ")".`), and a closer with no opener ends the value (`--x: ];` is
  `expected ";".`). The `@supports` reader and the body of a plain-CSS custom
  `@function`/`@mixin` capture values the same way and follow the same rules.
  In the indented syntax the line scanners that decide where a value ends now
  read a string inside `#{ … }` as text, so `b: #{"} // not a comment"}` is one
  declaration rather than a parse error, and they track which bracket each
  closer closes: a mismatched one (`--x: (]`) is left to the parser, which
  reports dart's `expected ")".` at the closer instead of the front-end
  complaining about the line indented beneath it.
- **Interpolation resolves inside a quoted string in every verbatim value.** A
  custom-property value, a `@supports` declaration and the body of a plain-CSS
  custom `@function` all copy their text verbatim, but `#{…}` is not part of
  that text. The custom-property reader resolved it inside quotes; the other
  two copied the string whole, so `@supports (--a: "#{$v}")` and
  `@function --f() { result: "#{$v}"; }` emitted the interpolation literally.
  The string's own text, escapes and line continuations included, still passes
  through untouched — dart does not re-serialize a verbatim value's string.
- **The `[global-builtin]` deprecation.** dart warns at every call to a global
  built-in that has a `sass:*` equivalent — `map-get`, `nth`, `percentage`,
  `str-length`, `lighten`, `type-of`, `selector-parse` and some seventy more —
  naming the member to use instead and underlining the whole call. sasso
  emitted nothing, so a build that dart floods with migration warnings was
  silent. The mapping is not mechanical and every entry was measured against
  dart-sass 1.103.1: the legacy colour adjusters all point at `color.adjust`,
  `unitless` at `math.is-unitless`, `comparable` at `math.compatible`,
  `list-separator` at `list.separator`. A global dart KEEPS is left alone — a
  CSS function it shares a name with (`abs`, `round`, `min`, `sqrt`, …),
  `ie-hex-str`, and `if()`, which has a deprecation of its own. The per-id cap
  of five and the "N repetitive deprecation warnings omitted" footer apply as
  they do to `[import]`.
- **A span that crosses lines is drawn the way dart draws it.** dart puts the
  arm glyph in the GUTTER beside the source when the span begins at its line's
  first non-whitespace character, and likewise when it ends at its line's last;
  it draws an `┌─…─^` / `└─…─^` arrow row only for an end that starts or stops
  mid-line. sasso always drew the arrow rows, so every multi-line diagnostic
  differed from dart:

  ```
  2 │ ┌   @include nope {        2 │     @include nope {
  3 │ │     c: d;                  │ ┌───^
  4 │ └   }                      3 │ │     c: d;
                                 4 │ │   }
                                   │ └───^
  ```

  The two ends are decided separately, so `.a { @include m {` … `  }` opens
  with an arrow row and closes in the gutter.
- **An error at the end of a file points at the last line with content.** dart's
  scanner never advances into a file's trailing whitespace, so `.a { b: c` (no
  closing brace) reports at the end of that line; sasso reported on the blank
  line after it, drawing an empty snippet. The position now walks back to the
  end of the last line that says something, trailing spaces on that line
  included — in the frame trace as well as the snippet.
- **Two parser messages name what was expected, as dart's do**: a file that ends
  inside a block is `expected "}".` rather than `unexpected end of input,
  expected "}"`, and anything that cannot begin a value — a stray `;`, a `)`, an
  empty `@if` condition, the end of the file — is `Expected expression.`
- **A module diagnostic carets the construct it is about.** dart underlines the
  whole rule, call or reference a diagnostic belongs to; sasso drew a single
  caret, or — for an `@include` — reported the error with no snippet at all:

  | | dart | sasso |
  |---|---|---|
  | `@use "nope"` (missing) | the whole rule | one caret |
  | `@use` after other rules | the whole rule | one caret |
  | `@include nope` | the whole call | no position |
  | `@include ns.nope` | the whole call | no position |
  | `ns.nope(1)` | the whole call | one caret |
  | `ns.$nope` | the reference | line 1, column 1 |
  | `@include ns.-private` | the member name | one caret |

  A namespaced variable reference carried no position at all, so its error
  landed on the file's first line rather than on the reference. The messages
  match dart now too: `Undefined mixin.` rather than `Undefined mixin nope.`,
  and `Can't find stylesheet to import.` without the url the span already
  points at. (A `Missing argument`/content-block error still shows only its
  primary span; dart adds a second one for the declaration.)
- **A string is quoted the way dart quotes it, wherever it is written back.**
  `meta.inspect` and `@error` wrapped the text in `"` unconditionally, so a
  string containing a quote or a backslash came out as invalid CSS:
  `b: meta.inspect("a\"b")` emitted `b: "a"b";` where dart emits `b: 'a"b';`,
  and `meta.inspect("a\\b")` lost the escape. dart picks single quotes when the
  text holds a `"` and no `'`, and escapes the chosen quote and every
  backslash. The same wrapper produced a plain-CSS import's url in the
  indented syntax, so `@import h\74 tps://x/y.css` emitted a url whose escape
  no longer survived a round trip; it is now serialized as the string it is.
- **A hex escape's terminator is one line break.** One whitespace character
  ends a hex escape, and a CRLF is one character's worth of line break where
  the text is captured VERBATIM: `--x: \61` + CRLF + `b` is `ab`, with no line
  break left in the value. Where the text is SassScript only the `\r` is
  consumed, so the `\n` still separates two identifiers (`b: \61` + CRLF + `b`
  is `a b`). The two readers had it backwards from each other. A vertical tab
  never terminates an escape — dart's whitespace set is space, tab and the
  three CSS newlines — which the indented front-end's own decoder now matches.
- **A form feed is a newline to the escape reader.** dart counts U+000C as a
  newline, so a backslash cannot escape it; the identifier and verbatim-value
  readers accepted the pair and serialized it, where the ordinary value reader
  (and dart) report `Expected escape sequence.`
- **A `.sass` custom-property value continues past a trailing backslash.** The
  front-end decides where such a value ends, and it ended one at the line break
  even when the last character was an unpaired `\`. A string continuation
  (`--x: "a\` then an indented `b"`) was rejected as a stray indented child,
  and `--x: c\` reported that same front-end message instead of dart's
  `Expected escape sequence.` at the backslash. An even number of trailing
  backslashes still ends the value: the last one is escaped, not an escape.
- **A backslash before a newline is an escape only inside a string.** dart's
  `escape()` fails on a newline, and only its string reader drops the pair
  first — which is what makes a CSS line continuation legal inside quotes and
  nowhere else. sasso accepted it everywhere and treated it as a line wrap, so
  `b: c\` followed by `d` compiled as `b: c d`, `.a,\` + `.b` became a
  selector with an escaped line break (`\a `), and a url kept reading. All of
  them now fail where dart fails, with dart's message and column. In the
  indented syntax the front-end had the same leniency of its own — it dropped
  the trailing backslash and joined the next line with a space — so
  `@import url(foo\` + `bar.css)` imported `url(foo bar.css)`; the pair now
  reaches the parser verbatim. A continuation inside quotes still works in a
  value and in a selector: `[a="x\` + `y"]` is `[a=xy]`.
- **Two statements on one line are reported at the second statement.** The
  indented syntax forbids `b: c; d: e`, and dart carets the `d` — the first
  character after the `;` and the whitespace following it — where sasso
  pointed at the `;` itself. The position is counted from the last line break
  inside the statement, so a `;` below a bracket continuation is reported on
  the source line it is written on rather than on the line the statement
  started on.
- **An `@import`'s `url()` drops its padding and decodes its escapes.** dart
  reads the token with `_tryUrlContents`: the whitespace after the `(` and
  before the `)` is not part of the url, and a `\` escape is consumed whole
  and written back canonically. sasso kept the text exactly as written, so
  `@import url(  x.css  )` — and a `url(` opened on one line and closed on
  another, which the indented syntax invites — emitted the padding, and
  `url(\61 b.css)` stayed escaped where dart prints `url(ab.css)`. The
  declaration-value reader already followed both rules; the import reader now
  does too — it runs the same trial, and falls back the same way when the
  contents are not a url token at all. dart parses `url(…)` as an ordinary
  FUNCTION CALL then, so its arguments evaluate: `@import url(foo + bar)` is
  `url(foobar)` and `@import url($base + ".css")` imports the computed url,
  where sasso emitted the SassScript verbatim — a `$variable` reaching the
  CSS. A quoted url is such a function call too, which is why it keeps its
  own spacing.
- **`//` inside a `url()` is no longer a comment in the indented syntax.**
  `url(http://x/y)`, `url(//cdn/x.png)` and `@import http://x/y.css` were
  truncated at the `//` (`url(http:` — "expected \")\""), because the front-end
  stripped silent comments before the url token was recognized. The scanners
  that decide where a logical line ENDS skip the token too, so a declaration
  after one (`b: url(http://x/y)` then `c: red`) is still its own statement
  rather than being joined into the value. dart scans
  `url(` and its contents as one token; only the exact `url` function
  qualifies, so `my-url(//y)` still starts a comment, as it does for dart.
- **Compressed output no longer writes a stray `;` after a nested rule, and
  maps that rule's children.** A loaded `.css` file that uses CSS nesting
  rendered its nested blocks into one pre-built string, so `.a { .b { x: 1 } z:
  3 }` came out as `.a{.b{x:1};z:3}` — dart writes `.a{.b{x:1}z:3}`, a block's
  `}` being its own separator (`_requiresSemicolon`) — and no declaration
  inside the nested block carried a source-map entry. The block's items now go
  through the mapping-aware serializer. A block at-rule nested inside such a
  rule — which dart keeps in place rather than bubbling, once CSS nesting is in
  play — carries its own position too, so it maps to its `@` keyword in both
  output styles.
- **An at-rule whose name is interpolated (`@#{"media"} screen`) carries its
  source span**, so it maps like the plain spelling and joins a trailing
  comment the same way (`@#{"media"} screen { /* t */` used to break the
  comment onto its own line).
- **Source maps: every generated line of a line-spanning construct maps, a
  comment maps from column 0, a rule maps to its selector's line, and
  passed-through `@import`s and nested plain-CSS rules map at all.** dart-sass
  keeps a mapping span open while it writes a construct, so each newline
  inside a multi-line selector list, comment, at-rule prelude or re-indented
  custom-property value adds an entry at the start of the new line that points
  back at the construct; sasso mapped only the first line. A rule mapped to its
  opening-brace line — a selector list written over several lines maps to its
  first line (`node.selector.span.start`) — and so did a block at-rule whose
  prelude spans lines, which maps to its `@` line. A nested comment mapped after its
  indentation where dart opens the span before indenting. A passed-through
  plain-CSS `@import` (mapped to its URL token) and a nested rule of a loaded
  `.css` file that uses CSS nesting (mapped to its selector) had no mapping.
  Verified byte-for-byte against dart-sass 1.103.1; on the Lichess corpus,
  bundles whose `mappings` are identical to dart's went from 2 to 148 of 148.
- **Blank lines between top-level groups survive dropped placeholders.** An
  unextended placeholder rule with a declaration and an empty nested rule
  (`%video { width: 100%; > * {} }`) produced two invisible nodes, and
  dropping each removed one blank-line separator: the separator after the
  previous group as well as the placeholder's own. The next comment or rule
  then packed tight where dart-sass keeps the blank line. On the Lichess corpus this was the difference in the
  blank-line placement of 123 of 148 bundles.
- **A loaded plain-CSS file's `@charset` is dropped**, as dart-sass drops it:
  a `.css` file reached through `@use` or `@import` that begins with
  `@charset "utf-8";` used to leave that line in the middle of the output
  (the Lichess `bits.cms` and `bits.ublog.form` bundles, via a vendored
  editor theme). The output's own `@charset "UTF-8";` is still derived from
  its content.
- **Nested rules in a loaded plain-CSS file keep their selector lines.** A
  `.css` file's nested rule whose selectors were written one per line
  (`.swiper-slide,\n  .swiper-cube-shadow {`) was emitted on one line;
  dart-sass keeps the source line structure for nested rules as it already
  did for top-level ones (the Lichess `recap` bundle, via the swiper
  stylesheet).
- **`@import` deprecation warnings fire when a file is parsed**, as in
  dart-sass, not when each rule is evaluated: all of a file's import
  deprecations now precede anything its body prints (its `@warn`s, the
  warnings of the files it imports), a file the import cache already parsed
  warns once however often it is imported, and a `@use`d module's own
  `@import` warns under the `@use` frame before the module body runs. This
  was the last difference in stderr ordering against dart-sass 1.103.1 on
  the `@import` chains tested here. In the same move a misplaced `@import`
  — in a mixin or function body, a control directive, a property set, or an
  at-rule nested in one of those (interpolated at-rules included) — is
  rejected as dart-sass rejects it, in loaded files as well as the entry
  (sasso used to accept it in property sets and in loaded files), and the
  "This at-rule is not allowed here." error now carries dart's snippet and
  frames. A property set admits no `@import` of any kind, plain-CSS ones
  included. And a plain-CSS entry (a `.css` input) is now evaluated as plain
  CSS like a `.css` module: its `@import "theme";` is passed through instead
  of being loaded as Sass (which warned and then failed with "Can't find
  stylesheet to import").
- **A mixin, function, or `@content` block runs against the file that wrote
  it**, as in dart-sass. A callable defined in a textually `@import`ed file
  (or reached through `meta.apply`/`meta.call`) used to be evaluated as if it
  were written in the caller's file: its output mapped to the caller's
  `sources` entry with the callable's line numbers, its warnings and errors
  named the caller's file and rendered the caller's source, and a `@content`
  block passed to a `@use`d module's mixin was attributed to the module. Now
  the body's output maps to its own file, stack frames read as dart prints
  them — `src/_dep.scss 2:3  m()`, the block's statements under a `@content`
  member in the includer's file with the mixin's `@content;` statement as a
  call site, `f()` (not `call()`) inside a function invoked through
  `meta.call`, with the `meta.call(...)` expression as a call site — and an
  error inside the body shows the body's source. A function invoked through
  `meta.call` also resolves `ns.member` against its own `@use` namespaces
  now, as a direct call did. A member `@forward`ed by a file that is then
  `@import`ed keeps its defining file too — and its own `@use` namespaces,
  so a forwarded function using `sass:math` no longer fails with "There is
  no module with the namespace "math"" when reached through `@import`. And an `@error` raised directly
  in a content block carets the nearest `@include` whose mixin is running
  (the name and arguments, as dart does — through any number of forwarded
  content blocks), not a `@content;` statement. Module
  callables also track whether they are a mixin now: `meta.content-exists()`
  inside a `@use`d mixin answers for the include at hand instead of erroring,
  and inside a module function it errors as it does in a plain one. A
  default in a content block's `using (...)` clause evaluates where the
  block was written (`using ($y: $caller)` sees the includer's `$caller`, as
  in dart-sass), not in the mixin's module. On the Lichess corpus this
  takes the source maps whose `sources` match dart-sass from 14 to 138 of
  148. (`WarnEvent::url`/`path` follow.)
- **`--quiet-deps` no longer aborts after a compile error.** The dependency
  record's mutex was allocated lazily on its first lock — from inside the
  compile, so in the CLI's bump arena, which the compile resets on the way
  out — and the error-CSS re-render (a second compile in the same process)
  then locked freed memory: `failed to lock mutex: Invalid argument` and exit
  code 134 instead of the error report and exit code 65. Every access to a
  `DependencySet` now runs with the arena paused, so the mutex and the keys
  it records live in system memory for the set's whole lifetime. Host
  functions (`Options::with_function`) now run with the arena paused as
  well, like importers and warn handlers already did, so anything a host
  keeps across calls is never arena-resident.
- **Warn handlers may retain event data.** The library now pauses its
  bump-arena scope while calling an embedder's `WarnHandler`, so a handler
  that appends the event to a buffer no longer ends up with memory the
  arena frees at the end of the compile (which surfaced as garbled or
  cross-contaminated warnings under parallel compiles). Importer calls were
  already paused the same way. The pause itself is now a counter behind an
  RAII guard rather than a zeroed scope depth: a `compile` run from inside an
  importer or warn callback nests instead of resetting the arena under its
  caller, and a callback that panics no longer leaves the thread paused.
## [0.9.1] - 2026-09-01

_C-ABI release fixes — no compiler changes. Ships musl c-api tarballs for
Alpine (#18) and corrects the version string the C ABI reports._

### Added

- **musl c-api tarballs** (`x86_64-unknown-linux-musl`,
  `aarch64-unknown-linux-musl`) for Alpine and distro-agnostic containers
  (#18). musl artifacts are STATIC-ONLY by design: a musl target defaults to
  `+crt-static`, under which rustc cannot build a cdylib, so the tarball
  ships `libsasso.a` (and `sasso.h`) without a `.so` — link it into your own
  binary or shared object. Verified end-to-end on Alpine 3.24 (gcc +
  musl-dev, dynamic and fully-static links both pass the C smoke test).
  Adapted from @shyim's fork.

### Fixed

- **`sasso_version()` reports the bundled compiler version** (now `0.9.1`),
  not the FFI wrapper crate's own version (which had drifted to `0.6.1` —
  the string the v0.9.0 c-api artifacts report). The core crate now exposes
  `sasso::VERSION` so wrappers cannot drift again. Contributed by @shyim.

## [0.9.0] - 2026-09-01

_Crate release `v0.9.0`; ships on npm as `sasso@0.12.0`. **Output-format
alignment with dart-sass 1.103.1** — the reference pins (CI parity binary,
sass-spec, baseline) all move together. If you byte-compare sasso's output
(snapshot tests, build caches), expect diffs on legacy colors and plain-CSS
`if()`; the CSS is equivalent, only its spelling changed. sass-spec passing
rose to **14061** (98.95% of attempted, +165 on a newer, larger suite).
Minor — not patch — for the serialization changes and one removal below._

### Changed (dart-sass 1.101.4–1.103.x alignment)

- **A legacy color with any fractional channel serializes its rgb triple as
  percentages** (dart 1.101.4): `rgb(127.5, 0, 127.5)` is now
  `rgb(50%, 0%, 50%)`. Older browsers only support integer or percentage
  channels in `rgb()`/`rgba()`, so this preserves backwards compatibility
  without losing precision. Contributed by @shyim (#19).
- **Plain-CSS `if()` values emit in CSS serialization format** (dart
  1.101.4), not `meta.inspect()` format: lists lose their parens
  (`if(css(): 1 2 3)`, invisible items drop out), `null` serializes to
  nothing, a preserved slash-division keeps its slash, and a value with no
  CSS form (`()`, a map, a function/mixin reference) is an error.
- **rec2020 uses the pure 2.4 gamma transfer function** (dart 1.102.0, per
  the latest CSS Color 4 draft), replacing the BT.2020 piecewise curve.
- **Compressed hsl/hwb serialization routes through rgb** like every legacy
  space (dart `_writeLegacyColor`): hex/named first, then the shorter of the
  percent rgb form and the hsl form *derived from that rgb* under dart's
  two-character hsl handicap. A powerless (zero-saturation) hue collapses to
  0, and a non-opaque hwb can emit `rgba()`; only an out-of-gamut color
  keeps its hsl form.
- **Reference pins**: sass-spec `1b03109a` → `4a9eea66`, CI parity binary
  `sass@1.101.3` → `sass@1.103.1`, `spec/BASELINE.json` 13896 → 14061
  passing. The parity binary is now pinned (previously floating `latest`),
  so upstream dart-sass releases can no longer redden unrelated PRs.

### Removed

- **Global `whiteness()` and `blackness()`**: like dart-sass, these are
  `sass:color`-only (`color.whiteness()` / `color.blackness()`); the global
  spellings now error. Contributed by @shyim (#21).

### Fixed

- **The indented syntax no longer panics on an overlapping `/*/`** comment
  terminator. Contributed by @shyim (#17).
- **Unknown-channel errors render the channel list with `inspect`**, not
  `to_css`, matching dart-sass message spelling. Contributed by @shyim (#20).
- **Source maps: a declaration whose value is a bare `$name` maps back to
  the variable's definition** (dart `Environment._variableNodes`),
  transitively through `$b: $a` chains, module members, and
  mixin/function parameters (which resolve to the call-site argument).
  Previously the segment was omitted entirely, which also renumbered every
  following delta-encoded segment. Contributed by @shyim (#22).

### Performance

- The definition-span bookkeeping behind the source-map fix is gated on an
  actual source-map compile — the plain `compile()` path pays nothing for it.
- The percent channel formatter appends `%` in place instead of allocating a
  second string per channel, keeping the `colors` benchmark at its
  pre-percent-serialization baseline (CodSpeed gate green).

## [0.8.1] - 2026-07-17

_Release-tooling only — no compiler changes._

### Changed

- Releases now attach a conventionally-named source tarball
  (`sasso-<version>.tar.xz`, extracting into `sasso-<version>/`) plus a
  `.sha256`, built deterministically with `git archive`, replacing
  cargo-dist's generic `source.tar.gz`. Requested by downstream packagers
  (FreeBSD ports).
- CI: bumped `moonrepo/setup-rust` v0 → v1 (Node 24 runtime, current cache
  backend — fixes the deprecation warning and cache-service 400s in
  benchmark runs).

## [0.8.0] - 2026-07-06

_Crate release `v0.8.0`; ships on npm as `sasso@0.11.0` (wasm + native — same
core). Byte-identity, complete: **all 20 projects in the real-world corpus
compile byte-identical to dart-sass 1.101**
([`bench/real-world/real_world.md`](bench/real-world/real_world.md), 2.9–51×
faster end-to-end). The corpus doubled this release (tabler, AdminLTE,
reveal.js, Font Awesome, video.js, forem, nextcloud server,
jekyll-theme-chirpy, grafana, wagtail) and every divergence it surfaced was
fixed against dart-sass semantics — each pinned by a parity test._

### Fixed (`@extend` engine — dart's per-registration model)

- **`@each` over a single value — `null` included — iterates once** (dart
  `Value.asList`). Bootstrap's `valid-radius(null)` relies on it; previously
  a css-less `border-radius` map key ERRORED the whole compile (tabler).
- **The application fold runs each registration exactly once — no fixpoint.**
  Extend cycles resolve the way dart's do: `_extensionsByExtender[target]` is
  a LIVE list, so an extender that itself contains the target self-derives
  within its own registration. The old fixpoint chained one extender of an
  `@extend` through its sibling of the same rule, emitting selectors dart
  never produces.
- **Original selectors are identity-tracked** (dart `_originals` is a
  `Set.identity()`): an extension product value-equal to one of the rule's
  own selectors is coverage-trimmed in the original's favor, keeping the
  original's position and source line break (`.btn-sm,\n.btn-group-sm > .btn`;
  `h1, .h1` heading runs). dart's bare fast path (a single-simple compound
  replaced wholesale returns the extender object) carries identity too,
  scope-gated per module store — dart#1297 keeps the in-store `:is()` rewrite
  alongside its source while the cross-module variant replaces it.
- **Foreign extensions apply in dart's cross-module store-merge order**
  (downstream stores merge transitively; sibling stores reverse-first-load;
  derived entries follow their trigger's absorption order) — bulma's `%block`
  extender interleaving.
- **Identical `(target, extender)` registrations merge per module store, not
  globally**, so each keeps its own store-merge rank (chirpy's
  `#access-lastmod a:hover` position and line break).
- **One `@extend` hitting several compounds of the same complex uses dart's
  `paths` order** (first component varies fastest) on the incremental path
  too (forem's `.crayons-btn + .crayons-btn` file-selector products).
- **Pre-rule extensions apply one-shot per dart's `addSelector` timing**, and
  the one-shot gate compares registration indices, not counts.
- **A placeholder-only module whose rules were all dropped counts as empty**,
  so its group-separator blank collapses (uswds `placeholders/`).

### Fixed (module system & output fidelity)

- **The pre-module comment engine matches dart on three fronts** (uswds):
  registration deep-scans pending comments through invisible module-scope
  placeholders; re-emitted clones are fenced and never re-register onto new
  module keys; a css-less module built while the shared comment map is
  non-empty absorbs pending registrations (dart's `transitivelyContainsCss`
  includes `preModuleComments.isNotEmpty`).
- **Re-emitted pre-module clones stay out of the loader's import-run sweep**
  (nextcloud's SPDX header no longer jumps to the top of the document).
- **CSS `@import` hoisting keeps the css flow's eval-time grouping** — dart's
  blank lines come solely from group-end flags, never source gaps; only the
  seam the pulled import run vacated is re-derived (forem).
- **`meta.load-css` copies re-acquire per-rule group separators** — dart
  re-visits the combined css node-by-node (reveal.js print styles).
- **A trailing invisible chain owns the enclosing group's end at any nesting
  depth**, packing the next group tight (chirpy).
- **`@at-root` separators follow dart's `_styleRule == null` group-end gate**
  — rules flattened out of a wrapper rule pack tight (wagtail's sidebar).
- **Selector line-break parity with dart** (pseudo-arg newlines,
  parent-resolution flags), **loud comment re-indentation** per dart's
  `_loudComment`, **invisible-last-child groups pack the next group tight**,
  and **an empty module scope no longer anchors a group separator**
  (bootstrap, quasar, mastodon, govuk-frontend byte-identity).

### Added

- **`bench/real-world/`: the vetted corpus doubled to 20 projects** — every
  one compiled standalone with both engines and byte-compared on every run
  (`node bench/real-world/run.mjs check` is the regression gate).

## [0.7.0] - 2026-07-04

_Crate release `v0.7.0`; ships on npm as `sasso@0.10.0` (wasm + native — same
core). The dart-sass byte-parity campaign: every project in the new
real-world corpus ([`bench/real-world/real_world.md`](bench/real-world/real_world.md))
now compiles, and most match dart-sass 1.101 byte-for-byte._

### Added (npm package — `sasso/native`; released as `sasso@0.9.0` on npm)

- **`sasso/native` subpath: the native addon as a first-class npm entry.**
  Prebuilt binaries publish as exact-version-pinned `optionalDependencies`
  (`sasso-native-{darwin-arm64, darwin-x64, linux-x64-gnu, linux-arm64-gnu}`) —
  npm installs only the matching platform, the release workflow builds and
  byte-parity-tests every binary against the wasm reference before publishing,
  and unsupported platforms get a clear error pointing back at the wasm
  entries. Resolution order: `SASSO_NATIVE_BINARY` override → platform
  package → repo-local build.

### Added (repo — native Node addon)

- **`napi/`: a native Node addon binding the core crate directly** (F4 of
  `docs/ASYNC_PERF_ARCHITECTURE.md`) — no wasm, no asyncify. Same dart-sass
  modern API as the `sasso` npm package, verified **byte-identical** to the
  wasm engine's output across the in-repo corpora (which is itself dart-sass
  byte-exact). Async compiles each run on their own OS thread: ~3× engine
  speed over the wasm modules, and a concurrent 8-entry cold build finishes
  in ~1.14× a single compile's time (true multi-core parallelism; the wasm
  engine's single JS thread serializes CPU-bound fan-out). User importers, custom functions,
  and loggers bridge to JS; `loadPaths`/relative resolution run natively.
  Repo-buildable (`bash napi/build.sh`, `node napi/test.mjs`); publishing
  waits on a per-platform prebuild matrix.

### Changed (npm package — async path performance; released as `sasso@0.8.0` on npm)

- **Concurrent `compileStringAsync`/`compileAsync` calls no longer serialize.**
  The single asyncify-instance lock is replaced by a lazily-grown pool of
  asyncify engines (default cap: `min(4, cpu cores)`, tunable via the new
  `configure({ asyncInstances })`). While one compile awaits an asynchronous
  importer, other compiles run on other engines — a bundler fanning out N
  sass entries no longer queues them end-to-end (measured: N=8 fan-out with
  2 ms importer latency, makespan −75.6%). A process that never overlaps
  async compiles still pays for exactly one instance; each additional engine
  reserves its own wasm memory (incl. the arena) plus a 1 MiB asyncify stack.
- **Synchronously-resolving importers and custom functions no longer pay the
  asyncify suspension on the async APIs.** Results that settle synchronously
  (plain return values — including the built-in `loadPaths` filesystem chain
  and sass-loader's cache-hit resolutions) are delivered without an
  unwind/rewind cycle. A `loadPaths`-only `compileStringAsync` now suspends
  zero times. Genuinely-async importers behave exactly as before.
- **`sasso/speed`'s async APIs now run a speed-optimized (`-O3`) asyncify
  module** (`sasso.speed.async.wasm`, ~3.2 MB / 1.0 MB gzip) instead of
  sharing the size-optimized one — ~2× engine throughput at v8 steady state
  (long-lived processes; one-shot CLI-style runs are dominated by v8 tiering
  and see little change). The default `sasso` entry is unchanged.
- Degraded async modules (built without `wasm-opt`) previously crashed on the
  first importer callback; they now work for synchronously-resolving chains
  and reject genuinely-async importers with a clear error.

### Fixed

- **Real-world corpora now compile — four previously failed.** Callable
  closures capture the defining file's `@use` namespace tables (dart
  `Environment.closure()`), fixing "There is no module with the namespace
  X" for functions/mixins reached via `@import` or multi-hop `@forward`
  (uswds's `units()`, quasar's `str-fe()`). CSS escapes are literal
  identifier text in selector scans (`.govuk-\!-font-size-19`,
  govuk-frontend). In the indented syntax, `as *` terminates a
  `@use`/`@forward` prelude instead of reading as a pending multiplication
  (vuetify), and a trailing-comma selector line with a pseudo-glued colon
  (`&:active,` / `i[type="s"]::-webkit-x,`) continues the list instead of
  being **silently dropped** (quasar — a correctness bug, not formatting).
- **Byte-parity with dart-sass across the serialization surface.** Loud
  comments dedent at serialize time (interpolated banners included) and an
  indented `/**` opener stays glued; comments registered before a module's
  first load re-emit at every dependency edge (bulma's `/* Bulma Form */`);
  `@import`ed files carry their own file identity (no cross-file trailing
  -comment gluing); invisible `@extend`-only rules leave no blank-line group
  end; selector lists keep their authored line structure inside nested
  at-rule wraps and plain-CSS imports (which also unquote identifier
  attribute values like dart's parser); multi-`&` parent expansion
  interleaves column-major (mastodon's adjacent-state selectors); a `&`
  nested in pseudo parens substitutes inside multi-`&` parts
  (`:not(&--mini-animate)`).
- **Chained `@extend` products keep dart's registration order.** Each
  `@extend`'s extender list is pre-extended by the store accumulated so far
  (dart's `addSelector`), so `.navbar > .container, … .container-xxl` comes
  out in forward order instead of reversed.
- **Errors inside loaded files are attributed to that file.** The snippet
  renders from the erring file and the trace stacks one frame per loader
  (`_mod.scss 1:13  @use` / `main.scss 1:1  root stylesheet`), matching
  dart for `@use`, `@forward`, and `@import` chains — parse errors
  included. Previously the root file's name and snippet were shown with the
  inner file's line numbers.
- **`@media` nested inside an unknown at-rule now compiles.** dart's
  `_inUnknownAtRule` context legalizes bare declarations without an enclosing
  style rule, so the canonical Tailwind v4 idiom
  `@utility container { @media (width >= 96rem) { max-width: 87.5rem; } }`
  parses and emits verbatim (byte-matched to dart-sass 1.101, including the
  classic `min-width` syntax, interpolated queries, and mixed
  declaration-plus-`@media` bodies). A bare declaration in a top-level
  `@media` still errors like dart. Previously: `Error: expected "{".`
- **Keyframe selector lists now join on one line, matching dart-sass.** A
  multi-line authored frame selector (`0%,\n60%,\n100% {`) was emitted with
  the author's line breaks preserved, as style-rule selector lists are; dart
  re-serializes keyframe stops joined with `", "` and drops the breaks
  (`0%, 60%, 100% {`). Found compiling a real-world Rails corpus (a Bootstrap
  → Tailwind compat layer) where this was the only byte difference across
  ~132 KB of output.

## [0.6.3] - 2026-06-25

### Fixed

- **Trailing-newline parity with dart-sass, split correctly between the library
  API and the CLI.** The library API (`compile`, `compile_with_source_map`, and
  thus the wasm `compileString().css` and the Ruby gem) now returns the
  serialized stylesheet with **no trailing newline** — byte-for-byte what
  dart-sass's library API returns. Previously expanded output carried a stray
  trailing newline, so a `sass-loader`/Vite integration saw one extra byte per
  stylesheet versus dart-sass. The CLI front-ends (the `sasso` binary and the
  wasm `sasso` CLI) now append the single trailing newline dart-sass's CLI adds
  to **non-empty** output in **both** styles — compressed CLI output previously
  omitted it — while empty output stays empty (0 bytes), also matching
  dart-sass. Verified byte-for-byte against dart-sass 1.101.0 on both the
  library and CLI paths (expanded, compressed, and empty output).
- **The wasm package now reports `dart-sass 1.101.0` in `info`** (was
  `1.89.0`), reflecting the modern-API surface it's compatible with. Tools such
  as `sass-loader` and Vite parse this version for feature gating, so the stale
  value could gate off newer behavior.

## [0.6.2] - 2026-06-25

### Fixed

- **Compressed output now emits the shortest equivalent legacy-color form**,
  matching dart-sass 1.101.0 byte-for-byte. A computed color such as
  `darken(#336699, 10%)` is written as `hsl(210,50%,30%)` instead of the longer
  `rgb(38.25,76.5,114.75)`, and an integer-rgb-equivalent hsl literal
  (`hsl(210, 50%, 40%)`) collapses to `#369`. The serializer now compares the
  hex/name, `rgb()`/`rgba()`, and `hsl()`/`hsla()` candidates and keeps the
  shortest — the rgb form winning ties — while a powerless (zero-saturation)
  hue is preserved. Expanded output is unchanged. This compressed path had no
  cross-check before (the conformance ratchet and the parity suite were both
  expanded-only), so a compressed dart-sass parity battery now runs in
  `tests/parity.rs`.

## [0.6.1] - 2026-06-16

### Fixed

- A relative `meta.load-css` inside a **first-class mixin** (captured with
  `meta.get-mixin` and invoked via `meta.apply`) now resolves against the
  mixin's **defining** file, not the caller's (issue #8). The regular
  namespaced include path was already correct.

### Added

- A **C ABI** (`ffi/`, `libsasso` + `sasso.h`) — drive sasso in-process from any
  language with a C FFI, with a userland importer callback. Releases now attach a
  per-target `sasso-<version>-<target>-c-api.{tar.xz,zip}` (prebuilt static +
  dynamic library + header). See the "C ABI" section in the README.

## [0.6.0] - 2026-06-15

### Changed (breaking)

- **The `Importer` trait is now dart-sass's two-phase `canonicalize`/`load`**
  (issue #4, RFC in `docs/IMPORTER_REDESIGN.md`). It replaces the old
  `resolve(path) -> Option<String>` plus the accreted `resolve_*` overloads:

  ```rust
  fn canonicalize(&self, url: &str, ctx: &CanonicalizeContext)
      -> Result<Option<CanonicalUrl>, ImporterError>;
  fn load(&self, canonical: &CanonicalUrl)
      -> Result<Option<ImporterResult>, ImporterError>;
  ```

  `canonicalize` resolves a URL to a stable identity without loading (its result
  is the module-cache key); `load` fetches the source as an
  `ImporterResult { contents, syntax, source_map_url }`. Three outcomes:
  `Ok(Some)` = handled, `Ok(None)` = not handled, `Err(ImporterError)` =
  handled-but-failed (an actionable compile error rather than a silent miss).
  New public types: `CanonicalUrl`, `ImporterResult`, `ImporterError`,
  `CanonicalizeContext`. A clean break with no compatibility shim (pre-1.0).
  `FsImporter` and the built-in resolution are unchanged in behavior (sass-spec
  ratchet delta +0); only custom `Importer` implementations must migrate.

### Added

- `ImporterResult.source_map_url` lets an importer set the URL recorded for a
  loaded file in generated source maps (dart-sass `ImporterResult.sourceMapUrl`).

## [0.5.3] - 2026-06-15

### Fixed

- **`!default` no longer evaluates its right-hand side when the variable is
  already set.** dart-sass short-circuits a guarded (`!default`) assignment
  *before* evaluating the RHS, so an expression that would otherwise error is
  harmless once the variable already holds a non-null value; sasso evaluated the
  RHS first. This surfaced in Bootstrap-on-Shopware setups where, after an
  override sets `$w: 1rem`, a later `$p: $w + .5em !default` raised an
  "incompatible units" error instead of being skipped. Thanks to
  [@shyim](https://github.com/shyim) (#2).
- **Legacy `rgb()`/`hsl()` preserve the caller's `rgba`/`hsla` spelling in
  special-value and relative-color passthroughs.** When a call can't resolve to
  a concrete color (a channel or alpha is a `var()`/`env()`/non-foldable
  `calc()`), dart-sass keeps the call *and* the exact function name written;
  sasso normalized `rgba`/`hsla` down to `rgb`/`hsl`, breaking Bootstrap's
  `rgba(var(--bs-body-color-rgb), …)` output. The called name is now threaded
  through every passthrough, keeping dart's carve-out that a `none`-only call
  still normalizes to the canonical `rgb`/`hsl` (and a `calc()` alpha that folds
  to a number resolves to a real color rather than a passthrough). Thanks to
  [@shyim](https://github.com/shyim) (#3).

## [0.5.2] - 2026-06-14

### Fixed

- **Expanded `@at-root` group-separation blank lines.** dart-sass writes one
  blank line at an `@at-root` hoist→resume boundary when the hoisted chunk ends
  in a style rule, while keeping a nested-`@at-root` chain and a rule + its own
  bubbled `@media` contiguous. sasso previously diverged BOTH ways — it never
  emitted the blank before a resumed parent rule, and it over-emitted (three
  blanks between top-level bare-`@at-root` siblings, spurious blanks between a
  nested-`@at-root` chain's rules / between a rule and its own bubbled `@media` /
  before an `@at-root` body's trailing comment). Now byte-exact vs dart-sass
  1.101 across a dedicated 54-shape group-separation sweep, with non-`@at-root`
  output byte-identical. Compressed output is unaffected (no blank lines).
  (sass-spec does not cover these `@at-root`-resume blanks.)

## [0.5.1] - 2026-06-14

Source-map fidelity + compressed-output corrections, all byte-exact vs
dart-sass 1.101.

### Fixed

- **Source maps: `@media`/`@at-root`/`@supports` bubbled parent selector.** When
  one of these at-rules nested in a style rule bubbles a copy of the enclosing
  selector out (`@media screen { .a { … } }`), that copy now maps back to the
  ORIGINAL rule's source position, matching dart-sass. It previously had no
  mapping at all — which in compressed output also let the consecutive-same-
  source-line coalescing drop a following declaration's mapping (a 0.5.0
  regression vs 0.4.0 for `@media`/`@at-root`-bubbled rules). CSS is unchanged.
- **Source maps: `@supports` header.** The `@supports (…)` at-rule header now
  maps to its `@supports` keyword (as `@media` already did); previously it had
  no mapping. CSS is unchanged.
- **Compressed `@media`/`@supports` whitespace.** Compressed output now omits the
  space before a prelude beginning with `(` for `@media`/`@supports`
  (`@media(min-width: 1px)`), and within a `@media` query drops the space before
  `and`/`or` after a `)` (`(a)and (b)`) and after the comma between queries
  (`(a),(b)`) — matching dart-sass. Other at-rules (`@container`) and `@supports`
  conditions keep their spaces. (Compressed CSS output change; expanded
  unchanged.)

## [0.5.0] - 2026-06-14

### Added

- **wasm: source maps.** The `@momiji-rs/sasso` package's `compile(scss, {
  sourceMap: true [, sourceMapIncludeSources: true] })` now returns
  `{ css, sourceMap }` (the v3 map as a parsed object) instead of a bare CSS
  string; without `sourceMap` it still returns the string (backwards
  compatible). New `sasso_compile_map` export returns a framed `[u32 css_len][css]
  [map json]` buffer. Source maps are now exposed on every surface (lib, CLI,
  wasm).

### Fixed

- **Compressed source maps** now emit one segment per source line, matching
  dart-sass (compressed packs many tokens onto a line; dart maps only the first
  per source line). Expanded maps are unchanged. The map's CSS is unaffected.

## [0.4.0] - 2026-06-14

### Added

- **Source map (v3) support.** New `compile_with_source_map(source, &Options)
  -> CompileResult { css, source_map: SourceMap }`, with `SourceMap::to_json()`
  and `Options::with_source_map_include_sources(bool)`. The CLI gains
  `-o/--output <file>` (write CSS to a file), `--source-map` (also write a
  `<output>.map` sidecar + append the `sourceMappingURL` footer),
  `--embed-sources`, and `--source-map-urls=relative|absolute`. Output is
  byte-for-byte identical to dart-sass for the common cases (selector +
  declaration-name mappings; expanded + compressed). The plain `compile` path
  and stdout output are unchanged. (Deferred for now: declaration-value-start
  mappings, the inline `--embed-source-map` data URI.)

### Changed

- Internal maintainability refactors only (no behaviour change, byte-identical
  output): the `.sass` line scanners, the `is_builtin` name table, and the
  oversized `eval`/`selector`/`parser` files were split into domain modules;
  the string serializers gained a no-escape fast path.

## [0.3.1] - 2026-06-13

### Fixed

- Compressed output now emits a color's canonical CSS name when it is no longer
  than the shortest hex, matching dart-sass (`red` not `#f00`, `aqua` not
  `#0ff`; duplicate names resolve to dart's canonical pick — `cyan`/`grey` →
  `aqua`/`gray`). Expanded output (which preserves the authored spelling) is
  unchanged.

## [0.3.0] - 2026-06-13

Since `0.2.0`. Conformance holds at **100% of the attempted sass-spec suite**
(13,896 / 13,896) — but that suite covers *valid* inputs plus the errors it
expects; this cycle hardened sasso to reject the same *malformed* inputs
dart-sass rejects, and cut more of the `@extend` and value hot paths.

### Changed

- **Strict input validation.** Beyond matching dart-sass's output, sasso now
  *errors* — rather than silently accepting — on malformed input, each with
  dart-sass's exact message: an invalid hex literal (`#00000`, `#0g`),
  out-of-grammar `rgb()`/`hsl()` channel units and legacy-vs-modern argument
  shapes, a duplicate `@mixin`/`@function` parameter, a malformed number
  exponent (`1e-`), a non-identifier `@use`/`@forward` namespace, a misplaced
  `@content`/`@extend`, a style rule / declaration / `@extend` in a `@function`
  body, a map or empty list used as a CSS value (`#{(a:1)}`, `-()`), a
  malformed `:nth-child()` An+B or empty `:not()` selector, a stray `!` in a
  selector, a leading-empty `@extend` target, and a malformed `@charset` /
  `@at-root (…)` query. Found by a leniency-mining sweep that diffed every
  category against dart-sass; the fixes are uncovered by the spec, so the
  ratchet is unchanged.

### Performance

- **Transitive `@extend`** went from ~151× *slower* than dart-sass to *faster*
  on a deep extend chain: a match pre-filter with typed dedup, an incremental
  per-rule fold (killing the O(N²) closure re-derivation), borrowed
  scope-originals, and cached typed selector hashes — the `@extend` maps are
  now FxHash + typed `Complex`/`Simple` keys, guarded by a render-injectivity
  parity proof. Byte-identical output throughout.
- **Reference-counted composite values** — `Str`/`List`/`Map` are `Rc`-backed,
  so cloning a read-only `$variable` is an O(1) refcount bump instead of a deep
  copy (copy-on-write for the mutating builtins): ~7× fewer instructions and
  ~13× less peak memory when a large list/map is passed through a call chain.
- **`Cow`-borrowed argument-name normalization** (called 4–6× per function
  call) plus trimmed function-call-path allocations — ~15% fewer instructions
  on a function-heavy compile.
- **Arena in-place `realloc`** — the scoped bump arena extends its tail
  allocation in place instead of stranding a dead buffer on every `Vec`
  doubling, trimming peak memory on parse-heavy compiles.
- Net: pure-compile throughput ~7.4 ms on the large benchmark (was ~9–10),
  ~2.3–2.9× faster than `grass` and ~19–30× faster than the dart-sass JS bin.

### Internal

- `eval.rs` split into an `eval/` module directory and `color.rs` into a
  `color/` directory (pure code moves); the typed selector model gained a
  parity-proof harness; the stringly hoist markers became typed `OutNode`
  variants; the `@extend` cartesian-order bool became a `CartesianOrder` enum;
  `OutNode` rule/at-rule constructors collapsed duplicated construction sites.
  All byte-identical, each verified base-binary-vs-refactor.

### Tooling

- The WebAssembly npm package publishes via OIDC Trusted Publishing (no token).
- Benchmark harness uses portable temp-file handling (`mktemp -d`).

## [0.2.0] - 2026-06-11

Everything since the initial `0.1.0` crates.io publish. This grew the compiler
from an early vertical slice to **100% of the *attempted* official sass-spec
suite** (13,896 / 13,896, zero failures — 11,405 byte-exact CSS outputs plus
2,491 error specs correctly rejected; the 8 remaining cases are tagged `:todo`
for dart-sass itself upstream), matching current dart-sass (1.100) byte-for-byte.
The pass is measured against a conformance harness tightened to reproduce the
official sass-spec comparator (`normalizeOutput`) exactly — collapse newline
runs only, no extra whitespace leniency — so the count holds under the upstream
comparator, not just a looser local one.

### Added

- **Byte-exact diagnostics** — errors, `@error`, `@warn`, and `@debug` now
  reproduce dart-sass's stderr byte-for-byte: source-span `╷│╵` snippets with
  carets and right-aligned gutters (tab→4 spaces), aligned stack frames
  (`root stylesheet` / `name()` / `@import`), a `--no-unicode` flag, and the
  `@import` deprecation warning (with a per-id cap/dedup deprecation registry).
  238 of the suite's 3,256 stderr expectations now match byte-for-byte (a
  `spec/run_spec.py --check-stderr` metric tracks it); the rest (other
  deprecations, multi-span layouts) build on this foundation.
- **`@use` / `@forward` module system** — built-in `sass:*` modules and user
  files, `with` configuration, namespacing, `@forward` prefix/`show`/`hide`,
  dash-insensitive member access, forward conflict resolution, and star
  (`as *`) modules.
- **Indented `.sass` syntax** — a full front-end (`Options::with_syntax`, the
  CLI `--indented` flag, `.sass` extension inference), including cross-syntax
  `@import` of partials by file extension.
- **CSS Color 4 color spaces** — `srgb`/`display-p3`/`lab`/`lch`/`oklab`/
  `oklch`/`xyz` via `color()`, with modern color serialization.
- **`@extend` and `%placeholder`s** — a faithful port of dart-sass's
  `ExtensionStore` engine: registration-order extension folding, selector
  weaving/unification/trimming, `@use`/`@forward` cross-module visibility, and
  the self-referential `:not`/`:has` pseudo cases — closing the suite's
  `@extend` family to byte-exact parity.
- **Built-in function modules** — `meta` (first-class function references via
  `get-function`/`call`, existence predicates), `math` (`clamp`/`min`/`max`/
  `round`/`log` and friends), `list` (bracket-preserving `join`/`append`),
  `map` (nested key paths, `deep-merge`/`deep-remove`), `string`
  (`split`/`unique-id`), and `selector` functions.
- **First-class mixins** — `meta.get-mixin` returns a mixin value and
  `meta.apply` invokes it (with `@content` support).
- **CLI** — compile multiple input files in one process (`sasso a.scss b.scss`,
  startup shared across files); `--loop <N>` for in-process throughput and
  `-q`/`--quiet` to suppress stdout (used by the benchmark harness).
- **Benchmark harness** — sasso registered as a first-class engine in `bench/`;
  three-way report [`bench/three_way.md`](bench/three_way.md) (sasso vs
  dart-sass vs grass).
- **`CODE_OF_CONDUCT.md`** adopting the
  [Sass Community Guidelines](https://sass-lang.com/community-guidelines/), as
  the Sass project asks every implementation to do.
- **This CHANGELOG.**

### Changed

- Selector resolution now matches dart-sass on combinator normalization,
  adjacent-compound separation, and bogus-combinator omission.
- `color` functions match dart-sass strictness: channel-unit leniency in
  `adjust`/`change`, missing/powerless-channel errors, the Microsoft `alpha()`
  filter overload, and `adjust-hue` rejecting non-legacy colors.
- `selector` functions coerce string/list arguments and validate arity, and
  accept a list of extendees in `extend`/`replace`.
- `list` builtins validate fixed-arity arguments and preserve list shape.
- Unquoted string serialization collapses newlines to spaces; custom-property
  values are emitted verbatim — both matching dart-sass.
- Control-flow blocks use semi-global scoping with a global-write guard.

### Performance

Profiling showed the compiler is allocation- and hashing-bound; a series of
hot-path cuts followed, with no behavior change (cumulative **~2× faster** on the
large benchmark vs. the original, lifting the lead over `grass` to ~1.9–2.4× and
over dart-sass to ~16–25×):

- Selector helpers `split_commas`/`tokenize_complex` return borrowed `&str`
  slices, and `copy_name`/`normalize_selector` avoid their intermediate
  `String`/`Vec` — no per-part/per-token/per-name heap allocation on the hot
  selector-resolution path.
- The compiler's internal `String`-keyed maps (variable scope, function/mixin
  tables, module maps) use a small inline FxHash hasher instead of std's
  DoS-resistant-but-slow SipHash. (Still zero runtime dependencies.)
- A **scoped bump-arena allocator** (`ScopedAlloc`): within each `compile()` a
  per-thread arena turns every allocation into a pointer bump and frees them
  wholesale (reset) at the end — a further ~1.5×. It is installed as the CLI's
  `#[global_allocator]`; library/wasm embedders can opt in the same way (it
  forwards to the system allocator outside a compile, so it's safe to install
  unconditionally). This is the library's one audited `unsafe` module —
  verified by unit tests, Miri (no UB), AddressSanitizer, and the full sass-spec
  suite run through it (zero crashes, byte-identical output); the
  rest of the crate is `deny(unsafe_code)`. Still zero runtime dependencies.
- **Smaller `Value`** — the `Color` variant's modern-color payload is boxed, so
  the `Value` enum drops from 128 to **64 bytes** (a compile-time `size_of`
  guard prevents regressions). Halves every scope-map slot, `Vec<Value>` element
  and lookup clone, with byte-identical output.
- **Zero-dependency Ryū float formatter** — a from-scratch `d2s` shortest-round-
  trip formatter on the float-to-string hot path, replacing `core::fmt`, with a
  differential fuzz test against a reference.

### Tooling

- The conformance ratchet pins the sass-spec commit (`spec/SPEC_VERSION.txt`)
  for reproducibility, with a `--latest`/`--canary` drift-detection mode.
- The conformance harness now reproduces the official sass-spec comparator
  (`sass-spec/lib/test-case/compare.ts` `normalizeOutput`) exactly, so a "pass"
  means byte-identical under the upstream comparator — no extra local leniency.

## [0.1.0] - 2026-06-06

Initial crates.io publish — an early vertical slice that already compiled
real-world SCSS byte-identically to dart-sass.

### Added

- `$variables` with lexical scoping, `!default` and `!global`.
- Nesting, the `&` parent selector with selector-list multiplication, and
  combinator normalization (`>`, `+`, `~`).
- `#{}` interpolation in selectors, property names and values.
- `//` (stripped) and `/* */` (preserved) comments.
- Numbers with units and unit arithmetic.
- A color model with fractional channels and author-spelling preservation;
  color functions (`rgb`/`rgba`/`hsl`/`hsla`/`mix`/`lighten`/`darken`/
  `percentage`/`red`/`green`/`blue`/`alpha`).
- `@import` partial inlining through a pluggable `Importer` (CSS imports pass
  through); a ready-made `FsImporter`.
- `expanded` and `compressed` output styles.
- Distribution: CLI binary (prebuilt via cargo-dist), library crate, and a
  zero-dependency WebAssembly build published to npm as `@momiji-rs/sasso`.

[Unreleased]: https://github.com/momiji-rs/sasso/compare/v0.21.0...HEAD
[0.21.0]: https://github.com/momiji-rs/sasso/compare/v0.20.0...v0.21.0
[0.20.0]: https://github.com/momiji-rs/sasso/compare/v0.19.3...v0.20.0
[0.19.3]: https://github.com/momiji-rs/sasso/compare/v0.19.2...v0.19.3
[0.19.2]: https://github.com/momiji-rs/sasso/compare/v0.19.1...v0.19.2
[0.19.1]: https://github.com/momiji-rs/sasso/compare/v0.19.0...v0.19.1
[0.19.0]: https://github.com/momiji-rs/sasso/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/momiji-rs/sasso/compare/v0.17.0...v0.18.0
[0.17.0]: https://github.com/momiji-rs/sasso/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/momiji-rs/sasso/compare/v0.15.0...v0.16.0
[0.15.0]: https://github.com/momiji-rs/sasso/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/momiji-rs/sasso/compare/v0.10.0...v0.14.0
[0.10.0]: https://github.com/momiji-rs/sasso/compare/v0.9.1...v0.10.0
[0.9.1]: https://github.com/momiji-rs/sasso/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/momiji-rs/sasso/compare/v0.8.1...v0.9.0
[0.8.1]: https://github.com/momiji-rs/sasso/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/momiji-rs/sasso/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/momiji-rs/sasso/compare/v0.6.3...v0.7.0
[0.3.0]: https://github.com/momiji-rs/sasso/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/momiji-rs/sasso/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/momiji-rs/sasso/releases/tag/v0.1.0
