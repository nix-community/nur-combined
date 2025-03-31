# Inspired from https://git.madhouse-project.org/iocaine/nixocaine
{ config, pkgs, lib, ... }:
let
  cfg = config.services.iocaine;

  configFormat = pkgs.formats.toml { };
  configType = with lib; types.submodule {
    freeformType = configFormat.type;
    options = {
      server = {
        bind = mkOption {
          type = types.str;
          default = "127.0.0.1:42069";
        };
      };
      sources = {
        words = mkOption {
          type = with types; oneOf [ str path ];
          default = "${pkgs.miscfiles}/share/web2";
        };
        markov = mkOption {
          type = with types; listOf (oneOf [ str path ]);
          default = [ ];
        };
      };
      generator = { };
    };
  };

  enabledServers = lib.filterAttrs (name: server: server.enable) cfg.servers;
in {
  options.services.iocaine = with lib; {
    package = mkPackageOption pkgs "iocaine" { };

    userAgents = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    ipRanges = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    nginx = {
      enable = mkEnableOption "nginx bad agents map";
    };

    servers = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "iocaine, the deadliest poison known to AI" // {
            default = true;
          };
          config = mkOption {
            type = configType;
            default = { };
          };
        };
      });
      default = { };
    };
  };

  config = {
    services.nginx.commonHttpConfig = let
      userAgentsMap = lib.concatMapStringsSep "\n" (userAgent: "\"~*${userAgent}\" 1;") cfg.userAgents;
      ipRangesMap = lib.concatMapStringsSep "\n" (ipRange: "${ipRange} 1;") cfg.ipRanges;
    in lib.mkIf cfg.nginx.enable ''
      map $http_user_agent $iocaine_badagent {
        default 0;
        ${userAgentsMap}
      }

      geo $iocaine_badrange {
        default 0;
        ${ipRangesMap}
      }
    '';

    systemd.services = lib.mapAttrs' (name: server: let
      configFile = configFormat.generate "iocaine-${name}.toml" server.config;
    in lib.nameValuePair "iocaine-${name}" {
      description = "iocaine - ${name}";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartTriggers = [ configFile ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.lib.getExe cfg.package} --config-file ${configFile}";
        Restart = "on-failure";
        DynamicUser = true;

        StateDirectory = "iocaine-${name}";
        WorkingDirectory = "/var/lib/iocaine-${name}";

        ProtectSystem = "strict";
        SystemCallArchitectures = "native";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        DevicePolicy = "closed";
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
      };
    }) enabledServers;

    lib.iocaine = {
      nginx = {
        mkVirtualHost = serverName: {
          locations."/.well-known/@iocaine".proxyPass = "http://${cfg.servers.${serverName}.config.server.bind}";
          extraConfig = ''
            if ($iocaine_badagent) { rewrite ^/(.*)$ /.well-known/@iocaine/$1; }
            if ($iocaine_badrange) { rewrite ^/(.$)$ /.well-known/@iocaine/$1; }
          '';
        };
      };
    };
  };
}
