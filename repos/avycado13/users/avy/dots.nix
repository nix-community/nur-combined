{ lib, ... }:
{
  home = {
    username = "avy";
    homeDirectory = lib.mkDefault "/home/avy";
    stateVersion = lib.mkDefault "25.05";
  };

  imports = [
    ./dotfiles/shell/default.nix
    ./dotfiles/editor/default.nix
    ./dotfiles/ssh/default.nix
    ./packages.nix
    ./dotfiles/git/default.nix
    ./dotfiles/terminal/default.nix
    ./dotfiles/apps/qutebrowser.nix
    ./dotfiles/gpg/default.nix
    ./dotfiles/devenv/default.nix
    ./dotfiles/theme/default.nix
    ./dotfiles/syncthing/default.nix
    ./dotfiles/restic/default.nix
    ./dotfiles/irc/default.nix
    ./dotfiles/media/default.nix
  ];

  programs.home-manager.enable = true;
  services.home-manager = {
    autoExpire = {
      enable = true;
      store = {
        cleanup = true;
        options = "--delete-older-than 7d";
      };
    };
    autoUpgrade = {
      enable = false;
      flakeDir = "~/nix";
      useFlake = true;
    };
  };

  systemd.user.startServices = "sd-switch";
}
