{
  lib,
  stdenv,
  fetchFromGitHub,
  makeDesktopItem,

  libevdev,
  qt6,

  cmake,
  pkg-config,
  copyDesktopItems,
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
    copyDesktopItems
  ];

  buildInputs = [
    libevdev
    qt6.qtbase
  ];

  cmakeFlags = [
    (lib.cmakeBool "PORTABLE_BUILD" false)
  ];

  qtWrapperArgs = [
    "--unset QT_QPA_PLATFORMTHEME"
  ];

  postInstall = ''
    install -Dm644 $src/res/logos/SquareIcon.png $out/share/icons/hicolor/256x256/apps/VGamepadPC.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "VGamepadPC";
      type = "Application";
      desktopName = "Virtual Gamepad PC";
      exec = "VGamepadPC";
      terminal = false;
      icon = "VGamepadPC";
      comment = "Control your PC with a virtual gamepad from your mobile device";
      categories = [
        "Utility"
        "Game"
      ];
    })
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
