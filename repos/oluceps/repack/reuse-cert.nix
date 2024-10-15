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
    nameCondPair = [
      {
        name = "trojan-server";
        cond = (config.services.trojan-server.enable);
      }
      {
        name = "hysteria-only";
        cond = (builtins.any (i: i.serve) (lib.attrValues config.services.hysteria.instances));
      }
    ];
  in
  {
    systemd.services =
      (lib.foldr (
        i: acc:
        acc
        // {
          ${i.name} = {
            serviceConfig.LoadCredential = lib.mkIf i.cond (
              map
                (
                  s:
                  "${s}:/var/lib/caddy/certificates/acme-v02.api.letsencrypt.org-directory/wildcard_.nyaw.xyz/wildcard_.nyaw.xyz.${s}"
                )
                [
                  "key"
                  "crt"
                ]
            );
          };
        }
      ) { } nameCondPair)
      // {
        caddy.serviceConfig.EnvironmentFile = config.age.secrets.porkbun-api.path;
      };
  }
)
