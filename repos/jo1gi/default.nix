{ pkgs }:

{
  AAXtoMP3 = pkgs.callPackage ./packages/aaxtomp3.nix {};
  audible-cli = pkgs.callPackage ./packages/audible-cli.nix {};
  audiobook-dl-git = pkgs.callPackage ./packages/audiobook-dl-git.nix {};
}
