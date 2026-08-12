{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "puremac";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Free, open-source macOS cleaner. CleanMyMac alternative with zero telemetry.";
      homepage = "https://www.moamenbasel.com/PureMac/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
