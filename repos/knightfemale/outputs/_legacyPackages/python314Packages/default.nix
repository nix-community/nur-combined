{
  lib,
  python314Packages,
}:

let
  inherit (python314Packages.stdenv.hostPlatform)
    isLinux
    ;
in
lib.makeScope python314Packages.newScope (self: {
  lada = if isLinux then self.callPackage ./lada { } else null;
})
