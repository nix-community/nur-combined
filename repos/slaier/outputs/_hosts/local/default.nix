{ modules, inputs, ... }:
{ config, pkgs, lib, ... }:
let
  modules-enable = with modules; [
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
    neovim
    nix
    openfortivpn
    podman
    sing-box
    sops
    spotify
    sway
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
    clang
    curl
    dogdns
    gammastep
    git
    gocryptfs
    hydra-check
    hyperfine
    iotop
    keepassxc
    killall
    librespeed-cli
    meld
    motrix
    mpv
    nali
    neovim
    nix-tree
    nixpkgs-fmt
    nvfetcher
    okular
    p7zip
    pavucontrol
    pciutils
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
    (config.nur.repos.xddxdd.qbittorrent-enhanced-edition.override {
      qbittorrent = qbittorrent.override {
        libtorrent-rasterbar = libtorrent-rasterbar.overrideAttrs (prev: {
          src = fetchFromGitHub {
            owner = "arvidn";
            repo = "libtorrent";
            rev = "v2.0.9";
            sha256 = "sha256-kUpeofullQ70uK/YZUD0ikHCquFTGwev7MxBYj0oHeU=";
            fetchSubmodules = true;
          };
        });
      };
    })
  ] ++ (map makeNoProxyWrapper [
    ydict
    ungoogled-chromium
  ]);

  environment.etc."sway/config.d/misc.conf".text = ''
    exec --no-startup-id XDG_SESSION_TYPE=x11 qbittorrent
    exec --no-startup-id gammastep -l 31:121
    exec motrix
    exec safeeyes
  '';
}
