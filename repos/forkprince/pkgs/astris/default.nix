{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "astris";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Nintendo Switch emulator for Apple silicon Macs";
      homepage = "https://codeberg.org/V380-Ori/Astris.Binaries";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
