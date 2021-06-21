{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.tmux;
in
{
  options.my.home.tmux = with lib; {
    enable = mkEnableOption "tmux dotfiles";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      terminal = "screen-256color";
      clock24 = true;

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.cpu;
          extraConfig = ''
            set -g status-right 'CPU: #{cpu_percentage} | %a %d-%h %H:%M '
          '';
        }
        {
          plugin = tmuxPlugins.tmux-colors-solarized;
          extraConfig = ''
            set -g @colors-solarized 'light'
          '';
        }
      ];
    };
  };
}
