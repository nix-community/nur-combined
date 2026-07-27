{ }:
let
  # finiteflow depends on cmake 3, so we need an old nixpkgs
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f4b140d5b253f5e2a1ff4e5506edbf8267724bde.tar.gz";
  }) { };
in
pkgs.stdenv.mkDerivation {
  name = "finiteflow";
  version = "1.0.0";
  src = fetchGit {
    url = "https://github.com/peraro/finiteflow.git";
    rev = "278344c169010b74e791af8c5604c8cb9cd8df11";
  };
  buildInputs = [
    pkgs.gmp
    pkgs.flint
  ];
  nativeBuildInputs = [ pkgs.cmake ];
  patches = [
    ./finiteflow.patch
  ];
}
