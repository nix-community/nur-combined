{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gps-sdr-sim";
  version = "2023-09-02";

  src = fetchFromGitHub {
    owner = "osqzss";
    repo = "gps-sdr-sim";
    rev = "e7b948ff496917ade58ab7f59d448b7ee6e55f43";
    hash = "sha256-jPku4QjCDGZvuhkYSI4I6HMlnjLHa245rjzAQ1DkLb4=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installPhase = ''
    install -Dm755 gps-sdr-sim -t $out/bin
  '';

  meta = with lib; {
    description = "Software-Defined GPS Signal Simulator";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
