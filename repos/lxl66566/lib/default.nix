# lib/default.nix
{
  pkgs,
  ...
}:
{
  makeBinPackage = pkgs.callPackage ./makeBinPackage.nix { };
}
