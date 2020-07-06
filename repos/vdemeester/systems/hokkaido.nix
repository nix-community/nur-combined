{ pkgs, lib, ... }:

with lib;
let
  hostname = "hokkaido";
  secretPath = ../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  ip = strings.optionalString secretCondition (import secretPath).wireguard.ips."${hostname}";
  ips = lists.optionals secretCondition ([ "${ip}/24" ]);
  endpointIP = strings.optionalString secretCondition (import secretPath).wg.endpointIP;
  endpointPort = if secretCondition then (import secretPath).wg.listenPort else 0;
  endpointPublicKey = strings.optionalString secretCondition (import secretPath).wireguard.kerkouane.publicKey;
in
{
  imports = [
    ./hardware/thinkpad-x220.nix
    ./modules
    (import ../users).vincent
    (import ../users).root
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/884a3d57-f652-49b2-9c8b-f6eebd5edbeb";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C036-34B9";
    fsType = "vfat";
  };
  swapDevices = [{ device = "/dev/disk/by-uuid/e1833693-77ac-4d52-bcc7-54d082788639"; }];

  networking = {
    hostName = hostname;
  };

  boot = {
    tmpOnTmpfs = true;
    plymouth.enable = true;
  };

  hardware.bluetooth.enable = true;
  profiles = {
    syncthing.enable = true;
    home = true;
    laptop.enable = true;
    desktop.enable = lib.mkForce false;
    avahi.enable = true;
    git.enable = true;
    ssh.enable = true;
    dev.enable = true;
    yubikey.enable = true;
    virtualization = { enable = true; nested = true; };
  };
  environment.systemPackages = with pkgs; [ virtmanager ];

  networking.networkmanager = {
    enable = true;
    unmanaged = [
      "interface-name:ve-*"
      "interface-name:veth*"
      "interface-name:wg0"
      "interface-name:docker0"
      "interface-name:virbr*"
    ];
    packages = with pkgs; [ networkmanager-openvpn ];
  };

  services.xserver.enable = true;
  services.xserver.layout = "fr";
  services.xserver.xkbVariant = "bepo";
  services.xserver.xkbOptions = "grp:menu_toggle,grp_led:caps,compose:caps";
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.gnome3.chrome-gnome-shell.enable = true;
  services.gnome3.core-shell.enable = true;
  services.gnome3.core-os-services.enable = true;
  services.gnome3.core-utilities.enable = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      emojione
      feh
      fira
      fira-code
      fira-code-symbols
      fira-mono
      hasklig
      inconsolata
      iosevka
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      overpass
      symbola
      source-code-pro
      twemoji-color-font
      ubuntu_font_family
      unifont
    ];
  };

  services = {
    fprintd.enable = true;
    # FIXME re-generate hokkaido key
    /*
    wireguard = {
      enable = true;
      ips = ips;
      endpoint = endpointIP;
      endpointPort = endpointPort;
      endpointPublicKey = endpointPublicKey;
    };
    */
  };

  virtualisation.containers = {
    enable = true;
    registries = {
      search = [ "registry.fedoraproject.org" "registry.access.redhat.com" "registry.centos.org" "docker.io" "quay.io" ];
    };
    policy = {
      default = [{ type = "insecureAcceptAnything"; }];
      transports = {
        docker-daemon = {
          "" = [{ type = "insecureAcceptAnything"; }];
        };
      };
    };
  };
}
