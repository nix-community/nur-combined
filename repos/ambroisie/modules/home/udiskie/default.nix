{ config, lib, ... }:
let
  cfg = config.my.home.udiskie;
in
{
  options.my.home.udiskie = with lib; {
    enable = mkEnableOption "udiskie configuration";
  };

  config.services.udiskie = lib.mkIf cfg.enable {
    enable = true;
  };
}
