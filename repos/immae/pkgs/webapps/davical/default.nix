{ davical_config ? "/etc/davical/config.php", stdenv, fetchurl, gettext }:
stdenv.mkDerivation rec {
  version = "1.1.9.2";
  name = "davical-${version}";
  src = fetchurl {
    url = "https://www.davical.org/downloads/davical_${version}.orig.tar.xz";
    sha256 = "133p7fl544df2rqw1nbnj5nj6bvb9kng9q0c3iqrqlpawq3a6ilh";
  };
  unpackCmd = ''
    tar --one-top-level -xf $curSrc
  '';
  makeFlags = "all";
  installPhase = ''
    mkdir -p $out
    cp -ra config dba docs htdocs inc locale po scripts testing zonedb $out
    ln -s ${davical_config} $out/config/config.php
  '';
  buildInputs = [ gettext ];
}
