# nur-packages
This repo contains packages for vhs-decoding on NixOS.

![Build and populate cache](https://github.com/JuniorISAJitterbug/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-jitterbug-blue.svg)](https://jitterbug.cachix.org)


# [vhs-decode](https://github.com/oyvindln/vhs-decode)
vhs-decode consists of a package and module.

The package must be in your in your `nixpkgs` via `packageOverrides` for the module to work.

Enable `exportVersionVariable` to have the environment variable `__VHS_DECODE_VERSION` set to the git hash.

## Example
```
{
  nixpkgs.config.packageOverrides = pkgs: {
    vhs-decode = url.vhs-decode;
  };

  programs.vhs-decode = {
    enable = true;
    exportVersionVariable = true;
  }
}
```

# [cxadc](https://github.com/happycube/cxadc-linux3)
cxadc consists of a package (a kernel driver) and a module.

You can set device parameters using `cxadc.parameters.*.parameter`. This uses udev and may require `udevadm trigger` to reload.

Set the group the device belongs to with `group` to allow non-root access. This uses udev and may require `udevadm trigger` to reload.

Enable `exportVersionVariable`to have the environment variable `__CXADC_VERSION` set to the git hash.

## Example
```
{
    hardware.cxadc = {
        enable = true;
        group = "video";
        exportVersionVariable = true;

        parameters = {
            cxadc0 = {
                crystal = 40000000;
                level = 0;
                sixdb = false;
                tenbit = true;
                tenxfsc = 0;
                vmux = 1;
            }

            cxadc1 = {
                center_offset = -15;
                crystal = 40000000;
                level = 0;
                sixdb = false;
                tenbit = true;
                tenxfsc = 0;
                vmux = 1;
            }
        };
    };
}
```

# [ltfs](https://github.com/LinearTapeFileSystem/ltfs)
The reference LTFS implementation.

# [stfs](https://github.com/pojntfx/stfs)
Simple Tape File System (STFS), a file system for tapes and tar files.

# [vapoursynth-bwdif](https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif)
Dependency for QTGMC.

# [vapoursynth-neofft3d](https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D)
Fork of fft3dfilter.

# [amcdx-video-patcher-cli](https://mogurenko.com)
Tool for editing ProRes MOV files.

# [pyhht](https://github.com/jaidevd/pyhht)
Dependency for vhs-decode.

# [tbc-video-export](https://github.com/JuniorIsAJitterbug/tbc-video-export)
Script for exporting TBC files to video.

# [tzpfms](https://git.sr.ht/~nabijaczleweli/tzpfms)
TPM-based encryption keys for ZFS datasets.

(currently disabled until zfs 2.2 supported)