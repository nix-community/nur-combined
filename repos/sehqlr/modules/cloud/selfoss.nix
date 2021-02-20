{ config, pkgs, ... }: {
  services.selfoss.enable = true;

  security.acme.certs."rss.samhatfield.me".email = "hey@samhatfield.me";
  services.nginx.virtualHosts."rss.samhatfield.me" = {
    addSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        root = "/var/lib/selfoss";
        index = "index.php index.html index.htm";
        tryFiles = "$uri /public/$uri /index.php$is_args$args";
      };
      "~ .php$" = {
        extraConfig = ''
          fastcgi_split_path_info ^(.\.php)(/.+)$;
          fastcgi_index index.php;
          fastcgi_pass unix:${config.services.phpfpm.pools.selfoss_pool.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
      "~ ^/favicons/.*$".tryFiles = "$uri /data/$uri";
      "~ ^/thumbnails/.$".tryFiles = "$uri /data/$uri";
      "~* ^/(data/logs|data/sqlite|config.ini|.ht)".extraConfig = ''
          deny all;
        '';
    };
  };
}
