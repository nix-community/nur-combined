{
  lib,
  hostConfig,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;

  mod = "SUPER";
  mod1 = "ALT";

  # hl.bind(keys, dispatcher, flags)
  bind = keys: dispatcher: flags: {
    _args = [
      keys
      (mkLuaInline dispatcher)
      flags
    ];
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    xwayland.enable = true;

    settings = {
      ### PROGRAMS (Lua locals) ###

      terminal._var = "kitty";
      browser._var = "brave";
      explorer._var = "pcmanfm";
      codeEditor._var = "cursor";
      screenshot._var = "grim - | wl-copy";
      screenshotSelective._var = "grim -g \"$(slurp)\" - | wl-copy";
      colorPicker._var = "hyprpicker -a";

      ### AUTOSTART ###

      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("hyprpaper")
              hl.exec_cmd("systemctl --user start hyprpolkitagent")
            end'')
        ];
      };

      ### ENVIRONMENT VARIABLES ###

      env = [
        {
          _args = [
            "HYPRCURSOR_SIZE"
            "24"
          ];
        }
        {
          _args = [
            "XCURSOR_SIZE"
            "24"
          ];
        }
      ]
      ++ lib.optional (hostConfig.device.hostname == "goliath") {
        _args = [
          "AQ_DRM_DEVICES"
          "/dev/dri/dgpu1"
        ];
      }
      ++ lib.optional (hostConfig.device.hostname == "archimedes") {
        _args = [
          "GDK_SCALE"
          "2"
        ];
      };

      ### SECTIONS (hl.config) ###

      config = {
        debug = {
          vfr = true;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        general = {
          gaps_in = 1;
          gaps_out = 2;

          border_size = 2;

          col = {
            active_border = lib.mkForce {
              colors = [
                "rgba(33ccffee)"
                "rgba(00ff99ee)"
              ];
              angle = 60;
            };
            inactive_border = lib.mkForce "rgba(595959aa)";
          };

          resize_on_border = false;
          allow_tearing = false;

          layout = "dwindle";
        };

        decoration = {
          rounding = 10;

          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = false;
            range = 4;
            render_power = 3;
            color = mkLuaInline "0xee1a1a1a";
          };

          blur = {
            enabled = false;
            size = 3;
            passes = 1;

            vibrancy = 0.1696;
          };
        };

        animations = {
          enabled = true;
        };

        dwindle = {
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          middle_click_paste = false;
        };

        input = {
          kb_layout = "latam";

          follow_mouse = 1;

          sensitivity = 0.8; # -1.0 - 1.0, 0 means no modification.

          touchpad = {
            natural_scroll = true;
          };
        };
      };

      ### ANIMATIONS ###

      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [
                  0.23
                  1
                ]
                [
                  0.32
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0.05
                ]
                [
                  0.36
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [
                  0
                  0
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  0.5
                ]
                [
                  0.75
                  1.0
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [
                  0.15
                  0
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          bezier = "easeOutQuint";
          style = "popin 87%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
      ];

      ### INPUT (gestures & per-device) ###

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
        {
          name = "tpps/2-elan-trackpoint";
          sensitivity = 0.5;
        }
      ];

      ### KEYBINDINGS ###

      bind = [
        (bind "${mod} + return" "hl.dsp.exec_cmd(terminal)" { description = "open terminal"; })
        (bind "${mod} + W" "hl.dsp.exec_cmd(browser)" { description = "open browser"; })
        (bind "${mod} + E" "hl.dsp.exec_cmd(explorer)" { description = "open file explorer"; })
        (bind "${mod} + C" "hl.dsp.exec_cmd(codeEditor)" { description = "open code editor"; })
        (bind "${mod} + SHIFT + C" "hl.dsp.exec_cmd(colorPicker)" { description = "open color picker"; })
        (bind "Print" "hl.dsp.exec_cmd(screenshot)" { description = "screenshot"; })
        (bind "XF86SelectiveScreenshot" "hl.dsp.exec_cmd(screenshotSelective)" {
          description = "selective screenshot";
        })
        (bind "${mod} + I" ''hl.dsp.exec_cmd("hyprsysteminfo")'' { description = "show system info"; })

        (bind "${mod} + R" ''hl.dsp.exec_cmd("rofi -show drun")'' { description = "open app menu"; })
        (bind "${mod1} + space" ''hl.dsp.exec_cmd("rofi -show drun")'' { description = "open app menu"; })
        (bind "${mod1} + SHIFT + space" ''hl.dsp.exec_cmd("rofi -show")'' {
          description = "open full menu";
        })

        (bind "${mod} + B" ''hl.dsp.exec_cmd("uwsm app -- rofi-bluetooth")'' {
          description = "open bluetooth menu";
        })
        (bind "${mod} + N" ''hl.dsp.exec_cmd("uwsm app -- networkmanager_dmenu")'' {
          description = "open networkmanager menu";
        })
        (bind "${mod} + A" ''hl.dsp.exec_cmd("uwsm app -- dmenu-wpctl")'' {
          description = "open audio menu";
        })
        (bind "${mod} + SHIFT + D" ''hl.dsp.exec_cmd("date.sh")'' { description = "show system date"; })
        (bind "${mod} + SHIFT + B" ''hl.dsp.exec_cmd("battery.sh")'' {
          description = "show battery status";
        })
        (bind "${mod} + SHIFT + I" ''hl.dsp.exec_cmd("cpu-mem.sh")'' {
          description = "show resources consumption";
        })

        (bind "${mod} + SHIFT + W" "hl.dsp.window.close()" { description = "close active window"; })
        (bind "${mod} + M" "hl.dsp.exit()" { description = "exit session"; })
        (bind "${mod} + L" ''hl.dsp.exec_cmd("loginctl lock-session")'' { description = "lock session"; })

        (bind "${mod} + V" ''hl.dsp.window.float({ action = "toggle" })'' {
          description = "toggle floating window";
        })
        (bind "${mod} + P" "hl.dsp.window.pseudo()" { description = "toggle pseudo mode"; }) # dwindle
        (bind "${mod} + J" ''hl.dsp.layout("togglesplit")'' { description = "toggle split mode"; })

        # Move focus with $mod + arrow keys
        (bind "${mod} + left" ''hl.dsp.focus({ direction = "left" })'' { description = "focus left"; })
        (bind "${mod} + right" ''hl.dsp.focus({ direction = "right" })'' { description = "focus right"; })
        (bind "${mod} + up" ''hl.dsp.focus({ direction = "up" })'' { description = "focus up"; })
        (bind "${mod} + down" ''hl.dsp.focus({ direction = "down" })'' { description = "focus down"; })

        # Special workspace (scratchpad)
        (bind "${mod} + S" ''hl.dsp.workspace.toggle_special("magic")'' {
          description = "toggle scratchpad workspace";
        })
        (bind "${mod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'' {
          description = "move window to scratchpad";
        })

        # Scroll through existing workspaces with $mod + scroll
        (bind "${mod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'' {
          description = "switch to next workspace";
        })
        (bind "${mod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'' {
          description = "switch to previous workspace";
        })

        # Move/resize windows with $mod + LMB/RMB and dragging
        (bind "${mod} + mouse:272" "hl.dsp.window.drag()" {
          description = "move window";
          mouse = true;
        })
        (bind "${mod} + mouse:273" "hl.dsp.window.resize()" {
          description = "resize window";
          mouse = true;
        })

        # Volume and Microphone
        (bind "XF86AudioRaiseVolume"
          ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && audio.sh")''
          {
            description = "increase volume";
            repeating = true;
            locked = true;
          }
        )
        (bind "XF86AudioLowerVolume"
          ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && audio.sh")''
          {
            description = "decrease volume";
            repeating = true;
            locked = true;
          }
        )
        (bind "${mod} + XF86AudioMicMute"
          ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ && audio.sh mic")''
          {
            description = "increase microphone volume";
            repeating = true;
            locked = true;
          }
        )
        (bind "${mod} + SHIFT + XF86AudioMicMute"
          ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%- && audio.sh mic")''
          {
            description = "decrease microphone volume";
            repeating = true;
            locked = true;
          }
        )

        # LCD brightness
        (bind "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("brightnessctl s 10%+ && brightness.sh")'' {
          description = "increase brightness";
          repeating = true;
          locked = true;
        })
        (bind "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("brightnessctl s 10%- && brightness.sh")'' {
          description = "decrease brightness";
          repeating = true;
          locked = true;
        })
        (bind "SHIFT + XF86MonBrightnessUp" ''hl.dsp.exec_cmd("brightnessctl s 5%+ && brightness.sh")'' {
          description = "fine increase brightness";
          repeating = true;
          locked = true;
        })
        (bind "SHIFT + XF86MonBrightnessDown" ''hl.dsp.exec_cmd("brightnessctl s 5%- && brightness.sh")'' {
          description = "fine decrease brightness";
          repeating = true;
          locked = true;
        })

        # Muting and unmuting audio and microphone
        (bind "XF86AudioMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && audio.sh")''
          {
            description = "toggle audio mute";
            locked = true;
          }
        )
        (bind "XF86AudioMicMute"
          ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && audio.sh mic")''
          {
            description = "toggle microphone mute";
            locked = true;
          }
        )

        # Play/pause, next, previous
        (bind "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'' {
          description = "play next track";
          locked = true;
        })
        (bind "XF86AudioPause" ''hl.dsp.exec_cmd("playerctl play-pause")'' {
          description = "toggle play/pause";
          locked = true;
        })
        (bind "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'' {
          description = "toggle play/pause";
          locked = true;
        })
        (bind "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'' {
          description = "play previous track";
          locked = true;
        })
      ]
      ++ (
        ### WORKSPACES BINDINGS ###

        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = toString (i + 1);
            in
            [
              (bind "${mod} + code:1${toString i}" "hl.dsp.focus({ workspace = ${ws} })" {
                description = "workspace ${ws}";
              })
              (bind "${mod} + SHIFT + code:1${toString i}" "hl.dsp.window.move({ workspace = ${ws} })" {
                description = "move to workspace ${ws}";
              })
            ]
          ) 9
        )
      );

      ### MONITORS ###

      monitor =
        if hostConfig.device.hostname == "goliath" then
          [
            {
              output = "DP-3";
              mode = "1920x1080@143.98";
              position = "0x0";
              scale = "auto";
            }
            {
              output = "HDMI-A-4";
              mode = "1920x1080@100.00";
              position = "1920x0";
              scale = "auto";
            }
          ]
        else
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = "auto";
          };

      ### WORKSPACE RULES ###

      workspace_rule = lib.optional (hostConfig.device.hostname == "goliath") {
        workspace = "1";
        monitor = "DP-3";
      };

      ### WINDOW RULES ###

      window_rule = [
        {
          # Ignore maximize requests from apps
          name = "suppress-maximize-events";
          match.class = ".*";
          suppress_event = "maximize";
        }
        {
          # Fix some dragging issues with XWayland
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
      ];
    };
  };
}
