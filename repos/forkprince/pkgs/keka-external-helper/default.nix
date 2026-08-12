{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "keka-external-helper";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Helper application for the Keka file archiver";
      homepage = "https://github.com/aonez/Keka/wiki/Default-application";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.unfree;
    };
  })
