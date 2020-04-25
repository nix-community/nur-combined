{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gpxsee;

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
  meta.maintainers = with maintainers; [ sikmir ];

  options.programs.gpxsee = {
    enable = mkEnableOption "GPS log file viewer and analyzer";

    package = mkOption {
      default = pkgs.gpxsee;
      defaultText = literalExample "pkgs.gpxsee";
      description = "GPXSee package to install.";
      type = types.package;
    };

    demPackage = mkOption {
      default = null;
      description = "GPXSee DEM package to install.";
      type = types.nullOr types.package;
    };

    mapsPackage = mkOption {
      default = null;
      description = "GPXSee maps package to install.";
      type = types.nullOr types.package;
    };

    poiPackages = mkOption {
      default = [];
      description = "GPXSee POI packages to install.";
      type = types.listOf types.package;
    };

    stylesPackage = mkOption {
      default = null;
      description = "QtPBFImagePlugin styles package to install.";
      type = types.nullOr types.package;
    };

    maps = mkOption {
      default = [];
      description = "";
      type = types.listOf types.str;
    };

    style = mkOption {
      default = "";
      description = "Style for MVT usable with QtPBFImagePlugin";
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = [ cfg.package pkgs.qtpbfimageplugin ];
      }

      (
        mkIf (cfg.demPackage != null) {
          home.file."${demDir}".source =
            "${cfg.demPackage}/share/gpxsee/DEM";
        }
      )

      (
        let
          mapXml = map: {
            name = "${mapDir}/${map}";
            value.source = "${cfg.mapsPackage}/share/gpxsee/maps/${map}";
          };
        in mkIf (cfg.mapsPackage != null && cfg.maps != []) {
          home.file = listToAttrs (map mapXml cfg.maps);
        }
      )

      (
        let
          mapPoi = poi: {
            name = "${poiDir}/${poi.name}";
            value.source = "${poi}/share/gpxsee/POI";
          };
        in mkIf (cfg.poiPackages != []) {
          home.file = listToAttrs (map mapPoi cfg.poiPackages);
        }
      )

      (
        mkIf (cfg.stylesPackage != null && cfg.style != "") {
          home.file."${styleDir}".source =
            "${cfg.stylesPackage}/share/gpxsee/style/${cfg.style}";
        }
      )
    ]
  );
}
