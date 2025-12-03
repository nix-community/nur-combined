{ vaculib, ... }:
let
  packagePaths = vaculib.directoryGrabber {
    path = ./.;
    mainName = "package.nix";
  };
in
packagePaths
