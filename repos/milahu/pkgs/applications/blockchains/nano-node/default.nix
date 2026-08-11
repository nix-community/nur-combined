# based on nixpkgs: pkgs/applications/blockchains/nano-wallet/default.nix

# FIXME dont install bin/api/flatbuffers/nanoapi.fbs
# this belongs somewhere else, not in bin/

{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, wrapQtAppsHook
, boost
, libGL
, qtbase
, python3
, rocksdb
, cpptoml-cryptocode
, magic-enum
, fmt
, spdlog
, miniupnpc
, gtest
, flatbuffers
, cryptopp
, lmdb
, libargon2
}:

stdenv.mkDerivation rec {

  #NIX_CFLAGS_COMPILE = "-Og -ggdb"; hardeningDisable = [ "all" ]; dontStrip = true;  # debug

  pname = "nano-node";
  version = "26.1";

  src =
  if true then
  # use shared libraries, dont fetch gitmodules
  # https://github.com/nanocurrency/nano-node/pull/4679
  fetchFromGitHub {
    owner = "milahu";
    repo = "nano-node";
    rev = "d8d564bfdb79195caaf9e420a3c14f952fd6783a";
    hash = "sha256-rGieXfsk0NN2QWaC8X3iI+1FJDFS1v3Q47VhTXNpYAs=";
  }
  else
  fetchFromGitHub {
    owner = "nanocurrency";
    repo = "nano-node";
    rev = "V${version}";
    fetchSubmodules = true;
    hash = "sha256-LzY4GWvbVpH/GxlHYBF5XlMmnWyg9MmkfEALf2FD7qU=";
  };

/*
  patches = [
    # Fix gcc-13 build failure due to missing <cstdint> includes.
    (fetchpatch {
      name = "gcc-13.patch";
      url = "https://github.com/facebook/rocksdb/commit/88edfbfb5e1cac228f7cc31fbec24bb637fe54b1.patch";
      stripLen = 1;
      extraPrefix = "submodules/rocksdb/";
      hash = "sha256-HhlIYyPzIZFuyzHTUPz3bXgXiaFSQ8pVrLLMzegjTgE=";
    })
  ];
*/

  cmakeFlags =
    let
      options = {
        PYTHON_EXECUTABLE = "${python3.interpreter}";
        #NANO_SHARED_BOOST = "ON";
        BOOST_ROOT = boost;
        RAIBLOCKS_GUI = "ON";
        RAIBLOCKS_TEST = "ON";
        Qt5_DIR = "${qtbase.dev}/lib/cmake/Qt5";
        Qt5Core_DIR = "${qtbase.dev}/lib/cmake/Qt5Core";
        Qt5Gui_INCLUDE_DIRS = "${qtbase.dev}/include/QtGui";
        Qt5Widgets_INCLUDE_DIRS = "${qtbase.dev}/include/QtWidgets";
      };
      optionToFlag = name: value: "-D${name}=${value}";
    in
    lib.mapAttrsToList optionToFlag options;

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
    flatbuffers
  ];

  buildInputs = [
    boost
    libGL
    qtbase
    rocksdb
    cpptoml-cryptocode
    magic-enum
    fmt
    spdlog
    miniupnpc
    gtest
    flatbuffers
    cryptopp
    lmdb
    libargon2
  ];

  strictDeps = true;

#  makeFlags = [ "nano_wallet" ];

  checkPhase = ''
    runHook preCheck
    ./core_test
    runHook postCheck
  '';

  meta = {
    description = "Nano cryptocurrency";
    homepage = "https://github.com/nanocurrency/nano-node";
    license = lib.licenses.bsd2;
    # Fails on Darwin. See:
    # https://github.com/NixOS/nixpkgs/pull/39295#issuecomment-386800962
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ];
  };

}
