{ lib, buildPythonPackage, fetchFromGitHub, fetchPypi, python, git, cmake, clang-tools, cppcheck, lcov, codespell }:
buildPythonPackage rec {
  pname = "cmake-init";
  version = "0.28.1";
  format = "wheel";

  src = fetchPypi {
    inherit version format;
    pname = "cmake_init";
    dist = "py3";
    python = "py3";
    sha256 = "sha256-du4/JPs6jSf0GiH0H9WtEhNieLZ2U+4VNE+ZNuVx6ns=";
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
