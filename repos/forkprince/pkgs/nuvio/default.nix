{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "nuvio";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Watch your library, anywhere";
      homepage = "https://nuvio.tv/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
