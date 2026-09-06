{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "oak-editor";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "A free non-linear video editor for Linux, macOS, and Windows";
    homepage = "https://github.com/OakVideoEditorCommunity/oak";
    changelog = "https://github.com/OakVideoEditorCommunity/oak/releases/tag/v${version}";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "oak-editor";
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
      name = "oak-editor";
      desktopName = "Oak Video Editor";
      comment = meta.description;
      exec = "oak-editor %U";
      icon = "oak-editor";
      terminal = false;
      categories = ["AudioVideo" "VideoEditing" "AudioVideoEditing"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/oak-editor.desktop

        if [ -d ${contents}/usr/share/icons ]; then
          cp -r ${contents}/usr/share/icons $out/share/ || true
        fi

        icon=$(find ${contents} -maxdepth 3 -name "*.png" -path "*/oak*" | head -n1)
        if [ -z "$icon" ]; then
          icon=$(find ${contents} -maxdepth 3 -name "*.png" | head -n1)
        fi
        if [ -n "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/oak-editor.png || true
        fi
      '';
    }
