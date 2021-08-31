{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.i3bar;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      alsaUtils # Used by `sound` block
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
              hide_when_empty = true;
            }
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
