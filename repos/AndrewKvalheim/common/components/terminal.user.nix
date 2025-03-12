{ lib, pkgs, ... }:

let
  palette = import ../resources/palette.nix { inherit lib pkgs; };
in
{
  programs.kitty = {
    enable = true;

    font = {
      package = pkgs.iosevka-custom.term;
      name = "Iosevka Custom Term";
      size = 11;
    };

    keybindings = {
      # Kitty
      "ctrl+shift+f5" = "load_config_file";

      # Panes
      "ctrl+n" = "launch --location=split";
      "ctrl+shift+down" = "launch --location=hsplit";
      "ctrl+shift+right" = "launch --location=vsplit";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+r" = "start_resizing_window";
      "alt+down" = "neighboring_window down";
      "alt+up" = "neighboring_window up";
      "alt+left" = "neighboring_window left";
      "alt+right" = "neighboring_window right";
      "alt+shift+up" = "move_window up";
      "alt+shift+left" = "move_window left";
      "alt+shift+right" = "move_window right";
      "alt+shift+down" = "move_window down";

      # Tabs
      "ctrl+t" = "new_tab";
      "ctrl+shift+t" = "detach_window ask";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+tab" = "next_tab";
      "ctrl+page_up" = "previous_tab";
      "ctrl+page_down" = "next_tab";
      "ctrl+shift+page_up" = "move_tab_backward";
      "ctrl+shift+page_down" = "move_tab_forward";

      # Windows
      "ctrl+shift+n" = "new_os_window";
      "f11" = "toggle_fullscreen";

      # Scrolling
      "shift+page_up" = "scroll_page_up";
      "shift+page_down" = "scroll_page_down";
      "alt+page_up" = "scroll_to_prompt -1";
      "alt+page_down" = "scroll_to_prompt 1";

      # Clipboard
      "ctrl+c" = "copy_and_clear_or_interrupt";
      "ctrl+shift+c" = "copy_ansi_to_clipboard";
      "ctrl+v" = "paste_from_clipboard";

      # Text input
      "alt+h" = "kitten hints --type hash --program -";
      "alt+l" = "kitten hints --type line --program -";
      "alt+p" = "kitten hints --type path --program -";
      "ctrl+shift+u" = "kitten unicode_input";
    };

    settings = with palette.hex; {
      # API
      allow_remote_control = true;

      # Keyboard
      clear_all_shortcuts = true;

      # Mouse
      click_interval = "0.25";
      focus_follows_mouse = "yes";
      mouse_hide_wait = "0";
      select_by_word_characters = "-_?&%+#";

      # Windows
      hide_window_decorations = true;
      scrollback_lines = "16384";
      enabled_layouts = "splits";

      # Workaround for https://github.com/kovidgoyal/kitty/issues/3180
      touch_scroll_multiplier = "10";

      # Sounds
      enable_audio_bell = "no";

      # Font
      bold_font = "Iosevka Custom Term Bold";
      italic_font = "Iosevka Custom Term Italic";
      bold_italic_font = "Iosevka Custom Term Bold Italic";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "bold";

      # Cursor
      cursor_shape = "beam";

      # URLs
      url_style = "single";

      # Colors
      dim_opacity = "0.4";
      wayland_titlebar_color = black;
      foreground = white;
      background = black;
      background_opacity = 0.9;
      cursor = orange;
      url_color = white;
      active_border_color = white-dark;
      inactive_border_color = white-dark;
      bell_border_color = red;
      active_tab_foreground = white;
      active_tab_background = white-dark;
      inactive_tab_foreground = white-dim;
      inactive_tab_background = white-dark;
      selection_foreground = black;
      selection_background = orange;
      color0 = white-dark;
      color1 = red;
      color2 = green;
      color3 = yellow;
      color4 = blue;
      color5 = orange;
      color6 = purple;
      color7 = white;
      color8 = white-dim;
      color9 = red;
      color10 = green;
      color11 = yellow;
      color12 = blue;
      color13 = orange;
      color14 = purple;
      color15 = white;
    };
  };

  programs.git.extraConfig."difftool \"kitty\"".cmd = "kitty +kitten diff $LOCAL $REMOTE";

  programs.zsh.shellAliases.icat = "kitty +kitten icat";
  programs.zsh.shellAliases.ssh = "kitty +kitten ssh";
}
