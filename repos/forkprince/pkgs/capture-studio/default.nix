{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "capture-studio";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Screen recorder and video editor";
    homepage = "https://tenzen.studio/capture/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "capture-studio";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [undmg];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Capture Studio";
      desktopId = "com.tenzen.desktop";
      categories = ["Video" "AudioVideoEditing"];
    }
