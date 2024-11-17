# chat (Matrix): #iio-sensor-proxy:dylanvanassche.be
# src: <https://gitlab.freedesktop.org/hadess/iio-sensor-proxy>
# IIO = "Industrial I/O": <https://www.kernel.org/doc/html/v4.12/driver-api/iio/index.html>
# iio-sensor-proxy reads IIO data reported by the kernel at /sys/bus/iio/* and makes it available to dbus applications.
# this includes:
# - ambient light sensor
# - compass/magnetometer  (LIMITED)
# - accelerometer (rotation)
#
# use:
# - show available sensors: `gdbus introspect --system --dest net.hadess.SensorProxy --object-path /net/hadess/SensorProxy`
# - read sensors: `sudo -u geoclue monitor-sensor --compass`
#   - default dbus policy only allows geoclue to use the compass
#   - `sudo monitor-sensor` for light/rotation
#
# HARDWARE SUPPORT: PINEPHONE (2024/07/01)
# - accelerometer and light sensor seem to work
# - magnetometer (af8133j, different but similar to lis3mdl) IS NOT SUPPORTED
#   - <https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/issues/310>
#   - exists in sysfs and can be viewed with
#     `cat /sys/devices/platform/soc/1c2b000.i2c/i2c-1/1-001c/iio:device2/in_magn_x_raw`
#   - nothing in iio-sensor-proxy reads anything related to "magn".
#   - WIP PR to support magnetometers: <https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/merge_requests/316>
#     - after rebase, it *functions*, but does not scale the readings correctly
#       heading changes only over the range of 50 - 70 deg.
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.iio-sensor-proxy;
in
{
  sane.programs.iio-sensor-proxy = {
    packageUnwrapped = pkgs.iio-sensor-proxy.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          name = "WIP:compass: Add support for polling uncalibrated devices";
          # url = "https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/merge_requests/316.diff";
          url = "https://git.uninsane.org/colin/iio-sensor-proxy/commit/fd21f1f4bf1eadd603b1f24f628b979691d9cf3b.diff";
          hash = "sha256-+GoEPby6q+uSkQlZWFWr5ghx3BKBMGk7uv/DDhGnxDk=";
        })
      ];
    });
    enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;  #< for dbus/polkit policies

    sandbox.whitelistDbus = [ "system" ];
    sandbox.extraPaths = [
      "/run/udev/data"
      "/sys/bus"
      "/sys/devices"
    ];
  };
  services.udev.packages = lib.mkIf cfg.enabled [ cfg.package ];
  # services.dbus.packages = lib.mkIf cfg.enabled [ cfg.package ];  #< for bus ownership policy
  systemd.packages = lib.mkIf cfg.enabled [ cfg.package ];  #< for iio-sensor-proxy.service
}
