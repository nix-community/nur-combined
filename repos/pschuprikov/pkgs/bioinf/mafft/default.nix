{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "7.453";

  name = "mafft-${version}";
  src = fetchurl {
    url = "https://mafft.cbrc.jp/alignment/software/${name}-without-extensions-src.tgz";
    sha256 = "sha256:1ydi53k8n9n6mkvp2y8a86gsbmn8qbxp74xazhws3jbks72dy1ac";
  };

  sourceRoot = "${name}-without-extensions/core";
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    platforms = lib.platforms.linux;
  };
}
