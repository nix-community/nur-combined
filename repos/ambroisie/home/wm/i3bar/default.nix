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
              buttons = [ "prev" "play" "next" ];
              max_width = 50;
              dynamic_width = true;
              hide_when_empty = true;
            }
            (lib.optionalAttrs config.my.home.bluetooth.enable {
              block = "bluetooth";
              mac = "4C:87:5D:06:40:D9";
              hide_disconnected = true;
              format = "Boson {percentage}";
            })
            (lib.optionalAttrs config.my.home.bluetooth.enable {
              block = "bluetooth";
              mac = "94:DB:56:00:EE:93";
              hide_disconnected = true;
              format = "Protons {percentage}";
            })
            (lib.optionalAttrs config.my.home.bluetooth.enable {
              block = "bluetooth";
              mac = "F7:78:BA:76:52:F7";
              hide_disconnected = true;
              format = "MX Ergo {percentage}";
            })
            {
              block = "cpu";
            }
            {
              block = "disk_space";
            }
            {
              block = "net";
              format = "{ssid} {ip} {signal_strength}";
            }
            {
              block = "backlight";
              invert_icons = true;
            }
            {
              block = "battery";
              format = "{percentage} ({time})";
              full_format = "{percentage}";
            }
            {
              block = "temperature";
              collapsed = false;
            }
            {
              block = "sound";
              device_kind = "source"; # Microphone status
              format = ""; # Only show icon
            }
            {
              block = "sound";
              show_volume_when_muted = true;
            }
            {
              block = "time";
              format = "%F %T";
            }
          ];
        };
      };
    };
  };
}
