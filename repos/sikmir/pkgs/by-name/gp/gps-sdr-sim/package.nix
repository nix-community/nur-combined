{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gps-sdr-sim";
  version = "0-unstable-2024-12-23";

  src = fetchFromGitHub {
    owner = "osqzss";
    repo = "gps-sdr-sim";
    rev = "116ab74d16b192cbc6697a73bd45940a100bd0a6";
    hash = "sha256-miHbEUvIf7pGrONdf49BVpgaroaOEdOPgg5A/b4ZF/U=";
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
