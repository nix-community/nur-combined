# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  p = pkgs.callPackage;
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Soundfonts
  soundfont-touhou = p ./pkgs/soundfonts/touhou { };

  # Games (Native)
  celeste-classic-2 = p ./pkgs/games/native/celeste-classic-2 { };

  # Games (Wine)
  wrapWine = p ./pkgs/wrapWine.nix { };

  celeste = p ./pkgs/games/wine/celeste { inherit wrapWine; };
  celesteMods = p ./pkgs/games/wine/celeste/mods.nix { };

  # Overrides
  obs-wayland = (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  });

  # Fetchers
  # note: zip suffix doesn't mean that only zip archives are supported,
  #       so that's why gz here is like an generic term for compression algorithms
  # source: https://www.reddit.com/r/NixOS/comments/kqe57g/comment/gi3uii6
  #         https://discourse.nixos.org/t/fetchurl-with-compressed-files/39823
  # TODO: add support for .gz, ...
  fetchzip-gz = p ./pkgs/fetchers/fetchzip-gz { };
  fetchurl-gz = p ./pkgs/fetchers/fetchurl-gz { };

  # Audio
  bitwig-custom = p ./pkgs/audio/bitwig-custom/default.nix { };

  TAL-NoiseMaker = p ./pkgs/audio/TAL-NoiseMaker { };
  TyrellN6 = p ./pkgs/audio/tyrelln6 { };
  neural-amp-modeler-lv2 = p ./pkgs/audio/neural-amp-modeler-lv2 { };

  artworks = p ./pkgs/audio/artworks { };
  nam-trainer = p ./pkgs/audio/nam-trainer { };
}
