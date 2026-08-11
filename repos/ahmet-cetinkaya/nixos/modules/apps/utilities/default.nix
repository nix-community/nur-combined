{pkgs, ...}: {
  # Flatpak
  services.flatpak.packages = [
    # System Tools
    "org.bleachbit.BleachBit"
    "org.kde.filelight"
    "org.kde.isoimagewriter"
    "com.anydesk.Anydesk"
    "org.filezillaproject.Filezilla"
    "org.kde.kalk"
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    kitty

    # CLI Utilities
    btop
    direnv
    eza
    fastfetch
    jq
    killall
    nano
    tree
    zoxide

    # Download Tools
    curl
    wget

    # Version Control
    git
    gh

    # Search Tools
    fd
    ripgrep

    # Archive Tools
    p7zip
    unar
    unzip
    zip

    # Build Tools
    pkg-config
    gnumake
    gcc
    clang
    cmake
    ninja

    # System Tools
    gparted
    openrgb-with-all-plugins
    scrcpy

    # Media Tools
    ffmpeg
    imagemagick
    prince-bin

    # Sandbox & Networking
    bubblewrap
    socat
  ];

  # OpenRGB with all plugins for RGB hardware control
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd"; # The workstation motherboard uses the AMD sensor/control backend.
  };

  systemd.services.openrgb.serviceConfig.RestartSec = 5;

  programs.kdeconnect.enable = true;

  environment.sessionVariables = {
    TERMINAL = "kitty";
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "docker"
          "kubectl"
        ];
        theme = "robbyrussell";
      };

      shellAliases = {
        ll = "ls -l";
        ls = "eza --icons=auto --hyperlink";
      };
    };
    starship = {
      enable = true;
    };
    zoxide = {
      enable = true;
    };
  };
}
