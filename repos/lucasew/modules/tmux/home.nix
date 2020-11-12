{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
