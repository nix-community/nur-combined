{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types mkIf mkPackageOption;
  cfg = config.services.gammastep;
in

{
  options.services.gammastep = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable Gammastep to change your screen's colour temperature depending on
        the time of day.
      '';
    };

    package = mkPackageOption pkgs "gammastep" { };
  };

  config = mkIf cfg.enable {
    # gammastep configuration is now managed by workspaced templates
    # See: config/.config/gammastep/config.ini.tmpl

    systemd.user.services.gammastep = {
      path = [ cfg.package ];
      script = ''
        # Wait for WAYLAND_DISPLAY to be available
        while [ -z "$WAYLAND_DISPLAY" ]; do
          sleep 1
        done
        gammastep -c ~/.config/gammastep/config.ini
      '';
      serviceConfig = {
        RestartSec = 3;
        Restart = "on-failure";
      };
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
  };
}
