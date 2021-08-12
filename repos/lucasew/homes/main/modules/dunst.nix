{pkgs, lib, ...}:
{
  services.dunst = {
    enable = true;
    settings = lib.mkForce {};
  };
  home.packages = with pkgs; [
    dunst
    custom_rofi
  ];
  xdg.configFile."dunst/dunstrc" = {
    text = ''
# Also stolen from: https://addy-dclxvi.github.io/post/dunst/
[global]
monitor = 0
follow = mouse
geometry = "300x60-20+48"
indicate_hidden = yes
shrink = yes
separator_height = 2
separator_color = auto;
padding = 5
horizontal_padding = 5
text_icon_padding = 5
frame_width = 2
sort = no
idle_threshold = 120
font = rissole 8
line_height = 4
markup = full
dmenu = ${pkgs.custom_rofi}/bin/dmenu
format = %s %p\n%b
alignment = left
show_age_threshold = 60
word_wrap = yes
ignore_newline = no
stack_duplicates = false
hide_duplicate_count = yes
show_indicators = no
icon_position = off
sticky_history = yes
history_length = 20
browser = /usr/bin/firefox -new-tab
always_run_script = true
title = Dunst
class = Dunst

[shortcuts]
close = ctrl+space
close_all = ctrl+shift+space
history = ctrl+grave
context = ctrl+shift+period

# stolen from: https://github.com/lighthaus-theme/dunst
[urgency_low]
# IMPORTANT: colors have to be defined in quotation marks.
# Otherwise the "#" and following would be interpreted as a comment.
frame_color = "#1D918B"
foreground = "#FFEE79"
background = "#18191E"
timeout = 5

[urgency_normal]
frame_color = "#D16BB7"
foreground = "#FFEE79"
background = "#18191E"
timeout = 10

[urgency_critical]
frame_color = "#FC2929"
foreground = "#FFFF00"
background = "#18191E"
timeout = 10
    '';
    onChange = ''
        pkillVerbose=""
        if [[ -v VERBOSE ]]; then
          pkillVerbose="-e"
        fi
        $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -u $USER $pkillVerbose dunst || true
        unset pkillVerbose
    '';
  };

}
