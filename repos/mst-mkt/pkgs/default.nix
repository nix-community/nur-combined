{ pkgs }:
{
  calldiff = pkgs.callPackage ./calldiff { };
  esa-cli = pkgs.callPackage ./esa-cli { };
  gengo = pkgs.callPackage ./gengo { };
  gh-pr-reviews = pkgs.callPackage ./gh-pr-reviews { };
  git-hunk = pkgs.callPackage ./git-hunk { };
  omniwm = pkgs.callPackage ./omniwm { };
  rinkaku = pkgs.callPackage ./rinkaku { };
}
