{
  lib,
  config,
  pkgs,
  nixpkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global-pkgs.nix
  ];

  eownerdead = {
    recommended = true;
    gnome = true;
    intelGraphics = true;
    libvirtd = true;
    fscrypt = true;
  };

  boot = {
    lanzaboote.enable = true;
    initrd.checkJournalingFS = false; # Takes more than half an hour.
    plymouth.enable = true;
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "slate";
    firewall = {
      allowedTCPPorts = [ 9300 ]; # GNOME Packet
      trustedInterfaces = [ "virbr0" ];
    };
    # wireless.enable = true; # Conflicts with networkmanager
  };

  hardware = {
    enableRedistributableFirmware = true; # wireless lan
    sensor.iio.enable = true;
  };

  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc-ut ];
    };
  };

  users.users.eownerdead = {
    isNormalUser = true;
    password = "test";
    extraGroups = [
      "wheel"
      "networkmanager"
      "wireshark"
      "libvirtd"
    ];
  };

  home-manager.users.eownerdead = import (../../. + "/users/eownerdead@slate");

  services = {
    printing.enable = true;
    fprintd.enable = true;
    # wacom.enable = true;
  };

  programs = {
    fuse.userAllowOther = true;
    wireshark.enable = true;
  };

  security = {
    pam = {
      enableFscrypt = true;
      services.login.gnupg = {
        enable = true;
        noAutostart = true;
      };
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
    fontDir.enable = true;
    fontconfig.localConf = ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
        <dir>/mnt/win/Windows/Fonts</dir>
      </fontconfig>
    '';
    fontconfig.defaultFonts = {
      serif = [
        "DejaVu Serif"
        "Noto Serif CJK JP"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans CJK JP"
      ];
    };
  };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=1G"
        "mode=755"
      ];
    };
    "/nix" = {
      options = [
        "noatime"
        "gc_merge"
        "inline_xattr"
        "inline_data"
        "inline_dentry"
        "flush_merge"
        "compress_algorithm=zstd:6"
        "compress_chksum"
        "compress_cache"
        "inlinecrypt"
        "atgc"
        "age_extent_cache"
      ];
      neededForBoot = true;
    };
    "/mnt/win" = {
      options = [
        "ro"
        "noatime"
        "showmeta"
        "prealloc"
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      ntfs3g
      libwacom
      glib
    ];
    persistence."/nix" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/.fscrypt"
        "/usr"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      users.eownerdead = {
        directories = [
          "persist"
          ".cache"
        ];
      };
    };
  };

  virtualisation.libvirtd.enable = true;

  system.stateVersion = "26.05";
}
