{
  flake.modules.nixos.ntfy =
    { config, lib, ... }:
    {
      realm.workloads.ntfy = {
        unit = "ntfy-sh.service";
        user = "ntfy-sh";
        group = "ntfy-sh";
        isolation.runtimePaths = [ "/run/ntfy-sh" ];
        ingressGroups = [ "ntfy-sh" ];
        ingress = {
          http = {
            port = 12586;
            backend = {
              kind = "unix";
              path = "/run/ntfy-sh/http.sock";
            };
            service = "ntfy";
            allow.identities = config.realm.caddy.allowedIDs.ntfy;
          };
          metrics = {
            port = 19099;
            backend = {
              kind = "private-tcp";
              port = 9099;
            };
            service = "ntfy-metrics";
            allow.identities = [ "spiffe://nyaw.xyz/service/observability-${config.networking.hostName}" ];
          };
        };
        http.internet = true;
      };
      realm.workloads.caddy = lib.mkIf (config ? caddy) {
        egress.ntfy = {
          service = "ntfy";
        };
      };
      realm.workloads.observability.egress.ntfy = {
        service = "ntfy-metrics";
      };
      realm.observability.endpoints.ntfy.socket = "/run/realm/observability/egress/ntfy.sock";
      systemd.services.ntfy-sh = {
        serviceConfig = {
          RuntimeDirectory = "ntfy-sh";
          UMask = "0007";
          AmbientCapabilities = lib.mkForce [ ];
          CapabilityBoundingSet = lib.mkForce [ ];
        };
      };
      services.ntfy-sh = {
        enable = true;
        settings = {
          listen-http = "-";
          listen-unix = "/run/ntfy-sh/http.sock";
          listen-unix-mode = 432;
          behind-proxy = true;
          auth-default-access = "deny-all";
          base-url = "http://ntfy.nyaw.xyz";
          enable-metrics = true;
          metrics-listen-http = "127.0.0.1:9099";
          auth-users = [
            "lyo:$2a$12$O8gSrfED8kHXOvdovr7lOew/gMfawvBKJdRUvaAiuR3vQOrm2aus2:admin"
            "phi:$2a$10$Nmlat8Qzx4ze8UcgBjzMGeGSq8b0smQ21F6bMC5d5Vs5AVFYJBUxC:user"
          ];
          auth-access = [
            "phi:broadcast:write-only"
            "*:broadcast:ro"
            "*:up*:rw"
          ];
        };
      };
    };
}
