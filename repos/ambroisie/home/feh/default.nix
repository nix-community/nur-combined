{ config, lib, ... }:
let
  cfg = config.my.home.feh;
in
{
  options.my.home.feh = with lib; {
    enable = mkEnableOption "feh configuration";
  };

  config.programs.feh = lib.mkIf cfg.enable {
    enable = true;
  };
}
