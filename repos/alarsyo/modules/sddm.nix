{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.displayManager.sddm;
in {
  options.my.displayManager.sddm.enable = mkEnableOption "SDDM setup";

  config = mkIf cfg.enable {
    services.xserver.displayManager.sddm = {
      enable = true;
      theme = "sugar-candy";
    };

    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs.packages)
        sddm-sugar-candy
        ;

      inherit
        (pkgs.libsForQt5.qt5)
        qtgraphicaleffects
        qtquickcontrols2
        qtsvg
        ;
    };
  };
}
