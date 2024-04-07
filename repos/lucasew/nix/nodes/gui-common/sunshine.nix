{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.sunshine;
in

{
  options = {
    programs.sunshine = {
      enable = lib.mkEnableOption "sunshine";
      package = lib.mkPackageOption pkgs "sunshine" { };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.sunshine = {
      script = lib.getExe cfg.package;
      serviceConfig = {
        Restart = "on-failure";
      };
    };
  };
}
