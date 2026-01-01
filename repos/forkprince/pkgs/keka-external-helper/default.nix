{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "keka-external-helper";

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
      description = "Helper application for the Keka file archiver";
      homepage = "https://github.com/aonez/Keka/wiki/Default-application";
      maintainers = ["Prinky"];
      license = lib.licenses.unfree;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
