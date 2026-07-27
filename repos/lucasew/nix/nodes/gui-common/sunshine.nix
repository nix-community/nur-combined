{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.sunshine;
in

{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.sunshine.settings = {
      motion_as_ds4 = true;
      touchpad_as_ds4 = true;
    };

    systemd.user.services.sunshine = {
      serviceConfig = {
        Restart = "on-failure";
      };
    };
  };
}
