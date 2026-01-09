# NOTE: Linux version may not have a desktop file
# NOTE: MacOS version untested
{
  appimageTools,
  fetchurl,
  stdenv,
  _7zz,
  lib,
}: let
  pname = "note-block-studio";
  version = "2025-01-09";

  meta = {
    description = "An open-source Minecraft music maker.";
    homepage = "https://github.com/OpenNBS/NoteBlockStudio";
    license = lib.licenses.mit;
    maintainers = ["Prinky"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
  };
in
  if stdenv.isDarwin
  then let
    url = "https://github.com/ForkPrince/tap/raw/c60a096fb2552904ec5eada157bcc8427eba13d9/Apps/Note%20Block%20Studio.dmg";
    name = lib.helper.extractName url;
  in
    stdenv.mkDerivation {
      inherit pname version meta;

      src = fetchurl {
        inherit url name;
        hash = "sha256-afEggp95TCan/AkqKYf+6RGeei0iw4oRWJJpJLvHngE=";
      };

      nativeBuildInputs = [_7zz];

      sourceRoot = ".";

      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
        cp -R "$app" $out/Applications/
        runHook postInstall
      '';
    }
  else let
    url = "https://github.com/ForkPrince/homebrew-tap/raw/refs/heads/main/Apps/Minecraft%20Note%20Block%20Studio%20(Snapshot%202025.08.02).appimage";
    name = lib.helper.extractName url;
  in
    appimageTools.extractType2 {
      inherit pname version meta;

      src = fetchurl {
        inherit url name;
        hash = "sha256-7cIv7CD0u95I3AvVV1N0OaTg18AzWRJm5sXm8n3cLrU=";
      };
    }
