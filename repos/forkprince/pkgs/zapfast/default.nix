{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "zapfast";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Fast, native WhatsApp client";
    homepage = "https://zapfast.rocks/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "zapfast";
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

      desktopName = "ZapFast";
      startupWMClass = "zapfast";
      categories = ["Network" "InstantMessaging" "Chat"];
    }
