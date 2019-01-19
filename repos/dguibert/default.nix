# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  adapters = import ./pkgs/stdenv/adapters.nix pkgs;
  inherit (adapters) optimizePackage withOpenMP optimizedStdEnv;

  example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  dyninst = pkgs.callPackage ./pkgs/dyninst { };
  palabos = pkgs.callPackage ./pkgs/palabos { };
  otf2 = pkgs.callPackage ./pkgs/otf2 { };

  score-p = pkgs.callPackage ./pkgs/score-p {
    inherit otf2;
    inherit cubew;
    inherit cubelib;
  };
  caliper = pkgs.callPackage ./pkgs/caliper {
    inherit dyninst;
  };
  cubew = pkgs.callPackage ./pkgs/cubew { };
  cubelib = pkgs.callPackage ./pkgs/cubelib { };
  cubegui = pkgs.callPackage ./pkgs/cubegui { inherit cubelib; };

  hpcg = pkgs.callPackage ./pkgs/hpcg { };
  hpl = pkgs.callPackage ./pkgs/hpl { };

  lo2s = pkgs.callPackage ./pkgs/lo2s { inherit otf2; };
  lulesh = pkgs.callPackage ./pkgs/lulesh { };

  must = pkgs.callPackage ./pkgs/must { inherit dyninst; };
  muster = pkgs.callPackage ./pkgs/muster { };
  nemo_36 = pkgs.callPackage ./pkgs/nemo/3.6.nix { xios = xios_10; };
  nemo = pkgs.callPackage ./pkgs/nemo { };
  nix-patchtools = pkgs.callPackage ./pkgs/nix-patchtools { };
  ravel = pkgs.callPackage ./pkgs/ravel {
    inherit otf2;
    inherit muster;
  };
  xios_10 = pkgs.callPackage ./pkgs/xios/1.0.nix { };
  xios = pkgs.callPackage ./pkgs/xios { };

  # miniapps
  miniapp-ping-pong = pkgs.callPackage ./pkgs/miniapp-ping-pong { inherit caliper; };
  stream = pkgs.callPackage ./pkgs/stream { };

  # fix
  gitAndTools = pkgs.gitAndTools // {
    git-annex = pkgs.haskell.lib.appendConfigureFlag pkgs.gitAndTools.git-annex "--ghc-options=-XNoMonadFailDesugaring";
  };

}

