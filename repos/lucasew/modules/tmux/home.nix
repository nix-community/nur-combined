{ pkgs, ... }:
let
  inherit (builtins) readFile;
in
{
  programs.tmux = {
    keyMode = "vi";
    extraConfig = readFile ./tmux.conf;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-dir '~/.config/tmux'
        '';
      }
      {
        plugin = continuum;
      }
    ];
  };
}
