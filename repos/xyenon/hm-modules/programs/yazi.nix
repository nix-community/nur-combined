{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.yazi;
  tomlFormat = pkgs.formats.toml { };

  shellIntegration = ''
    function ya() {
      tmp="$(mktemp -t "yazi-cwd")"
      yazi --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
in
{
  options.programs.yazi = {
    enable = mkEnableOption "yazi";

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.xyenon.yazi;
      defaultText = literalExpression "pkgs.nur.repos.xyenon.yazi";
      description = "Yazi package to install.";
    };

    enableBashIntegration = mkEnableOption "Bash integration";

    enableZshIntegration = mkEnableOption "Zsh integration";

    keymap = mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/yazi/keymap.toml`.

        See <https://github.com/sxyazi/yazi/blob/main/config/docs/keymap.md>
        for the full list of options. Note that this option will overwrite any existing keybinds.
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/yazi/yazi.toml`.

        See <https://github.com/sxyazi/yazi/blob/main/config/docs/yazi.md>
        for the full list of options.
      '';
    };

    theme = mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/yazi/theme.toml`.

        See <https://github.com/sxyazi/yazi/blob/main/config/docs/theme.md>
        for the full list of options
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash.initExtra = mkIf cfg.enableBashIntegration shellIntegration;

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration shellIntegration;

    xdg.configFile = {
      "yazi/keymap.toml" = mkIf (cfg.keymap != { }) {
        source = tomlFormat.generate "yazi-keymap" cfg.keymap;
      };
      "yazi/yazi.toml" = mkIf (cfg.settings != { }) {
        source = tomlFormat.generate "yazi-settings" cfg.settings;
      };
      "yazi/theme.toml" = mkIf (cfg.theme != { }) {
        source = tomlFormat.generate "yazi-theme" cfg.theme;
      };
    };
  };
}
