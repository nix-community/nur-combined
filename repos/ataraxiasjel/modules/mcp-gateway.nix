{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mcp-gateway;
  format = pkgs.formats.yaml { };

  capabilitiesDir =
    let
      files = mapAttrs (name: value: format.generate "${name}.yaml" value) cfg.capabilities;
    in
    pkgs.runCommand "mcp-gateway-capabilities" { } (
      "mkdir -p $out\n"
      + concatStringsSep "\n" (
        mapAttrsToList (name: _: "ln -s ${files.${name}} $out/${name}.yaml") cfg.capabilities
      )
    );

  settings' =
    cfg.settings
    // optionalAttrs (cfg.capabilities != { }) {
      capabilities = (cfg.settings.capabilities or { }) // {
        directories = [ capabilitiesDir ] ++ (cfg.settings.capabilities.directories or [ ]);
      };
    };

  configFile = format.generate "gateway.yaml" settings';
in
{
  options.services.mcp-gateway = {
    enable = mkEnableOption (
      lib.mdDoc "Universal MCP Gateway - single-port multiplexing with Meta-MCP"
    );

    package = mkPackageOption pkgs "mcp-gateway" { };

    settings = mkOption {
      type = with types; attrsOf format.type;
      default = { };
      example = literalExpression ''
        {
          server = {
            host = "127.0.0.1";
            port = 39400;
          };
          auth = {
            enabled = true;
            bearer_token = "env:MCP_GATEWAY_TOKEN";
          };
          backends = {
            tavily = {
              command = "npx -y @anthropic/mcp-server-tavily";
              description = "Web search via Tavily";
              env = {
                TAVILY_API_KEY = "env:TAVILY_API_KEY";
              };
            };
          };
        }
      '';
      description = lib.mdDoc ''
        MCP Gateway configuration. See
        <https://github.com/MikkoParkkola/mcp-gateway/blob/main/examples/gateway-full.yaml>
        for all supported options and defaults.

        Secrets should never be written literally here - the generated config
        file is a world-readable store path. Use `env:VAR_NAME` references and
        provide the actual values via `environmentFile` or the gateway's
        `env_files` option.
      '';
    };

    capabilities = mkOption {
      type = with types; attrsOf format.type;
      default = { };
      example = literalExpression ''
        {
          my-capability = {
            name = "My Capability";
            description = "Expose a REST endpoint as an MCP tool";
            tools = [
              {
                name = "fetch_status";
                description = "Fetch status from the API";
                url = "https://api.example.com/status";
                method = "GET";
              }
            ];
          };
        }
      '';
      description = lib.mdDoc ''
        Capability definitions rendered as YAML files into a store directory
        registered in `settings.capabilities.directories`. Enables the REST API
        integration (see `gateway_list_servers`).
      '';
    };

    configFile = mkOption {
      type = types.path;
      default = configFile;
      description = lib.mdDoc ''
        Path to the generated gateway configuration. Points into the nix store
        and is immutable; a new `nixos-rebuild` produces a fresh path, which
        restarts the service.
      '';
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/mcp-gateway";
      description = lib.mdDoc ''
        Writable state directory. Becomes the service's working directory and
        `HOME`, so relative paths (e.g. `capabilities.directories`,
        tool-profile persistence, `env_files`) and `~` expansion resolve
        inside it.
      '';
    };

    logLevel = mkOption {
      type = types.str;
      default = "info";
      description = lib.mdDoc ''
        Minimum log level: trace, debug, info, warn, or error.
      '';
    };

    logFormat = mkOption {
      type = with types; nullOr str;
      default = "json";
      description = lib.mdDoc ''
        Log output format: "text" for human-readable, "json" for structured.
      '';
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = lib.mdDoc ''
        File in the format of an EnvironmentFile as described by systemd.exec(5).
        Use this to provide values for `env:VAR_NAME` references in `settings`
        without embedding secrets in the nix store.
      '';
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = lib.mdDoc ''
        Additional packages added to the service PATH for stdio backends
        that spawn subprocesses. `nodejs` and `bash` are always provided
        (npx-based backends need both `node` and a shell on the PATH).
      '';
    };

    extraArguments = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = literalExpression ''[ "--no-meta-mcp" ]'';
      description = lib.mdDoc "Extra arguments passed to the mcp-gateway binary.";
    };

    extraEnvironment = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = lib.mdDoc "Extra environment variables passed to the service.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Open `settings.server.port` in the firewall. Only meaningful when the
        gateway binds a non-loopback address.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "mcp-gateway";
      description = lib.mdDoc "User account under which mcp-gateway runs.";
    };

    group = mkOption {
      type = types.str;
      default = "mcp-gateway";
      description = lib.mdDoc "Group under which mcp-gateway runs.";
    };

    memoryMax = mkOption {
      type = with types; nullOr str;
      default = "1G";
      description = lib.mdDoc ''
        Memory limit for the service, or `null` for no limit.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ (cfg.settings.server.port or 39400) ];

    systemd.services.mcp-gateway = {
      description = "MCP Gateway";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.nodejs
        pkgs.bash
      ]
      ++ cfg.extraPackages;
      environment = {
        HOME = cfg.stateDir;
        MCP_GATEWAY_LOG_LEVEL = cfg.logLevel;
      }
      // optionalAttrs (cfg.logFormat != null) { MCP_GATEWAY_LOG_FORMAT = cfg.logFormat; }
      // cfg.extraEnvironment;
      serviceConfig = {
        Type = "simple";
        ExecStart = concatStringsSep " " (
          [
            "${getExe cfg.package}"
            "--config"
            cfg.configFile
          ]
          ++ cfg.extraArguments
        );
        Restart = "on-failure";
        RestartSec = "5s";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "mcp-gateway";
        StateDirectoryMode = "0700";
        WorkingDirectory = cfg.stateDir;
        LimitNOFILE = 65536;
        LockPersonality = true;
        MemoryMax = cfg.memoryMax;
        NoNewPrivileges = true;
        PrivateIPC = true;
        PrivateMounts = true;
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
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ProtectSystem = "strict";
        UMask = "0007";
      }
      // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "MCP Gateway Daemon User";
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
