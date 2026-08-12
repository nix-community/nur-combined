{
  stdenvNoCC,
  fetchurl,
  tenacity,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "tenacity";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Sound editor with graphical UI";
      homepage = "https://tenacityaudio.org/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl2Plus;
    };
  })
else tenacity
