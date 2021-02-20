{ config, pkgs, ... }: {
  services.selfoss.enable = true;

  security.acme.certs."rss.samhatfield.me".email = "hey@samhatfield.me";
  services.nginx.virtualHosts."rss.samhatfield.me" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      root = "/var/lib/selfoss";
      index = "index.php index.html index.htm";
      extraConfig = ''
        fastcgi_split_path_info ^(.\.php)(/.+)$;
        fastcgi_index index.php;
        fastcgi_pass unix:${config.services.phpfpm.pools.selfoss_pool.socket};
        include ${pkgs.nginx}/conf/fastcgi_params;
        include ${pkgs.nginx}/conf/fastcgi.conf;
      '';
    };
  };
}
