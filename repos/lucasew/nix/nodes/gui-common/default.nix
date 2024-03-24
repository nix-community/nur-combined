{pkgs, lib, global, ...}:
let
  inherit (global) username;
in {
  imports = [
    ../common
    ./gui-variants
    ./audio.nix
    ./gui.nix
    ./networking.nix
    ./steam.nix
    ./git.nix
    ./gammastep.nix
    ./adb.nix
    ./vbox.nix
    ./tuning.nix
    ./ipfs.nix
    ./gamemode.nix
    ./syncthing.nix
    ./stremio.nix
    ./sunshine.nix
    ./wallpaper.nix
    ./extra-fonts.nix
    ./gui-variants
  ];

  systemd.extraConfig = ''
  DefaultTimeoutStartSec=10s
  '';

  environment.systemPackages = with pkgs; [
    gparted
    parallel
    home-manager
    paper-icon-theme
    p7zip unzip # archiving
    pv
    # Extra
    distrobox # plan b
    git-annex
    git-remote-gcrypt
    appimage-wrap
    xorg.xkill
  ];

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      ConnectTimeout=5
    '';
  };
  services.shellhub-agent = {
    enable = true;
    tenantId = "c574bf33-a21a-49ef-a7a5-1d8fbd823e4e";
  };
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # Users
  users.users = {
    ${username} = {
      description = "Lucas Eduardo";
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = lib.mkDefault true;

  qt.platformTheme = lib.mkDefault "qt5ct";
}
