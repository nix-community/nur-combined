{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.swayimg;

  iniFormat = pkgs.formats.ini {};
in {
  options = {
    programs.swayimg = {
      enable = mkEnableOption ''
        swayimg, a lightweight image viewer for Sway/Wayland display servers 
      '';

      package = mkOption {
        type = types.package;
        default = pkgs.swayimg;
        defaultText = literalExpression "pkgs.swayimg";
        description = "Package providing <command>kickoff</command>.";
      };

      settings = mkOption {
        type = tomlFormat.type;
        default = {};
        description = ''
          Configuration written to
          <filename>$XDG_CONFIG_HOME/swayimg/config</filename>
          </para><para>
          See <link xlink:href="https://github.com/artemsen/swayimg/blob/master/extra/swayimgrc"/>
          for a sample configuration.
        '';
        example = literalExpression ''
          {
            scale = "optimal";
	    window = "#000000";
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [(hm.assertions.assertPlatform "programs.swayimg" pkgs platforms.linux)];

    home.packages = [ cfg.package ];

    xdg.configFile."swayimg/config" = mkIf (cfg.settings != {}) {
      source = iniFormat.generate "swayimg-config" cfg.settings;
    };
  };

  meta.maintainers = [ maintainers.polykernel ];
}
