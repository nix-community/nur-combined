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
        and is immutable; a new rebuild produces a fresh path, which restarts
        the service.
      '';
    };

    stateDir = mkOption {
      type = with types; nullOr path;
      default = null;
      description = lib.mdDoc ''
        Writable state directory, or `null` for the platform default. Becomes
        the service's working directory and `HOME`, so relative paths (e.g.
        `capabilities.directories`, tool-profile persistence, `env_files`) and
        `~` expansion resolve inside it.
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

    memoryMax = mkOption {
      type = with types; nullOr str;
      default = "1G";
      description = lib.mdDoc ''
        Memory limit for the service, or `null` for no limit.
      '';
    };
  };
}
