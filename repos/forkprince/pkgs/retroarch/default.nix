# NOTE: This is untested
{
  retroarch-full,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "roblox";

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
      description = "Multi-platform emulator frontend for libretro cores";
      homepage = "https://libretro.com";
      maintainers = ["Prinky"];
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else retroarch-full
