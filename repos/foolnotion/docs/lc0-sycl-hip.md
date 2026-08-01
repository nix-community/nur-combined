# lc0 SYCL/HIP Notes

State as of 2026-07-31.

## Goal

Make `lc0` run newer transformer nets on AMD GPUs through the SYCL HIP path,
then upstream the packaging/runtime pieces to nixpkgs.

## Current local setup

Package lives here:

- `pkgs/lc0-sycl-hip/default.nix`

`nixos-config` consumes it via the `foolnotion` overlay.

Key config consumers in `nixos-config`:

- `home/modules/lc0-engines.nix`
- `home/modules/lc0.nix`
- `home/modules/chess-web.nix`

Current machine GPU targets:

- `jaghut`: `gfx1201` (RX 9070 XT / Navi 48)
- `imass`: `gfx1200` (RX 9060 XT / Navi 44)

The package currently:

- builds `lc0` from upstream commit `d8ce48258c39d331c119f8c8729374ceb3df8409`
- uses source-built `intel-llvm` with:
  - `rocmSupport = true`
  - `cudaSupport = false`
  - `levelZeroSupport = false`
  - `nativeCpuSupport = false`
- wraps the runtime to force:
  - `UR_ADAPTERS_FORCE_LOAD=.../libur_adapter_hip.so.0`
  - `ONEAPI_DEVICE_SELECTOR=hip:*`

## What we learned

### oneAPI binary bundle is not enough

The packaged `intel-oneapi-toolkit` runtime shipped:

- `libur_adapter_level_zero.so`
- `libur_adapter_opencl.so`

but not:

- `libur_adapter_hip.so`

So `sycl-ls` initially saw no AMD SYCL platform.

### source-built `intel-llvm` is the right base

`intel-llvm`'s in-tree `unified-runtime` can build the HIP adapter with:

- `UR_BUILD_ADAPTER_HIP=ON`

That produced a working `libur_adapter_hip.so`.

### runtime stack mismatch mattered

Mixing the binary oneAPI runtime with a source-built HIP adapter caused
libstdc++ ABI problems (`CXXABI_1.3.15` missing from the bundled VTune copy).

Using the source-built `intel-llvm` stack consistently is cleaner.

## Runtime status

The current local package is good enough to:

- build cleanly
- discover the AMD HIP SYCL platform
- run `lc0`
- return moves on `jaghut`

Useful direct smoke test:

```bash
{
  printf 'uci\n'
  printf 'isready\n'
  printf 'position startpos\n'
  printf 'go nodes 10\n'
  sleep 2
  printf 'quit\n'
} | lc0-gm --weights=/nix/store/hx6aq1b6yn2xa9gwkfacw2vg76hskca5-maia-2200.pb.gz
```

Expected result: `bestmove ...`

## Benchmark summary

### Maia, SYCL vs OpenCL on RX 9070 XT

| Batch | OpenCL nps | SYCL nps | Speedup |
|---|---:|---:|---:|
| 16 | 11658.7 | 20131.0 | 1.73x |
| 64 | 20289.2 | 68842.0 | 3.39x |
| 256 | 23853.3 | 192260.0 | 8.06x |

### T82, SYCL absolute throughput on RX 9070 XT

| Batch | SYCL nps | SYCL ms |
|---|---:|---:|
| 64 | 146 | 438.8 |
| 128 | 217 | 589.4 |
| 256 | 278 | 921.8 |

Interpretation:

- classic-net SYCL is clearly faster than old OpenCL on RDNA4
- modern transformer nets run successfully
- modern-net throughput still looks far from fully saturating the GPU

## Existing helpers

In `nixos-config`, current helper commands are:

- `lc0-bench-opencl`
- `lc0-bench-sycl`
- `lc0-bench-modern`
- `lc0-bench-modern-fixed <batch>`
- `lc0-bench-compare <batch>`

`lc0-bench-compare` is the easiest apples-to-apples local comparison.

## If resuming later

The next proper step is not more local hacking in `nixos-config`.

Make a nixpkgs branch and focus first on:

- `pkgs/by-name/in/intel-llvm/unified-runtime.nix`
- `pkgs/by-name/in/intel-llvm/package.nix`
- possibly `pkgs/by-name/in/intel-llvm/tests.nix`

Likely upstream goals:

1. Ensure HIP adapter support is built/exposed cleanly in `intel-llvm` / `unified-runtime`.
2. Ensure the runtime discovery path for HIP works without local wrapper hacks.
3. Only after that, decide whether `lc0` itself should get a first-class SYCL variant in nixpkgs.

## Important caveat

The local `lc0-sycl-hip` package currently uses a runtime wrapper and is meant
as a proof-of-work / integration scaffold, not final upstream shape.
