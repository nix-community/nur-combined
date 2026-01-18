{ pkgs, ... }:
{
  imports =
    [
      { programs.command-not-found.enable = false; }
      ./hardware-configuration.nix
    ];

  home-manager.users.nixos.imports = [
    ({ lib, ... }: {
      xdg.configFile."pip/pip.conf".text = lib.generators.toINI { } {
        global = {
          index-url = "https://mirror.nju.edu.cn/pypi/web/simple";
        };
      };
    })
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];
  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    firewall.enable = false;
    proxy = {
      default = "http://127.0.0.1:7890";
      noProxy = "127.0.0.1,localhost,.lan";
    };
  };

  documentation.man.generateCaches = false;

  nix.settings = {
    cores = 11;
    keep-outputs = true;
  };
  services.earlyoom.enable = true;

  services.speechd.enable = false;

  programs.adb.enable = true;
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    abiword
    alacritty
    arduino-ide
    bottom
    cloudflared
    curl
    doggo
    filezilla
    freerdp
    gdu
    gemini-cli
    geminicommit
    geo
    git
    gnumeric
    hydra-check
    hyperfine
    ianny
    iotop
    just
    killall
    kodi-wayland
    librespeed-cli
    localsend
    lsof
    meld
    minicom
    mtr
    nali
    neovim
    nix-tree
    nixpkgs-fmt
    nomacs
    p7zip
    pavucontrol
    pciutils
    python3
    qalculate-qt
    qpdfview
    qrencode
    rust-petname
    satty
    scrcpy
    sops
    ungoogled-chromium
    unrar
    unzip
    usbutils
    wget
    xdg-utils
    ydict
    yt-dlp
    zip
    (makeElectronWrapper teams-for-linux)
  ]
  ;
  nixpkgs.config.chromium.commandLineArgs = "--enable-wayland-ime --wayland-text-input-version=3";
}
