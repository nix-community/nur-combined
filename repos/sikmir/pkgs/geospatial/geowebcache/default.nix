{ lib, stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "geowebcache";
  version = "1.21.0";

  src = fetchurl {
    url = "mirror://sourceforge/geowebcache/geowebcache/${version}/geowebcache-${version}-war.zip";
    hash = "sha256-hiXXlBC6fNLR/+N18qPN5kzwsnbWMIE9kkEn2Y8qIVo=";
  };

  nativeBuildInputs = [ unzip ];

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/geowebcache.war"
  '';

  meta = with lib; {
    description = "Tile caching server implemented in Java";
    homepage = "https://www.geowebcache.org";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.lgpl3Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ sikmir ];
    skip.ci = true;
  };
}
