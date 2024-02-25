{ config, ... }:
let
  cfg = config.sane.programs.wireplumber;
in
{
  sane.programs.wireplumber = {
    persist.byStore.plaintext = [
      # persist per-device volume levels
      ".local/state/wireplumber"
    ];

    services.wireplumber = {
      description = "wireplumber: pipewire Multimedia Service Session Manager";
      after = [ "pipewire.service" ];
      bindsTo = [ "pipewire.service" ];
      wantedBy = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/wireplumber";
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
