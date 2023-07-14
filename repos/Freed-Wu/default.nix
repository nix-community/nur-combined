# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  allPkgs = pkgs // myPkgs;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);
  myPkgs = rec {
    # The `lib`, `modules`, and `overlay` names are special
    lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays

    mySources = callPackage ./_sources/generated.nix { };

    # https://github.com/NixOS-CN/flakes/pull/51
    netease-cloud-music = callPackage ./pkgs/netease-cloud-music { };
    # https://github.com/NixOS/nixpkgs/pull/243032
    g3kb-switch = callPackage ./pkgs/g3kb-switch { };

    help2man = callPackage ./pkgs/development/python-modules/help2man { };
    setuptools-generate = callPackage ./pkgs/development/python-modules/setuptools-generate { };
    repl-python-wakatime = callPackage ./pkgs/development/python-modules/repl-python-wakatime { };
    repl-python-codestats = callPackage ./pkgs/development/python-modules/repl-python-codestats { };
    translate-shell = callPackage ./pkgs/development/python-modules/translate-shell { };
    mulimgviewer = callPackage ./pkgs/development/python-modules/mulimgviewer { };
    autoconf-language-server = callPackage ./pkgs/development/python-modules/autoconf-language-server { };
    bitbake-language-server = callPackage ./pkgs/development/python-modules/bitbake-language-server { };
    pkgbuild-language-server = callPackage ./pkgs/development/python-modules/pkgbuild-language-server { };
    portage-language-server = callPackage ./pkgs/development/python-modules/portage-language-server { };
    requirements-language-server = callPackage ./pkgs/development/python-modules/requirements-language-server { };
    sublime-syntax-language-server = callPackage ./pkgs/development/python-modules/sublime-syntax-language-server { };
    termux-language-server = callPackage ./pkgs/development/python-modules/termux-language-server { };
    xilinx-language-server = callPackage ./pkgs/development/python-modules/xilinx-language-server { };
  };
in
myPkgs
