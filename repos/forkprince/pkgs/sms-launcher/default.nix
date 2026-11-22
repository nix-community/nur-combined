{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "sms-launcher";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Setup, build, update, and play launcher for the Super Mario Sunshine PC port";
    homepage = "https://github.com/chasem-dev/sms-launcher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = pname;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
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

      desktopName = "SMS Launcher";
      desktopId = "sms-launcher";
      icon = "sms-launcher";
      startupWMClass = "sms-launcher";
      categories = ["Game"];
      extraDesktopItem = {
        mimeTypes = ["x-scheme-handler/discord-1557924964869480578"];
      };
    }
