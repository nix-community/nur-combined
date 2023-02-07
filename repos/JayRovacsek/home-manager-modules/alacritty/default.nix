{ config, pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      shell.program = "${pkgs.zsh}/bin/zsh";
      window = {
        dimenstions = {
          columns = 0;
          lines = 0;
        };
        padding = {
          x = 2;
          y = 2;
        };
        dynamic_title = false;
        dynamic_padding = false;
        decorations = "full";
        startup_mode = "Windowed";
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal.family = "Hack Nerd Font";
        bold.family = "Hack Nerd Font";
        italic.family = "Hack Nerd Font";
        size = 14.0;
        offset = {
          x = 0;
          y = 0;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
      };

      draw_bold_text_with_bright_colors = true;

      colors = {
        primary.background = "0x000000";
        primary.foreground = "0xeaeaea";
        cursor.text = "0x000000";
        cursor.cursor = "0xffffff";
        normal = {
          black = "0x666666";
          red = "0xff3334";
          green = "0x9ec400";
          yellow = "0xe7c547";
          blue = "0x7aa6da";
          magenta = "0xb77ee0";
          cyan = "0x54ced6";
          white = "0xffffff";
        };
        indexed_colors = [ ];
      };

      bell.animation = "EaseOutExpo";
      bell.duration = 0;
      bell.color = "0xffffff";

      mouse.hide_when_typing = true;

      selection.semantic_escape_chars = '',│`|:"' ()[]{}<>'';
      selection.save_to_clipboard = false;

      cursor.style = "Block";
      cursor.unfocused_hollow = true;
      live_config_reload = true;
    };
  };
}
