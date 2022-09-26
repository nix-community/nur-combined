{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOptionDefault
    ;

  isEnabled = config.my.home.x.enable;

  myTerminal =
    # FIXME: fix when terminal is setup in home
    # if config.my.home.terminal.program != null
    if true
    then "alacritty"
    else "i3-sensible-terminal";

  alt = "Mod1"; # `Alt` key
  modifier = "Mod4"; # `Super` key

  logoutMode = "[L]ogout, [S]uspend, [P]oweroff, [R]eboot";

  i3Theme = config.my.theme.i3Theme;
in {
  config = mkIf isEnabled {
    my.home = {
      flameshot.enable = true;
    };

    home.packages = [pkgs.betterlockscreen pkgs.playerctl];

    xsession.windowManager.i3 = {
      enable = true;

      config = {
        inherit modifier;

        bars = let
          barConfigPath =
            config.xdg.configFile."i3status-rust/config-top.toml".target;
        in [
          {
            statusCommand = "i3status-rs ${barConfigPath}";
            position = "top";
            fonts = {
              names = ["DejaVuSansMono" "FontAwesome6Free"];
              size = 9.0;
            };

            colors = i3Theme.bar;

            trayOutput = "primary";

            # disable mouse scroll wheel in bar
            extraConfig = ''
              bindsym button4 nop
              bindsym button5 nop
            '';
          }
        ];

        colors = {
          inherit
            (i3Theme)
            focused
            focusedInactive
            unfocused
            urgent
            ;
        };

        focus = {
          followMouse = true;
          mouseWarping = true;
        };

        workspaceAutoBackAndForth = true;

        fonts = {
          names = ["DejaVu Sans Mono"];
          size = 8.0;
        };

        keybindings = mkOptionDefault {
          "${modifier}+Shift+e" = ''mode "${logoutMode}"'';
          "${modifier}+i" = "exec emacsclient --create-frame";
          "${modifier}+o" = "exec emacsclient --create-frame --eval '(load \"${config.xdg.configHome}/doom/launch-agenda.el\")'";

          # Volume handling
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

          # I need play-pause everywhere because somehow, keycode 172 seems to
          # be interpreted as pause everytime when sent by my keyboard. Ugh,
          # computers.
          "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioPause" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
          "XF86AudioNext" = "exec --no-startup-id playerctl next";

          "XF86MonBrightnessDown" = "exec --no-startup-id light -U 5";
          "XF86MonBrightnessUp" = "exec --no-startup-id light -A 5";
          "${modifier}+XF86MonBrightnessDown" = "exec --no-startup-id light -U 0.1";
          "${modifier}+XF86MonBrightnessUp" = "exec --no-startup-id light -A 0.1";

          "${modifier}+l" = "exec --no-startup-id betterlockscreen --lock";
          "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
        };

        modes = let
          makeModeBindings = attrs:
            attrs
            // {
              "Escape" = "mode default";
              "Return" = "mode default";
            };
        in
          mkOptionDefault {
            "${logoutMode}" = makeModeBindings {
              "l" = "exec --no-startup-id i3-msg exit, mode default";
              "s" = "exec --no-startup-id betterlockscreen --suspend, mode default";
              "p" = "exec --no-startup-id systemctl poweroff, mode default";
              "r" = "exec --no-startup-id systemctl reboot, mode default";
            };
          };

        terminal = myTerminal;

        assigns = {
          "10" = [
            {class = "Slack";}
            {class = "discord";}
          ];
        };

        window.commands = [
          {
            command = "border pixel 2";
            criteria = {class = "Alacritty";};
          }

          # NOTE: should be done with an assign command, but Spotify doesn't set
          # its class until after initialization, so has to be done this way.
          #
          # See https://i3wm.org/docs/userguide.html#assign_workspace
          {
            criteria = {class = "Spotify";};
            command = "move --no-auto-back-and-forth to workspace 8";
          }
        ];
      };
    };
  };
}
