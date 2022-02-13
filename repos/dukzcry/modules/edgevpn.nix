{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.networking.edgevpn;
  server = cfg.enable && cfg.server;
  client = cfg.enable && !cfg.server;
  edgevpn = pkgs.nur.repos.dukzcry.edgevpn;
  sleep = "while [ ! -d /sys/devices/virtual/net/${cfg.interface} ]; do sleep 5; done";
  serviceOptions = {
    LockPersonality = true;
    DeviceAllow = "/dev/net/tun";
    PrivateIPC = true;
    PrivateMounts = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    AmbientCapabilities = "CAP_NET_ADMIN";
    CapabilityBoundingSet = "CAP_NET_ADMIN";
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @resources";
    DynamicUser = true;
    LoadCredential = "config.yaml:${cfg.config}";
  };
in {
  options.networking.edgevpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable EdgeVPN.
      '';
    };
    server = mkEnableOption ''
      server mode
    '';
    logLevel = mkOption {
      type = types.str;
      default = "info";
    };
    config = mkOption {
      type = types.str;
      default = "/etc/edgevpn/config.yaml";
    };
    interface = mkOption {
      type = types.str;
      default = "edgevpn0";
    };
    address = mkOption {
      type = types.str;
      default = "10.1.0.1/24";
    };
    dhcp = mkOption {
      type = types.bool;
      default = client;
    };
    router = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    apiPort = mkOption {
      type = types.port;
      default = 8080;
    };
    apiAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    postStart = mkOption {
      type = types.str;
      default = "";
      example = ''
        ip route add dev ${config.networking.edgevpn.interface} 10.0.0.0/24
        echo -e "nameserver 10.0.0.2\nsearch local" | resolvconf -a ${config.networking.edgevpn.interface}
      '';
    };
    preStop = mkOption {
      type = types.str;
      default = "";
      example = ''
        resolvconf -d ${config.networking.edgevpn.interface}
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ edgevpn ];
    })
    (mkIf server {
      systemd.services.edgevpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        description = "EdgeVPN server";
        path = with pkgs; [ edgevpn ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "edgevpn" ''
            edgevpn --log-level ${cfg.logLevel} --config $CREDENTIALS_DIRECTORY/config.yaml --address ${cfg.address} --api --api-listen "${cfg.apiAddress}:${toString cfg.apiPort}"
          '';
          CPUQuota = "5%";
        } // serviceOptions;
      };
    })
    (mkIf client {
      boot.kernel.sysctl."net.core.rmem_max" = mkDefault 2500000;
      systemd.services.edgevpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        description = "EdgeVPN client";
        path = with pkgs; [ edgevpn iproute2 openresolv ];
        environment = {
          HOME = "%S/edgevpn";
        };
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "edgevpn" ''
            edgevpn --log-level ${cfg.logLevel} --config $CREDENTIALS_DIRECTORY/config.yaml --address ${cfg.address} ${optionalString cfg.dhcp "--dhcp"} ${optionalString (cfg.router != null) "--router ${cfg.router}"}
          '';
          StateDirectory = "edgevpn";
          ReadWritePaths = "/var/lib/edgevpn";
        } // serviceOptions;
      };
      systemd.services.edgevpn-script = {
        after = [ "edgevpn.service" ];
        bindsTo = [ "edgevpn.service" ];
        wantedBy = [ "edgevpn.service" ];
        description = "EdgeVPN script";
        path = with pkgs; [ iproute2 openresolv ];
        serviceConfig = {
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "edgevpn-start" ''
            ${optionalString (cfg.postStart != "") sleep}
            ${cfg.postStart}
          '';
          ExecStop = pkgs.writeShellScript "edgevpn-stop" ''
            ${cfg.preStop}
          '';
        };
      };
    })
  ];
}
