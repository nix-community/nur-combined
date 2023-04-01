{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.i3bar;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      alsa-utils # Used by `sound` block
      lm_sensors # Used by `temperature` block
      font-awesome # Icon font
    ];

    programs.i3status-rust = {
      enable = true;

      bars = {
        top = {
          icons = "awesome5";

          blocks = builtins.filter (attr: attr != { }) [
            {
              block = "music";
              # This format seems to remove the block when not playing, somehow
              format = "{ $icon $combo.str(max_w:50,rot_interval:0.5)  $prev  $play  $next |}";
              click = [
                {
                  button = "play";
                  action = "music_play";
                }
                {
                  button = "prev";
                  action = "music_prev";
                }
                {
                  button = "next";
                  action = "music_next";
                }
              ];
            }
            (lib.optionalAttrs config.my.home.bluetooth.enable {
              block = "bluetooth";
              mac = "4C:87:5D:06:40:D9";
              format = " $icon Boson{ $percentage|} ";
              disconnected_format = "";
            })
            (lib.optionalAttrs config.my.home.bluetooth.enable {
              block = "bluetooth";
              mac = "94:DB:56:00:EE:93";
              format = " $icon Protons{ $percentage|} ";
              disconnected_format = "";
            })
            (lib.optionalAttrs config.my.home.bluetooth.enable {
              block = "bluetooth";
              mac = "F7:78:BA:76:52:F7";
              format = " $icon MX Ergo{ $percentage|} ";
              disconnected_format = "";
            })
            {
              block = "cpu";
            }
            {
              block = "disk_space";
            }
            {
              block = "net";
              format = " $icon $ssid $ip $signal_strength ";
            }
            {
              block = "backlight";
              invert_icons = true;
            }
            {
              block = "battery";
              format = " $icon $percentage{ ($time)|} ";
              not_charging_format = " $icon $percentage ";
              full_format = " $icon $percentage ";
            }
            {
              block = "temperature";
              format_alt = " $icon ";
            }
            {
              block = "sound";
              device_kind = "source"; # Microphone status
              format = " $icon ";
            }
            {
              block = "sound";
              show_volume_when_muted = true;
            }
            {
              block = "time";
              format = " $icon $timestamp.datetime(f:'%F %T') ";
              interval = 5;
            }
          ];
        };
      };
    };
  };
}
