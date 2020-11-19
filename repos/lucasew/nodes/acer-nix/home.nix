{ pkgs, config, lib, ... }:
with import <dotfiles/globalConfig.nix>;
let
  wallpaper = builtins.fetchurl {
    url = "http://wallpaperswide.com/download/aurora_sky-wallpaper-1366x768.jpg";
    sha256 = "1gk4bw5mj6qgk054w4g0g1zjcnss843afq5h5k0qpsq9sh28g41a";
    # url = "http://wallpaperswide.com/download/armenia_syunik_khustup_hayk_k13-wallpaper-1366x768.jpg";
    # sha256 = "1z2439f0d8hpqwjp07xhwkcp7svzvbhljayhdfssmvi619chlc0p";
  };
  tuple = lib.hm.gvariant.mkTuple;
in
{
  imports = [
    ./modules/among_us/home.nix
    ./modules/dlna.nix
    ./modules/ets2/home.nix
    ./modules/firefox/home.nix
    ./modules/usb_tixati/home.nix
    ./modules/webviews/home.nix
    "${builtins.fetchGit { url = "https://github.com/lucasew/nixgram"; rev = "1b2c48fae75f9a2dbebff1930d3b8c34a74a4580";}}/hmModule.nix"
  ]
  ++ import <dotfiles/lib/listModules.nix> "home";

  home.packages = with pkgs; [
   # ------------ pacotes do nixpkgs ---------------
    # minecraft  # custom (excluded)
    pinball mspaint stremio my_rofi # custom
    gimp kdeApplications.kdenlive vlc youtube-dl # media
    discord tdesktop # social
    google-chrome # browser (extra)
    haskellPackages.git-annex # git
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
    # jetbrains
    # pkgs.jetbrains.clion
  ];
  programs = {
    adskipped-spotify.enable = true;
    adskipped-youtube-music.enable = true;
    command-not-found.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
    bash = {
      enable = true;
      initExtra = ''
        export EDITOR="nvim"
        export PS1="\u@\h \w \$?\\$ \[$(tput sgr0)\]"
        export PATH="$PATH:~/.yarn/bin/"
        source ~/.dotfilerc
        alias la="ls -a"
        alias ncdu="rclone ncdu . 2> /dev/null"
        alias sqlite3="${pkgs.rlwrap}/bin/rlwrap sqlite3"
      '';
    };
    htop = {
      enable = true;
      hideThreads = true;
      treeView = true;
    };
    tmux.enable = true;
    vscode.enable = true;
  };

  # Git
  programs.git = {
        enable = true;
        userName = username;
        userEmail = email;
  };

  # KDE connect
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Dconf
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      primary-color = "#ffffff";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/input-sources" = {
      current = "uint32 0";
      sources = [(tuple ["xkb" "br"]) (tuple ["xkb" "us"])];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };
    "org/gnome/desktop/interface" = {
      cursor-theme = "Adwaita";
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Adwaita-dark";
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = false;
    };
    "org/gnome/desktop/privacy" = {
      disable-microphone = true;
      report-technical-problems = false;
    };
    "org/gnome/system/location" = {
      enabled = false;
    };
    "org/gnome/desktop/periphereals/touchpad" = {
      tap-to-click = true;
    };
  };

  # nixgram
  services.nixgram = {
    enable = true;
    dotenvFile = ../../secrets/nixgram.env;
    customCommands = {
      echo = "echo $*";
      speak = ''
        ${pkgs.espeak}/bin/espeak -v mb/mb-br1 "$*"
      '';
    };
  };

  # wallpaper
  wallpaper = {
    enable = true;
    wallpaperFile = wallpaper;
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
