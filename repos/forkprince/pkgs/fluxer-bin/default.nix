# Modified from https://github.com/NixOS/nixpkgs/pull/490554
{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "fluxer-bin";
  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;

  meta = {
    description = "Fluxer desktop client";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "fluxer-bin";
    maintainers = ["WoutFontaine" "Prinky"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];

      sourceRoot = ".";

      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
        cp -R "$app" $out/Applications/
        runHook postInstall
      '';
    }
  else let
    appimageContents = appimageTools.extractType2 {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "fluxer";
      desktopName = "Fluxer";
      comment = "Fluxer desktop client";
      exec = "fluxer-bin %U";
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
