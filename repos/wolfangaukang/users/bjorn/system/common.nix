{ pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.bjorn = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "nixers" ];
  };
}
