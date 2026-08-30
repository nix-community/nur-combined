{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.mcp-searxng;
in
{
  options = {
    services.mcp-searxng = {
      enable = lib.mkEnableOption "mcp-searxng MCP server";

      package = lib.mkPackageOption pkgs "mcp-searxng" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for mcp-searxng.";
      };

      searxngUrl = lib.mkOption {
        type = lib.types.nonEmptyStr;
        example = "https://searxng.example.com";
        description = ''
          URL of the SearXNG instance to query, or a semicolon-separated list
          of interchangeable replica base URLs. Maps to the `SEARXNG_URL`
          environment variable. Required.

          See <https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md#core>
          for the accepted URL format.
        '';
      };

      environment = lib.mkOption {
        type = lib.types.submodule {
          freeformType =
            with lib.types;
            attrsOf (oneOf [
              str
              int
              float
              bool
              path
              package
            ]);

          options = {
            MCP_HTTP_HOST = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = ''
                Interface address for the streamable HTTP server to bind to.
                Set to `0.0.0.0` for remote or containerized deployments.
              '';
            };

            MCP_HTTP_PORT = lib.mkOption {
              type = lib.types.port;
              default = 3000;
              description = ''
                Port for the streamable HTTP server. Setting this enables HTTP
                transport; with it unset the server falls back to STDIO.
              '';
            };
          };
        };

        default = { };

        example = {
          MCP_HTTP_HOST = "127.0.0.1";
          MCP_HTTP_PORT = 3000;
          MCP_HTTP_STATELESS = true;
          MCP_HTTP_HARDEN = true;
          MCP_HTTP_TRUST_PROXY = "loopback";
          SEARXNG_FANOUT = true;
          NODE_EXTRA_CA_CERTS = "/etc/ssl/corp-ca.pem";
        };

        description = ''
          Environment variables to set for the mcp-searxng service. Keys are
          the literal environment variable names accepted by mcp-searxng; see
          <https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md>
          for the full reference.
        '';
      };

      environmentFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        example = [ "/run/secrets/mcp-searxng.env" ];
        description = ''
          Files to load environment variables from in addition to
          [](#opt-services.mcp-searxng.environment). Useful for passing secrets
          (e.g. a SearXNG URL with embedded credentials) without putting them
          into the Nix store.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.mcp-searxng = {
      description = "SearXNG MCP server (streamable HTTP)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = lib.mapAttrs (_: v: if lib.isBool v then lib.boolToString v else toString v) (
        { SEARXNG_URL = cfg.searxngUrl; } // cfg.environment
      );

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = cfg.environmentFiles;
        Restart = "on-failure";
        RestartSec = 5;

        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
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
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        UMask = "0077";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.environment.MCP_HTTP_PORT ];
    };
  };
}
