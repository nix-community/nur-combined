{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.merkaartor;
  configDir = "${config.xdg.configHome}/Merkaartor";
  configFile = "${configDir}/Merkaartor.conf";
  domain = "org.merkaartor.Merkaartor";
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.merkaartor = {
    enable = mkEnableOption "OpenStreetMap editor";

    package = mkOption {
      default = pkgs.merkaartor;
      defaultText = literalExample "pkgs.merkaartor";
      description = "Merkaartor package to install.";
      type = types.package;
    };

    user = mkOption {
      default = "";
      description = "OSM user.";
      type = types.str;
    };

    password = mkOption {
      default = "";
      description = "OSM password.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = [ cfg.package ];
      }

      (
        mkIf pkgs.stdenv.isLinux {
          home.activation.createConfigFile = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p ${configDir}
            $DRY_RUN_CMD touch ${configFile}
          '';
        }
      )

      (
        mkIf (cfg.user != "" && cfg.password != "") {
          home.activation.setupCredentials = lib.hm.dag.entryAfter [ "writeBoundary" ]
            (
              if pkgs.stdenv.isDarwin then ''
                $DRY_RUN_CMD /usr/bin/defaults write ${domain} OsmServers.1.url https://api.openstreetmap.org/api
                $DRY_RUN_CMD /usr/bin/defaults write ${domain} OsmServers.1.selected true
                $DRY_RUN_CMD /usr/bin/defaults write ${domain} OsmServers.1.user ${cfg.user}
                $DRY_RUN_CMD /usr/bin/defaults write ${domain} OsmServers.1.password ${cfg.password}
                $DRY_RUN_CMD /usr/bin/defaults write ${domain} OsmServers.size 1
              '' else ''
                $DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} OsmServers 1\\\\url https://api.openstreetmap.org/api
                $DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} OsmServers 1\\\\selected true
                $DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} OsmServers 1\\\\user ${cfg.user}
                $DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} OsmServers 1\\\\password ${cfg.password}
                $DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} OsmServers size 1
              ''
            );
        }
      )
    ]
  );
}
