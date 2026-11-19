{
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
  if stdenvNoCC.hostPlatform.isDarwin
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
  else
    lib.helper.mkAppImage {
      inherit pname version meta;

      src = fetchurl rec {
        url = "https://github.com/ForkPrince/homebrew-tap/raw/refs/heads/main/Apps/Minecraft%20Note%20Block%20Studio%20(Snapshot%202025.08.02).appimage";
        name = lib.helper.extractName url;
        hash = "sha256-7cIv7CD0u95I3AvVV1N0OaTg18AzWRJm5sXm8n3cLrU=";
      };

      desktopId = "Minecraft_Note_Block_Studio";
      desktopName = "Note Block Studio";
      icon = "Minecraft_Note_Block_Studio";
      categories = ["Game"];
    }
