{
  flake.modules.nixos.stalwart =
    { config, ... }:
    {
      vaultix.secrets.stalwart = {
        owner = "stalwart";
        mode = "400";
      };
      networking.firewall.allowedTCPPorts = [
        993
        25
        587
        465
        995
        4190
      ];
      systemd.services.stalwart.serviceConfig = {
        EnvironmentFile = config.vaultix.secrets.stalwart.path;
      };
      # Keep public mail protocols on the edge; mesh applications use this ingress.
      realm.workloads.stalwart = {
        isolation.privateNetwork = false;
        isolation.allowUnixSockets = [ "-/run/systemd/resolve" ];
        ingress.submission = {
          port = 14650;
          backend = {
            kind = "host-tcp";
            address = "127.0.0.1";
            port = 465;
          };
          service = "smtp-submission";
          allow.identities = [
            "spiffe://nyaw.xyz/service/forgejo"
            "spiffe://nyaw.xyz/service/vaultwarden"
            "${config.realm.servicePrefix}pocket-id"
          ];
        };
      };
      services.stalwart = {
        enable = true;
      };
      realm.observability.endpoints.stalwart = {
        port = 9313;
        path = "/metrics/prometheus";
        businessProxyPort = 19313;
        businessAllowedIDs = config.realm.caddy.allowedIDs.stalwart-web;
        businessService = "stalwart-web";
      };
    };
}
