{ lib, buildPythonPackage, fetchFromGitHub, fetchPypi, python, git, cmake, clang-tools, cppcheck, lcov, codespell }:
buildPythonPackage rec {
  pname = "cmake-init";
  version = "0.31.3";
  format = "wheel";

  src = fetchPypi {
    inherit version format;
    pname = "cmake_init";
    dist = "py3";
    python = "py3";
    sha256 = "sha256-YH22+zd0UV/nndesbP453i5J164kcYV9IIcV/2dJYt0=";
  };

  nativeBuildInputs = [ python git cmake ];

  doCheck = false;
  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "Modern CMake (3.14+) project initializer that generates FetchContent-ready projects, separates consumer and developer targets, provides install rules with proper relocatable CMake packages.";
    homepage = "https://github.com/friendlyanon/cmake-init";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
