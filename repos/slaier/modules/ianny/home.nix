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

  xdg.configFile."io.github.zefr0x.ianny/config.toml".text = ''
    [timer]
    ignore_idle_inhibitors = true
    idle_timeout = 240
    short_break_timeout = 1200
    long_break_timeout = 3840
    short_break_duration = 120
    long_break_duration = 240

    [notification]
    show_progress_bar = true
    minimum_update_delay = 2
  '';

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
