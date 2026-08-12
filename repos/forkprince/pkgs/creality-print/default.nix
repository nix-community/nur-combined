{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "creality-print";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Slicer and cloud services for some Creality FDM 3D printers";
      homepage = "https://github.com/CrealityOfficial/CrealityPrint";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
