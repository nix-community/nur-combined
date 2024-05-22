{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deegree";
  version = "3.5.7";

  src = fetchurl {
    url = "https://repo.deegree.org/content/repositories/public/org/deegree/deegree-webservices/${finalAttrs.version}/deegree-webservices-${finalAttrs.version}.war";
    hash = "sha256-BX7eB42HhiA2iX1Si5MSrMKbWuBzq08YS0MGt5apWWM=";
  };

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/deegree.war"
  '';

  meta = with lib; {
    description = "Open source software for spatial data infrastructures and the geospatial web";
    homepage = "https://www.deegree.org/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ sikmir ];
    skip.ci = true;
  };
})
