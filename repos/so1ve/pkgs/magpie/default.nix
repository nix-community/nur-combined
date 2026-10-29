{
  autoPatchelfHook,
  callPackage,
  copyDesktopItems,
  fetchurl,
  lib,
  makeDesktopItem,
  stdenv,
  wrapGAppsHook3,
  gdk-pixbuf,
  glib,
  gtk3,
  libX11,
  libsoup_3,
  source ? callPackage ./source.nix { },
  wayland,
  webkitgtk_4_1,
}:

let
  pname = "magpie";

  # The Linux build links against WebKitGTK 4.1 and ships no icon of its own.
  icon = fetchurl {
    url = "https://usemagpie.ai/img/icon-256.png";
    hash = "sha256-V0N8ZZbgWo/PxC1CiMAwqgDthraf411GTWnXAmFQxwQ=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname;
  inherit (source) version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk3
    libX11
    libsoup_3
    wayland
    webkitgtk_4_1
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/magpie
    install -Dm644 ${icon} $out/share/icons/hicolor/256x256/apps/magpie.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "magpie";
      exec = "magpie %u";
      icon = "magpie";
      desktopName = "magpie";
      comment = "One local gateway for the model every coding agent uses";
      startupWMClass = "magpie";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "x-scheme-handler/magpie" ];
    })
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/magpie
    test -f $out/share/applications/magpie.desktop
    test -f $out/share/icons/hicolor/256x256/apps/magpie.png

    runHook postInstallCheck
  '';

  meta = {
    description = "One local gateway for the model every coding agent uses";
    homepage = "https://usemagpie.ai";
    changelog = "https://github.com/yetone/magpie-releases/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = pname;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
