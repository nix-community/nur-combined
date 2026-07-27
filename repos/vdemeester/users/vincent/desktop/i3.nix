{ config, nixosConfig, lib, pkgs, ... }:

with lib;
let
  # FIXME(change this at some point)
  powermenu = pkgs.writeScript "powermenu.sh" ''
    #!/usr/bin/env bash
    MENU="$(${pkgs.rofi}/bin/rofi -sep "|" -dmenu -i -p 'System' -location 3 -xoffset -10 -yoffset 32 -width 20 -hide-scrollbar -line-padding 4 -padding 20 -lines 5 <<< "Suspend|Hibernate|Reboot|Shutdown")"
    case "$MENU" in
      *Suspend) systemctl suspend;;
      *Hibernate) systemctl hibernate;;
      *Reboot) systemctl reboot ;;
      *Shutdown) systemctl -i poweroff
    esac
  '';
  emacs-in-folder = pkgs.writeScript "emacs-in-folder" ''
    #!/usr/bin/env bash
    fd . -d 3 --type d ~/src | rofi -dmenu | xargs -I {} zsh -i -c "cd {}; emacs ."
  '';
  lockCommand = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
in
{
  imports = [
    ./alacritty.nix
    ./autorandr.nix
    # ./dconf.nix
    ./xsession.nix
  ];
  home.sessionVariables = { WEBKIT_DISABLE_COMPOSITING_MODE = 1; };
  home.packages = with pkgs; [
    alacritty
    kitty
    arandr
    # TODO switch to betterlockscreen
    i3lock-color
    libnotify
    maim
    slop
    # Gnome3 relica
    # gnome3.dconf-editor
    # FIXME move this elsewhere
    pop-gtk-theme
    pop-icon-theme
    pinentry-gnome

    aspell
    aspellDicts.en
    aspellDicts.fr
    hunspell
    hunspellDicts.en_US-large
    hunspellDicts.en_GB-ize
    hunspellDicts.fr-any
    wmctrl
    xclip
    xdg-user-dirs
    xdg-utils
    xsel
  ];
  xdg.configFile."rofi/slate.rasi".text = ''
    * {
      background-color: #282C33;
      border-color: #2e343f;
      text-color: #8ca0aa;
      spacing: 0;
      width: 512px;
    }

    inputbar {
      border: 0 0 1px 0;
      children: [prompt,entry];
    }

    prompt {
      padding: 16px;
      border: 0 1px 0 0;
    }

    textbox {
      background-color: #2e343f;
      border: 0 0 1px 0;
      border-color: #282C33;
      padding: 8px 16px;
    }

    entry {
      padding: 16px;
    }

    listview {
      cycle: false;
      margin: 0 0 -1px 0;
      scrollbar: false;
    }

    element {
      border: 0 0 1px 0;
      padding: 16px;
    }

    element selected {
      background-color: #2e343f;
    }
  '';
  programs.kitty = {
    enable = true;
    settings = {
      term = "xterm-256color";
      close_on_child_death = "yes";
      font_family = "Ubuntu Mono";
    };
    theme = "Tango Light";
  };
  programs.rofi = {
    enable = true;
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji pkgs.rofi-menugen pkgs.rofi-mpd ]; };
    font = "Ubuntu Mono 14";
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = "slate";
  };
  services = {
    blueman-applet.enable = true;
    pasystray.enable = true;
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
    /*
      screern-locker = {
      enable = true;
      lockCmd = lockCommand;
      inactiveInterval = 60;
      xautolock = {
      enable = true;
      detectSleep = true;
      };
      };
    */
    random-background = {
      enable = true;
      enableXinerama = true;
      imageDirectory = "${config.home.homeDirectory}/desktop/pictures/walls";
      interval = "5h";
    };
  };
  xsession.windowManager.i3 = {
    package = pkgs.i3-gaps;
    enable = true;
    config = {
      fonts = {
        names = [ "Ubuntu Mono" ];
        size = 10.0;
      };
      focus = {
        followMouse = false;
      };
      window = {
        titlebar = false;
        border = 1;
        hideEdgeBorders = "both";
      };
      keybindings = {
        "Mod4+Return" = "exec kitty";
        "Mod4+Shift+Return" = "exec emacsclient -c";
        "Mod4+Control+Return" = "exec emacs";
        "Mod4+Control+Shift+Return" = "exec ${emacs-in-folder}";
      };
      gaps = {
        inner = 2;
        outer = 2;
      };
      keycodebindings = {
        "Mod4+Shift+24" = "kill";
        "Mod4+33" = "exec \"rofi -show drun -modi 'drun,run,window,ssh' -kb-row-select 'Tab' -kb-row-tab '' -location 2 -hide-scrollbar -separator-style solid -font 'Ubuntu Mono 14'";
        "Mod4+Shift+33" = "exec \"rofi -show combi -modi 'drun,run,window,ssh,combi' -kb-row-select 'Tab' -kb-row-tab '' -location 2 -hide-scrollbar -separator-style solid -font 'Ubuntu Mono 14'";
        "Mod4+Control+33" = "exec \"rofi -show emoji -modi emoji -location 2 -hide-scrollbar -separator-style solid -font 'Ubuntu Mono 14'|pbcopy";
        # "Mod4+space" = "";
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
        # Fullscreen
        "Mod4+41" = "fullscreen toggle";
        # Change container layout
        "Mod4+39" = "layout stacking";
        "Mod4+25" = "layout tabbed";
        "Mod4+26" = "layout toggle split";
        # Split
        "Mod4+Control+39" = "split h";
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
        # "Mod4+Shift+39" = "exec ~/.screenlayout/home-work.sh && systemctl --user start random-background.service";
        "Mod4+24" = "border toggle";
        # TODO transform this into mode with multiple "capture" target
        "Mod4+32" = "exec capture";
      };
      modes = { };
      bars = [
        {
          mode = "hide";
          position = "bottom";
          trayOutput = "primary";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = {
            names = [ "Fira Code" ];
            size = 12.0;
          };
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

      #assign [class="Firefox" window_role="browser"] → $WS1
      #assign [class="Google-chrome" window_role="browser"] → $WS1

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
      bindsym $mod+F10 exec ${pkgs.my.scripts}/bin/shot %d
      bindsym $mod+Shift+F10 exec ${pkgs.my.scripts}/bin/shotf %d

      # screen management
      bindsym $mod+F11 exec "autorandr -c"
      bindsym $mod+Shift+F11 exec "arandr"

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
      ## quick terminal (tmux)
      exec --no-startup-id kitty --title metask --class metask tmux
      exec --no-startup-id emacsclient -n -c -F "((name . \"_emacs scratchpad_\"))"
      for_window [instance="metask"] floating enable;
      for_window [instance="metask"] move scratchpad; [instance="metask"] scratchpad show; move position center; move scratchpad
      bindcode $mod+49 [instance="metask"] scratchpad show

      bindcode $mod+51 [class="Spotify"] scratchpad show
      bindcode $mod+23 move scratchpad

      exec --no-startup-id emacsclient -n -c -F "((name . \"_emacs scratchpad_\"))"
      for_window [title="_emacs scratchpad_" class="Emacs"] move scratchpad
      bindcode $mod+Shift+49 [title="_emacs scratchpad_" class="Emacs"] scratchpad show

      # System menu
      set $sysmenu "system:  [s]uspend [l]ock [r]estart [b]lank-screen [p]oweroff reload-[c]onf e[x]it"
      bindsym $mod+q mode $sysmenu
      mode $sysmenu {
          # restart i3 inplace (preserves your layout/session)
          bindsym s exec ~/.i3/status_scripts/ambisleep; mode "default"
          bindsym l exec i3lock -c 5a5376; mode "default"
          bindsym r restart
          bindsym b exec "xset dpms force off"; mode "default"
          bindsym p exec systemctl shutdown
          bindsym c reload; mode "default"
          bindsym x exit
          bindsym Return mode "default"
          bindsym Escape mode "default"
          bindsym $mod+q mode "default"
      }
    '';
  };
  # FIXME switch to polybar ?
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

    order += "path_exists 🔑"
    order += "battery 0"
    order += "load"
    order += "tztime local"

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
  '';
}
