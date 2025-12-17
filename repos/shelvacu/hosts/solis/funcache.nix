{ ... }:
{
  services.caddy.virtualHosts."funcache.org" = {
    vacu.hsts = "preload";
    extraConfig = ''
      root * /xstore/funcache-root
      file_server
    '';
  };
}
