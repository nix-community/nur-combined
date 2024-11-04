{
  pkgs,
  config,
  inputs,
  reIf,
  lib,
  ...
}:
reIf (
  let
    inherit (lib) optionalAttrs;
    nameCondPair = [
      {
        name = "trojan-server";
        cond = (config.services.trojan-server.enable);
      }
      # {
      #   name = "hysteria-only";
      #   cond = (builtins.any (i: i.serve) (lib.attrValues config.services.hysteria.instances));
      # }
    ];
  in
  {
    systemd.services = lib.mkMerge [
      (lib.foldr (
        i: acc:
        acc
        // {
          ${i.name} = {
            # wildcard
            serviceConfig.LoadCredential = lib.mkIf i.cond (
              map
                (
                  s:
                  s
                  + ":"
                  + "/var/lib/caddy/certificates/acme-v02.api.letsencrypt.org-directory/wildcard_.nyaw.xyz/wildcard_.nyaw.xyz.${s}"
                )
                [
                  "key"
                  "crt"
                ]
            );
          };
        }
      ) { } nameCondPair)
      (optionalAttrs config.repack.caddy.enable {
        caddy.serviceConfig.EnvironmentFile = config.vaultix.secrets.caddy.path;
      })
      (optionalAttrs (builtins.any (i: i.serve) (lib.attrValues config.services.hysteria.instances)) {
        hysteria-only.serviceConfig.LoadCredential =
          map
            (
              s:
              s
              + ":"
              + "/var/lib/caddy/certificates/acme-v02.api.letsencrypt.org-directory/nyaw.xyz/nyaw.xyz.${s}"
            )
            [
              "key"
              "crt"
            ];
      })
    ];
  }
)
