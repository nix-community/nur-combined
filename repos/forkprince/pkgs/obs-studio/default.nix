{
  obs-studio,
  stdenvNoCC,
  fetchurl,
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
    pname = "obs-studio";

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
      description = "Free and open source software for video recording and live streaming";
      longDescription = ''
        This project is a rewrite of what was formerly known as "Open Broadcaster
        Software", software originally designed for recording and streaming live
        video content, efficiently
      '';
      homepage = "https://obsproject.com";
      maintainers = ["Prinky"];
      license = [lib.licenses.gpl2Plus];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else obs-studio
