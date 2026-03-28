{
  lib,
  stdenv,
  fetchFromGitHub,

  libevdev,
  qt6,

  cmake,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "virtualgamepad-pc";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "kitswas";
    repo = "VirtualGamePad-PC";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cax+VqdQODTojou5DC6FJOYjXWB9dElxkEYWdfZt7Bk=";
    fetchSubmodules = true;
  };

  patches = [
    ./rpath.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libevdev
    qt6.qtbase
  ];

  cmakeFlags = [
    "-DPORTABLE_BUILD=OFF"
  ];

  qtWrapperArgs = [
    "--unset QT_QPA_PLATFORMTHEME"
  ];

  meta = {
    changelog = "https://github.com/kitswas/VirtualGamePad-PC/releases/tag/v${finalAttrs.version}";
    description = "Linux server for Virtual Gamepad";
    homepage = "https://github.com/kitswas/VirtualGamePad-PC";
    license = lib.licenses.gpl3Only;
    mainProgram = "VGamepadPC";
    platforms = lib.platforms.linux;
  };
})
