{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "betteraudio";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "One menu bar app. Every audio control macOS forgot to ship.";
      homepage = "https://betteraudio.pro/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.unfree;
    };
  })
