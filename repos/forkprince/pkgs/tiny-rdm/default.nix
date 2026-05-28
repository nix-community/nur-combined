{
  stdenvNoCC,
  tiny-rdm,
  fetchurl,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "tiny-rdm";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Modern, colorful, super lightweight Redis GUI client";
      homepage = "https://github.com/tiny-craft/tiny-rdm";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
else tiny-rdm
