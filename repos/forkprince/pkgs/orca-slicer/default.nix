{
  orca-slicer,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;

  src = fetchurl (lib.helper.getSingle ver);

  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "orca-slicer";

    inherit version src;

    nativeBuildInputs = [_7zz];

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
      cp -R "$app" $out/Applications/
      runHook postInstall
    '';

    meta = {
      description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.)";
      homepage = "https://github.com/SoftFever/OrcaSlicer";
      changelog = "https://github.com/SoftFever/OrcaSlicer/releases/tag/v${version}";
      license = lib.licenses.agpl3Only;
      maintainers = ["Prinky"];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else orca-slicer
