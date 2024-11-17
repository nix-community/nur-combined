# docs: <https://github.com/Alexays/Waybar/wiki/Configuration>
# - custom modules: <https://github.com/Alexays/Waybar/wiki/Module:-Custom>
# - format specifiers: <https://fmt.dev/latest/syntax.html#syntax>
{ lib, static-nix-shell }:
let
  waybar-media = static-nix-shell.mkBash {
    pname = "waybar-media";
    srcRoot = ./.;
    pkgs = [ "jq" "playerctl" ];
  };
in
{ height, modules, persistWorkspaces }:
{
  inherit height;
  modules-left = [ "sway/workspaces" ];
  modules-center = lib.mkIf modules.windowTitle [ "sway/window" ];
  modules-right = lib.flatten [  # XXX can't use lib.mkMerge here without error ??
    (lib.optionals modules.media [ "custom/media" ])
    [ "custom/swaync" "clock" "battery" ]
    (lib.optionals modules.perf [ "memory" "cpu" ])
    (lib.optionals modules.network [ "network" ])
  ];

  "sway/window" = {
    max-length = 50;
  };

  "sway/workspaces".persistent-workspaces = lib.mkIf (persistWorkspaces != []) (
    lib.genAttrs persistWorkspaces (_: [])
  );

  "custom/media" = {
    # this module shows the actively playing song
    # - source: <https://www.reddit.com/r/swaywm/comments/ni0vso/waybar_spotify_tracktitle/>
    # - alternative: <https://github.com/Alexays/Waybar/wiki/Module:-MPRIS>
    # - alternative: <https://github.com/Alexays/Waybar/wiki/Module:-Custom#mpris-controller>
    # - alternative: <https://www.reddit.com/r/swaywm/comments/g6nw46/comment/fob604s/>
    #   - this one shades the background based on how far through the song you are
    #
    # N.B.: for this to behave well with multiple MPRIS clients,
    # `playerctld` must be enabled. see: <https://github.com/altdesktop/playerctl/issues/161>
    exec = lib.getExe waybar-media;
    return-type = "json";
    interval = 2;
    format = "{icon}{}";
    max-length = 50;
    format-icons = {
      playing = " ";
      paused = " ";
      inactive = "";
    };
    tooltip = false;
    on-click = "playerctl play-pause";
    on-scroll-up = "playerctl next";
    on-scroll-down = "playerctl previous";
  };
  "custom/swaync" = {
    # source: <https://github.com/ErikReider/SwayNotificationCenter#waybar-example>
    exec-if = "which swaync-client";
    exec = "swaync-client -swb";
    return-type = "json";
    escape = true;
    format = "{icon}";  # or "{icon} {}" to include notif count
    format-icons = {
      notification = "<span foreground='#ff968b'><sup></sup></span>";
      none = "";
      dnd-notification = "<span foreground='#ff968b'><sup></sup></span>";
      dnd-none = "";
      inhibited-notification = "<span foreground='#ff968b'><sup></sup></span>";
      inhibited-none = "";
      dnd-inhibited-notification = "<span foreground='#ff968b'><sup></sup></span>";
      dnd-inhibited-none = "";
    };
    tooltip = false;
    on-click = "swaync-client -t -sw";
    on-click-right = "swaync-client -d -sw";
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
