{ config, pkgs, lib, ... }:

let
  inherit (pkgs) v2ray-rules-dat;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.v2raya;
in

{
  options.abszero.services.v2raya.enable =
    mkEnableOption "cross-platform v2ray client";

  config = mkIf cfg.enable {
    # TODO: Add package option to upstream
    nixpkgs.overlays = [
      (_: prev: {
        v2raya = prev.v2raya.override {
          v2ray-geoip = v2ray-rules-dat.geoip;
          v2ray-domain-list-community = v2ray-rules-dat.geosite;
        };
      })
    ];
    networking.firewall.allowedTCPPorts = [ 10808 10809 10810 ];
    services.v2raya.enable = true;
  };
}
