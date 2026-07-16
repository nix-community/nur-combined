{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "bluebubbles-server";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Server for forwarding iMessages to clients within the BlueBubbles App ecosystem";
      homepage = "https://github.com/BlueBubblesApp/bluebubbles-server";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.asl20;
    };
  })
