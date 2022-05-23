# Deployed services
{ config, lib, ... }:
let
  secrets = config.age.secrets;
in
{
  # List services that you want to enable:
  my.services = {
    # Hosts-based adblock using unbound
    adblock = {
      enable = true;
    };
    # Backblaze B2 backup
    backup = {
      enable = true;
      repository = "b2:porthos-backup";
      # Backup every 6 hours
      timerConfig = {
        OnActiveSec = "6h";
        OnUnitActiveSec = "6h";
      };
      passwordFile = secrets."backup/password".path;
      credentialsFile = secrets."backup/credentials".path;
    };
    # My blog and related hosts
    blog.enable = true;
    calibre-web = {
      enable = true;
      libraryPath = "/data/media/library";
    };
    drone = {
      enable = true;
      runners = [ "docker" "exec" ];
      secretFile = secrets."drone/gitea".path;
      sharedSecretFile = secrets."drone/secret".path;
    };
    # Flood UI for transmission
    flood = {
      enable = true;
    };
    # Gitea forge
    gitea = {
      enable = true;
      mail = {
        enable = true;
        host = "smtp.migadu.com:465";
        user = lib.my.mkMailAddress "gitea" "belanyi.fr";
        passwordFile = secrets."gitea/mail-password".path;
      };
    };
    # Meta-indexers
    indexers = {
      prowlarr.enable = true;
    };
    # Jellyfin media server
    jellyfin.enable = true;
    # Gitea mirrorig service
    lohr = {
      enable = true;
      sharedSecretFile = secrets."lohr/secret".path;
      sshKeyFile = secrets."lohr/ssh-key".path;
    };
    # Matrix backend and Element chat front-end
    matrix = {
      enable = true;
      mailConfigFile = secrets."matrix/mail".path;
      # Only necessary when doing the initial registration
      # secret = "change-me";
    };
    miniflux = {
      enable = true;
      credentialsFiles = secrets."miniflux/credentials".path;
    };
    # Various monitoring dashboards
    monitoring = {
      enable = true;
      grafana = {
        passwordFile = secrets."monitoring/password".path;
      };
    };
    # FLOSS music streaming server
    navidrome = {
      enable = true;
      musicFolder = "/data/media/music";
    };
    # Nextcloud self-hosted cloud
    nextcloud = {
      enable = true;
      passwordFile = secrets."nextcloud/password".path;
    };
    nginx = {
      enable = true;
      acme = {
        credentialsFile = secrets."acme/dns-key".path;
      };
      sso = {
        authKeyFile = secrets."sso/auth-key".path;
        users = {
          ambroisie = {
            passwordHashFile = secrets."sso/ambroisie/password-hash".path;
            totpSecretFile = secrets."sso/ambroisie/totp-secret".path;
          };
        };
        groups = {
          root = [ "ambroisie" ];
        };
      };
    };
    paperless = {
      enable = true;
      documentPath = "/data/media/paperless";
      passwordFile = secrets."paperless/password".path;
      secretKeyFile = secrets."paperless/secret-key".path;
    };
    # The whole *arr software suite
    pirate.enable = true;
    # Podcast automatic downloader
    podgrab = {
      enable = true;
      passwordFile = secrets."podgrab/password".path;
      port = 9598;
    };
    # Regular backups
    postgresql-backup.enable = true;
    # An IRC client daemon
    quassel.enable = true;
    # RSS provider for websites that do not provide any feeds
    rss-bridge.enable = true;
    # Usenet client
    sabnzbd.enable = true;
    # Because I stilll need to play sysadmin
    ssh-server.enable = true;
    # Torrent client and webui
    transmission = {
      enable = true;
      credentialsFile = secrets."transmission/credentials".path;
    };
    # Simple, in-kernel VPN
    wireguard = {
      enable = true;
      startAtBoot = true; # Server must be started to ensure clients can connect
    };
  };
}
