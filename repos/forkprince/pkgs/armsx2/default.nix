{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "armsx2";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Playstation 2 Emulator for ARM64 Platforms";
    homepage = "https://armsx2.net";
    maintainers = with lib.maintainers; [Prinky];
    license = with lib.licenses; [gpl3Plus lgpl3Plus];
    platforms = lib.platforms.darwin ++ ["aarch64-linux"];
    mainProgram = "armsx2";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      extraInstall = ''
        mv $out/Applications/armsx2-macos-arm64-sha*.app $out/Applications/ARMSX2.app
      '';
    })
  else let
    contents = appimageTools.extractType2 {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "armsx2";
      desktopName = "ARMSX2";
      comment = meta.description;
      exec = "armsx2 %U";
      icon = "armsx2";
      terminal = false;
      categories = ["Game" "Emulator"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/armsx2.desktop
        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi
        icon=$(find ${contents} -maxdepth 2 -name "*.png" | head -n1)
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/armsx2.png || true
        fi
      '';
    }
