{pkgs, config, ...}:
with pkgs.lib;
let
  colors = {
    background = "#00ffffff";
    background-alt = "#aa111111";
    foreground = "#dfdfdf";
    foreground-alt = "#555";
    primary = "#ffb52a";
    secondary = "#e60053";
    alert = "#bd2c40";
    transparent = "#00000000";
  };
in {
  xsession.windowManager.i3.config.bars = [];
  services.polybar = {
    script = "polybar bar -r &";
    package = pkgs.polybar.override {
      alsaSupport = true;
      pulseSupport = true;
      i3Support = true;
    };
    config = {
      "bar/bar" = {
        "monitor" = "eDP-1";
        "enable-ipc" = true;
        "width" = "100%";
        "height" = 20;
      # ;offset-x = 1%;
      # ;offset-y = 1%;
      "radius" = 0;
      "fixed-center" = true;

      "font-0" = "Noto:pixelsize=10;1";
      "font-1" = "pango:Roboto, Light 7";
      "font-2" = "siji:pixelsize=10;1";

      "background" = colors.background;
      "foreground" = colors.foreground;

      "line-size" = 2;
      "line-color" = "#f00";

      "border-size" = 0;
      "border-color" = colors.transparent;

      "padding-left" = 0;
      "padding-right" = 0;

      "module-margin-left" = 1;
      "module-margin-right" = 1;

      "modules-left" = [
        "i3"
        "xwindow"
      ];
      "modules-center" = [
        "pulseaudio"
        "xkeyboard"
        "memory"
        "cpu"
        "netusage"
        "wlan"
        "eth"
        "temperature"
        "battery"
        "date"
      ];
      "cursor-click" = "pointer";
      "cursor-scroll" = "ns-resize";

      "tray-position" = "right";
      "tray-padding" = 4;
    };
    "module/xwindow" = {
      "type" = "internal/xwindow";
      "label" = "%title%";
    };
    "module/xkeyboard" = {
      "type" = "internal/xkeyboard";
      "format" = " <label-layout> <label-indicator>";
    # ; format-prefix = ""
    "format-prefix-foreground" = colors.foreground-alt;
    "format-prefix-underline" = colors.secondary;
    "label-layout-underline" = colors.secondary;
    "label-indicator-padding" = 2;
    "label-indicator-margin" = 1;
    "label-indicator-background" = colors.secondary;
    "label-indicator-underline" = colors.secondary;
    "label-indicator-on-capslock" = "C";
    "label-indicator-off-capslock" = "c";
    "label-indicator-on-numlock" = "N";
    "label-indicator-off-numlock" = "n";
    "label-indicator-on-scrolllock" = "S";
    "label-indicator-off-scrolllock" = "s";
  };
  "module/filesystem" = {
    "type" = "internal/fs";
    "interval" = 25;
    "mount-0" = "/";
    "mount-1" = "/run/media/lucasew/Dados/";
    "label-mounted" = "%{F#0a81f5}%mountpoint:0:10:---%%{F-}: %percentage_used%%";
    "label-unmounted" = "%mountpoint% OFF";
    "label-unmounted-foreground" = colors.foreground-alt;
  };
  "module/i3" = {
    "type" = "internal/i3";

    "format" = "<label-state> <label-mode>";
    "index-sort" = true;
    "wrapping-scroll" = false;

    # ; Only show workspaces on the same output as the bar
    "pin-workspaces" = true;

    "label-mode-padding" = 2;
    "label-mode-foreground" = "#000";
    "label-mode-background" = colors.primary;

    # ; focused = Active workspace on focused monitor
    "label-focused" = "%index%";
    "label-focused-background" = colors.background-alt;
    "label-focused-underline" = colors.primary;
    "label-focused-padding" = 2;

    # ; unfocused = Inactive workspace on any monitor
    "label-unfocused" = "%index%";
    "label-unfocused-padding" = 2;

    # ; visible = Active workspace on unfocused monitor
    # ; label-visible = %index%
    "label-visible" = "%index%";
    "label-visible-background" = "#44ffffff";
    "label-visible-underline" = colors.primary;
    "label-visible-padding" = 2;

    # ; urgent = Workspace with urgency hint set
    # ; label-urgent = !%index%!
    "label-urgent" = "%index%";
    "label-urgent-background" = "#77ff0000";
    "label-urgent-padding" = 4;

    # ; Separator in between workspaces
    # ; label-separator = |
  };
  "module/xbacklight" = {
    "type" = "internal/xbacklight";

    "format" = "<label> <bar>";
    "label" = "BL";

    "bar-width" = 10;
    "bar-indicator" = "|";
    "bar-indicator-foreground" = "#fff";
    "bar-indicator-font" = 2;
    "bar-fill" = "─";
    "bar-fill-font" = 2;
    "bar-fill-foreground" = "#9f78e1";
    "bar-empty" = "─";
    "bar-empty-font" = 2;
    "bar-empty-foreground" = colors.foreground-alt;
  };
  "module/backlight-acpi" = {
    "inherit" = "module/xbacklight";
    "type" = "internal/backlight";
    "card" = "intel_backlight";
  };
  "module/cpu" = {
    "type" = "internal/cpu";
    "interval" = 2;
    "format-prefix" = " ";
    # ; format-prefix-foreground = ${colors.foreground-alt}
    "format-underline" = "#f90000";
    "label" = "%percentage:2%%";

  };
  "module/memory" = {
    "type" = "internal/memory";
    "interval" = 2;
    # ; format-prefix = " "
    "format-prefix-foreground" = colors.foreground-alt;
    "format-underline" = "#4bffdc";
    "label" = " %percentage_used%%";
  };
  "module/netusage" = {
    "type" = "internal/network";
    "interface" = "wlp3s0";
    "interval" = 1;
    "label-connected" = "↓ %downspeed% ↑ %upspeed%";
    "label-disconnected" = "";
    "format-connected-underline" = "#00ff00";
    "format-disconnected-underline" = "#ff0000";
  };
  "module/wlan" = {
    "type" = "internal/network";
    "interface" = "wlp3s0";
    "interval" = 3;
    "format-connected" = "<ramp-signal> <label-connected>";
    "format-connected-underline" = "#00ff00";
    "label-connected" = "%essid%";

    "format-disconnected-underline" = "#ff0000";
    "format-disconnected" = "  OFF";
    "label-disconnected-foreground" = colors.foreground-alt;
    "ramp-signal-0" = "";
    "ramp-signal-1" = "";
    "ramp-signal-2" = "";
    "ramp-signal-3" = "";
    "ramp-signal-4" = "";
    # ; ramp-signal-foreground = 
  };
  "module/eth" = {
    "type" = "internal/network";
    "interface" = "enp2s0f1";
    "interval" = 3;

    "format-connected-prefix" = "  ON";
    "format-connected-underline" = "#00ff00";

    "format-connected-prefix-foreground" = colors.foreground-alt;
    "label-connected" = "%local_ip%";

    "format-disconnected" = "  OFF";
    # ; format-disconnected = 
    "format-disconnected-underline" = "#ff0000";
  };
  "module/date" = {
    "type" = "internal/date";
    "interval" = 5;

    "date" = "";
    "date-alt" = "%Y-%m-%d";

    "time" = "%H:%M";
    "time-alt" = "%H:%M:%S";

    "format-prefix" = "";
    "format-underline" = "#0a6cf5";

    "label" = "%date% %time%";
  };
  "module/pulseaudio" = {
    "type" = "internal/pulseaudio";

    # ; format-volume = <label-volume> <bar-volume>
    "format-volume" = "♫  <bar-volume>";
    # ; label-volume = som %percentage%%
    "label-volume" = "";

    "label-muted" = "";
    # ; label-muted-foreground = #666

    "bar-volume-width" = 10;
    "bar-volume-foreground-0" = "#55aa55";
    "bar-volume-foreground-1" = "#55aa55";
    "bar-volume-foreground-2" = "#55aa55";
    "bar-volume-foreground-3" = "#55aa55";
    "bar-volume-foreground-4" = "#55aa55";
    "bar-volume-foreground-5" = "#f5a70a";
    "bar-volume-foreground-6" = "#ff5555";
    "bar-volume-gradient" = false;
    "bar-volume-indicator" = "o";
    "bar-volume-indicator-font" = 2;
    "bar-volume-fill" = "-";
    "bar-volume-fill-font" = 2;
    "bar-volume-empty" = "-";
    "bar-volume-empty-font" = 2;
    "bar-volume-empty-foreground" = colors.foreground-alt;
  };
  "module/alsa" = {
    "type" = "internal/alsa";

    "format-volume" = "<label-volume> <bar-volume>";
    "label-volume" = "VOL";
    "label-volume-foreground" = colors.foreground;

    "format-muted-prefix" = "";
    "label-muted" = "sound muted";

    "bar-volume-width" = 10;
    "bar-volume-foreground-0" = "#55aa55";
    "bar-volume-foreground-1" = "#55aa55";
    "bar-volume-foreground-2" = "#55aa55";
    "bar-volume-foreground-3" = "#55aa55";
    "bar-volume-foreground-4" = "#55aa55";
    "bar-volume-foreground-5" = "#f5a70a";
    "bar-volume-foreground-6" = "#ff5555";
    "bar-volume-gradient" = false;
    "bar-volume-indicator" = "|";
    "bar-volume-indicator-font" = 2;
    "bar-volume-fill" = "─";
    "bar-volume-fill-font" = 2;
    "bar-volume-empty" = "─";
    "bar-volume-empty-font" = 2;
    "bar-volume-empty-foreground" = colors.foreground-alt;
  };
  "module/battery" = {
    "type" = "internal/battery";
    "battery" = "BAT1";
    "adapter" = "ACAD";
    "full-at" = 98;

    "format-charging" = "<animation-charging> <label-charging>";
    "format-charging-underline" = "#ffb52a";

    "format-discharging" = "<animation-discharging> <label-discharging>";
    "format-discharging-underline" = "#ffb52a";

    "format-full-prefix" = " ";
    # ; format-full-prefix-foreground = ${colors.foreground-alt}
    "format-full-underline" = "#ffb52a";

    "ramp-capacity-0" = "";
    "ramp-capacity-1" = "";
    "ramp-capacity-2" = "";
    # ; ramp-capacity-foreground = ${colors.foreground-alt}

    "animation-charging-0" = "";
    "animation-charging-1" = "";
    "animation-charging-2" = "";
    # ; animation-charging-foreground = ${colors.foreground-alt}
    "animation-charging-framerate" = 750;

    "animation-discharging-0" = "";
    "animation-discharging-1" = "";
    "animation-discharging-2" = "";
    # ; animation-discharging-foreground = ${colors.foreground-alt}
    "animation-discharging-framerate" = 750;
  };
  "module/temperature" = {
    "type" = "internal/temperature";
    "thermal-zone" = "0";
    "warn-temperature" = "60";

    "format" = "<ramp> <label>";
    "format-underline" = "#f50a4d";
    "format-warn" = "<ramp> <label-warn>";
    "format-warn-underline" = "#50a4d";

    "label" = "%temperature-c%";
    "label-warn" = "%temperature-c%";
    "label-warn-foreground" = colors.secondary;

    "ramp-0" = "";
    "ramp-1" = "";
    "ramp-2" = "";
    # ; ramp-foreground = ${colors.foreground-alt}
  };
  "module/powermenu" = {
    "type" = "custom/menu";

    "expand-right" = true;

    "format-spacing" = 1;

    "label-open" = "";
    "label-open-foreground" = colors.secondary;
    "label-close" = " cancel";
    "label-close-foreground" = colors.secondary;
    "label-separator" = "|";
    "label-separator-foreground" = colors.foreground-alt;

    "menu-0-0" = "reboot";
    "menu-0-0-exec" = "menu-open-1";
    "menu-0-1" = "power off";
    "menu-0-1-exec" = "menu-open-2";

    "menu-1-0" = "cancel";
    "menu-1-0-exec" = "menu-open-0";
    "menu-1-1" = "reboot";
    "menu-1-1-exec" = "sudo reboot";

    "menu-2-0" = "power off";
    "menu-2-0-exec" = "sudo poweroff";
    "menu-2-1" = "cancel";
    "menu-2-1-exec" = "menu-open-0";
  };
  "settings" = {
    "screenchange-reload" = "true";
    # ; compositing-background = xor
    # ; compositing-background = screen
    # ;compositing-foreground = source
    # ; compositing-border = over
    # ; pseudo-transparency = false
  };
  "global/wm" = {
    "margin-top" = 5;
    "margin-bottom" = 5;
  };
};
extraConfig = ''

'';
  };
}
