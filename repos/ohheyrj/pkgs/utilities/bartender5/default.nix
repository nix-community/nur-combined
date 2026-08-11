{ 
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  versionCheckHook,
  xcbuild,
  writeShellScript,
  config,
  generated
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (generated) pname version src;
  buildInputs = [ _7zz ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    7zz x $src -o$TMPDIR -y
    cd $TMPDIR
    mkdir -p $out/Applications
    mv "Bartender 5.app" $out/Applications
  '';

  meta = {
    homepage = "https://www.macbartender.com";
    changelog = "https://www.macbartender.com/Bartender5/release_notes/";
    description = "Bartender is a macOS app that lets you manage and hide menu bar items, improving workflow with search, hotkeys, and automation.";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
})
