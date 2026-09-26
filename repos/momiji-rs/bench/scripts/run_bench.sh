#!/usr/bin/env bash
# Reusable SCSS-compiler benchmark harness.
#
# Measures, for each engine:
#   1. cold single-file CLI wall time  (includes full process startup)
#   2. startup cost                    (compile a ~empty file; ~= pure startup)
#   3. amortized per-file cost         (compile a whole batch in ONE invocation)
#   4. pure compile throughput         (in-process tight loop, grass only;
#                                       dart-sass has no in-process mode here,
#                                       so we approximate via the amortized
#                                       batch number which removes startup)
#
# Engines are declared in the ENGINES section below. To add a third engine
# (e.g. sasso), add a block there following the same pattern: a one-shot
# command `$X <file>` printing CSS to stdout, and optionally a `--loop N` mode.
#
# Results: prints a markdown table to stdout and writes raw hyperfine JSON to
# results/. Honest about variance: hyperfine reports mean +/- stddev; we run
# >=10 timed runs with warmups.

set -euo pipefail
cd "$(dirname "$0")/.."   # -> bench/

# ---------------------------------------------------------------------------
# Engine binaries / commands
# ---------------------------------------------------------------------------
GRASS=./grass_runner/target/release/grass_runner
SASSO=../target/release/sasso   # the real shipped CLI (one-shot + --loop/--no-css)

# Locate the cached dart-sass bin (the dart2js/Node build that `npx sass` runs).
# We call it directly to measure dart-sass's OWN startup, separate from the
# ~0.9s npx resolution tax. We also benchmark `npx sass` so the npx tax is on
# the record (it's what the task spec invokes).
SASS_BIN="$(find "$HOME/.npm/_npx" -path '*node_modules/.bin/sass' 2>/dev/null | head -1)"
if [[ -z "${SASS_BIN:-}" || ! -x "$SASS_BIN" ]]; then
  # Prime the npx cache, then retry.
  npx --yes sass --version >/dev/null 2>&1 || true
  SASS_BIN="$(find "$HOME/.npm/_npx" -path '*node_modules/.bin/sass' 2>/dev/null | head -1)"
fi
echo "dart-sass bin: ${SASS_BIN:-<not found>}" >&2

# ---------------------------------------------------------------------------
# Corpus paths
# ---------------------------------------------------------------------------
LARGE=corpus/generated/large.scss
HAND=corpus/handwritten/main.scss
BATCH_DIR=corpus/batch
# A unique temp dir + a `.scss` file inside it. (`mktemp -d` is portable across
# BSD/macOS and GNU; a `tiny.XXXX.scss` *template* is NOT — BSD mktemp only
# substitutes a TRAILING run of X's, so the `.scss` suffix makes it a literal
# name that collides with a stale file and aborts the run under `set -e`.)
TINY_DIR=$(mktemp -d); TINY="$TINY_DIR/tiny.scss"; echo '.a{b:c}' > "$TINY"

RESULTS=results
mkdir -p "$RESULTS"

RUNS=${RUNS:-15}      # timed runs per measurement
WARMUP=${WARMUP:-3}

hf() { hyperfine --warmup "$WARMUP" --runs "$RUNS" "$@"; }

echo "## Raw measurements (hyperfine, ${RUNS} runs, ${WARMUP} warmups)"

# --- 1. Startup cost: compile the tiny file -------------------------------
echo "### Startup (tiny file)"
hf --export-json "$RESULTS/startup.json" \
  -n "sasso startup"      "$SASSO --no-css $TINY" \
  -n "grass startup"      "$GRASS --quiet $TINY" \
  -n "dart-sass startup"  "$SASS_BIN $TINY >/dev/null" \
  -n "npx-sass startup"   "npx --yes sass $TINY >/dev/null"

# --- 2. Cold single-file: the LARGE generated file ------------------------
echo "### Cold single-file (large generated, ~25k-line CSS)"
hf --export-json "$RESULTS/cold_large.json" \
  -n "sasso large"     "$SASSO --no-css $LARGE" \
  -n "grass large"     "$GRASS --quiet $LARGE" \
  -n "dart-sass large" "$SASS_BIN $LARGE >/dev/null" \
  -n "npx-sass large"  "npx --yes sass $LARGE >/dev/null"

# --- 3. Amortized batch: whole dir in ONE invocation ----------------------
# sasso + dart-sass: dir:dir mapping (sasso pinned to one worker so the
# comparison stays per-file). grass: pass all files as argv (runner loops).
OUTDIR=$(mktemp -d)
echo "### Amortized batch ($(ls $BATCH_DIR/*.scss | wc -l | tr -d ' ') files, one invocation each)"
hf --export-json "$RESULTS/batch.json" \
  -n "sasso batch"     "$SASSO -j 1 --no-source-map $BATCH_DIR:$OUTDIR" \
  -n "grass batch"     "$GRASS --quiet $BATCH_DIR/*.scss" \
  -n "dart-sass batch" "$SASS_BIN --no-source-map $BATCH_DIR:$OUTDIR" \
  --cleanup "rm -f $OUTDIR/*.css $OUTDIR/*.css.map 2>/dev/null || true"
rm -rf "$OUTDIR"

# --- 4. Pure in-process throughput (sasso + grass) ------------------------
echo "### Pure in-process throughput (--loop, startup excluded)"
LOOP_N=${LOOP_N:-200}
echo "Compiling $LARGE x$LOOP_N in-process:"
$SASSO --no-css --loop "$LOOP_N" "$LARGE"
$GRASS --quiet --loop "$LOOP_N" "$LARGE"
echo
echo "Compiling $HAND x$((LOOP_N*5)) in-process:"
$SASSO --no-css --loop "$((LOOP_N*5))" "$HAND"
$GRASS --quiet --loop "$((LOOP_N*5))" "$HAND"

rm -rf "$TINY_DIR"
echo "Raw JSON written to $RESULTS/"
