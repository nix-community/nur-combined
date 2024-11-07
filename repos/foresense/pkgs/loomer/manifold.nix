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
      x86_64-linux = "sha256-6Ea6raFJ9rwX5l6BsLtYAF3rhXESSyYDwL8qNkifZ4A=";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "manifold";
  version = "1.9.1";
  displayName = "Manifold";

  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = true;

  src = fetchurl {
    url = "https://lmr-dply.s3.eu-west-2.amazonaws.com/${pname}/${version}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };

  meta = {
    description = "Loomer Manifold - Ensemble Processor";
    homepage = "https://loomer.co.uk/manifold.html";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "Manifold";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
