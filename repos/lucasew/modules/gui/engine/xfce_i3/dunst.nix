{pkgs, ...}: let
  inherit (pkgs) dunst custom;
  inherit (custom) colorpipe;
in {
environment.etc."dunstconfig".text = ''
[global]
alignment="left"
always_run_script=yes
browser="xdg-open"
class="Dunst"
dmenu="dmenu"
follow="mouse"
font="rissole 8"
format="%s %p
%b"
frame_width=2
geometry="300x60-20+48"
hide_duplicate_count=no
history_length=20
horizontal_padding=5
icon_theme=paper
icon_position="off"
idle_threshold=120
ignore_newline=no
indicate_hidden=yes
line_height=4
markup="full"
monitor=0
padding=5
separator_color="auto"
separator_height=2
show_age_threshold=60
show_indicators=no
shrink=yes
sort=no
stack_duplicates=no
sticky_history=yes
text_icon_padding=5
title="Dunst"
word_wrap=yes

[shortcuts]
close="ctrl+space"
close_all="ctrl+shift+space"
context="ctrl+shift+period"
history="ctrl+grave"

[urgency_critical]
background="#%base08%"
foreground="#%base06%"
timeout=10

[urgency_low]
background="#%base01%"
foreground="#%base03%"
timeout=5

[urgency_normal]
background="#%base02%"
foreground="#%base05%"
timeout=10
    '';
  systemd.user.services.dunst = {
    wantedBy = [ "graphical-session.target" ];
    enable = true;
    restartIfChanged = true;
    path = [ dunst colorpipe ];
    script = ''
      cat /etc/dunstconfig | colorpipe > /run/user/`id -u`/dunstconfig
      dunst -config /run/user/`id -u`/dunstconfig
    '';
  };
}
