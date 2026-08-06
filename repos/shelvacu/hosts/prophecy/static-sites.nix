{ vaculib, ... }: {
  environment.persistence."/persistent".directories = [ {
    directory = "/var/static-sites";
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
  } ];

  services.caddy.virtualHosts = {
    "inv6.shelvacu.com" = {
      vacu.hsts = "preload";
      extraConfig = ''
        root * /var/static-sites/inv6.shelvacu.com
        encode zstd gzip
        file_server
        @spa {
            not path /static/*
            not path /index.html
            not path /manifest.json
            not path /sw.js
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
