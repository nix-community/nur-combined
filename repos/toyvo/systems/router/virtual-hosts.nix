{
  config,
  lib,
  homelab,
  ...
}:
{
  config = lib.mkIf config.services.caddy.enable {
    users.users.caddy.extraGroups = [ "acme" ];
    services.caddy = {
      email = "collin@diekvoss.com";
      virtualHosts =
        lib.concatMapAttrs
          (
            hostname:
            {
              ip,
              services ? { },
              ...
            }:
            (lib.mapAttrs' (
              service:
              {
                port,
                subdomain ? service,
                domain ? "diekvoss.net",
                selfSigned ? false,
                public ? domain != "diekvoss.net",
                ...
              }:
              {
                name = if subdomain == "@" then domain else "${subdomain}.${domain}";
                value = {
                  useACMEHost = domain;
                  listenAddresses =
                    if public then
                      [
                        "0.0.0.0"
                        "[::]"
                      ]
                    else
                      [
                        "127.0.0.1"
                        "[::1]"
                        homelab.router.ip
                      ];
                  extraConfig =
                    if selfSigned then
                      ''
                        reverse_proxy https://${ip}:${toString port} {
                          transport http {
                            tls_insecure_skip_verify
                          }
                        }
                      ''
                    else
                      "reverse_proxy http://${ip}:${toString port}";
                };
              }
            ) services)
          )
          (
            lib.filterAttrs (
              hostname:
              {
                ip ? "",
                ...
              }:
              lib.hasPrefix "10.1.0." ip
            ) homelab
          );
    };
  };
}
