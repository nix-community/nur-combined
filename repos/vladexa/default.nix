# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  crossSystem ? null,
  pkgs ? import <nixpkgs> { inherit crossSystem; },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  mozlz4 = pkgs.callPackage ./pkgs/mozlz4 { };
  arangodb = pkgs.callPackage ./pkgs/arangodb/package.nix {
    stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc13;
  };
  SteamTokenDumper = pkgs.callPackage ./pkgs/SteamTokenDumper/package.nix { };
  h3get = pkgs.callPackage ./pkgs/h3get/package.nix { };
  bgutil-ytdlp-pot-provider.server =
    pkgs.callPackage ./pkgs/bgutil-ytdlp-pot-provider/server/package.nix
      { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
