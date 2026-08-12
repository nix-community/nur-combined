{
  orca-slicer,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "orca-slicer";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.)";
      homepage = "https://github.com/SoftFever/OrcaSlicer";
      changelog = "https://github.com/SoftFever/OrcaSlicer/releases/tag/v${ver.version}";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
else orca-slicer
