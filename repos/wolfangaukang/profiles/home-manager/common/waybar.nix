{ config, pkgs, lib, ... }:

let
  battery-module = {
    format = "{capacity}% {icon}";
    format-icons = ["" "" "" "" ""];
    states = {
      "warning" = 20;
      "critical" = 15;
    };
  };
  backlight-module = {
    format = "{percent}%  ";
  };
  clock-module = {
    format = "{:%a, %d %b %Y %H:%M}";
  };
  network-module = {
    #interface = "wlp3s0";
    #interface = "enp0s25";
    format = "{ifname}  ";
    format-wifi = "{essid} ({signalStrength}%) {bandwidthUpBits}|{bandwidthDownBits}   ";
    format-wired = "{ifname} {bandwidthUpBits}|{bandwidthDownBits}  ";
    format-disconnected = "";
    tooltip-format = "{ifname}";
    tooltip-format-wifi = "{essid} ({signalStrength}%) ";
    tooltip-format-wired = "{ifname} ";
    tooltip-format-disconnected = "Disconnected";
  };
  temperature-module = {
    format = "{temperatureC}°C ";
  };
  volume-module = {
    format = "{}%  ";
    max-length = 20;
    interval = 60;
    exec = pkgs.writeShellScript "waybar_get_volume" ''
      pamixer --get-volume; pkill -SIGRTMIN+2 waybar
    '';
    signal = 2;
  };
  sway-mode-module = {
    format = " {}";
  };

in {
  home.packages = with pkgs; [ pamixer ];
  programs.waybar = {
    enable = true;
    style = builtins.readFile ../../../../config/waybar/style.css.rbnis;
    settings = [{
      height = 7;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" "network" "custom/pulseaudio" "backlight" "temperature" "battery" ];
      modules = {
        "sway/mode" = sway-mode-module;
        "backlight" = backlight-module;
        "custom/pulseaudio" = volume-module;
        "battery" = battery-module;
        "clock" = clock-module;
        "network" = network-module;
        "temperature" = temperature-module;
      };
    }];
  };
}
