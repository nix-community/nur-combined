# Upstream ships one universal, notarized DMG; the bundle is copied verbatim
# so its seal stays intact. Sparkle updates the app in place once copyApps
# has put a writable copy outside the store.
{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "heyclicky";
  inherit (pin) version src;

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R HeyClicky.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Screen-aware AI assistant that talks you through a task or does it for you";
    homepage = "https://www.heyclicky.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
