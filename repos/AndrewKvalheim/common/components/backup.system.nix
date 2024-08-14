{ config, pkgs, ... }:

let
  inherit (builtins) readFile;
  inherit (config) host;
in
{
  systemd.services."backup-${host.name}" = {
    description = "Mirror ${host.name} to closet";
    serviceConfig.Type = "oneshot";
    serviceConfig.Nice = 10;
    startAt = "00,12,17:00 America/Los_Angeles";
    onFailure = [ "alert@%n.service" ];
    path = with pkgs; [ curl netcat openssh rsync ];
    script = readFile (host.local + "/resources/mirror.sh");
  };

  systemd.timers."backup-${host.name}".timerConfig.Persistent = true;
}
