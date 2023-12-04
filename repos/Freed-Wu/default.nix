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

    # https://github.com/NixOS/nixpkgs/pull/243429
    netease-cloud-music = callPackage ./pkgs/applications/audio/netease-cloud-music { };
    # https://github.com/NixOS/nixpkgs/pull/243032
    g3kb-switch = callPackage ./pkgs/tools/misc/g3kb-switch { };

    gdb-prompt = callPackage ./pkgs/development/libraries/gdb-prompt { };
    tcl-prompt = callPackage ./pkgs/development/libraries/tcl-prompt { };
    bash-prompt = callPackage ./pkgs/shells/bash/bash-prompt { };
    undollar = callPackage ./pkgs/tools/misc/undollar { };
    manpager = callPackage ./pkgs/tools/misc/manpager { };
    # https://github.com/NixOS/nixpkgs/issues/261342
    repl-python-wakatime = callPackage ./pkgs/development/python-modules/repl-python-wakatime { };
    repl-python-codestats = callPackage ./pkgs/development/python-modules/repl-python-codestats { };
    translate-shell = callPackage ./pkgs/development/python-modules/translate-shell { };
    mulimgviewer = callPackage ./pkgs/development/python-modules/mulimgviewer { };
    # autotools-language-server = callPackage ./pkgs/development/python-modules/autotools-language-server { };
    # bitbake-language-server = callPackage ./pkgs/development/python-modules/bitbake-language-server { };
    expect-language-server = callPackage ./pkgs/development/python-modules/expect-language-server { };
    mutt-language-server = callPackage ./pkgs/development/python-modules/mutt-language-server { };
    # requirements-language-server = callPackage ./pkgs/development/python-modules/requirements-language-server { };
    sublime-syntax-language-server = callPackage ./pkgs/development/python-modules/sublime-syntax-language-server { };
    # termux-language-server = callPackage ./pkgs/development/python-modules/termux-language-server { };
    tmux-language-server = callPackage ./pkgs/development/python-modules/tmux-language-server { };
    xilinx-language-server = callPackage ./pkgs/development/python-modules/xilinx-language-server { };
    zathura-language-server = callPackage ./pkgs/development/python-modules/zathura-language-server { };
  };
in
myPkgs
