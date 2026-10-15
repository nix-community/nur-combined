{ pkgs }:
{
  calldiff = pkgs.callPackage ./calldiff { };
  esa-cli = pkgs.callPackage ./esa-cli { };
  gengo = pkgs.callPackage ./gengo { };
  git-hunk = pkgs.callPackage ./git-hunk { };
  proton-drive-cli = pkgs.callPackage ./proton-drive-cli { };
}
