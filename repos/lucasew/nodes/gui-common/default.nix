{pkgs, lib, global, ...}:
let
  inherit (global) username;
in {
  imports = [
    ../common
    ./audio.nix
    ./gui.nix
    ./plymouth.nix
    ./networking.nix
    ./git.nix
    ./adb.nix
    ./vbox.nix
  ];
  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  systemd.extraConfig = ''
  DefaultTimeoutStartSec=10s
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gparted
    paper-icon-theme
    p7zip unzip # archiving
    pv
    # Extra
    # intel-compute-runtime # OpenCL
    distrobox # plan b
  ];

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];
  services.gvfs.enable = true;

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

  virtualisation.libvirtd.enable = true;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = lib.mkDefault true;

  # Themes
  programs.qt5ct.enable = lib.mkDefault true;

}
