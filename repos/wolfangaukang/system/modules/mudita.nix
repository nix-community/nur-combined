{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    ;
  cfg = config.hardware.mudita;

in
{
  options.hardware.mudita.enable = mkEnableOption "Mudita Kompakt support";

  config = mkIf cfg.enable (mkMerge [
    { environment.systemPackages = [ pkgs.mudita-center ]; }
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      services.udev.extraRules = ''
        # Mudita devices
        SUBSYSTEM=="tty", ATTRS{idVendor}=="3310", ATTRS{idProduct}=="2012", MODE="0666"
      '';
    })
  ]);
}
