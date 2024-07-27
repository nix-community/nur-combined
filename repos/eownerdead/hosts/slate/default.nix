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
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.consoleMode = "0";
    };
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

  users.users.eownerdead = {
    isNormalUser = true;
    password = "test";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services = {
    homed.enable = true;
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
  };

  environment.systemPackages = with pkgs; [ ntfs3g ];

  system.stateVersion = "24.05";
}
