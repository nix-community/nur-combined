# docs:
# - <https://github.com/francma/wob/blob/master/wob.ini.5.scd>
# - `wob -vv` to see config defaults
#
# the wob services defined here are largely based on those from SXMO.
#
# this should arguably be just a (user) service. nothing actually needs `wob` on the PATH.
#
{ config, lib, pkgs, ... }:
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

    fs.".config/wob/wob.ini".symlink.text = ''
      timeout = 900

      anchor = top right
      orientation = vertical
      # margin top right bottom left
      # note that wob is "aware" of the sway bar, so margin 0 never overlaps it.
      # however it's not aware of sway's window title
      margin = 54 3 54 3

      height = 164
      width = 30

      border_offset = 0
      border_size = 2
      bar_padding = 0

      # very light teal, derived from conky background
      bar_color = e1f0efDC
      background_color = 000000B4
      border_color = 000000C8

      overflow_bar_color = FF4040DC
      overflow_background_color = FFFFFFC8
      overflow_border_color = FF4040DC
    '';

    services.wob = {
      description = "Wayland Overlay Bar (renders volume/backlight levels)";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        # ExecStart = "${cfg.package}/bin/wob";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      path = [ cfg.package ];
      script = ''
        wobsock="$XDG_RUNTIME_DIR/${cfg.config.sock}"
        rm -f "$wobsock" || true
        mkfifo "$wobsock" && wob <> "$wobsock"

        # TODO: cleanup should be done in a systemd OnFailure, or OnExit, or whatever
        rm -f "$wobsock"
      '';
    };

    services.wob-pulse = {
      description = "notify wob when pulseaudio volume changes";
      wantedBy = [ "wob.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      path = with pkgs; [
        # coreutils
        gnugrep
        gnused
        pulseaudio
      ];

      script = ''

        volismuted() {
          pactl get-sink-mute @DEFAULT_SINK@ | grep -q "Mute: yes"
        }

        volget() {
          if volismuted; then
            printf "0"
          else
            pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | cut -d'/' -f2 | sed 's/ //g' | sed 's/\%//'
          fi
        }

        notify_volume_change() {
          vol=$(volget)
          if [ "$vol" != "$lastvol" ]; then
            printf "%s\n" "$vol" > "$XDG_RUNTIME_DIR/${cfg.config.sock}"
          fi
          lastvol="$vol"
        }

        pactl subscribe | while read -r line; do
          case "$line" in
            "Event 'change' on sink "*)
              notify_volume_change
              ;;
            "Event 'change' on source "*)
              # microphone volume changed. ignore.
              ;;
          esac
        done
      '';
    };
  };
}
