# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }: rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  aria-csv = pkgs.callPackage ./pkgs/aria-csv { };

  asmjit = pkgs.callPackage ./pkgs/asmjit { };

  autodiff = pkgs.callPackage ./pkgs/autodiff { };

  berserk = pkgs.callPackage ./pkgs/berserk {
    stdenv = pkgs.llvmPackages_latest.stdenv;
  };

  boost-hana = pkgs.callPackage ./pkgs/boost-hana { };

  boost_unordered = pkgs.callPackage ./pkgs/boost_unordered { };

  byte-lite = pkgs.callPackage ./pkgs/byte-lite { };

  beman-optional = pkgs.callPackage ./pkgs/beman-optional { stdenv = pkgs.gcc14Stdenv; };

  cmake-init = pkgs.python3Packages.callPackage ./pkgs/cmake-init { };

  cmake-utils = pkgs.callPackage ./pkgs/cmake-utils { };

  cmaketools = pkgs.python3Packages.callPackage ./pkgs/cmaketools { };

  copacabana = pkgs.callPackage ./pkgs/copacabana { };

  cpp-flux = pkgs.callPackage ./pkgs/cpp-flux { };

  cpp-lazy = pkgs.callPackage ./pkgs/cpp-lazy { };

  cpp-sort = pkgs.callPackage ./pkgs/cpp-sort { };

  cppitertools = pkgs.callPackage ./pkgs/cppitertools { };

  dynamic-bitset = pkgs.callPackage ./pkgs/dynamic-bitset { };

  eve = pkgs.callPackage ./pkgs/eve { };

  expected-lite = pkgs.callPackage ./pkgs/expected-lite { };

  fastor = pkgs.callPackage ./pkgs/fastor { };

  fplus = pkgs.callPackage ./pkgs/fplus { };

  gch-small-vector = pkgs.callPackage ./pkgs/gch-small-vector { };

  gtl = pkgs.callPackage ./pkgs/gtl { };

  koivisto = pkgs.callPackage ./pkgs/koivisto { };

  ktl = pkgs.callPackage ./pkgs/ktl { cmake-utils = cmake-utils; };

  kumi = pkgs.callPackage ./pkgs/kumi { inherit copacabana; };

  lexy = pkgs.callPackage ./pkgs/lexy { };

  libdwarf = pkgs.callPackage ./pkgs/libdwarf { };

  cpptrace = pkgs.callPackage ./pkgs/cpptrace { libdwarf = libdwarf; };

  libassert = pkgs.callPackage ./pkgs/libassert { libdwarf = libdwarf; cpptrace = cpptrace; enableTesting = false; };

  linasm = pkgs.callPackage ./pkgs/linasm { };

  libnano = pkgs.callPackage ./pkgs/libnano { };

  plutovg = pkgs.callPackage ./pkgs/plutovg { };

  lunasvg = pkgs.callPackage ./pkgs/lunasvg { plutovg = plutovg; };

  mathpresso = pkgs.callPackage ./pkgs/mathpresso { };

  mdspan = pkgs.callPackage ./pkgs/mdspan { };

  mppp = pkgs.callPackage ./pkgs/mppp { };

  nanobench = pkgs.callPackage ./pkgs/nanobench { };

  parallel-hashmap = pkgs.callPackage ./pkgs/parallel-hashmap { };

  pareto = pkgs.python3Packages.callPackage ./pkgs/pareto { };

  practrand-rng-test = pkgs.callPackage ./pkgs/practrand-rng-test { };

  pegtl = pkgs.callPackage ./pkgs/pegtl { };

  perf-cpp = pkgs.callPackage ./pkgs/perf-cpp { };

  pmlb = pkgs.python3Packages.callPackage ./pkgs/pmlb { };

  pmt = pkgs.callPackage ./pkgs/pmt { };

  q5go = pkgs.libsForQt5.callPackage ./pkgs/q5go { };

  fast-float-6_1_6 = pkgs.fast-float.overrideAttrs(old: rec {
    version = "6.1.6";
    src = pkgs.fetchFromGitHub {
      owner = "fastfloat";
      repo = "fast_float";
      rev = "v${version}";
      hash = "sha256-MEJMPQZZZhOFiKlPAKIi0zVzaJBvjAlbSyg3wLOQ1fg=";
    };
  });

  scnlib = pkgs.callPackage ./pkgs/scnlib { fast-float = fast-float-6_1_6; };

  seq = pkgs.callPackage ./pkgs/seq { };

  singleton = pkgs.callPackage ./pkgs/singleton { };

  tlfloat = pkgs.callPackage ./pkgs/tlfloat { };

  sleef = pkgs.callPackage ./pkgs/sleef { tlfloat = tlfloat; };

  span-lite = pkgs.callPackage ./pkgs/span-lite { };

  taskflow = pkgs.callPackage ./pkgs/taskflow { };

  tessil-robin-map = pkgs.callPackage ./pkgs/tessil-robin-map { };

  testu01 = pkgs.callPackage ./pkgs/testu01 { };

  trng = pkgs.callPackage ./pkgs/trng { };

  tlx = pkgs.callPackage ./pkgs/tlx { };

  vdt = pkgs.callPackage ./pkgs/vdt { };

  vectorclass = pkgs.callPackage ./pkgs/vectorclass {
    vectorclass-cmake = ./pkgs/vectorclass/vectorclass-cmake;
  };

  xad = pkgs.callPackage ./pkgs/xad { };

  xxhash_cpp = pkgs.callPackage ./pkgs/xxhash_cpp { };

  qobuz-linux = pkgs.callPackage ./pkgs/qobuz-linux { };

  qpdfview-qt5 = pkgs.libsForQt5.callPackage ./pkgs/qpdfview { };
  qpdfview-qt6 = pkgs.qt6Packages.callPackage ./pkgs/qpdfview { };

  ned14-status-code = pkgs.callPackage ./pkgs/ned14-status-code { };
  ned14-quickcpplib = pkgs.callPackage ./pkgs/ned14-quickcpplib {
    byte-lite = byte-lite;
    span-lite = span-lite;
  };
  ned14-outcome = pkgs.callPackage ./pkgs/ned14-outcome {
    quickcpplib = ned14-quickcpplib;
    status-code = ned14-status-code;
    byte-lite = byte-lite;
    span-lite = span-lite;
  };

  unordered_dense = pkgs.callPackage ./pkgs/unordered_dense { };
}
