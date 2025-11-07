{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cgal,
  eigen,
  geoflow,
  LAStools,
  nlohmann_json,
  pdal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfp-building-reconstruction";
  version = "0.4.8";

  src = fetchFromGitHub {
    owner = "geoflow3d";
    repo = "gfp-building-reconstruction";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ivr7b6Te5RoEuuyC5G9Rs08iQeDJFBhVoXSI3eFEU1w=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    cgal
    eigen
    geoflow
    LAStools
    nlohmann_json
    pdal
  ];

  cmakeFlags = [ (lib.cmakeBool "GFP_WITH_PDAL" true) ];

  installPhase = ''
    install -Dm644 gfp_buildingreconstruction.so -t $out/lib/geoflow-plugins
  '';

  meta = {
    description = "Geoflow plugin for building LoD2 reconstruction from a point cloud";
    homepage = "https://github.com/geoflow3d/gfp-building-reconstruction";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
})
