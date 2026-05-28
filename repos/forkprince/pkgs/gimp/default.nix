{
  gimp-with-plugins,
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "gimp";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [undmg];

    meta = {
      description = "GNU Image Manipulation Program";
      homepage = "https://www.gimp.org/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Plus;
    };
  })
else gimp-with-plugins
