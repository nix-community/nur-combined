{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.dprint;
  jsonFormat = pkgs.formats.json { };

in
{
  meta.maintainers = [ hm.maintainers.wolfangaukang ];

  options.programs.dprint = {
    enable = mkEnableOption "dprint, a pluggable and configurable code formatting platform";

    package = mkOption {
      type = types.package;
      default = pkgs.dprint;
      defaultText = literalExpression "pkgs.dprint";
      description = "The package to use for dprint.";
    };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      example = literalExpression ''
        {
          markdown = {
            lineWidth = 120;
          };
          plugins = [
            "https://plugins.dprint.dev/markdown-0.20.0.wasm"
          ];
        }
      '';
      description = ''
        # Wait for https://github.com/dprint/dprint/issues/355
        Configuration written to
        {file}`~/.dprint.json`.

        See <https://docs.helix-editor.com/configuration.html>
        for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."dprint/dprint.json".source = jsonFormat.generate "dprint.json" cfg.settings;
  };
}
