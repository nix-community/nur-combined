{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.tmux;
in {
  options.my.home.tmux = {
    enable = (mkEnableOption "tmux dotfiles") // {default = true;};
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      escapeTime = 0;
      baseIndex = 1;
      terminal = "screen-256color";
      clock24 = true;

      plugins = let
        inherit (pkgs) tmuxPlugins;
      in [
        {
          plugin = tmuxPlugins.cpu;
          extraConfig = ''
            set -g status-right 'CPU: #{cpu_percentage} | %a %d-%h %H:%M '
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'latte'
            set -g @catppuccin_window_status_style "rounded"
          '';
        }
      ];
    };
  };
}
