{ global, config, pkgs, lib, ... }:
let
  inherit (pkgs) i3lock-color writeTextFile writeShellScript pulseaudio playerctl makeDesktopItem custom brightnessctl networkmanagerapplet feh blueberry xorg gawk dunst;
  inherit (global) wallpaper;
  inherit (lib) mkForce;

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

  wallPng = pkgs.lib.jpg2png {
    name = "wallpaper.jpg";
    image = wallpaper;
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
        client.focused #4c7899 #285577 #ffffff #2e9ef4 #285577
        client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
        client.unfocused #333333 #222222 #888888 #292d2e #222222
        client.urgent #2f343a #900000 #ffffff #900000 #900000
        client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
        client.background #ffffff


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
          exec_always ${feh}/bin/feh --bg-fill --no-xinerama --no-fehbg '/home/lucasew/.dotfiles/wall.jpg'

          new_window 1pixel
    '';

    environment.etc."polybarconfig".source = ./polybarconfig;
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

    environment.etc."dunstconfig".source = ./dunstrc;
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
      lockerCommand = "${i3lock-color}/bin/i3lock-color -B 5 --image ${wallPng} --tiling --ignore-empty-password --show-failed-attempts --clock --pass-media-keys --pass-screen-keys --pass-volume-keys";
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
