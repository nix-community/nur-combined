{ config, lib, ... }:
let
  cfg = config.programs.bat;
in
{
  config = lib.mkIf cfg.enable {
    catppuccin.bat = {
      enable = true;
      flavor = config.catppuccin.flavor;
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
    home.shellAliases = {
      cat = "bat -pp";
    };
  };
}
