{
  imports = [ ./catppuccin.nix ];

  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = 7;
    };
    misc = {
      disable_splash_rendering = true;
      force_default_wallpaper = 0;
      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;
    };

    # https://easings.net
    animation = "global, 1, 5, easeOutQuint";
    bezier = "easeOutQuint, 0.22, 1, 0.36, 1";
  };

  # Remove minimize, maximize, close buttons
  gtk = {
    gtk3.extraConfig.gtk-decoration-layout = "menu:";
    gtk4.extraConfig.gtk-decoration-layout = "menu:";
  };
}
