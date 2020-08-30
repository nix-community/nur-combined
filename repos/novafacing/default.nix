# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  python37Packages = rec {
    ailment = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/ailment { inherit pyvex; };

    angr = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/angr {
      inherit archinfo ailment claripy cle cooldict mulpyplexer pyvex unicorn;
    };

    archinfo = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/archinfo {};

    claripy = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/claripy { inherit PySMT z3-solver; };

    cle = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/cle { inherit archinfo minidump pyelftools pyvex pyxbe; };

    cooldict = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/cooldict {};

    minidump = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/minidump {};

    mulpyplexer = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/mulpyplexer {};

    pyelftools = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/pyelftools {};

    pyxbe = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/pyxbe {};

    pyvex = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/pyvex { inherit archinfo unicorn; };

    PySMT = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/pysmt {};

    unicorn = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/unicorn {};

    # TODO: Remove once NixOS/nixpkgs#75125 is resolved: This is here for `claripy` to work.
    z3-solver = pkgs.python37.pkgs.callPackage ./pkgs/python-modules/z3-solver {};
  };
}
