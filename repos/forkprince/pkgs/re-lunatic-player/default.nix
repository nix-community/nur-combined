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
  libgbm,
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
  info = builtins.fromJSON (builtins.readFile ./info.json);
in
  stdenvNoCC.mkDerivation rec {
    pname = "re-lunatic-player";
    inherit (info) version;

    src = fetchzip {
      url = "https://github.com/Prince527GitHub/Re-Lunatic-Player/releases/download/v${version}/re-lunatic-player-linux-x64-${version}.tar.gz";
      inherit (info) hash;
      stripRoot = false;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
    ];

    buildInputs =
      [
        alsa-lib
        at-spi2-atk
        cairo
        cups
        dbus
        electron
        glib
        gtk3
        libgbm
        libxkbcommon
        nss
      ]
      ++ (with xorg; [
        libX11
        libXcomposite
        libXdamage
        libXext
        libXfixes
        libXrandr
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
