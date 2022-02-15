{pkgs, lib, ...}:
let
  inherit (lib) mkForce;
  inherit (pkgs) dunst procps;
  inherit (pkgs.custom) rofi;
in
  {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          "monitor" = 0;
          "follow" = "mouse";
          "geometry" = "300x60-20+48";
          "indicate_hidden" = true;
          "shrink" = true;
          "separator_height" = 2;
          "separator_color" = "auto";
          "padding" = 5;
          "horizontal_padding" = 5;
          "text_icon_padding" = 5;
          "frame_width" = 2;
          "sort" = false;
          "idle_threshold" = 120;
          "font" = "rissole 8";
          "line_height" = 4;
          "markup" = "full";
          "dmenu" = "${rofi}/bin/dmenu";
          "format" = "%s %p\n%b";
          "alignment" = "left";
          "show_age_threshold" = 60;
          "word_wrap" = true;
          "ignore_newline" = false;
          "stack_duplicates" = false;
          "hide_duplicate_count" = false;
          "show_indicators" = false;
          "icon_position" = "off";
          "sticky_history" = true;
          "history_length" = 20;
          "browser" = "xdg-open";
          "always_run_script" = true;
          "title" = "Dunst";
          "class" = "Dunst";
        };
        "shortcuts" = {
          "close" = "ctrl+space";
          "close_all" = "ctrl+shift+space";
          "history" = "ctrl+grave";
          "context" = "ctrl+shift+period";
        };
        "urgency_low" = {
        # IMPORTANT: colors have to be defined in quotation marks.
        # Otherwise the "#" and following would be interpreted as a comment.
        "frame_color" = "#1D918B";
        "foreground" = "#FFEE79";
        "background" = "#18191E";
        "timeout" = 5;
      };
      "urgency_normal" = {
        "frame_color" = "#D16BB7";
        "foreground" = "#FFEE79";
        "background" = "#18191E";
        "timeout" = 10;
      };
      "urgency_critical" = {
        "frame_color" = "#FC2929";
        "foreground" = "#FFFF00";
        "background" = "#18191E";
        "timeout" = 10;
      };
    };
  };
}
