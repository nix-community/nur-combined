{ config, lib, pkgs, ... }:

{
  programs.zsh.enable = true;
  users = {
    groups.nixers = {
      name = "nixers";
    };
    users.bjorn = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "nixers" ];
    };
  };
  nix.settings.trusted-users = [ "@nixers" ];
}
