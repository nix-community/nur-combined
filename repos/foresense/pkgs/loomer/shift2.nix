{
  stdenv,
  lib,
  callPackage,
  fetchurl,
  xorg,
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
      x86_64-linux = "sha256-xk5TQy3pAsK0y6cmx0E53waoGIBVV6UKDpfi71JA95o=";
    }
    .${system} or throwSystem;
in
callPackage ./generic.nix rec {
  pname = "shift2";
  version = "2.4.1";
  displayName = "Shift2";

  withApp = true;
  withAU = if stdenv.hostPlatform.isDarwin then true else false;
  withVST = true;
  withVST3 = false; # No VST3

  src = fetchurl {
    url = "https://loomer.co.uk/downloads/${displayName}/${displayName}${arch}-${version}.${archive_fmt}";
    inherit hash;
  };

  extraBuildInputs = with xorg; [
    libX11
    libXinerama
    libXext
  ];

  meta = {
    description = "Loomer Shift2 - Granular pitch-tracking, pitch-shifting delay";
    homepage = "https://loomer.co.uk/shift.html";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Shift2";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
