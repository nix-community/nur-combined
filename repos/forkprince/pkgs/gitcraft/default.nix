{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "gitcraft";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Desktop Git client for exploring repository history and managing everyday changes";
    homepage = "https://github.com/MystifiedSky/GitCraft";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = pname;
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

      desktopName = "GitCraft";
      categories = ["Development"];
      startupWMClass = pname;
      extraDesktopItem = {
        mimeTypes = ["x-scheme-handler/gitcraft"];
      };
    }
