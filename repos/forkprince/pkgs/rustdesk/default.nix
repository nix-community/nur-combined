{
  stdenvNoCC,
  fetchurl,
  rustdesk,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "rustdesk";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Virtual / remote desktop infrastructure for everyone! Open source TeamViewer / Citrix alternative";
      homepage = "https://rustdesk.com";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.agpl3Only;
    };
  })
else rustdesk
