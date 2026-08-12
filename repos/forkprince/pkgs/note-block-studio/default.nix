{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  pname = "note-block-studio";
  version = "2025-01-09";

  meta = {
    description = "An open-source Minecraft music maker.";
    homepage = "https://github.com/OpenNBS/NoteBlockStudio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "note-block-studio";
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version meta;

      src = fetchurl rec {
        url = "https://github.com/ForkPrince/tap/raw/c60a096fb2552904ec5eada157bcc8427eba13d9/Apps/Note%20Block%20Studio.dmg";
        name = lib.helper.extractName url;
        hash = "sha256-afEggp95TCan/AkqKYf+6RGeei0iw4oRWJJpJLvHngE=";
      };

      nativeBuildInputs = [_7zz];
    })
  else let
    inherit pname version meta;

    src = fetchurl rec {
      url = "https://github.com/ForkPrince/homebrew-tap/raw/refs/heads/main/Apps/Minecraft%20Note%20Block%20Studio%20(Snapshot%202025.08.02).appimage";
      name = lib.helper.extractName url;
      hash = "sha256-7cIv7CD0u95I3AvVV1N0OaTg18AzWRJm5sXm8n3cLrU=";
    };

    appimageContents = appimageTools.extractType2 {inherit pname version src;};

    desktopItem = makeDesktopItem {
      name = "note-block-studio";
      desktopName = "Note Block Studio";
      comment = meta.description;
      exec = "note-block-studio %U";
      icon = "note-block-studio";
      terminal = false;
      categories = ["Game"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/note-block-studio.desktop

        install -Dm444 \
          ${appimageContents}/usr/share/icons/hicolor/64x64/apps/Minecraft_Note_Block_Studio.png \
          $out/share/icons/hicolor/64x64/apps/note-block-studio.png
      '';
    }
