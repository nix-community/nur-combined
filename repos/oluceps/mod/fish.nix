{
  flake.modules.nixos.fish =
    { config, ... }:
    {
      programs.fish = {
        enable = true;
        shellAbbrs = {
          sc = "systemctl";
          scs = "systemctl status";
          scr = "systemctl restart";
          jc = "journalctl";
          jcfu = "journalctl -fu";
          jcfk = "journalctl -fk";
        };
        shellAliases = {
          j = "just";
          ls = "eza --icons=auto --hyperlink --color=always --color-scale=all --color-scale-mode=gradient --git --git-repos";
          la = "eza --icons=auto --hyperlink --color=always --color-scale=all --color-scale-mode=gradient --git --git-repos -la";
          l = "eza --icons=auto --hyperlink --color=always --color-scale=all --color-scale-mode=gradient --git --git-repos -lh";
          nd = "cd /home/${config.identity.user}/Src/nixos";
          bl = "cd /home/${config.identity.user}/Src/blog.nyaw.xyz";
          swc = "sudo nixos-rebuild switch --flake /home/${config.identity.user}/Src/nixos";
          #--log-format internal-json -v 2>&1 | nom --json";
          daso = "sudo";
          daos = "sudo";
          off = "poweroff";
          mg = "kitty +kitten hyperlinked_grep --smart-case $argv .";
          kls = "lsd --icon never --hyperlink auto";
          lks = "lsd --icon never --hyperlink auto";
          g = "lazygit";
          "cd.." = "cd ..";
          st = "sudo systemctl-tui";
          rp = "rustplayer";
          y = "yazi";
          ".." = "cd ..";
          "。。" = "cd ..";
          "..." = "cd ../..";
          "。。。" = "cd ../..";
          "...." = "cd ../../..";
          "。。。。" = "cd ../../..";
        };

        shellInit = ''
          fish_vi_key_bindings
          set -g direnv_fish_mode eval_on_arrow
          set -U fish_greeting
          set fish_color_normal normal
          set fish_color_command blue
          set fish_color_quote yellow
          set fish_color_redirection cyan --bold
          set fish_color_end green
          set fish_color_error brred
          set fish_color_param cyan
          set fish_color_comment red
          set fish_color_match --background=brblue
          set fish_color_selection white --bold --background=brblack
          set fish_color_search_match bryellow --background=brblack
          set fish_color_history_current --bold
          set fish_color_operator brcyan
          set fish_color_escape brcyan
          set fish_color_cwd green
          set fish_color_cwd_root red
          set fish_color_valid_path --underline
          set fish_color_autosuggestion white
          set fish_color_user brgreen
          set fish_color_host normal
          set fish_color_cancel --reverse
          set fish_pager_color_prefix normal --bold --underline
          set fish_pager_color_progress brwhite --background=cyan
          set fish_pager_color_completion normal
          set fish_pager_color_description B3A06D --italics
          set fish_pager_color_selected_background --reverse
          set fish_cursor_default block blink
          set fish_cursor_insert line blink
          set fish_cursor_replace_one underscore blink
        '';
      };
    };
}
