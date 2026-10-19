# nixpkgs' obs-studio is Linux-only, so this repacks the official prebuilt
# macOS app from upstream's release DMGs. The bundle arrives notarized and
# with an intact seal (no AppleDouble sidecars, no re-signing needed), so it
# is copied verbatim. Version and hashes live in pin.json,
# bumped by release_pins.py.
#
# The bundled virtual camera (com.obsproject.obs-studio.mac-camera-extension)
# is a system extension, which macOS only accepts from an app inside
# /Applications, so install the bundle there rather than linking the store.
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
  pname = "obs-studio";
  inherit (pin) version src;

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    app=$(find . -maxdepth 1 -name "*.app" -print -quit)
    test -n "$app"
    mkdir -p "$out/Applications"
    cp -R "$app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Live streaming and screen recording studio (official prebuilt macOS app)";
    homepage = "https://obsproject.com/";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
