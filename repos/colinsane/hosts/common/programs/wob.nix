{ config, lib, ... }:
let
  cfg = config.sane.programs.wob;
in
{
  sane.programs.wob = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
        options.sock = mkOption {
          type = types.str;
          default = "sxmo.wobsock";
        };
      };
    };

    services.wob = {
      description = "Wayland Overlay Bar (renders volume/backlight levels)";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        # ExecStart = "${cfg.package}/bin/wob";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      script = ''
        wobsock="$XDG_RUNTIME_DIR/${cfg.config.sock}"
        rm -f "$wobsock" || true
        mkfifo "$wobsock" && ${cfg.package}/bin/wob <> "$wobsock"

        # TODO: cleanup should be done in a systemd OnFailure, or OnExit, or whatever
        rm -f "$wobsock"
      '';
    };
  };
}
