# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build and populate cache](https://github.com/xeals/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/xeals/nur-packages/actions) [![Cachix Cache](https://img.shields.io/badge/cachix-xeals-blue.svg)](https://xeals.cachix.org)

## Noteworthy packages

### Jetbrains with plugins

A fan of the Emacs/Vim/VSCode plugin builder? Now enjoy it with your favourite Jetbrains IDE!

The system is mostly proof-of-concept and there are a couple of issues with it at the moment, but it works for what is available in the repo.

#### Using

```nix
{ pkgs ? import <nixpkgs> {} }:
let
  xeals = import (builtins.fetchTarball "https://git.xeal.me/xeals/nur-packages/archive/master.tar.gz") {
    inherit pkgs;
  };
in
  # e.g., for IntelliJ IDEA
  xeals.jetbrains.ideaCommunityWithPlugins (jpkgs: [
    jpkgs.ideavim
    jpkgs.checkstyle-idea
  ])
```

#### Issues

- [ ] The plugin derivation overrides the base instead of extending it; this is really only an issue for the open-source IDEs, and only once they're actually built from source (instead of repackaging the JARs)
- [ ] Plugins must be manually added to the repo; long-term, I'd really want some way to scrape them, or at least have a script to add and update

### spotify-ripper

`spotify-ripper` is pretty flexible in the formats it supports, so the derivation allows you to customize which support packages to build with.

The default package comes with nothing (which is not entirely useful -- this will probably change at some point). See [the builder](./pkgs/tools/misc/spotify-ripper/default.nix) for options.

## General issues

- [ ] `spotify-ripper` does not build on stable NixOS channels before 20.09 when built with m4a or mp4 support, as `fdk-aac-encoder` is not available
- [ ] Due to changes in toolchains affected fixed output hashes, anything using `buildGoModule` and `buildRustPackage` will fail on NixOS 20.03. Override the hashes of `vendor` and `cargoDeps` attributes as needed
