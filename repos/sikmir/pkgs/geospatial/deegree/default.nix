{ lib, stdenv, fetchurl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "deegree";
  version = "3.4.31";

  src = fetchurl {
    url = "https://repo.deegree.org/content/repositories/public/org/deegree/deegree-webservices/${finalAttrs.version}/deegree-webservices-${finalAttrs.version}.war";
    hash = "sha256-CUmn+bAyaUARlJuwVJ2AMRqj/fejVjHtYnbYCUAOeYQ=";
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
