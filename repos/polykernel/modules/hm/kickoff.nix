{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.kickoff;

  tomlFormat = pkgs.formats.toml {};
in {
  options = {
    programs.kickoff = {
      enable = mkEnableOption ''
        kickoff, a minimalistic program launcher heavily inspired by rofi
      '';

      package = mkOption {
        type = types.package;
        default = pkgs.kickoff;
        defaultText = literalExpression "pkgs.kickoff";
        description = "Package providing <command>kickoff</command>.";
      };

      settings = mkOption {
        type = tomlFormat.type;
        default = {};
        description = ''
          Configuration written to
          <filename>$XDG_CONFIG_HOME/kickoff/config.toml</filename>
          </para><para>
          See <link xlink:href="https://github.com/j0ru/kickoff/blob/main/assets/default_config.toml"/>
          for the default configuration.
        '';
        example = literalExpression ''
          {
            font_size = 24.0;

            history = {
              decrease_interval = 48;
            };
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    home.file."${configDir}/kickoff/config.toml" = mkIf (cfg.settings != {}) {
      source = tomlFormat.generate "kickoff-config.toml" cfg.settings;
    };
  };

  meta.maintainers = [maintainers.polykernel];
}
