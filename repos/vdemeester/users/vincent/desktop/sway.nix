{ config, nixosConfig, lib, pkgs, ... }:

let
  emacs-in-folder = pkgs.writeScript "emacs-in-folder" ''
    #!/usr/bin/env bash
    fd . -d 3 --type d ~/src | ${pkgs.wofi}/bin/wofi -dmenu | xargs -I {} zsh -i -c "cd {}; emacs ."
  '';
  fontConf = {
    names = [ "JetBrains Mono" ];
    size = 12.0;
  };
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemd.enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARTENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
    checkConfig = false;
    config = {
      gaps = {
        inner = 2;
        outer = 2;
      };
      colors = {
	  focused = {
	    border = "#BD93F9";
	    background = "#282A36";
	    text = "#ffffff";
	    indicator = "#8BE9FD";
	    childBorder = "#BD93F9";
	  };
	  focusedInactive = {
	    border = "#BD93F9";
	    background = "#282A36";
	    text = "#F8F8F2";
	    indicator = "#44475A";
	    childBorder = "#44475A";
	  };
	  unfocused = {
	    border = "#44475A";
	    background = "#282A36";
	    text = "#BFBFBF";
	    indicator = "#282A36";
	    childBorder = "#282A36";
	  };
      };
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${pkgs.wofi}/bin/wofi -G --show drun -modi 'drun,run,window,ssh'";
      bindkeysToCode = true;
      input = {
        "type:keyboard" = {
          xkb_layout = "fr";
          xkb_variant = "bepo";
          xkb_options = "grp:menu_toggle,grp_led:caps,compose:caps";
        };
      };
      output = {
        "*" = {
          bg = "~/desktop/pictures/lockscreen fill";
        };
      };
      fonts = fontConf;
      bars = [];
      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
          inherit (config.wayland.windowManager.sway.config) left down up right menu terminal;
        in
        {
          "${mod}+Return" = "exec ${terminal}";

          "${mod}+Shift+Return" = "exec emacsclient -c";
          "${mod}+Control+Return" = "exec emacs";
          "${mod}+Control+Shift+Return" = "exec ${emacs-in-folder}";

          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          "${mod}+Control+Left" = "workspace prev_on_output";
          "${mod}+Control+Down" = "workspace prev";
          "${mod}+Control+Up" = "workspace next";
          "${mod}+Control+Right" = "workspace next_on_output";

          "${mod}+Shift+Control+Left" = "move workspace to output left";
          "${mod}+Shift+Control+Down" = "move workspace to output down";
          "${mod}+Shift+Control+Up" = "move workspace to output up";
          "${mod}+Shift+Control+Right" = "move workspace to output right";

          "${mod}+Shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";

          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
          "Shift+XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 1%+";
          "Shift+XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 1%-";
        };
      window.commands = [
        {
          command = "inhibit_idle fullscreen";
          criteria.app_id = "firefox";
        }
        {
          command = "inhibit_idle fullscreen";
          criteria.app_id = "mpv";
        }
        {
          # spotify doesn't set its WM_CLASS until it has mapped, so the assign is not reliable
          command = "move to workspace 10";
          criteria.class = "Spotify";
        }
        {
          command = "move to scratchpad, scratchpad show";
          criteria = {
            app_id = "metask";
          };
        }
        {
          command = "move to scratchpad, scratchpad show";
          criteria = {
            app_id = "emacs";
            title = "^_emacs scratchpad_$";
          };
        }
        {
          criteria = { title = "Save File"; };
          command = "floating enable, resize set width 600px height 800px";
        }
        {
          criteria = { class = "pavucontrol"; };
          command = "floating enable";
        }
        {
          criteria = { title = "(Sharing Indicator)"; };
          command = "inhibit_idle visible, floating enable";
        }
        {
          # browser zoom|meet|bluejeans
          criteria = { title = "(Blue Jeans)|(Meet)|(Zoom Meeting)"; };
          command = "inhibit_idle visible";
        }
        # for_window [app_id="^chrome-.*"] shortcuts_inhibitor disable
        {
          criteria = { app_id = "^chrome-.*"; };
          command = "shortcuts_inhibitor disable";
        }
      ];
      startup = [
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG _CURRENT_DESKTOP"; } #workaround
        # { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        { command = "systemctl --user restart kanshi"; always = true; }
	{ command = "${pkgs.pa-notify}/bin/pa-notify"; always = true;}
      ];
    };
    extraConfig =
      let
        mod = config.wayland.windowManager.sway.config.modifier;
        inherit (config.wayland.windowManager.sway.config) left down up right menu terminal;
      in
      ''
        bindcode ${mod}+33 exec "${menu}"
        bindcode ${mod}+Control+33 exec "${pkgs.wofi-emoji}/bin/wofi-emoji -G"
        bindcode ${mod}+Shift+24 kill
        bindcode ${mod}+38 focus parent
        bindcode ${mod}+39 layout stacking
        bindcode ${mod}+25 layout tabbed
        bindcode ${mod}+26 layout toggle split
        bindcode ${mod}+Shift+54 reload
        bindcode ${mod}+Shift+26 exec "swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'"
        bindcode ${mod}+32 mode resize
        bindcode ${mod}+Shift+32 exec "${pkgs.swaylock}/bin/swaylock -i $HOME/desktop/pictures/lockscreen"

	bindcode ${mod}+24 exec notify-send --icon=battery --category=info --urgency=critical "$(acpi)"
        # bindcode ${mod}+58 exec
	bindcode ${mod}+28 exec notify-send --icon=clock --category=info --urgency=critical "$(date +"%I:%M")"
	bindcode ${mod}+Shift+28 exec notify-send --icon=clock --category=info --urgency=critical "$(date)" 

        # switch to workspace
        bindcode ${mod}+10 workspace number 1
        bindcode ${mod}+11 workspace number 2
        bindcode ${mod}+12 workspace number 3
        bindcode ${mod}+13 workspace number 4
        bindcode ${mod}+14 workspace number 5
        bindcode ${mod}+15 workspace number 6
        bindcode ${mod}+16 workspace number 7
        bindcode ${mod}+17 workspace number 8
        bindcode ${mod}+18 workspace number 9
        bindcode ${mod}+19 workspace number 10

        # move focused container to workspace
        bindcode ${mod}+Shift+10 move container to workspace number 1
        bindcode ${mod}+Shift+11 move container to workspace number 2
        bindcode ${mod}+Shift+12 move container to workspace number 3
        bindcode ${mod}+Shift+13 move container to workspace number 4
        bindcode ${mod}+Shift+14 move container to workspace number 5
        bindcode ${mod}+Shift+15 move container to workspace number 6
        bindcode ${mod}+Shift+16 move container to workspace number 7
        bindcode ${mod}+Shift+17 move container to workspace number 8
        bindcode ${mod}+Shift+18 move container to workspace number 9
        bindcode ${mod}+Shift+19 move container to workspace number 10

        bindcode ${mod}+Control+39 split h
        bindcode ${mod}+41 fullscreen toggle

        bindsym XF86AudioRaiseVolume exec ${pkgs.pamixer}/bin/pamixer -ui 5 && ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
        bindsym XF86AudioLowerVolume exec ${pkgs.pamixer}/bin/pamixer -ud 5 && ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
        bindsym XF86AudioMute exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ( ${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob

        bindsym XF86AudioPlay exec "playerctl play-pause"
        bindsym XF86Messenger exec "playerctl play-pause"
        bindsym XF86AudioNext exec "playerctl next"
        bindsym XF86Go exec "playerctl next"
        bindsym XF86AudioPrev exec "playerctl previous"
        bindsym Cancel exec "playerctl previous"

        bindcode ${mod}+49 exec swaymsg [app_id="metask"] scratchpad show || exec ${pkgs.kitty}/bin/kitty --title metask --class metask
        bindsym --whole-window button8 exec sswaymsg [app_id="metask"] scratchpad show || exec ${pkgs.kitty}/bin/kitty --title metask --class metask
        bindcode ${mod}+Shift+49 exec swaymsg '[app_id="emacs" title="^_emacs scratchpad_$"]' scratchpad show || exec ${config.programs.emacs.package}/bin/emacsclient -c -F "((name . \"_emacs scratchpad_\"))"
        bindsym --whole-window button9 exec swaymsg '[app_id="emacs" title="^_emacs scratchpad_$"]' scratchpad show || exec ${config.programs.emacs.package}/bin/emacsclient -c -F "((name . \"_emacs scratchpad_\"))"

        # Mouse
        # Disabled as it doesn't play well with thinkpad's trackpoint :D
        # bindsym --whole-window button6 workspace next_on_output
        # bindsym --whole-window button7 workspace prev_on_output

        bindsym ${mod}+F10 exec ${pkgs.my.scripts}/bin/shot %d
        bindsym ${mod}+Shift+F10 exec ${pkgs.my.scripts}/bin/shotf %d

        bindsym ${mod}+F9 exec ${pkgs.mako}/bin/makoctl mode -s do-not-disturb
        bindsym ${mod}+Shift+F9 exec ${pkgs.mako}/bin/makoctl mode -s default
      '';
  };
  home.packages = with pkgs; [
    swaybg
  ];

}

