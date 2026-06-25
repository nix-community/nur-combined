{
  config,
  pkgs,
  lib,
  ...
}:
let
  secrets = config.sops.secrets;
  certName = "eh5.me";
  acmeCert = config.security.acme.certs.${certName};
  caddyCfg = config.services.caddy;
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "i+acme@eh5.me";
      keyType = "ec256";
      dnsProvider = "cloudflare";
      environmentFile = secrets.acmeEnv.path;
    };
    certs."eh5.me" = {
      extraDomainNames = [
        "sokka.cn"
        "*.eh5.me"
        "*.sokka.cn"
      ];
      postRun = ''
        export PATH="$PATH:${pkgs.bash}/bin/:${pkgs.openssh}/bin:${pkgs.sshpass}/bin"
        bash ${secrets.postScript.path}
      '';
      reloadServices = [
        # "v2ray-next.service"
      ];
    };
  };

  # sing-box
  services.sing-box = {
    enable = true;
    settings = {
      log.level = "warn";
      route = {
        geoip.path = "/var/lib/sing-box/geoip.db";
        geosite.path = "/var/lib/sing-box/geosite.db";
      };
    };
  };
  systemd.services.sing-box.preStart = ''
    cp ${secrets."sb-config.json".path} /run/sing-box/other.json
  '';
  sops.secrets."sb-config.json".restartUnits = [ "sing-box.service" ];

  # Caddy
  users.users.${caddyCfg.user}.extraGroups = [ acmeCert.group ];
  services.caddy = {
    enable = true;
    package = pkgs.caddy; # XXX: use custom build with plugins?
    acmeCA = null;
    globalConfig = ''
      auto_https disable_certs
      default_sni eh5.me
    '';
  };
  services.caddy.virtualHosts = {
    "eh5.me" = {
      useACMEHost = certName;
      extraConfig = ''
        root * /var/www/eh5.me
        @prefer_tw {
          path /
          header_regexp Accept-Language ^zh-(TW|HK).*
        }
        @prefer_zh {
          path /
          header_regexp Accept-Language ^zh.*
        }
        redir @prefer_tw /zh-cn/
        redir @prefer_zh /zh-cn/
        redir / /en/
        file_server {
          browse
          precompressed br gzip
        }
        header /rss.xml Content-Type "application/rss+xml; charset=utf-8"
        header /atom.xml Content-Type "application/atom+xml; charset=utf-8"
        header /feed.json Content-Type "application/feed+json; charset=utf-8"

        handle_errors {
          rewrite /{err.status_code}.html
          file_server
        }
      '';
    };
    "www.eh5.me" = {
      serverAliases = [
        "blog.eh5.me"
      ];
      useACMEHost = certName;
      extraConfig = ''
        redir https://eh5.me{uri}
      '';
    };
    "mail.eh5.me" = {
      serverAliases = [
        "mx.eh5.me"
        "mx2.eh5.me"
      ];
      useACMEHost = certName;
      extraConfig = ''
        redir /rspamd /rspamd/
        handle_path /rspamd/* {
          reverse_proxy unix//run/rspamd/worker-controller.sock {
            header_up X-Real-IP {remote_host}
          }
        }
        import `${secrets.webConfig.path}`
      '';
    };
    "autoconfig.eh5.me" = {
      serverAliases = [ "autoconfig.sokka.cn" ];
      useACMEHost = certName;
      extraConfig = ''
        handle_path /mail/* {
          root * `${./files/autoconfig}`
          templates {
            mime application/xml text/xml
          }
          file_server
        }
      '';
    };
    "autodiscover.eh5.me" = {
      serverAliases = [ "autodiscover.sokka.cn" ];
      useACMEHost = certName;
      extraConfig = ''
        rewrite /Autodiscover/Autodiscover.xml /autodiscover/autodiscover.xml
        rewrite /Autodiscover/Autodiscover.json /autodiscover/autodiscover.json
        handle_path /autodiscover/* {
          root * `${./files/autodiscover}`
          templates {
            mime application/json application/xml text/xml
          }
          file_server
        }
      '';
    };
  };
  systemd.services.caddy.serviceConfig.ReadOnlyPaths = [
    "/nix/store"
    "/var/www"
    secrets.webConfig.path
  ];

  # PostgreSQL
  services.postgresql = {
    enable = true;
    enableTCPIP = false;
  };
}
