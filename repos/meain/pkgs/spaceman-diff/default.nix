{ pkgs, lib, imagemagick, jp2a, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "spaceman-diff";
  name = pname;
  version = "b81423c93e9fcd9251e54767e45e95731ea975c1";

  src = fetchFromGitHub {
    owner = "holman";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-7T6bwy6PjTeNbONH24o4sgV8aIFPQxU/OnzNxXDGYZo=";
  };

  propagatedInputs = [ imagemagick jp2a ];

  installPhase = ''
    mkdir -p $out/bin
    cp spaceman-diff $out/bin/spaceman-diff
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "diff images from the command line";
    homepage = "https://github.com/holman/${pname}";
    license = licenses.mit;
  };
}
