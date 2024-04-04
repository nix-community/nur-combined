{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{

  home.packages = with pkgs; [
    qq
    gtkcord4
    celeste
    stellarium
    celluloid
    thiefmd
    wpsoffice
    fractal
    mari0
    # anyrun
    # factorio
    loupe
    gedit
    logseq
    jetbrains.pycharm-professional
    jetbrains.idea-ultimate
    jetbrains.clion
    # jetbrains.rust-rover
    (pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/embedded/openocd" {
      extraHardwareSupport = [
        "cmsis-dap"
        "jlink"
      ];
    })

    # bottles

    kooha # recorder

    typst
    blender-hip
    ruffle

    # fractal

    # yuzu-mainline
    photoprism

    virt-manager
    xdg-utils
    fluffychat
    mpv
    hyfetch

    # microsoft-edge
    dosbox-staging
    meld
    # yubioath-flutter
    openapi-generator-cli

    gimp
    imv

    veracrypt
    openpgp-card-tools
    tutanota-desktop

    # davinci-resolve
    cava

    # wpsoffice-cn

    sbctl
    qbittorrent

    protonmail-bridge

    koreader
    cliphist
    # realvnc-vnc-viewer
    #    mathematica
    pcsctools
    ccid

    # nrfconnect
    nrfutil
    # nrf-command-line-tools
    yubikey-manager

    xdeltaUnstable
    xterm

    feeluown
    feeluown-bilibili
    # feeluown-local
    feeluown-netease
    feeluown-qqmusic

    chntpw
    gkraken
    libnotify

    # Perf
    stress
    s-tui
    mprime

    # reader
    calibre
    # obsidian
    mdbook
    sioyek
    zathura
    foliate

    # file
    filezilla
    file
    lapce
    kate
    # cinnamon.nemo
    gnome.nautilus
    gnome.dconf-editor
    gnome.gnome-boxes
    gnome.evince
    # zathura

    # social
    # discord
    tdesktop
    nheko
    element-desktop-wayland
    # thunderbird
    # fluffychat
    scrcpy

    alacritty
    rio
    appimage-run
    lutris
    tofi
    # zoom-us
    # gnomecast
    tetrio-desktop

    ffmpeg_5-full

    foot

    brightnessctl

    fuzzel
    swaybg
    wl-clipboard
    wf-recorder
    grim
    slurp

    mongodb-compass
    tor-browser-bundle-bin

    vial

    ncdu_2 # disk space info

    android-tools
    zellij
    # netease-cloud-music-gtk
    cmatrix
    termius
    # kotatogram-desktop
    nmap
    lm_sensors

    feh
    pamixer
    sl
    ncpamixer
    # texlive.combined.scheme-full
    vlc
    bluedevil
    julia-bin
    prismlauncher
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.graphite-cursors;
    name = "graphite-light-nord";
    size = 22;
  };

  android-sdk.enable = true;

  android-sdk.packages =
    sdk: with sdk; [
      # build-tools-31-0-0
      cmdline-tools-latest
      # emulator
      # platforms-android-31
      # sources-android-31
    ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (
      ps: with ps; [
        rustup
        zlib
      ]
    );
  };

  programs.pandoc.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [ obs-studio-plugins.wlrobs ];
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.fluent-icon-theme;
      name = "Fluent";
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      {
        "tg" = [ "org.telegram.desktop.desktop" ];

        "application/pdf" = [ "sioyek.desktop" ];
        "ppt/pptx" = [ "wps-office-wpp.desktop" ];
        "doc/docx" = [ "wps-office-wps.desktop" ];
        "xls/xlsx" = [ "wps-office-et.desktop" ];
      }
      // lib.genAttrs
        [
          "x-scheme-handler/unknown"
          "x-scheme-handler/about"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/mailto"
          "text/html"
        ]
        # (_: "brave-browser.desktop")
        (_: "firefox.desktop")
      // lib.genAttrs [
        "image/gif"
        "image/webp"
        "image/png"
        "image/jpeg"
      ] (_: "org.gnome.Loupe.desktop")
      // lib.genAttrs [
        "inode/directory"
        "inode/mount-point"
      ] (_: "org.gnome.Nautilus");
  };

  services = {

    swayidle = {
      enable = false;
      systemdTarget = "sway-session.target";
      timeouts = [
        {
          timeout = 900;
          command = "${pkgs.swaylock}/bin/swaylock";
        }
        {
          timeout = 905;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
      ];
      events = [
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock";
        }
      ];
    };
  };
}
