# GPS:
# - enable: `mmcli --modem any --location-enable-gps-unmanaged`
#   - or `mmcli -m any --location-enable-gps-nmea`
#   - or use `systemctl start eg25-control-gps`
# - verify GPS is enabled: `mmcli --modem any --location-status`
# - query GPS coordinates: `mmcli -m any --location-get`
# - monitor constellation info: `mmcli -m any --location-monitor`
#   - i.e. which satellites are in view
#   - or just `cat /dev/ttyUSB1`
#
# interactions, warnings:
# - Geoclue (`where-am-i`) toggles mmcli GPS on/off every 60s, often resetting it to the "off" state
#   - see: <https://gitlab.freedesktop.org/geoclue/geoclue/-/issues/180>
#   - the effect is that GPS data is effectively useless inside apps like gnome-maps
#     i think the trick is to get "--location-enable-gps-unmanaged" gps working again
#     or use gnss-share/gpsd (this may be what "unmanaged" means).
{ pkgs, ... }:
{
  sane.programs.mmcli = {
    packageUnwrapped = pkgs.modemmanager-split.mmcli.overrideAttrs (upstream: {
      meta = upstream.meta // {
        mainProgram = "mmcli";
      };
    });

    sandbox.tryKeepUsers = true;
    sandbox.whitelistDbus.system = true;
  };
}

