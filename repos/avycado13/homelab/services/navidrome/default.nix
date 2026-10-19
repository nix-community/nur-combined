{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.navidrome;
  hl = config.homelab;
  port = 4533;
  proxyHost =
    if cfg.host == "127.0.0.1" && cfg.listenAddress != "0.0.0.0" then cfg.listenAddress else cfg.host;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.navidrome = {
    enable = lib.mkEnableOption "Navidrome music server";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where navidrome actually runs, if not this machine";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address Navidrome binds to on the machine running it";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        # navidrome.db (users, playlists, play counts, transcode cache
        # index) lives here; the music/playlist files themselves are the
        # beets library and are backed up independently of navidrome.
        sqlite = "${cfg.dataFolder}/navidrome.db";
      };
      description = "What to back up for navidrome; see homelab/services/restic";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "music.${hl.baseDomainName}";
      description = "Domain to serve Navidrome on";
    };
    dataFolder = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/navidrome";
      description = "Where navidrome keeps its database and cache";
    };
    musicFolder = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/beets/library";
      description = "Path to the beets-managed music library";
    };
    playlistsPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/beets/playlists";
      description = ''
        Comma-separated list of paths to scan for playlists (.m3u/.nsp),
        kept separate from musicFolder since the beets playlist folder
        lives outside the library directory.
      '';
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Navidrome";
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
        services.navidrome = {
          enable = true;
          settings = {
            Address = cfg.listenAddress;
            Port = port;
            MusicFolder = cfg.musicFolder;
            DataFolder = cfg.dataFolder;
            PlaylistsPath = cfg.playlistsPath;
          };
        };

        systemd.services.navidrome.serviceConfig.OnFailure = lib.mkIf (
          hl.notifications.ntfySecretsFile != null
        ) "notify-failure@%n.service";
      })
      {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${proxyHost}:${toString port}
          '';
        };
      }
    ]
  );
}
