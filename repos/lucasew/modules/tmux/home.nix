{ pkgs, ... }:
let
  inherit (builtins) readFile;
in
{
  programs.tmux = {
    keyMode = "vi";
    extraConfig = readFile ./tmux.conf;
  };
}
