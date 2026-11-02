{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "photon-studio";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Free Photoshop alternative for photo editing";
    homepage = "https://tenzen.studio/photon/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "photon-studio";
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

      desktopName = "Photon Studio";
      desktopId = "com.tenzen.photon";
      categories = ["Graphics" "Photography"];
    }
