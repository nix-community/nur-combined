{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption length head tail types;
  cfg = config.services.jellyfin-container;
in {
  options.services.jellyfin-container = {
    enable = mkEnableOption "jellyfin";
    mediaDirs = mkOption {
      description = "Media folders";
      type = types.listOf types.path;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.jellyfin = {
      image = "jellyfin/jellyfin:latest";
      volumes = [ "/var/lib/jellyfin" "/var/cache/jellyfin" ] ++ (let
        recur = idx: origin: if (length origin) == 0 then [] else
          [ "${head origin}:/media/${toString idx}:ro" ] ++ (recur (idx + 1)) (tail origin);
      in recur 0 cfg.mediaDirs);
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
