{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "passepartout";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "OpenVPN and WireGuard client";
      homepage = "https://passepartoutvpn.app/";
      license = lib.licenses.gpl3;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
