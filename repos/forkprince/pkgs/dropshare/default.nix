{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "dropshare";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "File sharing solution";
      homepage = "https://dropshare.app/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.unfree;
    };
  })
