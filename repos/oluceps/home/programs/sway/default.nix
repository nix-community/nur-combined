{
  config,
  pkgs,
  lib,
  osConfig,
  user,
  ...
}:
{

  wayland.windowManager.sway =
    let
      wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
      wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
      genDeps = n: lib.genAttrs n (name: lib.getExe pkgs.${name});
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
      modifier = "Mod4";
    in
    {

      package = null;
      # enable = if osConfig.networking.hostName == "hastur" then false else true;
      enable = true;
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      wrapperFeatures.gtk = true;

      extraConfig = ''
        bindgesture swipe:right workspace prev
        bindgesture swipe:left workspace next
        bindsym --whole-window {
            ${modifier}+button4 workspace prev
            ${modifier}+button5 workspace next
        }

        for_window [app_id="org.gnome.Nautilus"] floating enable
        for_window [title="^Open File$"] floating enable
        for_window [title="^Media viewer$"] floating enable, resize set 800 600

        # blur enable
        # blur_passes 2
        # corner_radius 2
        # shadows enable
      '';
      config = {

        inherit modifier;
        assigns = {
          # "1" = [{ app_id = "Alacritty"; }];
          # "2" = [{ app_id = "firefox"; }];
          # "3" = [{ app_id = "org.telegram.desktop"; }];
        };
        window.commands = [
          {
            criteria = {
              app_id = "gcr-prompter";
            };
            command = "floating enable";
          }
        ];
        startup = [
          { command = "fcitx5 -d"; }
          { command = with pkgs; "${lib.getExe systemd-run-app} ${firefox}"; }
          { command = with pkgs; "${lib.getExe systemd-run-app} ${lib.getExe tdesktop}"; }
          { command = with deps; "${wl-paste} --type text --watch ${cliphist} store"; } # Stores only text data
          { command = with deps; "${wl-paste} --type image --watch ${cliphist} store"; } # Stores image data
        ];
        gaps = {
          inner = 2;
          outer = 1;
          smartGaps = true;
        };
        bars = [ ];
        input = {
          "1267:12764:ELAN2204:00_04F3:31DC_Touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };

        colors = {
          focused = {
            background = "#787878";
            border = "#f0c9cf";
            childBorder = "#D7C4BB";
            indicator = "#E1A679";
            text = "#ffffff";
          };
          unfocused = {
            background = "#2b3339";
            border = "#597B84";
            childBorder = "#597B84";
            indicator = "#E1A679";
            text = "#888888";
          };
          urgent = {
            background = "#e68183";
            border = "#DB8E71";
            childBorder = "#DB8E71";
            indicator = "#a7c080";
            text = "#ffffff";
          };
          background = "a7c080";
        };

        workspaceOutputAssign = [
          {
            output = "HDMI-A-1";
            workspace = "1";
          }
        ];

        output =
          if osConfig.networking.hostName == "hastur" then
            {
              HDMI-A-1 = {
                bg = "/home/${user}/Src/nixos/.attachs/wall.jpg fill";
                mode = "1920x1080";
                scale = "1.25";
              };
            }
          else if osConfig.networking.hostName == "kaambl" then
            {
              eDP-1 = {
                bg = "/home/${user}/Src/nixos/.attachs/wall.jpg fill";
                mode = "2160x1440";
                scale = "2";
              };
              HDMI-A-1 = {
                bg = "/home/${user}/Src/nixos/.attachs/wall.jpg fill";
                mode = "2560x1660";
                scale = "2";
              };
            }
          else
            {

              eDP-1 = {
                bg = "/home/${user}/Src/nixos/.attachs/wall.jpg fill";
                mode = "1366x768";
                scale = "1";
              };
            };

        window.hideEdgeBorders = "smart";
        keybindings =
          let
            inherit (config.wayland.windowManager.sway.config) modifier;
            fuzzelArgs = "-I -l 7 -x 8 -y 7 -P 9 -b ede3e7d9 -r 3 -t 8b614db3 -C ede3e7d9 -f 'Maple Mono SC NF:style=Regular:size=15' -P 10 -B 7";
          in
          with pkgs;
          lib.mkOptionDefault (
            {
              # "blur" = "enable";
              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";
              "${modifier}+i" = "move scratchpad";
              "${modifier}+q" = "kill";
              "${modifier}+Shift+q" = null;
              "${modifier}+Ctrl+i" = "scratchpad show";

              "${modifier}+Ctrl+h" = "move left";
              "${modifier}+Ctrl+j" = "move down";
              "${modifier}+Ctrl+k" = "move up";
              "${modifier}+Ctrl+l" = "move right";
              "${modifier}+Ctrl+s" = "exec ${deps.save-clipboard-to}";

              "--no-repeat XF86AudioMute" = "exec pamixer --toggle-mute";
              "XF86AudioRaiseVolume" = "exec pamixer -i 5";
              "XF86AudioLowerVolume" = "exec pamixer -d 5";
              "XF86MonBrightnessUp" = "exec brightnessctl set +3%";
              "XF86MonBrightnessdown" = "exec brightnessctl set 3%-";
              "${modifier}+Return" = "exec ${lib.getExe systemd-run-app} ${lib.getExe foot}";
              "${modifier}+d" = "exec ${lib.getExe fuzzel} ${fuzzelArgs}";
              "${modifier}+space" = "floating toggle";
              "${modifier}+Shift+space" = null;
              "Print" = "exec ${lib.getExe sway-contrib.grimshot} copy area";
              "Alt+Print" = "exec ${deps.grim} - | ${wl-copy} -t image/png";
              "Ctrl+Shift+l" = "exec ${lib.getExe swaylock}";
              "${modifier}+Ctrl+p" = "exec ${lib.getExe cliphist} list | ${lib.getExe fuzzel} -d ${fuzzelArgs} ${"-w 50"} | ${lib.getExe cliphist} decode | ${wl-copy}";
              "${modifier}+shift+r" = "exec ${lib.getExe screen-recorder-toggle}";
            }
            # override default
            // (lib.listToAttrs (
              (map (n: {
                name = "${modifier}+Shift+${n}";
                value = null;
              }))
                [
                  "h"
                  "j"
                  "k"
                  "l"
                ]
            ))
            // (lib.listToAttrs (
              (map (n: {
                name = "${modifier}+Shift+${toString n}";
                value = null;
              }))
                (lib.range 1 9)
            ))
            // (lib.listToAttrs (
              (map (n: {
                name = "${modifier}+Ctrl+${toString n}";
                value = "move container to workspace number ${toString n}";
              }))
                (lib.range 1 9)
            ))
          );
      };
    };
}
