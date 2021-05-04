{ config, lib, ... }:
let
  cfg = config.my.home.wm.dunst;
in
{
  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;

      settings = {
        global = {
          alignment = "center"; # Put message in the middle of the box
          browser = "xdg-open"; # use default browser to open links
          follow = "keyboard"; # follow keyboard focus
          font = "Monospace 8"; # Simple looking font
          frame_width = 3; # small frame
          geometry = "300x50-15+49";
          markup = "full"; # subset of HTML
          padding = 6; # distance between text and bubble border
          progress_bar = true; # show a progress bar in notification bubbles
          separator_color = "frame"; # use frame color to separate bubbles
          sort = true; # sort messages by urgency
        };

        urgency_low = {
          background = "#191311";
          foreground = "#3b7c87";
          frame_color = "#3b7c87";
          highlight = "#4998a6";
          timeout = 10;
        };

        urgency_normal = {
          background = "#191311";
          foreground = "#5b8234";
          frame_color = "#5b8234";
          highlight = "#73a542";
          timeout = 10;
        };

        urgency_critical = {
          background = "#191311";
          foreground = "#b7472a";
          frame_color = "#b7472a";
          highlight = "#d25637";
          timeout = 0;
        };

        fullscreen_delay_everything = {
          # delay notifications by default
          fullscreen = "delay";
        };

        fullscreen_show_critical = {
          # show critical notification
          fullscreen = "show";
          msg_urgency = "critical";
        };
      };
    };
  };
}
