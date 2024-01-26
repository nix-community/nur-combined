{ pkgs, stdenv, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "unimatrix";
  version = "1.0.0";

  src = pkgs.fetchgit {
    url = "https://github.com/will8211/unimatrix";
    name = "unimatrix";
    hash = "sha256-QN2YunUN0nHD6aa4praWYy+o6lmPMFzR3rnVdEJw6fc=";
  };

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/bin
    cp $src/unimatrix.py $out/bin/unimatrix
    chmod +x $out/bin/unimatrix
  '';

  meta = with pkgs.lib; {
    description = "Python script to simulate the display from \"The Matrix\" in terminal. Uses half-width katakana unicode characters by default, but can use custom character sets. Accepts keyboard controls while running";
    homepage = https://github.com/will8211/unimatrix;
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
