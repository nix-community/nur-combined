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
    inputs.nix-index-database.hmModules.nix-index
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

  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty
    arduino-ide
    audiorelay
    bottom
    curl
    doggo
    gdu
    geo
    git
    gocryptfs
    hydra-check
    hyperfine
    ianny
    iotop
    just
    kdePackages.okular
    keepassxc
    killall
    libreoffice
    librespeed-cli
    localsend
    lsof
    meld
    minicom
    nali
    neovim
    nix-tree
    nixpkgs-fmt
    nvfetcher
    p7zip
    pavucontrol
    pciutils
    python3
    qrencode
    remmina
    rust-petname
    satty
    scrcpy
    scrcpy-mask
    sops
    tdesktop
    unrar
    unzip
    usbutils
    wget
    xdg-utils
    yt-dlp
    zip
  ] ++ (map makeNoProxyWrapper [
    ydict
    kodi-wayland
    ungoogled-chromium
  ]);
  nixpkgs.config.chromium.commandLineArgs = "--enable-wayland-ime --wayland-text-input-version=3";
}
