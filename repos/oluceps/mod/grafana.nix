{
  flake.modules.nixos.grafana =
    { config, ... }:
    {
      services.grafana = {
        enable = true;
        settings = {
          database = {
            type = "postgres";
            host = "/run/postgresql";
            name = "grafana";
            user = "grafana";
            ssl_mode = "disable";
          };
          server = {
            protocol = "socket";
            socket = "/run/grafana/grafana.sock";
            socket_mode = "0660";
            domain = "gf.nyaw.xyz";
            root_url = "https://gf.nyaw.xyz/";
            serve_from_sub_path = false;
          };
          auth = {
            oauth_allow_insecure_email_lookup = true;
          };
          security.secret_key = "$__file{/run/credentials/grafana.service/grafana-secretkey}";
          feature_toggles.dashboardNewLayouts = true;
        };
      };
      realm.workloads.grafana = {
        isolation.runtimePaths = [ "/run/grafana" ];
        isolation.allowUnixSockets = [ "/run/postgresql" ];
        ingressGroups = [ "grafana" ];
        ingress.http = {
          port = 13002;
          backend = {
            kind = "unix";
            path = "/run/grafana/grafana.sock";
          };
          service = "grafana";
          allow.groups = [ "public-caddy" ];
        };
        http.internet = true;
        egress = {
          loki = {
            service = "loki";
            localPort = 13030;
          };
          victoriametrics = {
            service = "victoriametrics-${config.networking.hostName}";
            localPort = 13090;
          };
        };
      };
      services.grafana.provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:13030";
          }
          {
            name = "VictoriaMetrics";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:13090";
            isDefault = true;
            jsonData = {
              httpMethod = "POST";
              prometheusType = "VictoriaMetrics";
            };
          }
        ];
      };
      systemd.services.grafana = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
        serviceConfig.LoadCredential = [
          "grafana-secretkey:${config.vaultix.secrets.grafana-secretkey.path}"
        ];
        # The legacy secret URL selects host TCP and overrides the peer socket settings.
        serviceConfig.UnsetEnvironment = [ "GF_DATABASE_URL" ];
      };
      vaultix.secrets = {
        grafana = {
          owner = "grafana";
          mode = "400";
        };
        grafana-secretkey = {
          owner = "grafana";
          mode = "400";
        };
      };
      systemd.services.grafana.serviceConfig = {
        EnvironmentFile = config.vaultix.secrets.grafana.path;
      };
    };
}
