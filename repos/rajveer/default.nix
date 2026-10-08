{
  pkgs ? import <nixpkgs> { },
}:
let
  mkPackage = package: pkgs.callPackage ./pkgs/nixbox/package.nix { inherit package; };
in
{
  nixbox = mkPackage "nixbox";
  nixbox-cli = mkPackage "nixbox-cli";
}
// pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  nixbox-gui = mkPackage "nixbox-gui";
}
