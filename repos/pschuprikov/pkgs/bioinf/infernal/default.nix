{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "1.1.3";
  name = "infernal-${version}";

  src = fetchurl {
    url = "http://eddylab.org/infernal/${name}.tar.gz";
    sha256 = "sha256:0pm8bm3s6nfa0av4x6m6h27lsg12b3lz3jm0fyh1mc77l2isd61v";
  };

  meta = {
    platforms = lib.platforms.unix;
  };
}
