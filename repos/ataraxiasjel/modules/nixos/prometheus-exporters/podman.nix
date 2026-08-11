{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.prometheus.exporters.${name};
  name = "podman";
  port = 9882;
in
{
  options.services.prometheus.exporters.${name} = {
    enable = mkEnableOption (lib.mdDoc "the prometheus ${name} exporter");
    port = mkOption {
      type = types.port;
      default = port;
      description = lib.mdDoc ''
        Port to listen on.
      '';
    };
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = lib.mdDoc ''
        Address to listen on.
      '';
    };
    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = lib.mdDoc ''
        Extra commandline options to pass to the ${name} exporter.
      '';
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Open port in firewall for incoming connections.
      '';
    };
    firewallFilter = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = literalExpression ''
        "-i eth0 -p tcp -m tcp --dport ${toString port}"
      '';
      description = lib.mdDoc ''
        Specify a filter for iptables to use when
        {option}`services.prometheus.exporters.${name}.openFirewall`
        is true. It is used as `ip46tables -I nixos-fw firewallFilter -j nixos-fw-accept`.
      '';
    };
    user = mkOption {
      type = types.str;
      default = "root";
      description = lib.mdDoc ''
        User name under which the ${name} exporter shall be run.
      '';
    };
    group = mkOption {
      type = types.str;
      default = "root";
      description = lib.mdDoc ''
        Group under which the ${name} exporter shall be run.
      '';
    };
    enabledCollectors = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "pod" ];
      description = lib.mdDoc ''
        Collectors to enable. The collectors listed here are enabled in addition to the default ones.
      '';
    };
  };
  config =
    let
      containersStorage = config.virtualisation.containers.storage.settings.storage.graphroot;
    in
    mkIf cfg.enable {
      virtualisation.podman.enable = true;
      virtualisation.containers.containersConf.settings = {
        engine.helper_binaries_dir = [ "${config.virtualisation.podman.package}/libexec/podman" ];
      };

      networking.firewall.extraCommands = mkIf cfg.openFirewall (concatStrings [
        "ip46tables -A nixos-fw ${cfg.firewallFilter} "
        "-m comment --comment ${name}-exporter -j nixos-fw-accept"
      ]);

      systemd.services."prometheus-${name}-exporter" = {
        description = "Prometheus ${name} exporter service";
        wantedBy = [ "multi-user.target" ];
        wants = [ "podman.socket" ];
        after = [
          "podman.socket"
          "network.target"
        ];
        path = with pkgs; [
          runc
          crun
          conmon
        ];
        environment.HOME = "/tmp";
        serviceConfig.ExecStart = ''
          ${pkgs.prometheus-podman-exporter}/bin/prometheus-podman-exporter \
            ${concatMapStringsSep " " (x: "--collector." + x) cfg.enabledCollectors} \
            --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
            ${concatStringsSep " " cfg.extraFlags}
        '';
        serviceConfig.ExecReload = "${pkgs.procps}/bin/kill -HUP $MAINPID";
        serviceConfig.TimeoutStopSec = "20s";
        serviceConfig.SendSIGKILL = "no";
        serviceConfig.WorkingDirectory = "/tmp";

        serviceConfig.Restart = "always";
        serviceConfig.PrivateTmp = true;
        serviceConfig.DynamicUser = false;
        serviceConfig.User = cfg.user;
        serviceConfig.Group = cfg.group;
        # Hardening
        serviceConfig.AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
        serviceConfig.CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
        serviceConfig.DeviceAllow = [ "" ];
        serviceConfig.LockPersonality = true;
        serviceConfig.MemoryDenyWriteExecute = true;
        serviceConfig.NoNewPrivileges = true;
        serviceConfig.PrivateDevices = true;
        serviceConfig.ProtectClock = true;
        serviceConfig.ProtectControlGroups = true;
        serviceConfig.ProtectHome = true;
        serviceConfig.ProtectHostname = true;
        serviceConfig.ProtectKernelLogs = true;
        serviceConfig.ProtectKernelModules = true;
        serviceConfig.ProtectKernelTunables = true;
        serviceConfig.ProtectSystem = "strict";
        serviceConfig.ReadWritePaths = [ containersStorage ];
        serviceConfig.RemoveIPC = true;
        serviceConfig.RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        serviceConfig.RestrictNamespaces = true;
        serviceConfig.RestrictRealtime = true;
        serviceConfig.RestrictSUIDSGID = true;
        serviceConfig.SystemCallArchitectures = "native";
        serviceConfig.UMask = "0077";
      };
    };
}
