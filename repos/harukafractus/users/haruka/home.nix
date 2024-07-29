{ pkgs, config, lib, ... }:
let
  mac-only = with pkgs; [
    whisky
    utm
    iina
  ];
  linux-only  = with pkgs; [
    gnome.simple-scan
    bottles
    gthumb
    audacious
    gnome-console
    waybar
  ];
  all-platforms = with pkgs; [
    vscodium
    librewolf
    baobab
    qbittorrent
    fastfetch
    hyfetch
  ];
in {
  imports = [
    ../_homeOptions
    ./apps/git.nix
  ];

  dotfiles = {
    fonts.enable = true;
    gnome.enable = true;
    zsh.enable = true;
  };
  
  home = {
    username = "haruka";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/haruka" else "/Users/haruka";
    stateVersion = "23.11";
    shellAliases = {
      gc = "sudo nix-collect-garbage -d";
    };
  };

  home.file.".nanorc" = {
    enable = true;
    text = "include ${pkgs.nano}/share/nano/*.nanorc";
  };

  home.packages = all-platforms ++ (if pkgs.stdenv.isDarwin then mac-only else linux-only);
}
