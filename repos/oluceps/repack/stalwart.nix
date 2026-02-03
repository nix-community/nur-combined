{
  reIf,
  config,
  pkgs,
  ...
}:
reIf {
  networking.firewall.allowedTCPPorts = [
    993
    25
    587
    465
  ];
  systemd.services.stalwart-mail.serviceConfig.EnvironmentFile = config.vaultix.secrets.stalwart.path;
  services.stalwart-mail = {
    enable = true;
    settings = {
      http.use-x-forwarded = true;
      http.url = "'https' + '://' + config_get('server.hostname')";
      authentication = {
        fallback-admin = {
          # secret = "%{file:/run/credentials/stalwart-mail.service/ADMIN_SECRET}%";
          secret = "%{env:ADMIN_SECRET}%";
          user = "admin";
        };
      };
      directory = {
        internal = {
          store = "db";
          type = "internal";
        };
      };
      acme."cf" = {
        provider = "cloudflare";
        secret = "%{env:CF_API_TOKEN}%";
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "dns-01";
        contact = [ "sec@nyaw.xyz" ];
        domains = [
          "box.nyaw.xyz"
        ];
        cache = config.services.stalwart-mail.dataDir + "/acme";
        renew-before = "30d";
        default = true;
      };
      server = {
        hostname = "box.nyaw.xyz";
        tls = {
          enable = true;
          implicit = false;
          timeout = "1m";
          disable-protocols = [ "TLSv1.2" ];
          disable-ciphers = [
          ];
          ignore-client-order = true;
        };
        listener = {
          management = {
            bind = [ "127.0.0.1:9313" ];
            protocol = "http";
          };
          imaptls = {
            bind = [ "[::]:993" ];
            protocol = "imap";
            tls = {
              implicit = true;
            };
          };
          smtp = {
            bind = [ "[::]:25" ];
            protocol = "smtp";
          };
          submissions = {
            bind = [ "[::]:465" ];
            protocol = "smtp";
            tls = {
              implicit = true;
            };
          };
        };
      };
      storage = {
        blob = "db";
        data = "db";
        directory = "internal";
        fts = "db";
        lookup = "db";
      };
      store = {
        db = {
          compression = "lz4";
          path = config.services.stalwart-mail.dataDir + "/db";
          type = "rocksdb";
        };
      };
      tracer = {
        stdout = {
          ansi = false;
          enable = true;
          level = "info";
          type = "stdout";
        };
      };
    };
  };

}
