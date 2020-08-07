{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gpxsee;
  configDir = "${config.xdg.configHome}/gpxsee";
  configFile = "${configDir}/gpxsee.conf";
  domain = "com.gpxsee.GPXSee";

  appDataLocation =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/GPXSee"
    else
      "${config.xdg.dataHome}/gpxsee";
  demDir = "${appDataLocation}/DEM";
  mapDir = "${appDataLocation}/maps";
  poiDir = "${appDataLocation}/POI";
  styleDir = "${appDataLocation}/style";
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.gpxsee = {
    enable = mkEnableOption "GPS log file viewer and analyzer";

    package = mkOption {
      default = pkgs.gpxsee;
      defaultText = literalExample "pkgs.gpxsee";
      example = "pkgs.nur.repos.sikmir.gpxsee-bin";
      description = "GPXSee package to install.";
      type = types.package;
    };

    demPackage = mkOption {
      default = null;
      example = "pkgs.nur.repos.sikmir.dem";
      description = "DEM package to install.";
      type = types.nullOr types.package;
    };

    mapPackages = mkOption {
      default = [ ];
      example = [
        "pkgs.nur.repos.sikmir.gpxsee-maps"
        "pkgs.nur.repos.sikmir.maptourist"
      ];
      description = "Map packages to install.";
      type = types.listOf types.package;
    };

    poiPackages = mkOption {
      default = [ ];
      example = [
        "pkgs.nur.repos.sikmir.gpxsee-poi.geocachingSu"
        "pkgs.nur.repos.sikmir.gpxsee-poi.westra"
      ];
      description = "POI packages to install.";
      type = types.listOf types.package;
    };

    stylePackage = mkOption {
      default = null;
      example = "pkgs.nur.repos.sikmir.qtpbfimageplugin-styles";
      description = "QtPBFImagePlugin style package to install.";
      type = types.nullOr types.package;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = [ cfg.package pkgs.qtpbfimageplugin ];

        home.activation.hideToolbar =
          config.lib.dag.entryAfter [ "writeBoundary" ]
            (
              if pkgs.stdenv.isDarwin then
                "$DRY_RUN_CMD /usr/bin/defaults write ${domain} Settings.toolbar -bool false"
              else
                "$DRY_RUN_CMD ${pkgs.crudini}/bin/crudini $VERBOSE_ARG --set ${configFile} Settings toolbar 0"
            );
      }

      (
        mkIf pkgs.stdenv.isLinux {
          home.activation.createConfigFile = config.lib.dag.entryBefore [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p ${configDir}
            $DRY_RUN_CMD touch ${configFile}
          '';
        }
      )

      (
        mkIf (cfg.demPackage != null) {
          home.file."${demDir}".source = "${cfg.demPackage}";
        }
      )

      (
        mkIf (length cfg.mapPackages > 0) {
          home.file = listToAttrs (
            map
              (m: {
                name = "${mapDir}/${m.name}";
                value.source = "${m}";
              })
              cfg.mapPackages
          );
        }
      )

      (
        mkIf (length cfg.poiPackages > 0) {
          home.file = listToAttrs (
            map
              (p: {
                name = "${poiDir}/${p.name}";
                value.source = "${p}";
              })
              cfg.poiPackages
          );
        }
      )

      (
        mkIf (cfg.stylePackage != null) {
          home.file."${styleDir}".source = "${cfg.stylePackage}";
        }
      )
    ]
  );
}
