{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.calibre-web;
  hl = config.homelab;
  port = 8083;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.calibre-web = {
    enable = lib.mkEnableOption "Calibre-Web ebook library server";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where calibre-web actually runs, if not this machine";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        # dirOf sqlite backs up all of libraryPath, i.e. metadata.db plus
        # the book files themselves.
        sqlite = "${cfg.libraryPath}/metadata.db";
      };
      description = "What to back up for calibre-web; see homelab/services/restic";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "books.${hl.baseDomainName}";
      description = "Domain to serve Calibre-Web on";
    };
    libraryPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/calibre-web/library";
      description = ''
        Path to the Calibre library directory (must contain metadata.db;
        create one with `calibredb` before first start if starting fresh).
      '';
    };
    enableBookUploading = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow books to be uploaded via the Calibre-Web UI";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Calibre-Web";
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
        services.calibre-web = {
          enable = true;
          listen = {
            ip = "127.0.0.1";
            inherit port;
          };
          options = {
            calibreLibrary = cfg.libraryPath;
            inherit (cfg) enableBookUploading;
            enableBookConversion = true;
          };
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.libraryPath} 0750 calibre-web calibre-web -"
        ];

        systemd.services.calibre-web.unitConfig.OnFailure = lib.mkIf (
          hl.notifications.ntfySecretsFile != null
        ) "notify-failure@%n.service";
      })
      {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:${toString port}
          '';
        };
      }
    ]
  );
}
