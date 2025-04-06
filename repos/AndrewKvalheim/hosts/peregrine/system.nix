{ lib, pkgs, ... }:

let
  inherit (lib) getExe';
in
{
  imports = [
    ../../common/system.nix
    <nixos-hardware/common/cpu/intel/alder-lake> # TODO: Contribute P8
    /etc/nixos/hardware-configuration.nix
    ./local/system.nix
  ];

  # Host parameters
  host = {
    name = "peregrine";
    local = ./local;
    resources = ./resources;
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_p8;
  boot.consoleLogLevel = 3 /* error */; # Hide https://bbs.archlinux.org/viewtopic.php?id=300997

  # Display
  boot.kernelParams = [ "fbcon=rotate:1" "video=DSI-1:panel_orientation=right_side_up" ];

  # Keyboard
  services.udev.extraHwdb = ''
    # From:
    #              ░                     [   ]   \    -    =
    #         ░    ░    ░    ░   ░   ░   ░   ░   ░    ░    ░    ⌫
    #         q    w    e    r    t    y    u    i    o    p    ⌦
    #     ░    ░    ░    ░    ░    g    ░    ░    ░    ░    ↵
    #      ⇧    ░    ░    ░    ░    ░    ░    m    ░   ░ ░  ⇧
    #       ⎈    ❖    ⎇                  ␣    ░    ⎈   ;    '
    #                                            ≣
    # To:
    #              ░                     -   =   ¥    ]    \
    #         ░    ░    ░    ░   ░   ░   ░   ░   ░    ░    ░    [
    #         g    q    w    e    r    t    y    u    i    o    p
    #     ░    ░    ░    ░    ░    ↵    ░    ░    ░    ░    ;
    #      m    ░    ░    ░    ░    ░    ░    ␣    ░   ░ ░  '
    #       ⎇    ⎈    ❖                  ⇧    ░    ⎙   ❖    ろ
    #                                            ★
    evdev:name:SINO WEALTH USB TOUCHPAD KEYBOARD:*
      KEYBOARD_KEY_7002f=minus
      KEYBOARD_KEY_70030=equal
      KEYBOARD_KEY_70031=yen
      KEYBOARD_KEY_7002d=rightbrace
      KEYBOARD_KEY_7002e=backslash
      KEYBOARD_KEY_7002a=leftbrace
      KEYBOARD_KEY_70014=g
      KEYBOARD_KEY_7001a=q
      KEYBOARD_KEY_70008=w
      KEYBOARD_KEY_70015=e
      KEYBOARD_KEY_70017=r
      KEYBOARD_KEY_7001c=t
      KEYBOARD_KEY_70018=y
      KEYBOARD_KEY_7000c=u
      KEYBOARD_KEY_70012=i
      KEYBOARD_KEY_70013=o
      KEYBOARD_KEY_7004c=p
      KEYBOARD_KEY_7000a=enter
      KEYBOARD_KEY_70028=semicolon
      KEYBOARD_KEY_700e1=m
      KEYBOARD_KEY_70010=space
      KEYBOARD_KEY_700e5=apostrophe
      KEYBOARD_KEY_700e0=leftalt
      KEYBOARD_KEY_700e3=leftctrl
      KEYBOARD_KEY_700e2=leftmeta
      KEYBOARD_KEY_7002c=leftshift
      KEYBOARD_KEY_700e4=sysrq
      KEYBOARD_KEY_70033=rightmeta
      KEYBOARD_KEY_70034=ro
      KEYBOARD_KEY_70065=favorites
  '';
  services.kmonad.keyboards.default.device = "/dev/input/by-id/usb-SINO_WEALTH_USB_TOUCHPAD_KEYBOARD-event-if00";

  # Nix
  system.stateVersion = "24.11"; # Permanent

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

  # Networking
  systemd.network.links = {
    "10-jack".linkConfig.Name = "jack";
    "10-wifi".linkConfig.Name = "wifi";
  };
}
