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
    mkOption
    types
    ;

  cfg = config.my.services.tailscale;
in {
  options.my.services.tailscale = {
    enable = mkEnableOption "Tailscale";
    useRoutingFeatures = mkOption {
      type = types.enum ["none" "client" "server" "both"];
      default = "none";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      package = pkgs.tailscale;
      openFirewall = true;
      useRoutingFeatures = cfg.useRoutingFeatures;
    };

    networking.firewall = {
      trustedInterfaces = [config.services.tailscale.interfaceName];
    };
  };
}
