# Hold down the `next page` button to scroll using the ball
{ config, lib, ... }:
let
  cfg = config.my.hardware.trackball;
in
{
  options.my.hardware.trackball = with lib; {
    enable = mkEnableOption "trackball configuration";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      # This section must be *after* the one configured by `libinput`
      # for the `ScrollMethod` configuration to not be overridden
      inputClassSections = lib.mkAfter [
        # MX Ergo
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
