{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  unzip,
  curl,
  cacert,
  xmlstarlet,
  writeShellApplication,
  common-updater-scripts,
  sourceRoot,
  source,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "Bartender 6";
  inherit (source) version src;
  inherit sourceRoot;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  nativeBuildInputs = [
    _7zz
    unzip
  ];

  unpackPhase = ''
    unzip $src

  '';

  postInstall = ''

      	mkdir -p $out/Applications
    	mv "Bartender6-${finalAttrs.version}/Bartender 6.app" $out/Applications
  '';

  meta = {
    description = "Take control of your menu bar";
    longDescription = ''
      Bartender is an award-winning app for macOS that superpowers your menu bar, giving you total control over your menu bar items, what's displayed, and when, with menu bar items only showing when you need them.
      Bartender improves your workflow with quick reveal, search, custom hotkeys and triggers, and lots more.
    '';
    homepage = "https://www.macbartender.com";
    changelog = "https://macbartender.com/B2/updates/${
      builtins.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }/rnotes.html";
    license = [ lib.licenses.unfree ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.darwin;
  };
})
