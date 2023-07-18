# starship prompt: <https://starship.rs/config/#prompt>
# my own config heavily based off:
# - <https://starship.rs/presets/pastel-powerline.html>
{ config, lib, pkgs, ...}:

let
  enabled = config.sane.zsh.starship;
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
  config = lib.mkIf config.sane.zsh.starship {
    sane.programs.zsh = lib.mkIf enabled {
      fs.".config/zsh/.zshrc".symlink.text = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';
      fs.".config/starship.toml".symlink.target = toml.generate "starship.toml" {
        format = builtins.concatStringsSep "" [
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
  };
}
