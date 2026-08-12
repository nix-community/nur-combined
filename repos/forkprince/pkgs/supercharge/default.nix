{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "supercharge";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Elevate your Mac experience";
      homepage = "https://sindresorhus.com/supercharge";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.unfree;
    };
  })
