{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.comfyui-workflow-mcp;
  toml = pkgs.formats.toml { };
in
{
  options.programs.comfyui-workflow-mcp = {
    enable = lib.mkEnableOption "comfyui-workflow-mcp";

    package = lib.mkPackageOption pkgs "comfyui-workflow-mcp" { };

    settings = lib.mkOption {
      type = toml.type;
      default = { };
      example = lib.literalExpression ''
        {
          log_level = "info";
          paths.env_file = "/run/secrets/comfyui-workflow-mcp.toml";
      '';
      description = ''
        Written to `$XDG_CONFIG_HOME/comfyui-workflow-mcp/config.toml` as-is,
        with the same key structure as the config.

        The built-in defaults and every available key are documented in
        https://github.com/Silicon-AI-Garden-Ecosystem/comfyui-workflow-mcp/blob/master/sim/config.toml
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."comfyui-workflow-mcp/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = toml.generate "comfyui-workflow-mcp-config.toml" cfg.settings;
    };
  };
}
