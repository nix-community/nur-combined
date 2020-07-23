{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.josm;
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.josm = {
    enable = mkEnableOption "An extensible editor for OpenStreetMap";

    package = mkOption {
      default = pkgs.josm;
      defaultText = literalExample "pkgs.josm";
      description = "JOSM package to install.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
