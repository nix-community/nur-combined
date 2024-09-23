{
  programs.kitty = {
    enable = true;
    font.name = "Iosevka ZT Extended";
    font.size = 12;
    shellIntegration.enableFishIntegration = true;
    settings = {
      tab_bar_edge = "top";
      bold_font = "Iosevka ZT Semibold Extended";
      italic_font = "Iosevka ZT Italic Extended";
      bold_italic_font = "ZT Semibold Extended Italic";
      enable_audio_bell = false;
      scrollback_lines = 8000;
      initial_window_width = 640;
      initial_window_height = 400;
      update_check_interval = 0;
      hide_window_decorations = true;
      tabs = true;
      tab_bar_style = "powerline";
      scrollback_pager = "bat";
    };
    keybindings = {
      "alt+shift+left" = "resize_window narrower";
      "alt+shift+right" = "resize_window wider";
    };
    # https://github.com/kovidgoyal/kitty-themes/blob/master/themes.json
    themeFile = "everforest_dark_medium";
  };
}
