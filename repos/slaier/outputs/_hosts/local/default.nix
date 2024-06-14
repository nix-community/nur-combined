{ modules, inputs, ... }:
{ config, pkgs, lib, ... }:
let
  modules-enable = with modules; [
    aria2
    bluetooth
    common
    croc
    direnv
    fcitx5
    firefox
    fish
    fonts
    git
    grub
    gtk
    liferea
    mpv
    neovim
    nix
    openfortivpn
    podman
    radicale
    sing-box
    sops
    spotify
    sway
    syncthing
    users
    vscode
    waybar
    inputs.nix-index-database.hmModules.nix-index
  ];
in
{
  imports = map (x: x.default or { }) modules-enable ++
    (with inputs; [
      nix-index-database.nixosModules.nix-index
      { programs.command-not-found.enable = false; }
    ]);

  home-manager.users.nixos.imports = map (x: x.home or { }) modules-enable;

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

  nix.settings = {
    cores = 11;
    keep-outputs = true;
  };
  services.earlyoom.enable = true;

  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    bottom
    curl
    doggo
    gammastep
    git
    gocryptfs
    hydra-check
    hyperfine
    iotop
    keepassxc
    killall
    librespeed-cli
    lsof
    meld
    nali
    neovim
    nix-tree
    nixpkgs-fmt
    nvfetcher
    okular
    p7zip
    pavucontrol
    pciutils
    qrencode
    rust-petname
    safeeyes
    sops
    tdesktop
    tealdeer
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

  services.safeeyes.enable = true;

  environment.etc."sway/config.d/misc.conf".text = ''
    exec --no-startup-id gammastep -l 31:121
  '';
}
