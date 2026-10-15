{ pkgs }:
{
  calldiff = pkgs.callPackage ./calldiff { };
  esa-cli = pkgs.callPackage ./esa-cli { };
  gengo = pkgs.callPackage ./gengo { };
  gh-actions-lock = pkgs.callPackage ./gh-actions-lock { };
  git-hunk = pkgs.callPackage ./git-hunk { };
  proton-drive-cli = pkgs.callPackage ./proton-drive-cli { };
}
