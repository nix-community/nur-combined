{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "cspell-dict-elisp";
  version = "1.0.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@cspell/dict-elisp/-/dict-elisp-${version}.tgz";
    hash = "sha256-Xjj4omEFCvri5idYrJFK3hNJW7X+UqMZr6jrS3SbKNY=";
  };

  installPhase = ''
    mkdir -p $out/share
    cd $out/share
    tar -xvf $src
    mv package cspell-dict-elisp
  '';
}

