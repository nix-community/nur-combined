{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gpxsee;
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
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      gpxsee-maps
      qtpbfimageplugin
      qtpbfimageplugin-styles
    ];
  };
}
