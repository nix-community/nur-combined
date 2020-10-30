{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ nixfmt python37Packages.editorconfig ];

  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "solarized-dark";
      hooks = [
        {
          name = "WinCreate";
          option = "^[^*]+$";
          commands = "editorconfig-load";
        }
        {
          name = "BufCreate";
          option = "^.*md$";
          commands = ''
            set-option buffer modelinefmt 'wc:%sh{ cat "$kak_buffile" | wc -w} - %val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]'
          '';
        }
        {
          name = "BufCreate";
          option = "^.*lhs$";
          commands = ''
            set-option buffer filetype markdown
          '';
        }
        {
          name = "InsertChar";
          option = "j";
          commands = ''
            try %{
                exec -draft hH <a-k>jj<ret> d
                exec <esc>
            }
          '';
        }
      ];
      numberLines.enable = true;
      showWhitespace.enable = true;
      ui.enableMouse = true;
    };
  };
}
