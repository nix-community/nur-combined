{
  stdenvNoCC,
  fetchurl,
  rpcs3,
  _7zz,
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
    pname = "rpcs3";

    inherit version src;

    nativeBuildInputs = [_7zz];

    sourceRoot = ".";

    unpackPhase = ''
      7zz x $src
    '';

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
      description = "PS3 emulator/debugger";
      homepage = "https://rpcs3.net/";
      maintainers = ["Prinky"];
      license = lib.licenses.gpl2Only;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else rpcs3
