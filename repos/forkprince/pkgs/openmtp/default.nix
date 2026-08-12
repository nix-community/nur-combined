{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "openmtp";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Advanced Android File Transfer Application";
      homepage = "https://openmtp.ganeshrvel.com/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
