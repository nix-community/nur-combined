{ lib, config, pkgs, nixpkgs, ... }:
let sops = config.sops.secrets;
in {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix

    ../common/sops.nix
    ../common/global-pkgs.nix
  ];

  eownerdead = {
    recommended = true;
    sound = true;
    intelGraphics = true;
    libvirtd = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.consoleMode = "0";
    };
    initrd.checkJournalingFS = false; # Takes more than half an hour.
    plymouth.enable = true;
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "slate";
    useNetworkd = true;
    firewall = {
      allowedUDPPorts = [ 51820 ]; # WireGuard
      checkReversePath = false;
    };
    # wireless.enable = true; # Conflicts with networkmanager
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ intel-media-driver ];
    };
    enableRedistributableFirmware = true; # wireless lan
    sensor.iio.enable = true;
  };

  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc ];
    };
  };

  users.mutableUsers = lib.mkForce true;
  users.users.eownerdead = {
    isNormalUser = true;
    password = "test";
    extraGroups = [ "wheel" "networkmanager" "wireshark" "libvirtd" ];
  };

  services = {
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        domain = true;
        addresses = true;
      };
    };
    xserver = {
      enable = true;
      displayManager = {
        startx.enable = true;
        gdm.enable = true;
      };
      desktopManager.gnome.enable = true;
    };
    gnome = {
      gnome-browser-connector.enable = false;
      gnome-keyring.enable = lib.mkForce false;
    };
    wacom.enable = true;
  };

  programs = {
    fuse.userAllowOther = true;
    wireshark.enable = true;
  };

  security.pam = {
    enableFscrypt = true;
    services.login.gnupg = {
      enable = true;
      noAutostart = true;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];

  fileSystems."/nix".neededForBoot = true;

  environment = {
    systemPackages = with pkgs; [ ntfs3g libwacom ];
    persistence."/nix" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      files = [ "/etc/machine-id" ];
    };
  };

  virtualisation.libvirtd.enable = true;

  system.stateVersion = "24.05";
}
