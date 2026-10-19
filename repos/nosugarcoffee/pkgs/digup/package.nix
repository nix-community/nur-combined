{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "digup";
  inherit (pin) version src;

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    mkdir digup-mounted
    /usr/bin/hdiutil attach -quiet -readonly -nobrowse -mountpoint "$PWD/digup-mounted" "$src"
    cp -R digup-mounted/DigUp.app .
    /usr/bin/hdiutil detach -quiet "$PWD/digup-mounted"
    rmdir digup-mounted
    runHook postUnpack
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R DigUp.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Search files on your Mac by their content with on-device embeddings";
    homepage = "https://github.com/ARahim3/DigUp";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
