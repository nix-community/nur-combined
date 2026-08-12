{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "playcover";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];
    meta = {
      description = "Sideload iOS apps and games";
      homepage = "https://playcover.io/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Plus;
    };
  })
