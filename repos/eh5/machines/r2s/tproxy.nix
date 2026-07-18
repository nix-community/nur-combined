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

  systemd.services.usque = {
    description = "usque";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.usque}/bin/usque socks -6 -p 4080 -c ${secrets."usque.json".path} -s hoyoverse.com -d 1.1.1.1 -d 1.0.0.1 -d 2606:4700:4700::1111 -d 2606:4700:4700::1001
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 4;
      LogFilterPatterns = [ "~is not associated with tcp" ];
    };
  };
  sops.secrets."usque.json".restartUnits = [ "usque.service" ];

  # systemd.services.kcptun = {
  #   description = "kcptun";
  #   wants = [ "network-online.target" ];
  #   after = [ "network-online.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   script = ''
  #     ${pkgs.kcptun}/bin/kcptun-client -c ${secrets."kcptun.json".path}
  #   '';
  #   serviceConfig = {
  #     Restart = "on-failure";
  #     RestartSec = 4;
  #   };
  # };
  # sops.secrets."kcptun.json".restartUnits = [ "kcptun.service" ];
}
