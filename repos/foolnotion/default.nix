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

  aria-csv = pkgs.callPackage ./pkgs/aria-csv { };

  asmjit = pkgs.callPackage ./pkgs/asmjit { };

  autodiff = pkgs.callPackage ./pkgs/autodiff { };

  berserk = pkgs.callPackage ./pkgs/berserk { };

  boost-hana = pkgs.callPackage ./pkgs/boost-hana { };

  cmake-init = pkgs.python3Packages.callPackage ./pkgs/cmake-init { };

  cmaketools = pkgs.python3Packages.callPackage ./pkgs/cmaketools { };

  cpp-flux = pkgs.callPackage ./pkgs/cpp-flux { };

  cpp-lazy = pkgs.callPackage ./pkgs/cpp-lazy { };

  cpp-sort = pkgs.callPackage ./pkgs/cpp-sort { };

  cppitertools = pkgs.callPackage ./pkgs/cppitertools { };

  cutechess-qt6 = pkgs.qt6Packages.callPackage ./pkgs/cutechess {
    qt5compat = pkgs.qt6.qt5compat;
    qtwayland = pkgs.qt6.qtwayland;
  };

  eli5 = pkgs.python3Packages.callPackage ./pkgs/eli5 { };

  eovim = pkgs.callPackage ./pkgs/eovim { };

  eve = pkgs.callPackage ./pkgs/eve { };

  expected-lite = pkgs.callPackage ./pkgs/expected-lite { };

  fast_float = pkgs.callPackage ./pkgs/fast_float { };
  
  fastor = pkgs.callPackage ./pkgs/fastor { };

  gch-small-vector = pkgs.callPackage ./pkgs/gch-small-vector { };

  koivisto = pkgs.callPackage ./pkgs/koivisto { };

  lexy = pkgs.callPackage ./pkgs/lexy { };

  linasm = pkgs.callPackage ./pkgs/linasm { };

  libnano = pkgs.callPackage ./pkgs/libnano { };

  mathpresso = pkgs.callPackage ./pkgs/mathpresso { };

  mdspan = pkgs.callPackage ./pkgs/mdspan { };

  nanobind = pkgs.callPackage ./pkgs/nanobind { python = pkgs.python3; };

  nlr = pkgs.callPackage ./pkgs/nlr { };

  pareto = pkgs.python3Packages.callPackage ./pkgs/pareto { };

  pegtl = pkgs.callPackage ./pkgs/pegtl { };

  pmlb = pkgs.python3Packages.callPackage ./pkgs/pmlb { };

  pratt-parser = pkgs.callPackage ./pkgs/pratt-parser {
    fast_float = fast_float;
    robin-hood-hashing = robin-hood-hashing;
  };

  q5go = pkgs.libsForQt5.callPackage ./pkgs/q5go { };

  robin-hood-hashing = pkgs.callPackage ./pkgs/robin-hood-hashing { };

  scid = pkgs.callPackage ./pkgs/scid { };

  scnlib = pkgs.callPackage ./pkgs/scnlib { };

  seq = pkgs.callPackage ./pkgs/seq { };

  sleef = pkgs.callPackage ./pkgs/sleef { };

  span-lite = pkgs.callPackage ./pkgs/span-lite { };

  taskflow = pkgs.callPackage ./pkgs/taskflow { };

  tessil-robin-map = pkgs.callPackage ./pkgs/tessil-robin-map { };

  trng = pkgs.callPackage ./pkgs/trng { };

  vectorclass = pkgs.callPackage ./pkgs/vectorclass {
    vectorclass-cmake = ./pkgs/vectorclass/vectorclass-cmake;
  };

  vstat = pkgs.callPackage ./pkgs/vstat { vectorclass = vectorclass; };

  xad = pkgs.callPackage ./pkgs/xad { };

  xxhash_cpp = pkgs.callPackage ./pkgs/xxhash_cpp { };

  pyoperon = pkgs.python3Packages.callPackage ./pkgs/pyoperon { };

  qpdfview-qt5 = pkgs.libsForQt5.callPackage ./pkgs/qpdfview { };
  qpdfview-qt6 = pkgs.qt6Packages.callPackage ./pkgs/qpdfview { };

  ned14-status-code = pkgs.callPackage ./pkgs/ned14-status-code { };
  ned14-quickcpplib = pkgs.callPackage ./pkgs/ned14-quickcpplib { };
  ned14-outcome = pkgs.callPackage ./pkgs/ned14-outcome {
    quickcpplib = ned14-quickcpplib;
    status-code = ned14-status-code;
  };

  unordered_dense = pkgs.callPackage ./pkgs/unordered_dense { };
}
