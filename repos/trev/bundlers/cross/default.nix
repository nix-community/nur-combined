{
  drv,
  pkgs,
}:
let
  targetSystem = pkgs.pkgsCross.aarch64-multiplatform;
in
targetSystem.callPackage drv { }
