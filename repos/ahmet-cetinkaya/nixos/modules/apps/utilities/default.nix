{pkgs, ...}: {
  # Flatpak
  services.flatpak.packages = [
    # System Tools
    "org.bleachbit.BleachBit"
    "org.kde.filelight"
    "org.kde.isoimagewriter"
    "com.anydesk.Anydesk"
    "org.filezillaproject.Filezilla"
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

    # Containers
    docker
    docker-compose
    podman
    distrobox
    act

    # System Tools
    konsave
    gparted
    openrgb-with-all-plugins

    # Media Tools
    ffmpeg
    imagemagick
    tesseract

    # Sandbox & Networking
    bubblewrap
    socat

    # Wine
    wineWow64Packages.stable
    winetricks
  ];

  # OpenRGB with all plugins for RGB hardware control
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  systemd.services.openrgb.serviceConfig.RestartSec = 5;

  # Containers
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  programs.kdeconnect.enable = true;

  # Shell
  users.users.ac.shell = pkgs.zsh;

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
        ls = "eza --icons=auto";
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
