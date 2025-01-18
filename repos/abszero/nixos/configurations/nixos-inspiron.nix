{ inputs, lib, ... }:

let
  inherit (builtins)
    fromJSON
    readDir
    readFile
    warn
    ;
  inherit (lib) recursiveUpdate;

  proxySettings =
    if (readDir ./fracture-ray ? "proxy.json") then
      fromJSON (readFile ./fracture-ray/proxy.json)
    else
      warn "proxy.json is hidden, configuration is incomplete" { };

  modules = {
    main = {
      imports = [
        # hyprland-latte-pink is the default specialisation
        # Take advantage of the fact that `config.specialisation` is unset on
        # specialisations to disable inheritance of this module
        ({ config, lib, ... }: lib.mkIf (config.specialisation != { }) modules.hyprland-latte-pink)
      ];

      abszero = {
        profiles.full.enable = true;
        users.admins = [ "weathercold" ];
        hardware.dell-inspiron-7405.enable = true;
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
                extraArgs = [ "--compression=zstd" ];
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
                extraArgs = [ "--compression=zstd" ];
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

      specialisation.plasma6-latte-pink.configuration = modules.plasma6-latte-pink;
    };

    hyprland-latte-pink = {
      abszero = {
        wayland.windowManager.hyprland.enable = true;
        services.displayManager.tuigreet.enable = true;
      };

      catppuccin.accent = "pink";
    };

    plasma6-latte-pink = {
      abszero = {
        services = {
          displayManager.sddm.enable = true;
          desktopManager.plasma6.enable = true;
        };
        themes.catppuccin.sddm.enable = true;
      };

      catppuccin.accent = "pink";
    };
  };
in

{
  imports = [ ./_options.nix ];

  nixosConfigurations.nixos-inspiron = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.dell-inspiron-7405
      modules.main
    ];
  };
}
