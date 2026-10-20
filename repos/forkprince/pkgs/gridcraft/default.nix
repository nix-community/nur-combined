{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "gridcraft";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Spreadsheet editor";
    homepage = "https://getartcraft.com/apps/gridcraft";
    maintainers = with lib.maintainers; [Prinky];
    license = with lib.licenses; [asl20 mit];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "gridcraft";
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

      desktopName = "GridCraft";
      categories = ["Office" "Spreadsheet"];
      desktopId = "ai.storyteller.${pname}";
      startupWMClass = "ai.storyteller.${pname}";
      icon = "ai.storyteller.${pname}";
    }
