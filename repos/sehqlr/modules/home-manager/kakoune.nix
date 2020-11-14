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
          '';
        }
        {
          name = "WinCreate";
          option = "^.*zettelkasten.*$";
          commands = ''
            set-option window filetype zettel
          '';
        }
        {
          name = "WinSetOption";
          option = "filetype=markdown";
          commands = ''
            set-option buffer lintcmd 'proselint'
            set-option buffer formatcmd 'pandoc -f markdown -t markdown -s'
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
      keyMappings = [
        {
          docstring = "wc -w on a selection; will not work on large selections";
          mode = "user";
          key = "w";
          effect = '':echo %sh{ echo "$kak_selection" | wc -w }<ret>'';
        }
        {
          docstring =
            "wc -w on the whole buffile; will not work on scratch buffers";
          mode = "user";
          key = "W";
          effect = '':echo %sh{ cat "$kak_buffile" | wc -w }<ret>'';
        }
      ];
      numberLines.enable = true;
      showWhitespace.enable = true;
      ui.enableMouse = true;
      wrapLines = {
        enable = true;
        marker = "⏎";
        word = true;
      };
    };
  };
}
