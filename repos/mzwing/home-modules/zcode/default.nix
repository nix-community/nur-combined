{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zcode;
  jsonFormat = pkgs.formats.json {};
  mergeConfig = (import ../../internal/config-merge {inherit pkgs;}).mkMergeConfig {
    name = "zcode-merge-config";
    format = "json";
  };
  mcpSettings = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable && config.programs.mcp.servers != {}) {
    mcp.servers = lib.mapAttrs (_: server:
      lib.hm.mcp.transformMcpServer {
        inherit server;
        extraTransforms = [lib.hm.mcp.addType];
        exclude = ["serverUrl"];
      })
    config.programs.mcp.servers;
  };
  finalSettings = lib.recursiveUpdate mcpSettings cfg.settings;
  configDir = "${config.home.homeDirectory}/.zcode/cli";
in {
  options.programs.zcode = {
    enable = lib.mkEnableOption "ZCode, the Z.ai coding desktop app";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = lib.literalExpression "inputs.llm-agents.packages.\${pkgs.stdenv.hostPlatform.system}.zcode";
      description = "ZCode is not in nixpkgs; on macOS it is usually installed with the Homebrew cask `zcode` instead.";
    };

    context = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Global instructions written to `~/.zcode/AGENTS.md`; the app's personalization page replaces the link when saving.";
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      example = {
        permission.mode = "auto";
        mcp.servers.example = {
          type = "stdio";
          command = "example";
        };
      };
      description = "Settings merged into `~/.zcode/cli/config.json` on every activation. Nix-owned keys win, app-written keys are kept, and keys removed here are removed from the file. See <https://github.com/zai-org/ZCode/blob/main/apps/zcode-cli/docs/usage/03-config.md> for the schema.";
    };

    enableMcpIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to integrate {option}`programs.mcp.servers` into {option}`programs.zcode.settings.mcp.servers`, with ZCode settings taking precedence.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;

    home.file.".zcode/AGENTS.md" = lib.mkIf (cfg.context != "") {
      text = cfg.context;
    };

    home.activation.zcodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe mergeConfig} \
        ${lib.escapeShellArg "${configDir}/config.json"} \
        ${jsonFormat.generate "zcode-config.json" finalSettings} \
        ${lib.escapeShellArg "${configDir}/.nix-managed.json"} \
        ${lib.escapeShellArg "${configDir}/config.json.stateful"}
    '';
  };
}
