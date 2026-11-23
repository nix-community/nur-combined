{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "openchamber";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Agentic development environment based on the OpenCode AI agent";
    homepage = "https://github.com/openchamber/openchamber";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.mit;
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

      desktopName = "OpenChamber";
      desktopComment = "Electron desktop runtime for OpenChamber";
      desktopId = pname;
      icon = pname;
      startupWMClass = pname;
      categories = ["Development"];
    }
