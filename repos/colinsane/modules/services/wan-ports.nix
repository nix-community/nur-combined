{ config, lib, ... }:
let
  cfg = config.sane.services.wan-ports;
in
{
  options = with lib; {
    sane.services.wan-ports = {
      openFirewall = mkOption {
        default = false;
        type = types.bool;
      };

      # TODO: openUpnp option

      # TODO: rework this to look like:
      # ports.53 = {
      #   protocol = [ "udp" "tcp" ];  # have this be default
      #   visibility = "wan";  # or "lan"
      # }
      tcp = mkOption {
        type = types.listOf types.int;
        default = [];
      };
      udp = mkOption {
        type = types.listOf types.int;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.openFirewall {
    networking.firewall.allowedTCPPorts = cfg.tcp;
    networking.firewall.allowedUDPPorts = cfg.udp;
  };
}
