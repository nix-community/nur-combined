{ stdenvNoCC, fetchurl, _7zz, cpio, xar, xcbuild, versionCheckHook, writeShellScript, lib, config, generated }:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (generated) pname version src;

  buildInputs = [
    _7zz
    cpio
    xar
  ];
  sourceRoot = ".";
  unpackPhase = ''
    runHook preUnpack
    7zz x $src -o$TMPDIR
    cd $TMPDIR
    cat RemotePlay.pkg/Payload | gunzip -dc | cpio -i
    runHook postUnpack
    '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv RemotePlay.app $out/Applications
    runHook postInstall
    '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/RemotePlay.app/Contents/Info.plist"
  ];
  doInstallCheck = true;
  meta = with lib; {
    homepage = "https://remoteplay.dl.playstation.net/remoteplay/lang/gb/";
    description = "PS Remote Play is a free app that lets you stream and play your PS5 or PS4 games on compatible devices like smartphones, tablets, PCs, and Macs, allowing you to game remotely over Wi-Fi or mobile data.";
    license = licenses.unfree;
    platforms = platforms.darwin;
    broken = !(config.allowUnfree or false);
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
