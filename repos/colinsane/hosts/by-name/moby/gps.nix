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

{ ... }:
{
  services.gpsd.enable = true;
  services.gpsd.devices = [ "/dev/ttyUSB1" ];

  # TODO: enable eg25-manager, and bring online both the modem and GPS on boot
}
