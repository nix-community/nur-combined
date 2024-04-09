{ config, pkgs, nixpkgs, inputs, ... }:
let sops = config.sops.secrets;
in {
  imports = [
    ./hardware-configuration.nix

    ../common/sops.nix
    ../common/global-pkgs.nix
    ../common/hardened.nix

    ./nginx.nix
    ./actions.nix
    ./libretranslate.nix
  ];

  sops.defaultSopsFile = ./sops.yaml;

  eownerdead = {
    recommended = true;
    nvidia = true;
    sound = true;
    zfs = true;
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
      };
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "btrfs" "exfat" "ext4" "ntfs" "vfat" "xfs" "zfs" ];
    kernelModules = [ "btrfs" "exfat" "ext4" "ntfs3" "vfat" "xfs" ];
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "nixos";
    hostId = "8556b001";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "9.9.9.9" "149.112.112.112" ];
    defaultGateway = {
      interface = "enp42s0";
      address = "192.168.1.1";
    };
    defaultGateway6 = {
      interface = "enp42s0";
      address = "fe80::1";
    };
    interfaces.enp42s0.ipv4 = {
      addresses = [{
        address = "192.168.1.100";
        prefixLength = 24;
      }];
    };
    firewall.allowedTCPPorts = [
      443 # https
    ];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
    printing.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
    };
    snowflake-proxy.enable = true;
    textgen = {
      enable = true;
      settings = { dark_theme = false; };
      extraArgs = [ "--api" ];
    };
  };

  programs.wireshark.enable = true;

  hardware.opengl.enable = true;

  users.users.noobuser = {
    isNormalUser = true;
    hashedPasswordFile = sops.noobuserPassword.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY59B9RvaQW314iSWSIi9EWO+J6aNWImXoeZyLwQzSC openpgp:0x5CA54D63"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5bTpOOFrIF3IqOZqUsJUTziQduAzXOpNfsFM4Yat8F a@DESKTOP-R9IE7K2"
    ];
    extraGroups = [ "wheel" "wireshark" "adbusers" ];
  };

  environment = {
    systemPackages = with pkgs; [ wget home-manager ntfs3g cachix unzip glib ];
  };

  i18n.defaultLocale = "ja_JP.UTF-8";

  fonts.fonts = with pkgs; [ noto-fonts-cjk-sans noto-fonts-cjk-serif ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      enableNvidia = true;
    };
    oci-containers.backend = "podman";
    libvirtd.enable = true;
    waydroid.enable = true;
  };

  system = {
    stateVersion = "23.11";
    autoUpgrade = {
      enable = true;
      flake = "git+https://codeberg.org/eownerdead/flakes?ref=dev/nixos";
    };
  };
}
