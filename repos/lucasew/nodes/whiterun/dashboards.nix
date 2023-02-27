{ config, pkgs, ... }: {
  services.grafana = {
    enable = true;
    settings.server.domain = "grafana.${config.networking.hostName}.${config.networking.domain}";
    port = 65528;
    addr = "127.0.0.1";
  };
  services.nginx.virtualHosts."grafana.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
  
  services.nginx.virtualHosts."prometheus.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
      # proxyWebsockets = true;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    webExternalUrl = "http://prometheus.${config.networking.hostName}.${config.networking.domain}";
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "logind" "systemd"];
        port = 9002;
      };
      zfs.enable = true;
      dnsmasq.enable = true;
      nginx = {
        enable = true;
        sslVerify = false; # rede interna não usa ssl
      };
      postgres = {
        enable = true;
        runAsLocalSuperUser = true;
      };
    };
    scrapeConfigs = (map (item: {
      job_name = item;
      static_configs = [
        {
          targets = ["127.0.0.1:${toString config.services.prometheus.exporters.${item}.port}"];
        }
      ];
    })  ["node" "zfs" "dnsmasq" "nginx" "postgres"]);
  };
}
