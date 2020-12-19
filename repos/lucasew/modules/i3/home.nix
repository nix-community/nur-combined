{pkgs, config, ... }:
with pkgs.lib;
let
  mod = "Mod4";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  modn = pkgs.writeShellScript "modn" ''
goto_ws=$(i3-msg i3-msg -t get_workspaces | jq '.[] | select(.focused == true) | "i3-msg workspace number " + .name' | sed s/\"//g)

i3-msg -t get_outputs | jq '.[] | select(.current_workspace != null) |  "i3-msg workspace number " + .current_workspace + ";i3-msg move workspace to output left"' | sed s/\"//g | bash

echo $goto_ws | bash
  '';
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
    services.picom.enable = true;
    xsession.windowManager.i3 = {
      config = {
        terminal = "${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal";
        menu = "my-rofi";
        modifier = mod;
        keybindings = {
          "${mod}+0" = "workspace number 10";
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+Down" = "focus down";
          "${mod}+Left" = "focus left";
          "${mod}+Return" = "exec /nix/store/y25qrmbp9qgq8m1ik7m0ss33c8x0s4nf-xfce4-terminal-0.8.9.2/bin/xfce4-terminal";
          "${mod}+Right" = "focus right";
          "${mod}+Shift+0" = "move container to workspace number 10";
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Right" = "move right";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'xfce4-session-logout'";
          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+Shift+q" = "kill";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+Up" = "focus up";
          "${mod}+a" = "focus parent";
          "${mod}+d" = "exec my-rofi";
          "${mod}+e" = "layout toggle split";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+h" = "split h";
          "${mod}+minus" = "scratchpad show";
          "${mod}+r" = "mode resize";
          "${mod}+s" = "layout stacking";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+v" = "split v";
          "${mod}+w" = "layout tabbed";
          # custom keys
          "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${pactl} set-sink-volume @DEFAULT_SOURCE@ toggle";
          "${mod}+l" = "exec ${pkgs.xautolock}/bin/xautolock -locknow";
          "${mod}+m" = "move workspace to output left";
          "${mod}+n" = "exec ${modn}";
          "XF86AudioNext" = "exec ${playerctl} next";
          "XF86AudioPrev" = "exec ${playerctl} previous";
          "XF86AudioPlay" = "exec ${playerctl} play-pause";
          "XF86AudioPause" = "exec ${playerctl} play-pause";
        };
      };
      extraConfig = ''
          exec --no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet
          exec --no-startup-id ${pkgs.feh}/bin/feh --bg-center ~/.background-image

          new_window 1pixel
      '';
    };
  }
