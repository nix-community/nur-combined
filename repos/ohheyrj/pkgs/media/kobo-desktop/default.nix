{
  stdenvNoCC,
  undmg,
  fetchurl,
  lib,
  stdenv,
  versionCheckHook,
  writeShellScript,
  xcbuild
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kobo-desktop";
  version = "0-unstable-2025-05-11";

  src = fetchurl {
    url = "https://cdn.kobo.com/downloads/desktop/kobodesktop/kobosetup.dmg";
    hash = "sha256-OHkhC1lPwgoPr3/629FLf8hSVZZhcuAHlREYx0CX7m8=";
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
    mv Kobo.app $out/Applications
    '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Kobo.app/Contents/Info.plist"
  ];

    meta = {
      homepage = "https://www.kobo.com/gb/en/p/desktop";
      description = "Kobo Desktop is a free app for Windows and Mac that lets you buy, read, and manage eBooks, as well as sync them with your Kobo eReader.";
      license = lib.licenses.unfree;
      platforms = lib.platforms.darwin;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
})
