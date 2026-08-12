{
  stdenvNoCC,
  fetchurl,
  steam,
  undmg,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "steam";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [undmg];

    meta = {
      description = "Digital distribution platform";
      longDescription = ''Steam is a video game digital distribution service and storefront from Valve.'';
      homepage = "https://store.steampowered.com/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.unfreeRedistributable;
    };
  })
else steam
