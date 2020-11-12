{ pkgs, config, ... }:
{
  imports = [
  ]
  ++ import <dotfiles/lib/listModules.nix> "home";

  manual.manpages.enable = false;

  home.packages = with pkgs; [
    # ------------ pacotes do nixpkgs ---------------
    calibre
    file
    fortune
    lazydocker
    libnotify
    manix
    neofetch
    nix-index
    scrcpy
    sqlite
    typora
    #browser
    google-chrome
    # jetbrains
    # pkgs.jetbrains.clion
  ];
  programs = {
    command-not-found.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  home.stateVersion = "20.03";
}
