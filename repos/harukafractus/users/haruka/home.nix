{ pkgs, config, lib, ... }:
let
  mac-only = with pkgs; [
    whisky
    utm
  ];
  linux-only  = with pkgs; [
    gnome.simple-scan
    bottles
    gthumb
    audacious
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

  home.packages = all-platforms ++ (if pkgs.stdenv.isDarwin then mac-only else linux-only);

  programs = {
    # Enable Git
    git = {
      enable = true;
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        user = {
          email = "106440141+harukafractus@users.noreply.github.com";
          name = "harukafractus";
          signingkey = "~/.ssh/id_rsa.pub";
        };
        gpg = {
          format = "ssh";
        };
        commit = {
          gpgSign = true;
        };
      };
    };
  };
}
