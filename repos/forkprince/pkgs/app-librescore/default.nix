{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "app-librescore";
  src = fetchurl (lib.helper.getPlatform platform ver);

  inherit (ver) version;

  meta = {
    description = "App to download sheet music";
    homepage = "https://github.com/LibreScore/app-librescore";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "app-librescore";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else let
    contents = appimageTools.extractType2 {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "app-librescore";
      desktopName = "LibreScore";
      comment = meta.description;
      exec = "app-librescore %U";
      icon = "app-librescore";
      terminal = false;
      categories = ["AudioVideo" "Music"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/app-librescore.desktop
        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi
        icon=$(find ${contents} -maxdepth 2 -name "*.png" | head -n1)
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/app-librescore.png || true
        fi
      '';
    }
