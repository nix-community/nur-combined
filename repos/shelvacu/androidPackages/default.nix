{ vaculib, ... }:
vaculib.directoryGrabber {
  path = ./.;
  mainName = "package.nix";
  ignore = [ ./notes.md ];
}
