{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.scrutiny;
  hl = config.homelab;
  port = 8086;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.scrutiny = {
    enable = lib.mkEnableOption "Scrutiny SMART disk health monitoring";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where scrutiny actually runs, if not this machine";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        # SMART history db; low-value but cheap to keep (state dir per the
        # upstream scrutiny NixOS module).
        files = [ "/var/lib/scrutiny" ];
      };
      description = "What to back up for scrutiny; see homelab/services/restic";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain to serve Scrutiny on";
    };
    # Shoutrrr notification URLs — see https://containrrr.dev/shoutrrr/
    # For self-hosted ntfy: "ntfy://user:pass@ntfy.example.com/topic"
    # For ntfy.sh (no auth): "ntfy://ntfy.sh/topic"
    notifyUrls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Shoutrrr notification URLs for disk failure alerts";
      example = [ "ntfy://ntfy.example.com/disk-alerts" ];
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Scrutiny";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.domain}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        services.scrutiny = {
          enable = true;
          # Run the collector on this host to gather SMART data
          collector.enable = true;
          settings = {
            web.listen.port = port;
            notify.urls = cfg.notifyUrls;
          };
        };
      })
      {
        services.caddy.virtualHosts."${cfg.domain}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:${toString port}
          '';
        };
      }
    ]
  );
}
