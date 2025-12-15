{
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  libxkbcommon,
  at-spi2-atk,
  makeWrapper,
  stdenvNoCC,
  electron,
  alsa-lib,
  fetchzip,
  mesa,
  cairo,
  xorg,
  cups,
  dbus,
  glib,
  gtk3,
  nss,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "re-lunatic-player";
    inherit (ver) version;

    src = fetchzip (lib.helper.getSingle ver
      // {
        stripRoot = false;
      });

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
    ];

    buildInputs =
      [
        libxkbcommon
        at-spi2-atk
        alsa-lib
        electron
        cairo
        cups
        dbus
        glib
        gtk3
        mesa
        nss
      ]
      ++ (with xorg; [
        libXcomposite
        libXdamage
        libXrandr
        libXfixes
        libXext
        libX11
      ]);

    desktopItems = makeDesktopItem {
      name = "re-lunatic-player";
      desktopName = "Re:Lunatic Player";
      exec = "re-lunatic-player";
      startupWMClass = "Re:Lunatic Player";
      genericName = "Radio Player";
      keywords = [
        "radio"
        "touhou"
        "lunatic"
        "player"
        "music"
      ];
      categories = [
        "Audio"
        "AudioVideo"
      ];
    };

    installPhase = ''
      mkdir $out
      cp -r . $out/opt

      makeWrapper ${electron}/bin/electron $out/bin/re-lunatic-player \
        --add-flags $out/opt/resources/app.asar

      runHook postInstall
    '';

    meta = {
      description = "A Gensokyo Radio player with easy song info, continuing the Lunatic Player project. ";
      homepage = "https://github.com/Prince527GitHub/Re-Lunatic-Player";
      license = lib.licenses.agpl3Only;
      maintainers = ["Wam25" "Prinky"];
      platforms = ["x86_64-linux"];
      mainProgram = "re-lunatic-player";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
