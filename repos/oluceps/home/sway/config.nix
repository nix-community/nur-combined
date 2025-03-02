{ pkgs, lib, ... }:
let
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  pw-volume = "${pkgs.pw-volume}/bin/pw-volume";
  genDeps = n: lib.genAttrs n (name: lib.getExe pkgs.${name});
  bg = "${
    pkgs.fetchurl {
      url = "https://s3.nyaw.xyz/misskey//9cf87424-affa-46d6-acec-0cd35ff90663.jpg";
      sha256 = "0vrxr9imkp04skpbk6zmxjkcdlz029c9zc6xvsmab1hh2kzwkm33";
    }
  } fill";

  variables = [
    "DISPLAY"
    "WAYLAND_DISPLAY"
    "SWAYSOCK"
    "XDG_CURRENT_DESKTOP"
    "XDG_SESSION_TYPE"
    "NIXOS_OZONE_WL"
    "XCURSOR_THEME"
    "XCURSOR_SIZE"
    "QT_IM_MODULES"
  ];
  extraCommands = [ "systemctl --user start sway-session.target" ];
  systemd-run-app = lib.getExe (
    pkgs.writeShellApplication {
      name = "systemd-run-app";
      text = ''
        name=$(${pkgs.uutils-coreutils-noprefix}/bin/basename "$1")
        id=$(${pkgs.openssl}/bin/openssl rand -hex 4)
        exec systemd-run \
          --user \
          --scope \
          --unit "$name-$id" \
          --slice=app \
          --same-dir \
          --collect \
          --property PartOf=graphical-session.target \
          --property After=graphical-session.target \
          -- "$@"
      '';
    }
  );
  deps = genDeps [
    "fuzzel"
    "foot"
    "grim"
    "light"
    "playerctl"
    "pulsemixer"
    "slurp"
    "swaybg"
    "hyprpicker"
    "cliphist"
    "firefox"
    "tdesktop"
    "save-clipboard-to"
    "screen-recorder-toggle"
    "systemd-run-app"
  ];
in
''
  font pango:monospace 8.000000
  floating_modifier Mod4
  default_border pixel 2
  default_floating_border pixel 2
  hide_edge_borders smart
  focus_wrapping no
  focus_follows_mouse yes
  focus_on_window_activation smart
  mouse_warping output
  workspace_layout default
  workspace_auto_back_and_forth no
  client.focused #f0c9cf #787878 #ffffff #E1A679 #D7C4BB
  client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
  client.unfocused #597B84 #2b3339 #888888 #E1A679 #597B84
  client.urgent #DB8E71 #e68183 #ffffff #a7c080 #DB8E71
  client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
  client.background a7c080

  bindsym --no-repeat XF86AudioMute exec "${pw-volume} mute toggle; pkill -RTMIN+8 waybar"
  bindsym Alt+Print exec ${deps.grim} - | ${wl-copy} -t image/png
  bindsym Ctrl+Shift+l exec ${lib.getExe pkgs.swaylock}
  bindsym Mod4+0 workspace number 10
  bindsym Mod4+1 workspace number 1
  bindsym Mod4+2 workspace number 2
  bindsym Mod4+3 workspace number 3
  bindsym Mod4+4 workspace number 4
  bindsym Mod4+5 workspace number 5
  bindsym Mod4+6 workspace number 6
  bindsym Mod4+7 workspace number 7
  bindsym Mod4+8 workspace number 8
  bindsym Mod4+9 workspace number 9
  bindsym Mod4+Ctrl+1 move container to workspace number 1
  bindsym Mod4+Ctrl+2 move container to workspace number 2
  bindsym Mod4+Ctrl+3 move container to workspace number 3
  bindsym Mod4+Ctrl+4 move container to workspace number 4
  bindsym Mod4+Ctrl+5 move container to workspace number 5
  bindsym Mod4+Ctrl+6 move container to workspace number 6
  bindsym Mod4+Ctrl+7 move container to workspace number 7
  bindsym Mod4+Ctrl+8 move container to workspace number 8
  bindsym Mod4+Ctrl+9 move container to workspace number 9
  bindsym Mod4+Ctrl+h move left
  bindsym Mod4+Ctrl+i scratchpad show
  bindsym Mod4+Ctrl+j move down
  bindsym Mod4+Ctrl+k move up
  bindsym Mod4+Ctrl+l move right
  bindsym Mod4+Ctrl+p exec ${deps.cliphist} list | ${deps.fuzzel} -d -I -l 7 -x 8 -y 7 -P 9 -b ede3e7d9 -r 3 -t 8b614db3 -C ede3e7d9 -f 'Maple Mono SC NF:style=Regular:size=15' -P 10 -B 7 -w 50 | ${deps.cliphist} decode | ${wl-copy}
  bindsym Mod4+Ctrl+s exec ${pkgs.writeShellScriptBin "save-clipboard-to" ''
    wl-paste > $HOME/Pictures/Screenshots/$(date +'shot_%Y-%m-%d-%H%M%S.png')
  ''}
  bindsym Mod4+Down focus down
  bindsym Mod4+Left focus left
  bindsym Mod4+Return exec ${systemd-run-app} ${deps.foot}
  bindsym Mod4+Right focus right
  bindsym Mod4+Shift+0 move container to workspace number 10

  bindsym Mod4+Shift+Down move down
  bindsym Mod4+Shift+Left move left
  bindsym Mod4+Shift+Right move right
  bindsym Mod4+Shift+Up move up
  bindsym Mod4+Shift+c reload
  bindsym Mod4+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'

  bindsym Mod4+Shift+minus move scratchpad

  bindsym Mod4+Up focus up
  bindsym Mod4+a focus parent
  bindsym Mod4+b splith
  bindsym Mod4+d exec ${deps.fuzzel} -I -l 7 -x 8 -y 7 -P 9 -b ede3e7d9 -r 3 -t 8b614db3 -C ede3e7d9 -f 'Maple Mono SC NF:style=Regular:size=15' -P 10 -B 7
  bindsym Mod4+e layout toggle split
  bindsym Mod4+f fullscreen toggle
  bindsym Mod4+h focus left
  bindsym Mod4+i move scratchpad
  bindsym Mod4+j focus down
  bindsym Mod4+k focus up
  bindsym Mod4+l focus right
  bindsym Mod4+minus scratchpad show
  bindsym Mod4+q kill
  bindsym Mod4+r mode resize
  bindsym Mod4+s layout stacking
  bindsym Mod4+shift+r exec ${pkgs.writeShellScriptBin "screen-recorder-toggle" ''
    pid=`${pkgs.procps}/bin/pgrep wl-screenrec`
    status=$?
    if [ $status != 0 ]
    then
      ${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(${pkgs.slurp}/bin/slurp)" -f $HOME/Videos/record/$(date +'recording_%Y-%m-%d-%H%M%S.mp4');
    else
      ${pkgs.procps}/bin/pkill --signal SIGINT wl-screenrec
    fi;
  ''}
  bindsym Mod4+space floating toggle
  bindsym Mod4+v splitv
  bindsym Mod4+w layout tabbed
  bindsym Print exec ${lib.getExe pkgs.sway-contrib.grimshot} copy area
  bindsym XF86AudioLowerVolume exec "${pw-volume} change -2.5%; pkill -RTMIN+8 waybar"
  bindsym XF86AudioRaiseVolume exec "${pw-volume} change +2.5%; pkill -RTMIN+8 waybar"
  bindsym XF86MonBrightnessUp exec brightnessctl set +3%
  bindsym XF86MonBrightnessdown exec brightnessctl set 3%-

  # need further redesign
  input "1267:12764:ELAN2204:00_04F3:31DC_Touchpad" {
  natural_scroll enabled
  tap enabled
  }

  output "HDMI-A-1" {
  bg ${bg}
  mode 2560x1660
  scale 2
  }

  output "eDP-1" {
  adaptive_sync on
  bg ${bg}
  mode 2160x1440@60Hz
  scale 2
  }

  mode "resize" {
    bindsym Down resize grow height 10 px
    bindsym Escape mode default
    bindsym Left resize shrink width 10 px
    bindsym Return mode default
    bindsym Right resize grow width 10 px
    bindsym Up resize shrink height 10 px
    bindsym h resize shrink width 10 px
    bindsym j resize grow height 10 px
    bindsym k resize shrink height 10 px
    bindsym l resize grow width 10 px
  }

  set $my_cursor graphite-light-nord
  set $my_cursor_size 22

  seat seat0 xcursor_theme $my_cursor $my_cursor_size
  exec_always {
      gsettings set org.gnome.desktop.interface cursor-theme $my_cursor
      gsettings set org.gnome.desktop.interface cursor-size $my_cursor_size
  }

  gaps inner 2
  gaps outer 1
  smart_gaps on
  for_window [app_id="gcr-prompter"] floating enable
  exec fcitx5 -d

  exec ${systemd-run-app} ${lib.getExe pkgs.firefox}

  exec ${systemd-run-app} ${lib.getExe pkgs.tdesktop}

  exec ${wl-paste} --type text --watch ${deps.cliphist} store

  exec ${wl-paste} --type image --watch ${deps.cliphist} store

  exec ${lib.getExe pkgs.waybar}

  exec ${lib.getExe pkgs.mako}

  workspace "1" output "HDMI-A-1"
  exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${lib.concatStringsSep " " variables}; ${lib.concatStringsSep " && " extraCommands}"
  bindgesture swipe:right workspace prev
  bindgesture swipe:left workspace next
  bindsym --whole-window {
      Mod4+button4 workspace prev
      Mod4+button5 workspace next
  }

  for_window [app_id="org.gnome.Nautilus"] floating enable
  for_window [title="^Open File$"] floating enable
  for_window [title="^Media viewer$"] floating enable, resize set 800 600

  # blur enable
  # blur_passes 2
  # corner_radius 2
  # shadows enable
''
