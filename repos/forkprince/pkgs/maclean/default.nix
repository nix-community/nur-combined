{
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "maclean";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    meta = {
      description = "Safe and open-source mac cleaner";
      homepage = "https://github.com/Hasan72341/maclean";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
