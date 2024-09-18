{
  programs.wezterm = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    #shellIntegration.enableFishIntegration = true;
    extraConfig = ''
      '';
    settings = {
      #font_family = "FiraCode Nerd Font";
      #font_family = "Liberation Mono";
      font_family = "DejaVu Sans Mono";
      cursor = "#cccccc";
      font_size = "12";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      enable_audio_bell = false;
      scrollback_lines = -1;
      tab_bar_edge = "top";
      allow_remote_control = "yes";
      #shell_integration = "enabled";
      #shell = "fish";
    };
    #theme = "Solarized Light";
  };

}
