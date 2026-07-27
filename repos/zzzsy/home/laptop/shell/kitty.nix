{
  programs.kitty = {
    enable = true;
    font.name = "Iosevka ZT Extended";
    font.size = 12;
    shellIntegration.enableFishIntegration = true;
    enableGitIntegration = true;
    settings = {
      auto_reload_config = "-1";
      tab_bar_edge = "top";
      bold_font = "Iosevka ZT Semibold Extended";
      italic_font = "Iosevka ZT Italic Extended";
      bold_italic_font = "ZT Semibold Extended Italic";
      enable_audio_bell = false;
      scrollback_lines = 10000;
      initial_window_width = 640;
      initial_window_height = 400;
      update_check_interval = 0;
      hide_window_decorations = true;
      tabs = true;
      tab_bar_style = "powerline";
      scrollback_pager = "bat";
      dynamic_background_opacity = true;
      background_opacity = 0.95;
      strip_trailing_spaces = "smart";
      background_blur = 20;
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      wheel_scroll_multiplier = 5.0;
    };
    quickAccessTerminalConfig = {
      hide_on_focus_loss = true;
    };
    # https://github.com/kovidgoyal/kitty-themes/blob/master/themes.json
    autoThemeFiles = {
      dark = "everforest_dark_medium";
      light = "everforest_light_medium";
      noPreference = "everforest_dark_medium";
    };
  };
}
