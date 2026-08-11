{ 
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  versionCheckHook,
  xcbuild,
  writeShellScript,
  config,
  generated
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (generated) pname version src;
  buildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv Cryptomator.app $out/Applications
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Cryptomator.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = {
    homepage = "https://github.com/cryptomator/cryptomator";
    changelog = "https://github.com/cryptomator/cryptomator/releases";
    description = "Cryptomator offers multi-platform transparent client-side encryption of your files in the cloud.";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
})
