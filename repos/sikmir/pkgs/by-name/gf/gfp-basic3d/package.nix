{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  geoflow,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfp-basic3d";
  version = "0.4.18";

  src = fetchFromGitHub {
    owner = "geoflow3d";
    repo = "gfp-basic3d";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hSf5c5fnJQJHNPxLtZZZJa2JsOuje1dH6Q9YtJz82h4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    geoflow
    nlohmann_json
  ];

  installPhase = ''
    install -Dm644 gfp_core_io.so -t $out/lib/geoflow-plugins
  '';

  meta = {
    description = "Various 3D format writers for geoflow (CityJSON, PLY, OBJ)";
    homepage = "https://github.com/geoflow3d/gfp-basic3d";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
