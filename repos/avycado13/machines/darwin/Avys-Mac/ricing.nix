_: {

  services.aerospace = {
    enable = true;

    settings = {
      # config-version = 2;
      accordion-padding = 30;

      exec-on-workspace-change = [ ];

      automatically-unhide-macos-hidden-apps = false;

      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      gaps = {
        inner = {
          horizontal = 18;
          vertical = 18;
        };

        outer = {
          top = 18;
          left = 18;
          right = 18;
          bottom = 18;
        };
      };

      key-mapping.preset = "qwerty";

      mode = {
        main.binding = {
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";
          alt-a = "workspace A";
          alt-b = "workspace B";
          alt-c = "workspace C";
          alt-comma = "layout accordion horizontal vertical";
          alt-d = "workspace D";
          alt-e = "workspace E";
          alt-equal = "resize smart +50";
          alt-shift-equal = "flatten-workspace-tree";
          # alt-f = "workspace F";
          alt-g = "workspace G";
          alt-h = "focus left";
          alt-i = "workspace I";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";
          alt-m = "workspace M";
          alt-minus = "resize smart -50";
          # alt-n = "workspace N";
          alt-o = "workspace O";
          alt-p = "workspace P";
          alt-q = "workspace Q";
          alt-r = "workspace R";
          alt-s = "workspace S";
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";
          alt-shift-a = "move-node-to-workspace A";
          alt-shift-b = "move-node-to-workspace B";
          alt-shift-c = "move-node-to-workspace C";
          alt-shift-d = "move-node-to-workspace D";
          alt-shift-e = "move-node-to-workspace E";
          alt-shift-g = "move-node-to-workspace G";
          alt-shift-h = "move left";
          alt-shift-i = "move-node-to-workspace I";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";
          alt-shift-m = "move-node-to-workspace M";
          alt-shift-n = "move-node-to-workspace N";
          alt-shift-o = "move-node-to-workspace O";
          alt-shift-p = "move-node-to-workspace P";
          alt-shift-q = "move-node-to-workspace Q";
          alt-shift-r = "move-node-to-workspace R";
          alt-shift-s = "move-node-to-workspace S";
          alt-shift-semicolon = "mode service";
          alt-shift-t = "move-node-to-workspace T";
          alt-shift-tab = "move-node-to-monitor --wrap-around next";
          alt-shift-u = "move-node-to-workspace U";
          alt-shift-v = "move-node-to-workspace V";
          alt-shift-w = "move-node-to-workspace W";
          alt-shift-x = "move-node-to-workspace X";
          alt-shift-y = "move-node-to-workspace Y";
          alt-shift-z = "move-node-to-workspace Z";
          alt-slash = "layout tiles horizontal vertical";
          alt-t = "workspace T";
          alt-tab = "workspace-back-and-forth";
          alt-u = "workspace U";
          alt-v = "workspace V";
          alt-w = "workspace W";
          alt-x = "workspace X";
          alt-y = "workspace Y";
          alt-z = "workspace Z";
          alt-ctrl-tab = "move-workspace-to-monitor --wrap-around next";
          alt-ctrl-s = "exec-and-forget screencapture -i -c";
        };

        service.binding = {
          alt-shift-h = [
            "join-with left"
            "mode main"
          ];
          alt-shift-j = [
            "join-with down"
            "mode main"
          ];
          alt-shift-k = [
            "join-with up"
            "mode main"
          ];
          alt-shift-l = [
            "join-with right"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];
          down = "volume down";
          esc = [
            "reload-config"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          shift-down = [
            "volume set 0"
            "mode main"
          ];
          up = "volume up";
        };
      };

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      on-window-detected = [
        {
          # "if" = "test %{app-bundle-id} = com.microsoft.VSCode";
          "if".app-id = "com.microsoft.VSCode";
          run = "move-node-to-workspace C";
        }
        {
          # "if" = "test %{app-bundle-id} = com.tinyspeck.slackmacgap";
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "move-node-to-workspace M";
        }
        {
          # "if" = "test %{app-bundle-id} = com.tinyspeck.slackmacgap";
          "if".app-id = "app.jer.taut";
          run = "move-node-to-workspace M";
        }
        {
          # "if" = "test %{app-bundle-id} = com.apple.MobileSMS";
          "if".app-id = "com.apple.MobileSMS";
          run = "move-node-to-workspace M";
        }
      ];
    };
  };
  services.jankyborders = {
    enable = true;
    style = "round";
    width = 4.0;
    hidpi = true;
    active_color = "0xFFCBA6F7"; # Mauve
    inactive_color = "0xFF585B70"; # Surface2
    background_color = "0x00000000"; # Transparent
    blur_radius = 0.0;
    order = "above";
    ax_focus = false;
  };
}
