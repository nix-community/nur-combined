{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkPackageOption mkEnableOption mkIf;

  cfg = config.services.ssacli;
in
{
  options.services.ssacli = {
    enable = mkEnableOption "ssacli: The HPE Smart Storage Administrator CLI is a commandline-based disk configuration program that helps you configure, manage, diagnose, and monitor HPE ProLiant Smart Array Controllers";
    package = mkPackageOption pkgs "ssacli" { };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "sg" ];
    environment.systemPackages = [ cfg.package ];
  };
}
