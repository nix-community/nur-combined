{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.sops) secrets;
in
{
  users.groups.direct-net = { };

  services.dae = {
    enable = true;
    package = pkgs.dae-unstable;
    configFile = secrets."config.dae".path;
  };
  sops.secrets."config.dae".restartUnits = [ "dae.service" ];

  systemd.services.kcptun = {
    description = "kcptun";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.kcptun}/bin/kcptun-client -c ${secrets."kcptun.json".path}
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 4;
    };
  };
  sops.secrets."kcptun.json".restartUnits = [ "kcptun.service" ];
}
