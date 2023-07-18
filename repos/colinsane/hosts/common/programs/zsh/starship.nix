# starship prompt: <https://starship.rs/config/#prompt>
# my own config heavily based off:
# - <https://starship.rs/presets/pastel-powerline.html>
{ config, lib, pkgs, ...}:

let
  enabled = config.sane.zsh.starship;
  toml = pkgs.formats.toml {};
in {
  config = lib.mkIf config.sane.zsh.starship {
    sane.programs.zsh = lib.mkIf enabled {
      fs.".config/zsh/.zshrc".symlink.text = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';
      fs.".config/starship.toml".symlink.target = toml.generate "starship.toml" {
        format = builtins.concatStringsSep "" [
          "[](#9A348E)"
          "$os"
          "$username"
          "$hostname"
          "[](bg:#DA627D fg:#9A348E)"
          "$directory"
          "[](fg:#DA627D bg:#FCA17D)"
          "$git_branch"
          "$git_status"
          "[](fg:#FCA17D bg:#86BBD8)"
          "[](fg:#86BBD8 bg:#06969A)"
          "[](fg:#06969A bg:#33658A)"
          "$time"
          "$status"
          "[ ](fg:#33658A)"
        ];
        add_newline = false;  # no blank line before prompt

        os.style = "bg:#9A348E";
        os.format = "[$symbol]($style)";
        os.disabled = false;
        # os.symbols.NixOS = "❄️";  # removes the space after logo

        # TODO: tune foreground color of username
        username.style_user = "bg:#9A348E";
        username.style_root = "bold bg:#9A348E";
        username.format = "[$user]($style)";

        hostname.style = "bold bg:#9A348E";
        hostname.format = "[$ssh_symbol$hostname]($style)";

        directory.style = "bg:#DA627D fg:#ffffff";
        directory.format = "[ $path ]($style)";
        directory.truncation_length = 3;
        directory.truncation_symbol = "…/";

        # git_branch.symbol = "";  # looks good in nerd fonts
        git_branch.symbol = "";
        git_branch.style = "bg:#FCA17D fg:#ffffff";
        # git_branch.style = "bg:#FF8262";
        git_branch.format = "[ $symbol $branch ]($style)";

        git_status.style = "bold bg:#FCA17D fg:#ffffff";
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
        time.style = "bg:#33658A";
        time.format = "[ $time ]($style)";

        status.disabled = false;
        status.style = "bg:#33658A";
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
