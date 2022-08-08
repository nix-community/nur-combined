{ global, pkgs, config, lib, self, ... }:
let 
  inherit (global) username email rootPath;
  inherit (builtins) fetchurl;
  inherit (self) inputs outputs;
  inherit (pkgs) writeShellScript espeak wrapDotenv p2k;
  inherit (lib.hm.gvariant) mkTuple; environmentShell = outputs.environmentShell.x86_64-linux;
  inherit (pkgs.custom) colors;
in {
  imports = [
    ../base/default.nix
    ./dlna.nix
    ./espanso.nix
    ./dconf.nix
    ./nixgram.nix
    ./borderless-browser.nix
    ./theme.nix

  ];

  home.packages = with pkgs; [
    calibre # a dependency is broken
    chromium
    custom.tixati
    (custom.neovim.override { inherit colors; })
    (custom.emacs.override { inherit colors; })
    custom.firefox
    dotenv
    discord
    feh
    fortune
    graphviz
    gimp
    libnotify
    libreoffice
    mendeley
    ncdu
    nix-option
    nix-prefetch-scripts
    obsidian
    pipedream-cli
    pkg
    rclone
    ripgrep
    sqlite
    sshpass
    stremio
    tdesktop # communication
    terraform
    t-launcher
    vlc # media
    wineApps.wine7zip
    wineApps.skyrim
    xxd
    pavucontrol # controle de volume
    zeal
    rnix-lsp
    # retroarchFull
    # texlive.combined.scheme-full
  ] ;

  # programs.hello-world.enable = true;
  

  services.redial_proxy.enable = true;

  programs = {
    # adskipped-spotify.enable = true;
    command-not-found.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
    htop = {
      enable = true;
      settings = {
        hideThreads = true;
        treeView = true;
      };
    };
  };

  # KDE connect
  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };

  gtk = {
    enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  programs.terminator = {
    enable = true;
    config = {
      global_config.borderless = true;
    };
  };
  programs.bash.enable = true;
}
