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
    pname = "redream-dev";

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
      description = "Dreamcast emulator";
      homepage = "https://redream.io";
      maintainers = ["Prinky"];
      license = lib.licenses.unfree;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
