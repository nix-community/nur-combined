# lc0 HIP Notes

State as of 2026-09-06.

## Goal

Run lc0 (including modern transformer nets) on AMD GPUs through the native
HIP backend that was merged upstream in
[lc0 PR #2420](https://github.com/LeelaChessZero/lc0/pull/2420).

## Current local setup

Package lives here:

- `pkgs/lc0-hip/default.nix`

`nixos-config` consumes it via the `foolnotion` overlay.

Key config consumers in `nixos-config`:

- `home/modules/lc0-engines.nix`
- `home/modules/lc0.nix`
- `home/modules/chess-web.nix`

Current machine GPU targets:

- `jaghut`: `gfx1201` (RX 9070 XT / Navi 48)
- `imass`: `gfx1200` (RX 9060 XT / Navi 44)

The package:

- builds `lc0` from upstream commit `ef3310638ae39644cd8d3e1fd33f05e5fe797706`
  (the native HIP merge; first commit exposing the `hip` / `hip-fp16` /
  `hip-auto` backends)
- uses the plain gcc stdenv; the only ROCm build inputs are
  `rocmPackages.clr` (HIP runtime), `hipblas`, `rocblas`, and a small `hipcc`
  wrapper (see below)
- needs no runtime wrapper: the final binary resolves `libhipblas`,
  `libamdhip64` etc. via normal nix rpaths

## The hipcc wrapper

lc0's `meson.build` calls `hipcc` directly (via `find_program`) to compile its
CUDA-spelled kernels for AMD GPUs. nixpkgs' ROCm packages are separate store
paths rather than a merged `/opt/rocm`, and upstream removed
`rocm-merged-llvm`, so bare `hipcc` cannot locate:

- the clang to drive → `HIP_CLANG_PATH=<rocmPackages.llvm.clang>/bin`
- the HIP runtime → `--rocm-path=<rocmPackages.clr>`
- the device libraries → `--rocm-device-lib-path=<rocmPackages.rocm-device-libs>/amdgcn/bitcode`

The package wraps `hipcc` once with those three spelled out and puts the
wrapper on `PATH` via `nativeBuildInputs`.

## What replaced the SYCL setup

The previous `lc0-sycl-hip` package (source-built `intel-llvm` with the
unified-runtime HIP adapter, `-Dsycl=amd`, and a runtime wrapper forcing
`UR_ADAPTERS_FORCE_LOAD` / `ONEAPI_DEVICE_SELECTOR=hip:*`) is obsolete: the
native HIP backend runs lc0's own optimized kernels directly on ROCm with no
Intel DPC++ toolchain at all.

## Benchmark summary

### Maia 2200 (conv-SE ResNet), RX 9070 XT (gfx1201), backendbench

| Batch | OpenCL nps | SYCL nps | HIP nps | HIP vs SYCL |
|---|---:|---:|---:|---:|
| 16 | 11658.7 | 20131.0 | 28508 | 1.42x |
| 64 | 20289.2 | 68842.0 | 94738 | 1.38x |
| 256 | 23853.3 | 192260.0 | 246510 | 1.28x |

### T82 (768x15x24 transformer), RX 9070 XT (gfx1201), backendbench

| Batch | SYCL nps | HIP nps | Speedup |
|---|---:|---:|---:|
| 64 | 146 | 3772 | 25.8x |
| 128 | 217 | 4586 | 21.1x |
| 256 | 278 | 4792 | 17.2x |

The transformer numbers are the headline: the SYCL path never came close to
saturating the GPU on attention-body nets; the native kernels do.

Correctness: `backendbench -b check -o "hip-fp16(),eigen(),mode=check,..."`
passes on both nets across batch sizes 1-55 (fp16 tolerance), and a UCI
`go nodes` game runs fault-free on gfx1201. Upstream's own validation covered
gfx90a and gfx1100; gfx1201/RDNA4 is validated locally by the above.

## Existing helpers

In `nixos-config`:

- `lc0-bench-opencl`
- `lc0-bench-hip`
- `lc0-bench-modern`
- `lc0-bench-modern-fixed <batch>`
- `lc0-bench-compare <batch>`

`lc0-bench-compare` is the easiest apples-to-apples local comparison.

## If upstreaming later

The nixpkgs-shaped end state would be an `lc0` variant (or meson flag set)
built with `-Dhip=true` plus the hipcc wrapper pattern, similar to how
`whisper-cpp` handles its ROCm build. The source pin and the eigen
`postPatch` line can drop out once nixpkgs' `lc0` moves past the HIP merge.
