{ pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "nixers" ];
  };
}