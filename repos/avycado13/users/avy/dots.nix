{
  inputs,
  ...
}:
let
  home = {
    username = "avy";
    homeDirectory = "/home/avy";
    stateVersion = "25.05";
  };
  helpers = import ../../flakeHelpers.nix inputs;
in
{
  nixpkgs = helpers.nixpkgsCfg;

  inherit home;

  imports = [
    ./dotfiles/shell/default.nix
    ./dotfiles/editor/default.nix
    ./dotfiles/ssh/default.nix
    ./packages.nix
    ./dotfiles/git/default.nix
    ./dotfiles/terminal/default.nix
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
