# nixpkgs carries Scroll Reverser too, but its bot stopped at 1.9 while
# upstream moved on to 2.x, so this follows the GitHub release zip (one
# universal build for both Darwin systems) instead of adapting nixpkgs'.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "scroll-reverser";
  inherit (pin) version src;

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    unzip -d "$out/Applications" "$src"
    # Info-ZIP unpacks the archive's AppleDouble sidecars (._Foo) as plain
    # files inside the bundle. They are not in the Developer ID seal, so
    # Gatekeeper rejects the app as "damaged" until they are deleted.
    find "$out/Applications/Scroll Reverser.app" -name '._*' -delete
    runHook postInstall
  '';

  meta = {
    description = "Tool to reverse the direction of scrolling (official signed release)";
    homepage = "https://pilotmoon.com/scrollreverser/";
    changelog = "https://github.com/pilotmoon/Scroll-Reverser/releases/tag/v${pin.version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
