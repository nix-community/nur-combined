{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.shiori;
  hl = config.homelab;
  port = 8090;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.shiori = {
    enable = lib.mkEnableOption "Shiori bookmark manager";

    url = lib.mkOption {
      type = lib.types.str;
      default = "bookmarks.${hl.baseDomainName}";
      description = "Domain to serve Shiori on";
    };
    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        sqlite = "/var/lib/shiori/shiori.db";
      };
      description = "What to back up for Shiori; see homelab/services/restic";
    };
    gatus = import ../../lib/gatusEndpoint.nix {
      inherit lib;
      name = "Shiori";
      url = "https://${cfg.url}";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Shiori";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable {
    services.shiori = {
      enable = true;
      address = "127.0.0.1";
      inherit port;
    };

    systemd.services.shiori.unitConfig.OnFailure = lib.mkIf (
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
