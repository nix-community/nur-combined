{
  flake.modules.nixos.ntfy =
    { config, ... }:
    {
      services.ntfy-sh = {
        enable = true;
        settings = {
          listen-http = ":2586";
          behind-proxy = true;
          auth-default-access = "deny-all";
          base-url = "http://ntfy.nyaw.xyz";
          enable-metrics = true;
          metrics-listen-http = "[${config.data.node.${config.networking.hostName}.unique_addr_nomask}]:9099";
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
