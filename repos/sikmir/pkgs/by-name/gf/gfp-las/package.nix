{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  geoflow,
  LAStools,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfp-las";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "geoflow3d";
    repo = "gfp-las";
    tag = "v${finalAttrs.version}";
    hash = "sha256-05seXLQm2TAFLRSN2Fiar5j6bYZP9AYWjdM0xXKKHuw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    geoflow
    LAStools
    nlohmann_json
  ];

  installPhase = ''
    install -Dm644 gfp_las.so -t $out/lib/geoflow-plugins
  '';

  meta = {
    description = "LAS reader and writer for geoflow";
    homepage = "https://github.com/geoflow3d/gfp-las";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
