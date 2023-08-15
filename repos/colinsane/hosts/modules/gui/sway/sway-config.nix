{ pkgs }:
let
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  sed = "${pkgs.gnused}/bin/sed";
  wtype = "${pkgs.wtype}/bin/wtype";
  launcher-cmd = fuzzel;
  terminal-cmd = "${pkgs.xdg-terminal-exec}/bin/xdg-terminal-exec";
  lock-cmd = "${pkgs.swaylock}/bin/swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
  vol-up-cmd = "${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5";
  vol-down-cmd = "${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5";
  mute-cmd = "${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
  brightness-up-cmd = "${pkgs.brightnessctl}/bin/brightnessctl set +2%";
  brightness-down-cmd = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
  screenshot-cmd = "${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
  # "bookmarking"/snippets inspired by Luke Smith:
  # - <https://www.youtube.com/watch?v=d_11QaTlf1I>
  snip-file = ../snippets.txt;
  list-snips = "cat ${snip-file} ~/.config/sane-sway/snippets.txt";
  strip-comments = "${sed} 's/ #.*$//'";
  snip-cmd = "${wtype} $(${list-snips} | ${fuzzel} -d -i -w 60 | ${strip-comments})";
  # TODO: splatmoji release > 1.2.0 should allow `-s none` to disable skin tones
  emoji-cmd = "${pkgs.splatmoji}/bin/splatmoji -s medium-light type";

  # mod = "Mod1";  # Alt
  mod = "Mod4";  # Super
in ''
  ### default font
  font pango:monospace 8

  ### pixel boundary between windows
  default_border pixel 3
  default_floating_border pixel 2
  hide_edge_borders smart

  ### defaults
  focus_wrapping no
  focus_follows_mouse yes
  focus_on_window_activation smart
  mouse_warping output
  workspace_layout default
  workspace_auto_back_and_forth no

  ### default colors (#border #background #text #indicator #childBorder)
  client.focused #4c7899 #285577 #ffffff #2e9ef4 #285577
  client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
  client.unfocused #333333 #222222 #888888 #292d2e #222222
  client.urgent #2f343a #900000 #ffffff #900000 #900000
  client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
  client.background #ffffff

  ### key bindings
  floating_modifier ${mod}
  ## media keys
  bindsym XF86AudioRaiseVolume exec ${vol-up-cmd}
  bindsym XF86AudioLowerVolume exec ${vol-down-cmd}
  bindsym ${mod}+Page_Up exec ${vol-up-cmd}
  bindsym ${mod}+Page_Down exec ${vol-down-cmd}
  bindsym XF86AudioMute exec ${mute-cmd}
  bindsym XF86MonBrightnessUp exec ${brightness-up-cmd}
  bindsym XF86MonBrightnessDown exec ${brightness-down-cmd}
  ## special functions
  bindsym ${mod}+Print exec ${screenshot-cmd}
  bindsym ${mod}+l exec ${lock-cmd}
  bindsym ${mod}+s exec ${snip-cmd}
  bindsym ${mod}+slash exec ${emoji-cmd}
  bindsym ${mod}+d exec ${launcher-cmd}
  bindsym ${mod}+Return exec ${terminal-cmd}
  bindsym ${mod}+Shift+q kill
  bindsym ${mod}+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
  bindsym ${mod}+Shift+c reload
  ## layout
  bindsym ${mod}+b splith
  bindsym ${mod}+v splitv
  bindsym ${mod}+f fullscreen toggle
  bindsym ${mod}+a focus parent
  bindsym ${mod}+w layout tabbed
  bindsym ${mod}+e layout toggle split
  bindsym ${mod}+Shift+space floating toggle
  bindsym ${mod}+space focus mode_toggle
  bindsym ${mod}+r mode resize
  ## movement
  bindsym ${mod}+Up focus up
  bindsym ${mod}+Down focus down
  bindsym ${mod}+Left focus left
  bindsym ${mod}+Right focus right
  bindsym ${mod}+Shift+Up move up
  bindsym ${mod}+Shift+Down move down
  bindsym ${mod}+Shift+Left move left
  bindsym ${mod}+Shift+Right move right
  ## workspaces
  bindsym ${mod}+1 workspace number 1
  bindsym ${mod}+2 workspace number 2
  bindsym ${mod}+3 workspace number 3
  bindsym ${mod}+4 workspace number 4
  bindsym ${mod}+5 workspace number 5
  bindsym ${mod}+6 workspace number 6
  bindsym ${mod}+7 workspace number 7
  bindsym ${mod}+8 workspace number 8
  bindsym ${mod}+9 workspace number 9
  bindsym ${mod}+Shift+1 move container to workspace number 1
  bindsym ${mod}+Shift+2 move container to workspace number 2
  bindsym ${mod}+Shift+3 move container to workspace number 3
  bindsym ${mod}+Shift+4 move container to workspace number 4
  bindsym ${mod}+Shift+5 move container to workspace number 5
  bindsym ${mod}+Shift+6 move container to workspace number 6
  bindsym ${mod}+Shift+7 move container to workspace number 7
  bindsym ${mod}+Shift+8 move container to workspace number 8
  bindsym ${mod}+Shift+9 move container to workspace number 9
  ## "scratchpad" = ??
  bindsym ${mod}+Shift+minus move scratchpad
  bindsym ${mod}+minus scratchpad show

  ### defaults
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

  ### lightly modified bars
  bar {
    mode dock
    hidden_state hide
    position top
    status_command ${pkgs.i3status}/bin/i3status
    swaybar_command ${pkgs.waybar}/bin/waybar
    workspace_buttons yes
    strip_workspace_numbers no
    tray_output primary
    colors {
      background #000000
      statusline #ffffff
      separator #666666
      #  #border #background #text
      focused_workspace #4c7899 #285577 #ffffff
      active_workspace #333333 #5f676a #ffffff
      inactive_workspace #333333 #222222 #888888
      urgent_workspace #2f343a #900000 #ffffff
      binding_mode #2f343a #900000 #ffffff
    }
  }

  ### displays
  ## DESKTOP
  output "Samsung Electric Company S22C300 0x00007F35" {
    pos 0,0
    res 1920x1080
  }
  output "Goldstar Company Ltd LG ULTRAWIDE 0x00004E94" {
    pos 1920,0
    res 3440x1440
  }

  ## LAPTOP
  # sh/en TV
  output "Pioneer Electronic Corporation VSX-524 0x00000101" {
    pos 0,0
    res 1920x1080
  }
  # internal display
  output "Unknown 0x0637 0x00000000" {
    pos 1920,0
    res 1920x1080
  }

  # XXX: needed for xdg-desktop-portal-* to work.
  # this is how we expose these env vars to user dbus services:
  # - DISPLAY
  # - WAYLAND_DISPLAY
  # - SWAYSOCK
  # - XDG_CURRENT_DESKTOP
  # for more, see: <repo:nixos/nixpkgs:nixos/modules/programs/wayland/sway.nix>
  include /etc/sway/config.d/*
''
