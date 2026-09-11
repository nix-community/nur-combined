{ config, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@shiroki.tech";
      extraLegoFlags = [ "--dns.propagation-wait=10s" ];
    };
    certs = {
      "berry.shiroki.tech" = {
        domain = "*.berry.shiroki.tech";
        group = config.services.nginx.group;
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets."acme/cloudflare".path;
        };
        reloadServices = [ "nginx" ];
      };
    };
  };
  sops.secrets."acme/cloudflare" = {
    restartUnits = [ "acme-order-renew-berry.shiroki.tech.service" ];
  };

  services.nginx = {
    enable = true;

    prependConfig = ''
      worker_processes auto;
    '';

    eventsConfig = ''
      use epoll;
    '';

    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    experimentalZstdSettings = true;
    recommendedProxySettings = true;

    commonHttpConfig = ''
      map $http_x_forwarded_for $xff_passthrough {
          default $http_x_forwarded_for;
          ""      $remote_addr;
      }
    '';

    virtualHosts = {
      "ha.berry.shiroki.tech" = {
        addSSL = true;
        acmeRoot = null;
        useACMEHost = "berry.shiroki.tech";
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8123";
            proxyWebsockets = true;
            recommendedProxySettings = false;
            extraConfig = ''
              proxy_buffering off;
              proxy_set_header Host $host;
              # Home Assistant use first untrusted X-Forwarded-For from RIGHT,
              # using $proxy_add_x_forwarded_for will cause CDN IPs treated as client
              proxy_set_header X-Forwarded-For $xff_passthrough;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $hostname;
            '';
          };
        };
      };
      "qbt.berry.shiroki.tech" = {
        addSSL = true;
        acmeRoot = null;
        useACMEHost = "berry.shiroki.tech";
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8080";
          };
        };
      };
      "jellyfin.berry.shiroki.tech" = {
        addSSL = true;
        acmeRoot = null;
        useACMEHost = "berry.shiroki.tech";
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8096";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };
    };
  };

  # If you enabled ACME above, configure the email address for registration.
  # Uncomment and set your email if you want automatic Let's Encrypt certs.
  # services.acme = {
  #   acceptTerms = true;
  #   email = "you@example.com";
  #   certs = {
  #     "your.hass.domain" = {
  #       webroot = "/var/www/letsencrypt";
  #     };
  #   };
  # };

}
