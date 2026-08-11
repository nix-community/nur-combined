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
    mv Hazel.app $out/Applications
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Hazel.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = {
    homepage = "https://www.noodlesoft.com";
    changelog = "https://www.noodlesoft.com/release_notes";
    description = "Automated Organization for Your Mac.";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
})
