{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "MacSai";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Open-source Mac cleaner, optimizer, and malware scanner";
      homepage = "https://github.com/iliyami/MacSai";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.bsd3;
    };
  })
