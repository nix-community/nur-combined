{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "diffusionbee";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Run Stable Diffusion locally";
      homepage = "https://diffusionbee.com/";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
