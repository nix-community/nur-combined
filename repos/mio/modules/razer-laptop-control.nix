{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.razer-laptop-control;
in
{
  options.services.razer-laptop-control = {
    enable = mkEnableOption "Enables razer-laptop-control";
    package = mkPackageOption pkgs "razer-laptop-control" { };
  };

  config = mkIf cfg.enable {
    services.upower.enable = true;
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];

    systemd.user.services."razerdaemon" = {
      description = "Razer laptop control daemon";
      unitConfig.ConditionUser = "!@system";
      serviceConfig = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/razercontrol";
        ExecStart = "${cfg.package}/libexec/daemon";
      };
      wantedBy = [ "default.target" ];
    };
  };
}
