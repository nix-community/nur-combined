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

  mainModule =
    { pkgs, ... }:
    {
      abszero = {
        profiles.desktop.enable = true;

        zramSwap.enable = true;

        users.admins = [ "weathercold" ];

        hardware.framework-desktop-amd-ai-max-300-series.enable = true;

        services = {
          displayManager.tuigreet.enable = true;
          hardware.framework_rgbafan = {
            enable = true;
            mode = "smoothspin";
            # Blue-white gradient
            colors = [
              "eef3fb"
              "dee6f7"
              "cddaf3"
              "bdceef"
              "acc1ec"
              "9cb5e8"
              "8ba9e4"
              "7b9de0"
              "6a90dc"
              "5a84d8"
              "4978d4"
              "396bd0"
              "2f61c6"
              "234995"
              "1f4184"
              "173163"
              "132853"
              "102042"
              "0a152b"
              "102042"
              "132853"
              "173163"
              "1f4184"
              "234995"
              "2f61c6"
              "396bd0"
              "4978d4"
              "5a84d8"
              "6a90dc"
              "7b9de0"
              "8ba9e4"
              "9cb5e8"
              "acc1ec"
              "bdceef"
              "cddaf3"
              "dee6f7"
            ];
            nLeds = 36;
          };
          openssh.enable = true;
          xray = recursiveUpdate proxySettings {
            # enable = true;
            preset = "vless-tcp-xtls-reality-client";
            reality.shortId = "77b852c767077a1a";
          };
        };

        programs.niri.enable = true;

        themes.catppuccin = {
          enable = true;
          fonts.enable = true;
          plymouth.enable = true;
        };
      };

      disko.devices.disk.nvme0n1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S7LANJ0Y429484H";
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
                  "umask=0077" # rwx------
                  "x-systemd.automount"
                  "x-systemd.idle-timeout=10min"
                ];
              };
            };
            data = {
              label = "data";
              size = "700G";
              priority = 1;
              content = {
                type = "btrfs";
                subvolumes = {
                  home = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress-force=zstd"
                      "noatime"
                      "nodev"
                      "nosuid"
                    ];
                  };
                };
              };
            };
            nixos = {
              label = "nixos";
              size = "100%";
              priority = 2;
              content = {
                type = "btrfs";
                subvolumes = {
                  root = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress-force=zstd"
                      "noatime"
                    ];
                  };
                  nix = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };

      catppuccin.accent = "pink";

      nixpkgs.config.rocmSupport = true; # For ComfyUI

      users.users = rec {
        weathercold = {
          description = "Weathercold";
          isNormalUser = true;
          hashedPassword = "$6$QOTimFq0v8u6oN.I$.m0BQc/tC6/8nluwwQT7AmkbJbfNoh2PnO9biVL4wgWA22zlb/0HheieexWgISAB67r/7floX3bQpZrUjZv9v.";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNpRiJBIfsEXVgHQ7NuJ7uk9TEEq97EG6bISYZp+Zt+ Weathercold"
          ];
        };
        root = {
          inherit (weathercold) hashedPassword;
        };
      };

      services = {
        comfyui = {
          enable = true;
          acceleration = "rocm";
          extraFlags = [
            "--highvram"
            "--preview-method=auto"
          ];
          customNodes = [
            pkgs.comfyui-autocomplete-plus
            pkgs.comfyuiPackages.comfyui-res4lyf
            pkgs.comfyuiPackages.comfyui-rgthree
            pkgs.comfyui-teacache
          ];
        };
        ollama = {
          enable = true;
          package = pkgs.ollama-vulkan;
        };
        sillytavern.enable = true;
      };
    };
in

{
  imports = [ ./_options.nix ];

  nixosConfigurations.nixos-fwdesktop = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series
      mainModule
    ];
  };
}
