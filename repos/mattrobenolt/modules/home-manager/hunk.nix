{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.hunk;
  toml = pkgs.formats.toml { };
in
{
  options.programs.hunk = {
    enable = lib.mkEnableOption "Hunk diff viewer";

    package = lib.mkPackageOption pkgs "hunk" { };

    enableGitIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to configure Git to use Hunk as its pager.";
    };

    settings = lib.mkOption {
      inherit (toml) type;
      default = { };
      example = {
        theme = "graphite";
        mode = "auto";
        line_numbers = true;
        wrap_lines = false;
      };
      description = "Configuration written to {file}`$XDG_CONFIG_HOME/hunk/config.toml`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."hunk/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = toml.generate "hunk-config" cfg.settings;
    };

    programs.git.settings.core.pager =
      lib.mkIf cfg.enableGitIntegration "${lib.getExe cfg.package} pager";
  };
}
