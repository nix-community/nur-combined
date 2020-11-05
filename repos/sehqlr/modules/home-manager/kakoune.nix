{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    nixfmt
    nix-linter
    pandoc
    proselint
    python37Packages.editorconfig
  ];

  programs.zsh.sessionVariables = { EDITOR = "kak"; };
  home.sessionVariables = { EDITOR = "kak"; };
  systemd.user.sessionVariables = { EDITOR = "kak"; };

  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "solarized-dark";
      hooks = [
        {
          name = "WinCreate";
          option = "^[^*]+$";
          commands = ''
            editorconfig-load
            autowrap-enable
          '';
        }
        {
          name = "BufCreate";
          option = "^.*md$";
          commands = ''
            set-option buffer modelinefmt 'wc:%sh{ cat "$kak_buffile" | wc -w} - %val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]'
            set-option buffer lintcmd 'proselint'
            set-option buffer formatcmd 'pandoc -f commonmark -t commonmark'
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
        {
          name = "BufCreate";
          option = "^.*nix$";
          commands = ''
            set-option buffer formatcmd 'nixfmt'
            set-option buffer lintcmd 'nix-linter'
          '';
        }
      ];
      keyMappings = [{
        docstring = "wc -w on a selection";
        mode = "user";
        key = "w";
        effect = ":echo %sh{ wc -w <lt><lt><lt> \"$kak_selection\" }<ret>";
      }];
      numberLines.enable = true;
      showWhitespace.enable = true;
      ui.enableMouse = true;
    };
  };
}
