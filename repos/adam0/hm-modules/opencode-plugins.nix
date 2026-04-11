{
  # keep-sorted start
  config,
  lib,
  pkgs,
  # keep-sorted end
  ...
}: let
  inherit
    (builtins)
    # keep-sorted start
    attrNames
    filter
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    genAttrs
    literalExpression
    mkAfter
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    # keep-sorted end
    ;
  inherit (pkgs) callPackage;

  jsonFormat = pkgs.formats.json {};

  cfg = config.programs.opencode;

  pluginPackages = removeAttrs (callPackage ../pkgs/opencode/plugins {}) ["mkOpencodePlugin"];
  pluginNames = attrNames pluginPackages;

  pluginSource = name:
    if name == "auto-resume" && cfg.plugins.auto-resume.settings != null
    then [
      "file://${pluginPackages.${name}}"
      cfg.plugins.auto-resume.settings
    ]
    else "file://${pluginPackages.${name}}";

  pluginOption = name:
    mkOption {
      default = {};
      type = types.submodule {
        options =
          {
            enable = mkEnableOption "the ${name} opencode plugin";
          }
          // optionalAttrs (name == "auto-resume") {
            settings = mkOption {
              type = types.nullOr jsonFormat.type;
              default = null;
              example = literalExpression ''
                {
                  chunkTimeoutMs = 45000;
                  maxRetries = 3;
                }
              '';
              description = ''
                Inline configuration passed to the plugin as
                `[ "file://..." { ... } ]` in `programs.opencode.settings.plugin`.
              '';
            };
          }
          // optionalAttrs (name == "notifier") {
            settings = mkOption {
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
          };
      };
    };

  enabledPluginNames = filter (name: cfg.plugins.${name}.enable) pluginNames;
  pluginSources =
    map pluginSource enabledPluginNames
    ++ map (pkg: "file://${pkg}") cfg.plugins.extraPackages;
in {
  options.programs.opencode.plugins = mkOption {
    default = {};
    description = "OpenCode plugin packages to enable and configure.";
    type = types.submodule {
      options =
        genAttrs pluginNames pluginOption
        // {
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
    mkMerge [
      (mkIf (pluginSources != []) {programs.opencode.settings.plugin = mkAfter pluginSources;})

      (mkIf (cfg.plugins.notifier.settings != null) {
        xdg.configFile."opencode/opencode-notifier.json".source =
          jsonFormat.generate "opencode-notifier.json" cfg.plugins.notifier.settings;
      })
    ]
  );
}
