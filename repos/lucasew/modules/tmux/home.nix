{ pkgs, ... }:
{
  programs.tmux = {
    keyMode = "vi";
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
