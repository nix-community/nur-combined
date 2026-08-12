{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "open-emu";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Retro video game emulation";
      homepage = "https://openemu.org/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
