# NOTE: Linux version is not tested
{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "app-librescore";
  src = fetchurl (lib.helper.getPlatform platform ver);

  inherit (ver) version;

  meta = {
    description = "App to download sheet music";
    homepage = "https://github.com/LibreScore/app-librescore";
    maintainers = ["Prinky"];
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

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
    }
  else
    appimageTools.wrapType2 {
      inherit pname version src meta;
    }
