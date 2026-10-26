{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.hysteria;
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    mapAttrs'
    nameValuePair
    optional
    ;
in
{
  disabledModules = [ "services/networking/hysteria.nix" ];
  options.services.hysteria = {
    instances = mkOption {
      description = "list of hysteria instance";
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "enable this hysteria instance";
            mimic = mkEnableOption "contain mimic path";
            package = mkPackageOption pkgs "hysteria" { };
            credentials = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                Load extra credentials.
                Could be written as systemd `LoadCredentials` format e.g.
                `["key:/etc/hysteria-key"]` and access in config with
                `/run/credentials/hysteria-''${name}.service/key`
              '';
            };
            openFirewall = mkOption {
              type = with types; nullOr port;
              default = null;
              description = "Open firewall port";
            };
            serve = mkEnableOption "using `hysteria-server` instead of `hysteria-client`";
            configFile = mkOption {
              type = types.str;
              default = "/etc/hysteria/config.yaml";
              description = "Config file location, absolute path";
            };
          };
        }
      );
      default = { };
    };
  };
  config = mkIf (cfg.instances != [ ]) {
    environment.systemPackages = lib.unique (
      lib.foldr (s: acc: acc ++ (optional s.enable s.package)) [ ] (builtins.attrValues cfg.instances)
    );

    # only allow udp port since hysteria based on udp
    networking.firewall.allowedUDPPorts = lib.unique (
      lib.foldr (
        s: acc: acc ++ (lib.optional (s.enable && (s.openFirewall != null)) s.openFirewall)
      ) [ ] (builtins.attrValues cfg.instances)
    );

    systemd.services = mapAttrs' (
      name: opts:
      nameValuePair "hysteria-${name}" {
        wantedBy = [ "multi-user.target" ];
        after = [
          "network-online.target"
          "nss-lookup.target"
        ];
        wants = [
          "network-online.target"
          "nss-lookup.target"
        ];
        unitConfig = {
          StartLimitIntervalSec = 0;
        };
        description = "hysteria daemon";
        path = mkIf opts.mimic [ pkgs.mimic-bpf ];
        serviceConfig =
          let
            binSuffix = if opts.serve then "server" else "client";
            capabilities = [
              "CAP_NET_BIND_SERVICE"
            ]
            ++ lib.optionals (!opts.serve || opts.mimic) [
              "CAP_NET_ADMIN"
              "CAP_NET_RAW"
            ]
            ++ lib.optionals opts.mimic [
              "CAP_BPF"
              "CAP_PERFMON"
            ];
          in
          {
            Type = "simple";
            DynamicUser = true;
            ExecStart = "${lib.getExe' opts.package "hysteria"} ${binSuffix} -c \${CREDENTIALS_DIRECTORY}/config.yaml";
            LoadCredential = [ "config.yaml:${opts.configFile}" ] ++ opts.credentials;
            Environment = [ "HYSTERIA_DISABLE_UPDATE_CHECK=1" ];
            StateDirectory = "hysteria-${name}";
            WorkingDirectory = "/var/lib/hysteria-${name}";
            RuntimeDirectory = mkIf opts.mimic "mimic";
            AmbientCapabilities = capabilities;
            CapabilityBoundingSet = capabilities;
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            PrivateDevices = !opts.mimic && opts.serve;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            ProtectProc = "invisible";
            RestrictNamespaces = true;
            RestrictSUIDSGID = true;
            RestrictRealtime = true;
            LockPersonality = true;
            SystemCallArchitectures = "native";
            UMask = "0077";
            LimitNPROC = 512;
            LimitNOFILE = "infinity";
            Restart = "always";
            RestartSec = 1;
            # Public proxy traffic must share CPU with discovery and identity.
            CPUSchedulingPolicy = "other";
            CPUSchedulingPriority = 0;
          };
      }
    ) (lib.filterAttrs (_: v: v.enable) cfg.instances);
  };
}
