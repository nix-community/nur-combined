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
, pkgs2511 ? pkgs
, pkgsUnstable ? pkgs
, stardropPkgs ? null
, cljNix ? null
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
  #frozencpp = pkgs.callPackage ./pkgs/frozen-cpp { };
  #nexus-autodl = pkgs2505.callPackage ./pkgs/nexus-autodl { };
  bsa-browser-cli = pkgs.callPackage ./pkgs/bsa-browser-cli { };
  deflix-stremio = pkgs.callPackage ./pkgs/deflix-stremio { };
  archive-org-downloader = pkgs.callPackage ./pkgs/archive.org-downloader { };
  #glojure = pkgs.callPackage ./pkgs/glojure { };
  salmagundi = pkgs.callPackage ./pkgs/salmagundi { };
  chadstr = pkgs.callPackage ./pkgs/chadstr { };
  radontea = pkgs.callPackage ./pkgs/radontea { };
  # planetiler = pkgs.callPackage ./pkgs/planetiler { };
  # libremdb = pkgs.callPackage ./pkgs/libremdb { }; Need to fix the pnpm2nix -> I don't want to do it
  # numen = pkgs.callPackage ./pkgs/numen { };
  # clooj = pkgs.callPackage ./pkgs/clooj { inherit cljNix; };

  flat-manager = pkgs.callPackage ./pkgs/flat-manager { };
  open-battery-information = pkgs.callPackage ./pkgs/open-battery-information { };

  pypush = pkgs.callPackage ./pkgs/pypush { };

  gloriousctl = pkgs.callPackage ./pkgs/gloriousctl { };

  anisette-v3-server = pkgs.callPackage ./pkgs/anisette-v3-server { };
  #go-haystack = pkgs.callPackage ./pkgs/go-haystack { };

  hugomods-ascii = pkgs.callPackage ./pkgs/hugomods/ascii { };
  hugomods-code-block-panel = pkgs.callPackage ./pkgs/hugomods/code-block-panel { };
  hugomods-shortcodes = pkgs.callPackage ./pkgs/hugomods/shortcodes { };
  hugomods-snackbar = pkgs.callPackage ./pkgs/hugomods/snackbar { };
  hugomods-fuse-js = pkgs.callPackage ./pkgs/hugomods/fuse-js { };
  hugomods-i18n-js = pkgs.callPackage ./pkgs/hugomods/i18n-js { };
  hugomods-encoder = pkgs.callPackage ./pkgs/hugomods/encoder { };
  hugomods-decap-cms = pkgs.callPackage ./pkgs/hugomods/decap-cms { };
  hugomods-pwa = pkgs.callPackage ./pkgs/hugomods/pwa { };
  hugomods-icons = pkgs.callPackage ./pkgs/hugomods/icons { };
 
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  stardrop = pkgs.callPackage ./pkgs/stardrop {};
}
