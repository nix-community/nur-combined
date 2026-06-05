# test gpsd with `gpspipe -w -n 10 2> /dev/null | grep -m 1 TPV | jq '.lat, .lon' | tr '\n' ' '`
# ^ should return <lat> <long>
#
# TODO(2024/06/19): nixpkgs' gpsd service isn't sandboxed at ALL. i should sandbox that, or remove this integration.
#
# pinephone GPS happens in EG25 modem
# serial control interface to modem is /dev/ttyUSB2
# after enabling GPS, readout is /dev/ttyUSB1
#
# minimal process to enable modem and GPS:
# - `echo 1 > /sys/class/modem-power/modem-power/device/powered`
# - `screen /dev/ttyUSB2 115200`
#   - `AT+QGPSCFG="nmeasrc",1`
#   - `AT+QGPS=1`
# this process is automated by my `eg25-control` program and services (`eg25-control-powered`, `eg25-control-gps`)
# - see the `modules/` directory further up this repository.
#
# now, something like `gpsd` can directly read from /dev/ttyUSB1,
# or geoclue can query the GPS directly through modem-manager
#
# initial GPS fix can take 15+ minutes.
# meanwhile, services like eg25-manager or eg25-control-freshen-agps can speed this up by uploading assisted GPS data to the modem.
{ config, lib, ... }:
let
  cfg = config.sane.programs.gpsd;
in
{
  sane.programs.gpsd = {};
  services.gpsd = lib.mkIf cfg.enabled {
    enable = true;
    devices = [ "/dev/ttyUSB1" ];
  };
}
