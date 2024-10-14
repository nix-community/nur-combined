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
            serviceConfig.LoadCredential = lib.mkIf i.cond (
              (map (lib.genCredPath config)) [
                "nyaw.cert"
                "nyaw.key"
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
