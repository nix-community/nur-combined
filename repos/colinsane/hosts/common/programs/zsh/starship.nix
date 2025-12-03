# starship prompt: <https://starship.rs/config/#prompt>
# my own config heavily based off:
# - <https://starship.rs/presets/pastel-powerline.html>
{ config, lib, pkgs, ...}:

let
  enabled = config.sane.programs.zsh.config.starship;
  toml = pkgs.formats.toml {};
  colors = {
    # colors sorted by the order they appear in the status bar
    _01_purple = "#9A348E";
    _02_pink = "#DA627D";
    _03_orange = "#FCA17D";
    _04_teal = "#86BBD8";
    _05_blue = "#06969A";
    _06_blue = "#33658A";
  };
in {
  sane.programs.zsh.fs = lib.mkIf enabled {
    ".config/zsh/rc.d/10-starship".symlink.text = ''
      eval "$(${lib.getExe pkgs.starship} init zsh)"
    '';
    ".config/starship.toml".symlink.target = let
      x1b = builtins.fromJSON '' "\u001b" '';  # i.e `^[`
      set = opt: "${x1b}\\[?${opt}h";
      clear = opt: "${x1b}\\[?${opt}l";
    in toml.generate "starship.toml" {
      format = builtins.concatStringsSep "" [
        # reset terminal mode (in case the previous command screwed with it)
        # 'l' = turn option of, 'h' = turn option on.
        #
        # options are enumerated in Alacritty's VTE library's `PrivateMode` type:
        # - <https://github.com/alacritty/vte/blob/ebc4a4d7259678a8626f5c269ea9348dfc3e79b2/src/ansi.rs#L845>
        # see also the reset code path (does a bit too much, like clearing the screen):
        # - <https://github.com/alacritty/alacritty/blob/6067787763e663bd308e5b724a5efafc2c54a3d1/alacritty_terminal/src/term/mod.rs#L1802>
        # and the crucial TermMode::default: <https://github.com/alacritty/alacritty/blob/master/alacritty_terminal/src/term/mod.rs#L113>
        #
        # query the state of any mode bit `<n>` with `printf '\033[?<n>$p'`
        # e.g. `printf '\033[?7$p'` returns `^[[?7;1$y` with the `1` indicating it's **set**,
        #      `printf '\033[?1000$p'` returns `^[[?1000;2$y` with the `2` indicating it's **unset**.
        #
        # TODO: unset Line mode and Insert mode?
        (clear "1")      # Cursor Keys
        # (clear "3")    # Column Mode (i.e. clear screen/history)
        (clear "6")      # Origin
        (set "7")        # Line Wrap
        (clear "12")     # Blinking Cursor
        (set "25")       # Show Cursor
        (clear "1000")   # Report Mouse Clicks
        (clear "1002")   # Report Cell Mouse Motion
        (clear "1003")   # Report All Mouse Motion
        (clear "1004")   # Report Focus In/Out
        (clear "1005")   # UTF8 Mouse
        (clear "1006")   # Sgr Mouse
        (set "1007")     # Alternate Scroll
        (set "1042")     # Urgency Hints
        # (clear "1049") # Swap Screen And Set Restore Cursor
        (clear "2004")   # Bracketed Paste
        (clear "2026")   # Sync Update

        # prompt
        "[](${colors._01_purple})"
        "$os"
        "$username"
        "$hostname"
        "[](bg:${colors._02_pink} fg:${colors._01_purple})"
        "$directory"
        "[](fg:${colors._02_pink} bg:${colors._03_orange})"
        "$git_branch"
        "$git_status"
        "[](fg:${colors._03_orange} bg:${colors._04_teal})"
        "[](fg:${colors._04_teal} bg:${colors._05_blue})"
        "[](fg:${colors._05_blue} bg:${colors._06_blue})"
        "$time"
        "$status"
        "[ ](fg:${colors._06_blue})"
      ];
      add_newline = false;  # no blank line before prompt

      os.style = "bg:${colors._01_purple}";
      os.format = "[$symbol]($style)";
      os.disabled = false;
      # os.symbols.NixOS = "❄️";  # removes the space after logo

      # TODO: tune foreground color of username
      username.style_user = "bg:${colors._01_purple}";
      username.style_root = "bold bg:${colors._01_purple}";
      username.format = "[$user ]($style)";

      hostname.style = "bold bg:${colors._01_purple}";
      hostname.format = "[$ssh_symbol$hostname ]($style)";

      directory.style = "bg:${colors._02_pink} fg:#ffffff";
      directory.format = "[ $path ]($style)";
      directory.truncation_length = 3;
      directory.truncation_symbol = "…/";

      # git_branch.symbol = "";  # looks good in nerd fonts
      git_branch.symbol = "";
      git_branch.style = "bg:${colors._03_orange} fg:#ffffff";
      # git_branch.style = "bg:#FF8262";
      git_branch.format = "[ $symbol $branch ]($style)";

      git_status.style = "bold bg:${colors._03_orange} fg:#ffffff";
      # git_status.style = "bg:#FF8262";
      git_status.format = "[$all_status$ahead_behind ]($style)";
      git_status.ahead = "⇡$count";
      git_status.behind = "⇣$count";
      # git_status.diverged = "⇣$behind_count⇡$ahead_count";
      git_status.diverged = "⇡$ahead_count⇣$behind_count";
      git_status.modified = "*";
      git_status.stashed = "";
      git_status.untracked = "";


      time.disabled = true;
      time.time_format = "%R"; # Hour:Minute Format
      time.style = "bg:${colors._06_blue}";
      time.format = "[ $time ]($style)";

      status.disabled = false;
      status.style = "bg:${colors._06_blue}";
      # status.success_symbol = "♥ ";
      # status.success_symbol = "💖";
      # status.success_symbol = "💙";
      # status.success_symbol = "💚";
      # status.success_symbol = "💜";
      # status.success_symbol = "✔️'";
      status.success_symbol = "";
      status.symbol = "❌";
      # status.symbol = "❗️";
      # status.symbol = "‼️";
      status.format = "[$symbol]($style)";
    };
  };
}
