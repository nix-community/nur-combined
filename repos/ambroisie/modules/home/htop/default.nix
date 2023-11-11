{ config, lib, ... }:
let
  cfg = config.my.home.htop;
in
{
  options.my.home.htop = with lib; {
    enable = my.mkDisableOption "htop configuration";
  };

  config.programs.htop = lib.mkIf cfg.enable {
    enable = true;
  };
}
