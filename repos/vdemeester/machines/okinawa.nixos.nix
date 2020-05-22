{ config, pkgs, ... }:

with import ../assets/machines.nix; {
  imports = [ ./home.nixos.nix ];
  boot = {
    cleanTmpDir = true;
  };
  networking = {
    firewall.enable = false; # we are in safe territory :D
    bridges.br1.interfaces = [ "enp0s31f6" ];
    useDHCP = false;
    interfaces.br1 = {
      useDHCP = true;
    };
  };
  profiles = {
    avahi.enable = true;
    git.enable = true;
    nix-config.buildCores = 4;
    ssh.enable = true;
    syncthing.enable = true;
    virtualization = {
      enable = true;
      nested = true;
      listenTCP = true;
    };
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
          file = ../assets/db.home;
        }
        {
          # home.reverse
          name = "192.168.1.in-addr.arpa";
          slaves = [ ];
          file = ../assets/db.192.168.1;
        }
        {
          # vpn
          name = "vpn";
          slaves = [ ];
          file = ../assets/db.vpn;
        }
        {
          # vpn.reverse
          name = "10.100.0.in-addr.arpa";
          slaves = [ ];
          file = ../assets/db.10.100.0;
        }
      ];
    };
    nix-binary-cache = {
      enable = true;
      domain = "nix.cache.home";
      aliases = [ "cache.massimo.home" "nix.okinawa.home" ];
    };
    syncthing.guiAddress = "0.0.0.0:8384";
    tarsnap = {
      enable = true;
      archives = {
        documents = {
          directories = [ "/home/vincent/desktop/documents" ];
          period = "daily";
          keyfile = "/etc/nixos/assets/tarsnap.documents.key";
        };
        org = {
          directories = [ "/home/vincent/desktop/org" ];
          period = "daily";
          keyfile = "/etc/nixos/assets/tarsnap.org.key";
        };
        sites = {
          directories = [ "/home/vincent/desktop/sites" ];
          period = "daily";
          keyfile = "/etc/nixos/assets/tarsnap.sites.key";
        };
      };
    };
    wireguard = {
      enable = true;
      ips = [ "${wireguard.ips.okinawa}/24" ];
      endpoint = wg.endpointIP;
      endpointPort = wg.listenPort;
      endpointPublicKey = wireguard.kerkouane.publicKey;
    };
  };
  security.apparmor.enable = true;
  security.pam.enableSSHAgentAuth = true;
}
