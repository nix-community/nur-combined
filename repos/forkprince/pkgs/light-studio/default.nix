{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "light-studio";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Lightroom alternative for photo library and RAW development";
    homepage = "https://tenzen.studio/light/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "light-studio";
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

      desktopName = "Light Studio";
      desktopId = "studio.light";
      categories = ["Graphics" "Photography"];
    }
