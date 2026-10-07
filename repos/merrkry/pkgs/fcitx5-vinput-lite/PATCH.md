# Package maintenance

Keep command-based cloud ASR and LLM post-processing working. Local ASR must remain disabled, with no local models or inference services.

When updating, review upstream build changes, including `flake.nix` and CMake files, for new inference dependencies.

Build and run upstream tests with `nix build .#buildJobs.x86_64-linux.nur.fcitx5-vinput-lite` from the repository root.

Check derivation and runtime closures for `openfst`, `onnx`, `sherpa`, `kaldi`, and `sentencepiece`. Both searches must return no matches.
