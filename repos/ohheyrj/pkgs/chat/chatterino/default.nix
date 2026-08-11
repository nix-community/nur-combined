{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib,
  stdenv,
  versionCheckHook,
  writeShellScript,
  xcbuild,
  generated
}:


stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (generated) pname version src;
  
  buildInputs = [ undmg ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Chatterino.app $out/Applications
    '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Chatterino.app/Contents/Info.plist"
  ];


    meta = {
      homepage = "https://chatterino.com";
      changelog = "https://github.com/Chatterino/chatterino2/blob/master/CHANGELOG.md";
      description = "Chat client for Twitch";
      license = lib.licenses.mit;
      platforms = lib.platforms.darwin;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
})
