# geoclue location services daemon.
#
# SUPPORT:
# - irc: #gnome-maps on irc.gimp.org
# - Matrix: #gnome-maps:gnome.org  (unclear if bridged to IRC)
# - forums: <https://discourse.gnome.org/c/platform>
# - git: <https://gitlab.freedesktop.org/geoclue/geoclue/>
# - D-Bus API docs: <https://www.freedesktop.org/software/geoclue/docs/>
#
# HOW TO TEST:
# - just invoke `where-am-i`: it should output the current latitude/longitude.
## more manual testing:
# - build `geoclue2-with-demo-agent`
# - run the service: `systemctl start geoclue` or "${geoclue2-with-demo-agent}/libexec/geoclue"
# - run "${geoclue2-with-demo-agent}/libexec/geoclue-2.0/demos/agent"
#   - keep this running in the background
# - run "${geoclue2-with-demo-agent}/libexec/geoclue-2.0/demos/where-am-i"
#
# DATA FLOW:
# - geoclue2 does http calls into local `ols`, which either hits the local disk or queries https://wigle.net.
# - geoclue users like gnome-maps somehow depend on an "agent",
#   a user service which launches the geoclue system service on-demand (via dbus activation).
#
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.geoclue2;
in
{
  sane.programs.geoclue2 = {
    # packageUnwrapped = pkgs.rmDbusServices pkgs.geoclue2;
    # packageUnwrapped = pkgs.geoclue2.override { withDemoAgent = true; };
    packageUnwrapped = pkgs.geoclue2-with-demo-agent;
    suggestedPrograms = [
      "avahi"  #< to discover LAN gps devices
      "geoclue-demo-agent"
      # "gps-share"
      "iio-sensor-proxy"
      "ols"  #< WiFi SSID -> lat/long lookups
      "satellite"  #< graphical view into GPS fix data
      "where-am-i"  #< handy debugging/testing tool
    ];

    # XXX(2024/07/05): no way to plumb my sandboxed geoclue into `services.geoclue2`.
    # then, the package doesn't get used directly anywhere. but other programs reference `packageUnwrapped`,
    # so keep that part still.
    sandbox.enable = false;
    package = lib.mkForce null;

    # experimental sandboxing (2024/07/05)
    # sandbox.whitelistDbus.system = true;
    # sandbox.net = "all";
  };

  # sane.programs.geoclue2.enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;

  services.geoclue2 = lib.mkIf cfg.enabled {
    enable = true;
    geoProviderUrl = "http://127.0.0.1:8088/v1/geolocate";  #< ols
    # XXX(2024/06/25): when Geoclue uses ModemManager's GPS API, it wants to enable GPS
    # tracking at the start, and disable it at the end. that causes tracking to be lost, regularly.
    # this is not optional behavior: if Geoclue fails to control modem manager (because of a polkit policy, say),
    # then it won't even try to read the data from modem manager.
    # SOLUTION: tell Geoclue to get GPS from gps-share ("enableNmea", i.e. `network-nmea.enable`)
    # and NOT from modem manager.
    enableModemGPS = false;
    enableNmea = true;
  };
  systemd.user.services = lib.mkIf cfg.enabled {
    # nixos services.geoclue2 runs the agent as a user service by default, but i don't use systemd so that doesn't work.
    # i manage the agent myself, in sane.programs.geoclue-demo-agent.
    geoclue-agent.enable = false;
  };
}
