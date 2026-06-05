# config docs:
# - `man 5 mako`
{ config, lib, pkgs, ... }:
{
  sane.programs.mako = {
    # we control mako as a systemd service, so have dbus not automatically activate it.
    packageUnwrapped = pkgs.rmDbusServices pkgs.mako;
    fs.".config/mako/config".symlink.text = ''
      # notification interaction mapping
      # "on-touch" defaults to "dismiss", which isn't nice for touchscreens.
      on-button-left=invoke-default-action
      on-touch=invoke-default-action
      on-button-middle=dismiss-group

      max-visible=3
      # layer:
      # - overlay: shows notifs above all else, even full-screen windows
      # - top: shows notifs above windows, but not if they're full-screen
      # - bottom; background
      layer=overlay
      # notifications can be grouped by:
      # - app-name
      # - app-icon
      # - summary
      # - body
      # possibly more: urgency, category, desktop-entry, ...
      # to group by multiple fields, join with `,`
      group-by=app-name

      # BELOW IS SXMO DEFAULTS, modified very slightly.
      # TODO: apply theme colors!

      # default-timeout=15000
      background-color=#ffffff
      text-color=#000000
      border-color=#000000
      # group-by=app-name

      [urgency=low]
      # default-timeout=10000
      background-color=#222222
      text-color=#888888

      [urgency=high]
      default-timeout=0
      background-color=#900000
      text-color=#ffffff
      background-color=#ff0000
    '';

    # mako supports activation via dbus (i.e. the daemon will be started on-demand when a
    # dbus client tries to talk to it): that works out-of-the-box just by putting mako
    # on environment.packages, but then logs are blackholed.
    services.mako = {
      description = "mako desktop notification daemon";
      partOf = [ "graphical-session" ];
      command = lib.getExe config.sane.programs.mako.package;
    };
  };
}
