{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.deepseek-harness;
  yaml = pkgs.formats.yaml { };

  installedPackage =
    if
      lib.any (profile: builtins.elem "github:YuJunZhiXue/dsh-purge" profile.plugins) (
        builtins.attrValues cfg.profiles
      )
    then
      pkgs.callPackage ../pkgs/dsh-plugins/purge-host.nix { deepseek-harness = cfg.package; }
    else
      cfg.package;

  pluginPackages = pkgs.callPackage ../pkgs/dsh-plugins { deepseek-harness = installedPackage; };
  catalog = import ../pkgs/dsh-plugins/catalog.nix { inherit lib; };

  profileType = lib.types.submodule {
    imports = [ (lib.mkRenamedOptionModule [ "bundles" ] [ "plugins" ]) ];

    options = {
      plugins = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (builtins.attrNames catalog));
        description = ''
          Plugins from the catalog, applied in list order.
          Use npm: package names or github: repositories.
        '';

        example = [
          "npm:@deepseek-ai/dsh-base"
          "npm:@deepseek-ai/dsh-web-app"
          "npm:dsh-context"
          "npm:@ychris12138/dsh-usage-stats"
        ];
      };

      patch = lib.mkOption {
        type = yaml.type;
        default = { };
        description = "Profile-specific Cordis patch written to cordis.patch.yml.";
      };
    };
  };

  profileFiles = lib.concatMapAttrs (
    name: profile:
    let
      packages = lib.listToAttrs (
        map (
          source:
          let
            plugin = pluginPackages.${source};
          in
          {
            name = plugin.packageName;
            value = "${plugin}/lib/node_modules/${plugin.packageName}";
          }
        ) (lib.filter (source: !catalog.${source}.bundled) profile.plugins)
      );

      bundles = map (plugin: catalog.${plugin}.packageName) profile.plugins;
    in
    {
      ".dsh/profiles/${name}/package.json".text = builtins.toJSON {
        name = "deepseek-harness-profile-${name}";
        private = true;

        dependencies = lib.mapAttrs (_: path: "file:${path}") packages;

        dsh.profile = {
          inherit bundles;
        };
      };
    }
    // lib.mapAttrs' (packageName: path: {
      name = ".dsh/profiles/${name}/node_modules/${packageName}";
      value.source = path;
    }) packages
    // lib.optionalAttrs (profile.patch != { }) {
      ".dsh/profiles/${name}/cordis.patch.yml".source =
        yaml.generate "dsh-${name}-patch.yml" profile.patch;
    }
  ) cfg.profiles;
in
{
  options.programs.deepseek-harness = {
    enable = lib.mkEnableOption "DeepSeek Harness";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/deepseek-harness { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/deepseek-harness { }";
      description = ''
        DeepSeek Harness package. Enabling purge applies its patches to all profiles.
      '';
    };

    settings = lib.mkOption {
      type = yaml.type;
      default = { };
      description = ''
        Settings written to ~/.dsh/settings.yaml. Refer to secrets by an
        environment variable (for example, apiKeyEnv = "DEEPSEEK_API_KEY")
        instead of putting secret values in this option.
      '';
    };

    cordisPatch = lib.mkOption {
      type = yaml.type;
      default = { };
      description = "Home-level Cordis patch written to ~/.dsh/cordis.patch.yml.";
    };

    agentsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "Global agent instructions written to ~/.dsh/AGENTS.md.";
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf profileType;
      default = { };
      description = "Profiles and plugins managed by Home Manager.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.mapAttrsToList (name: _: {
      assertion =
        !(
          lib.hasInfix "/" name
          || lib.hasInfix "\\" name
          || builtins.elem name [
            ""
            "."
            ".."
            "node_modules"
          ]
        );
      message = "programs.deepseek-harness.profiles: invalid profile name ${name}";
    }) cfg.profiles;

    home.packages = [ installedPackage ];

    home.file =
      profileFiles
      // lib.optionalAttrs (cfg.settings != { }) {
        ".dsh/settings.yaml".source = yaml.generate "deepseek-harness-settings.yaml" cfg.settings;
      }
      // lib.optionalAttrs (cfg.cordisPatch != { }) {
        ".dsh/cordis.patch.yml".source = yaml.generate "deepseek-harness-cordis.patch.yml" cfg.cordisPatch;
      }
      // lib.optionalAttrs (cfg.agentsFile != null) {
        ".dsh/AGENTS.md".text = cfg.agentsFile;
      };
  };
}
