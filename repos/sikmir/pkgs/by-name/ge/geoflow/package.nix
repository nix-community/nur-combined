{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  glfw3,
  gtk2,
  nlohmann_json,
  proj,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geoflow";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "geoflow3d";
    repo = "geoflow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tfMRyBhFgfdR8U9iu5o8QFBEToHi244AUA4IGhFmm+I=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace apps/CMakeLists.txt --replace-fail "/Applications" "$out/Applications"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glfw3
    gtk2
    nlohmann_json
    proj
    sqlite
  ];

  cmakeFlags = [
    (lib.cmakeFeature "GF_PLUGIN_FOLDER" "${placeholder "out"}/lib/geoflow-plugins")
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-error=missing-template-arg-list-after-template-kw"
    ]
  );

  meta = {
    description = "flowchart tool for geo-spatial data processing";
    homepage = "https://github.com/geoflow3d/geoflow";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "geof";
  };
})
