{ lib, pkgs, ... }:

let
  inherit (lib) mkIf versionOlder;

  identity = import ../../common/resources/identity.nix;
in
{
  imports = [
    ../../common/system.nix
    <nixos-hardware/lenovo/thinkpad/t14/amd/gen2>
    /etc/nixos/hardware-configuration.nix
    ./local/system.nix
  ];

  # Host parameters
  host = {
    name = "main";
    local = ./local;
    resources = ./resources;
  };

  # Kernel
  boot.kernelPackages = mkIf (versionOlder pkgs.linux.version "6.12") pkgs.linuxPackages_6_12;

  # Hardware
  services.fstrim.enable = true;
  services.kmonad.keyboards.default.device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  systemd.services.configure-sound-leds = rec {
    wantedBy = [ "sound.target" ];
    after = wantedBy;
    serviceConfig.Type = "oneshot";
    script = ''
      echo follow-route > /sys/class/sound/ctl-led/mic/mode
      echo off > /sys/class/sound/ctl-led/speaker/mode # follow-route pending https://discourse.nixos.org/t/20480
    '';
  };

  # Nix
  system.stateVersion = "22.05"; # Permanent

  # Filesystems
  # TODO: Set `chattr +i` on intermittent mount points
  fileSystems = {
    "/home/ak/annex" = {
      device = "closet.home.arpa:/mnt/hdd/home-ak-annex";
      fsType = "nfs";
      options = [ "noauto" "user" ];
    };

    "/home/ak/services-hdd" = {
      device = "closet.home.arpa:/mnt/hdd/services";
      fsType = "nfs";
      options = [ "noauto" "user" ];
    };

    "/home/ak/services-ssd" = {
      device = "closet.home.arpa:/mnt/ssd/services";
      fsType = "nfs";
      options = [ "noauto" "user" ];
    };
  };
  # Workaround for:
  #   - https://github.com/NixOS/nixpkgs/issues/24913
  #   - https://github.com/NixOS/nixpkgs/issues/9848
  security.wrappers = {
    "mount.nfs" = {
      source = "${pkgs.nfs-utils}/bin/mount.nfs";
      owner = "root"; group = "root"; setuid = true;
    };
    "umount.nfs" = {
      source = "${pkgs.nfs-utils}/bin/umount.nfs";
      owner = "root"; group = "root"; setuid = true;
    };
  };

  # Mouse
  services.input-remapper.enable = true;

  # Networking
  systemd.network.links = {
    "10-dock".linkConfig.Name = "dock";
    "10-jack".linkConfig.Name = "jack";
    "10-wifi".linkConfig.Name = "wifi";
  };

  # usbmuxd
  services.usbmuxd.enable = true;

  # Wireshark
  programs.wireshark.enable = true;
  users.users.${identity.username}.extraGroups = [ "usbmux" "wireshark" ];

  # Devices
  services.udev.packages = with pkgs; [ espressif-serial ];
}
