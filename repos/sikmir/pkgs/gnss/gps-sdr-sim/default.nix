{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gps-sdr-sim";
  version = "0-unstable-2024-04-11";

  src = fetchFromGitHub {
    owner = "osqzss";
    repo = "gps-sdr-sim";
    rev = "dc65ee836a6bb8a0ba2b28ead26d1085d415e0c9";
    hash = "sha256-EA+UG591hayT85GiGvloQiJM+ptGqdOTJJpVwQYCpKs=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installPhase = ''
    install -Dm755 gps-sdr-sim -t $out/bin
  '';

  meta = {
    description = "Software-Defined GPS Signal Simulator";
    homepage = "https://github.com/osqzss/gps-sdr-sim";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
