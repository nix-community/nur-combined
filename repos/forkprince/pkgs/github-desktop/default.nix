{
  github-desktop,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "github-desktop";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "GUI for managing Git and GitHub";
      homepage = "https://desktop.github.com/";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
else github-desktop
