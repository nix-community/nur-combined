{ lib, pkgs, ... }:
{
  programs.zsh.enable = true;
  users.users.avy.shell = pkgs.zsh;
  dots.shell.enable = true;
  dots.editor.enable = true;

  # User services cannot read the host's root-only SSH key.
  home-manager.users.avy.sops.age.sshKeyPaths = lib.mkForce [ ];
  home-manager.users.avy.home.stateVersion = lib.mkForce "26.05";
}
