{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.ts-proxy;
in

{
  options = {
    services.ts-proxy = {
      network-domain = lib.mkOption {
        description = "Which ts.net domain this machine belongs";
        default = "stargazer-shark.ts.net";
      };

      environmentFile = lib.mkOption {
        description = "Path to environment file for ts-proxy credentials";
        default = "/run/secrets/ts-proxy";
      };

      image = lib.mkOption {
        description = "Which ts-proxy image to use";
        default = "ghcr.io/lucasew/ts-proxy:latest";
        type = lib.types.str;
      };

      user = lib.mkOption {
        description = "Service user";
        type = lib.types.str;
        default = "tsproxy";
      };
      group = lib.mkOption {
        description = "Service group";
        type = lib.types.str;
        default = "tsproxy";
      };

      dataDir = lib.mkOption {
        description = "Data dir";
        type = lib.types.str;
        default = "/var/lib/ts-proxy";
      };

      hosts = lib.mkOption {
        description = "Services to expose to ts-proxy";

        default = {};

        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, ... }:
            {
              options = {
                enableFunnel = lib.mkEnableOption "enable funnel for this endpoint";
                enableTLS = lib.mkEnableOption "enable TLS for this endpoint";
                enableRaw = lib.mkEnableOption "treat this endpoint as a raw TCP socket";

                network = lib.mkOption {
                  description = "First parameter of net.Dial";
                  type = lib.types.str;
                  default = "";
                };

                address = lib.mkOption {
                  description = "Second parameter of net.Dial";
                  type = lib.types.str;
                };

                listen = lib.mkOption {
                  description = "Which port to listen in the vhost";
                  type = lib.types.port;
                  default = 0;
                };

                name = lib.mkOption {
                  description = "Service name";
                  type = lib.types.str;
                  default = name;
                };

                proxies = lib.mkOption {
                  description = "Which units this ts-proxy instance is proxying.";
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };

                unitName = lib.mkOption {
                  description = "Systemd unit of the proxy";
                  type = lib.types.str;
                  default = "ts-proxy-${name}";
                };
              };

            }
          )
        );
      };
    };
  };

  config = {
    sops.secrets.ts-proxy = {
      sopsFile = ../../../../secrets/ts-proxy.env;
      owner = cfg.user;
      group = cfg.group;
      format = "dotenv";
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
    };

    users.groups.${cfg.group} = { };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group} - -" ];

    systemd.slices.ts-proxys.sliceConfig = {
      CPUQuota = "10%";
      MemoryHigh = "256M";
      MemoryMax = "384M";
    };

    virtualisation.oci-containers.containers = lib.mkMerge (
      builtins.attrValues (
          builtins.mapAttrs (k: host: {
            ${host.unitName} = {
              inherit (cfg) image;
              pull = "always";
              serviceName = host.unitName;
              extraOptions = [ "--network=host" ];
              environmentFiles = [ cfg.environmentFile ];
              volumes = [
                "${cfg.dataDir}/tsproxy-${host.name}:/state"
              ];
              cmd = []
                ++ ([ "-address" host.address ])
                ++ (lib.optional host.enableFunnel "-f")
                ++ (lib.optionals (host.listen != 0) [ "-listen" ":${toString host.listen}" ])
                ++ ([ "-n" host.name ])
                ++ (lib.optionals (host.network != "") [ "-net" host.network ])
                ++ (lib.optional host.enableRaw "-raw")
                ++ ([ "-s" "/state" ])
                ++ (lib.optional host.enableTLS "-t")
              ;
            };
          }) cfg.hosts
        )
    );

    systemd.services = lib.mkMerge (
      builtins.attrValues (
        builtins.mapAttrs (k: host: {
          ${host.unitName} = {

            description = "ts-proxy service for ${host.name}";
            wantedBy = if host.proxies == [ ] then [ "multi-user.target" ] else host.proxies;

            after = host.proxies;
            partOf = host.proxies;
            wants = host.proxies;

            restartIfChanged = true;

            serviceConfig = {
              Slice = "ts-proxy.slice";
              # User = cfg.user;
              # Group = cfg.group;
              Restart = lib.mkForce "always";
              RestartSec = "10s";
            };
          };
        }) cfg.hosts
      )
    );
  };
}
