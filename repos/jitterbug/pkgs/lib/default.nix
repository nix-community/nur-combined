{ pkgs, ... }:
let
  maintainers = import ../../maintainers.nix;
in
{
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit maintainers; });
}
