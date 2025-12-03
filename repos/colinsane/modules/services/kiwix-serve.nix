{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.sane.services.kiwix-serve;
in
{
  options = {
    sane.services.kiwix-serve = {
      enable = mkEnableOption "serve .zim files (like Wikipedia archives) with kiwix";
      package = mkPackageOption pkgs "kiwix-tools" {};
      port = mkOption {
        type = types.port;
        default = 80;
        description = "Port number to listen on.";
      };
      listenAddress = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          IP address to listen on. Listens on all available addresses if unspecified.
        '';
      };
      zimPaths = mkOption {
        type = types.nonEmptyListOf (types.either types.str types.path);
        description = "ZIM file path(s)";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.kiwix-serve = let
      maybeListenAddress = lib.optionals (cfg.listenAddress != null) ["-l" cfg.listenAddress];
      args = maybeListenAddress ++ ["-p" cfg.port] ++ cfg.zimPaths;
    in {
      description = "Deliver ZIM file(s) articles via HTTP";
      serviceConfig.ExecStart = "${lib.getExe' cfg.package "kiwix-serve"} ${lib.escapeShellArgs args}";
      serviceConfig.Type = "simple";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # hardening (systemd-analyze security kiwix-serve)
      serviceConfig.LockPersonality = true;
      serviceConfig.MemoryDenyWriteExecute = true;
      serviceConfig.NoNewPrivileges = true;
      serviceConfig.PrivateDevices = true;
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      serviceConfig.PrivateUsers = true;
      serviceConfig.ProcSubset = "pid";
      serviceConfig.ProtectClock = true;
      serviceConfig.ProtectControlGroups = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectHostname = true;
      serviceConfig.ProtectKernelLogs = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectKernelTunables = true;
      serviceConfig.ProtectProc = "invisible";
      serviceConfig.ProtectSystem = "strict";
      serviceConfig.RemoveIPC = true;
      serviceConfig.ReadOnlyPaths = cfg.zimPaths;
      serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
      serviceConfig.RestrictNamespaces = true;
      serviceConfig.RestrictSUIDSGID = true;
      serviceConfig.SystemCallArchitectures = "native";
      serviceConfig.SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    };
  };
}
