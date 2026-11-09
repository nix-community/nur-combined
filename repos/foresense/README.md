# foresense/nur-packages

[NUR](https://github.com/nix-community/NUR/) repository with audio/music packages.

## Open source packages

- [ConvertWithMoss](https://github.com/git-moss/ConvertWithMoss): Converts multisamples from a source format (WAV, multisample, KMP, wavestate, NKI, SFZ, SoundFont 2) to a different destination format.
- [MTS-ESP library](https://github.com/ODDSound/MTS-ESP): A simple but versatile C/C++ library for adding microtuning support to audio and MIDI plugins.
- [sektron](https://empr.cl/sektron/): A midi step sequencer that mimics hardware workflows.
- [serialosc](https://monome.org/docs/serialosc/): Multi-device, bonjour-capable monome OSC server.
- [signls](https://empr.cl/signls/): A non-linear, generative MIDI sequencer designed for music composition.
- [utu](https://github.com/madronalabs/utu): A command-line program that uses the Loris library to analyze sounds (useful for Madronalabs Sumu plugin).-----

## Binary distributions

- [Architect](https://loomer.co.uk/architect.html): Modular MIDI toolkit.
- [Aspect](https://loomer.co.uk/aspect.html): Semi-modular polyphonic synthesizer.
- [Manifold](https://loomer.co.uk/manifold.html): Ensemble processor.
- [Resound](https://loomer.co.uk/resound.html): Vintage tape echo.
- [Sequent](https://loomer.co.uk/sequent.html): Modular step-sequenced FX processor.
- [Shift](https://loomer.co.uk/shift.html): Diatonic granular pitch-shifting delay
- [String](https://loomer.co.uk/string.html): Ensemble string synthesizer

-----

## Updating packages

Run `nix develop -c ./update.sh` to update all release-tracked packages
(`convert-with-moss`, `sektron`, `signls`, `serialosc`) via
[nix-update](https://github.com/Mic92/nix-update) (in the dev shell, no global
install needed). Pass attrs to update specific packages instead, e.g.
`nix develop -c ./update.sh libmts` (pinned-rev packages: use
`--version=branch`, and check the build afterwards). The Loomer packages are
frozen — upstream is defunct, so their hashes are never updated. Build any
updated package locally (`nix build .#<attr>`) before pushing.

-----

![Build and populate cache](https://github.com/foresense/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-foresense-blue.svg)](https://foresense.cachix.org)
