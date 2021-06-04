{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.tmux;
in
{
  options.my.home.tmux = with lib; {
    enable = mkEnableOption "tmux dotfiles";
  };

  config.programs.tmux = lib.mkIf cfg.enable {
    enable = true;
    baseIndex = 1;
    terminal = "screen-256color";
  };
}
