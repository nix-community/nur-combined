{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.selector4nix;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/selector4nix { };
  settingsFormat = pkgs.formats.toml { };

  rawConfigFile = settingsFormat.generate "selector4nix.raw.toml" cfg.settings;
  configFile = pkgs.runCommand "selector4nix.toml" { } ''
    echo 'Checking the configuration file via selector4nix check'
    ${cfg.package}/bin/selector4nix --config-file "${rawConfigFile}" check && cp ${rawConfigFile} $out
  '';
in
{
  options.services.selector4nix = {
    enable = lib.mkEnableOption "selector4nix service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The selector4nix package to use.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [ "error" "warn" "info" "debug" "trace" ];
      default = "info";
      description = "The verbosity of the logging output";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options.server = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "The IP address that selector4nix listens on";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 5496;
            description = "The port that selector4nix listens on";
          };
        };
      };
      default = { };
      description = "The configuration that will be read by selector4nix";
    };

    configureSubstituter = lib.mkOption {
      type = lib.types.enum [ "keep" "prepend" "overwrite" ];
      default = "keep";
      description = "Whether to configure the substituter list";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.services.selector4nix = {
        description = "Nix substituter proxy with parallel cache queries and latency-aware selection";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/selector4nix";
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

    (lib.mkIf (cfg.enable && cfg.configureSubstituter == "prepend") {
      nix.settings.substituters = lib.mkBefore [
        "http://${cfg.settings.server.ip}:${builtins.toString cfg.settings.server.port}/"
      ];
    })

    (lib.mkIf (cfg.enable && cfg.configureSubstituter == "overwrite") {
      nix.settings.substituters = lib.mkForce [
        "http://${cfg.settings.server.ip}:${builtins.toString cfg.settings.server.port}/"
      ];
    })
  ];
}
