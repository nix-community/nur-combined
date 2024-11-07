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
      x86_64-linux = "sha256-j25H/ATa145mqfLs96uFG7XpOKu+XLyOUqPeD2CPmqQ=";
      # x86_64-darwin = "";
      # aarch64-darwin = "";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "resound";
  version = "1.9.1";
  displayName = "Resound";

  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = true;

  src = fetchurl {
    url = "https://lmr-dply.s3.eu-west-2.amazonaws.com/${pname}/${version}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };

  meta = {
    description = "Loomer Resound - Vintage Tape Echo";
    homepage = "https://loomer.co.uk/resound.html";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "Resound";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
