{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "compositor";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "The Photoshop alternative for Mac";
      homepage = "https://github.com/robbietilton/Compositor";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
