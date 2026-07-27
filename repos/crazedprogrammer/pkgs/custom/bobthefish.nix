{ nixpkgs ? import <nixpkgs> {},
  stdenv ? nixpkgs.stdenv,
  fetchFromGitHub ? nixpkgs.fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "bobthefish";
  version = "2020-10-16";

  src = fetchFromGitHub {
    owner = "oh-my-fish";
    repo = "theme-bobthefish";
    rev = "dfec8fa044a937b7a84f54dc2d7cf39495770580";
    sha256 = "0v1qgf11xln0lzkh3yar7kd81vqwyy57l3c5x3qawddxjz8mnwpc";
  };

  installPhase = ''
    mkdir -p $out/lib
    cp -r . $out/lib/bobthefish
  '';
}
