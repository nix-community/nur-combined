{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.romm;
  hl = config.homelab;
  port = 8081;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.romm = {
    enable = lib.mkEnableOption "RomM ROM manager";

    url = lib.mkOption {
      type = lib.types.str;
      default = "romm.${hl.baseDomainName}";
      description = "Domain to serve RomM on";
    };
    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        postgres = "romm";
        files = [ config.services.romm.dataDir ];
      };
      description = "RomM database and library to back up; see homelab/services/restic";
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Runtime environment file with metadata provider credentials (e.g. IGDB_CLIENT_ID and IGDB_CLIENT_SECRET)";
    };
    gatus = import ../../lib/gatusEndpoint.nix {
      inherit lib;
      name = "RomM";
      url = "https://${cfg.url}";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "RomM";
    };
    glance.description = lib.mkOption {
      type = lib.types.str;
      default = "ROM manager and game library";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for RomM in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable {
    services.romm = {
      enable = true;
      inherit (cfg) environmentFile;
      nginx.virtualHost = cfg.url;
      # TLS terminates at Caddy rather than the local nginx virtual host.
      extraEnvironment = {
        ROMM_BASE_URL = "https://${cfg.url}";
        ROMM_SESSION_SECURE_COOKIE = "true";
      };
    };

    # RomM's nginx host serves the frontend, downloads and emulator assets;
    # the backend alone cannot be reverse-proxied directly.
    services.nginx.virtualHosts.${cfg.url}.listen = [
      {
        addr = "127.0.0.1";
        inherit port;
      }
    ];

    services.caddy.virtualHosts.${cfg.url} = {
      useACMEHost = hl.acmeHostFor cfg.url;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString port}
      '';
    };

    systemd.services.romm.serviceConfig.OnFailure = lib.mkIf (
      hl.notifications.ntfySecretsFile != null
    ) "notify-failure@%n.service";
  };
}
