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
    # CLI Utilities
    btop
    direnv
    areofyl-fetch
    jq
    killall
    nano
    tree

    # Download Tools
    curl
    wget

    # Version Control
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
}
