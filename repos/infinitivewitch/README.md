# NUR Spellbook

> The Unholy [NUR](https://github.com/nix-community/NUR) repository

[![Deploy](https://github.com/infinitivewitch/nurspellbook/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/infinitivewitch/nurspellbook/actions/workflows/deploy.yml)
[![Update](https://github.com/infinitivewitch/nurspellbook/actions/workflows/update.yml/badge.svg?branch=main)](https://github.com/infinitivewitch/nurspellbook/actions/workflows/update.yml)
[![Cachix](https://img.shields.io/badge/cachix-infinitivewitch-white.svg)](https://infinitivewitch.cachix.org)
[![WakaTime](https://wakatime.com/badge/github/infinitivewitch/nurspellbook.svg)](https://wakatime.com/badge/github/infinitivewitch/nurspellbook)

## Contents

### Modules

|       Name        |                   Description                   |
| :---------------: | :---------------------------------------------: |
| `lillipup-tweaks` | Hardware tweaks for the **lillipup** chromebook |

### Packages

|       Name       |                      Description                      |
| :--------------: | :---------------------------------------------------: |
| [eupnea-scripts] | Audio scripts and settings for **chromebook** devices |

## Acknowledgments

- [**hercules-ci**](https://github.com/divnix)
  - https://github.com/hercules-ci/flake-parts
    - for the **whole _flake-parts_ framework**
- [**linyinfeng**](https://github.com/linyinfeng)
  - https://github.com/linyinfeng/nur-packages
    - for the [lib](./scrolls/lib/library.nix) functions
    - for many bits under [scrolls](./scrolls/)
    - **check all files with:**
      - `nix-shell -p reuse --run "reuse spdx | awk -v RS='' -v ORS='\n\n' '/lin.yinfeng@outlook.com/'"`

## License

This work is licensed under multiple licences.

- All original source code is licensed under **MIT**.
- All documentation is licensed under **CC-BY-SA-4.0**.

For more accurate information, check the individual files and the data at [.reuse/dep5](.reuse/dep5).

[eupnea-scripts]: https://github.com/eupnea-linux/audio-scripts
