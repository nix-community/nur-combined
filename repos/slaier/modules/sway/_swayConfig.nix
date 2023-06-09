{ lib, pkgs }:
let
  mod = "Mod4";
  left = "h";
  down = "j";
  up = "k";
  right = "l";

  grimshot = lib.getExe pkgs.sway-contrib.grimshot;
in
''
  # sway config file

  # window border settings
  default_border          none
  default_floating_border none
  smart_gaps on
  gaps inner 8
  gaps outer 2

  ### Key bindings
  #
  # Basics:
  #
    # Start a terminal
    bindsym ${mod}+Return exec --no-startup-id alacritty

    # Kill focused window
    bindsym ${mod}+Shift+q kill

    # Start your launcher
    bindsym ${mod}+d exec --no-startup-id ${lib.getExe pkgs.rofi-wayland} -show drun

    # switching window
    workspace_auto_back_and_forth yes
    bindsym ${mod}+Shift+d exec ${pkgs.swayr}/bin/swayr switch-window
    bindsym ${mod}+Tab     exec ${pkgs.swayr}/bin/swayr switch-to-urgent-or-lru-window

    # Drag floating windows by holding down ${mod} and left mouse button.
    # Resize them with right mouse button + ${mod}.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier ${mod} normal

    # Reload the configuration file
    bindsym ${mod}+Shift+c reload

    # Exit wm
    bindsym ${mod}+Shift+e exec swaymsg exit
  #
  # Moving around:
  #
    # Move your focus around
    bindsym ${mod}+${left} focus left
    bindsym ${mod}+${down} focus down
    bindsym ${mod}+${up} focus up
    bindsym ${mod}+${right} focus right
    # Or use ${mod}+[up|down|left|right]
    bindsym ${mod}+Left focus left
    bindsym ${mod}+Down focus down
    bindsym ${mod}+Up focus up
    bindsym ${mod}+Right focus right

    # Move the focused window with the same, but add Shift
    bindsym ${mod}+Shift+${left} move left
    bindsym ${mod}+Shift+${down} move down
    bindsym ${mod}+Shift+${up} move up
    bindsym ${mod}+Shift+${right} move right
    # Ditto, with arrow keys
    bindsym ${mod}+Shift+Left move left
    bindsym ${mod}+Shift+Down move down
    bindsym ${mod}+Shift+Up move up
    bindsym ${mod}+Shift+Right move right
  #
  # Workspaces:
  #
    # Switch to workspace
    bindsym ${mod}+1 workspace number 1
    bindsym ${mod}+2 workspace number 2
    bindsym ${mod}+3 workspace number 3
    bindsym ${mod}+4 workspace number 4
    bindsym ${mod}+5 workspace number 5
    bindsym ${mod}+6 workspace number 6
    bindsym ${mod}+7 workspace number 7
    bindsym ${mod}+8 workspace number 8
    bindsym ${mod}+9 workspace number 9
    bindsym ${mod}+0 workspace number 10
    # Move focused container to workspace
    bindsym ${mod}+Shift+1 move container to workspace number 1
    bindsym ${mod}+Shift+2 move container to workspace number 2
    bindsym ${mod}+Shift+3 move container to workspace number 3
    bindsym ${mod}+Shift+4 move container to workspace number 4
    bindsym ${mod}+Shift+5 move container to workspace number 5
    bindsym ${mod}+Shift+6 move container to workspace number 6
    bindsym ${mod}+Shift+7 move container to workspace number 7
    bindsym ${mod}+Shift+8 move container to workspace number 8
    bindsym ${mod}+Shift+9 move container to workspace number 9
    bindsym ${mod}+Shift+0 move container to workspace number 10
    # Note: workspaces can have any name you want, not just numbers.
    # We just use 1-10 as the default.
  #
  # Layout stuff:
  #
    # You can "split" the current object of your focus with
    # ${mod}+b or ${mod}+v, for horizontal and vertical splits
    # respectively.
    bindsym ${mod}+b splith
    bindsym ${mod}+v splitv

    # Switch the current container between different layout styles
    bindsym ${mod}+s layout stacking
    bindsym ${mod}+w layout tabbed
    bindsym ${mod}+e layout toggle split

    # Make the current focus fullscreen
    bindsym ${mod}+f fullscreen

    # Toggle the current focus between tiling and floating mode
    bindsym ${mod}+Shift+space floating toggle
    floating_maximum_size 1280 x 720

    # Swap focus between the tiling area and the floating area
    bindsym ${mod}+space focus mode_toggle

    # Move focus to the parent container
    bindsym ${mod}+a focus parent
  #
  # Scratchpad:
  #
    # scratchpad is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym ${mod}+Shift+minus move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym ${mod}+minus scratchpad show
  #
  # Resizing containers:
  #
  mode "resize" {
    # left will shrink the containers width
    # right will grow the containers width
    # up will shrink the containers height
    # down will grow the containers height
    bindsym ${left} resize shrink width 10px
    bindsym ${down} resize grow height 10px
    bindsym ${up} resize shrink height 10px
    bindsym ${right} resize grow width 10px

    # Ditto, with arrow keys
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px

    # Return to default mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
  }
  bindsym ${mod}+r mode "resize"

  #
  # Input/Output:
  #
  input "type:keyboard" {
    repeat_delay 300
    repeat_rate 30
  }
  output * bg ${pkgs.nixos-artwork.wallpapers.dracula}/share/backgrounds/nixos/nix-wallpaper-dracula.png fill

  #
  # Window rules:
  #
  for_window {
    [title=".*"] titlebar hide
    [title="(?:Open|Save) (?:File|Folder|As)"] floating enable
    [class="Safeeyes"] floating enable
    [app_id="pavucontrol"] floating enable
    [app_id="firefox" title="^Page Info — .*"] floating enable
    [app_id="firefox" title="^Picture-in-Picture$"] floating enable
    [app_id="firefox" title=".*Download Panel.*"] focus; floating enable; resize set width 400px height 250px;
    [app_id="org.keepassxc.KeePassXC" title="Generate Password"] floating enable
    [app_id="org.keepassxc.KeePassXC" title="Unlock Database - KeePassXC"] floating enable
  }

  #
  # Screenshots:
  #
  bindsym ${mod}+p       exec ${grimshot} save window
  bindsym ${mod}+Shift+p exec ${grimshot} save area
  bindsym ${mod}+Mod1+p  exec ${grimshot} save output
  bindsym ${mod}+Ctrl+p  exec ${grimshot} save active

  #
  # Startup:
  #
  exec ${lib.getExe pkgs.dex} -a
  exec --no-startup-id ${lib.getExe pkgs.mako} --default-timeout 3000
  exec --no-startup-id ${pkgs.swayr}/bin/swayrd

  #
  # Others:
  #
  include /etc/sway/config.d/*
''
