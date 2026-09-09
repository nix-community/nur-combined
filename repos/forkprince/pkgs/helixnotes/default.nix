{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "helixnotes";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "A local, open-source Markdown note-taking app.";
    homepage = "https://helixnotes.com";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "helixnotes";
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
      name = "helixnotes";
      desktopName = "HelixNotes";
      comment = meta.description;
      exec = "helixnotes %U";
      icon = "helixnotes";
      terminal = false;
      categories = ["Utility" "Office"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/helixnotes.desktop
        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi
        icon=$(find ${contents} -maxdepth 2 -name "*.png" | head -n1)
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/helixnotes.png || true
        fi
      '';
    }
