{
  lib,
  clangStdenv,
  fetchFromGitHub,
  cmake,
  icu,
  boost,
  qt6,
  pkg-config,
  tinyxml,
  lld,
  nix-update-script,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "sourectrail";
  version = "2026.6";
  src = fetchFromGitHub {
    owner = "petermost";
    repo = "Sourcetrail";
    tag = finalAttrs.version;
    hash = "sha256-K4Vd5aV5pj/+Y3iWJNBXeI3WYjqAg2yn0o9IxBHFA0E=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
  ];

  strictDeps = true;
  __structuredAttrs = true;

  buildInputs = [
    icu
    boost
    qt6.qtbase
    qt6.qtsvg
    tinyxml
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
    lld
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Free and open-source interactive source explorer";
    homepage = "http://sourcetrail.de/";
    license = lib.licenses.gpl3Plus;
  };
})
