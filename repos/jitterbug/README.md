# nur-packages
This repo contains packages for vhs-decoding on NixOS.

![Build and populate cache](https://github.com/JuniorISAJitterbug/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-jitterbug-blue.svg)](https://jitterbug.cachix.org)


## Packages in this repo
- [vhs-decode](https://github.com/oyvindln/vhs-decode) - Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats. (with [module](modules/vhs-decode/README.md))
- [cxadc](https://github.com/happycube/cxadc-linux3) - cxadc is an alternative Linux driver for the Conexant CX2388x series of video decoder/encoder chips used on many PCI TV tuner and capture cards. (with [module](modules/cxadc/README.md))
- [tbc-video-export](https://github.com/JuniorIsAJitterbug/tbc-video-export) - Tool for exporting S-Video and CVBS-type TBCs to video files.
- [vhs-decode-auto-audio-align](https://gitlab.com/wolfre/vhs-decode-auto-audio-align) - A project to automatically align synchronous (RF) HiFi and linear audio captures to a video RF capture for VHS-Decode.
- [cxadc-vhs-server](https://github.com/namazso/cxadc_vhs_server) - A terrible HTTP server made for capturing VHS with two cxadc cards and cxadc-clock-generator-audio-adc or cxadc-clockgen-mod.
- [domesdayduplicator](https://github.com/harrypm/DomesdayDuplicator) - The Domesday Duplicator is a USB3 based DAQ capable of 40 million samples per second (20mhz of bandwith) aquisition of analogue RF data.
- [misrc-extract](https://github.com/Stefan-Olt/MISRC) - Tool to extract the two ADC channels and the AUX data from the raw capture.
- [vapoursynth-bwdif](https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif) - Bwdif filter for VapourSynth. (required for QTGMC)
- [vapoursynth-neofft3d](https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D) - Neo FFT3D (forked from fft3dfilter) is a 3D Frequency Domain filter - strong denoiser and moderate sharpener.
- [vapoursynth-vsrawsource](https://github.com/JuniorIsAJitterbug/vsrawsource) - Raw format reader for VapourSynth.
- [pyhht](https://github.com/jaidevd/pyhht) - A Python module for the Hilbert Huang Transform. (required for old vhs-decode builds)
- [amcdx-video-patcher-cli](https://mogurenko.com) - AMCDX Video Patcher CLI.
- [ab-av1](https://github.com/alexheretic/ab-av1) - AV1 video encoding tool with fast VMAF sampling & automatic encoder crf calculation.
- [ltfs](https://github.com/LinearTapeFileSystem/ltfs) - Reference LTFS implementation.
- [stfs](https://github.com/pojntfx/stfs) - Simple Tape File System (STFS), a file system for tapes and tar files.
- [tzpfms](https://git.sr.ht/~nabijaczleweli/tzpfms) - TPM-based encryption keys for ZFS datasets. (disabled)