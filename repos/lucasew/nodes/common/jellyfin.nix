{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption length head tail types mapAttrs attrValues;
  cfg = config.services.jellyfin-container;
in {
  options.services.jellyfin-container = {
    enable = mkEnableOption "jellyfin";
    mediaDirs = mkOption {
      description = "Media folders";
      type = types.attrsOf types.path;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.jellyfin = {
      image = "jellyfin/jellyfin:latest";
      volumes = [ "/var/lib/jellyfin:/config" "/var/cache/jellyfin:/cache" ]
      ++ (attrValues (mapAttrs (k: v: "${v}:/media/${k}:ro") cfg.mediaDirs));
      extraOptions = [ "--network=host" ];
    };

    services.nginx.virtualHosts."jellyfin.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };
    networking.firewall.allowedUDPPorts = [ 1900 7359 ];

  };
}
