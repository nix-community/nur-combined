{ lib, pkgs, ... }:

let
  inherit (lib) getExe' mkIf versionOlder;

  identity = import ../../common/resources/identity.nix;
in
{
  imports = [
    ../../common/system.nix
    <nixos-hardware/lenovo/thinkpad/p16s/amd/gen2>
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
  fileSystems = let base = { fsType = "nfs"; options = [ "noauto" "user" ]; }; in {
    "/home/ak/annex" = base // { device = "closet.home.arpa:/mnt/hdd/home-ak-annex"; };
    "/home/ak/services-hdd" = base // { device = "closet.home.arpa:/mnt/hdd/services"; };
    "/home/ak/services-ssd" = base // { device = "closet.home.arpa:/mnt/ssd/services"; };
  };
  security.wrappers = with pkgs; {
    # Workaround for NixOS/nixpkgs#24913, NixOS/nixpkgs#9848
    "mount.nfs" = { source = getExe' nfs-utils "mount.nfs"; owner = "root"; group = "root"; setuid = true; };
    "umount.nfs" = { source = getExe' nfs-utils "umount.nfs"; owner = "root"; group = "root"; setuid = true; };
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

  # LLM
  nixpkgs.config.rocmSupport = true;
  services.ollama = { enable = true; rocmOverrideGfx = "11.0.2"; /* Pending support for gfx1103 */ };
  systemd.services.ollama.serviceConfig.Nice = 5;
}
