{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.openorienteering-mapper;
  configDir = "${config.xdg.configHome}/OpenOrienteering.org";
  configFile = "${configDir}/Mapper.conf";
  domain = "org.openorienteering.Mapper";
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.openorienteering-mapper = {
    enable = mkEnableOption "An orienteering mapmaking program";

    package = mkOption {
      default = pkgs.openorienteering-mapper;
      defaultText = literalExample "pkgs.openorienteering-mapper";
      example = "pkgs.nur.repos.sikmir.openorienteering-mapper-bin";
      description = "OpenOrienteering Mapper package to install.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = [ cfg.package ];
      }

      (
        mkIf pkgs.stdenv.isLinux {
          home.activation.createConfigFile = config.lib.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p ${configDir}
            $DRY_RUN_CMD touch ${configFile}
          '';
        }
      )

      {
        home.activation.tipsVisible =
          config.lib.dag.entryAfter [ "writeBoundary" ]
            (
              if pkgs.stdenv.isDarwin then
                "$DRY_RUN_CMD /usr/bin/defaults write ${domain} HomeScreen.tipsVisible -bool false"
              else
                "$DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} HomeScreen tipsVisible 0"
            );
      }
    ]
  );
}
