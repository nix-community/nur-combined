{ lib, pkgs, ... }:

let
  inherit (lib) concatStringsSep;

  palette = import ../library/palette.lib.nix { inherit lib pkgs; };

  # https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
  nerdFontsRange = concatStringsSep "," [
    "U+0e000-U+0e00a"
    "U+0e0a0-U+0e0a2"
    "U+0e0a3"
    "U+0e0b0-U+0e0b3"
    "U+0e0b4-U+0e0c8"
    "U+0e0ca"
    "U+0e0cc-U+0e0d7"
    "U+0e200-U+0e2a9"
    "U+0e300-U+0e3e3"
    "U+0e5fa-U+0e6b7"
    "U+0e700-U+0e8ef"
    "U+0ea60-U+0ec1e"
    "U+0ed00-U+0efce"
    "U+0f000-U+0f2ff"
    "U+0f300-U+0f381"
    "U+0f400-U+0f533"
    "U+f0001-U+f1af0"
  ];
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
      symbol_map = "${nerdFontsRange} Symbols Nerd Font Mono"; # Prefer bundled Nerd Font
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
      color0 = ansi.black;
      color1 = ansi.red;
      color2 = ansi.green;
      color3 = ansi.yellow;
      color4 = ansi.blue;
      color5 = ansi.magenta;
      color6 = ansi.cyan;
      color7 = ansi.white;
      color8 = ansi.bright.black;
      color9 = ansi.bright.red;
      color10 = ansi.bright.green;
      color11 = ansi.bright.yellow;
      color12 = ansi.bright.blue;
      color13 = ansi.bright.magenta;
      color14 = ansi.bright.cyan;
      color15 = ansi.bright.white;
    };
  };

  programs.git.settings."difftool \"kitty\"".cmd = "kitty +kitten diff $LOCAL $REMOTE";

  programs.zsh.shellAliases.icat = "kitty +kitten icat";
  programs.zsh.shellAliases.ssh = "kitty +kitten ssh";
}
