# ZSA keyboard udev rules
{ config, lib, ... }:
let
  cfg = config.my.hardware.ergodox;
in
{
  options.my.hardware.ergodox = with lib; {
    enable = mkEnableOption "ZSA udev rules and user group configuration";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.zsa.enable = true;
  };
}
