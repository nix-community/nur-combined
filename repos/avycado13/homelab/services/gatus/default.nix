{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.gatus;
  hl = config.homelab;
  port = 8087;

  # Keep the monitored endpoints explicit until we decide which services to
  # discover automatically. These are public URLs, not local service ports.
  hosts = [
    {
      name = "Auth";
      url = "https://auth.avyay.in";
    }
    {
      name = "Miniflux";
      url = "https://news.avyay.in";
    }
    {
      name = "Glance";
      url = "https://glance.avyay.in";
    }
    {
      name = "Nix cache";
      url = "https://cache.avyay.in";
    }
    {
      name = "Navidrome";
      url = "https://music.avyay.in";
    }
  ];
in
{
  options.homelab.services.gatus = {
    enable = lib.mkEnableOption "Gatus status page";
    url = lib.mkOption {
      type = lib.types.str;
      default = "status.${hl.baseDomainName}";
      description = "Domain to serve Gatus on";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Gatus";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        web = {
          address = "127.0.0.1";
          inherit port;
        };
        endpoints = map (
          host:
          host
          // {
            interval = "5m";
            conditions = [ "[STATUS] < 400" ];
          }
        ) hosts;
      };
    };

    systemd.services.gatus.unitConfig.OnFailure = lib.mkIf (
      hl.notifications.ntfySecretsFile != null
    ) "notify-failure@%n.service";

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = hl.acmeHostFor cfg.url;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString port}
      '';
    };
  };
}
