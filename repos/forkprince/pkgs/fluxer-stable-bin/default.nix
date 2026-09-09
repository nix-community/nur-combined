# Modified from https://github.com/NixOS/nixpkgs/pull/490554
{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "fluxer-stable-bin";
  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;

  meta = {
    description = "Fluxer desktop client";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "fluxer-stable-bin";
    maintainers = with lib.maintainers; [WoutFontaine Prinky];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else let
    contents = appimageTools.extractType2 {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "fluxer";
      desktopName = "Fluxer";
      comment = "Fluxer desktop client";
      exec = "fluxer-stable-bin %U";
      icon = "fluxer";
      terminal = false;
      categories = ["InstantMessaging"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/fluxer.desktop

        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi

        icon=$(find ${contents} -maxdepth 3 -name "*.png" -path "*/fluxer*" | head -n1)
        if [ -z "$icon" ]; then
          icon=$(find ${contents} -maxdepth 3 -name "*.png" | head -n1)
        fi
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/fluxer.png || true
        fi
      '';
    }
