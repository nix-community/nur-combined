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
                protected ? true,
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
                    let
                      forwardAuthBlock = lib.optionalString (protected && !selfSigned) ''
                        forward_auth http://${homelab.authentik.ip}:9000 {
                          uri /outpost.goauthentik.io/auth/caddy
                          copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Jwt X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Session-Issuer
                          header_up X-Forwarded-Method {method}
                          header_up X-Forwarded-Proto {scheme}
                          header_up X-Forwarded-Host {host}
                          header_up X-Forwarded-Uri {uri}
                          header_up X-Forwarded-For {remote}
                        }
                      '';
                    in
                    forwardAuthBlock
                    + (
                      if selfSigned then
                        ''
                          header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
                          reverse_proxy https://${ip}:${toString port} {
                            header_down -Server
                            transport http {
                              tls_insecure_skip_verify
                            }
                          }
                        ''
                      else
                        ''
                          header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
                          reverse_proxy http://${ip}:${toString port} {
                            header_down -Server
                          }
                        ''
                    );
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
              (lib.hasPrefix "10.1.0." ip || lib.hasPrefix "10.200." ip)
            ) homelab
          );
    };
  };
}
