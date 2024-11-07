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
      x86_64-linux = "";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
  archive_fmt = if stdenv.hostPlatform.isDarwin then "dmg" else "tar.gz";
  hash =
    {
      x86_64-linux = "sha256-kMSyymXZ3paPOgVw2NYwyxF/L7SVriOJ5XbiEKl05N8=";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "sequent";
  version = "2.0.5";
  displayName = "Sequent";

  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = true;

  src = fetchurl {
    url = "https://lmr-dply.s3.eu-west-2.amazonaws.com/${pname}/${version}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };

  meta = {
    description = "Loomer Sequent - Modular Step-Sequenced FX Processor";
    homepage = "https://loomer.co.uk/sequent.html";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Sequent";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
