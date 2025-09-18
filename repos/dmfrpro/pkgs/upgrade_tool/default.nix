{ stdenv, lib, fetchzip, pkgs, ... }:

stdenv.mkDerivation rec {
  name = "upgrade_tool";
  version = "2.1";

  src = fetchzip {
    url = "https://dl.radxa.com/tools/linux/Linux_Upgrade_Tool_V${version}.zip";
    sha256 = "sha256-fd0r3CNmHFX3Q1Y2og8lmsbc/KZT7vmsMXP52XaeUA4=";
  };
  
  installPhase = ''
    mkdir -p $out/bin
    install -D -m0755 $src/upgrade_tool $out/bin/upgrade_tool
  '';

  meta = {
    license = lib.licenses.unfree;
    homepage = "https://docs.radxa.com/en/compute-module/cm3j/low-level-dev/upgrade-tool";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    description = "Rockchip Firmware Upgrade Utility";
    platforms = [ "x86_64-linux" ];
    mainProgram = "upgrade_tool";
  };
}
