{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  fetchzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "streamnook";
  inherit (ver) version;

  # NOTE: In the future we can simplify this, once the linux version officially drops on github.
  platform = stdenvNoCC.hostPlatform.system;
  src =
    (
      if lib.helper.unpackPlatform platform ver
      then fetchzip
      else fetchurl
    )
    (lib.helper.getPlatform platform ver);

  meta = {
    description = "A native desktop client for Twitch, Kick and YouTube multi-streaming";
    homepage = "https://streamnook.app";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "streamnook";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;
    })
  else let
    contents = appimageTools.extract {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "streamnook";
      desktopName = "StreamNook";
      comment = meta.description;
      exec = "streamnook %U";
      icon = "StreamNook";
      terminal = false;
      categories = ["Video" "AudioVideo"];
      mimeTypes = ["x-scheme-handler/streamnook"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/streamnook.desktop
        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/
        fi
        if [ ! -e $out/share/icons/hicolor/512x512/apps/StreamNook.png ]; then
          icon=$(find ${contents} -maxdepth 2 -name "*.png" | head -n1)
          if [ -n "$icon" ]; then
            install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/StreamNook.png
          fi
        fi
      '';
    }
