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

  hmModules = import ./hm-modules;

  _3dstool = pkgs.callPackage ./pkgs/3dstool { };
  lnshot = pkgs.callPackage ./pkgs/lnshot { };
  save3ds = pkgs.callPackage ./pkgs/save3ds { };
  cleaninty = pkgs.python3Packages.callPackage ./pkgs/cleaninty { };
  rvthtool = pkgs.callPackage ./pkgs/rvthtool { };
  themethod3 = pkgs.callPackage ./pkgs/themethod3 { };
  makebax = pkgs.callPackage ./pkgs/makebax { };
  ctrtool = pkgs.callPackage ./pkgs/ctrtool { };
  makerom = pkgs.callPackage ./pkgs/makerom { };
  homebox-bin = pkgs.callPackage ./pkgs/homebox-bin { };
  _3dslink = pkgs.callPackage ./pkgs/3dslink { };

  mediawiki_1_39 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.39.8";
    hash = "sha256-rSf8yOY2F5wryiH/5hnW0uYtNDkNaCiwZ3/HaG5qCmo=";
  };
  mediawiki_1_40 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.40.4";
    hash = "sha256-hUkUPBFma+u4SxT1pTzxMXCwcSEbf86BjNsNoF756J4=";
  };
  mediawiki_1_41 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.41.2";
    hash = "sha256-UrtCw071AvZt/FSSGVq2rBVobK6m2Ir9JICyjL1rHOU=";
  };
  mediawiki_1_42 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.42.1";
    hash = "sha256-7IevlaNd0Jw01S4CeVZSoDCrcpVeQx8IynIqc3N+ulM=";
  };

  kwin-move-window = pkgs.callPackage ./pkgs/kwin-move-window { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  # compatibility
  "3dstool" = _3dstool;
  "3dslink" = _3dslink;
}
