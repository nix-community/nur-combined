{ lib, pkgs, ... }:
{
  programs.zsh.enable = true;
  users.users.avy.shell = pkgs.zsh;
  dots = {
    shell.enable = false;
    editor.enable = true;
  };

  home-manager.users.avy.home.stateVersion = lib.mkForce "26.05";
}
