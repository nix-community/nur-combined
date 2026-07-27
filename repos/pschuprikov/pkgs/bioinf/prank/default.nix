{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "170427";

  name = "prank-${version}";

  src = fetchurl {
    url = "http://wasabiapp.org/download/prank/prank.source.${version}.tgz";
    sha256 = "sha256:0nc8g9c5rkdxcir46s0in9ci1sxwzbjibxrvkksf22ybnplvagk2";
  };

  sourceRoot = "prank-msa/src";

  installPhase = ''
    mkdir -p $out/bin/
    cp prank $out/bin/
  '';

  meta = {
    platforms = lib.platforms.linux;
  };
}
