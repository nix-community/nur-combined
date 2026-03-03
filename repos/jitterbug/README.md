# nur-packages
This repo contains packages for RF decoding on NixOS.

![Build and populate cache](https://github.com/JuniorISAJitterbug/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-jitterbug-blue.svg)](https://jitterbug.cachix.org)


## Packages
### Decoders
- [vhs-decode[-unstable]](https://github.com/oyvindln/vhs-decode)
- [ld-decode[-unstable]](https://github.com/happycube/ld-decode)

### Tools
- [cxadc-vhs-server[-jitterbug]](https://github.com/namazso/cxadc_vhs_server)
- [tbc-raw-stack](https://github.com/namazso/tbc-raw-stack)
- [tbc-video-export](https://github.com/JuniorIsAJitterbug/tbc-video-export)
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
- [ezpwd-reed-solomon](https://github.com/pjkundert/ezpwd-reed-solomon) *(vhs-decode, vhs-decode-unstable, ld-decode-unstable)*
- [hsdaoh[-unstable]](https://github.com/Stefan-Olt/hsdaoh) *(misrc-tools, misrc-tools-unstable)*
- [qwt-(qt5|qt6)](https://qwt.sourceforge.net) *(vhs-decode, vhs-decode-unstable, ld-decode)*

## Modules
- [cxadc](modules/cxadc/README.md)
- [ld-decode](modules/ld-decode/README.md)
- [vhs-decode](modules/vhs-decode/README.md)