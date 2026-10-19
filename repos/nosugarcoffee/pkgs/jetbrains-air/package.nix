# JetBrains Air (agentic development environment) isn't in nixpkgs, so this
# repacks the official prebuilt macOS app from JetBrains' DMG -- same approach
# as the other DMG repacks here. Air is still a preview product: JetBrains ships
# per-arch DMGs and prunes older preview builds from the CDN, so pin.json
# needs bumping fairly often; release_pins.py follows the JetBrains products
# API for it.
{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "jetbrains-air";
  inherit (pin) version src;

  # Unlike the other DMG-packaged darwin apps in this repo, Air's DMG (as of
  # 262.1037.6) is a flat GPT image with a single "whole disk" blkx entry
  # instead of the legacy Apple Partition Map undmg expects (one blkx per
  # partition, named e.g. "Apple_HFS (...)"). undmg only recognizes HFS by
  # that name match, so it can't tell this is HFS+ and bails with "only HFS
  # file systems are supported" even though the volume inside is plain
  # HFS+. 7-Zip parses the GPT partition table and HFS+ filesystem directly
  # and preserves the symlinks/permissions the app bundle needs.
  nativeBuildInputs = [ _7zz ];
  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  unpackPhase = ''
    runHook preUnpack
    7zz x "$src" -y
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    app=$(find . -mindepth 1 -maxdepth 2 -name "*.app" -print -quit)
    test -n "$app"
    mkdir -p "$out/Applications"
    cp -R "$app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "JetBrains Air, an agentic development environment (official prebuilt macOS app)";
    homepage = "https://air.dev/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
