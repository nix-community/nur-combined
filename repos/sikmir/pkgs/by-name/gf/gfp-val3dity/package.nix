{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cgal,
  geoflow,
  geos,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfp-val3dity";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "geoflow3d";
    repo = "gfp-val3dity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LUldG3xslYb7fF1NlNG+oYzPZS9ttpgjxPAMsj46Tpk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    cgal
    geoflow
    geos
    nlohmann_json
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  installPhase = ''
    install -Dm644 gfp_val3dity.so -t $out/lib/geoflow-plugins
  '';

  meta = {
    description = "3D geometry validation for geoflow based on val3dity";
    homepage = "https://github.com/geoflow3d/gfp-val3dity";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
})
