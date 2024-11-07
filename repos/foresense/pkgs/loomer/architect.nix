{
  lib,
  stdenv,
  callPackage,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";
  arch =
    {
      i686-linux = "";
      x86_64-linux = "_x86_64";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
  archive_fmt = if stdenv.hostPlatform.isDarwin then "dmg" else "tar.gz";
  hash =
    {
      i686-linux = "";
      x86_64-linux = "sha256-kISRFAnkuPoz/ehVlZfyuDAjMHW80xViNFgBo8bjDwY=";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "architect";
  version = "0.10.23";
  displayName = "Architect";

  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = true;

  src = fetchurl {
    url = "https://lmr-dply.s3.eu-west-2.amazonaws.com/${displayName}/${version}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };

  meta = {
    description = "Loomer Architect - Modular MIDI Toolkit";
    homepage = "https://loomer.co.uk/architect.html";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "Architect";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
