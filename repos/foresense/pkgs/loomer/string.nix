{
  stdenv,
  lib,
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
      x86_64-linux = "sha256-p5luB8tnmC6+wen1tNWPeDae2AeAU5VsvUChTY83StI=";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "string";
  version = "1.17.3";
  displayName = "String";
  
  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = true;

  src = fetchurl {
    url = "https://lmr-dply.s3.eu-west-2.amazonaws.com/${displayName}/${version}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };

  meta = {
    description = "Loomer String - Ensemble Synth";
    homepage = "https://loomer.co.uk/string.html";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "String";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
