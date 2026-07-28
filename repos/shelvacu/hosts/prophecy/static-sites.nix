{ vaculib, ... }: {
  systemd.tmpfiles.settings.whatever."/var/static-sites".d = {
    user = "shelvacu";
    group = "root";
    mode = vaculib.accessModeStr {
      user = "all";
      group = {
        read = true;
        execute = true;
      };
      other = {
        read = true;
        execute = true;
      };
    };
  };

  services.caddy.virtualHosts = {
    "inv6.shelvacu.com" = {
      vacu.hsts = "preload";
      extraConfig = ''
        root * /var/static-sites/inv6.shelvacu.com
        encode zstd gzip
        file_server
        @spa {
            not path /static/*
            not file
        }
        rewrite @spa /index.html
      '';
    };
    "baregit.shelvacu.com" = {
      vacu.hsts = "preload";
      extraConfig = ''
        root * /var/static-sites/baregit.shelvacu.com
        encode zstd gzip
        file_server
      '';
    };
  };
}
