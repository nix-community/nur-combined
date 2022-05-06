{ lib, config, pkgs, ... }:

let
  iosevka_nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };
in {
  imports = [
    ../../profiles/home-manager/sets/cli.nix
    ../../profiles/home-manager/sets/dev.nix
    #../../profiles/home-manager/sets/gaming.nix
    ../../profiles/home-manager/sets/general.nix
    ../../profiles/home-manager/sets/gui.nix
    #../../profiles/home-manager/non-nixos/alacritty.nix
    ../../profiles/home-manager/non-nixos/settings.nix
    ../../profiles/home-manager/non-nixos/zsh-tmux.nix
  ];

  home.packages = with pkgs; [
    # Personal CLI
    jq

    # Personal GUI
    discord 

    # Special
    #(callPackage ../../pkgs/signumone-ks/default.nix { }) # Signumone-ks
    #(callPackage ../../pkgs/stremio/default.nix { })
    signumone-ks

    # Applications not working on pop!_OS
    # Pomodoro's .desktop does not work
    # alacritty gnome3.cheese gnome3.pomodoro kitty shotwell steam
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "signumone-ks"
    "ssm-session-manager-plugin"
    "steam-runtime"
    "upwork"
  ];

  # Helps in loading icons on Pop!_OS (GNOME on Xorg)
  # TODO: Find a way to reference the home.homeDirectory from home.nix
  xdg.systemDirs.data = [
    "/home/bjorn/.nix-profile/share"
  ];
}

