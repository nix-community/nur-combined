{
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
    mainProgram = "armsx2";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      extraInstall = ''
        mv $out/Applications/armsx2-macos-arm64-sha*.app $out/Applications/ARMSX2.app
      '';
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "ARMSX2";
      desktopId = "net.armsx2.ARMSX2";
      categories = ["Game" "Emulator"];
      icon = "ARMSX2";
      startupWMClass = "ARMSX2";
    }
