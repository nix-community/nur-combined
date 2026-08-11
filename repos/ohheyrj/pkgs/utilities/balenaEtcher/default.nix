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
    mv balenaEtcher.app $out/Applications
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/balenaEtcher.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = {
    homepage = "https://github.com/balena-io/etcher";
    changelog = "https://github.com/balena-io/etcher/blob/master/CHANGELOG.md";
    description = "Flash OS images to SD cards & USB drives, safely and easily.";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
})
