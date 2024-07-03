{
  imports = [ ./catppuccin.nix ];

  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = 5;
    };
    misc = {
      force_default_wallpaper = 2;
      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;
    };

    # https://easings.net
    animation = "global, 1, 5, easeOutQuint";
    bezier = "easeOutQuint, 0.22, 1, 0.36, 1";
  };
}
