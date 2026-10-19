{ config, ... }:
{
  sops.secrets = {
    cloudflare-dns-credentials = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "cloudflare/dns_credentials";
    };
    miniflux-admin-credentials = {
      sopsFile = ../../../secrets/services.yaml;
      key = "miniflux/admin_credentials";
    };
    miniflux-oauth-client-id = {
      sopsFile = ../../../secrets/services.yaml;
      key = "miniflux/oauth_client_id";
      mode = "0444";
    };
    miniflux-oauth-client-secret = {
      sopsFile = ../../../secrets/services.yaml;
      key = "miniflux/oauth_client_secret";
      mode = "0444";
    };
    cloudflare-fail2ban-apikey = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "cloudflare/fail2ban_apikey";
    };
    ntfy_topic = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "ntfy_topic";
    };
    # speedtest-tracker-app-key = {
    #   sopsFile = ../../../secrets/services.yaml;
    #   key = "speedtest-tracker/app_key";
    #   owner = "speedtest-tracker";
    # };
    restic-repository-password = {
      sopsFile = ../../../secrets/services.yaml;
      key = "restic/repository_password";
    };
    restic-b2-credentials = {
      sopsFile = ../../../secrets/services.yaml;
      key = "restic/b2_credentials";
    };

    retrom-igdb-client-id = {
      sopsFile = ../../../secrets/services.yaml;
      key = "retrom/igdb_client_id";
    };
    retrom-igdb-client-secret = {
      sopsFile = ../../../secrets/services.yaml;
      key = "retrom/igdb_client_secret";
    };

    isponsorblocktv-living-room-tv-screen-id = {
      sopsFile = ../../../secrets/services.yaml;
      key = "isponsorblocktv/living_room_tv_screen_id";
    };

    lard-env = {
      sopsFile = ../../../secrets/services.yaml;
      key = "lard/env";
    };

    asterisk-cisco7945-password = {
      sopsFile = ../../../secrets/services.yaml;
      key = "asterisk/cisco7945_password";
    };
    # cloudflared-credentials = {
    #   sopsFile = ../../../secrets/services.yaml;
    #   key = "cloudflared/credentials";
    # };

    he-tunnel-update-credentials = {
      sopsFile = ../../../secrets/services.yaml;
      key = "he_tunnel/update_credentials";
    };
  };

  services.fail2ban-cloudflare = {
    enable = true;
    zoneId = "1ed193738a5409e5d718135e83605de1";
    apiKeyFile = config.sops.secrets.cloudflare-fail2ban-apikey.path;
    # No jails configured yet -- add entries here once indiko emits a
    # journal line for failed logins (see homelab/fail2ban-cloudflare).
    jails = { };
  };

  homelab = {
    enable = true;
    baseDomainName = "avyay.in";
    email = "avycado13@icloud.com";
    cloudflare.dnsCredentialsFile = config.sops.secrets.cloudflare-dns-credentials.path;

    motd.enable = true;
    notifications.ntfySecretsFile = config.sops.secrets.ntfy_topic.path;

    services = {
      enable = true;

      auth.enable = true;
      indiko = {
        domain = "auth.avyay.in";
        repository = "https://github.com/taciturnaxolotl/indiko.git";
        # repository = "https://tangled.org/avycado13.tngl.sh/indiko";
        branch = "main";
        autoUpdate = true;
      };

      miniflux = {
        enable = true;
        url = "news.avyay.in";
        adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;
        oauthClientIdFile = config.sops.secrets.miniflux-oauth-client-id.path;
        oauthClientSecretFile = config.sops.secrets.miniflux-oauth-client-secret.path;
      };

      glance = {
        enable = true;
        url = "glance.avyay.in";
      };

      # niks3 itself now runs on apollo1 (see machines/nixos/apollo1/default.nix);
      # pi1 only reverse-proxies to it over tailscale.
      niks3 = {
        enable = true;
        url = "cache.avyay.in";
        host = "100.72.166.0"; # apollo1 tailscale IP
        data = null;
      };

      cloudrun = {
        enable = true;
        services = {
          searxng.cloudRunHost = "searxng-671676671649.europe-west1.run.app";
          it-tools.cloudRunHost = "it-tools-671676671649.europe-west1.run.app";
        };
      };

      retrom = {
        enable = false;
        url = "retrom.avyay.in";
        contentDirectories = [
          {
            path = "/var/lib/retrom/library";
            storageType = "MultiFileGame";
          }
        ];
        igdb = {
          clientId = config.sops.placeholder.retrom-igdb-client-id;
          clientSecret = config.sops.placeholder.retrom-igdb-client-secret;
        };
      };

      restic = {
        enable = true;
        repository = "b2:avyrestic:pi1";
        passwordFile = config.sops.secrets.restic-repository-password.path;
        environmentFile = config.sops.secrets.restic-b2-credentials.path;
      };

      isponsorblocktv = {
        enable = true;
        devices = [
          {
            screenId = config.sops.placeholder.isponsorblocktv-living-room-tv-screen-id;
            name = "[LG] webOS TV OLED55C8PUA";
          }
        ];
        muteAds = true;
        skipAds = true;
      };

      lard = {
        enable = true;
        url = "lard.avyay.in";
        environmentFile = config.sops.secrets.lard-env.path;
        allowedUsers = [ "https://auth.avyay.in/u/avy" ];
      };

      calibre-web = {
        enable = false;
        url = "books.avyay.in";
      };

      navidrome = {
        enable = true;
        url = "music.avyay.in";
        host = "100.72.166.0"; # apollo1 tailscale IP
        data = null; # Navidrome's database lives on apollo1
      };

      asterisk = {
        enable = false;
        url = "pbx.avyay.in";
        domain = "avyay.in";
        phones = [
          {
            mac = "D0C7891479BC";
            extension = "1001";
            callerId = "Avy";
            line1Secret = config.sops.placeholder.asterisk-cisco7945-password;
          }
        ];
      };
      irc = {
        enable = true;
      };
    };
  };
  # networking.heTunnel = {
  #   enable = true;
  #   tunnelId = "1020159";
  #   serverIPv4 = "72.52.104.74";
  #   clientIPv6 = "2001:470:1f04:61e::2";
  #   routedPrefix = "2001:470:1f05:61e::";
  #   updateCredentialsFile = config.sops.secrets.he-tunnel-update-credentials.path;
  # };
}
