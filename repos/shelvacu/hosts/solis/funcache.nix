{ vaculib, ... }: {
  systemd.tmpfiles.settings.whatever = {
    "/xstore/funcache-root".d = {
      user = "shelvacu";
      group = "root";
      mode = vaculib.accessModeStr {
        user = "all";
        group = "none";
        other = {
          read = true;
          write = false;
          execute = true;
        };
      };
    };
  };

  services.caddy.virtualHosts."funcache.org" = {
    vacu.hsts = "preload";
    extraConfig = ''
      root * /xstore/funcache-root
      file_server
    '';
  };
}
