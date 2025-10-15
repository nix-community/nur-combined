# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  far2l = pkgs.callPackage ./pkgs/by-name/fa/far2l/default.nix { };
  _1c-enterprise-client = pkgs.callPackage ./pkgs/by-name/_1/_1c-enterprise-client/default.nix { };
  _1c-enterprise-common = pkgs.callPackage ./pkgs/by-name/_1/_1c-enterprise-common/default.nix { };
  _1c-enterprise-server = pkgs.callPackage ./pkgs/by-name/_1/_1c-enterprise-server/default.nix { };
  _1c-enterprise = pkgs.callPackage ./pkgs/by-name/_1/_1c-enterprise/default.nix { };
  _7zlib = pkgs.callPackage ./pkgs/by-name/_7/_7zlib/default.nix { };
  waterfox = pkgs.callPackage ./pkgs/by-name/wa/waterfox/default.nix { };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
