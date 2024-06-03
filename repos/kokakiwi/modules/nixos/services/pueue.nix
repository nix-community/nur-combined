{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.pueue;

  yamlFormat = pkgs.formats.yaml { };
  configFile = let
    fullConfig = {
      shared = { };
    } // cfg.settings;
  in yamlFormat.generate "pueue.yml" fullConfig;
in {
  options.services.pueue = {
    enable = mkEnableOption "Pueue, CLI process scheduler and manager";

    package = mkPackageOption pkgs "pueue" { };

    settings = mkOption {
      type = yamlFormat.type;
      default = { };
      example = literalExpression ''
        {
          daemon = {
            default_parallel_tasks = 2;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."pueue/pueue.yml".source = configFile;
    environment.variables.PUEUE_CONFIG_PATH = "/etc/pueue/pueue.yml";

    systemd.user.services.pueued = {
      description = "Pueue Daemon - CLI process scheduler and manager";
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Restart = "on-failure";
        ExecStart = "${cfg.package}/bin/pueued -v -c ${configFile}";
      };
    };
  };
}
