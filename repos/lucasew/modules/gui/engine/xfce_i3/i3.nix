{pkgs, lib, ...}: 
with pkgs.custom.colors.colors;
let

  inherit (pkgs.custom) rofi;
  inherit (pkgs) writeShellScript makeDesktopItem;
  mod = "Mod4";
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
in {
  environment.systemPackages = with pkgs; [
    xfce.xfce4-xkb-plugin
    lockerSpace
    custom.rofi
  ];
  services.xserver.windowManager.i3 = {
    enable = true;
    configFile = "/etc/i3config";
    extraPackages = with pkgs; [
      playerctl
      custom.rofi
      pulseaudio
      feh
      brightnessctl
    ];
  };
  systemd.user.services.nm-applet = {
    path = with pkgs; [ networkmanagerapplet ];
    script = "nm-applet";
  };
  systemd.user.services.blueberry-tray = {
    path = with pkgs; [ blueberry ];
    script = "blueberry-tray; while true; do sleep 3600; done";
  };
  environment.etc."i3config".text = lib.mkForce ''
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
bindsym $mod+Shift+p exec toggle-monitor
bindsym $mod+Shift+q kill
bindsym $mod+Shift+r restart
bindsym $mod+Up focus up
bindsym $mod+a focus parent
bindsym $mod+d exec rofi-launch
bindsym $mod+Shift+d exec rofi-window
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
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +10%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -10%
bindsym XF86AudioMute exec pactl set-sink-volume @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute exec pactl set-sink-volume @DEFAULT_SOURCE@ toggle
bindsym $mod+l exec ${locker}
bindsym $mod+m move workspace to output left
bindsym $mod+n exec ${modn}
bindsym $mod+b exec ${gotoNewWs}
bindsym $mod+Shift+b exec ${sendToPQP}
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioPause exec playerctl play-pause
bindsym XF86MonBrightnessUp exec brightnessctl s +5%
bindsym XF86MonBrightnessDown exec brightnessctl s 5%-

# exec_always feh --bg-fill --no-xinerama --no-fehbg '/etc/wallpaper'
exec_always feh --bg-fill --no-fehbg '/etc/wallpaper'

exec_always systemctl restart --user polybar.service nm-applet.service blueberry-tray.service

default_border pixel 2
hide_edge_borders smart
  '';
}
