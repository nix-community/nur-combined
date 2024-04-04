{ osConfig, ... }:
{
  programs.starship = {
    enable = !osConfig.programs.starship.enable;
    enableNushellIntegration = false;

    settings = {
      add_newline = false;

      scan_timeout = 10;

      command_timeout = 1000;

      format = "$directory$git_branch$git_commit$git_status$cmd_duration$line_break$python$character";

      directory.style = "blue";

      character = {
        success_symbol = "[>](white)";
        error_symbol = "[>](red)";
        vicmd_symbol = "[<](green)";
        vimcmd_replace_one_symbol = "[<](bold purple)";
        vimcmd_replace_symbol = "[<](bold purple)";
        vimcmd_visual_symbol = "[<](bold yellow)";
      };

      hostname = {
        ssh_only = true;
        format = "[$hostname]($style) ";
        style = "#91b493";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style = "#f1c4cd";
      };

      git_commit = {
        format = "[$hash]($style) ";
        style = "#c8adc4";
        only_detached = false;
        tag_disabled = true;
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style) ";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = "\([$state( $progress_current/$progress_total)]($style)\) ";
        style = "bright-black";
      };

      directory = {
        truncation_length = 5;
        format = "[$path]($style) ";
      };

      cmd_duration = {
        format = "[$duration]($style)";
        style = "yellow";
      };
      python = {
        format = "[$virtualenv]($style)";
        style = "bright-black";
      };

      time = {
        disabled = false;
        format = "$time($style) ";
        time_format = "%T";
        style = "bold yellow";
        utc_time_offset = "-5";
      };

      nix_shell = {
        format = "[$symbol$state( \($name\))]($style) ";
      };
    };
  };
}
