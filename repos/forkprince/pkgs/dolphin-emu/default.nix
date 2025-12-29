{
  dolphin-emu,
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
    pname = "dolphin-emu";

    src = fetchurl (lib.helper.getApi ver);
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
      description = "Gamecube/Wii/Triforce emulator for x86_64 and ARMv8";
      homepage = "https://dolphin-emu.org";
      maintainers = ["Prinky"];
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else dolphin-emu
