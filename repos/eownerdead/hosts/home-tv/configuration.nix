{ config, pkgs, nixpkgs, ... }:
let sops = config.sops.secrets;
in {
  imports = [
    (import ./disko-config.nix {
      disk = "/dev/disk/by-id/ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E5PS4JDV";
    })
    ./hardware-configuration.nix
    ../../nixos

    ../common/sops.nix
  ];

  eownerdead = {
    recommended = true;
    sound = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = with config.boot.kernelPackages; [ rtl8821au ];
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "home-tv";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };
  };

  i18n.defaultLocale = "ja_JP.UTF-8";

  hardware.opengl.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [ noto-fonts-cjk-sans noto-fonts-cjk-serif ];
  };

  users.users.noobuser = {
    isNormalUser = true;
    passwordFile = sops.noobuserPassword.path;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [ wget ];

  services = {
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        domain = true;
        addresses = true;
      };
    };
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
    };
  };

  system.stateVersion = "22.11";
}
