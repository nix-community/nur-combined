{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.volta;
in
{
  options.programs.volta = {
    enable = lib.mkEnableOption "Enable volta";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.volta;
      description = "The volta package to use";
    };
    voltaHome = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.volta";
      description = "The directory where volta does its thing";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.sessionVariables = {
      VOLTA_HOME = cfg.voltaHome;
      NODE_ENV = "development";
      RUN_ENV = "local";
    };
  };
}
