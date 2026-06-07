# Jitterbug's nur-packages
This repo contains packages for RF decoding on NixOS.

[![Actions Badge]](../../actions/workflows/build.yml)
[![Cachix Badge]](https://jitterbug.cachix.org)
[![License Badge]](LICENSE)

<!-- badge images -->

[Actions Badge]: https://img.shields.io/github/actions/workflow/status/JuniorIsAJitterbug/nur-packages/build.yml
[Cachix Badge]: https://img.shields.io/badge/cachix-jitterbug-blue.svg
[License Badge]: https://img.shields.io/github/license/JuniorIsAJitterbug/nur-packages

## Packages
### Decoders
- [vhs-decode[-unstable|-legacy]](https://github.com/oyvindln/vhs-decode) [^1]
- [ld-decode[-unstable]](https://github.com/happycube/ld-decode) [^1]
- [tape-decode-rs](https://github.com/namazso/tape-decode-rs)

### Tools
- [cc-decoder](https://github.com/eshaz/cc_decoder)
- [cxadc-vhs-server[-jitterbug]](https://github.com/namazso/cxadc_vhs_server)
- [decode-orc[-unstable]](https://github.com/simoninns/decode-orc) [^1]
- [ld-decode-tools[-unstable]](https://github.com/simoninns/ld-decode-tools) [^1]
- [tbc-raw-stack](https://github.com/namazso/tbc-raw-stack)
- [tbc-tools[-unstable]](https://github.com/harrypm/tbc-tools) [^1]
- [tbc-video-export](https://github.com/JuniorIsAJitterbug/tbc-video-export) [^1]
- [vhs-decode-auto-audio-align](https://gitlab.com/wolfre/vhs-decode-auto-audio-align)

### Hardware
- [cxadc](https://github.com/happycube/cxadc-linux3)
- [domesdayduplicator](https://github.com/harrypm/DomesdayDuplicator)
- [misrc-tools[-unstable]](https://github.com/Stefan-Olt/MISRC)

### VapourSynth
- [vapoursynth-analog](https://github.com/JustinTArthur/vapoursynth-analog)
- [vapoursynth-bwdif](https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif)
- [vapoursynth-neofft3d](https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D)
- [vapoursynth-vsrawsource](https://github.com/JuniorIsAJitterbug/vsrawsource)

### Misc
- [amcdx-video-patcher-cli](https://mogurenko.com)
- [ltfs](https://github.com/LinearTapeFileSystem/ltfs)
- [stfs](https://github.com/pojntfx/stfs)

### Dependencies
- [binnah](https://gitlab.com/wolfre/binnah) *(vhs-decode-auto-audio-align)*
- [ezpwd-reed-solomon](https://github.com/pjkundert/ezpwd-reed-solomon) *(ld-decode-tools, tbc-tools[-unstable])*
- [hsdaoh[-misrc[-unstable]]](https://github.com/Stefan-Olt/hsdaoh) *(misrc-tools[-unstable])*
- [nodeeditor[-unstable]](https://github.com/paceholder/nodeeditor) *(decode-orc[-unstable])*
- [qwt-[qt5|qt6]](https://qwt.sourceforge.net) *(vhs-decode-legacy)*

## Modules
- [cxadc](modules/cxadc/README.md)

[^1]: Upstream project provides flake
