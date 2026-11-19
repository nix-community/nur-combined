{
  stdenvNoCC,
  fetchurl,
  unzip,
  icu,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "quiver-launcher";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Cross-platform game launcher and library manager";
    homepage = "https://github.com/tgeorgiadis/quiver-launcher";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = pname;
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Quiver Launcher";
      desktopId = "QuiverLauncher";
      icon = "QuiverLauncher";
      startupWMClass = "QuiverLauncher";
      categories = ["Game" "Utility"];

      extraPkgs = [icu];
    }
