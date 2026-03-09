{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.opencode;
  pluginsCfg = cfg.plugins;
  jsonFormat = pkgs.formats.json { };

  pluginPackages = builtins.removeAttrs (pkgs.callPackage ../pkgs/opencode/plugins { }) [ "mkOpencodePlugin" ];
  pluginNames = builtins.attrNames pluginPackages;

  pluginOption = name:
    mkOption {
      default = { };
      type = types.submodule {
        options = {
          enable = mkEnableOption "the ${name} opencode plugin";
        }
        // lib.optionalAttrs (name == "notifier") {
          settings = mkOption {
            type = types.nullOr (types.either types.path jsonFormat.type);
            default = null;
            example = literalExpression ''
              {
                sound = false;
              }
            '';
            description = ''
              Configuration written to $XDG_CONFIG_HOME/opencode/opencode-notifier.json.
              Accepts either a JSON value to generate or a path to an existing JSON file.
            '';
          };
        };
      };
    };

  enabledPluginNames = builtins.filter (name: pluginsCfg.${name}.enable) pluginNames;
  pluginSources =
    map (name: "file://${pluginPackages.${name}}") enabledPluginNames
    ++ map (pkg: "file://${pkg}") pluginsCfg.extraPackages;
in
{
  options.programs.opencode.plugins = mkOption {
    default = { };
    description = "OpenCode plugin packages to enable and configure.";
    type = types.submodule {
      options =
        lib.genAttrs pluginNames pluginOption
        // {
          extraPackages = mkOption {
            type = types.listOf types.package;
            default = [ ];
            example = literalExpression "[ pkgs.my-opencode-plugin ]";
            description = ''
              Additional OpenCode plugin packages to append to
              `programs.opencode.settings.plugin` as `file://` package roots.
            '';
          };
        };
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      (mkIf (pluginSources != [ ]) {
        programs.opencode.settings.plugin = lib.mkAfter pluginSources;
      })
      (mkIf (pluginsCfg.notifier.settings != null) {
        xdg.configFile."opencode/opencode-notifier.json".source =
          if builtins.isPath pluginsCfg.notifier.settings then
            pluginsCfg.notifier.settings
          else
            jsonFormat.generate "opencode-notifier.json" pluginsCfg.notifier.settings;
      })
    ]
  );
}
