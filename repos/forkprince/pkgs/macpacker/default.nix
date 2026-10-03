{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "macpacker";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Archive creator and extractor for macOS";
      homepage = "https://github.com/sarensw/MacPacker";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
