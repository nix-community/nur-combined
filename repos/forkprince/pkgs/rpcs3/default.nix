{
  stdenvNoCC,
  fetchurl,
  rpcs3,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "rpcs3";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    unpackPhase = ''
      7zz x $src
    '';

    meta = {
      description = "PS3 emulator/debugger";
      homepage = "https://rpcs3.net/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl2Only;
    };
  })
else rpcs3
