# https://starship.rs/config
{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.starship;
in

{
  options.abszero.programs.starship.enable = mkEnableOption "managing Starship";

  config.programs.starship = mkIf cfg.enable {
    enable = true;
    settings = {
      format = ''
        ($directory )($username$hostname )($cmd_duration )($jobs )$fill( $git_state)( $git_branch)( $nix_shell)( $direnv)
        $character
      '';

      directory = {
        format = "([$read_only]($read_only_style) )[$path]($style)";
        # Different format for git repos
        repo_root_format = "([$read_only]($read_only_style) )[]($repo_root_style) [$repo_root]($repo_root_style)[$path]($style)";
        read_only = "󰍁";
        truncation_symbol = "…/";
        # Set these two options so repo_root_format takes effect
        before_repo_root_style = "bold cyan";
        repo_root_style = "bold #bf5700";
      };
      username.format = "[$user]($style)";
      hostname.format = "@[$hostname]($style)";
      cmd_duration = {
        format = "[$duration]($style)";
        style = "bold blue";
        show_milliseconds = true;
        min_time = 1000;
        show_notifications = true;
        min_time_to_notify = 60000;
      };
      jobs = {
        format = "$symbol[$number]($style)";
        symbol = "󱓺";
        style = "bold bright-yellow";
      };

      fill.symbol = " ";

      git_state = {
        format = "[$state( $progress_current/$progress_total)]($style)";
        style = "bold #bf5700";
      };
      git_branch = {
        format = "[$symbol $branch]($style)";
        symbol = "󰘬";
        style = "bold #bf5700";
        ignore_branches = [
          "master"
          "main"
        ];
      };
      nix_shell = {
        format = "[$symbol $state]($style)";
        symbol = "";
      };
      direnv = {
        # TODO: Fix invalid allow status - possibly due to nix-direnv?
        # disabled = false;
        format = "$allowed$loaded";
        allowed_msg = "";
        denied_msg = "[󱏵](bold red)";
        loaded_msg = "[󰂖](bold purple)";
        unloaded_msg = "[󰂕](bold yellow)";
      };

      character = {
        success_symbol = "[󰘧](bold green)";
        error_symbol = "[󰘧](bold red)";
      };
    };
  };
}
