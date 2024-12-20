# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  cloudflare-ddns = pkgs.callPackage ./pkgs/cloudflare-ddns { };
  nh_plus = pkgs.callPackage ./pkgs/nh_plus { };
  # oracle-cloud-agent = pkgs.callPackage ./pkgs/oracle-cloud-agent { };
  kanata = pkgs.callPackage ./pkgs/kanata { };
  rename_music = pkgs.callPackage ./pkgs/rename_music {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
