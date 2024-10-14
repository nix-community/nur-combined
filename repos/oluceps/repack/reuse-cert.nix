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
        name = "hysteria";
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
            serviceConfig.BindReadOnlyPaths = lib.mkIf i.cond [
              "-/var/lib/caddy/certificates/acme-v02.api.letsencrypt.org-directory/"
            ];
          };
        }
      ) { } nameCondPair)
      // {
        caddy.serviceConfig.EnvironmentFile = config.age.secrets.porkbun-api.path;
      };
  }
)
