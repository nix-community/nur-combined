{ lib
, fetchFromGitHub
, buildPythonPackage
, cmake
, pybind11
, abseil-cpp
, wrapt
, attrs
, numpy
, absl-py
}:

buildPythonPackage rec {
  pname = "dm-tree";
  version = "0.1.6";
  nativeBuildInputs = [ cmake ];
  buildInputs = [ pybind11 abseil-cpp ];
  dontUseCmakeConfigure = true;
  dontUseCmakeBuildDir = true;
  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "tree";
    rev = "b452e5c2743e7489b4ba7f16ecd51c516d7cd8e3";
    sha256 = "sha256-SYJv4ARZLrekXa3QC2P84PdFx2bPauUpStLafXk/KOQ=";
  };
  checkInputs = [ wrapt numpy absl-py attrs ];
  patches = [ ./0001-fix-cmake-use-find_package.patch ];
}

