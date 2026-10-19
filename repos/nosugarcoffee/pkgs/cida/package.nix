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
  pname = "cida";
  inherit (pin) version src;

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    mkdir cida-mounted
    /usr/bin/hdiutil attach -quiet -readonly -nobrowse -mountpoint "$PWD/cida-mounted" "$src"
    cp -R cida-mounted/Cida.app .
    /usr/bin/hdiutil detach -quiet "$PWD/cida-mounted"
    rmdir cida-mounted
    runHook postUnpack
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R Cida.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Translate and polish text anywhere on macOS with an LLM of your choice";
    homepage = "https://github.com/Xuanwo/cida";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
