{ config, lib, ... }:
let
  cfg = config.my.home.dircolors;
in
{
  options.my.home.dircolors = with lib; {
    enable = my.mkDisableOption "dircolors configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.dircolors = {
      enable = true;
    };
  };
}
