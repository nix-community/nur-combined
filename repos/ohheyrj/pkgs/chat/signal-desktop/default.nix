{
  stdenvNoCC,
  fetchurl,
  lib,
  _7zz,
  stdenv,
  versionCheckHook,
  writeShellScript,
  xcbuild,
  generated
}:


stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (generated) pname version src;
  
  buildInputs = [ _7zz ];
  dontUnpack = true;
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    7zz x $src -o$TMPDIR -y &> /dev/null
    cd $TMPDIR
    mkdir -p $out/Applications
    mv Signal.app $out/Applications
    '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Signal.app/Contents/Info.plist"
  ];


    meta = {
      homepage = "https://signal.org";
      changelog = "https://github.com/signalapp/Signal-Desktop/releases";
      description = "Signal Desktop links with Signal on Android or iOS and lets you message from your Windows, macOS, and Linux computers.";
      license = lib.licenses.agpl3Only;
      platforms = lib.platforms.darwin;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
})
