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
    mv Handbrake.app $out/Applications
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Handbrake.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = {
    homepage = "https://handbrake.fr";
    changelog = "https://github.com/HandBrake/HandBrake/releases";
    description = "HandBrake is an open-source video transcoder available for Linux, Mac, and Windows.";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
})
