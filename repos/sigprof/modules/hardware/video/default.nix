{lib, ...}: let
  inherit (lib) mdDoc mkOption types;
in {
  options = {
    sigprof.hardware.video.uiScale = mkOption {
      type = types.either types.float types.ints.positive;
      description = mdDoc "UI scaling factor for the default display.";
      default = 1;
    };
  };
}
