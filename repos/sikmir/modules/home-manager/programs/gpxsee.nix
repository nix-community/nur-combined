{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gpxsee;

  appDataLocation =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/GPXSee"
    else
      "${config.xdg.dataHome}/gpxsee";
  mapDir = "${appDataLocation}/maps";
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

    mapsPackage = mkOption {
      default = pkgs.gpxsee-maps;
      description = "GPXSee maps package to install.";
      type = types.package;
    };

    stylesPackage = mkOption {
      default = pkgs.qtpbfimageplugin-styles;
      description = "QtPBFImagePlugin styles package to install.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package pkgs.qtpbfimageplugin ];

    home.file."${mapDir}/OpenStreetMap.xml".source =
      if pkgs.stdenv.isDarwin then
        "${cfg.package}/Applications/GPXSee.app/Contents/Resources/maps/OpenStreetMap.xml"
      else
        "${cfg.package}/share/gpxsee/maps/OpenStreetMap.xml";
    home.file."${mapDir}/OpenTopoMap-RU.xml".source =
      "${cfg.mapsPackage}/share/gpxsee/maps/World/Europe/RU/OpenTopoMap-RU.xml";
    home.file."${mapDir}/nakarte-ggc500.xml".source =
      "${cfg.mapsPackage}/share/gpxsee/maps/World/Europe/RU/nakarte-ggc500.xml";
    home.file."${mapDir}/Karjalankartta20k.xml".source =
      "${cfg.mapsPackage}/share/gpxsee/maps/World/Europe/FI/Karjalankartta20k.xml";
    home.file."${mapDir}/Maastokartta.xml".source =
      "${cfg.mapsPackage}/share/gpxsee/maps/World/Europe/FI/Maastokartta.xml";
    home.file."${mapDir}/CyclOSM.xml".source =
      "${cfg.mapsPackage}/share/gpxsee/maps/World/CyclOSM.xml";
    home.file."${mapDir}/MapTiler.xml".source =
      "${cfg.mapsPackage}/share/gpxsee/maps/World/MapTiler.xml";

    home.file."${appDataLocation}/style".source =
      "${cfg.stylesPackage}/share/gpxsee/style/OpenMapTiles/klokantech-basic";
  };
}
