{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deegree";
  version = "3.6.9";

  __structuredAttrs = true;

  src = fetchurl {
    url = "https://repo.deegree.org/content/repositories/public/org/deegree/deegree-webservices/${finalAttrs.version}/deegree-webservices-${finalAttrs.version}.war";
    hash = "sha256-iSPk3i3WQdbuR0y7OM3mqcdKbNW6iFAg/ufjmk5Brcc=";
  };

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/deegree.war"
  '';

  meta = {
    description = "Open source software for spatial data infrastructures and the geospatial web";
    homepage = "https://www.deegree.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
