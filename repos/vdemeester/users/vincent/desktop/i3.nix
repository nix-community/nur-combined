{ config, lib, pkgs, ... }:

with lib;
let
  powermenu = pkgs.writeScript "powermenu.sh" ''
    #!${pkgs.stdenv.shell}
    MENU="$(${pkgs.rofi}/bin/rofi -sep "|" -dmenu -i -p 'System' -location 3 -xoffset -10 -yoffset 32 -width 20 -hide-scrollbar -line-padding 4 -padding 20 -lines 5 <<< "Suspend|Hibernate|Reboot|Shutdown")"
    case "$MENU" in
      *Suspend) systemctl suspend;;
      *Hibernate) systemctl hibernate;;
      *Reboot) systemctl reboot ;;
      *Shutdown) systemctl -i poweroff
    esac
  '';
  lockCommand = "${pkgs.i3lock-color}/bin/i3lock-color -c 666666";
in
{
  home.packages = with pkgs; [
    alacritty
    arandr
    i3lock-color
    libnotify
    maim
    slop
  ];
  programs.rofi.enable = true;
  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          geometry = "500x5-10+10";
          follow = "keyboard";
          frame_color = "#cccccc";
          font = "Ubuntu Mono 11";
          indicate_hidden = "yes";
          separator_height = 1;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          sort = "yes";
          markup = "full";
          format = "<b>%s</b>\n%b";
          ignore_newline = "no";
          stack_duplicates = true;
          show_indicators = "yes";
          history_length = 40;
        };
        shortcuts = {
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+percent";
          context = "ctrl+shift+period";
        };
        urgency_low = {
          background = "#000000";
          foreground = "#ffffff";
          timeout = 4;
        };
        urgency_normal = {
          background = "#000000";
          foreground = "#ffffff";
          timeout = 6;
        };
        urgency_critical = {
          background = "#000000";
          foreground = "#cf6a4c";
          timeout = 0;
        };
      };
    };
    udiskie.enable = true;
    network-manager-applet.enable = true;
    screen-locker = {
      enable = true;
      lockCmd = lockCommand;
      inactiveInterval = 60;
    };
    random-background = {
      enable = true;
      imageDirectory = "${config.home.homeDirectory}/desktop/pictures/walls";
      interval = "5h";
    };
  };
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        normal = {
          family = "Ubuntu Mono";
          style = "Regular";
        };
        bold = {
          family = "Ubuntu Mono";
          style = "Bold";
        };
        italic = {
          family = "Ubuntu Mono";
          style = "Italic";
        };
        size = 11;
      };
      colors = {
        primary = {
          background = "0x0A0E14";
          foreground = "0xB3B1AD";
        };
        normal = {
          black = "0x01060E";
          blue = "0x53BDFA";
          cyan = "0x90E1C6";
          green = "0x91B362";
          magenta = "0xFAE994";
          red = "0xEA6C73";
          white = "0xC7C7C7";
          yellow = "0xF9AF4F";
        };
        bright = {
          black = "0x686868";
          blue = "0x59C2FF";
          cyan = "0x95E6CB";
          green = "0xC2D94C";
          magenta = "0xFFEE99";
          red = "0xF07178";
          white = "0xFFFFFF";
          yellow = "0xFFB454";
        };
      };
      mouse.url.modifiers = "Control";
      shell.program = "${pkgs.zsh}/bin/zsh";
      key_bindings = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "Insert";
          mods = "Shift";
          action = "PasteSelection";
        }
        {
          key = "Key0";
          mods = "Control";
          action = "ResetFontSize";
        }
        {
          key = "Equals";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "Add";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "Subtract";
          mods = "Control";
          action = "DecreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Control";
          action = "DecreaseFontSize";
        }
        {
          key = "Return";
          mods = "Alt";
          action = "ToggleFullscreen";
        }
      ];
    };
  };
  xsession.windowManager.i3 = {
    package = pkgs.i3-gaps;
    enable = true;
    config = {
      fonts = [ "Fira Code 10" ];
      focus = {
        followMouse = false;
      };
      window = {
        titlebar = false;
        border = 1;
        hideEdgeBorders = "both";
      };
      keybindings = {
        "Mod4+Return" = "exec alacritty";
      };
      gaps = {
        inner = 0;
        outer = 0;
      };
      keycodebindings = {
        "Mod4+Shift+24" = "kill";
        "Mod4+33" = "exec \"${pkgs.rofi}/bin/rofi -show run -modi 'run,window' -kb-row-select 'Tab' -kb-row-tab '' -location 2 -hide-scrollbar -separator-style solid -font 'Ubuntu Mono 14'";
        # focus window
        "Mod4+44" = "focus left";
        "Mod4+45" = "focus down";
        "Mod4+46" = "focus up";
        "Mod4+47" = "focus right";
        "Mod4+38" = "focus parent";
        # move focused window
        "Mod4+Shift+44" = "move left";
        "Mod4+Shift+45" = "move down";
        "Mod4+Shift+46" = "move up";
        "Mod4+Shift+47" = "move right";
        # resize
        "Mod4+Control+44" = "resize shrink width 5px or 5ppt";
        "Mod4+Control+45" = "resize grow width 5px or 5ppt";
        "Mod4+Control+46" = "resize shrink height 5px or 5ppt";
        "Mod4+Control+47" = "resize grow height 5px or 5ppt";
        # gaps
        "Mod4+Mod1+44" = "gaps inner current plus 5";
        "Mod4+Mod1+45" = "gaps inner current minus 5";
        "Mod4+Mod1+46" = "gaps outer current plus 5";
        "Mod4+Mod1+47" = "gaps outer current minus 5";
        # Split
        "Mod4+43" = "split h";
        "Mod4+55" = "split v";
        # Fullscreen
        "Mod4+41" = "fullscreen toggle";
        # Change container layout
        "Mod4+39" = "layout stacking";
        "Mod4+25" = "layout tabbed";
        "Mod4+26" = "layout toggle split";
        # Manage floating
        "Mod4+Shift+61" = "floating toggle";
        "Mod4+61" = "focus mode_toggle";
        # manage workspace
        "Mod4+113" = "workspace prev_on_output";
        "Mod4+112" = "workspace prev_on_output";
        "Mod4+114" = "workspace next_on_output";
        "Mod4+117" = "workspace next_on_output";
        # manage output
        "Mod4+Shift+113" = "focus output left";
        "Mod4+Shift+116" = "focus output down";
        "Mod4+Shift+111" = "focus output up";
        "Mod4+Shift+114" = "focus output right";
        # Custom keybinding
        "Mod4+Shift+32" = "exec ${lockCommand}";
        "Mod4+Shift+39" = "exec ~/.screenlayout/home-work.sh && systemctl --user start random-background.service";
        "Mod4+24" = "border toggle";
      };
      modes = { };
      bars = [
        {
          mode = "hide";
          position = "bottom";
          trayOutput = "primary";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = [ "Fira Code 12" ];
        }
      ];
    };
    extraConfig = ''
        set $mod Mod4

      # Use Mouse+$mod to drag floating windows to their wanted position
      floating_modifier $mod

      set $WS0 0
      set $WS1 1
      set $WS2 2
      set $WS3 3
      set $WS4 4
      set $WS5 5
      set $WS6 6
      set $WS7 7
      set $WS8 8
      set $WS9 9

      # switch to workspace
      bindcode $mod+10 workspace $WS1
      bindcode $mod+11 workspace $WS2
      bindcode $mod+12 workspace $WS3
      bindcode $mod+13 workspace $WS4
      bindcode $mod+14 workspace $WS5
      bindcode $mod+15 workspace $WS6
      bindcode $mod+16 workspace $WS7
      bindcode $mod+17 workspace $WS8
      bindcode $mod+18 workspace $WS9
      bindcode $mod+19 workspace $WS0

      # move focused container to workspace
      bindcode $mod+Shift+10 move container to workspace $WS1
      bindcode $mod+Shift+11 move container to workspace $WS2
      bindcode $mod+Shift+12 move container to workspace $WS3
      bindcode $mod+Shift+13 move container to workspace $WS4
      bindcode $mod+Shift+14 move container to workspace $WS5
      bindcode $mod+Shift+15 move container to workspace $WS6
      bindcode $mod+Shift+16 move container to workspace $WS7
      bindcode $mod+Shift+17 move container to workspace $WS8
      bindcode $mod+Shift+18 move container to workspace $WS9
      bindcode $mod+Shift+19 move container to workspace $WS0

      assign [class="Firefox" window_role="browser"] → $WS1
      assign [class="Google-chrome" window_role="browser"] → $WS1

      ## quick terminal (tmux)
      exec --no-startup-id alacritty --title metask --class metask --command tmux
      for_window [instance="metask"] floating enable;
      for_window [instance="metask"] move scratchpad; [instance="metask"] scratchpad show; move position center; move scratchpad
      bindcode $mod+49 [instance="metask"] scratchpad show

      for_window [title="capture"] floating enable;

      bindsym XF86MonBrightnessUp exec "xbacklight -inc 10"
      bindsym XF86MonBrightnessDown exec "xbacklight -dec 10"
      bindsym shift+XF86MonBrightnessUp exec "xbacklight -inc 1"
      bindsym shift+XF86MonBrightnessDown exec "xbacklight -dec 1"
      bindsym XF86AudioLowerVolume exec "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ -5%"
      bindsym XF86AudioRaiseVolume exec "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ +5%"
      bindsym XF86AudioMute exec "pactl set-sink-mute @DEFAULT_SINK@ toggle"
      bindsym XF86AudioMicMute exec "pactl set-source-mute @DEFAULT_SOURCE@ toggle"
      bindsym XF86AudioPlay exec "playerctl play-pause"
      bindsym XF86AudioNext exec "playerctl next"
      bindsym XF86AudioPrev exec "playerctl previous"

      # reload the configuration file
      bindsym $mod+Shift+x reload
      # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
      bindsym $mod+Shift+o restart
      # exit i3 (logs you out of your X session)
      bindsym $mod+Shift+p exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3?' -b 'Yes, exit i3' 'i3-msg exit'"
      # powermenu
      bindsym $mod+F12 exec ${powermenu}

      # screen management
      bindsym $mod+F11 exec "autorandr -c on-the-move"
      bindsym $mod+Shift+F11 exec "arandr"
      bindsym $mod+Control+F11 exec "autorandr -c home1"

      # move workspace to output
      set $workspace_move Move workspace to output : [l]eft [r]ight [d]own [u]p

      mode "$workspace_move" {
      bindsym left move workspace to output left
        bindsym l move workspace to output left

      bindsym right move workspace to output right
        bindsym r move workspace to output right

      bindsym down move workspace to output down
        bindsym d move workspace to output down

      bindsym up move workspace to output up
        bindsym u move workspace to output up

      bindsym Escape mode "default"
      bindsym Return mode "default"
        }

        bindsym $mod+m mode "$workspace_move"

      # resize window (you can also use the mouse for that)
      mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

      # Pressing left will shrink the window’s width.
      # Pressing right will grow the window’s width.
      # Pressing up will shrink the window’s height.
      # Pressing down will grow the window’s height.
      bindsym t resize shrink width 10 px or 10 ppt
      bindsym s resize grow height 10 px or 10 ppt
      bindsym r resize shrink height 10 px or 10 ppt
      bindsym n resize grow width 10 px or 10 ppt

      # same bindings, but for the arrow keys
      bindsym Left resize shrink width 10 px or 10 ppt
      bindsym Down resize grow height 10 px or 10 ppt
      bindsym Up resize shrink height 10 px or 10 ppt
      bindsym Right resize grow width 10 px or 10 ppt

      # back to normal: Enter or Escape
      bindsym Return mode "default"
      bindsym Escape mode "default"
        }

      bindsym $mod+o mode "resize"
    '';
  };
  xdg.configFile."i3status/config".text = ''
    # i3status configuration file.
    # see "man i3status" for documentation.

    # It is important that this file is edited as UTF-8.
    # The following line should contain a sharp s:
    # ß
    # If the above line is not correctly displayed, fix your editor first!

    general {
      colors = true
      interval = 2
    }

    #order += "disk /"
    #order += "run_watch 🐳"
    order += "path_exists 🔑"
    #order += "wireless _first_"
    #order += "ethernet _first_"
    #order += "volume master"
    order += "battery 0"
    order += "load"
    order += "tztime local"

    wireless _first_ {
      format_up = "W: (%quality at %essid) %ip"
      format_down = "W: down"
    }

    ethernet _first_ {
      # if you use %speed, i3status requires root privileges
      format_up = "E: %ip (%speed)"
      format_down = "E: down"
    }

    battery 0 {
      format = "%status %percentage %remaining"
      format_down = "No battery"
      status_chr = "⚇"
      status_bat = "⚡"
      status_full = "☻"
      status_unk = "?"
      path = "/sys/class/power_supply/BAT%d/uevent"
      low_threshold = 10
    }

    run_watch 🐳 {
      pidfile = "/run/docker.pid"
    }

    path_exists 🔑 {
      path = "/proc/sys/net/ipv4/conf/wg0"
    }

    tztime local {
      format = "%Y-%m-%d %H:%M:%S"
    }

    load {
      format = "%1min"
    }

    cpu_temperature 0 {
      format = "T: %degrees °C"
      path = "/sys/class/hwmon/hwmon0/temp1_input"
    }

    disk "/" {
      format = "%avail"
    }

    volume master {
      format = "♪: %volume"
      format_muted = "♪: muted (%volume)"
      device = "default"
      mixer = "Master"
      mixer_idx = 0
    }
  '';
}
