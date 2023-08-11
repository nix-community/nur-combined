{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.xdg-open-svc;
  flakePkgs = import ../.. { inherit pkgs; };
in
{
  options.services.xdg-open-svc = {
    enable = mkEnableOption "xdg-open-svc";
    package = mkPackageOption flakePkgs "xdg-open-svc" { };
    logFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = ''
        ${config.xdg.cacheHome}/xdg-open-svc.log
      '';
      description = ''
        Path to a file to log to. If not specified, no logging will be done.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      launchd.agents.xdg-open-svc = {
        enable = true;
        config = {
          ProgramArguments = [ "${cfg.package}/bin/xdg-open-svc" ];
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = cfg.logFile;
          StandardErrorPath = cfg.logFile;
        };
      };
    })
  ];
}
