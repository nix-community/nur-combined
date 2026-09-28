{
  makeDesktopItem,
  appimageTools,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "kryoto-desktop";
  src = fetchurl (lib.helper.getSingle ver);
  inherit (ver) version;

  contents = appimageTools.extractType2 {inherit pname version src;};

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Kryoto Desktop";
    comment = "Desktop client";
    exec = pname;
    icon = pname;
    startupWMClass = pname;
    terminal = false;
    categories = ["Game"];
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    meta = {
      description = "Find a game, download it and play it";
      homepage = "https://github.com/kyrotooooo/kryoto-desktop";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };

    extraInstallCommands = ''
      install -Dm444 ${desktopItem}/share/applications/*.desktop \
        $out/share/applications/${pname}.desktop

      if [ -d ${contents}/usr/share/icons ]; then
        cp -r ${contents}/usr/share/icons $out/share/
      fi
    '';
  }
