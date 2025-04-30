{ config, lib, ... }:

let
  inherit (builtins) attrNames length mapAttrs;
  inherit (config) host;
  inherit (config.services) syncthing;
  inherit (lib) mapAttrsToList mkForce mkIf mkOption;
  inherit (lib.types) attrsOf listOf str submodule;

  guiIp = "127.0.0.100";
in
{
  options.host.syncthing = {
    peers = mkOption { type = attrsOf str; default = [ ]; };
    shares = mkOption {
      type = attrsOf (submodule {
        options = {
          path = mkOption { type = str; };
          peers = mkOption { type = listOf str; };
        };
      });
      default = { };
    };
  };

  config = mkIf (length (attrNames host.syncthing.shares) > 0) {
    networking.firewall.interfaces.wg0.allowedUDPPorts = [ 22000 ];

    networking.interfaces.lo.ipv4.routes = [{
      type = "local";
      address = guiIp;
      prefixLength = 32;
      options = { table = "local"; protocol = "kernel"; scope = "host"; src = guiIp; };
    }];

    services.syncthing = {
      enable = true;

      guiAddress = "${guiIp}:80"; # Used by syncthing-init.service

      settings = {
        options = {
          autoUpgradeIntervalH = 0 /* disabled */;
          globalAnnounceEnabled = false;
          listenAddresses = [ "quic://${host.wireguard.ip}:22000" ];
          localAnnounceEnabled = false;
          urAccepted = -1 /* declined */;
        };

        devices = mapAttrs
          (h: id: {
            inherit id;
            addresses = [ "quic://${host.wireguard.peers.${h}.ip}" ];
            compression = "always";
          })
          host.syncthing.peers;

        folders = mapAttrs
          (id: share: {
            blockPullOrder = "inOrder";
            copyOwnershipFromParent = true;
            copyRangeMethod = "copy_file_range";
            devices = share.peers;
            order = "oldestFirst";
            path = "/mnt/${id}";
            syncOwnership = true;
          })
          host.syncthing.shares;
      };
    };

    systemd.services.syncthing = {
      onFailure = [ "alert@%N.service" ];

      confinement.enable = true;

      serviceConfig = rec {
        RuntimeDirectory = "%N";
        BindReadOnlyPaths = [ "/etc/group" "/etc/passwd" ];
        BindPaths = [ syncthing.dataDir ]
          ++ mapAttrsToList (id: share: "${share.path}:/mnt/${id}") host.syncthing.shares;

        AmbientCapabilities = [
          "CAP_NET_BIND_SERVICE" # TCP 80

          # Pending NixOS/nixpkgs#338485
          "CAP_CHOWN"
          "CAP_DAC_OVERRIDE"
          "CAP_FOWNER"
        ];
        CapabilityBoundingSet = /* module ++ */ AmbientCapabilities;
        DeviceAllow = "";
        DevicePolicy = "closed";
        IPAddressAllow = [ guiIp ]
          ++ mapAttrsToList (h: _: host.wireguard.peers.${h}.ip) host.syncthing.peers;
        IPAddressDeny = "any";
        PrivateUsers = mkForce false;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectHome = "tmpfs";
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_INET" ];

        Nice = 10;
        IOSchedulingClass = "idle";
      };
    };

    systemd.services.syncthing-init.onFailure = [ "alert@%N.service" ];
  };
}
