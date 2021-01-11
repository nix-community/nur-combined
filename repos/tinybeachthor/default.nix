# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> {}
}:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  libraries = import ./pkgs/libraries { inherit pkgs; };

  vimPlugins = import ./pkgs/vimPlugins { inherit pkgs; };

  spotify-authenticate = pkgs.callPackage ./pkgs/spotify-authenticate { };
  jlink = pkgs.callPackage ./pkgs/jlink { };
  operator-sdk = pkgs.callPackage ./pkgs/operator-sdk { };
  i3status-rust = pkgs.callPackage ./pkgs/i3status-rust { };
  fluidsynth = pkgs.callPackage ./pkgs/fluidsynth {
    inherit (pkgs.stdenv.darwin.apple_sdk.frameworks)
    AudioUnit CoreAudio CoreMIDI CoreServices;
  };
}
