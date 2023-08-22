{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption length head tail types mapAttrs attrValues mkDefault;
  cfg = config.services.jellyfin;
in {
  options.services.jellyfin = {
    mediaDirs = mkOption {
      description = "Media folders";
      type = types.attrsOf types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/jellyfin/media 700 ${cfg.user} ${cfg.group}"
    ]
      ++ (lib.pipe cfg.mediaDirs [
        (mapAttrs (k: v: "L+ /var/lib/jellyfin/media/${k} - - - - ${v}"))
        (attrValues)
      ]);

    systemd.services.jellyfin.serviceConfig = {
      ProtectSystem = "strict";
      ReadOnlyDirectories = attrValues cfg.mediaDirs;
    };

    services.nginx.virtualHosts."jellyfin.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };
    services.jellyfin.openFirewall = mkDefault true;

  };
}
