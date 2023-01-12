{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.swayimg;

  iniAtom = oneOf [ str float int null ];
  toSwayimgIni = lib.generators.toINIWithGlobalSection { };
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
        description = "Package providing <command>swayimg</command>.";
      };

      settings = mkOption {
        type = types.submodules {
          options = {
            globalSection = mkOption {
	      type = types.attrsOf iniAtom;
	      default = {};
	      description = ''
                Global properties to be set in the swayimg configuration.
              '';
            };
	    sections = mkOption {
	      type = types.attrsOf (types.attrsOf iniAtom);
	      default = {};
	      description = ''
                Sections to be set in the swayimg configuration.
              '';
	    };
          };
        };
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
    assertions = [ (hm.assertions.assertPlatform "programs.swayimg" pkgs platforms.linux) ];

    home.packages = [ cfg.package ];

    xdg.configFile."swayimg/config" = mkIf (cfg.settings != {}) {
      text = toSwayimgIni cfg.settings;
    };
  };

  meta.maintainers = [ maintainers.polykernel ];
}
