{
  lib,
  config,
  ...
}:
# metrics for exposed machine
let
  cfg = config.services.metrics;
in
{
  options.services.metrics = {
    enable = lib.mkEnableOption "export server metrics";
  };
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        enable = true;
        listenAddress = "[::]";
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "arp" ];
      };
      chrony = {
        enable=true;
        listenAddress="[::]";
      };
    };

    repack.caddy.enable = true;
    repack.caddy.settings.apps.http.servers.srv0.routes = [
      {

        handle = [
          {
            handler = "subroute";
            routes = [

              {
                match = [
                  {
                    host = [ config.networking.fqdn ];
                    path = [ "/metrics" ];
                  }
                ];
                handle = [
                  {
                    handler = "authentication";
                    providers.http_basic.accounts = [
                      {
                        username = "prometheus";
                        password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
                      }
                    ];
                  }
                  {
                    handler = "reverse_proxy";
                    upstreams = with config.services.prometheus.exporters.node; [
                      { dial = "${listenAddress}:${toString port}"; }
                    ];
                  }
                ];
              }
              {
                match = [
                  {
                    host = [ config.networking.fqdn ];
                    path = [ "/probe" ];
                  }
                ];
                handle = [
                  {
                    handler = "authentication";
                    providers.http_basic.accounts = [
                      {
                        username = "prometheus";
                        password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
                      }
                    ];
                  }
                  {
                    handler = "reverse_proxy";
                    upstreams = with config.services.prometheus.exporters.blackbox; [
                      { dial = "${listenAddress}:${toString port}"; }
                    ];
                  }
                ];
              }
            ];
          }
        ];
        match = [ { host = [ "*.nyaw.xyz" ]; } ];
      }
    ];
  };
}
