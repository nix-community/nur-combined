#!/usr/bin/env bash
# Build BOTH wasm variants, size-optimize each with wasm-opt, and stage them
# into the npm package dir:
#   • size  (default): cargo opt-level=z + wasm-opt -Oz  -> npm/sasso.wasm
#   • speed ("/speed"): cargo opt-level=3 + wasm-opt -O3  -> npm/sasso.speed.wasm
# Both embed the scoped bump arena (see ../src/arena.rs); the arena reservation
# defaults to 32 MiB and is overridable at build time via SASSO_WASM_ARENA_MB
# and at runtime via the loader's `configure({ arenaMiB })`.
#
# Each variant builds in its OWN target dir: switching cargo's opt-level within
# one target dir can reuse a stale artifact (the env override doesn't always
# refingerprint), so isolating them guarantees a true z/3 build each.
#
# Local-dev note: if `rustc` on PATH is Homebrew's, it lacks the wasm rust-std,
# so we fall back to rustup's stable rustc (which has it). CI uses a clean
# rustup toolchain, so no fallback is needed there.
set -euo pipefail
cd "$(dirname "$0")"

TARGET=wasm32-unknown-unknown

rustc_path="$(command -v rustc || true)"
if [[ "$rustc_path" == /opt/homebrew/* || "$rustc_path" == /usr/local/* ]]; then
  for c in "$HOME"/.rustup/toolchains/stable-*/bin/rustc; do
    if [[ -x "$c" ]]; then
      export RUSTC="$c"
      echo "note: PATH rustc is system/Homebrew; using rustup rustc: $RUSTC"
      break
    fi
  done
fi

mkdir -p npm

# build_variant <name> <cargo-opt-level> <wasm-opt-flag> <out.wasm>
build_variant() {
  local name="$1" opt="$2" wopt="$3" out="$4"
  local tdir="target-$name"
  echo ">> [$name] cargo build --release (opt-level=$opt) --target $TARGET"
  CARGO_TARGET_DIR="$tdir" CARGO_PROFILE_RELEASE_OPT_LEVEL="$opt" \
    cargo build --lib --release --target "$TARGET"
  local raw="$tdir/$TARGET/release/sasso_wasm.wasm"
  if command -v wasm-opt >/dev/null 2>&1; then
    echo ">> [$name] wasm-opt $wopt"
    wasm-opt "$wopt" --enable-bulk-memory --enable-nontrapping-float-to-int --enable-sign-ext "$raw" -o "$out"
  else
    echo "note: wasm-opt not found; shipping the unoptimized $name module"
    cp "$raw" "$out"
  fi
  local raw_sz out_sz gz_sz
  raw_sz=$(wc -c <"$raw"); out_sz=$(wc -c <"$out"); gz_sz=$(gzip -9 -c "$out" | wc -c)
  printf '   [%s] raw=%s  wasm-opt=%s  gzip=%s bytes -> %s\n' "$name" "$raw_sz" "$out_sz" "$gz_sz" "$out"
}

build_variant size  z -Oz npm/sasso.wasm
build_variant speed 3 -O3 npm/sasso.speed.wasm

# Async variants: asyncify each build so the *async* JS APIs (compileStringAsync
# / compileAsync / the Compiler API) can suspend the whole compile across an
# `await` and thus support ASYNCHRONOUS importers — the kind sass-loader and Vite
# inject by default. ~2x the source module's size, so the loader uses them only
# on the async path (sync compiles keep the fast non-asyncify'd modules). Reuses
# each variant's raw artifact; the --asyncify pass runs BEFORE the opt level
# (same ordering for both variants — do not reorder).
# build_async <name> <raw-target-dir> <wasm-opt-flag> <out.wasm>
build_async() {
  local name="$1" tdir="$2" wopt="$3" out="$4"
  local raw="$tdir/$TARGET/release/sasso_wasm.wasm"
  if command -v wasm-opt >/dev/null 2>&1; then
    echo ">> [$name] wasm-opt --asyncify $wopt"
    wasm-opt "$raw" -o "$out" \
      --asyncify \
      --pass-arg=asyncify-imports@sasso_host.host_canonicalize,sasso_host.host_load,sasso_host.host_call_function \
      "$wopt" --enable-bulk-memory --enable-nontrapping-float-to-int --enable-sign-ext
  else
    # No wasm-opt -> ship the non-asyncify'd module. The loader detects the
    # missing asyncify_* exports and degrades gracefully (async importers then
    # behave as on the sync path).
    echo "note: wasm-opt not found; $name module will NOT support async importers"
    cp "$raw" "$out"
  fi
  local out_sz gz_sz; out_sz=$(wc -c <"$out"); gz_sz=$(gzip -9 -c "$out" | wc -c)
  printf '   [%s] wasm-opt=%s  gzip=%s bytes -> %s\n' "$name" "$out_sz" "$gz_sz" "$out"
}
build_async async       target-size  -Oz npm/sasso.async.wasm
build_async speed-async target-speed -O3 npm/sasso.speed.async.wasm

echo ">> done: npm/sasso.wasm (size), npm/sasso.speed.wasm (speed), npm/sasso.async.wasm (async), npm/sasso.speed.async.wasm (speed async)"
