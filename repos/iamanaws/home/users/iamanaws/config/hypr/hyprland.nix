{
  lib,
  hostConfig,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;

  host = hostConfig.device.hostname;
  isGoliath = host == "goliath";
  isArchimedes = host == "archimedes";

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

  # Shell command binds
  sh =
    keys: cmd: flags:
    bind keys ''hl.dsp.exec_cmd("${cmd}")'' flags;
  lsh =
    keys: cmd: flags:
    sh keys cmd (flags // { locked = true; });
  rlsh =
    keys: cmd: flags:
    sh keys cmd (
      flags
      // {
        repeating = true;
        locked = true;
      }
    );

  # Lua-local command binds (terminal, browser, ...)
  run =
    keys: var: flags:
    bind keys "hl.dsp.exec_cmd(${var})" flags;

  env = name: value: {
    _args = [
      name
      value
    ];
  };

  bezier = name: x0: y0: x1: y1: {
    _args = [
      name
      {
        type = "bezier";
        points = [
          [
            x0
            y0
          ]
          [
            x1
            y1
          ]
        ];
      }
    ];
  };

  anim =
    leaf: speed: bezier: extras:
    {
      inherit leaf speed bezier;
      enabled = true;
    }
    // extras;
in
{
  wayland.windowManager.hyprland = {
    enable = true;

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
        (env "HYPRCURSOR_SIZE" "24")
        (env "XCURSOR_SIZE" "24")
      ]
      ++ lib.optional isGoliath (env "AQ_DRM_DEVICES" "/dev/dri/dgpu1")
      ++ lib.optional isArchimedes (env "GDK_SCALE" "2");

      ### SECTIONS (hl.config) ###

      config = {
        debug.vfr = true;

        xwayland.force_zero_scaling = true;

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
          shadow.enabled = false;
          blur.enabled = false;
        };

        dwindle.preserve_split = true;
        master.new_status = "master";

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          middle_click_paste = false;
        };

        input = {
          kb_layout = "latam";
          follow_mouse = 1;
          sensitivity = 0.8; # -1.0 - 1.0, 0 means no modification.
          touchpad.natural_scroll = true;
        };
      };

      ### ANIMATIONS ###

      curve = [
        (bezier "easeOutQuint" 0.23 1 0.32 1)
        (bezier "linear" 0 0 1 1)
        (bezier "almostLinear" 0.5 0.5 0.75 1.0)
        (bezier "quick" 0.15 0 0.1 1)
      ];

      animation = [
        (anim "global" 10 "default" { })
        (anim "border" 5.39 "easeOutQuint" { })
        (anim "windows" 4.79 "easeOutQuint" { })
        (anim "windowsIn" 4.1 "easeOutQuint" { style = "popin 87%"; })
        (anim "windowsOut" 1.49 "linear" { style = "popin 87%"; })
        (anim "fadeIn" 1.73 "almostLinear" { })
        (anim "fadeOut" 1.46 "almostLinear" { })
        (anim "fade" 3.03 "quick" { })
        (anim "layers" 3.81 "easeOutQuint" { })
        (anim "layersIn" 4 "easeOutQuint" { style = "fade"; })
        (anim "layersOut" 1.5 "linear" { style = "fade"; })
        (anim "fadeLayersIn" 1.79 "almostLinear" { })
        (anim "fadeLayersOut" 1.39 "almostLinear" { })
        (anim "workspaces" 1.94 "almostLinear" { style = "fade"; })
        (anim "workspacesIn" 1.21 "almostLinear" { style = "fade"; })
        (anim "workspacesOut" 1.94 "almostLinear" { style = "fade"; })
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
        (run "${mod} + return" "terminal" { description = "open terminal"; })
        (run "${mod} + W" "browser" { description = "open browser"; })
        (run "${mod} + E" "explorer" { description = "open file explorer"; })
        (run "${mod} + C" "codeEditor" { description = "open code editor"; })
        (run "${mod} + SHIFT + C" "colorPicker" { description = "open color picker"; })
        (run "Print" "screenshot" { description = "screenshot"; })
        (run "XF86SelectiveScreenshot" "screenshotSelective" { description = "selective screenshot"; })
        (sh "${mod} + I" "hyprsysteminfo" { description = "show system info"; })

        (sh "${mod} + R" "rofi -show drun" { description = "open app menu"; })
        (sh "${mod1} + space" "rofi -show drun" { description = "open app menu"; })
        (sh "${mod1} + SHIFT + space" "rofi -show" { description = "open full menu"; })

        (sh "${mod} + B" "uwsm app -- rofi-bluetooth" { description = "open bluetooth menu"; })
        (sh "${mod} + N" "uwsm app -- networkmanager_dmenu" { description = "open networkmanager menu"; })
        (sh "${mod} + A" "uwsm app -- dmenu-wpctl" { description = "open audio menu"; })
        (sh "${mod} + SHIFT + D" "date.sh" { description = "show system date"; })
        (sh "${mod} + SHIFT + B" "battery.sh" { description = "show battery status"; })
        (sh "${mod} + SHIFT + I" "cpu-mem.sh" { description = "show resources consumption"; })

        (bind "${mod} + SHIFT + W" "hl.dsp.window.close()" { description = "close active window"; })
        (bind "${mod} + M" "hl.dsp.exit()" { description = "exit session"; })
        (sh "${mod} + L" "loginctl lock-session" { description = "lock session"; })

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
        (rlsh "XF86AudioRaiseVolume" "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && audio.sh" {
          description = "increase volume";
        })
        (rlsh "XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && audio.sh" {
          description = "decrease volume";
        })
        (rlsh "${mod} + XF86AudioMicMute" "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ && audio.sh mic" {
          description = "increase microphone volume";
        })
        (rlsh "${mod} + SHIFT + XF86AudioMicMute"
          "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%- && audio.sh mic"
          {
            description = "decrease microphone volume";
          }
        )

        # LCD brightness
        (rlsh "XF86MonBrightnessUp" "brightnessctl s 10%+ && brightness.sh" {
          description = "increase brightness";
        })
        (rlsh "XF86MonBrightnessDown" "brightnessctl s 10%- && brightness.sh" {
          description = "decrease brightness";
        })
        (rlsh "SHIFT + XF86MonBrightnessUp" "brightnessctl s 5%+ && brightness.sh" {
          description = "fine increase brightness";
        })
        (rlsh "SHIFT + XF86MonBrightnessDown" "brightnessctl s 5%- && brightness.sh" {
          description = "fine decrease brightness";
        })

        # Muting and unmuting audio and microphone
        (lsh "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && audio.sh" {
          description = "toggle audio mute";
        })
        (lsh "XF86AudioMicMute" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && audio.sh mic" {
          description = "toggle microphone mute";
        })

        # Play/pause, next, previous
        (lsh "XF86AudioNext" "playerctl next" { description = "play next track"; })
        (lsh "XF86AudioPause" "playerctl play-pause" { description = "toggle play/pause"; })
        (lsh "XF86AudioPlay" "playerctl play-pause" { description = "toggle play/pause"; })
        (lsh "XF86AudioPrev" "playerctl previous" { description = "play previous track"; })
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
        if isGoliath then
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

      workspace_rule = lib.optional isGoliath {
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
