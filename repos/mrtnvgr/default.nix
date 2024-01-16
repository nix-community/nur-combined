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
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Soundfonts
  soundfont-arachno = p ./pkgs/soundfonts/arachno { };
  soundfont-touhou = p ./pkgs/soundfonts/touhou { };

  # Games (Native)
  celeste-classic = p ./pkgs/games/native/celeste-classic { };
  celeste-classic-pm = celeste-classic.override { practiceMod = true; };

  celeste-classic-2 = p ./pkgs/games/native/celeste-classic-2 { };

  # Games (Wine)
  celeste = p ./pkgs/games/wine/celeste { inherit (lib) wrapWine; };
  celesteMods = p ./pkgs/games/wine/celeste/mods.nix { };

  # Fonts
  comic-code = p ./pkgs/fonts/comic-code { };

  # Overrides
  obs-wayland = (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  });

  cascadia-code-nerd-font = (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; });
  cascadia-mono-nerd-font = (pkgs.nerdfonts.override { fonts = [ "CascadiaMono" ]; });

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
