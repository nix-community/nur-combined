{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geowebcache";
  version = "1.21.0";

  src = fetchurl {
    url = "mirror://sourceforge/geowebcache/geowebcache/${finalAttrs.version}/geowebcache-${finalAttrs.version}-war.zip";
    hash = "sha256-hiXXlBC6fNLR/+N18qPN5kzwsnbWMIE9kkEn2Y8qIVo=";
  };

  nativeBuildInputs = [ unzip ];

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/geowebcache.war"
  '';

  meta = {
    description = "Tile caching server implemented in Java";
    homepage = "https://www.geowebcache.org";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
