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
    rev = "8aa9d8ce86ef018fb442c585ad7fbb2a15a4f822";
    hash = "sha256-XNmLf4HqUM6/he/eJiHT+Mvxmt7QuwgGU14jB4Ha+pM=";
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
