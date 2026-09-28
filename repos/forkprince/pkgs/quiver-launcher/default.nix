{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "quiver-launcher";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Cross-platform game launcher and library manager";
    homepage = "https://github.com/tgeorgiadis/quiver-launcher";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = pname;
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
      name = pname;
      desktopName = "Quiver Launcher";
      comment = meta.description;
      exec = "${pname} %U";
      icon = pname;
      terminal = false;
      categories = ["Game" "Utility"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraPkgs = pkgs: with pkgs; [icu];

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/${pname}.desktop

        icon=$(find ${contents} -maxdepth 4 -name '*.png' | head -n1)
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/${pname}.png
        fi
      '';
    }
