# pinephone GPS happens in EG25 modem
# serial control interface to modem is /dev/ttyUSB2
# after enabling GPS, readout is /dev/ttyUSB1
#
# minimal process to enable modem and GPS:
# - `echo 1 > /sys/class/modem-power/modem-power/device/powered`
# - `screen /dev/ttyUSB2 115200`
#   - `AT+QGPSCFG="nmeasrc",1`
#   - `AT+QGPS=1`
#
# now, something like `gpsd` can directly read from /dev/ttyUSB1.
#
# initial GPS fix can take 15+ minutes.
# meanwhile, services like eg25-manager can speed this up by uploading assisted GPS data to the modem.
#
# geoclue somehow fits in here as a geospatial provider that leverages GPS and also other sources like radio towers

{ lib, ... }:
{
  # test gpsd with `gpspipe -w -n 10 2> /dev/null | grep -m 1 TPV | jq '.lat, .lon' | tr '\n' ' '`
  # ^ should return <lat> <long>
  services.gpsd.enable = true;
  services.gpsd.devices = [ "/dev/ttyUSB1" ];

  # test geoclue2 by building `geoclue2-with-demo-agent`
  # and running "${geoclue2-with-demo-agent}/libexec/geoclue-2.0/demos/where-am-i"
  # note that geoclue is dbus-activated, and auto-stops after 60s with no caller
  services.geoclue2.enable = true;
  services.geoclue2.appConfig.where-am-i = {
    # this is the default "agent", shipped by geoclue package: allow it to use location
    isAllowed = true;
    isSystem = false;
    # XXX: setting users != [] might be causing `where-am-i` to time out
    # users = [
    #   # restrict to only one set of users. empty array (default) means "allow any user to access geolocation".
    #   (builtins.toString config.users.users.colin.uid)
    # ];
  };
  systemd.services.geoclue.after = lib.mkForce [];  #< defaults to network-online, but not all my sources require network
  users.users.geoclue.extraGroups = [
    "dialout"  # TODO: figure out if dialout is required. that's for /dev/ttyUSB1, but geoclue probably doesn't read that?
  ];

  sane.services.eg25-control.enable = true;
}
