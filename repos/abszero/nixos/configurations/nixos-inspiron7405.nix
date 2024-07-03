{ self, lib, ... }:

let
  inherit (builtins) fromJSON readFile;
  inherit (lib) recursiveUpdate mkForce;

  proxySettings = fromJSON (readFile ./fracture-ray/proxy.json);

  mainModule = {
    abszero = {
      users.admins = [ "weathercold" ];
      services.xray = recursiveUpdate proxySettings {
        # enable = true;
        preset = "vless-tcp-xtls-reality-client";
        reality.shortId = "77b852c767077a1a";
      };
    };

    disko.devices.disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "esp";
            size = "512M";
            type = "EF00"; # EFI system partition
            priority = 0;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "noatime"
                "noauto"
                "nodev" # block device files for security
                "nofail"
                "nosuid" # block suid and sgid bits for security
                "x-systemd.automount"
                "x-systemd.idle-timeout=10min"
              ];
            };
          };
          data = {
            label = "data";
            size = "250G";
            priority = 1;
            content = {
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/home";
              mountOptions = [
                "noatime"
                "nodev"
                "nosuid"
              ];
            };
          };
          nixos = {
            label = "nixos";
            end = "-16G";
            priority = 2;
            content = {
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
          swap = {
            label = "swap";
            size = "100%";
            content = {
              type = "swap";
              discardPolicy = "pages";
              resumeDevice = true;
            };
          };
        };
      };
    };
    # FIXME
    swapDevices = mkForce [];

    users.users = rec {
      weathercold = {
        description = "Weathercold";
        isNormalUser = true;
        hashedPassword = "$6$QOTimFq0v8u6oN.I$.m0BQc/tC6/8nluwwQT7AmkbJbfNoh2PnO9biVL4wgWA22zlb/0HheieexWgISAB67r/7floX3bQpZrUjZv9v.";
      };
      root = {
        inherit (weathercold) hashedPassword;
      };
    };

    specialisation.plasma6-latte-pink.configuration = {
      abszero.services.desktopManager.plasma6.enable = true;
      catppuccin.accent = "pink";
    };
  };

  hyprland-latte-pink = { config, lib, ... }:
  {
    # Take advantage of the fact that `config.specialisation` is unset on
    # specialisations to disable inheritance of this module
    config = lib.mkIf (config.specialisation != { }) {
      abszero.wayland.windowManager.hyprland.enable = true;
      catppuccin.accent = "pink";
    };
  };
in

{
  imports = [ ./_options.nix ];

  nixosConfigurations.nixos-inspiron7405 = {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      profiles-full
      hardware-inspiron-7405
      catppuccin-sddm
      mainModule
      # hyprland-latte-pink is the default specialisation
      hyprland-latte-pink
    ];
  };
}
