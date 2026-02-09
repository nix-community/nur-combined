{
  pixelflasher,
  stdenvNoCC,
  fetchurl,
  _7zz,
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
    pname = "pixelflasher";

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
      description = "Pixel™ phone flashing GUI utility with features";
      homepage = "https://github.com/badabing2005/PixelFlasher";
      changelog = "https://github.com/badabing2005/PixelFlasher/releases/tag/v${version}";
      license = lib.licenses.agpl3Plus;
      maintainers = ["Prinky"];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else pixelflasher
