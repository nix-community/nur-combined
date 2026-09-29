{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "openemu-silicon";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Native ARM64 port of OpenEmu for Apple silicon MacBooks";
      homepage = "https://github.com/OpenEmu-Silicon/OpenEmu-Silicon";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.bsd3;
    };
  })
