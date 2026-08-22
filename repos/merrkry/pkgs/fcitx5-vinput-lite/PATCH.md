# Patch maintenance

This package follows upstream `xifan2333/fcitx5-vinput`, keeping command-based cloud ASR and LLM post-processing while removing local inference.

## Upstream basis

`default.nix` is based on upstream `flake.nix`: build dependencies, CMake flags, and Python and libopus runtime wrappers. Local inference dependencies and upstream-only build tools are omitted.

The patch adds `VINPUT_ENABLE_LOCAL_ASR`. When disabled, CMake replaces the Sherpa backends with `sherpa_disabled_backend.cpp` and omits the bundled VAD model.

## Updating

1. Read the upstream commits since the packaged revision. Inspect with `git show` every commit concerning builds, packaging, dependencies, ASR backends, local inference, models, or VAD.
2. Read the new upstream `flake.nix`, every `CMakeLists.txt`, and the build files they reference completely. Apply relevant packaging changes to `default.nix`.
3. Rewrite the patch when upstream changes how local providers are selected, compiled, linked, or installed. A patch that applies may still leave new inference code enabled.

The result must compile no local inference source, reference no local inference library or model, and reject every local ASR backend as unsupported. Command-based cloud ASR and LLM post-processing must remain available.

Build `.#fcitx5-vinput-lite`, run its upstream tests, then check its derivation and runtime closures for `openfst`, `onnx`, `sherpa`, `kaldi`, and `sentencepiece`. Both closure searches must return no matches.
