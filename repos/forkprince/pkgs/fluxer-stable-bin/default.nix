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
    mainProgram = "fluxer-stable-bin";
    maintainers = with lib.maintainers; [WoutFontaine Prinky];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else let
    appimageContents = appimageTools.extractType2 {inherit pname version src;};

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

        install -Dm444 \
          ${appimageContents}/usr/share/icons/hicolor/256x256/apps/fluxer.png \
          $out/share/icons/hicolor/256x256/apps/fluxer.png
      '';
    }
