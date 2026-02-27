{
  lib,
  stdenv,
  fetchFromGitHub,

  pkg-config,
  cmake,
  ninja,
  spirv-tools,
  qt6,
  breakpad,
  jemalloc,
  cli11,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libxcb,
  libdrm,
  libgbm,
  pipewire,
  pam,
  sysprof,
  polkit,
  glib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "noctalia-qs";
  version = "0.2.1";

  # https://github.com/noctalia-dev/noctalia-qs
  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-qs";
    rev = "cb52f093b6a340a4ae4da5c9ea0244f6f2ee58ca";
    hash = "sha256-zhuvZYO2AW1cYEMWBR8sGtk86cSHz4I8SwaFocp5y1E=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.qtshadertools
    spirv-tools
    wayland-scanner
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    qt6.qtsvg
    cli11
    wayland
    wayland-protocols
    libdrm
    libgbm
    breakpad
    jemalloc
    libxcb
    pam
    pipewire
    sysprof
    polkit
    glib
  ];

  cmakeFlags = [
    (lib.cmakeFeature "DISTRIBUTOR" "Nixpkgs")
    (lib.cmakeBool "DISTRIBUTOR_DEBUGINFO_AVAILABLE" true)
    (lib.cmakeFeature "INSTALL_QML_PREFIX" qt6.qtbase.qtQmlPrefix)
    (lib.cmakeFeature "GIT_REVISION" "tag-v${finalAttrs.version}")
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;
  dontStrip = false;


  passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://github.com/noctalia-dev/noctalia-qs";
    description = "Flexbile QtQuick based desktop shell toolkit";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "quickshell";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
