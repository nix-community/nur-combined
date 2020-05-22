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
  fileSystems."/export/gaia" = { device = "/mnt/gaia"; options = [ "bind" ]; };
  fileSystems."/export/toshito" = { device = "/mnt/toshito"; options = [ "bind" ]; };
  services = {
    nfs.server = {
      enable = true;
      exports = ''
        /export                      192.168.1.0/24(rw,fsid=0,no_subtree_check) 10.100.0.0/24(rw,fsid=0,no_subtree_check)
        /export/gaia                 192.168.1.0/24(rw,fsid=1,no_subtree_check) 10.100.0.0/24(rw,fsid=1,no_subtree_check)
        /export/toshito              192.168.1.0/24(rw,fsid=2,no_subtree_check) 10.100.0.0/24(rw,fsid=2,no_subtree_check)
      '';
    };
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
    syncthing.guiAddress = "0.0.0.0:8384";
    wireguard = {
      enable = true;
      ips = [ "${wireguard.ips.sakhalin}/24" ];
      endpoint = wg.endpointIP;
      endpointPort = wg.listenPort;
      endpointPublicKey = wireguard.kerkouane.publicKey;
    };
  };
  security.apparmor.enable = true;
  # -----------------------------------
  environment.etc."vrsync".text = ''
    /home/vincent/desktop/pictures/screenshots/ vincent@synodine.home:/volumeUSB2/usbshare/pictures/screenshots/
    /home/vincent/desktop/pictures/wallpapers/ vincent@synodine.home:/volumeUSB2/usbshare/pictures/wallpapers/
    /home/vincent/desktop/documents/ vincent@synodine.home:/volume1/documents/
    /mnt/gaia/photos/ vincent@synodine.home:/volumeUSB2/usbshare/pictures/photos/
    /mnt/gaia/music/ vincent@synodine.home:/volumeUSB2/usbshare/music/
  '';
  systemd.services.vrsync = {
    description = "vrsync - sync folders to NAS";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    unitConfig.X-StopOnRemoval = false;
    restartIfChanged = false;

    path = with pkgs; [ rsync coreutils bash openssh ];
    script = ''
      ${pkgs.vrsync}/bin/vrsync
    '';

    startAt = "hourly";
    serviceConfig = {
      Type = "oneshot";
      OnFailure = "status-email-root@%n.service";
    };
  };
  environment.etc."secrets/srht-token".text = "${token_srht}";
  # builds.sr.ht: daily builds
  systemd.services.builds-srht = {
    description = "Daily builds.sr.ht";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;

    serviceConfig = {
      Type = "oneshot";
      User = "vincent";
      OnFailure = "status-email-root@%n.service";
    };

    script = "${pkgs.my.bus}/bin/bus";

    startAt = "daily";
  };
  # ape – sync git mirrors
  systemd.services.ape = {
    description = "Ape - sync git mirrors";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;

    serviceConfig = {
      Type = "oneshot";
      User = "vincent";
      OnFailure = "status-email-root@%n.service";
    };

    path = with pkgs; [ git ];
    script = ''
      ${pkgs.my.ape}/bin/ape up /home/vincent/var/mirrors
    '';

    startAt = "hourly";
  };
  # mr -i u daily
  systemd.services.mr = {
    description = "Update configs daily";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;

    serviceConfig = {
      Type = "oneshot";
      User = "vincent";
      OnFailure = "status-email-root@%n.service";
    };

    path = with pkgs; [ git mr ];
    script = ''
      set -e
       cd /mnt/gaia/src/configs/
       mr -t run git reset --hard
       mr -t u
    '';

    startAt = "daily";
  };
}
