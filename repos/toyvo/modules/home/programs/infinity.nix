# Declarative configuration for the Infinity coding agent CLI
# (~/.infinity/providers.json + ~/.infinity/rap.json).
#
# Both files are managed as immutable store symlinks, like the other editor
# modules: the daemon only reads them at startup, so normal operation never
# writes. The lifecycle commands (`infinity provider/rap install|update`)
# DO write them and will fail with EACCES — manage those lifecycles through
# nix instead (pkgs/infinity-agent-cli/update.ts + rebuild).
#
# Secrets do not belong here: infinity performs no secret expansion, so any
# token would land literally in /nix/store. Prefer local MCP entries whose
# commands are wrappers that read secrets at runtime; manage secret-bearing
# remote servers by hand in a project-level .infinity/rap.json (merged by
# the daemon, overrides nothing here).
{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  cfg = config.programs.infinity;
in
{
  options.programs.infinity = {
    enable = lib.mkEnableOption "Infinity coding agent CLI";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.nixcfg.packages.${system}.infinity-agent-cli;
      description = "The infinity-agent-cli package to install.";
    };

    providers = lib.mkOption {
      type = jsonFormat.type;
      default = {
        "models.dev" = {
          command = [ (lib.getExe inputs.nixcfg.packages.${system}.infinity-provider-models-dev) ];
        };
        bedrock = {
          command = [ (lib.getExe inputs.nixcfg.packages.${system}.infinity-provider-bedrock) ];
        };
      };
      description = ''
        Model providers written to ~/.infinity/providers.json, mapping
        provider id to its configuration. Key order in the generated file
        follows `providerOrder` (then any remaining ids alphabetically):
        the first model of the first provider is the default model for
        new sessions.
        The daemon reads the file at startup; restart it after changes.
      '';
    };

    providerOrder = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "models.dev"
        "bedrock"
      ];
      description = ''
        Provider ids in the order they should appear in
        ~/.infinity/providers.json. Ids not listed here are appended
        alphabetically; ids listed here but absent from `providers`
        are ignored. Nix attrsets serialize to JSON alphabetically
        (bedrock before models.dev), so this ordering is applied
        manually instead of relying on `pkgs.formats.json`.
      '';
    };

    # Nix-built RAP servers by default. Kept separate from `toolSets` so a
    # host setting `toolSets` (which replaces the default) doesn't silently
    # drop them; both lists are concatenated in rap.json.
    rapServers = lib.mkOption {
      type = lib.types.listOf jsonFormat.type;
      default = [
        {
          type = "toolset_command";
          command = lib.getExe inputs.nixcfg.packages.${system}.sandbox-local;
          id = "sandbox-local";
        }
        {
          type = "toolset_command";
          command = lib.getExe inputs.nixcfg.packages.${system}.rap-steering-server;
          id = "rap-steering-server";
        }
        {
          type = "toolset_command";
          command = lib.getExe inputs.nixcfg.packages.${system}.rap-github-event-poller;
          id = "rap-github-event-poller";
        }
      ];
      description = ''
        Nix-built RAP servers included in ~/.infinity/rap.json.
      '';
    };

    toolSets = lib.mkOption {
      type = lib.types.listOf jsonFormat.type;
      default = [ ];
      example = [
        {
          type = "mcp_server";
          name = "mcp-nixos";
          command = [
            lib.getExe
            pkgs.mcp-nixos
          ];
        }
      ];
      description = ''
        Additional tool set entries for the tool_sets array in
        ~/.infinity/rap.json (mcp_server, http_mcp_server, ...),
        concatenated after `rapServers`.
        Secret-free only (see note at the top of this module).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file = {
      # builtins.toJSON sorts attrset keys alphabetically, which would put
      # bedrock before models.dev. Build the top-level object manually so
      # `providerOrder` is honored (per-value toJSON is fine; inner key
      # order is insignificant).
      ".infinity/providers.json" = lib.mkIf (cfg.providers != { }) {
        source =
          let
            ordered =
              (builtins.filter (name: builtins.hasAttr name cfg.providers) cfg.providerOrder)
              ++ (builtins.filter (name: !(builtins.elem name cfg.providerOrder)) (
                builtins.attrNames cfg.providers
              ));
            entries = map (name: "${builtins.toJSON name}:${builtins.toJSON cfg.providers.${name}}") ordered;
          in
          pkgs.writeText "infinity-providers.json" "{${lib.concatStringsSep "," entries}}";
      };
      ".infinity/rap.json" = lib.mkIf (cfg.rapServers != [ ] || cfg.toolSets != [ ]) {
        source = jsonFormat.generate "infinity-rap.json" {
          tool_sets = cfg.rapServers ++ cfg.toolSets;
        };
      };
    };
  };
}
