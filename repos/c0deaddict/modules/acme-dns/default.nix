{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.acme-dns;

  format = pkgs.formats.toml { };

  configFile = format.generate "acme-dns.cfg" cfg.settings;

in
{

  ### Interface

  options = {
    services.acme-dns = {
      enable = mkEnableOption (lib.mdDoc "ACME DNS server");

      package = mkOption {
        type = types.package;
        default = pkgs.acme-dns;
      };

      settings = mkOption {
        default = { };
        type = format.type;
      };
    };
  };

  ### Implementation

  config = mkIf cfg.enable {
    systemd.services.acme-dns = {
      description = "ACME DNS server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";

        ExecStart = "${cfg.package}/bin/acme-dns -c ${configFile}";
        Restart = "on-failure";

        DynamicUser = true;
        StateDirectory = "acme-dns";
        StateDirectoryMode = "0750";

        # Hardening
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadOnlyPaths = [ ];
        ReadWritePaths = [ "/var/lib/acme-dns" ];
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        UMask = "0077";
      };
    };
  };

}
