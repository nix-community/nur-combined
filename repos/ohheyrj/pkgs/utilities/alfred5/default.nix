{
  stdenvNoCC,
  undmg,
  fetchurl,
  lib,
  stdenv,
  versionCheckHook,
  writeShellScript,
  xcbuild,
  config
}:

stdenvNoCC.mkDerivation (finalAttrs:
  let
    version = "5.6.2";
    build = "2296";
  in {
    pname = "alfred5";
    inherit version;

    src = fetchurl {
      url = "https://cachefly.alfredapp.com/Alfred_${version}_${build}.dmg";
      hash = "sha256-bEn7gB7v10T6oSJ2JhxUyuyzFyGNWw0FUyLTPlmAnNc=";
    };

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    buildInputs = [ undmg ];

    sourceRoot = ".";
    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      mv 'Alfred 5.app' $out/Applications
      '';
    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgram = writeShellScript "version-check" ''
      ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
    '';
    versionCheckProgramArg = [
      "${placeholder "out"}/Applications/Alfred 5.app/Contents/Info.plist"
    ];

    meta = {
      homepage = "https://www.alfredapp.com";
      description = "Productivity app for macOS that boosts efficiency with hotkeys, keywords, text expansion, and powerful workflows.";
      license = lib.licenses.unfree;
      platforms = lib.platforms.darwin;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      broken = !(config.allowUnfree or false);
    };
})
