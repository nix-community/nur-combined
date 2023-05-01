{ config, lib, ... }:
let
  cfg = config.my.home.dircolors;
in
{
  options.my.home.dircolors = with lib; {
    enable = my.mkDisableOption "dircolors configuration";
  };

  config = {
    programs.dircolors = {
      enable = true;
    };
  };
}
