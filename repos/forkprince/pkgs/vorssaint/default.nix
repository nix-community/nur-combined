{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "vorssaint";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Free and open-source macOS menu bar toolkit.";
      homepage = "https://vorssaint.com";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
