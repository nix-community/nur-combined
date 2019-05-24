{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "0.59";
  name = "awl-${version}";
  src = fetchurl {
    url = "https://www.davical.org/downloads/awl_${version}.orig.tar.xz";
    sha256 = "01b7km7ga3ggbpp8axkc55nizgk5c35fl2z93iydb3hwbxmsvnjp";
  };
  unpackCmd = ''
    tar --one-top-level -xf $curSrc
  '';
  installPhase = ''
    mkdir -p $out
    cp -ra dba docs inc scripts tests $out
  '';
}
