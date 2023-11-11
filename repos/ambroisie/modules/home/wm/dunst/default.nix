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
          dmenu =
            lib.mkIf
              config.my.home.wm.rofi.enable
              "rofi -p dunst -dmenu"; # use rofi for menu
          follow = "keyboard"; # follow keyboard focus
          font = "Monospace 8"; # Simple looking font
          frame_width = 3; # small frame
          markup = "full"; # subset of HTML
          max_icon_size = 32; # avoid icons that are too big
          padding = 6; # distance between text and bubble border
          progress_bar = true; # show a progress bar in notification bubbles
          separator_color = "frame"; # use frame color to separate bubbles
          sort = true; # sort messages by urgency
          word_wrap = true; # Break long lines to make them readable

          # Fixed size notifications, slightly recessed from the top right
          width = 300;
          height = 50;
          origin = "top-right";
          offset = "15x50";
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
