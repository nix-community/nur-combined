{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.qmapshack;
in
{
  meta.maintainers = with maintainers; [ sikmir ];

  options.programs.qmapshack = {
    enable = mkEnableOption "Consumer grade GIS software";

    package = mkOption {
      default = pkgs.qmapshack;
      defaultText = literalExample "pkgs.qmapshack";
      description = "QMapShack package to install.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
