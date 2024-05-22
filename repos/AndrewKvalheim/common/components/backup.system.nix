{ config, pkgs, ... }:

let
  inherit (builtins) readFile;
in
{
  systemd.services.mirror = {
    description = "Mirror to closet";
    serviceConfig.Type = "oneshot";
    serviceConfig.Nice = 10;
    startAt = "00,12,17:00 America/Los_Angeles";
    onFailure = [ "alert@%n.service" ];
    path = with pkgs; [ curl netcat openssh rsync ];
    script = readFile (config.host.local + "/resources/mirror.sh");
  };

  systemd.timers.mirror.timerConfig.Persistent = true;
}
