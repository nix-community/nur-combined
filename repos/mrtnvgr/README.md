# nurpkgs

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build](https://github.com/mrtnvgr/nurpkgs/workflows/Build/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-mrtnvgr-blue.svg)](https://mrtnvgr.cachix.org)

## Updating

Packages are updated automatically once a week by the
[Update](https://github.com/mrtnvgr/nurpkgs/actions/workflows/update.yml) workflow,
which runs [`nix-update`](https://github.com/Mic92/nix-update) and bumps `flake.lock`.

To update a package manually:

```console
$ nix run nixpkgs#nix-update -- --flake <package>
```

Packages without a machine-readable upstream feed (e.g. `celeste`, `celesteMods`,
`anina`, `TAL-NoiseMaker`, `soundfont-touhou`) are still updated by hand.

## Packages

### Soundfonts

- [touhou](https://musical-artifacts.com/artifacts/433)

### Games

- [celeste](https://www.celestegame.com)

- [celeste-classic-2](https://mattmakesgames.itch.io/celeste-classic-2)

### Audio

#### DAWs

- [js_ReaScriptAPI](https://github.com/juliansader/ReaExtensions)

#### Plugins

- [TAL-NoiseMaker](https://tal-software.com/products/TAL-NoiseMaker)
- [ANINA](https://crql.works/archive/anina/)
- [PitchNet](https://github.com/SessionLoops/PitchNet)

#### Utilities

- [nam-trainer](https://github.com/sdatkinson/neural-amp-modeler)

### Media

- **obs-studio-plus** - obs with plugins for wayland, pipewire support and more

### Fetchers

- **fetchurl-gz** - `fetchurl` but with decompression support
- **fetchzip-gz** - `fetchzip` but with decompression support
