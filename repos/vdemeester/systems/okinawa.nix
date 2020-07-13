{ pkgs, lib, ... }:

with lib;
let
  hostname = "okinawa";
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
    ./hardware/gigabyte-brix.nix
    ./modules
    (import ../users).vincent
    (import ../users).root
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f10a12e7-d711-4bec-8246-a063de66589a";
    fsType = "ext4";
    options = [ "noatime" "discard" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/0cd32a1a-5eab-4cba-8c9c-de310645b8b1";
    fsType = "ext4";
    options = [ "noatime" "discard" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B89C-E217";
    fsType = "vfat";
  };
  fileSystems."/mnt/naha" = {
    device = "/dev/disk/by-uuid/9e2c7dda-2469-4f28-8d64-b34a609e3136";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  swapDevices = [{ device = "/dev/disk/by-uuid/de4449cb-a158-409f-9e22-32a7b2c98c86"; }];

  networking = {
    hostName = hostname;
    firewall.enable = false; # we are in safe territory :D
    bridges.br1.interfaces = [ "enp0s31f6" ];
    useDHCP = false;
    interfaces.br1 = {
      useDHCP = true;
    };
  };

  profiles = {
    home = true;
    avahi.enable = true;
    ssh.enable = true;
    syncthing.enable = true;
    virtualization = { enable = true; nested = true; listenTCP = true; };
  };

  services = {
    bind = {
      enable = true;
      forwarders = [ "8.8.8.8" "8.8.4.4" ];
      cacheNetworks = [ "192.168.1.0/24" "127.0.0.0/8" "10.100.0.0/24" ];
      zones = [
        {
          # home
          name = "home";
          slaves = [ ];
          file = pkgs.mkSecret ../secrets/db.home;
        }
        {
          # home.reverse
          name = "192.168.1.in-addr.arpa";
          slaves = [ ];
          file = pkgs.mkSecret ../secrets/db.192.168.1;
        }
        {
          # vpn
          name = "vpn";
          slaves = [ ];
          file = pkgs.mkSecret ../secrets/db.vpn;
        }
        {
          # vpn.reverse
          name = "10.100.0.in-addr.arpa";
          slaves = [ ];
          file = pkgs.mkSecret ../secrets/db.10.100.0;
        }
      ];
    };
    syncthing.guiAddress = "0.0.0.0:8384";
    wireguard = {
      enable = true;
      ips = ips;
      endpoint = endpointIP;
      endpointPort = endpointPort;
      endpointPublicKey = endpointPublicKey;
    };
  };
  security.apparmor.enable = true;
  security.pam.enableSSHAgentAuth = true;
}
