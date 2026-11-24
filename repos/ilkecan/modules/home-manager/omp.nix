{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.omp;
  yamlFormat = pkgs.formats.yaml { };
  configFile = yamlFormat.generate "omp-config.yml" cfg.settings;
  configFileName = ".omp/agent/hm-config.yml";
in
{
  meta.maintainers = with lib.maintainers; [ ilkecan ];

  options.programs.omp = {
    enable = lib.mkEnableOption "omp, a terminal-based coding agent";

    package = lib.mkPackageOption pkgs "omp" { nullable = true; };

    configFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Additional configuration overlays, loaded in order before `settings`. Values from later files take precedence, while list settings that declare a merge strategy, such as `bash.patterns`, are combined instead. Nix paths are copied to the store. omp reports an error for a missing file instead of skipping it.
      '';
    };

    settings = lib.mkOption {
      inherit (yamlFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          bash.patterns = [
            {
              match = "git status *";
              approval = "allow";
            }
          ];
        }
      '';
      description = ''
        Configuration written to {file}`~/${configFileName}` and loaded as the last overlay through {env}`PI_CONFIG_FILES`. Overlays take precedence over project settings and over the {file}`config.yml` that omp manages, including changes made with {command}`omp config set`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.${configFileName}.source = configFile;
    home.packages = lib.optional (cfg.package != null) cfg.package;
    home.sessionVariables.PI_CONFIG_FILES = lib.concatStringsSep ":" (
      cfg.configFiles
      ++ [
        "${config.home.homeDirectory}/${config.home.file.${configFileName}.target}"
      ]
    );
  };
}
