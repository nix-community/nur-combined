{ config, pkgs, ... }: {
  services.selfoss.enable = true;

  security.acme.certs."rss.samhatfield.me".email = "hey@samhatfield.me";
  services.nginx.virtualHosts."rss.samhatfield.me" = {
    addSSL = true;
    enableACME = true;
    root = "/var/lib/selfoss/public_html";
    
    locations = {
      "/" = {
          index = "index.php";
          tryFiles = "$uri /public/$uri /index.php$is_args$args";
      };
      "~ \.php$" = {
        extraConfig = ''
          fastgci_intercept_errors on;
          fastcgi_buffers 16 16k;
          fastcgi_buffer_size 32k;
          fastcgi_pass unix:${config.services.phpfpm.pools.selfoss_pool.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
      "~* \ (gif|jpg|png)".extraConfig = ''
        expires 30d;
      '';
      "~ ^/favicons/.*$".tryFiles = "$uri /data/$uri";
      "~ ^/thumbnails/.$".tryFiles = "$uri /data/$uri";
      "~* ^/(data/logs|data/sqlite|config.ini|.ht)".extraConfig = ''
        deny all;
      '';
    };
  };
}
