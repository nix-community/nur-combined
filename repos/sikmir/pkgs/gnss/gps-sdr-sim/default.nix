{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gps-sdr-sim";
  version = "2022-01-14";

  src = fetchFromGitHub {
    owner = "osqzss";
    repo = "gps-sdr-sim";
    rev = "becf3a33e9d1ffa445e5341137bdf31006072650";
    hash = "sha256-Z+fGsqQUzTCKgbbH8B4qttHFnEfgUulxuttINHJT6IA=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installPhase = ''
    install -Dm755 gps-sdr-sim -t $out/bin
  '';

  meta = with lib; {
    description = "Software-Defined GPS Signal Simulator";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
