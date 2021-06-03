# Hold down the `next page` button to scroll using the ball
{ config, lib, ... }:
let
  cfg = config.my.hardware.mx-ergo;
in
{
  options.my.hardware.mx-ergo = with lib; {
    enable = mkEnableOption "MX Ergo configuration";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.inputClassSections = [
      ''
        Identifier   "MX Ergo Mouse"
        MatchProduct "MX Ergo Mouse"
        Driver       "libinput"
        Option       "ScrollMethod"    "button"
        Option       "ScrollButton"    "9"
      ''
    ];
  };
}
