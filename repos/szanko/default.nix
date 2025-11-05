# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ 
pkgs ? import <nixpkgs> { } 
, pkgs2311 ? pkgs
, pkgs2411 ? pkgs
, pkgs2505 ? pkgs
, pkgsUnstable ? pkgs
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays


  samloader = pkgs.callPackage ./pkgs/samloader { };
  gogextract = pkgs.callPackage ./pkgs/gogextract { };
  mmio = pkgs.callPackage ./pkgs/mmio { };
  rgsstool = pkgs.callPackage ./pkgs/rgsstool { };
  jakym = pkgs.callPackage ./pkgs/jakym { };
  #radontea = pkgs.callPackage ./pkgs/radontea { };
  robin-hood-hashing = pkgs.callPackage ./pkgs/robin-hood-hashing { };
  pciids = pkgs.callPackage ./pkgs/pciids { };
  autotoml = pkgs.callPackage ./pkgs/autotoml { };
  frozencpp = pkgs.callPackage ./pkgs/frozen-cpp { };
  #nexus-autodl = pkgs2505.callPackage ./pkgs/nexus-autodl { };
  bsa-browser-cli = pkgs.callPackage ./pkgs/bsa-browser-cli { };
  deflix-stremio = pkgs.callPackage ./pkgs/deflix-stremio { };
  archive-org-downloader = pkgs.callPackage ./pkgs/archive.org-downloader { };
  #glojure = pkgs.callPackage ./pkgs/glojure { };
  salmagundi = pkgs.callPackage ./pkgs/salmagundi { };
  chadstr = pkgs.callPackage ./pkgs/chadstr { };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
}
