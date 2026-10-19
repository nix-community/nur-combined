{
  config,
  lib,
  ...
}:
let
  service = "miniflux";
  hl = config.homelab;
  cfg = hl.services.${service};
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where miniflux actually runs, if not this machine";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        postgres = "miniflux";
      };
      description = "What to back up for miniflux; see homelab/services/restic";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "news.avyay.in";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Miniflux";
    };
    glance.description = lib.mkOption {
      type = lib.types.str;
      default = "Minimalist and opinionated feed reader";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
    adminCredentialsFile = lib.mkOption {
      description = "File with admin credentials";
      type = lib.types.path;
    };
    oauthClientIdFile = lib.mkOption {
      description = "File containing the indiko OAuth2 client ID";
      type = lib.types.path;
    };
    oauthClientSecretFile = lib.mkOption {
      description = "File containing the indiko OAuth2 client secret";
      type = lib.types.path;
    };
    role = lib.mkOption {
      type = lib.types.enum [
        "client"
        "server"
      ];
      default = "client";
    };
  };
  config =
    let
      addr = "127.0.0.1";
      port = 8067;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        (lib.mkIf (cfg.host == "127.0.0.1") {
          services.${service} = {
            enable = true;
            inherit (cfg) adminCredentialsFile;
            config = {
              BASE_URL = "https://${cfg.url}";
              CREATE_ADMIN = true;
              LISTEN_ADDR = "${addr}:${toString port}";
              OAUTH2_PROVIDER = "oidc";
              OAUTH2_CLIENT_ID_FILE = cfg.oauthClientIdFile;
              OAUTH2_CLIENT_SECRET_FILE = cfg.oauthClientSecretFile;
              OAUTH2_REDIRECT_URL = "https://${cfg.url}/oauth2/oidc/callback";
              OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://${hl.services.indiko.domain}";
              OAUTH2_USER_CREATION = "1";
              DISABLE_LOCAL_AUTH = "false";
            };
          };
        })
        {
          services.caddy.virtualHosts."${cfg.url}" = {
            useACMEHost = "avyay.in";
            extraConfig = ''
              reverse_proxy http://${cfg.host}:${toString port}
            '';
          };
        }
      ]
    );
}
