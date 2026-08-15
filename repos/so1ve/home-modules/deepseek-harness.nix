{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.deepseek-harness;
  yaml = pkgs.formats.yaml { };
  profileType = lib.types.submodule {
    options = {
      bundles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Ordered list of built-in or profile-local bundle package names.";
        example = [
          "@deepseek-ai/dsh-base"
          "@deepseek-ai/dsh-headless"
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
    {
      ".dsh/profiles/${name}/package.json".text = builtins.toJSON {
        name = "deepseek-harness-profile-${name}";
        private = true;
        dsh.profile = {
          inherit (profile) bundles;
        };
      };
    }
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
      description = "DeepSeek Harness package to install.";
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
      description = ''
        Declarative profiles composed from bundles bundled with DeepSeek
        Harness. Third-party bundles must also be present in the selected
        package's Node.js dependency tree.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

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
