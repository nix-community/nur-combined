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
      x86_64-linux = "";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
  archive_fmt = if stdenv.hostPlatform.isDarwin then "dmg" else "tar.gz";
  hash =
    {
      # i686-linux = "";
      x86_64-linux = "sha256-30sV1yYhNWWaXEkii+FGUwfvJM/KFIHsYDLsmoryGHs=";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "aspect";
  version = "2.0.3";
  displayName = "Aspect";
  
  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = true;
  
  src = fetchurl {
    url = "https://lmr-dply.s3.eu-west-2.amazonaws.com/${pname}/${version}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };
  
  meta = {
    description = "Loomer Aspect - Semi Modular Polyphonic Synthesizer";
    homepage = "https://loomer.co.uk/aspect.html";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "Aspect";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
