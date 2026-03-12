{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    attrNames
    ;
  inherit
    (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    mkAfter
    ;
  inherit (pkgs) callPackage;

  jsonFormat = pkgs.formats.json {};

  cfg = config.programs.opencode;

  pluginPackages = removeAttrs (callPackage ../pkgs/opencode/plugins {}) ["mkOpencodePlugin"];
  pluginNames = attrNames pluginPackages;

  pluginOption = name:
    mkOption {
      default = {};
      type = types.submodule {
        options = {
          enable = mkEnableOption "the ${name} opencode plugin";
        };
      };
    };

  enabledPluginNames = builtins.filter (name: cfg.plugins.${name}.enable) pluginNames;
  pluginSources =
    map (name: "file://${pluginPackages.${name}}") enabledPluginNames
    ++ map (pkg: "file://${pkg}") cfg.plugins.extraPackages;
in {
  options.programs.opencode.plugins = mkOption {
    default = {};
    description = "OpenCode plugin packages to enable and configure.";
    type = types.submodule {
      options =
        lib.genAttrs pluginNames pluginOption
        // {
          notifier.settings = mkOption {
            type = types.nullOr jsonFormat.type;
            default = null;
            example = literalExpression ''
              {
                sound = false;
              }
            '';
            description = ''
              Configuration written to $XDG_CONFIG_HOME/opencode/opencode-notifier.json.
              The value is rendered to JSON and managed by Home Manager.
            '';
          };

          extraPackages = mkOption {
            type = types.listOf types.package;
            default = [];
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
      (mkIf (pluginSources != []) {programs.opencode.settings.plugin = mkAfter pluginSources;})

      (mkIf (cfg.plugins.notifier.settings != null) {
        xdg.configFile."opencode/opencode-notifier.json".source =
          jsonFormat.generate "opencode-notifier.json" cfg.plugins.notifier.settings;
      })
    ]
  );
}
