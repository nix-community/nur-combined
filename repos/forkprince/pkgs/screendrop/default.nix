{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "screendrop";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "A beautiful screenshot, screen recording and loom alternative";
      homepage = "https://github.com/fayazara/screendrop";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.cc0;
    };
  })
