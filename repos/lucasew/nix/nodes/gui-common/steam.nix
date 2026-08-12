{ config, lib, ... }:
{
  # allow downloading games on the local network
  networking.firewall.allowedTCPPorts = lib.optional config.programs.steam.enable 24070;
}
