{ pkgs, lib, ... }:

let
  serviceName = "app-io.github.zefr0x.ianny@autostart.service";
  monitorIannyServiceScript = pkgs.writeShellScript "monitor-ianny-service-script" ''
    #!/usr/bin/env bash

    journalctl --user -f -u "${serviceName}" | while IFS= read -r line; do
        echo "$line"
        if [[ "$line" == *starts || "$line" == *ends ]]; then
          ${lib.getExe pkgs.playerctl} -p spotify play-pause
        fi
    done
  '';
in
{
  systemd.user.enable = true;

  systemd.user.services = {
    "monitor-ianny-log" = {
      Unit = {
        Description = "Monitor ianny service log";
        After = [ serviceName ];
        PartOf = [ serviceName ];
      };
      Service = {
        ExecStart = "${monitorIannyServiceScript}";
        Restart = "on-failure";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
