# gps-share: <https://github.com/zeenix/gps-share>
# takes a local GPS device (e.g. /dev/ttyUSB1) and makes it available over TCP/Avahi (multicast DNS).
#
# common usecases:
# 1. make positioning available to any device on a network, even if that device has no local GPS
#    - e.g. my desktop can use my phone's GPS device, if on the same network.
# 2. allow multiple clients to share a GPS device.
#    GPS devices are serial devices, and so only one process can consume the data at a time.
#    gps-share can camp the serial device, and then allow *multiple* subscribers
# 3. provide a *read-only* API to clients like Geoclue.
#    that is, expose the GPS device *output* to a client, but don't let the client write to the device (e.g. enable/disable the GPS).
#    this is the primary function i derive from gps-share
#
# HOW TO TEST:
# - `nc localhost 10110`
#   should stream GPS NMEA output to the console
# - `avahi-browse --resolve _nmea-0183._tcp`: should show hosts on the local network which provide GPS info
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.gps-share;
in
{
  sane.programs.gps-share = {
    suggestedPrograms = [
      "jq"
      # and systemd, for udevadm
    ];

    sandbox.net = "all";
    sandbox.autodetectCliPaths = "existing";  #< N.B.: `test -f /dev/ttyUSB1` fails, we can't use `existingFile`
    sandbox.whitelistDbus = [ "system" ];  #< to register with Avahi

    services.gps-share = {
      description = "gps-share: make local GPS serial readings available over Avahi";
      # usage:
      # gps-share --no-announce  # to disable Avahi
      # gps-share --no-tcp  # only makes sense if using --socket-path
      # gps-share --network-interface lo  # defaults to all interfaces, but firewalling means actually more restrictive
      # gps-share --socket-path $XDG_RUNTIME_DIR/gps-share/gps-share.sock  # share over a unix socket
      command = pkgs.writeShellScript "gps-share" ''
        dev=$(udevadm info --property-match=ID_MM_PORT_TYPE_GPS=1 --json=pretty --export-db | jq -r .DEVNAME)
        if [ -z "$dev" ]; then
          echo "no GPS device found"
          exit 1
        fi
        echo "using $dev for GPS NMEA"
        gps-share "$dev"
      '';
      # N.B.: it fails to launch if the NMEA device doesn't yet exist, so don't launch by default; only launch as part of GPS
      # dependencyOf = [ "geoclue-agent" ];
      partOf = [ "gps" ];
      depends = [ "eg25-control-powered" ];
    };
  };

  # TODO: restrict this to just LAN devices!!
  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enabled [ 10110 ];
}
