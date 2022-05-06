{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/home-manager/sets/cli.nix
    ../../profiles/home-manager/sets/dev.nix
    ../../profiles/home-manager/sets/general.nix
    ../../profiles/home-manager/sets/gui.nix
    ../../profiles/home-manager/sets/simplerisk.nix
    ../../profiles/home-manager/non-nixos/settings.nix
    ../../profiles/home-manager/non-nixos/zsh-tmux.nix
  ];

  programs = {
    kitty = {
      enable = true;
      extraConfig = builtins.readFile /home/bjorn/.config/kitty/extras;
      font = {
        package = pkgs.iosevka;
        name = "Iosevka Term";
      };
    };
    urxvt = {
      enable = true;
      #extraConfig = { builtins.readFile /home/bjorn/.config/urxvt/config};
      fonts = [
        "xft:Iosevka Term:pixelsize=14:antialias=true"
      ];
      keybindings = {
        "Shift-Control-C" = "eval:selection_to_clipboard";
        "Shift-Control-V" = "eval:paste_clipboard";
        "M-u" = "perl:url-select:select_next";
      };
      scroll.bar.enable = false;
    };
  };
}
