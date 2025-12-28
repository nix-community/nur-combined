{
  github-desktop,
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
    pname = "tiny-rdm";

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
      description = "Modern, colorful, super lightweight Redis GUI client";
      homepage = "https://github.com/tiny-craft/tiny-rdm";
      license = lib.licenses.gpl3Plus;
      maintainers = ["Prinky"];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else github-desktop
