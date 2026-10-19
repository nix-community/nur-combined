{
  config,
  lib,
  ...
}:
let
  service = "retrom";
  hl = config.homelab;
  cfg = hl.services.${service};
  rt = config.services.retrom;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where retrom actually runs, if not this machine";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "retrom.${hl.baseDomainName}";
      description = "Domain to serve Retrom on";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 5101;
      description = "Port the retrom service listens on";
    };
    enableDatabase = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Configure and use a local PostgreSQL database for Retrom";
    };
    dbUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "URL for a remote database. Only used when enableDatabase is false.";
    };
    contentDirectories = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption { type = lib.types.str; };
            storageType = lib.mkOption {
              type = lib.types.enum [
                "MultiFileGame"
                "SingleFileGame"
              ];
            };
          };
        }
      );
      default = [ ];
      description = "Directories Retrom scans for games";
    };
    igdb = {
      clientId = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "IGDB client ID, e.g. config.sops.placeholder.retrom-igdb-client-id";
      };
      clientSecret = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "IGDB client secret, e.g. config.sops.placeholder.retrom-igdb-client-secret";
      };
    };
    steam = {
      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Steam API key, e.g. config.sops.placeholder.retrom-steam-api-key";
      };
      userId = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Steam user ID, e.g. config.sops.placeholder.retrom-steam-user-id";
      };
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Retrom";
    };
    glance.description = lib.mkOption {
      type = lib.types.str;
      default = "Self-hosted game library manager";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        # The upstream module only merges in `connection` (port/dbUrl) when it
        # renders settings itself. Supplying configFile bypasses that, so we
        # include `connection` here too. Secrets (igdb/steam) go through a
        # sops-rendered template rather than `settings`, since `settings` is
        # written to the Nix store in plaintext via pkgs.writeText.
        sops.templates."retrom-config.json" = {
          owner = rt.user;
          inherit (rt) group;
          content = builtins.toJSON {
            connection = {
              inherit (cfg) port;
              dbUrl = if cfg.enableDatabase then "postgres:///retrom?host=/var/run/postgresql" else cfg.dbUrl;
            };
            inherit (cfg) contentDirectories;
            igdb = {
              clientId = cfg.igdb.clientId;
              clientSecret = cfg.igdb.clientSecret;
            };
            steam = {
              apiKey = cfg.steam.apiKey;
              userId = cfg.steam.userId;
            };
          };
        };
        services.${service} = {
          enable = true;
          inherit (cfg) enableDatabase;
          inherit (cfg) port;
          configFile = config.sops.templates."retrom-config.json".path;
        };
      })
      {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:${toString cfg.port}
          '';
        };
      }
    ]
  );
}
