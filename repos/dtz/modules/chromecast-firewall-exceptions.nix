{ config, pkgs, ... }:

{
  # https://productforums.google.com/d/msg/chromecast/G3E2ENn-YZI/s7Xoz6ICCwAJ

  networking.firewall = {
    allowedTCPPorts = [
      8008 8009

      # videostream requests these open: (not range?)
      5556 5558

      # VLC used this
      8010
    ];
    # castnow wiki
    allowedTCPPortRanges = [ { from = 4100; to = 4105; } ];

    allowedUDPPorts = [ 1900 5353 ];
  };
}
