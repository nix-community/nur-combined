{
  stdenvNoCC,
  openrct2,
  fetchurl,
  unzip,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "openrct2";

    src = fetchurl (lib.helper.getSingle ver);
    inherit (ver) version;

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
      description = "Open source re-implementation of RollerCoaster Tycoon 2 (original game required)";
      homepage = "https://openrct2.io/";
      downloadPage = "https://github.com/OpenRCT2/OpenRCT2/releases";
      maintainers = ["Prinky"];
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else openrct2
