{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "opendisk";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Fast macOS disk-usage analyzer.";
      homepage = "https://github.com/137137137/OpenDisk";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
