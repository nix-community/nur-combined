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
          plugin = tmuxPlugins.tmux-colors-solarized;
          extraConfig = ''
            set -g @colors-solarized 'light'
          '';
        }
      ];
    };
  };
}
