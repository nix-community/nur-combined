{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.sigprof.hardware.printers.driver.hplip;
in {
  options.sigprof.hardware.printers.driver.hplip = {
    enable = mkEnableOption "the 'hplip' printer driver";
    enablePlugin = mkEnableOption "the unfree plugin in the 'hplip' printer driver";
    package = mkPackageOption pkgs "hplip" {};
  };

  config = mkIf cfg.enable {
    services.printing.drivers = [
      (cfg.package.override {
        withPlugin = cfg.enablePlugin;
      })
    ];
    sigprof.nixpkgs.permittedUnfreePackages = mkIf cfg.enablePlugin [
      "hplip"
    ];
  };
}
