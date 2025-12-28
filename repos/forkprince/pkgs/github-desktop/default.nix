{
  github-desktop,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "github-desktop";

    inherit version src;

    nativeBuildInputs = [unzip];

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r "GitHub Desktop.app" $out/Applications/
      runHook postInstall
    '';

    meta = {
      description = "GUI for managing Git and GitHub";
      homepage = "https://desktop.github.com/";
      license = lib.licenses.mit;
      maintainers = ["Prinky"];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else github-desktop
