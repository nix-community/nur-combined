{
  stdenvNoCC,
  overlayed,
  fetchurl,
  unzip,
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
    pname = "overlayed";

    inherit version src;

    nativeBuildInputs = [unzip];

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
      description = "Modern discord voice chat overlay";
      homepage = "https://github.com/overlayeddev/overlayed";
      changelog = "https://github.com/overlayeddev/overlayed/releases/tag/v${version}";
      maintainers = ["Prinky"];
      license = lib.licenses.agpl3Plus;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else overlayed
