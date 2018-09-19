{ config, pkgs, ... }:

{
  # https://productforums.google.com/d/msg/chromecast/G3E2ENn-YZI/s7Xoz6ICCwAJ

  networking.firewall.allowedTCPPorts = [
    8008 8009

    # videostream requests these open:
    5556 5558
  ];

  networking.firewall.allowedUDPPorts = [
    1900 5353
  ];
}
