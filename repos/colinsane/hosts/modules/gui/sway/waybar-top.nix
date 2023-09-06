# docs: <https://github.com/Alexays/Waybar/wiki/Configuration>
# format specifiers: <https://fmt.dev/latest/syntax.html#syntax>
{ lib, pkgs }:
{
  height = lib.mkDefault 40;
  modules-left = lib.mkDefault [ "sway/workspaces" ];
  modules-center = lib.mkDefault [ "sway/window" ];
  modules-right = lib.mkDefault [
    "custom/media"
    "custom/swaync"
    "clock"
    "battery"
    "memory"
    "cpu"
    "network"
  ];

  "sway/window" = {
    max-length = 50;
  };

  # include song artist/title.
  # source: <https://www.reddit.com/r/swaywm/comments/ni0vso/waybar_spotify_tracktitle/>
  "custom/media" = {
    exec = pkgs.writeShellScript "waybar-mediaplayer" ''
      player_status=$(${pkgs.playerctl}/bin/playerctl status 2> /dev/null)
      if [ "$player_status" = "Playing" ]; then
        echo " $(${pkgs.playerctl}/bin/playerctl metadata artist) - $(${pkgs.playerctl}/bin/playerctl metadata title)"
      elif [ "$player_status" = "Paused" ]; then
        echo " $(${pkgs.playerctl}/bin/playerctl metadata artist) - $(${pkgs.playerctl}/bin/playerctl metadata title)"
      fi
    '';
    interval = 2;
    format = "{}";
    # return-type = "json";
    on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
    on-scroll-up = "${pkgs.playerctl}/bin/playerctl next";
    on-scroll-down = "${pkgs.playerctl}/bin/playerctl previous";
  };
  "custom/swaync" = {
    # source: <https://github.com/ErikReider/SwayNotificationCenter#waybar-example>
    tooltip = false;
    format = "{icon}";  # or "{icon} {}" to inclde notif count
    format-icons = {
      notification = "<span foreground='red'><sup></sup></span>";
      none = "";
      dnd-notification = "<span foreground='red'><sup></sup></span>";
      dnd-none = "";
      inhibited-notification = "<span foreground='red'><sup></sup></span>";
      inhibited-none = "";
      dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
      dnd-inhibited-none = "";
    };
    return-type = "json";
    exec-if = "which swaync-client";
    exec = "swaync-client -swb";
    on-click = "swaync-client -t -sw";
    on-click-right = "swaync-client -d -sw";
    escape = true;
  };
  network = {
    # docs: <https://github.com/Alexays/Waybar/blob/master/man/waybar-network.5.scd>
    interval = 2;
    max-length = 40;
    # custom :> format specifier explained here:
    # - <https://github.com/Alexays/Waybar/pull/472>
    format-ethernet = " {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";
    tooltip-format-ethernet = "{ifname} {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";

    format-wifi = "{ifname} ({signalStrength}%) {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";
    tooltip-format-wifi = "{essid} ({signalStrength}%) {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";

    format-disconnected = "";
  };
  cpu = {
    format = " {usage:2}%";
    tooltip = false;
  };
  memory = {
    format = "☵ {percentage:2}%";
    tooltip = false;
  };
  battery = {
    states = {
      good = 95;
      warning = 30;
      critical = 10;
    };
    format = "{icon} {capacity}%";
    format-icons = [
      ""
      ""
      ""
      ""
      ""
    ];
  };
  clock = {
    format-alt = "{:%a, %d. %b  %H:%M}";
  };
}
