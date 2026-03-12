{
  drv,
  pkgs,
}:
let
  target = pkgs.pkgsCross.aarch64-multiplatform;
in
drv { inherit target; }
