{ pkgs }:
{
  fetchDeps = pkgs.callPackage ./fetchDeps.nix { };
  configHook = pkgs.callPackage ./configHook.nix { };
}
