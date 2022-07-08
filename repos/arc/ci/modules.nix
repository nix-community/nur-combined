{ pkgs }: let
  home = ../modules/home;
  nixos = ../modules/nixos;
  system = pkgs.nixos {
    boot.isContainer = true;
    imports = [nixos <home-manager/nixos>];
    home-manager.users.root = _: {
      imports = [home];
      config.home.stateVersion = "21.05";
    };
  };
  # TODO: support nix-darwin
in pkgs.lib.optional pkgs.hostPlatform.isLinux system.toplevel
