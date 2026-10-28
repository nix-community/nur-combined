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
  pname = "qingjian";
  inherit (pin) version src;

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    /usr/sbin/pkgutil --expand-full "$src" expanded
    cp -R expanded/Qingjian-component.pkg/Payload/Qingjian.app .
    rm -rf expanded
    runHook postUnpack
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Library/Input Methods"
    cp -R Qingjian.app "$out/Library/Input Methods/"
    runHook postInstall
  '';

  meta = {
    description = "Pinyin input method that shows a word in the language you are learning beside each candidate";
    homepage = "https://qingjian.app";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
