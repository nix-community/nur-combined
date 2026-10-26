{
  flake.modules.nixos.calibre =
    { config, ... }:
    {
      users.groups.calibre = { };
      services.calibre-web = {
        enable = true;
        group = "calibre";
        listen.ip = "127.0.0.1";
        options = {
          calibreLibrary = "/var/lib/calibre";
          enableBookUploading = true;
          reverseProxyAuth.enable = true;
        };
      };
      realm.workloads.calibre = {
        unit = "calibre-web.service";
        user = "calibre-web";
        group = "calibre";
        isolation.runtimePaths = [ "/run/calibre-web" ];
        ingressGroups = [ "calibre" ];
        ingress.http = {
          port = 18083;
          backend = {
            kind = "unix";
            path = "/run/calibre-web/http.sock";
          };
          service = "calibre";
          allow.identities = config.realm.caddy.allowedIDs.calibre;
        };
        http.internet = true;
      };
      systemd.services.calibre-web.serviceConfig.RuntimeDirectory = "calibre-web";
      systemd.services.calibre-web.environment = {
        CALIBRE_UNIX_SOCKET = "/run/calibre-web/http.sock";
      };
    };
}
