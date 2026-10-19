# Pulsar (Atom successor) is Linux-only in nixpkgs, so this repacks the
# official prebuilt macOS app from upstream's GitHub release zip -- same
# approach as clash-verge-rev, but a .zip instead of a .dmg since
# that's all upstream publishes per-arch. Only the Apple Silicon build is
# packaged here.
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  unzip,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "pulsar";
  inherit (pin) version src;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];
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

    # PULSAR_PATH is mandatory, not a nicety: pulsar.sh locates the bundle by
    # walking three directories up from $0, which from $out/bin lands on the
    # store root rather than a .app, and its fallback only searches
    # /Applications and ~/Applications -- never the ~/Applications/Home Manager
    # Apps/ directory home-manager actually links into.
    makeWrapper "$out/Applications/Pulsar.app/Contents/Resources/pulsar.sh" \
      "$out/bin/pulsar" \
      --set PULSAR_PATH "$out/Applications"
    runHook postInstall
  '';

  meta = {
    description = "Community-led hyperhackable text editor (official prebuilt macOS app)";
    homepage = "https://pulsar-edit.dev/";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
