{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.qmapshack;
  configDir = "${config.xdg.configHome}/QLandkarte";
  configFile = "${configDir}/QMapShack.conf";
  domain = "org.qlandkarte.QMapShack";
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.qmapshack = {
    enable = mkEnableOption "Consumer grade GIS software";

    package = mkOption {
      default = pkgs.qmapshack;
      defaultText = literalExample "pkgs.qmapshack";
      example = "pkgs.nur.repos.sikmir.qmapshack-bin";
      description = "QMapShack package to install.";
      type = types.package;
    };

    demPackages = mkOption {
      default = [ ];
      example = [ "pkgs.nur.repos.sikmir.dem" ];
      description = "DEM packages to install.";
      type = types.listOf types.package;
    };

    mapPackages = mkOption {
      default = [ ];
      example = [
        "pkgs.nur.repos.sikmir.qmapshack-onlinemaps"
        "pkgs.nur.repos.sikmir.maptourist"
      ];
      description = "Map packages to install.";
      type = types.listOf types.package;
    };

    routinoPackages = mkOption {
      default = [ ];
      example = [ "pkgs.nur.repos.sikmir.routinodb" ];
      description = "Routino DB packages to install.";
      type = types.listOf types.package;
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
        mkIf (length cfg.demPackages > 0) {
          home.activation.setupDemPaths =
            lib.hm.dag.entryAfter [ "writeBoundary" ]
              (
                if pkgs.stdenv.isDarwin then
                  "$DRY_RUN_CMD /usr/bin/defaults write ${domain} Canvas.demPaths -array ${toString cfg.demPackages}"
                else
                  "$DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} Canvas demPaths ${concatStringsSep "," cfg.demPackages}"
              );
        }
      )

      (
        mkIf (length cfg.mapPackages > 0) {
          home.activation.setupMapPaths =
            lib.hm.dag.entryAfter [ "writeBoundary" ]
              (
                if pkgs.stdenv.isDarwin then
                  "$DRY_RUN_CMD /usr/bin/defaults write ${domain} Canvas.mapPath -array ${toString cfg.mapPackages}"
                else
                  "$DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} Canvas mapPath ${concatStringsSep "," cfg.mapPackages}"
              );
        }
      )

      (
        mkIf (length cfg.routinoPackages > 0) {
          home.activation.setupRoutinoPaths =
            lib.hm.dag.entryAfter [ "writeBoundary" ]
              (
                if pkgs.stdenv.isDarwin then
                  "$DRY_RUN_CMD /usr/bin/defaults write ${domain} Route.routino.paths -array ${toString cfg.routinoPackages}"
                else
                  "$DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} Route routino\\\\paths ${concatStringsSep "," cfg.routinoPackages}"
              );
        }
      )
    ]
  );
}
