# NOTE: This has not been testing on MacOS yet.
{
  stdenvNoCC,
  fetchurl,
  steam,
  _7zz,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "steam";

    src = fetchurl (lib.helper.getSingle ver);
    inherit (ver) version;

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
      description = "Digital distribution platform";
      longDescription = ''Steam is a video game digital distribution service and storefront from Valve.'';
      homepage = "https://store.steampowered.com/";
      maintainers = ["Prinky"];
      license = lib.licenses.unfreeRedistributable;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else steam
