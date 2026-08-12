{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "pearcleaner";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "A free, source-available and fair-code licensed mac app cleaner";
      homepage = "https://itsalin.com/appInfo/?id=pearcleaner";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.commons-clause;
    };
  })
