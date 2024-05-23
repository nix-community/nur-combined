{ self, lib, ... }:

let
  inherit (builtins) fromJSON readFile;
  inherit (lib) recursiveUpdate;

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

    catppuccin.accent = "pink";

    boot = {
      kernelParams = [ "resume_offset=4929334" ];
      resumeDevice = "/dev/disk/by-label/nixos";
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=root"
          "noatime"
          "compress-force=zstd"
        ];
      };
      "/boot" = {
        device = "/dev/disk/by-label/esp";
        fsType = "vfat";
        options = [
          "nofail"
          "noauto"
          "noatime"
          "x-systemd.automount"
          "x-systemd.idle-timeout=10min"
        ];
      };
      "/home" = {
        device = "/dev/disk/by-label/data";
        fsType = "btrfs";
        options = [
          "subvol=home"
          "noatime"
          "compress-force=zstd"
        ];
      };
      "/nix" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=nix"
          "noatime"
          "compress-force=zstd"
        ];
      };
      "/swap" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=swap"
          "noatime"
        ];
      };
    };
    swapDevices = [ { device = "/swap/swapfile"; } ];

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

    services.btrfs.autoScrub.enable = true;
  };
in

{
  imports = [ ./_options.nix ];

  nixosConfigurations.nixos-inspiron7405 = {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      profiles-full
      hardware-inspiron-7405
      catppuccin-catppuccin
      mainModule
    ];
  };
}
