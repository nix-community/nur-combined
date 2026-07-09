{pkgs, ...}: let
  androidWebcam = pkgs.writeShellScriptBin "android-webcam" ''
    set -euo pipefail

    device="''${1:-/dev/video2}"
    shift || true

    if [ ! -e "$device" ]; then
      echo "Virtual camera device not found: $device" >&2
      echo "Available video devices:" >&2
      ls /dev/video* 2>/dev/null >&2 || true
      exit 1
    fi

    # Mirror the phone camera (not the screen) into the v4l2 loopback so OBS
    # sees a webcam feed. CAMERA_FACING (front/back/external) and CAMERA_SIZE
    # are overridable; requires Android 12+ on the phone.
    exec ${pkgs.scrcpy}/bin/scrcpy \
      --v4l2-sink="$device" \
      --video-source=camera \
      --camera-facing="''${CAMERA_FACING:-front}" \
      --camera-size="''${CAMERA_SIZE:-1920x1080}" \
      --no-audio \
      "$@"
  '';
in {
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
    scrcpy
    androidWebcam

    # Media Tools
    ffmpeg
    imagemagick
    tesseract
    prince-bin

    # Document Conversion
    python314Packages.markitdown

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
