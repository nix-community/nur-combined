# naysayer color theme for Alacritty
#
# Based on the naysayer Emacs theme:
# https://github.com/nickav/naysayer-theme.el/blob/master/naysayer-theme.el
#
# Usage: splice the `colors` attrset into your alacritty settings, e.g. in
# modules/alacritty.nix:
#
#   colors = (import ./alacritty-naysayer.nix).colors;
#
# ANSI mapping:
#   normal  = monokai accents from the theme palette
#   bright  = lightened variants (dim grey for bright black)
#   dim     = ~55% darkened normal colors (for dim text / tmux status)
#
# Palette: bg #062329, text #d1b897, selection #0000ff, panel #0b3335,
# border #126367, strings #2ec09c, comments #44b340, constants #7ad0c6,
# macros/punct #8cde94, keywords #ffffff, variables #c1d1e3.
{
  colors = {
    primary = {
      # dark green-blue background, tan text
      background = "0x062329";
      foreground = "0xd1b897";
    };

    # Normal colors
    normal = {
      black = "0x062329";
      red = "0xf92672";
      green = "0xa6e22e";
      yellow = "0xe6db74";
      blue = "0x66d9ef";
      magenta = "0xfd5ff0";
      cyan = "0xa1efe4";
      white = "0xd1b897";
    };

    # Bright colors
    bright = {
      black = "0x93a7ab";
      red = "0xff5c8a";
      green = "0xc6f34f";
      yellow = "0xf5ed9c";
      blue = "0x93e7f7";
      magenta = "0xff9ef5";
      cyan = "0xc9f7f0";
      white = "0xf0e8da";
    };

    # Dim colors (darkened normal colors)
    dim = {
      black = "0x031317";
      red = "0x89153f";
      green = "0x5b7c19";
      yellow = "0x7f7840";
      blue = "0x387783";
      magenta = "0x8b3484";
      cyan = "0x59837d";
      white = "0x736553";
    };

    # naysayer selection: blue region, tan text
    selection = {
      text = "0xd1b897";
      background = "0x0000ff";
    };

    # naysayer cursor: white block (Emacs cursor face), tan glyph
    cursor = {
      text = "0xd1b897";
      cursor = "0xffffff";
    };

    # Unused config key
    # vi = {
    #   text = "0xd1b897";
    #   cursor = "0xffffff";
    # };

    # Search: monokai blue for the focused match, teal for others
    search = {
      matches = {
        foreground = "0xd1b897";
        background = "0x126367";
      };
      focused_match = {
        foreground = "0x062329";
        background = "0x66d9ef";
      };
      # Unused config key:
      # footer_bar = {
      #   foreground = "0xd1b897";
      #   background = "0x0b3335";
      # };
    };

    # URL/vi-mode hints: yellow start, orange end
    hints = {
      start = {
        foreground = "0x062329";
        background = "0xe6db74";
      };
      end = {
        foreground = "0x062329";
        background = "0xfd971f";
      };
    };
  };
}
