{
  config,
  pkgs,
  nixpkgs,
  inputs,
  ...
}:
let
  sops = config.sops.secrets;
in
{
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
    supportedFilesystems = [
      "btrfs"
      "exfat"
      "ext4"
      "ntfs"
      "vfat"
      "xfs"
      "zfs"
    ];
    kernelModules = [
      "btrfs"
      "exfat"
      "ext4"
      "ntfs3"
      "vfat"
      "xfs"
    ];
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "nixos";
    hostId = "8556b001";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];
    defaultGateway = {
      interface = "enp42s0";
      address = "192.168.1.1";
    };
    defaultGateway6 = {
      interface = "enp42s0";
      address = "fe80::1";
    };
    interfaces.enp42s0.ipv4 = {
      addresses = [
        {
          address = "192.168.1.100";
          prefixLength = 24;
        }
      ];
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
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
    printing.enable = true;
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager = {
        startx.enable = true;
        gdm.enable = true;
      };
    };
    gnome = {
      gnome-browser-connector.enable = false;
      gnome-keyring.enable = false;
    };
    snowflake-proxy.enable = true;
    kubo = {
      enable = true;
      enableGC = true;
      autoMount = true;
      localDiscovery = true;
    };
    cloudflared = {
      enable = true;
      tunnels."92e4660b-3691-4157-a217-b288c6e45e62" = {
        credentialsFile = "/var/lib/92e4660b-3691-4157-a217-b288c6e45e62.json";
        default = "http_status:404";
        ingress = {
          "nixos.eownerdead.dedyn.io" = "ssh://localhost:22";
        };
      };
    };
    usbmuxd.enable = true;
    hardware.openrgb.enable = true;
  };

  programs.wireshark.enable = true;

  hardware = {
    opengl.enable = true;
    nvidia-container-toolkit.enable = true;
  };

  users.users.noobuser = {
    isNormalUser = true;
    hashedPasswordFile = sops.noobuserPassword.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe9DvgMExABKFYs71DimswPTn8S8Im7shTJMAFx/Jny openpgp:0x2EDEF31C"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5bTpOOFrIF3IqOZqUsJUTziQduAzXOpNfsFM4Yat8F a@DESKTOP-R9IE7K2"
    ];
    extraGroups = [
      "wheel"
      "wireshark"
      "adbusers"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      home-manager
      ntfs3g
      cachix
      unzip
      glib
    ];
  };

  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    inputMethod.ibus = {
      enabled = true;
      engines = with pkgs.ibus-engines; [ mozc ];
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
    };
    oci-containers.backend = "podman";
    libvirtd.enable = true;
  };

  system.stateVersion = "24.05";
}
