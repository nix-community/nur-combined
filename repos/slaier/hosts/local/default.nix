{ pkgs, ... }:
{
  imports = [
    { programs.command-not-found.enable = false; }
    ./hardware-configuration.nix
  ];

  home-manager.users.nixos.imports = [
    (
      { lib, ... }:
      {
        xdg.configFile."pip/pip.conf".text = lib.generators.toINI { } {
          global = {
            index-url = "https://mirror.nju.edu.cn/pypi/web/simple";
          };
        };
      }
    )
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];
  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    firewall.enable = false;
    proxy = {
      default = "http://local.lan:7890";
      noProxy = "127.0.0.1,localhost,.lan";
    };
  };
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 16384 134217728";
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.route.flush" = 1;
  };

  documentation.man.cache.enable = false;

  nix.settings = {
    keep-outputs = true;
  };
  services.earlyoom.enable = true;

  services.speechd.enable = false;

  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    # gui
    abiword
    freerdp
    gnumeric
    kodi-wayland
    localsend
    nomacs
    pavucontrol
    qalculate-qt
    qbittorrent
    qpdfview
    satty
    scrcpy
    ungoogled-chromium
    # cli
    android-tools
    axel
    bottom
    cachix
    chezmoi
    cloudflared
    curl
    doggo
    gdu
    geo
    git
    hydra-check
    hyperfine
    ianny
    iotop
    jq
    just
    killall
    librespeed-cli
    lsof
    meld
    minicom
    mtr
    nali
    neovim
    nix-tree
    nixpkgs-fmt
    p7zip
    pciutils
    python3
    qrencode
    ripgrep
    rust-petname
    sops
    tmux
    unrar
    unzip
    usbutils
    wget
    xdg-utils
    ydict
    yq-go
    yt-dlp
    zip
  ];
  nixpkgs.config.chromium.commandLineArgs = "--enable-wayland-ime --wayland-text-input-version=3";
}
