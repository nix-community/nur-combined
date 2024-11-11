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
    # Audiobook and podcast library
    audiobookshelf = {
      enable = true;
      port = 9599;
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
    # Auto-ban spammy bots and incorrect logins
    fail2ban = {
      enable = true;
    };
    # Flood UI for transmission
    flood = {
      enable = true;
    };
    # Forgejo forge
    forgejo = {
      enable = true;
      mail = {
        enable = true;
        host = "smtp.migadu.com";
        user = lib.my.mkMailAddress "forgejo" "belanyi.fr";
        passwordFile = secrets."forgejo/mail-password".path;
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
      secretFile = secrets."matrix/secret".path;
    };
    mealie = {
      enable = true;
      credentialsFile = secrets."mealie/mail".path;
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
        secretKeyFile = secrets."monitoring/secret-key".path;
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
    nix-cache = {
      enable = true;
      secretKeyFile = secrets."nix-cache/cache-key".path;
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
    # Sometimes, editing PDFs is useful
    pdf-edit = {
      enable = true;
      loginFile = secrets."pdf-edit/login".path;
    };
    # Regular backups
    postgresql-backup.enable = true;
    pyload = {
      enable = true;
      credentialsFile = secrets."pyload/credentials".path;
    };
    # RSS provider for websites that do not provide any feeds
    rss-bridge.enable = true;
    # Usenet client
    sabnzbd.enable = true;
    # The whole *arr software suite
    servarr = {
      enable = true;
      # ... But not Lidarr because I don't care for music that much
      lidarr = {
        enable = false;
      };
    };
    # Because I still need to play sysadmin
    ssh-server.enable = true;
    # Torrent client and webui
    transmission = {
      enable = true;
      credentialsFile = secrets."transmission/credentials".path;
    };
    # Self-hosted todo app
    vikunja = {
      enable = true;
      mail = {
        enable = true;
        configFile = secrets."vikunja/mail".path;
      };
    };
    # Simple, in-kernel VPN
    wireguard = {
      enable = true;
      startAtBoot = true; # Server must be started to ensure clients can connect
    };
    woodpecker = {
      enable = true;
      # Avoid clashes with drone
      port = 3035;
      rpcPort = 3036;
      runners = [ "docker" "exec" ];
      secretFile = secrets."woodpecker/gitea".path;
      sharedSecretFile = secrets."woodpecker/secret".path;
    };
  };
}
