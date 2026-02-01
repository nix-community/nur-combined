{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.kvrocks;
  inherit (lib)
    mkEnableOption
    mkOption
    mkPackageOption
    mkIf
    types
    concatStringsSep
    ;
in
{
  options.services.prometheus.exporters.kvrocks = {
    enable = mkEnableOption "the prometheus kvrocks exporter";

    package = mkPackageOption pkgs "nur.repos.xyenon.kvrocks-exporter" { };

    port = mkOption {
      type = types.port;
      default = 9121;
      description = "Port to listen on.";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "";
      description = "Address to listen on.";
    };

    kvrocksAddress = mkOption {
      type = types.str;
      default = "kvrocks://localhost:6666";
      description = "Address of the kvrocks instance to scrape.";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra commandline options to pass to the kvrocks exporter.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for incoming connections.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.prometheus-kvrocks-exporter = {
      description = "Prometheus kvrocks exporter";
      documentation = [ "https://github.com/kvrocks/kvrocks_exporter" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        WorkingDirectory = /tmp;
        DynamicUser = true;
        ExecStart = ''
          ${lib.getExe cfg.package} \
            -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
            -kvrocks.addr ${cfg.kvrocksAddress} \
            ${concatStringsSep " " cfg.extraFlags}
        '';

        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ xyenon ];
}
