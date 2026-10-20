{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "effectcraft";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Motion graphics and visual effects compositor";
    homepage = "https://getartcraft.com/apps/effectcraft";
    maintainers = with lib.maintainers; [Prinky];
    license = with lib.licenses; [asl20 mit];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "effectcraft";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "EffectCraft";
      categories = ["Graphics"];
      desktopId = "ai.storyteller.${pname}";
      startupWMClass = "ai.storyteller.${pname}";
      icon = "ai.storyteller.${pname}";
    }
