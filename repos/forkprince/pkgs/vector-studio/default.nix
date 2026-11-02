{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "vector-studio";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Illustrator alternative for vector illustration and design";
    homepage = "https://tenzen.studio/vector/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "vector-studio";
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

      desktopName = "Vector Studio";
      desktopId = "org.tenzen.vector-studio";
      categories = ["Graphics" "2DGraphics"];
    }
