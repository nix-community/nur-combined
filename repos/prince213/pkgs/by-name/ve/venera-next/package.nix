{
  lib,
  fetchFromGitHub,
  flutter341,
  replaceVars,
  rustPlatform,
  stdenvNoCC,

  # nativeBuildInputs
  copyDesktopItems,
  makeDesktopItem,

  # buildInputs
  glib-networking,
  webkitgtk_4_1,
}:

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "venera-next";
  version = "1.18.5";

  src = fetchFromGitHub {
    owner = "CyrilPeng";
    repo = "Venera-Next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3RK1oAunDnUGEHGZwYO5PoSryKqR7d8zoTrLg2KRzPU=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = {
    flutter_inappwebview = "sha256-Vh5bZP/tkSAlstbT3souy/iLmpw3CENrA/rCUOcJb2o=";
    flutter_inappwebview_android = "sha256-Vh5bZP/tkSAlstbT3souy/iLmpw3CENrA/rCUOcJb2o=";
    flutter_inappwebview_ios = "sha256-Vh5bZP/tkSAlstbT3souy/iLmpw3CENrA/rCUOcJb2o=";
    flutter_inappwebview_macos = "sha256-Vh5bZP/tkSAlstbT3souy/iLmpw3CENrA/rCUOcJb2o=";
    flutter_inappwebview_platform_interface = "sha256-Vh5bZP/tkSAlstbT3souy/iLmpw3CENrA/rCUOcJb2o=";
    flutter_inappwebview_web = "sha256-Vh5bZP/tkSAlstbT3souy/iLmpw3CENrA/rCUOcJb2o=";
    flutter_qjs = "sha256-pDorKeWLGsrWUCDtcfl0CBx/p+b0WM2pqkteCQxC2tU=";
  };

  customSourceBuilders = {
    rhttp = import ./rhttp.nix { inherit replaceVars rustPlatform stdenvNoCC; };
  };

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    glib-networking
    webkitgtk_4_1
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "venera-next";
      desktopName = "VeneraNext";
      comment = "Comic reader";
      icon = "venera-next";
      exec = "venera-next %U";
      mimeTypes = [ "x-scheme-handler/venera" ];
    })
  ];

  postInstall = ''
    install -Dm644 debian/gui/venera-next.png $out/share/icons/hicolor/256x256/apps/venera-next.png
    install -Dm644 assets/app_icon.png $out/share/icons/hicolor/512x512/apps/venera-next.png
  '';

  meta = {
    description = "Comic reader";
    homepage = "https://github.com/CyrilPeng/Venera-Next";
    downloadPage = "https://github.com/CyrilPeng/Venera-Next/releases";
    changelog = "https://github.com/CyrilPeng/Venera-Next/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "venera-next";
    platforms = lib.platforms.linux;
  };
})
