# Package maintenance

This package follows upstream `xifan2333/fcitx5-vinput`, keeping command-based cloud ASR and LLM post-processing while removing local inference.

## Upstream basis

`default.nix` is based on upstream `flake.nix`: build dependencies, CMake flags, and Python and libopus runtime wrappers. Local inference dependencies and upstream-only build tools are omitted.

Upstream provides `VINPUT_ENABLE_LOCAL_ASR`. When disabled, CMake omits the Sherpa backends and the bundled VAD model. The backend factory rejects local providers.

## Updating

1. Read the upstream commits since the packaged revision. Inspect with `git show` every commit concerning builds, packaging, dependencies, ASR backends, local inference, models, or VAD.
2. Read the new upstream `flake.nix`, every `CMakeLists.txt`, and the build files they reference completely. Apply relevant packaging changes to `default.nix`.
3. Review how upstream selects, links, and installs local providers. Adjust the package if the lite option starts pulling in large inference dependencies or running a local inference service.

The package must avoid large local inference dependencies in its build and runtime closures, install no local models, and run no local inference service. Local ASR providers must remain unsupported. Command-based cloud ASR and LLM post-processing must remain available.

Build `.#fcitx5-vinput-lite`, run its upstream tests, then check its derivation and runtime closures for `openfst`, `onnx`, `sherpa`, `kaldi`, and `sentencepiece`. Both closure searches must return no matches.
