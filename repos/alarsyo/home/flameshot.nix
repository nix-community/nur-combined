{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.flameshot;
in {
  options.my.home.flameshot = {
    enable = mkEnableOption "flameshot autolaunch";
  };

  config.services.flameshot = mkIf cfg.enable {
    enable = true;
  };
}
