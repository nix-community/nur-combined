{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkAfter;
  cfg = config.abszero.services.tailscale;
in

{
  options.abszero.services.tailscale.enable = mkEnableOption "Tailscale client";

  config = mkIf cfg.enable {
    # MagicDNS
    networking = {
      nameservers = mkAfter [
        "fd7a:115c:a1e0::53"
        "100.100.100.100"
      ];
      # search = [ config.networking.domain ];
    };
    systemd.services.tailscale-serve.enable = false; # TODO: remove
    services.tailscale = {
      enable = true;
      disableUpstreamLogging = true;
      serve.enable = mkIf (config.services.tailscale.serve.services != { }) true;
    };
  };
}
