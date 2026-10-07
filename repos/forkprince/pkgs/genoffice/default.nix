{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "genoffice";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Free, open-source AI Office suite: Docs, Sheets, Slides, PDF, Markdown and HTML editors with a built-in AI agent";
    homepage = "https://genoffice.ai/";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = pname;
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else let
    contents = appimageTools.extract {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = pname;
      desktopName = "GenOffice";
      comment = meta.description;
      exec = "${pname} %U";
      icon = pname;
      terminal = false;
      categories = ["Office"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/genoffice.desktop
        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi
        icon=$(find ${contents} -maxdepth 2 -name "*.png" | head -n1)
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/genoffice.png || true
        fi
      '';
    }
