{ davical_config ? "/etc/davical/config.php", stdenv, fetchurl, gettext }:
stdenv.mkDerivation rec {
  version = "1.1.7";
  name = "davical-${version}";
  src = fetchurl {
    url = "https://www.davical.org/downloads/davical_${version}.orig.tar.xz";
    sha256 = "1ar5m2dxr92b204wkdi8z33ir9vz2jbh5k1p74icpv9ywifvjjp9";
  };
  unpackCmd = ''
    tar --one-top-level -xf $curSrc
  '';
  makeFlags = "all";
  patches = [ ./davical_19eb79ebf9250e5f339675319902458c40ed1755.patch ];
  installPhase = ''
    mkdir -p $out
    cp -ra config dba docs htdocs inc locale po scripts testing zonedb $out
    ln -s ${davical_config} $out/config/config.php
  '';
  buildInputs = [ gettext ];
}
