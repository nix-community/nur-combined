{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdal,
  geoflow,
  geos,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfp-gdal";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "geoflow3d";
    repo = "gfp-gdal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u4u4xJm2FaCg2TO/CRtt284VrQgGrQhlDy24pfhr0Uw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gdal
    geoflow
    geos
    nlohmann_json
  ];

  installPhase = ''
    install -Dm644 gfp_gdal.so -t $out/lib/geoflow-plugins
  '';

  meta = {
    description = "OGR reader and writer for geoflow";
    homepage = "https://github.com/geoflow3d/gfp-gdal";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
