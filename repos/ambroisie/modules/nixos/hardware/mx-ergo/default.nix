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
    services.xserver = {
      # This section must be *after* the one configured by `libinput`
      # for the `ScrollMethod` configuration to not be overriden
      inputClassSections = lib.mkAfter [
        ''
          Identifier      "MX Ergo scroll button configuration"
          MatchProduct    "MX Ergo"
          MatchIsPointer  "on"
          Option          "ScrollMethod"    "button"
          Option          "ScrollButton"    "9"
        ''
      ];
    };
  };
}
