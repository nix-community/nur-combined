{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.services.tailscale;
in {
  options.my.services.tailscale = {
    enable = mkEnableOption "Tailscale";

    # NOTE: still have to do `tailscale up --advertise-exit-node`
    exitNode = mkEnableOption "Use as exit node";
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      package = pkgs.tailscale;
    };

    networking.firewall = {
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
      # needed for exit node usage
      checkReversePath = "loose";
    };

    # enable IP forwarding to use as exit node
    boot.kernel.sysctl = mkIf cfg.exitNode {
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv4.ip_forward" = true;
    };
  };
}
