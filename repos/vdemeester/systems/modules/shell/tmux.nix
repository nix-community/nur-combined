{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.shell.tmux;
in
{
  options.modules.shell.tmux = {
    enable = mkEnableOption "enable tmux";
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      escapeTime = 0;
      terminal = "tmux-256color";
    };
  };
}
