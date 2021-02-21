{ config, pkgs, ... }: {
  services.selfoss.enable = true;

  security.acme.certs."rss.samhatfield.me".email = "hey@samhatfield.me";
  services.nginx.virtualHosts."rss.samhatfield.me" = {
    addSSL = true;
    enableACME = true;
    root = "/var/lib/selfoss";
    
    locations = {
      "/" = {
          index = "index.php index.html index.htm";
          tryFiles = "$uri /public/$uri /index.php$is_args$args";
      };
      "~ \.php$" = {
        extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.selfoss_pool.socket};
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
      "~* \ (gif|jpg|png)".extraConfig = ''
        expires 30d;
      '';
      "~ ^/favicons/.*$".tryFiles = "$uri /data/$uri";
      "~* ^/(data/logs|data/sqlite|config\.ini|\.ht)".extraConfig = ''
        deny all;
      '';
    };
  };
}
