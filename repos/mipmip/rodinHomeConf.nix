{ pkgsForSystem, unstableForSystem, jsonify-aws-dotfiles, extraPkgs, isDesktop, ... }:
{
  modules = [
    (import ./home/pim/home-machine-rodin.nix)
  ];

  pkgs = pkgsForSystem "x86_64-linux";
  extraSpecialArgs = {
    username = "pim";
    homedir = "/home/pim";
    withLinny = true;
    isDesktop = isDesktop;
    tmuxPrefix = "a";
    unstable = unstableForSystem "x86_64-linux";
    jsonify-aws-dotfiles = jsonify-aws-dotfiles;
    extraPkgs = extraPkgs;
  };
}
