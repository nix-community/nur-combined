# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  diskgraph = pkgs.callPackage ./pkgs/diskgraph { };
  freqtop = pkgs.callPackage ./pkgs/freqtop { };
  map = pkgs.callPackage ./pkgs/map { };
  microsoft-ergonomic-keyboard = pkgs.callPackage ./pkgs/microsoft-ergonomic-keyboard {
    kernel = pkgs.linuxPackages.kernel;
  };
  openscad-snapshot = pkgs.callPackage ./pkgs/openscad-snapshot { };
  # TODO: fix dependency specification
  #raspi-oled = pkgs.callPackage ./pkgs/raspi-oled { };
  #raspi-oled-cross = pkgs.pkgsCross.muslpi.callPackage ./pkgs/raspi-oled { };
  #ripgrep-all = pkgs.callPackage ./pkgs/ripgrep-all {
  #  inherit (pkgs.darwin.apple_sdk.frameworks) Security;
  #};
  sddm-theme-utah = pkgs.callPackage ./pkgs/sddm-theme-utah { };
  thumbs = pkgs.callPackage ./pkgs/thumbs { };
  tmux-thumbs = pkgs.callPackage ./pkgs/tmux-thumbs {
    inherit (pkgs.tmuxPlugins) mkTmuxPlugin;
    inherit thumbs;
  };
}
