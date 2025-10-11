{ config, lib, ... }:

with lib;

let

  bmi260 = config.boot.kernelPackages.callPackage ../pkgs/linux/bmi260/package.nix { };

in
{

  meta.maintainers = [ maintainers.Cryolitia ];

  boot.extraModulePackages = [ bmi260 ];
  boot.kernelModules = [
    "aic8800_fdrv"
    "aic_btusb"
    "aic_load_fw"
  ];
}
