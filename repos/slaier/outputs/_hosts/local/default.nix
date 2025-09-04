{ modules, inputs, ... }:
{ config, pkgs, lib, ... }:
{
  imports = map (x: x.default or { }) (lib.attrValues modules) ++
    (with inputs; [
      nix-index-database.nixosModules.nix-index
      { programs.command-not-found.enable = false; }
      niri.nixosModules.niri
    ]);

  home-manager.users.nixos.imports = map (x: x.home or { }) (lib.attrValues modules) ++ [
    inputs.nix-index-database.homeModules.nix-index
    ({ lib, ... }: {
      xdg.configFile."pip/pip.conf".text = lib.generators.toINI { } {
        global = {
          index-url = "https://mirror.nju.edu.cn/pypi/web/simple";
        };
      };
    })
  ];

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

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

  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty
    arduino-ide
    audiorelay
    bottom
    curl
    doggo
    filezilla
    freerdp
    gdu
    gemini-cli
    geo
    git
    hydra-check
    hyperfine
    ianny
    iotop
    just
    killall
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
    unrar
    unzip
    usbutils
    wget
    xdg-utils
    yt-dlp
    zip
    (makeElectronWrapper teams-for-linux)
  ] ++ (map makeNoProxyWrapper [
    ydict
    kodi-wayland
    ungoogled-chromium
  ]);
  nixpkgs.config.chromium.commandLineArgs = "--enable-wayland-ime --wayland-text-input-version=3";
}
