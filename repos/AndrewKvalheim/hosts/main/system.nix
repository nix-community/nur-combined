{ lib, pkgs, ... }:

let
  inherit (lib) getExe' throwIf versionAtLeast;

  identity = import ../../library/identity.lib.nix { inherit lib; };
in
{
  imports = [
    ../../system.nix
    <nixos-hardware/lenovo/thinkpad/p16s/amd/gen2>
    /etc/nixos/hardware-configuration.nix
    ./system.local.nix
  ];

  # Host parameters
  host = {
    name = "main";
    dir = ./.;
    metrics = rec{
      cpuCores = 16;
      cpuMarkMulti = 24435;
      cpuMarkSingle = 3680;
      displayDensity = 1.75;
      displayWidth = 3840;
      ramGb = 64 - vramGb;
      vramGb = 8;
    };
  };

  # Workaround for drm/amd#3787, drm/amd#3925, drm/amd#4141
  boot.kernelPackages = throwIf (versionAtLeast pkgs.linux.version "6.18") "Kernel no longer requires override" pkgs.linuxPackages_6_18;
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" ];

  # Hardware
  systemd.services.configure-sound-leds = rec {
    wantedBy = [ "sound.target" ];
    after = wantedBy;
    serviceConfig.Type = "oneshot";
    script = ''
      echo follow-route > /sys/class/sound/ctl-led/mic/mode
      echo off > /sys/class/sound/ctl-led/speaker/mode # follow-route pending https://discourse.nixos.org/t/20480
    '';
  };

  # Keyboard
  services.udev.extraHwdb = ''
    # From:
    #   角 ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #    ↹  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #     ░  ░  ░  ░  ░  g  ░  ░  ░  ░  ░  ░  ░  ░
    #      ⇧  ░  ░  c  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #      ⎈  ❖  ⎇  無    ␣  換 仮 ⇮  ⎙  ░
    # To:
    #   ⎙  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #    g  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #     ░  ░  ░  ░  ░  ↵  ░  ░  ░  ░  ░  ░  ░  ░
    #      c  ░  ░  ␣  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #      ❖  ⎇  ⎈  ↹     ⇧  ⇧  ⇮  ⎇  ❖  ░
    evdev:name:AT Translated Set 2 keyboard:*
      KEYBOARD_KEY_29=sysrq
      KEYBOARD_KEY_0f=g
      KEYBOARD_KEY_22=enter
      KEYBOARD_KEY_2a=c
      KEYBOARD_KEY_2e=space
      KEYBOARD_KEY_1d=leftmeta
      KEYBOARD_KEY_db=leftalt
      KEYBOARD_KEY_38=leftctrl
      KEYBOARD_KEY_7b=tab
      KEYBOARD_KEY_39=leftshift
      KEYBOARD_KEY_79=rightshift
      KEYBOARD_KEY_70=rightalt
      KEYBOARD_KEY_b8=leftalt
      KEYBOARD_KEY_b7=rightmeta
  '';
  services.kmonad.keyboards.default.device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

  # Nix
  system.stateVersion = "22.05"; # Permanent

  # Filesystems
  # TODO: Set `chattr +i` on intermittent mount points
  fileSystems = let base = { fsType = "nfs4"; options = [ "noauto" "nconnect=4" "noatime" "user" ]; }; in {
    "/home/ak/annex" = base // { device = "closet.home.arpa:/mnt/hdd/home-ak-annex"; };
    "/home/ak/satellite" = base // { device = "satellite.home.arpa:/home/ak/src/configuration"; };
    "/home/ak/services" = base // { device = "closet.home.arpa:/mnt/hdd/services"; };
  };
  security.wrappers = with pkgs; {
    # Workaround for NixOS/nixpkgs#24913, NixOS/nixpkgs#9848
    "mount.nfs4" = { source = getExe' nfs-utils "mount.nfs4"; owner = "root"; group = "root"; setuid = true; };
    "umount.nfs4" = { source = getExe' nfs-utils "umount.nfs4"; owner = "root"; group = "root"; setuid = true; };
  };
  systemd.automounts = map
    (path: {
      wantedBy = [ "remote-fs.target" ];
      automountConfig.TimeoutIdleSec = 30;
      where = path;
    }) [
    "/home/ak/annex"
    "/home/ak/satellite"
    "/home/ak/services"
  ];

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

  # Android Debug Bridge (ADB)
  programs.adb.enable = true;

  # Devices
  services.udev.packages = with pkgs; [ espressif-serial ];

  # Permissions
  users.users.${identity.username}.extraGroups = [ "adbusers" "usbmux" "wireshark" ];
}
