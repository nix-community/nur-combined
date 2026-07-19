{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geowebcache";
  version = "2.0.0";

  __structuredAttrs = true;

  src = fetchurl {
    url = "mirror://sourceforge/geowebcache/geowebcache/${finalAttrs.version}/geowebcache-${finalAttrs.version}-war.zip";
    hash = "sha256-dLbdSp3N2cH7Yv90pJPfcwZQdt/hIctMoVZH+L1qJYM=";
  };

  nativeBuildInputs = [ unzip ];

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/geowebcache.war"
  '';

  meta = {
    description = "Tile caching server implemented in Java";
    homepage = "https://geowebcache.osgeo.org";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
