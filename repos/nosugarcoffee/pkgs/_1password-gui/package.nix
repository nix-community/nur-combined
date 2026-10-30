# nixpkgs carries the 1Password app too, but trails the stable channel by
# several releases; this follows the stable release feed nightly. The app
# arrives notarized, so it is copied verbatim: a fixup pass would break the
# seal that the CLI and browser extension check before they connect.
#
# `version` describes the zip in the store. Once home-manager copies the
# bundle somewhere writable, 1Password's own updater may move it ahead.
#
# Linux is left to nixpkgs, which already wraps the .tar.gz and its
# setuid helper.
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
  pname = "1password-gui";
  inherit (pin) version src;

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R 1Password.app $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "1Password password manager desktop app (official notarized release)";
    homepage = "https://1password.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit (pin) platforms;
  };
}
