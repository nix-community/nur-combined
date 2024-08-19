let
  keybinds = builtins.readFile ./config/keybinds.conf;
  window-rules = builtins.readFile ./config/window-rules.conf;
in

{
  imports = [
    ./pkgs.nix
    ./waybar
    ./swaylock.nix
  ];
  home.file.".config/hypr/hyprpaper.conf".source = ./config/hyprpaper.conf;
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;

    xwayland = {
      enable = true;
      hidpi = true;
    };
    settings = {

      monitor = [ ", preferred, auto, auto" ];
      "$mod" = "SUPER";

      general = {
        gaps_in = 2;
        gaps_out = 0;
        border_size = 0;
        no_border_on_floating = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      input = {
        kb_layout = "us, fr";
        kb_options = "grp:alt_shift_toggle";
        touchpad = {
          natural_scroll = true;
          drag_lock = true;
        };
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_cancel_ratio = 0.3;
      };

      decoration = {
        rounding = 8;
        drop_shadow = true;
        shadow_ignore_window = true;
        shadow_offset = "0 5";
        shadow_range = 50;
        shadow_render_power = 3;
        "col.shadow" = "rgba(00000099)";
      };

      animation = [
        "border, 1, 2, default"
        "fade, 1, 4, default"
        "windows, 1, 3, default, popin 80%"
        "workspaces, 1, 2, default, slide"
      ];
    };
    extraConfig = ''
      ${window-rules}
      ${keybinds}
    '';
  };
}
