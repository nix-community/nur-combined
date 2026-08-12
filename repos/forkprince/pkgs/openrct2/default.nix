{
  stdenvNoCC,
  openrct2,
  fetchurl,
  unzip,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "openrct2";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Open source re-implementation of RollerCoaster Tycoon 2 (original game required)";
      homepage = "https://openrct2.io/";
      downloadPage = "https://github.com/OpenRCT2/OpenRCT2/releases";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Only;
    };
  })
else openrct2
