{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "achico";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Minimal free macOS local file compressor app";
      homepage = "https://github.com/nuance-dev/achico/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
