# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  # acmed = pkgs.callPackage ./pkgs/acmed { };

  alquitran = pkgs.callPackage ./pkgs/alquitran { };

  autorandr-rs = pkgs.callPackage ./pkgs/autorandr-rs { };

  blflash = pkgs.callPackage ./pkgs/blflash { };

  bouffalo-cli = pkgs.callPackage ./pkgs/bouffalo-cli { };

  #bpf-linker = pkgs.callPackage ./pkgs/bpf-linker { };

  check_mk-agent = pkgs.callPackage ./pkgs/check_mk-agent { };

  conduit = pkgs.callPackage ./pkgs/conduit { };

  espflash = pkgs.callPackage ./pkgs/espflash { };

  deploy-rs = pkgs.callPackage ./pkgs/deploy-rs { };

  firejail = pkgs.callPackage ./pkgs/firejail { };

  freenukum = pkgs.callPackage ./pkgs/freenukum { };

  gobi_loader = pkgs.callPackage ./pkgs/gobi_loader { };

  innernet = pkgs.callPackage ./pkgs/innernet { };

  libcerror = pkgs.callPackage ./pkgs/libcerror { };

  #libcthreads = pkgs.callPackage ./pkgs/libcthreads { };

  #libcdata = pkgs.callPackage ./pkgs/libcdata { };

  mumble-web-proxy = pkgs.callPackage ./pkgs/mumble-web-proxy { };

  nixpkgs-check = pkgs.callPackage ./pkgs/nixpkgs-check { };

  pixelpwnr = pkgs.callPackage ./pkgs/pixelpwnr { };

  photoview-api = pkgs.callPackage ./pkgs/photoview-api { };

  routinator = pkgs.callPackage ./pkgs/routinator { };

  wireguard-vanity-address = pkgs.callPackage ./pkgs/wireguard-vanity-address { };

  #zellij = pkgs.callPackage ./pkgs/zellij { };

}

