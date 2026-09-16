{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.tailscale;
in

{
  options.abszero.services.tailscale.enable = mkEnableOption "Tailscale client";

  config = mkIf cfg.enable {
    systemd.services.tailscale-serve.enable = false; # TODO: remove
    services.tailscale = {
      enable = true;
      disableUpstreamLogging = true;
      serve.enable = mkIf (config.services.tailscale.serve.services != { }) true;
    };
  };
}
