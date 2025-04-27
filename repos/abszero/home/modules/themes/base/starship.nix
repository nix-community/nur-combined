# https://starship.rs/config
{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.starship;
in

{
  options.abszero.themes.base.starship.enable = mkEnableOption "managing Starship";

  config.programs.starship.settings = mkIf cfg.enable {
    format = ''
      ($directory )($git_branch )($jobs )($cmd_duration)$fill($git_state)( $nodejs)( $rust)( $nix_shell)
      ($username$hostname )$character
    '';

    # region Head Left

    directory = {
      format = "[[($read_only )$path]($style inverted)]($style)";
      # Different format for git repos
      repo_root_format = "[[($read_only ) $repo_root$path]($repo_root_style inverted)]($repo_root_style)";
      read_only = "󰍁";
      truncation_symbol = "…/";
      # Set these two options so repo_root_format takes effect
      before_repo_root_style = "";
      repo_root_style = "bold yellow";
    };
    git_branch = {
      format = "[[$symbol $branch]($style inverted)]($style)";
      symbol = "󰘬";
      style = "bold red";
      ignore_branches = [
        "HEAD"
        "master"
        "main"
      ];
    };
    jobs = {
      format = "[[$symbol $number]($style inverted)]($style)";
      symbol = "󱓺";
      style = "bold pink";
    };
    cmd_duration = {
      format = "[[󰅐 $duration]($style inverted)]($style)";
      style = "bold blue";
      show_milliseconds = true;
      min_time = 1000;
      show_notifications = true;
      min_time_to_notify = 60000;
    };

    # endregion

    fill.symbol = " ";

    # region Head Right

    git_state = {
      format = "[[󰘭 $state( $progress_current/$progress_total)]($style inverted)]($style)";
      rebase = "rebasing";
      merge = "merging";
      revert = "reverting";
      cherry_pick = "cherry-picking";
      bisect = "bisecting";
      am = "am'ing";
      am_or_rebase = "am/rebasing";
      style = "bold red";
    };
    nodejs = {
      format = "[[$symbol( $version)]($style inverted)]($style)";
      symbol = "󰎙";
    };
    rust = {
      format = "[[$symbol( $version)]($style inverted)]($style)";
      symbol = "󱘗";
    };
    nix_shell = {
      # NOTE: state doesn't display if wrapped in parentheses
      format = "[[$symbol $state]($style inverted)]($style)";
      symbol = "";
      unknown_msg = "env";
    };
    # FIXME: invalid allow status - possibly due to nix-direnv?
    # direnv = {
    #   # disabled = false;
    #   format = "$allowed$loaded";
    #   allowed_msg = "";
    #   denied_msg = "[󱏵](bold red)";
    #   loaded_msg = "[󰂖](bold purple)";
    #   unloaded_msg = "[󰂕](bold yellow)";
    # };

    # endregion
    # region Prompt Left

    username.format = "[$user]($style)";
    hostname.format = "@[$hostname]($style)";
    character = {
      success_symbol = "[󰘧](bold green)";
      error_symbol = "[󰘧](bold red)";
    };

    # endregion
  };
}
