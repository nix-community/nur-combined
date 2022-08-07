{ global, config, pkgs, lib, ... }:
let
  inherit (lib) mkForce;

  inherit (pkgs) i3lock-color writeTextFile writeShellScript pulseaudio playerctl makeDesktopItem custom brightnessctl networkmanagerapplet feh blueberry xorg gawk dunst;
  inherit (pkgs.custom) wallpaper;
  inherit (pkgs.custom.colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
  custom_rofi = let
      commonFlags = "-theme gruvbox-dark -show-icons";
    in
    pkgs.symlinkJoin {
      name = "custom-rofi";
      paths = [
        (pkgs.writeShellScriptBin "rofi-launch" ''
          ${pkgs.rofi}/bin/rofi -show combi -combi-modi drun ${commonFlags}
        '')
        (pkgs.writeShellScriptBin "rofi-window" ''
          ${pkgs.rofi}/bin/rofi -show combi -combi-modi window ${commonFlags}
        '')
        (pkgs.writeShellScriptBin "dmenu" ''
          ${pkgs.rofi}/bin/rofi -dmenu ${commonFlags}
        '')
      ];
    };

  polybar = pkgs.polybar.override {
    alsaSupport = true;
    pulseSupport = true;
    i3Support = true;
  };

  mod = "Mod4";
  pactl = "${pulseaudio}/bin/pactl";
  playerctl-bin = "${playerctl}/bin/playerctl";
  modn = writeShellScript "modn" ''
    goto_ws=$(i3-msg i3-msg -t get_workspaces | jq '.[] | select(.focused == true) | "i3-msg workspace number " + .name' | sed s/\"//g)

    i3-msg -t get_outputs | jq '.[] | select(.current_workspace != null) |  "i3-msg workspace number " + .current_workspace + ";i3-msg move workspace to output left"' | sed s/\"//g | bash

    echo $goto_ws | bash
  '';
  sendToPQP = writeShellScript "sendToPQP" ''
    ws=$[ $RANDOM % 100 + 11 ]
    i3-msg move container to workspace number $ws
    i3-msg workspace number $ws
  '';
  gotoNewWs = writeShellScript "gotoNewWs" ''
    ws=$[ $RANDOM % 100 + 11 ]
    i3-msg workspace number $ws
  '';
  locker = writeShellScript "locker" ''
    loginctl lock-session
    sleep 1
    xset dpms force off
  '';
  lockerSpace = makeDesktopItem {
    name = "locker";
    desktopName = "Bloquear Tela";
    icon = "lock";
    type = "Application";
    exec = "${locker}";
  };
in
  {
    environment.etc."i3config".text = mkForce ''
        set $mod ${mod}

        # Property Name         Border    Background Text     Indicator  Child
        client.focused          #${base01} #${base00} #${base05} #${base0D} #${base0C}
        client.focused_inactive #${base01} #${base01} #${base05} #${base03} #${base01}
        client.unfocused        #${base01} #${base02} #${base05} #${base01} #${base01}
        client.urgent           #${base08} #${base08} #${base00} #${base08} #${base08}
        client.placeholder      #${base00} #${base00} #${base05} #${base00} #${base00}
        client.background       #${base07}

        bindsym $mod+0 workspace number 10
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+6 workspace number 6
        bindsym $mod+7 workspace number 7
        bindsym $mod+8 workspace number 8
        bindsym $mod+9 workspace number 9
        bindsym $mod+Down focus down
        bindsym $mod+Left focus left
        bindsym $mod+Return exec xfce4-terminal
        bindsym $mod+Right focus right
        bindsym $mod+Shift+0 move container to workspace number 10
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
        bindsym $mod+Shift+4 move container to workspace number 4
        bindsym $mod+Shift+5 move container to workspace number 5
        bindsym $mod+Shift+6 move container to workspace number 6
        bindsym $mod+Shift+7 move container to workspace number 7
        bindsym $mod+Shift+8 move container to workspace number 8
        bindsym $mod+Shift+9 move container to workspace number 9
        bindsym $mod+Shift+Down move down
        bindsym $mod+Shift+Left move left
        bindsym $mod+Shift+Right move right
        bindsym $mod+Shift+Up move up
        bindsym $mod+Shift+c reload
        bindsym $mod+Shift+e exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'xfce4-session-logout'
        bindsym $mod+Shift+f floating toggle
        bindsym $mod+Shift+minus move scratchpad
        bindsym $mod+Shift+q kill
        bindsym $mod+Shift+r restart
        bindsym $mod+Up focus up
        bindsym $mod+a focus parent
        bindsym $mod+d exec ${custom_rofi}/bin/rofi-launch
        bindsym $mod+Shift+d exec ${custom_rofi}/bin/rofi-window
        bindsym $mod+e layout toggle split
        bindsym $mod+f fullscreen toggle
        bindsym $mod+h split h
        bindsym $mod+minus scratchpad show
        bindsym $mod+s layout stacking
        bindsym $mod+space focus mode_toggle
        bindsym $mod+v split v
        bindsym $mod+w layout tabbed
        bindsym $mod+Ctrl+Right=resize shrink width 1 px or 1 ppt
        bindsym $mod+Ctrl+Up=resize grow height 1 px or 1 ppt
        bindsym $mod+Ctrl+Down=resize shrink height 1 px or 1 ppt
        bindsym $mod+Ctrl+Left=resize grow width 1 px or 1 ppt

          # custom keys
          bindsym XF86AudioRaiseVolume exec ${pactl} set-sink-volume @DEFAULT_SINK@ +10%
          bindsym XF86AudioLowerVolume exec ${pactl} set-sink-volume @DEFAULT_SINK@ -10%
          bindsym XF86AudioMute exec ${pactl} set-sink-volume @DEFAULT_SINK@ toggle
          bindsym XF86AudioMicMute exec ${pactl} set-sink-volume @DEFAULT_SOURCE@ toggle
          bindsym $mod+l exec ${locker}
          bindsym $mod+m move workspace to output left
          bindsym $mod+n exec ${modn}
          bindsym $mod+b exec ${gotoNewWs}
          bindsym $mod+Shift+b exec ${sendToPQP}
          bindsym XF86AudioNext exec ${playerctl-bin} next
          bindsym XF86AudioPrev exec ${playerctl-bin} previous
          bindsym XF86AudioPlay exec ${playerctl-bin} play-pause
          bindsym XF86AudioPause exec ${playerctl-bin} play-pause
          bindsym XF86MonBrightnessUp exec ${brightnessctl}/bin/brightnessctl s +5%
          bindsym XF86MonBrightnessDown exec ${brightnessctl}/bin/brightnessctl s 5%-
          exec --no-startup-id ${networkmanagerapplet}/bin/nm-applet
          exec --no-startup-id ${feh}/bin/feh --bg-center ~/.background-image
          exec --no-startup-id ${blueberry}/bin/blueberry-tray
          exec_always systemctl restart --user polybar.service
          exec_always ${feh}/bin/feh --bg-fill --no-xinerama --no-fehbg '${wallpaper}'

          default_border pixel 2
          hide_edge_borders smart
    '';

    environment.etc."polybarconfig".text = ''
[colors]
primary=${base05}

[bar/primary]
monitor=%primary_monitor%
background=${base00}
foreground=${base05}
border-size=0
cursor-click=pointer
cursor-scroll=ns-resize
enable-ipc=true
fixed-center=true
font-0=Noto:pixelsize=10;1
font-1=pango:Roboto, Light 7
font-2=siji:pixelsize=10;1
height=20
line-size=0
module-margin-left=1
module-margin-right=1
modules-center=cpu memory xkeyboard wlan netusage-wifi eth netusage-ethernet temperature pulseaudio battery date
modules-left=i3
padding-left=0
padding-right=0
radius=0
tray-padding=4
tray-position=right
width=100%

[bar/secondary]
monitor=%secondary_monitor%
background=${base00}
foreground=${base05}
border-size=0
cursor-click=pointer
cursor-scroll=ns-resize
enable-ipc=true
fixed-center=true
font-0=Noto:pixelsize=10;1
font-1=pango:Roboto, Light 7
font-2=siji:pixelsize=10;1
height=20
line-size=0
module-margin-left=1
module-margin-right=1
modules-center=temperature date
modules-left=i3
padding-left=0
padding-right=0
radius=0
width=100%

[global/wm]
margin-bottom=5
margin-top=5

[module/alsa]
type=internal/alsa
bar-volume-empty=─
bar-volume-empty-font=2
bar-volume-empty-foreground=${base03}
bar-volume-fill=─
bar-volume-fill-font=2
bar-volume-foreground-0=${base0B}
bar-volume-foreground-1=${base0B}
bar-volume-foreground-2=${base0B}
bar-volume-foreground-3=${base0A}
bar-volume-foreground-4=${base0A}
bar-volume-foreground-5=${base09}
bar-volume-foreground-6=${base09}
bar-volume-foreground-7=${base08}
bar-volume-gradient=false
bar-volume-indicator=|
bar-volume-indicator-font=2
bar-volume-width=10
format-muted-prefix=
format-volume=<label-volume> <bar-volume>
label-muted=sound muted
label-volume=VOL
label-volume-foreground=#dfdfdf

[module/backlight-acpi]
card=intel_backlight
inherit=module/xbacklight
type=internal/backlight

[module/battery]
adapter=ACAD
animation-charging-0=
animation-charging-1=
animation-charging-2=
animation-charging-framerate=750
animation-discharging-0=
animation-discharging-1=
animation-discharging-2=
animation-discharging-framerate=750
battery=BAT1
format-charging=<animation-charging> <label-charging>
format-discharging=<animation-discharging> <label-discharging>
format-full-prefix=" "
full-at=98
ramp-capacity-0=
ramp-capacity-1=
ramp-capacity-2=
type=internal/battery

[module/cpu]
format-prefix=" "
interval=2
label=%percentage:2%%
type=internal/cpu

[module/date]
date=
date-alt=%Y-%m-%d
format-prefix=
interval=5
label=%date% %time%
time=%H:%M
time-alt=%H:%M:%S
type=internal/date

[module/eth]
type=internal/network
format-connected-prefix=" "
format-disconnected=  OFF
interface=enp2s0f1
interval=3
label-connected=%local_ip%

[module/filesystem]
interval=25
label-mounted=%{F#0a81f5}%mountpoint:0:10:---%%{F-}: %percentage_used%%
label-unmounted=%mountpoint% OFF
label-unmounted-foreground=${base05}
mount-0=/
mount-1=/run/media/lucasew/Dados/
type=internal/fs

[module/i3]
type=internal/i3
pin-workspaces=true
wrapping-scroll=false

format=<label-state> <label-mode>
index-sort=true
label-mode-foreground=${base07}
label-mode-background=${base03}
label-mode-padding=2

label-focused=%index%
label-focused-foreground=${base05}
label-focused-background=${base01}
label-focused-underline=${base05}
label-focused-padding=2

label-visible=%index%
label-visible-foreground=${base03}
label-visible-background=${base00}
label-visible-underline=${base03}
label-visible-padding=2

label-unfocused=%index%
label-unfocused-padding=2
label-unfocused-foreground=${base03}
label-unfocused-background=${base00}

label-urgent=%index%
label-urgent-padding=4
label-urgent-foreground=${base07}
label-urgent-background=${base03}

[module/memory]
type=internal/memory
format-prefix-foreground=${base05}
interval=2
label= %percentage_used%%

[module/netusage-ethernet]
type=internal/network
interface=enp2s0f1
interval=1
label-connected=↓ %downspeed% ↑ %upspeed%
label-disconnected=

[module/netusage-wifi]
type=internal/network
interface=wlp3s0
interval=1
label-connected=↓ %downspeed% ↑ %upspeed%
label-disconnected=

[module/powermenu]
type=custom/menu
expand-right=true
format-spacing=1
label-close= cancel
label-close-foreground=${base05}
label-open=
label-open-foreground=${base05}
label-separator=|
label-separator-foreground=${base03}
menu-0-0=reboot
menu-0-0-exec=menu-open-1
menu-0-1=power off
menu-0-1-exec=menu-open-2
menu-1-0=cancel
menu-1-0-exec=menu-open-0
menu-1-1=reboot
menu-1-1-exec=sudo reboot
menu-2-0=power off
menu-2-0-exec=sudo poweroff
menu-2-1=cancel
menu-2-1-exec=menu-open-0

[module/pulseaudio]
type=internal/pulseaudio
bar-volume-empty=-
bar-volume-empty-font=2
bar-volume-empty-foreground=${base03}
bar-volume-fill=-
bar-volume-fill-font=2
bar-volume-width=10
bar-volume-foreground-0=${base0B}
bar-volume-foreground-1=${base0B}
bar-volume-foreground-2=${base0B}
bar-volume-foreground-3=${base0A}
bar-volume-foreground-4=${base0A}
bar-volume-foreground-5=${base09}
bar-volume-foreground-6=${base08}
bar-volume-gradient=false
bar-volume-indicator=o
bar-volume-indicator-font=2
format-volume=♫  <label-volume>
label-muted=
label-volume=%percentage%

[module/temperature]
type=internal/temperature
format=<ramp> <label>
format-warn=<ramp> <label-warn>
label=%temperature-c%
label-warn=%temperature-c%
label-warn-foreground=${base08}
ramp-0=
ramp-1=
ramp-2=
thermal-zone=0
warn-temperature=70

[module/wlan]
type=internal/network
format-connected=<ramp-signal> <label-connected>
format-connected-underline=#00ff00
format-disconnected=  OFF
format-disconnected-underline=#ff0000
interface=wlp3s0
interval=3
label-connected=%essid%
label-disconnected-foreground=#555
ramp-signal-0=
ramp-signal-1=
ramp-signal-2=
ramp-signal-3=
ramp-signal-4=

[module/xbacklight]
type=internal/xbacklight
bar-empty=─
bar-empty-font=2
bar-empty-foreground=#555
bar-fill=─
bar-fill-font=2
bar-fill-foreground=#9f78e1
bar-indicator=|
bar-indicator-font=2
bar-indicator-foreground=#fff
bar-width=10
format=<label> <bar>
label=BL

[module/xkeyboard]
type=internal/xkeyboard
format=  <label-indicator> <label-layout>
label-indicator-margin=1
label-indicator-off-capslock=c
label-indicator-off-numlock=n
label-indicator-off-scrolllock=s
label-indicator-on-capslock=C
label-indicator-on-numlock=N
label-indicator-on-scrolllock=S
label-indicator-padding=2

[module/xwindow]
label=%title%
type=internal/xwindow

[settings]
screenchange-reload=true
    '';
    systemd.user.services.polybar = {
      enable = true;
      wantedBy = [ "graphical-session.target" ];
      restartIfChanged = true;
      path = [
        xorg.xrandr
        gawk
        polybar
      ];
      script = ''
        FIRST_INPUT=`xrandr --listactivemonitors | awk '{print $4}' | grep -v -e '^$' | head -n 1 | tail -n 1`
        SECOND_INPUT=`xrandr --listactivemonitors | awk '{print $4}' | grep -v -e '^$' | head -n 2 | tail -n 1`
        install /etc/polybarconfig -m777 /run/user/`id -u`/polybarconfig 
        sed -i "s;%primary_monitor%;$FIRST_INPUT;g" /run/user/`id -u`/polybarconfig
        if [ "$FIRST_INPUT" != "$SECOND_INPUT" ]; then
          echo "Starting second screen"
          sed -i "s;%secondary_monitor%;$SECOND_INPUT;g" /run/user/`id -u`/polybarconfig
          polybar secondary -r -c /run/user/`id -u`/polybarconfig &
        fi
        polybar primary -r -c /run/user/`id -u`/polybarconfig
      '';
      # reload = ''
      #   rm /run/user/`id -u`/polybarconfig
      # '';
    };

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
background="#${base08}"
foreground="#${base06}"
timeout=10

[urgency_low]
background="#${base01}"
foreground="#${base03}"
timeout=5

[urgency_normal]
background="#${base02}"
foreground="#${base05}"
timeout=10
    '';
    systemd.user.services.dunst = {
      wantedBy = [ "graphical-session.target" ];
      enable = true;
      restartIfChanged = true;
      path = [ dunst ];
      script = ''
        dunst -config /etc/dunstconfig
      '';
    };

    services.xserver = {
      enable = true;
      displayManager.defaultSession = "xfce+i3";
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
          enableScreensaver = false;
          thunarPlugins = with pkgs.xfce; [
            thunar-media-tags-plugin
            thunar-archive-plugin
          ];
        };
      };
      windowManager.i3 = {
        enable = true;
        configFile = "/etc/i3config";
      };
    };
    programs.xss-lock = {
      enable = true;
      lockerCommand = "${i3lock-color}/bin/i3lock-color -B 5 --image ${wallpaper} --tiling --ignore-empty-password --show-failed-attempts --clock --pass-media-keys --pass-screen-keys --pass-volume-keys";
      extraOptions = [];
    };
    environment.systemPackages = [
      custom_rofi
      pkgs.xfce.xfce4-xkb-plugin
      lockerSpace
    ];
    services.picom = {
      enable = true;
      vSync = true;
    };
  }
