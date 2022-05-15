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

  #spotify-adblock-linux = pkgs.callPackage ./pkgs/spotify-adblock-linux { };

  ricochet-refresh = pkgs.libsForQt5.callPackage ./pkgs/ricochet-refresh/default.nix { };

  aether-server = pkgs.libsForQt5.callPackage ./pkgs/aether-server/default.nix { };

  archive-org-downloader = pkgs.callPackage ./pkgs/archive-org-downloader/default.nix { };

  rpl = pkgs.callPackage ./pkgs/rpl/default.nix { };

  svn2github = pkgs.callPackage ./pkgs/svn2github/default.nix { };

  recaf-bin = pkgs.callPackage ./pkgs/recaf-bin/default.nix { };

  github-downloader = pkgs.callPackage ./pkgs/github-downloader/default.nix { };

  oci-image-generator = pkgs.callPackage ./pkgs/oci-image-generator-nixos/default.nix { };

  /*
  linux-firecracker = pkgs.callPackage ./pkgs/linux-firecracker { };
  FIXME eval error
    linuxManualConfig

    error: cannot import '/nix/store/wncs0mpydwbj89bljzfldk5vij0dalwy-config.nix', since path '/nix/store/ngggbr62d4nk754m3bj3s5fy11j1ginn-config.nix.drv' is not valid

           at /nix/store/hlzqh8yqzrzp2knrrndf9133k6hxsbjv-source/pkgs/os-specific/linux/kernel/manual-config.nix:7:28:

                6| let
                7|   readConfig = configfile: import (runCommand "config.nix" {} ''
                 |                            ^
  */

  hazel-editor = pkgs.callPackage ./pkgs/hazel-editor { };

  brother-hll3210cw = pkgs.callPackage ./pkgs/brother-hll3210cw { };

  rasterview = pkgs.callPackage ./pkgs/rasterview { };

  srtgen = pkgs.callPackage ./pkgs/srtgen { };

  gaupol = pkgs.callPackage ./pkgs/gaupol/gaupol.nix { };

  autosub-by-abhirooptalasila = pkgs.callPackage ./pkgs/autosub-by-abhirooptalasila/autosub.nix { };

  proftpd = pkgs.callPackage ./pkgs/proftpd/proftpd.nix { };

  pyload = pkgs.callPackage ./pkgs/pyload/pyload.nix { };

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
