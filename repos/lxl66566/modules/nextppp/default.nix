{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nextppp;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/nextppp { };
  settingsFormat = pkgs.formats.json { };
  # Typed options that stay unset in a mode default to null; the binary
  # rejects unknown fields (deny_unknown_fields), so nulls must not leak
  # into the generated JSON.
  filteredSettings = lib.filterAttrs (_: v: v != null) cfg.settings;
  configFile = settingsFormat.generate "nextppp.jsonc" filteredSettings;
in
{
  options.services.nextppp = {
    enable = lib.mkEnableOption "nextppp service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The nextppp package to use.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "server"
        "client"
      ];
      description = "Whether to run nextppp as a server or a client.";
      example = "server";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          listen = lib.mkOption {
            type = lib.types.str;
            description = "Listen address for nextppp connections.";
            example = "0.0.0.0:6666";
          };

          password = lib.mkOption {
            type = lib.types.str;
            description = "Shared tunnel password. Must be changed per deployment.";
          };

          bond_enabled = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = ''
              (Server) Accept bond-link sessions — the members of aggregated
              multi-link tunnels — on the same listen port as plain tunnels;
              the two roles are told apart in the handshake. Refused sessions
              are answered at the handshake. Defaults to true in nextppp
              >= 0.3.0, so leave it unset to accept them.
            '';
          };

          bond = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                listen = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Local SOCKS5 inbound served by bonded (multi-link
                    aggregated) tunnels — the bandwidth path. Route bulk
                    traffic here and interactive traffic to `listen`.
                  '';
                  example = "127.0.0.1:1081";
                };
                links = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 3;
                  description = ''
                    Nextppp link sessions per bonded tunnel. Each link is a
                    full connection to the server's regular address.
                  '';
                };
                pool_size = lib.mkOption {
                  type = lib.types.ints.u32;
                  default = 1;
                  description = "Bonded tunnels kept hot by the pool.";
                };
                max_streams = lib.mkOption {
                  type = lib.types.ints.u32;
                  default = 64;
                  description = ''
                    Streams a bonded tunnel may carry before another is
                    preferred.
                  '';
                };
              };
            });
            default = null;
            description = ''
              (Client) Enable the bonded multi-link SOCKS5 inbound — the
              bandwidth path. Links dial the server's regular
              `server.address`; no separate bond port is needed
              (nextppp >= 0.3.0).
            '';
          };
        };
      };
      description = "The nextppp configuration.";
      example = {
        listen = "0.0.0.0:6666";
        password = "CHANGE_ME";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextppp.settings =
      if cfg.mode == "server" then
        {
          listen = lib.mkDefault "0.0.0.0:6666";
          password = lib.mkDefault "CHANGE_ME";
          connect_timeout = lib.mkDefault 10;
          handshake_timeout = lib.mkDefault 15;
        }
      else
        {
          listen = lib.mkDefault "127.0.0.1:1080";
          password = lib.mkDefault "CHANGE_ME";
          server = lib.mkDefault {
            address = "your.server.example:6666";
          };
        };
    systemd.services.nextppp = {
      description = "nextppp ${cfg.mode} service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/nextppp ${cfg.mode} -c ${configFile}";

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
  };
}
