{
  programs.kitty = {
    enable = true;
    font.name = "Iosevka ZT Extended";
    font.size = 12;
    shellIntegration.enableFishIntegration = true;
    settings = {
      bold_font = "Iosevka ZT Semibold Extended";
      italic_font = "Iosevka ZT Semibold Italic";
      bold_italic_font = "ZT Semibold Extended Italic";
      enable_audio_bell = false;
      remember_window_size = true;
      scrollback_lines = 8000;
      initial_window_width = 640;
      initial_window_height = 400;
      update_check_interval = 0;
      background_opacity = "0.95";
      hide_window_decorations = true;
      tabs = true;
      tab_bar_style = "powerline";
    };
    # https://github.com/kovidgoyal/kitty-themes/blob/master/themes.json
    theme = "Everforest Dark Soft";
  };
}
