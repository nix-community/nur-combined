# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./home.nix
    ./secrets.nix
  ];

  hardware.amdgpu.opencl = false;

  boot.kernelPackages = pkgs.linuxPackages;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.initrd.systemd.enable = true;
  # boot.plymouth.enable = true;
  # boot.kernelParams = ["quiet"];

  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.tmp.useTmpfs = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = ["/"];
    };
  };

  networking.hostName = "hephaestus"; # Define your hostname.
  networking.domain = "alarsyo.net";

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List services that you want to enable:
  my.services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    pipewire.enable = true;

    restic-backup = {
      enable = true;
      repo = "b2:hephaestus-backup";
      passwordFile = config.age.secrets."restic-backup/hephaestus-password".path;
      environmentFile = config.age.secrets."restic-backup/hephaestus-credentials".path;

      timerConfig = {
        OnCalendar = "*-*-* 13:00:00"; # laptop only gets used during the day
      };

      paths = [
        "/home/alarsyo"
      ];
      exclude = [
        "/home/alarsyo/Downloads"

        # Rust builds using half my storage capacity
        "/home/alarsyo/**/target"
        "/home/alarsyo/work/rust/build"

        # don't backup nixpkgs
        "/home/alarsyo/work/nixpkgs"

        "/home/alarsyo/go"

        # C build crap
        "*.a"
        "*.o"
        "*.so"

        ".direnv"

        # test vms
        "*.qcow2"

        # secrets stay offline
        "/home/alarsyo/**/secrets"

        # ignore all dotfiles as .config and .cache can become quite big
        "/home/alarsyo/.*"
      ];
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  services = {
    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
    fwupd.enable = true;
    openssh.enable = true;
  };

  my.gui.enable = true;
  my.displayManager.sddm.enable = lib.mkForce false;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.General.Experimental = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.power-profiles-daemon.enable = false;

  services.autorandr = {
    enable = true;
    profiles = {
      default = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0030e42c0600000000001c0104a51f117802aa95955e598e271b5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001ab62c80f4703816403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746412d535044340018";
        };
        config = {
          "eDP-1" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
          };
        };
      };
      dock = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0030e42c0600000000001c0104a51f117802aa95955e598e271b5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001ab62c80f4703816403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746412d535044340018";
          "DP-3" = "00ffffffffffff0026cd0f610101010101190103813420782a4ca5a7554da226105054adcf0031468180818c9500950fb300a940d1c0283c80a070b023403020360006442100001a000000ff0031313230303530313030333630000000fd00324b1e4b11000a202020202020000000fc0058323438350a20202020202020008a";
          "DP-4" = "00ffffffffffff0026cd0f610101010108180103813420782a4ca5a7554da226105054adcf0031468180818c9500950fb300a940d1c0283c80a070b023403020360006442100001a000000ff0031313230303430383030333330000000fd00324b1e4b11000a202020202020000000fc0058323438350a202020202020200081";
        };
        config = {
          "eDP-1" = {
            enable = true;
            primary = false;
            position = "0x120";
            mode = "1920x1080";
          };
          "DP-3" = {
            enable = true;
            primary = true;
            position = "1920x0";
            mode = "1920x1200";
          };
          "DP-4" = {
            enable = true;
            primary = false;
            position = "3840x0";
            mode = "1920x1200";
          };
        };
      };
      dock-lid-closed = {
        fingerprint = {
          "DP-3" = "00ffffffffffff0026cd0f610101010101190103813420782a4ca5a7554da226105054adcf0031468180818c9500950fb300a940d1c0283c80a070b023403020360006442100001a000000ff0031313230303530313030333630000000fd00324b1e4b11000a202020202020000000fc0058323438350a20202020202020008a";
          "DP-4" = "00ffffffffffff0026cd0f610101010108180103813420782a4ca5a7554da226105054adcf0031468180818c9500950fb300a940d1c0283c80a070b023403020360006442100001a000000ff0031313230303430383030333330000000fd00324b1e4b11000a202020202020000000fc0058323438350a202020202020200081";
        };
        config = {
          "DP-3" = {
            enable = true;
            primary = true;
            position = "1920x0";
            mode = "1920x1200";
          };
          "DP-4" = {
            enable = true;
            primary = false;
            position = "3840x0";
            mode = "1920x1200";
          };
        };
      };
    };
  };

  systemd.services.autorandr-lid-listener = {
    wantedBy = ["multi-user.target"];
    description = "Listening for lid events to invoke autorandr";

    serviceConfig = {
      Type = "simple";
      ExecStart = let
        stdbufExe = lib.getExe' pkgs.coreutils "stdbuf";
        libinputExe = lib.getExe' pkgs.libinput "libinput";
        grepExe = lib.getExe pkgs.gnugrep;
        autorandrExe = lib.getExe pkgs.autorandr;
      in
        pkgs.writeShellScript "lid-listener.sh" ''
          ${stdbufExe} -oL ${libinputExe} debug-events |
            ${grepExe} -E --line-buffered '^[[:space:]-]+event[0-9]+[[:space:]]+SWITCH_TOGGLE[[:space:]]' |
            while read line; do
              ${pkgs.systemd}/bin/systemctl start --no-block autorandr.service
            done
        '';
      Restart = "always";
      RestartSec = "30";
    };
  };

  # Configure console keymap
  console.keyMap = "us";

  programs.light.enable = true;
}
