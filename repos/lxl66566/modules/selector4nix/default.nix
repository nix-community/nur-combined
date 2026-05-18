{
  config,
  lib,
  pkgs,
  ...
}:

let
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/selector4nix { };
  common = import ./module-common.nix {
    inherit lib pkgs;
    packageDefault = defaultPackage;
  };
  cfg = config.services.selector4nix;
  configFile = common.mkConfigFile cfg;
in
{
  options.services.selector4nix = common.serviceOptions;

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.services.selector4nix = {
        description = "Nix substituter proxy with parallel cache queries and latency-aware selection";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/selector4nix --no-log-timestamp";
          Environment = [
            "SELECTOR4NIX_CONFIG_FILE=${configFile}"
            "RUST_LOG=selector4nix=${cfg.logLevel}"
          ];
          Restart = "on-failure";
          RestartSec = 5;

          DynamicUser = true;
          CapabilityBoundingSet = [ "" ];
          DeviceAllow = "";
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
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@resources"
            "~@privileged"
          ];
          UMask = "0077";
        };
      };
    })

    (common.mkSubstituterConfig cfg)
  ];
}
