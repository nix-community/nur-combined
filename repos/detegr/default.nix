{ pkgs }:
{
  armcl = pkgs.callPackage ./armcl { };
  kap = pkgs.callPackage ./kap { };
}
