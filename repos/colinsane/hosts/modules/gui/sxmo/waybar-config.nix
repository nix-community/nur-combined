# docs: https://github.com/Alexays/Waybar/wiki/Configuration
# format specifiers: https://fmt.dev/latest/syntax.html#syntax
{ pkgs }:
[
  { # TOP BAR
    layer = "top";
    height = 32;

    modules-left = [ "sway/workspaces" ];
    modules-center = [ ];
    modules-right = [ "custom/sxmo" ];

    "sway/workspaces" = {
      all-outputs = true;
      # force the bar to always show even empty workspaces
      persistent_workspaces = {
        "1" = [];
        "2" = [];
        "3" = [];
        "4" = [];
        "5" = [];
      };
    };

    "custom/sxmo" = {
      # this gives wifi state, batter, mic/speaker, lockstate, time all as one widget.
      # a good starting point, but may want to split these apart later to make things configurable.
      # e.g. distinct vol-up & vol-down buttons next to the speaker?
      exec = "sxmo_status.sh";
      interval = 1;
      format = "{}";
    };
  }
]
