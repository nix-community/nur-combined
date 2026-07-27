{
  lib,
  config,
  pkgs,
  nixpkgs,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./buildbot.nix
    ./samba.nix

    ../common/global-pkgs.nix
  ];

  eownerdead = {
    recommended = true;
    hardening = true;
    gnome = true;
    nvidia = true;
    zfs = true;
    encryptedDns = true;
    podman = true;
    fscrypt = true;
  };

  boot = {
    lanzaboote.enable = true;
    initrd.checkJournalingFS = false; # Takes more than half an hour.
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "data" ];
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "lem";
    hostId = "8556b001";
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
    interfaces.enp42s0 = {
      ipv4.addresses = [
        {
          address = "192.168.1.100";
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = "fe80::100";
          prefixLength = 64;
        }
      ];
    };
    firewall.allowedTCPPorts = [
      443 # https
    ];
    networkmanager.enable = false;
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
    printing.enable = true;
    usbmuxd.enable = true;
    hardware.openrgb.enable = true;
  };

  programs = {
    fuse.userAllowOther = true;
    wireshark.enable = true;
    dconf.profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        };
      }
    ];
  };

  security = {
    pam.sshAgentAuth.enable = true;
  };

  hardware = {
    nvidia-container-toolkit.enable = true;
    nvidia.branch = "legacy_580";
  };

  users.users.eownerdead = {
    uid = 1000;
    isNormalUser = true;
    password = "test";
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

  home-manager.users.eownerdead = import (../../. + "/users/eownerdead@lem");

  fileSystems = {
    "/nix" = {
      neededForBoot = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      glib
    ];
    persistence."/nix/persist" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib"
        "/.fscrypt"
        "/usr"
      ];
      users.eownerdead = {
        directories = [
          "persist"
          ".cache"
        ];
      };
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };

  i18n = {
    # defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc-ut ];
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];

  virtualisation.libvirtd.enable = true;

  system.stateVersion = "26.05";
}
