{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "orbolay";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Quick, small, native, multi-platform Discord overlay alternative";
    homepage = "https://github.com/SpikeHD/Orbolay";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "orbolay";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else let
    contents = appimageTools.extract {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "orbolay";
      desktopName = "Orbolay";
      comment = meta.description;
      exec = "orbolay %U";
      icon = "orbolay";
      terminal = false;
      categories = ["Network"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/orbolay.desktop
        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi
        icon=$(find ${contents} -maxdepth 2 -name "*.png" | head -n1)
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/orbolay.png || true
        fi
      '';
    }
