{ pkgs, ... }:
let
  globalConfig = import <dotfiles/globalConfig.nix>;
in
with globalConfig;
{
  programs.git = {
    enable = true;
    userName = username;
    userEmail = email;
  };
  home.packages = with pkgs; [
    haskellPackages.git-annex
  ];
}
