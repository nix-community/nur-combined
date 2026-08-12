{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "redream-dev";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];
    meta = {
      description = "Dreamcast emulator";
      homepage = "https://redream.io";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.unfree;
    };
  })
