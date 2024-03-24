# docs: https://github.com/Alexays/Waybar/wiki/Configuration
# format specifiers: https://fmt.dev/latest/syntax.html#syntax
# this is merged with the sway/waybar-top.nix defaults
{
  height = 26;

  modules-left = [ "sway/workspaces" ];
  modules-center = [ ];
  modules-right = [
    "custom/swaync"
    "clock"
    "battery"
    "custom/sxmo-sane"
    # "custom/sxmo"
    # "custom/sxmo/modem-state"
    # "custom/sxmo/modem-tech"
    # "custom/sxmo/modem-signal"
    # "custom/sxmo/wifi"
  ];

  "sway/workspaces" = {
    all-outputs = true;
    # force the bar to always show even empty workspaces
    persistent-workspaces = {
      "1" = [];
      "2" = [];
      "3" = [];
      "4" = [];
      "5" = [];
    };
  };

  "custom/sxmo-sane" = {
    # this calls all the SXMO indicators, inline.
    # so it works even without the "statusbar periodics" sxmo service running.
    interval = 2;
    format = "{}";
    exec = "waybar-sxmo-status modem-state modem-tech modem-signal wifi-status volume";
  };

  "custom/sxmo" = {
    # this gives wifi state, battery, mic/speaker, lockstate, time all as one widget.
    # a good starting point, but may want to split these apart later to make things configurable.
    # the values for this bar are computed in sxmo:configs/default_hooks/sxmo_hook_statusbar.sh
    exec = "sxmo_status.sh";
    interval = 1;
    format = "{}";
  };
  # not ported: battery, ethernet
  "custom/sxmo/modem-state" = {
    exec = "cat /run/user/1000/sxmo_status/default/10-modem-state";
    interval = 2;
    format = "{}";
  };
  "custom/sxmo/modem-tech" = {
    exec = "cat /run/user/1000/sxmo_status/default/11-modem-tech";
    interval = 2;
    format = "{}";
  };
  "custom/sxmo/modem-signal" = {
    exec = "cat /run/user/1000/sxmo_status/default/12-modem-signal";
    interval = 2;
    format = "{}";
  };
  "custom/sxmo/wifi" = {
    exec = "cat /run/user/1000/sxmo_status/default/30-wifi-status";
    interval = 2;
    format = "{}";
  };
  "custom/sxmo/volume" = {
    exec = "cat /run/user/1000/sxmo_status/default/50-volume";
    interval = 2;
    format = "{}";
  };
  "custom/sxmo/state" = {
    exec = "cat /run/user/1000/sxmo_status/default/90-state";
    interval = 2;
    format = "{}";
  };
  "custom/sxmo/time" = {
    exec = "cat /run/user/1000/sxmo_status/default/99-time";
    interval = 2;
    format = "{}";
  };
}
