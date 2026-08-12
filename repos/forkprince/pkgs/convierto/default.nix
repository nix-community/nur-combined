{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "convierto";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Native macOS file converter app";
      homepage = "https://github.com/nuance-dev/convierto/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
