# `--watch`: how long a save takes to become CSS

The rest of this directory measures a compile. This one measures the wait a
person actually sits through: **save the file, watch the browser**. Harness:
[`scripts/watch_latency.mjs`](./scripts/watch_latency.mjs), which takes any
engine.

```
node bench/scripts/watch_latency.mjs node wasm/npm/cli.mjs
node bench/scripts/watch_latency.mjs path/to/sass
```

Each measurement runs in its own temp directory, so the harness pins any
argument that names a real file to an absolute path before spawning —
otherwise the invocation above looks for `<temp>/wasm/npm/cli.mjs` and dies
before the first sample, which is how it shipped the first time.

## Current state (measured 2026-09-19, macOS, M2 Max)

Median edit-to-correct-CSS, 15 saves per style, three runs back to back on
one machine so the columns are comparable.

| save style | sasso before #137 | **sasso now** | dart-sass 1.104.1 |
|---|---|---|---|
| atomic (temp file + rename) | 63.7 ms | **12.4 ms** | 82.4 ms |
| quick (truncate + write) | 63.6 ms | **12.4 ms** | 83.7 ms |
| slow (truncate, pause, finish) | 113.4 ms | **63.0 ms** | 107.5 ms |

Zero spurious errors in every cell.

## Why three save styles, and why errors are in the table

Editors do not save the same way, and the difference decides the design.

- **atomic** — write a temp file, rename over the target. A reader sees the
  old bytes or the new ones, never half.
- **quick** — truncate and write in one go. A reader can catch it empty, but
  the window is microseconds.
- **slow** — truncate, write, pause, finish. A large file, a network
  filesystem, a formatter that streams. The window is real.

A watcher that compiles the instant the first event arrives is fastest on
`atomic` and worst on `slow`: it reads a half-written file, reports a parse
error, deletes the output, and then has to compile *again* when the write
lands. Three designs were tried that way, and each printed an error on
**15 of 15** slow saves while looking faster in the latency column.

So the harness prints the error count beside the milliseconds and marks any
row that has one as **"not a faster row"**. The number alone is what led
#137 to the wrong conclusion in the first place — that the 50 ms debounce
was dead weight, when it was the window in which a save finishes.

What ships is a **provisional first compile**: the head of a burst compiles
immediately, and if it fails it says nothing, removes nothing, and asks for
a catch-up at the end of the window. The catch-up is authoritative. A
half-written file costs one wasted compile; a real error arrives 50 ms later
than it used to.

## The survey that is not taken

`--watch` keeps two snapshots — the mtimes of everything loaded, and a
listing of the watched directories minus our own output — for events that
`fs.watch` delivers without a filename. macOS and Linux always name their
events, so on both those platforms the snapshots are never taken at all.

That laziness is not a micro-optimisation. Taking them on every compile,
which is how they first shipped, costs a directory survey per edit:

| files on the load path | eager | lazy |
|---|---|---|
| 10 | 13.7 ms | 13.4 ms |
| 500 | 16.2 ms | — |
| 2000 | 22.7 ms | 13.4 ms |
| 5000 | 37.6 ms | 13.4 ms |

A big `-I` directory would have eaten most of the improvement above. The
first nameless event a platform does send compiles unconditionally — there
is nothing to compare it against yet — and turns snapshotting on from
then.

## A difference from dart worth knowing

dart's `--watch` **does not follow a dependency into another directory.**
Measured with an entry in `src/`, one dependency beside it, one reached by
`../far/far`, and one found through `-I inc`:

```
dart    _near.scss=yes  _far.scss=NO   _viaload.scss=yes
sasso   _near.scss=yes  _far.scss=yes  _viaload.scss=yes
```

dart watches the entry's own directory and the load paths. We watch the
directory of every file the compile loaded.

This is not a micro-optimisation, it is whether the tool works: Lichess
writes its imports as `@import '../../../lib/css/component/slist'`, so on
that tree dart's watcher never fires for most of the codebase, and an
earlier version of the latency harness recorded it as a 60-second timeout
ten times in a row before the cause was clear.

## What is not measured here

- **The binary has no `--watch`** yet (#86), so every number above is the
  npm CLI. When the binary grows one it should be added as a column, and it
  should implement the same provisional rule rather than rediscovering it.
- **Throughput under a burst.** The harness leaves 400 ms between saves so
  each measures one edit rather than the tail of the last. How many compiles
  a burst costs is a different question, covered by the `--watch` tests in
  `wasm/test.mjs` rather than by a number here.
