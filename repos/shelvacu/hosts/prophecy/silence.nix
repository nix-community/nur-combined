{ pkgs, ... }:
let
  serialNode = "/dev/ttyUSB0";
in
{
  systemd.services.silence-equallogic = {
    script = ''
      if ! [[ -e ${serialNode} ]]; then
        echo "${serialNode} does not exist" >&2
        exit 1
      fi
      ${pkgs.coreutils}/bin/stty -F ${serialNode} 38400 raw -echoe -echok -echoctl -echoke
      for _ in {1..5}; do
        printf 'set_speed 10\r' > ${serialNode}
        sleep 1
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
  systemd.timers.silence-equallogic = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitInactiveSec = "1h";
    };
  };
}
