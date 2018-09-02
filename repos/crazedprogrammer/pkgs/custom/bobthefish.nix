{ nixpkgs ? import <nixpkgs> {},
  stdenv ? nixpkgs.stdenv,
  fetchFromGitHub ? nixpkgs.fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "bobthefish";
  version = "2017-09-07";

  src = fetchFromGitHub {
    owner = "oh-my-fish";
    repo = "theme-bobthefish";
    rev = "f4378582d644e34562d65fc13f318498215bb106";
    sha256 = "1wgi1fk0mapyy8cwjvm6mzvkjd6asrg6195y4zv0ay0c17zalj3z";
  };

  installPhase = ''
    mkdir -p $out/lib
    cp -r . $out/lib/bobthefish
  '';
}
