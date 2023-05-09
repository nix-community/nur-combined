{ config, pkgs, modules, inputs, ... }:
let
  modules-enable = with modules; [
    avahi
    bluetooth
    clash
    common
    direnv
    fcitx5
    firefox
    fish
    fonts
    genymotion
    git
    grub
    gtk
    neovim
    nix
    nix-serve
    pipewire
    podman
    safeeyes
    smartdns
    spotify
    sway
    users
    vscode
    waybar
  ];
in
{
  imports = map (x: x.default or { }) modules-enable ++
    (with inputs; [
      (nixpkgs-unstable + "/nixos/modules/programs/nix-index.nix")
      nix-index-database.nixosModules.nix-index
      { programs.command-not-found.enable = false; }
    ]);

  home-manager = {
    users.nixos = {
      imports = map (x: x.home or { }) modules-enable;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];
  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    firewall.enable = false;
    proxy = {
      default = "http://127.0.0.1:7890";
      noProxy = "127.0.0.1,localhost,.local";
    };
  };

  nix.settings.cores = 11;
  services.earlyoom.enable = true;

  programs.adb.enable = true;

  environment.systemPackages = assert !pkgs ? motrix; with pkgs; [
    alacritty
    bottom
    clang
    croc
    curl
    dogdns
    gammastep
    git
    hydra-check
    hyperfine
    keepassxc
    killall
    librespeed-cli
    nali
    neovim
    nix-tree
    nixpkgs-fmt
    nvfetcher
    okular
    p7zip
    pavucontrol
    pciutils
    quiterss
    tdesktop
    tealdeer
    unrar
    unzip
    usbutils
    vlc
    wget
    xdg-utils
    yt-dlp
    zip
    (callPackage (inputs.nixpkgs-unstable + "/pkgs/tools/networking/motrix") { })
    config.nur.repos.xddxdd.qbittorrent-enhanced-edition
  ] ++ (map makeNoProxyWrapper [
    ydict
    ungoogled-chromium
  ]);

  environment.etc."sway/config.d/misc.conf".text = ''
    exec --no-startup-id XDG_SESSION_TYPE=x11 qbittorrent
    exec --no-startup-id gammastep -l 31:121
    exec motrix
  '';
}
