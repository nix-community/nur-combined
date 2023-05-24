{ pkgs, config }:
let
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  sed = "${pkgs.gnused}/bin/sed";
  wtype = "${pkgs.wtype}/bin/wtype";
  kitty = "${pkgs.kitty}/bin/kitty";
  launcher-cmd = fuzzel;
  terminal-cmd = kitty;
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
  # TODO: querying sops here breaks encapsulation
  list-snips = "cat ${snip-file} ${config.sops.secrets.snippets.path}";
  strip-comments = "${sed} 's/ #.*$//'";
  snip-cmd = "${wtype} $(${list-snips} | ${fuzzel} -d -i -w 60 | ${strip-comments})";
  # TODO: next splatmoji release should allow `-s none` to disable skin tones
  emoji-cmd = "${pkgs.splatmoji}/bin/splatmoji -s medium-light type";
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
  floating_modifier Mod1
  ## media keys
  bindsym XF86AudioRaiseVolume exec ${vol-up-cmd}
  bindsym XF86AudioLowerVolume exec ${vol-down-cmd}
  bindsym Mod1+Page_Up exec ${vol-up-cmd}
  bindsym Mod1+Page_Down exec ${vol-down-cmd}
  bindsym XF86AudioMute exec ${mute-cmd}
  bindsym XF86MonBrightnessUp exec ${brightness-up-cmd}
  bindsym XF86MonBrightnessDown exec ${brightness-down-cmd}
  ## special functions
  bindsym Mod1+Print exec ${screenshot-cmd}
  bindsym Mod1+l exec ${lock-cmd}
  bindsym Mod1+s exec ${snip-cmd}
  bindsym Mod1+slash exec ${emoji-cmd}
  bindsym Mod1+d exec ${launcher-cmd}
  bindsym Mod1+Return exec ${terminal-cmd}
  bindsym Mod1+Shift+q kill
  bindsym Mod1+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
  bindsym Mod1+Shift+c reload
  ## layout
  bindsym Mod1+b splith
  bindsym Mod1+v splitv
  bindsym Mod1+f fullscreen toggle
  bindsym Mod1+a focus parent
  bindsym Mod1+w layout tabbed
  bindsym Mod1+e layout toggle split
  bindsym Mod1+Shift+space floating toggle
  bindsym Mod1+space focus mode_toggle
  bindsym Mod1+r mode resize
  ## movement
  bindsym Mod1+Up focus up
  bindsym Mod1+Down focus down
  bindsym Mod1+Left focus left
  bindsym Mod1+Right focus right
  bindsym Mod1+Shift+Up move up
  bindsym Mod1+Shift+Down move down
  bindsym Mod1+Shift+Left move left
  bindsym Mod1+Shift+Right move right
  ## workspaces
  bindsym Mod1+1 workspace number 1
  bindsym Mod1+2 workspace number 2
  bindsym Mod1+3 workspace number 3
  bindsym Mod1+4 workspace number 4
  bindsym Mod1+5 workspace number 5
  bindsym Mod1+6 workspace number 6
  bindsym Mod1+7 workspace number 7
  bindsym Mod1+8 workspace number 8
  bindsym Mod1+9 workspace number 9
  bindsym Mod1+Shift+1 move container to workspace number 1
  bindsym Mod1+Shift+2 move container to workspace number 2
  bindsym Mod1+Shift+3 move container to workspace number 3
  bindsym Mod1+Shift+4 move container to workspace number 4
  bindsym Mod1+Shift+5 move container to workspace number 5
  bindsym Mod1+Shift+6 move container to workspace number 6
  bindsym Mod1+Shift+7 move container to workspace number 7
  bindsym Mod1+Shift+8 move container to workspace number 8
  bindsym Mod1+Shift+9 move container to workspace number 9
  ## "scratchpad" = ??
  bindsym Mod1+Shift+minus move scratchpad
  bindsym Mod1+minus scratchpad show

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
    # TODO: fonts was:
    #   config.fonts.fontconfig.defaultFonts; (monospace ++ emoji)
    font pango:Hack, Font Awesome 6 Free, Twitter Color Emoji 24.000000
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
''
