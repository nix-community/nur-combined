# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }: rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  aria-csv = pkgs.callPackage ./pkgs/aria-csv {
    aria-csv-cmake = ./pkgs/aria-csv/aria-csv-cmake;
  };

  asmjit = pkgs.callPackage ./pkgs/asmjit { };

  autodiff = pkgs.callPackage ./pkgs/autodiff { };

  cmake-init = pkgs.python39Packages.callPackage ./pkgs/cmake-init { };

  cmaketools = pkgs.python39Packages.callPackage ./pkgs/cmaketools { };

  cpp-sort = pkgs.callPackage ./pkgs/cpp-sort { };

  cutechess = pkgs.libsForQt5.callPackage ./pkgs/cutechess { };

  eli5 = pkgs.python39Packages.callPackage ./pkgs/eli5 { };

  eovim = pkgs.callPackage ./pkgs/eovim { };

  eve = pkgs.callPackage ./pkgs/eve { };

  expected-lite = pkgs.callPackage ./pkgs/expected-lite { };

  fast_float = pkgs.callPackage ./pkgs/fast_float { };

  keyd = pkgs.callPackage ./pkgs/keyd { };

  linasm = pkgs.callPackage ./pkgs/linasm { };

  mathpresso = pkgs.callPackage ./pkgs/mathpresso { };

  pareto = pkgs.python39Packages.callPackage ./pkgs/pareto { };

  pegtl = pkgs.callPackage ./pkgs/pegtl { };

  pmlb = pkgs.python39Packages.callPackage ./pkgs/pmlb { };

  robin-hood-hashing = pkgs.callPackage ./pkgs/robin-hood-hashing { };

  pratt-parser = pkgs.callPackage ./pkgs/pratt-parser {
    fast_float = fast_float;
    robin-hood-hashing = robin-hood-hashing;
  };

  scnlib = pkgs.callPackage ./pkgs/scnlib { };

  span-lite = pkgs.callPackage ./pkgs/span-lite { };

  taskflow = pkgs.callPackage ./pkgs/taskflow { };

  vectorclass = pkgs.callPackage ./pkgs/vectorclass {
    vectorclass-cmake = ./pkgs/vectorclass/vectorclass-cmake;
  };

  vstat = pkgs.callPackage ./pkgs/vstat { vectorclass = vectorclass; };

  xxhash = pkgs.callPackage ./pkgs/xxhash { };

  operon = pkgs.callPackage ./pkgs/operon {
    aria-csv = aria-csv;
    fast_float = fast_float;
    pratt-parser = pratt-parser;
    robin-hood-hashing = robin-hood-hashing;
    scnlib = scnlib;
    span-lite = span-lite;
    taskflow = taskflow;
    vectorclass = vectorclass;
    vstat = vstat;
    xxhash = xxhash;
  };

  pyoperon = pkgs.callPackage ./pkgs/pyoperon {
    operon = operon;
    pybind11 = pkgs.python3Packages.pybind11;
    aria-csv = aria-csv;
    fast_float = fast_float;
    pratt-parser = pratt-parser;
    robin-hood-hashing = robin-hood-hashing;
    span-lite = span-lite;
    taskflow = taskflow;
    vectorclass = vectorclass;
    vstat = vstat;
    xxhash = xxhash;
  };

  quickcpplib = pkgs.callPackage ./pkgs/quickcpplib { };
}
