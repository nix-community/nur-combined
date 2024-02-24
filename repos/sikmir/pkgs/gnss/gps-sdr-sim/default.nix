{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gps-sdr-sim";
  version = "0-unstable-2024-01-05";

  src = fetchFromGitHub {
    owner = "osqzss";
    repo = "gps-sdr-sim";
    rev = "4fdf282763867aeede0c8308bfa65d01e56c5ec2";
    hash = "sha256-Txc5iwj9gzNyzIMFS4h+wdQTif7dJ67IsCl3IfF2wGE=";
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
