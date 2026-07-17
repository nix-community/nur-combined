{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "armsx2";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Playstation 2 Emulator for ARM64 Platforms";
    homepage = "https://armsx2.net";
    maintainers = with lib.maintainers; [Prinky];
    license = with lib.licenses; [gpl3Plus lgpl3Plus];
    platforms = lib.platforms.darwin ++ ["aarch64-linux"];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;
    })
  else
    appimageTools.wrapType2 {
      inherit pname version src meta;
    }
