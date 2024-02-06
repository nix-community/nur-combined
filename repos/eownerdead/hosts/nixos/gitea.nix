{ config, pkgs, ... }: {
  services = {
    nginx = {
      enable = true;
      virtualHosts."git.eownerdead.dedyn.io" = {
        locations."/".extraConfig = ''
          include ${config.services.nginx.package}/conf/fastcgi.conf;
          fastcgi_pass unix:${config.services.gitea.settings.server.HTTP_ADDR};
        '';
      };
    };

    gitea = {
      enable = true;
      package = pkgs.forgejo;
      database.type = "mysql";
      settings = {
        service.DISABLE_REGISTRATION = true;
        server = {
          PROTOCOL = "fcgi+unix";
          ROOT_URL = "https://git.eownerdead.dedyn.io/";
          DISABLE_SSH = true;
        };
        indexer.REPO_INDEXER_ENABLED = true;
        federation.ENABLED = true;
      };
    };
  };
}
