{pkgs, ...}: let
  inherit (pkgs) xorg gawk custom;
  inherit (custom) colorpipe;

  polybar = pkgs.polybar.override {
    alsaSupport = true;
    pulseSupport = true;
    i3Support = true;
  };
in {
  systemd.user.services.polybar = {
    enable = true;
    wantedBy = [ "graphical-session.target" ];
    restartIfChanged = true;
    path = [
      xorg.xrandr
      gawk
      polybar
      colorpipe
    ];
    script = ''
      FIRST_INPUT=`xrandr --listactivemonitors | awk '{print $4}' | grep -v -e '^$' | head -n 1 | tail -n 1`
      SECOND_INPUT=`xrandr --listactivemonitors | awk '{print $4}' | grep -v -e '^$' | head -n 2 | tail -n 1`
      tmpfile=$(mktemp)
      install /etc/polybarconfig -m777 $tmpfile
      sed -i "s;%primary_monitor%;$FIRST_INPUT;g" $tmpfile
      sed -i "s;%secondary_monitor%;$SECOND_INPUT;g" $tmpfile
      cat $tmpfile | colorpipe > /run/user/`id -u`/polybarconfig
      if [ "$FIRST_INPUT" != "$SECOND_INPUT" ]; then
        echo "Starting second screen"
        polybar secondary -r -c /run/user/`id -u`/polybarconfig &
      fi
      polybar primary -r -c /run/user/`id -u`/polybarconfig
    '';
    # reload = ''
    #   rm /run/user/`id -u`/polybarconfig
    # '';
  };

  environment.etc."polybarconfig".text = ''
[colors]
primary=%base05%

[bar/primary]
monitor=%primary_monitor%
background=%base00%
foreground=%base05%
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
background=%base00%
foreground=%base05%
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
bar-volume-empty-foreground=%base03%
bar-volume-fill=─
bar-volume-fill-font=2
bar-volume-foreground-0=%base0B%
bar-volume-foreground-1=%base0B%
bar-volume-foreground-2=%base0B%
bar-volume-foreground-3=%base0A%
bar-volume-foreground-4=%base0A%
bar-volume-foreground-5=%base09%
bar-volume-foreground-6=%base09%
bar-volume-foreground-7=%base08%
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
label-unmounted-foreground=%base05%
mount-0=/
mount-1=/run/media/lucasew/Dados/
type=internal/fs

[module/i3]
type=internal/i3
pin-workspaces=true
wrapping-scroll=false

format=<label-state> <label-mode>
index-sort=true
label-mode-foreground=%base07%
label-mode-background=%base03%
label-mode-padding=2

label-focused=%index%
label-focused-foreground=%base05%
label-focused-background=%base01%
label-focused-underline=%base05%
label-focused-padding=2

label-visible=%index%
label-visible-foreground=%base03%
label-visible-background=%base00%
label-visible-underline=%base03%
label-visible-padding=2

label-unfocused=%index%
label-unfocused-padding=2
label-unfocused-foreground=%base03%
label-unfocused-background=%base00%

label-urgent=%index%
label-urgent-padding=4
label-urgent-foreground=%base07%
label-urgent-background=%base03%

[module/memory]
type=internal/memory
format-prefix-foreground=%base05%
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
label-close-foreground=%base05%
label-open=
label-open-foreground=%base05%
label-separator=|
label-separator-foreground=%base03%
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
bar-volume-empty-foreground=%base03%
bar-volume-fill=-
bar-volume-fill-font=2
bar-volume-width=10
bar-volume-foreground-0=%base0B%
bar-volume-foreground-1=%base0B%
bar-volume-foreground-2=%base0B%
bar-volume-foreground-3=%base0A%
bar-volume-foreground-4=%base0A%
bar-volume-foreground-5=%base09%
bar-volume-foreground-6=%base08%
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
label-warn-foreground=%base08%
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
}
