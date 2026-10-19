# nixpkgs' clash-verge-rev is Linux-only, so this repacks the official
# prebuilt macOS app from upstream's release DMGs -- same approach nixpkgs
# takes for google-chrome on darwin. Version and hashes live in
# pin.json, bumped by release_pins.py.
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
  pname = "clash-verge-rev";
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
    description = "Clash Meta GUI (official prebuilt macOS app)";
    homepage = "https://www.clashverge.dev/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
