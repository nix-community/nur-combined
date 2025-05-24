{ stdenvNoCC, fetchurl, _7zz, cpio, xar, xcbuild, versionCheckHook, writeShellScript, lib, undmg, config, generated }:

stdenvNoCC.mkDerivation {
  inherit (generated) pname version src;

  buildInputs = [
    _7zz
    cpio
    xar
    undmg
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    7zz x "Install BaseCamp.pkg" -o$TMPDIR
    cd $TMPDIR
    cat garminBaseCamp.pkg/Payload | gunzip -dc | cpio -i
    cat garminMapInstall.pkg/Payload | gunzip -dc | cpio -i
    cat garminMapManager.pkg/Payload | gunzip -dc | cpio -i
    mkdir -p $out/Applications
    mv *.app $out/Applications
    runHook postInstall
    '';
  
  meta = {
    homepage = "https://www.garmin.com/en-GB/software/basecamp/";
    changelog = "https://www8.garmin.com/support/download_details.jsp?id=4449";
    description = "Garmin BaseCamp is a free desktop app for planning outdoor adventures and managing GPS data with Garmin devices.";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
}
