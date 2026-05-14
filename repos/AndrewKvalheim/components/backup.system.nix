{ config, pkgs, ... }:

let
  inherit (builtins) readFile;
  inherit (config) host;
in
{
  systemd.services."backup-${host.name}" = {
    description = "Mirror ${host.name} to closet";

    startAt = "00,12,17:00 America/Los_Angeles";
    unitConfig.ConditionACPower = true;
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    onFailure = [ "alert@%n.service" ];

    path = with pkgs; [ curl netcat openssh rsync ];
    script = readFile (host.dir + "/assets/mirror.local.sh");

    serviceConfig = {
      Nice = 10;
      Type = "oneshot";
    };
  };

  systemd.timers."backup-${host.name}".timerConfig.Persistent = true;
}
